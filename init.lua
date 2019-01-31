local mod_storage = minetest.get_mod_storage()
local snow = {} --the class

snow.playertable = {} --the player table

is_snowing = false
is_raining = false
local changeupdate = 1  --checks if player position changed every x seconds
local snowrange = 20

-----------------------------------------------------------------------------------------
--texture tile style (strange)
minetest.register_node("snow:snowfall", {
	description = "H@CK3R",
	drawtype = "plantlike",
	visual_scale = 1.4,
	waving = true,
	--tiles = {"default_papyrus.png"},
	tiles = {
		{
			name = "snowfallhd.png",

			animation = {
				type = "vertical_frames",
				aspect_w = 64,
				aspect_h = 64,
				length = 3,
			},
			align_style="user"
		},
},
	inventory_image = "default_papyrus.png",
	wield_image = "default_papyrus.png",
	paramtype = "light",
  pointable = false,
  diggable = false,
	buildable_to = true,
	floodable = true,
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {0, 0, 0, 0, 0, 0},
	},
	groups = {snow=1},
})
--move this to voxelmanip
--make snow form
minetest.register_abm{
  label = "snowfall",
	nodenames = {"snow:snowfall"},
	interval = 1,
	chance = 300, --300 seems to be good
	action = function(pos)
			pos.y = pos.y - 1
			local node = minetest.get_node(pos).name
			--snow on top of node
			if node ~= "air" and node ~= "snow:snowfall" and minetest.get_item_group(node, "liquid") == 0 and node ~= "default:snow" and minetest.registered_nodes[node]["buildable_to"] == false then
				pos.y = pos.y + 1
				minetest.set_node(pos,{name="default:snow"})
			--replace node if buildable to
		elseif node ~= "air" and node ~= "snow:snowfall" and minetest.get_item_group(node, "liquid") == 0 and node ~= "default:snow" and minetest.registered_nodes[node]["buildable_to"] == true then
				minetest.set_node(pos,{name="default:snow"})
			end
	end,
}
-----------------------------------------------------------------------------------------------
minetest.register_node("snow:rainfall", {
	description = "H@CK3R",
	drawtype = "plantlike",
	visual_scale = 1.4,
	waving = true,
	--tiles = {"default_papyrus.png"},
	tiles = {
		{
			name = "rainfall.png",

			animation = {
				type = "vertical_frames",
				aspect_w = 256,
				aspect_h = 256,
				length = 1,
			},
		},
},
	inventory_image = "default_papyrus.png",
	wield_image = "default_papyrus.png",
	paramtype = "light",
  pointable = false,
  diggable = false,
	buildable_to = true,
	floodable = true,
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {0, 0, 0, 0, 0, 0},
	},
	groups = {snow=1},
})
--make snow form
minetest.register_abm{
        label = "rainfall",
	nodenames = {"snow:rainfall"},
	interval = 1,
	chance = 50,
	action = function(pos)
		pos.y = pos.y - 1
		local node = minetest.get_node(pos).name
		--water on top of node
		if node ~= "air" and node ~= "snow:rainfall" and minetest.get_item_group(node, "liquid") == 0 and node ~= "default:snow" and minetest.registered_nodes[node]["buildable_to"] == false then
				pos.y = pos.y + 1
				minetest.set_node(pos,{name="default:water_flowing",param2=3})
			--replace node if buildable to
		elseif node ~= "air" and node ~= "snow:rainfall" and minetest.get_item_group(node, "liquid") == 0 and minetest.registered_nodes[node]["buildable_to"] == true then
				minetest.set_node(pos,{name="default:water_flowing",param2=3})
			end
	end,
}

--------------------------------------------------------------------

--check if player has moved nodes
local changetimer = 0
local old_weather = 0
minetest.register_globalstep(function(dtime)
	--add to timer to prevent extreme lag
	changetimer = changetimer + dtime
	if changetimer >= changeupdate then
		for _,player in pairs(minetest.get_connected_players()) do
			if player:get_player_name() then
					--print("checking "..player:get_player_name())
					changetimer = 0
					--only snow if snowing
						--get required info
						--snow or rain
					local oldpos = snow.playertable[player:get_player_name()]
					if is_snowing == true or is_raining == true then
						local playerpos = player:getpos()
						local exactplayerpos = {x=math.floor(playerpos.x+0.5),y=math.floor(playerpos.y+0.5),z=math.floor(playerpos.z+0.5)}

						--if position moved clear old weather
						if oldpos.x ~= exactplayerpos.x or oldpos.y ~= exactplayerpos.y or oldpos.z ~= exactplayerpos.z then
								if oldpos.x then --stop crashes
									snow.clear_old_snow(oldpos)
									snow.set_ms_pos(exactplayerpos,player)
								end
								--print("clearing old weather")
						end
						--then make new weather
						snow.make_snow_around_player(exactplayerpos)

						--this acts as old position
						snow.playertable[player:get_player_name()] = exactplayerpos

						old_weather = 1 --do this so that it doesn't try to clear weather every loop
					--clear up snow
				elseif old_weather == 1 then
						local playerpos = player:getpos()
						local exactplayerpos = {x=math.floor(playerpos.x+0.5),y=math.floor(playerpos.y+0.5),z=math.floor(playerpos.z+0.5)}
						snow.clear_old_snow(oldpos)
						--this acts as old position
						snow.playertable[player:get_player_name()] = exactplayerpos
						old_weather = 0
					end
			end
		end
	end
end)

---------------------------------------------------------------------------

--this checks and makes snow fall nodes
snow.make_snow_around_player = function(pos)
		local range = snowrange
		local air = minetest.get_content_id("air")
		local snow = minetest.get_content_id("snow:snowfall")
		local rain = minetest.get_content_id("snow:rainfall")
		local water = minetest.get_content_id("default:water_source")

		local min = {x=pos.x-range,y=pos.y-range,z=pos.z-range}
		local max = {x=pos.x+range,y=pos.y+range,z=pos.z+range}
		local vm = minetest.get_voxel_manip()
		local emin, emax = vm:read_from_map(min,max)
		local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
		local data = vm:get_data()
		local lightdata = vm:get_light_data()
		local content_id = minetest.get_name_from_content_id

		--this sets if snow or rain
		local percip
		if is_snowing == true then
			percip = snowing
		elseif is_raining == true then
			percip = rain
		end

		for x=-range, range do
		for y=-range, range do
		for z=-range, range do
			if vector.distance(pos, vector.add(pos, {x=x, y=y, z=z})) <= range then
				local p_pos = area:index(pos.x+x,pos.y+y,pos.z+z)
				local n = content_id(data[p_pos])
				local l = lightdata[p_pos]
				--sets the data
				if n == "air" and l >= 15 then
					local lightleveltest = minetest.get_node_light({x=pos.x+x,y=pos.y+y,z=pos.z+z}, 0.5)
					--print(lightleveltest)
					if lightleveltest and lightleveltest >= 15 then
						data[p_pos] = percip
					else
						data[p_pos] = air
					end
				elseif (n == "snow:snowfall" and l < 15) or (n == "snow:rainfall" and l < 15)  then
					data[p_pos] = air --this makes the snow adapt to the environment
				end
			end
		end
		end
		end

		vm:set_data(data)
		vm:write_to_map()
end

--this checks and removes old nodes
snow.clear_old_snow = function(pos)
		local range = snowrange
		local air = minetest.get_content_id("air")
		local snow = minetest.get_content_id("snow:snowfall")
		local rain = minetest.get_content_id("snow:rainfall")


		local min = {x=pos.x-range,y=pos.y-range,z=pos.z-range}
		local max = {x=pos.x+range,y=pos.y+range,z=pos.z+range}
		local vm = minetest.get_voxel_manip()
		local emin, emax = vm:read_from_map(min,max)
		local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
		local data = vm:get_data()
		local content_id = minetest.get_name_from_content_id

		for x=-range, range do
		for y=-range, range do
		for z=-range, range do
			if vector.distance(pos, vector.add(pos, {x=x, y=y, z=z})) <= range then
				local p_pos = area:index(pos.x+x,pos.y+y,pos.z+z)
				local n = content_id(data[p_pos])
				--sets the data
				if n == "snow:snowfall" or n == "snow:rainfall" then
					data[p_pos] = air --this clears old snow
				end
			end
		end
		end
		end

		vm:set_data(data)
		vm:write_to_map()
end


--commands
minetest.register_chatcommand("rain", {
	params = "<text>",
	description = "make it rain",
	privs = {server = true},
	func = function( _ , text)
		is_raining = true
		is_snowing = false
	end,
})
minetest.register_chatcommand("snow", {
	params = "<text>",
	description = "make it rain",
	privs = {server = true},
	func = function( _ , text)
		is_raining = false
		is_snowing = true
	end,
})
minetest.register_chatcommand("clear", {
	params = "<text>",
	description = "make it rain",
	privs = {server = true},
	func = function( _ , text)
		is_raining = false
		is_snowing = false
	end,
})

------------------------------------- additional helpers

--remove snow when player leaves!
minetest.register_on_leaveplayer(function(player)
	print("clearing "..player:get_player_name().."'s weather")

	--clear old snow in current and last position(if there)
	local playerpos = player:getpos()
	local exactplayerpos = {x=math.floor(playerpos.x+0.5),y=math.floor(playerpos.y+0.5),z=math.floor(playerpos.z+0.5)}
	snow.clear_old_snow(exactplayerpos)

	if snow.playertable[player:get_player_name()] then
		snow.clear_old_snow(snow.playertable[player:get_player_name()])
	end
	snow.set_ms_pos(exactplayerpos,player)
end)

--remove snow when player leaves!
--get player node position on joining
minetest.register_on_joinplayer(function(player)
	print("clearing "..player:get_player_name().."'s weather")

	--clear old snow in current pos
	local playerpos = player:getpos()
	local exactplayerpos = {x=math.floor(playerpos.x+0.5),y=math.floor(playerpos.y+0.5),z=math.floor(playerpos.z+0.5)}
	snow.clear_old_snow(exactplayerpos)


	--remove old snow in last position

	if snow.get_ms_pos(player) then
		snow.clear_old_snow(snow.get_ms_pos(player))
	end

	snow.set_ms_pos(exactplayerpos,player)
	snow.playertable[player:get_player_name()] = exactplayerpos
end)


--helpers for position in mod storage
snow.set_ms_pos = function(pos,player)
	mod_storage:set_string(player:get_player_name().."_pos", minetest.pos_to_string(pos, 0))
end

snow.get_ms_pos = function(player)
	return(minetest.string_to_pos(mod_storage:get_string(player:get_player_name().."_pos")))
end

















--
