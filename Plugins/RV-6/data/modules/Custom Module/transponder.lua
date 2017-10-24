size = {479,111}

local sevenSegment = loadFont("7Segment.otf")
--local sevenSegment = loadFont("arial.ttf")
local arial = loadFont("arial.ttf")

createGlobalPropertyf("RV-6/radio/transponder/standard_barometric_altitude",0)
createGlobalPropertyi("RV-6/radio/transponder/flight_level",0)
createGlobalPropertyi("RV-6/radio/transponder/vfr_mode",0)
createGlobalPropertyi("RV-6/radio/transponder/last_code",0)

defineProperty("pressure", globalPropertyf("sim/weather/barometer_current_inhg"))
defineProperty("altitude", globalPropertyf("RV-6/radio/transponder/standard_barometric_altitude"))
defineProperty("flightlevel", globalPropertyi("RV-6/radio/transponder/flight_level"))
defineProperty("vfrmode", globalPropertyi("RV-6/radio/transponder/vfr_mode"))
defineProperty("currentcode", globalPropertyi("sim/cockpit2/radios/actuators/transponder_code"))
defineProperty("lastcode", globalPropertyi("RV-6/radio/transponder/last_code"))
defineProperty("squwak",globalPropertyi("sim/cockpit2/radios/indicators/transponder_id"))
defineProperty("mode",globalPropertyi("sim/cockpit2/radios/actuators/transponder_mode"))
defineProperty("avionicsswitch",globalPropertyi("sim/cockpit2/switches/avionics_power_on"))
defineProperty("bus2power",globalPropertyfae("sim/cockpit2/electrical/bus_volts",2))
defineProperty("bus2extra",globalPropertyfae("sim/cockpit2/electrical/plugin_bus_load_amps",2))


function rgbColour(r,g,b)
	return {r/255,g/255,b/255}
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function vfrModeHandler(phase) -- phase equals: 0 on press; 1 while holding; 2 on release
	if 0 == phase then
		--Future alterations to add the press and hold functionality.
		if get(vfrmode) == 0 then
			set(lastcode,get(currentcode))
			set(currentcode,1200)
			set(vfrmode,1)
		else
			set(currentcode,get(lastcode))
			set(vfrmode,0)
		end
	end
	return 0
end

local vfrMode = sasl.createCommand("RV-6/radio/transponder/vfr_button", "Toggles VFR Mode")
registerCommandHandler(vfrMode, 0, vfrModeHandler)

--These functions are to handle the order that the functions are in on the transponder dial.
function xpndrUpHandler(phase) -- phase equals: 0 on press; 1 while holding; 2 on release
	if 0 == phase then
		if get(mode) == 0 then
			set(mode,1)
		elseif get(mode) == 1 then
			set(mode,4)
		elseif get(mode) == 4 then
			set(mode,2)
		elseif get(mode) == 2 then
			set(mode,3)
		end 
	end
	return 0
end

local xpndrUp = sasl.createCommand("RV-6/radio/transponder/mode_up", "Positive XPNDR Mode")
registerCommandHandler(xpndrUp, 0, xpndrUpHandler)

function xpndrDnHandler(phase) -- phase equals: 0 on press; 1 while holding; 2 on release
	if 0 == phase then
		if get(mode) == 1 then
			set(mode,0)
		elseif get(mode) == 4 then
			set(mode,1)
		elseif get(mode) == 2 then
			set(mode,4)
		elseif get(mode) == 3 then
			set(mode,2)
		end 
	end
	return 0
end

local xpndrDn = sasl.createCommand("RV-6/radio/transponder/mode_down", "Negative XPNDR Mode")
registerCommandHandler(xpndrDn, 0, xpndrDnHandler)

function update()
	--Determine the FL, this transponder doesn't round to 5. Typically you need to have an encoding altimeter fitted, 
	--will attempt to simulate at some point.
	set(altitude,145442.1609230769 * (((29.92126 / get(pressure)) ^ 0.19026643566373184768498208549422) - 1))
	--altitude = (288.15 / 0.0065) * (((29.92/pressure)^(1/5.257))  - 1)
	set(flightlevel,round(get(altitude)/100,0))
	
	--Subtracts the amp drain when transponder is off, this will eventually move to an electrical systems code set.
	if get(mode) == 0 then
		set(bus2extra,-0.5)
	else
		set(bus2extra,0)
	end
	
	--Caters for if the mode somehow gets set to Ground = 5, will reset to standby.
	if get(mode) == 5 then
		set(mode,2)
	end
	
	updateAll(components)
end

local quartz_colour = rgbColour(255,153,0)
local shadow_colour = rgbColour(32,19,0)

function draw()
	drawAll(components)
	drawRectangle (0, 0, 479, 111, rgbColour(0,0,0))
	drawText(sevenSegment, 310, 36, "8888", 30,false,true,TEXT_ALIGN_LEFT,shadow_colour)
	drawText(sevenSegment, 80, 36, "888", 30,false,true,TEXT_ALIGN_LEFT,shadow_colour)
	drawText(arial, 285, 55, "R", 14,true,false,TEXT_ALIGN_LEFT,shadow_colour)
	drawText(arial, 190, 55, "ALT", 14,true,false,TEXT_ALIGN_LEFT,shadow_colour)
	drawText(arial, 48, 30, "FL", 14,true,false,TEXT_ALIGN_LEFT,shadow_colour)
	if get(avionicsswitch) == 1 and get(bus2power) > 11 then
		if get(mode) == 4 then
			drawText(sevenSegment, 310, 36, "8888", 30,false,true,TEXT_ALIGN_LEFT,quartz_colour)
			drawText(sevenSegment, 80, 36, "888", 30,false,true,TEXT_ALIGN_LEFT,quartz_colour)
			drawText(arial, 285, 55, "R", 14,true,false,TEXT_ALIGN_LEFT,quartz_colour)
			drawText(arial, 190, 55, "ALT", 14,true,false,TEXT_ALIGN_LEFT,quartz_colour)
			drawText(arial, 48, 30, "FL", 14,true,false,TEXT_ALIGN_LEFT,quartz_colour)
		elseif get(mode) == 1 or get(mode) == 2 or get(mode) == 3 or get(mode) == 5 then
			drawText(sevenSegment, 310, 36, string.format("%i",get(currentcode)), 30,false,true,TEXT_ALIGN_LEFT,quartz_colour) -- number id , number x , number y , string text , number size , boolean isBold , boolean isItalic , TextAlignment alignment , Color color
			drawText(sevenSegment, 80, 36, string.format("%03i",get(flightlevel)), 30,false,true,TEXT_ALIGN_LEFT,quartz_colour)
			if get(squwak) == 1 then
				drawText(arial, 285, 55, "R", 14,true,false,TEXT_ALIGN_LEFT,quartz_colour)
			end
			if get(mode) == 3 then
				drawText(arial, 190, 55, "ALT", 14,true,false,TEXT_ALIGN_LEFT,quartz_colour)
			end
			drawText(arial, 48, 30, "FL", 14,true,false,TEXT_ALIGN_LEFT,quartz_colour)
		end
	end
end