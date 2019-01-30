is_snowing = true
is_raining = false
local changeupdate = 1  --checks if player position changed every x seconds

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

	label="removesnow",
	nodenames = {"snow:snowfall"},
	interval = 1,
	chance = 1,
	action=function(pos)
		--print("removing")
		if is_snowing == false then
			--print("removing")
			minetest.remove_node(pos)
		end
	end,
}

minetest.register_abm{
        label = "snowfall",
	nodenames = {"snow:snowfall"},
	interval = 3,
	chance = 100,
	action = function(pos)
			pos.y = pos.y - 1
			local node = minetest.get_node(pos).name
			if node ~= "air" and node ~= "snow:snowfall" and minetest.get_item_group(node, "liquid") ~= 0 and node ~= "default:snow" then
				pos.y = pos.y + 1
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
				aspect_w = 64,
				aspect_h = 64,
				length = 3,
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

	label="removerain",
	nodenames = {"snow:rainfall"},
	interval = 1,
	chance = 1,
	action=function(pos)
		--print("removing")
		if is_raining == false then
			--print("removing")
			minetest.remove_node(pos)
		end
	end,
}

minetest.register_abm{
        label = "rainfall",
	nodenames = {"snow:rainfall"},
	interval = 3,
	chance = 100,
	action = function(pos)
			pos.y = pos.y - 1
			local node = minetest.get_node(pos).name
			if node ~= "air" and node ~= "snow:rainfall" and minetest.get_item_group(node, "liquid") ~= 0 and node ~= "default:snow" then
				pos.y = pos.y + 1
				minetest.set_node(pos,{name="default:water_flowing", param2 = 10})
			end
	end,
}

--------------------------------------------------------------------
local snow = {} --the class
snow.playertable = {} --the player table

--get player node position on joining
minetest.register_on_joinplayer(function(player)
	local playerpos = player:getpos()
	--get center of node
	snow.playertable[player:get_player_name()] ={x=math.floor(playerpos.x+0.5),y=math.floor(playerpos.y+0.5),z=math.floor(playerpos.z+0.5)}
	--print(dump(snow.playertable[player:get_player_name()]))
	snow.make_snow_around_player(snow.playertable[player:get_player_name()])
end)

--check if player has moved nodes
local changetimer = 0
minetest.register_globalstep(function(dtime)
	--add to timer to prevent extreme lag
	changetimer = changetimer + dtime
	if changetimer >= changeupdate then
		for _,player in pairs(minetest.get_connected_players()) do
			if player:get_player_name() then
					--print("checking "..player:get_player_name())
					changetimer = 0
					--only snow if snowing
					if is_snowing == true then
					--	print("IT IS SNOWING")
						--get required info
						local playerpos = player:getpos()
						local exactplayerpos = {x=math.floor(playerpos.x+0.5),y=math.floor(playerpos.y+0.5),z=math.floor(playerpos.z+0.5)}
						local tablepos = snow.playertable[player:get_player_name()]
						--do some maths and check if new position, if so, update
						if tablepos.x ~= exactplayerpos.x or tablepos.y ~= exactplayerpos.y or tablepos.z ~= exactplayerpos.z then
						--	print(player:get_player_name().."'s position has changed! updating!")
							snow.playertable[player:get_player_name()] = exactplayerpos
							snow.make_snow_around_player(exactplayerpos)
						end
					elseif is_raining == true then
							--print("IT IS RAINING")
							--get required info
							local playerpos = player:getpos()
							local exactplayerpos = {x=math.floor(playerpos.x+0.5),y=math.floor(playerpos.y+0.5),z=math.floor(playerpos.z+0.5)}
							local tablepos = snow.playertable[player:get_player_name()]
							--do some maths and check if new position, if so, update
							if tablepos.x ~= exactplayerpos.x or tablepos.y ~= exactplayerpos.y or tablepos.z ~= exactplayerpos.z then
							--	print(player:get_player_name().."'s position has changed! updating!")
								snow.playertable[player:get_player_name()] = exactplayerpos
								snow.make_snow_around_player(exactplayerpos)
							end
					end
			end
		end
	end
end)

--this checks and makes snow fall
snow.make_snow_around_player = function(pos)
		local range = 50
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

		local percip = 0
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

				--if n.name ~= "air" then
				if n == "air" and l >= 15 then
					data[p_pos] = percip
				elseif n == "snow:snowfall" and l < 15 then
					data[p_pos] = air
				end
			end
		end
		end
		end

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
end
