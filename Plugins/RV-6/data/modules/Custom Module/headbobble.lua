defineProperty("head_x", globalPropertyf("sim/graphics/view/pilots_head_x"))
defineProperty("head_y", globalPropertyf("sim/graphics/view/pilots_head_y"))
defineProperty("head_z", globalPropertyf("sim/graphics/view/pilots_head_z"))
defineProperty("a_x", globalPropertyf("sim/flightmodel/position/local_ax"))
defineProperty("a_y", globalPropertyf("sim/flightmodel/position/local_ay"))
defineProperty("a_z", globalPropertyf("sim/flightmodel/position/local_az"))
defineProperty("globaltime",globalPropertyf("sim/time/total_flight_time_sec"))

local pos_x = -0.213360
local pos_y = 0.701040
local pos_z = 0.670560
local amp_linear = 0.01
local amp_radial = 3

function update()
	set(head_x,pos_x+(amp_linear*math.atan(0.1*get(a_x))/(math.pi/2)))
	set(head_y,pos_y+(amp_linear*math.atan(0.1*get(a_y))/(math.pi/2)))
	set(head_z,pos_z+(amp_linear*math.atan(0.1*get(a_z))/(math.pi/2)))
end