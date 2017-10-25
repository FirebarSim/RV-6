size = {723,100}

local arial = loadFont("arial.ttf")
local sixteenSegment = loadFont("16Segment.otf")
--local sixteenSegment = loadFont("quartz.ttf")
local sevenSegment = loadFont("7Segment.otf")
--local sevenSegment = loadFont("quartz.ttf")

createGlobalPropertyi("RV-6/radio/navcom/com1_mode",1) -- 1 = normal, 2 = active entry, 3 = channel select, 4 = channel program, 
createGlobalPropertyi("RV-6/radio/navcom/com1_last_mode",0)
createGlobalPropertyi("RV-6/radio/navcom/com1_fineout",0)
createGlobalPropertyfa("RV-6/radio/navcom/com1_ch",32) -- saved com channels
createGlobalPropertyi("RV-6/radio/navcom/nav1_mode",1)
createGlobalPropertyi("RV-6/radio/navcom/nav1_fineout",0) -- 1 = normal, 2 = active entry
createGlobalPropertyf("RV-6/radio/navcom/total_navcom_time_sec",0)

defineProperty("com1freq", globalPropertyf("sim/cockpit2/radios/actuators/com1_frequency_hz"))
defineProperty("com1stby", globalPropertyf("sim/cockpit2/radios/actuators/com1_standby_frequency_hz"))
defineProperty("com1mode", globalPropertyi("RV-6/radio/navcom/com1_mode"))
defineProperty("com1power",globalPropertyi("sim/cockpit2/radios/actuators/com1_power"))
defineProperty("com1last", globalPropertyi("RV-6/radio/navcom/com1_last_mode"))
com1ch = globalPropertyfa("RV-6/radio/navcom/com1_ch")
defineProperty("nav1freq", globalPropertyf("sim/cockpit2/radios/actuators/nav1_frequency_hz"))
defineProperty("nav1stby", globalPropertyf("sim/cockpit2/radios/actuators/nav1_standby_frequency_hz"))
defineProperty("nav1mode", globalPropertyi("RV-6/radio/navcom/nav1_mode"))
defineProperty("nav1power",globalPropertyi("sim/cockpit2/radios/actuators/nav1_power"))
defineProperty("nav1hdefcopilot", globalPropertyf("sim/cockpit2/radios/indicators/nav1_hdef_dots_pilot"))
defineProperty("nav1flag", globalPropertyi("sim/cockpit2/radios/indicators/nav1_display_horizontal"))
defineProperty("nav1obscopilot", globalPropertyf("sim/cockpit2/radios/actuators/nav1_obs_deg_mag_pilot"))
defineProperty("nav1type", globalPropertyi("sim/cockpit2/radios/indicators/nav1_type"))
defineProperty("globaltime",globalPropertyf("sim/time/total_flight_time_sec"))
defineProperty("timeperiod", globalPropertyf("sim/operation/misc/frame_rate_period"))
defineProperty("elapsedtime",globalPropertyf("RV-6/radio/navcom/total_navcom_time_sec"))

local channel_number = 1

set(nav1power,get(com1power)) -- Initialise Power Values

function rgbColour(r,g,b)
	return {r/255,g/255,b/255}
end

local quartz_colour = rgbColour(255, 153, 0)
local shadow_colour = rgbColour(32,19,0)

function navcomPowerHandler(phase)
	if phase == 0 then
		if get(com1power) == 0 then
			set(com1power,1)
			set(nav1power,1)
		else
			set(com1power,0)
			set(nav1power,0)
		end
	end
end

local navcomPower = createCommand("RV-6/radio/navcom/navcom1_power_toggle", "Toggles Power to Nav Com 1")
registerCommandHandler(navcomPower,0, navcomPowerHandler)

function com1TransferHandler(phase)
	local com1Flip = findCommand("sim/radios/com1_standy_flip")
	if phase == 0 then
		temp = get(globaltime)
		flips = 0
	elseif phase == 1 then
		if get(globaltime) - temp > 2 and flips < 1 then
			if get(com1mode) == 1 then
				set(com1mode,2)
			elseif get(com1mode) == 2 then
				set(com1mode,1)
			elseif get(com1mode) == 3 then
				set(com1freq,get(com1ch,channel_number))
			elseif get(com1mode) == 4 then
				set(com1mode,5)
			elseif get(com1mode) == 5 then
				set(com1mode,4)
			end
			flips = 1
		end
	elseif phase == 2 then
		if get(globaltime) - temp < 2 then
			if get(com1mode) == 1 then
				commandOnce(com1Flip)
			elseif get(com1mode) == 2 then
				set(com1mode,1)
			elseif get(com1mode) == 3 then
				set(com1freq,get(com1ch,channel_number))
			elseif get(com1mode) == 4 then
				set(com1mode,5)
			elseif get(com1mode) == 5 then
				set(com1mode,4)
			end
		end
	end
end

local com1Transfer = createCommand("RV-6/radio/navcom/com1_transfer", "Press - Switch Frequencies, Hold - Enter Channel Mode")
registerCommandHandler(com1Transfer,0, com1TransferHandler)

function com1CoarseUpHandler(phase)
	if phase == 0 then
		if get(com1mode) == 1 then
			commandOnce(findCommand("sim/radios/stby_com1_coarse_up"))
		elseif get(com1mode) == 2 then
			commandOnce(findCommand("sim/radios/actv_com1_coarse_up"))
		elseif get(com1mode) == 5 then
			--Program Freq
			if get(com1ch,channel_number - 1) == 0 then
				set(com1ch,11800,channel_number - 1)
			elseif get(com1ch,channel_number - 1) >= 13600 then
				set(com1ch,0,channel_number - 1)
			else
				set(com1ch,get(com1ch,channel_number) + 100,channel_number - 1)
			end
		end
	end
end

local com1CoarseUp = createCommand("RV-6/radio/navcom/com1_coarse_up", "Large Knob Up")
registerCommandHandler(com1CoarseUp,0, com1CoarseUpHandler)

function com1CoarseDnHandler(phase)
	if phase == 0 then
		if get(com1mode) == 1 then
			commandOnce(findCommand("sim/radios/stby_com1_coarse_down"))
		elseif get(com1mode) == 2 then
			commandOnce(findCommand("sim/radios/actv_com1_coarse_down"))
		elseif get(com1mode) == 5 then
			--Program Freq
			if get(com1ch,channel_number - 1) == 0 then
				set(com1ch,13600,channel_number - 1)
			elseif get(com1ch,channel_number - 1) <= 11800 then
				set(com1ch,0,channel_number - 1)
			else
				set(com1ch,get(com1ch,channel_number) - 100,channel_number - 1)
			end
		end
	end
end

local com1CoarseDn = createCommand("RV-6/radio/navcom/com1_coarse_dn", "Large Knob Down")
registerCommandHandler(com1CoarseDn,0, com1CoarseDnHandler)

function com1FineUpHandler(phase)
	if phase == 0 then
		if get(com1mode) == 1 then
			commandOnce(findCommand("sim/radios/stby_com1_fine_up"))
		elseif get(com1mode) == 2 then
			commandOnce(findCommand("sim/radios/actv_com1_fine_up"))
		elseif get(com1mode) == 3 and channel_number < 32 then
			channel_number = channel_number + 1
		elseif get(com1mode) == 4 and channel_number < 32 then
			channel_number = channel_number + 1
		elseif get(com1mode) == 5 then
			--Program Freq
			if get(com1ch,channel_number - 1) == 0 then
				set(com1ch,11800,channel_number - 1)
			elseif get(com1ch,channel_number - 1) >= 13697 then
				set(com1ch,0,channel_number - 1)
			else
				if get(com1ch,channel_number - 1) % 5 == 0 then
					set(com1ch,get(com1ch,channel_number) + 2,channel_number - 1)
				else
					set(com1ch,get(com1ch,channel_number) + 3,channel_number - 1)
				end
			end
		end
	end
end

local com1FineUp = createCommand("RV-6/radio/navcom/com1_fine_up", "Small Knob Up")
registerCommandHandler(com1FineUp,0, com1FineUpHandler)

function com1FineDnHandler(phase)
	if phase == 0 then
		if get(com1mode) == 1 then
			commandOnce(findCommand("sim/radios/stby_com1_fine_down"))
		elseif get(com1mode) == 2 then
			commandOnce(findCommand("sim/radios/actv_com1_fine_down"))
		elseif get(com1mode) == 3 and channel_number > 1 then
			channel_number = channel_number - 1
		elseif get(com1mode) == 4 and channel_number < 32 then
			channel_number = channel_number - 1
		elseif get(com1mode) == 5 then
			--Program Freq
			if get(com1ch,channel_number - 1) == 0 then
				set(com1ch,13697,channel_number - 1)
			elseif get(com1ch,channel_number) <= 11800 then
				set(com1ch,0,channel_number)
			else
				set(com1ch,get(com1ch,channel_number - 1) - 2.5,channel_number - 1)
			end
		end
	end
end

local com1FineDn = createCommand("RV-6/radio/navcom/com1_fine_dn", "Small Knob Down")
registerCommandHandler(com1FineDn,0, com1FineDnHandler)

function com1ChannelHandler(phase)
	if phase == 0 then
		temp = get(globaltime)
		flips = 0
	elseif phase == 1 then
		if get(globaltime) - temp > 2 and flips < 1 then
			if get(com1mode) == 1 then
				set(com1last,get(com1mode))
				set(com1mode,4)
			elseif get(com1mode) == 2 then
				set(com1last,get(com1mode))
				set(com1mode,4)
			elseif get(com1mode) == 3 then
				set(com1last,get(com1mode))
				set(com1mode,4)
			elseif get(com1mode) == 4 then
				set(com1mode,get(com1last))
			elseif get(com1mode) == 5 then
				--Nothing
			end
			flips = 1
		end
	elseif phase == 2 then
		if get(globaltime) - temp < 2 then
			if get(com1mode) == 1 then
				set(com1last,get(com1mode))
				set(com1mode,3)
			elseif get(com1mode) == 2 then
				set(com1last,get(com1mode))
				set(com1mode,3)
			elseif get(com1mode) == 3 then
				set(com1mode,1)
			elseif get(com1mode) == 4 then
				set(com1mode,get(com1last))
			elseif get(com1mode) == 5 then
				--Nothing
			end
		end
	end
end

local com1Channel = createCommand("RV-6/radio/navcom/com1_channel", "Small Knob Down")
registerCommandHandler(com1Channel,0, com1ChannelHandler)

function nav1TransferHandler(phase)
	local nav1Flip = findCommand("sim/radios/nav1_standy_flip")
	if phase == 0 then
		temp = get(globaltime)
		flips = 0
	elseif phase == 1 then
		if get(globaltime) - temp > 2 and flips < 1 then
			if get(nav1mode) == 1 then
				set(nav1mode,2)
			else
				set(nav1mode,1)
			end
			flips = 1
		end
	elseif phase == 2 then
		if get(globaltime) - temp < 2 then
			if get(nav1mode) == 2 then
				set(nav1mode,1)
			else
				commandOnce(nav1Flip)
			end
		end
	end
end

local nav1Transfer = createCommand("RV-6/radio/navcom/nav1_transfer", "Press - Switch Frequencies, Hold - Enter Channel Mode")
registerCommandHandler(nav1Transfer,0, nav1TransferHandler)

function nav1CoarseUpHandler(phase)
	if phase == 0 then
		if get(nav1mode) == 0 then
		
		elseif get(nav1mode) == 1 then
			commandOnce(findCommand("sim/radios/stby_nav1_coarse_up"))
		elseif get(nav1mode) == 2 then
			commandOnce(findCommand("sim/radios/actv_nav1_coarse_up"))
		end
	end
end

local nav1CoarseUp = createCommand("RV-6/radio/navcom/nav1_coarse_up", "Large Knob Up")
registerCommandHandler(nav1CoarseUp,0, nav1CoarseUpHandler)

function nav1CoarseDnHandler(phase)
	if phase == 0 then
		if get(nav1mode) == 0 then
		
		elseif get(nav1mode) == 1 then
			commandOnce(findCommand("sim/radios/stby_nav1_coarse_down"))
		elseif get(nav1mode) == 2 then
			commandOnce(findCommand("sim/radios/actv_nav1_coarse_down"))
		end
	end
end

local nav1CoarseDn = createCommand("RV-6/radio/navcom/nav1_coarse_dn", "Large Knob Down")
registerCommandHandler(nav1CoarseDn,0, nav1CoarseDnHandler)

function nav1FineUpHandler(phase)
	if phase == 0 then
		if get(nav1mode) == 0 then
			set(nav1obscopilot,get(nav1obscopilot)+1)
		elseif get(nav1mode) == 1 then
			--commandOnce(findCommand("sim/radios/stby_nav1_fine_up"))
			set(nav1obscopilot,get(nav1obscopilot)+1)
		elseif get(nav1mode) == 2 then
			--commandOnce(findCommand("sim/radios/actv_nav1_fine_up"))
			set(nav1obscopilot,get(nav1obscopilot)+1)
		end
	end
end

local nav1FineUp = createCommand("RV-6/radio/navcom/nav1_fine_up", "Small Knob Up")
registerCommandHandler(nav1FineUp,0, nav1FineUpHandler)

function nav1FineDnHandler(phase)
	if phase == 0 then
		if get(nav1mode) == 0 then
			set(nav1obscopilot,get(nav1obscopilot)-1)
		elseif get(nav1mode) == 1 then
			--commandOnce(findCommand("sim/radios/stby_nav1_fine_down"))
			set(nav1obscopilot,get(nav1obscopilot)-1)
		elseif get(nav1mode) == 2 then
			--commandOnce(findCommand("sim/radios/actv_nav1_fine_down"))
			set(nav1obscopilot,get(nav1obscopilot)-1)
		end
	end
end

local nav1FineDn = createCommand("RV-6/radio/navcom/nav1_fine_dn", "Small Knob Down")
registerCommandHandler(nav1FineDn,0, nav1FineDnHandler)

function update()
	if get(com1power) == 1 then
		set(elapsedtime,get(elapsedtime)+get(timeperiod))
	else
		set(elapsedtime,0)
	end
	
	updateAll(components)
end

function draw()
	drawRectangle(0,0,723,100,rgbColour(0,0,0))
	if get(com1power) == 1 then
		--drawText(sixteenSegment,45,15,"FLAG",30,false,true,TEXT_ALIGN_LEFT,quartz_colour)
		--LCD Shadows
		drawText(sevenSegment,45,55,"888.88",30,false,true,TEXT_ALIGN_LEFT,shadow_colour)
		drawText(sevenSegment,215,55,"888.88",30,false,true,TEXT_ALIGN_LEFT,shadow_colour)
		drawText(sevenSegment,395,55,"888.88",30,false,true,TEXT_ALIGN_LEFT,shadow_colour)
		drawText(sevenSegment,575,55,"888.88",30,false,true,TEXT_ALIGN_LEFT,shadow_colour)
		drawText(sixteenSegment,215,15,"###:##",30,false,false,TEXT_ALIGN_LEFT,shadow_colour)
		drawText(sixteenSegment,380,15,"#############",30,false,false,TEXT_ALIGN_LEFT,shadow_colour) --13 Digits
		--Active Freqs
		drawText(sevenSegment,45,55,string.format("%3.2f",get(com1freq)/100),30,false,true,TEXT_ALIGN_LEFT,quartz_colour)
		drawText(sevenSegment,395,55,string.format("%3.2f",get(nav1freq)/100),30,false,true,TEXT_ALIGN_LEFT,quartz_colour)
		--Mode Displays
		if get(com1mode) == 1 then
			drawText(sevenSegment,215,55,string.format("%6.2f",get(com1stby)/100),30,false,true,TEXT_ALIGN_LEFT,quartz_colour)
		elseif get(com1mode) == 1 then
			--Nothing
		elseif get(com1mode) == 3 then
			drawText(sevenSegment,215,55,string.format("%06.2f",get(com1ch,channel_number - 1)/100),30,false,true,TEXT_ALIGN_LEFT,quartz_colour)
			drawText(sixteenSegment,215,15," CH:" .. channel_number .. "",30,false,false,TEXT_ALIGN_LEFT,quartz_colour)
		elseif get(com1mode) == 4 then
			drawText(sevenSegment,215,55,string.format("%06.2f",get(com1ch,channel_number - 1)/100),30,false,true,TEXT_ALIGN_LEFT,quartz_colour)
			drawText(sixteenSegment,215,15," PG:",30,false,false,TEXT_ALIGN_LEFT,quartz_colour)
			if get(globaltime) % 1 > 0.5 then
				drawText(sixteenSegment,215,15,"   :" .. channel_number .. "",30,false,false,TEXT_ALIGN_LEFT,quartz_colour)
			end
		elseif get(com1mode) == 5 then
			if get(globaltime) % 1 > 0.5 then
				drawText(sevenSegment,215,55,string.format("%06.2f",get(com1ch,channel_number - 1)/100),30,false,true,TEXT_ALIGN_LEFT,quartz_colour)
			end
			drawText(sixteenSegment,215,15," PG:" .. channel_number .. "",30,false,false,TEXT_ALIGN_LEFT,quartz_colour)
		end
		
		if get(nav1mode) == 1 then
			--Normal Mode
			--drawText(sevenSegment,575,55,string.format("%6.2f",get(nav1stby)/100),30,false,true,TEXT_ALIGN_LEFT,quartz_colour)
		elseif get(nav1mode) == 2 then
			--Direct Entry Mode
		elseif get(nav1mode) == 3 then
			--CDI Mode
			if get(nav1type) == 40 then
				drawText(sevenSegment,575,55,"  L_0C",30,false,true,TEXT_ALIGN_LEFT,quartz_colour)
			else
				drawText(sevenSegment,575,55,"  " .. string.format("%01.2f",get(nav1obscopilot)/100):gsub("%.","_"),30,false,true,TEXT_ALIGN_LEFT,quartz_colour)
			end
			if get(nav1flag) == 1 then
				if get(nav1hdefcopilot) < -2.25 then
					drawText(sixteenSegment,380,15,"-+----X------",30,false,false,TEXT_ALIGN_LEFT,quartz_colour) --13 Digits
				elseif get(nav1hdefcopilot) < -1.75 then
					drawText(sixteenSegment,380,15,"--+---X------",30,false,false,TEXT_ALIGN_LEFT,quartz_colour) --13 Digits
				elseif get(nav1hdefcopilot) < -1.25 then
					drawText(sixteenSegment,380,15,"---+--X------",30,false,false,TEXT_ALIGN_LEFT,quartz_colour) --13 Digits
				elseif get(nav1hdefcopilot) < -0.75 then
					drawText(sixteenSegment,380,15,"----+-X------",30,false,false,TEXT_ALIGN_LEFT,quartz_colour) --13 Digits
				elseif get(nav1hdefcopilot) < -0.25 then
					drawText(sixteenSegment,380,15,"-----+X------",30,false,false,TEXT_ALIGN_LEFT,quartz_colour) --13 Digits
				elseif get(nav1hdefcopilot) < 0.25 then
					drawText(sixteenSegment,380,15,"------@------",30,false,false,TEXT_ALIGN_LEFT,quartz_colour) --13 Digits
				elseif get(nav1hdefcopilot) < 0.75 then
					drawText(sixteenSegment,380,15,"------X+-----",30,false,false,TEXT_ALIGN_LEFT,quartz_colour) --13 Digits
				elseif get(nav1hdefcopilot) < 1.25 then
					drawText(sixteenSegment,380,15,"------X-+----",30,false,false,TEXT_ALIGN_LEFT,quartz_colour) --13 Digits
				elseif get(nav1hdefcopilot) < 1.75 then
					drawText(sixteenSegment,380,15,"------X--+---",30,false,false,TEXT_ALIGN_LEFT,quartz_colour) --13 Digits
				elseif get(nav1hdefcopilot) < 2.25 then
					drawText(sixteenSegment,380,15,"------X---+--",30,false,false,TEXT_ALIGN_LEFT,quartz_colour) --13 Digits
				else
					drawText(sixteenSegment,380,15,"------X----+-",30,false,false,TEXT_ALIGN_LEFT,quartz_colour) --13 Digits
				end
			else
				drawText(sixteenSegment,380,15," FLAG ------",30,false,false,TEXT_ALIGN_LEFT,quartz_colour)
			end
		end
		--Test Segments
		drawText(sevenSegment,575,55,string.format("% 3i",math.floor(math.abs(get(elapsedtime))/60)) .. ":" .. string.format("%02i",math.floor(math.abs(get(elapsedtime))) % 60),30,false,true,TEXT_ALIGN_LEFT,quartz_colour)
	end
	drawAll(components)
end