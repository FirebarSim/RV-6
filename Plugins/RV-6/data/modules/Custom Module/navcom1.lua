size = {723,100}

local arial = loadFont("arial.ttf")
local sixteenSegment = loadFont("16Segment.otf")
local sevenSegment = loadFont("7Segment.otf")

createGlobalPropertyi("RV-6/radio/com/com1_mode",0) -- 0 = off, 1 = normal, 2 = active entry, 3 = channel select, 4 = channel program, 
createGlobalPropertyi("RV-6/radio/com/com1_last_mode",0)
createGlobalPropertyfa("RV-6/radio/com/com1_ch",32) -- saved com channels
createGlobalPropertyi("RV-6/radio/nav/nav1_mode",0) -- 0 = off, 1 = normal, 2 = active entry

defineProperty("com1freq", globalPropertyf("sim/cockpit2/radios/actuators/com1_frequency_hz"))
defineProperty("com1stby", globalPropertyf("sim/cockpit2/radios/actuators/com1_standby_frequency_hz"))
defineProperty("com1mode", globalPropertyi("RV-6/radio/com/com1_mode"))
defineProperty("com1power",globalPropertyi("sim/cockpit2/radios/actuators/com1_power"))
defineProperty("com1last", globalPropertyi("RV-6/radio/com/com1_last_mode"))
defineProperty("nav1freq", globalPropertyf("sim/cockpit2/radios/actuators/nav1_frequency_hz"))
defineProperty("nav1stby", globalPropertyf("sim/cockpit2/radios/actuators/nav1_standby_frequency_hz"))
defineProperty("nav1mode", globalPropertyi("RV-6/radio/nav/nav1_mode"))
defineProperty("nav1power",globalPropertyi("sim/cockpit2/radios/actuators/nav1_power"))
defineProperty("globaltime",globalPropertyf("sim/time/total_flight_time_sec"))

function rgbColour(r,g,b)
	return {r/255,g/255,b/255}
end

local quartz_colour = rgbColour(255, 153, 0)

function navcomPowerHandler(phase)
	if phase == 0 then
		if get(com1mode) == 0 then
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
			else
				set(com1mode,1)
			end
			flips = 1
		end
	elseif phase == 2 then
		if get(globaltime) - temp < 2 then
			if get(com1mode) == 2 then
				set(com1mode,1)
			else
				commandOnce(com1Flip)
			end
		end
	end
end

local com1Transfer = createCommand("RV-6/radio/navcom/com1_transfer", "Press - Switch Frequencies, Hold - Enter Channel Mode")
registerCommandHandler(com1Transfer,0, com1TransferHandler)

function com1CoarseUpHandler(phase)
	if phase == 0 then
		if get(com1mode) == 0 then
		
		elseif get(com1mode) == 1 then
			commandOnce(findCommand("sim/radios/stby_com1_coarse_up"))
		elseif get(com1mode) == 2 then
			commandOnce(findCommand("sim/radios/actv_com1_coarse_up"))
		end
	end
end

local com1CoarseUp = createCommand("RV-6/radio/navcom/com1_coarse_up", "Large Knob Up")
registerCommandHandler(com1CoarseUp,0, com1CoarseUpHandler)

function com1CoarseDnHandler(phase)
	if phase == 0 then
		if get(com1mode) == 0 then
		
		elseif get(com1mode) == 1 then
			commandOnce(findCommand("sim/radios/stby_com1_coarse_down"))
		elseif get(com1mode) == 2 then
			commandOnce(findCommand("sim/radios/actv_com1_coarse_down"))
		end
	end
end

local com1CoarseDn = createCommand("RV-6/radio/navcom/com1_coarse_dn", "Large Knob Down")
registerCommandHandler(com1CoarseDn,0, com1CoarseDnHandler)

function com1FineUpHandler(phase)
	if phase == 0 then
		if get(com1mode) == 0 then
		
		elseif get(com1mode) == 1 then
			commandOnce(findCommand("sim/radios/stby_com1_fine_up"))
		elseif get(com1mode) == 2 then
			commandOnce(findCommand("sim/radios/actv_com1_fine_up"))
		end
	end
end

local com1FineUp = createCommand("RV-6/radio/navcom/com1_fine_up", "Small Knob Up")
registerCommandHandler(com1FineUp,0, com1FineUpHandler)

function com1FineDnHandler(phase)
	if phase == 0 then
		if get(com1mode) == 0 then
		
		elseif get(com1mode) == 1 then
			commandOnce(findCommand("sim/radios/stby_com1_fine_down"))
		elseif get(com1mode) == 2 then
			commandOnce(findCommand("sim/radios/actv_com1_fine_down"))
		end
	end
end

local com1FineDn = createCommand("RV-6/radio/navcom/com1_fine_dn", "Small Knob Down")
registerCommandHandler(com1FineDn,0, com1FineDnHandler)

function com1ChannelHandler(phase)
--	if phase == 0 then
--		temp = get(globaltime)
--		flips = 0
--	elseif phase == 1 then
--		if get(globaltime) - temp > 2 and flips < 1 then
--			if get(com1mode) == 1 or get(com1mode) == 2 then
--				set(com1last,get(com1mode))
--				set(com1mode,3)
--			else
--				set(com1mode,get(com1last))
--			end
--			flips = 1
--		end
--	elseif phase == 2 then
--		if get(com1mode) == 3 then
--			set(com1mode,get(com1last))
--		end
--	end
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
		
		elseif get(nav1mode) == 1 then
			commandOnce(findCommand("sim/radios/stby_nav1_fine_up"))
		elseif get(nav1mode) == 2 then
			commandOnce(findCommand("sim/radios/actv_nav1_fine_up"))
		end
	end
end

local nav1FineUp = createCommand("RV-6/radio/navcom/nav1_fine_up", "Small Knob Up")
registerCommandHandler(nav1FineUp,0, nav1FineUpHandler)

function nav1FineDnHandler(phase)
	if phase == 0 then
		if get(nav1mode) == 0 then
		
		elseif get(nav1mode) == 1 then
			commandOnce(findCommand("sim/radios/stby_nav1_fine_down"))
		elseif get(nav1mode) == 2 then
			commandOnce(findCommand("sim/radios/actv_nav1_fine_down"))
		end
	end
end

local nav1FineDn = createCommand("RV-6/radio/navcom/nav1_fine_dn", "Small Knob Down")
registerCommandHandler(nav1FineDn,0, nav1FineDnHandler)

function draw()
	drawAll(components)
	--drawRectangle(0,0,723,100,rgbColour(0,0,0))
	drawRectangle(0,0,723,100,rgbColour(32,19,0))
	drawText(sixteenSegment,165,15,"FLAG",30,false,true,TEXT_ALIGN_RIGHT,quartz_colour)
	drawText(sevenSegment,165,55,string.format("%3.2f",get(com1freq)/100),30,false,true,TEXT_ALIGN_RIGHT,quartz_colour)
	drawText(sevenSegment,215,55,string.format("%6.2f",get(com1stby)/100),30,false,true,TEXT_ALIGN_LEFT,quartz_colour)
	drawText(sixteenSegment,395,15,"FLAG",30,false,true,TEXT_ALIGN_LEFT,quartz_colour)
	drawText(sevenSegment,395,55,string.format("%3.2f",get(nav1freq)/100),30,false,true,TEXT_ALIGN_LEFT,quartz_colour)
	drawText(sevenSegment,575,55,string.format("%6.2f",get(nav1stby)/100),30,false,true,TEXT_ALIGN_LEFT,quartz_colour)
	drawCircle(10,10,5,true,rgbColour(0,255,0))
end