size = {831,146}

local sevenSegment = loadFont("7Segment.otf")
local arial = loadFont("arial.ttf")

createGlobalPropertyi("RV-6/engine/indicators/fuel_quantity_mode",1)

defineProperty("manifoldpressure", globalPropertyfa("sim/cockpit2/engine/indicators/MPR_in_hg"))
defineProperty("rpm", globalPropertyfa("sim/cockpit2/engine/indicators/prop_speed_rpm"))
defineProperty("oiltemp", globalPropertyfa("sim/cockpit2/engine/indicators/oil_temperature_deg_C"))
defineProperty("busvolts",globalPropertyfa("sim/cockpit2/electrical/bus_volts"))
defineProperty("fuelflow", globalPropertyfa("sim/cockpit2/engine/indicators/fuel_flow_kg_sec"))
defineProperty("fuelweight", globalPropertyfa("sim/cockpit2/fuel/fuel_quantity"))

defineProperty("fuelquantitymode", globalPropertyf("RV-6/engine/indicators/fuel_quantity_mode"))

function rgbColour(r,g,b)
	return {r/255,g/255,b/255}
end

function draw()
	drawAll(components)
	if get(fuelquantitymode) == 0 then --Left
		drawText(sevenSegment, 275, 20, string.format("%4i",get(fuelweight,1)*2.2), 30,false,true,TEXT_ALIGN_LEFT) --Fuel Quantity
	elseif get(fuelquantitymode) == 1 then --Both
		drawText(sevenSegment, 275, 20, string.format("%4i",(get(fuelweight,1)+get(fuelweight,2))*2.2), 30,false,true,TEXT_ALIGN_LEFT) --Fuel Quantity
	elseif get(fuelquantitymode) == 2 then --Right
		drawText(sevenSegment, 275, 20, string.format("%4i",get(fuelweight,2)*2.2), 30,false,true,TEXT_ALIGN_LEFT) --Fuel Quantity
	end
	drawText(sevenSegment, 383, 20, string.format("%4i",get(oiltemp,1)), 30,false,true,TEXT_ALIGN_LEFT) --Oil T and P
	drawText(sevenSegment, 275, 93, string.format("%4.1f",get(manifoldpressure,1)), 30,false,true,TEXT_ALIGN_LEFT) --Manifold Pressure
	drawText(sevenSegment, 383, 93, string.format("%4i",get(rpm,1)), 30,false,true,TEXT_ALIGN_LEFT) --RPM
	drawText(sevenSegment, 500, 22, string.format("%5.1f",get(fuelflow,1)*2.2*3600), 35,false,true,TEXT_ALIGN_LEFT) --Fuel Monitor
	drawText(sevenSegment, 500, 83, string.format("%5.1f",get(busvolts,1)), 35,false,true,TEXT_ALIGN_LEFT) --Ammeter
	drawText(sevenSegment, 672, 22, "888.8", 35,false,true,TEXT_ALIGN_LEFT) --Clock
	drawText(sevenSegment, 668, 82, string.format("%4.1f",8), 20,false,true,TEXT_ALIGN_LEFT) --Temp Left
	drawText(sevenSegment, 752, 82, "8888", 20,false,true,TEXT_ALIGN_LEFT) --Temp Right
end