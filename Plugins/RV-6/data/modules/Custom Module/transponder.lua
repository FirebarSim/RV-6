size = {479,111}

local quartz = sasl.gl.loadFont("quartz.ttf")

createGlobalPropertyf("RV-6/data/standard_barometric_altitude",0)
createGlobalPropertyi("RV-6/data/flight_level",0)
createGlobalPropertyi("RV-6/radio/transponder/vfr_mode",0)
createGlobalPropertyi("RV-6/radio/transponder/last_code",0)

defineProperty("pressure", globalPropertyf("sim/weather/barometer_current_inhg"))
defineProperty("altitude", globalPropertyf("RV-6/data/standard_barometric_altitude"))
defineProperty("flightlevel", globalPropertyi("RV-6/data/flight_level"))
defineProperty("vfrmode", globalPropertyi("RV-6/radio/transponder/vfr_mode"))
defineProperty("currentcode", globalPropertyi("sim/cockpit/radios/transponder_code"))
defineProperty("lastcode", globalPropertyi("RV-6/radio/transponder/last_code"))

local vfrMode = sasl.createCommand("RV-6/radio/transponder/vfr_button", "Toggles VFR Mode")

function rgbColour(r,g,b)
	return {r/255,g/255,b/255}
end

local quartz_colour = rgbColour(255,153,0)

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function vfrModeHandler(phase) -- phase equals: 0 on press; 1 while holding; 2 on release
	if 0 == phase then
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

sasl.registerCommandHandler(vfrMode, 0, vfrModeHandler)

function update()
	set(altitude,145442.1609230769 * (((29.92126 / get(pressure)) ^ 0.19026643566373184768498208549422) - 1))
	--altitude = (288.15 / 0.0065) * (((29.92/pressure)^(1/5.257))  - 1)
	--altitude = 44330.76923076923 * (((29.92126 / pressure)
	--top formula above includes factor to convert to feet
	
	set(flightlevel,round((get(altitude)/100)/5,0)*5)
	
	updateAll(components)
end

function draw()
	drawAll(components)
	drawText(quartz, 310, 36, string.format("%i",get(currentcode)), 45,false,true,TEXT_ALIGN_LEFT,quartz_colour) -- number id , number x , number y , string text , number size , boolean isBold , boolean isItalic , TextAlignment alignment , Color color
	drawText(quartz, 80, 36, string.format("%03i",get(flightlevel)), 45,false,true,TEXT_ALIGN_LEFT,quartz_colour)
end