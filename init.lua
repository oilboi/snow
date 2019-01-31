local snow = {} --the class
snow.playertable = {} --the player table

local snowfallradius = 120
local snowfallheight = 30
local snowchance = 0.95 --0.99 is best

--particles stuff
local radius = 15
local height = 10
local amountofsnow = 400
local snowvelocity = 0.5
local snowfallvelocity = {-1,-3}

local timer = 0
local timerexpire = 2
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer > timerexpire then
	timer = 0
	for _,player in pairs(minetest.get_connected_players()) do
		if player:get_player_name() then
      local playerpos = player:getpos()
      local exactplayerpos = {x=math.floor(playerpos.x+0.5),y=math.floor(playerpos.y+0.5),z=math.floor(playerpos.z+0.5)}
      local oldpos = snow.playertable[player:get_player_name()]

      --make snow
    	--if oldpos and (oldpos.x ~= exactplayerpos.x or oldpos.y ~= exactplayerpos.y or oldpos.z ~= exactplayerpos.z) then
        --CHANGE SPAWNERS
        --snow.check_nodes(playerpos, player:get_player_name())
				snow.make_snow_fall(playerpos)
      --end

      snow.playertable[player:get_player_name()] = exactplayerpos
    end
  end
end
end)


minetest.register_on_joinplayer(function(player)
  local playerpos = player:getpos()
	local exactplayerpos = {x=math.floor(playerpos.x+0.5),y=math.floor(playerpos.y+0.5),z=math.floor(playerpos.z+0.5)}

	snow.playertable[player:get_player_name()] = exactplayerpos

	player:set_sky("grey", "plain", "", false)

	minetest.add_particlespawner({
			amount = amountofsnow,
			-- Number of particles spawned over the time period `time`.

			time = 0,
			-- Lifespan of spawner in seconds.
			-- If time is 0 spawner has infinite lifespan and spawns the `amount` on
			-- a per-second basis.

			minpos = {x=-radius, y=0, z=-radius},
			maxpos = {x=radius, y=height, z=radius},
			minvel = {x=-snowvelocity, y=snowfallvelocity[1], z=-snowvelocity},
			maxvel = {x=snowvelocity, y=snowfallvelocity[2], z=snowvelocity},
			minacc = {x=0, y=0, z=0},
			maxacc = {x=0, y=0, z=0},
			minexptime = 1,
			maxexptime = 1,
			minsize = 1,
			maxsize = 1,
			-- The particles' properties are random values between the min and max
			-- values.
			-- pos, velocity, acceleration, expirationtime, size

			collisiondetection = true,
			-- If true collide with `walkable` nodes and, depending on the
			-- `object_collision` field, objects too.

			collision_removal = true,
			-- If true particles are removed when they collide.
			-- Requires collisiondetection = true to have any effect.

			object_collision = true,
			-- If true particles collide with objects that are defined as
			-- `physical = true,` and `collide_with_objects = true,`.
			-- Requires collisiondetection = true to have any effect.

			attached = player,
			-- If defined, particle positions, velocities and accelerations are
			-- relative to this object's position and yaw

			vertical = true,
			-- If true face player using y axis only

			texture = "snowflake.png",

			playername = player:get_player_name(),
			-- Optional, if specified spawns particles only on the player's client


			glow = 0
			-- Optional, specify particle self-luminescence in darkness.
			-- Values 0-14.
	})

end)

snow.check_nodes = function(pos,name)
	--[[
	for x=-snowfallradius,snowfallradius do
			for z=-snowfallradius,snowfallradius do
				if math.random() > snowchance then
					local superpos = {x=pos.x+x,y=pos.y+snowfallheight,z=pos.z+z}
					local lighttest = minetest.get_node_light(superpos, 0.5)
						if lighttest and lighttest >= 15 then
							--minetest.set_node(superpos, {name="snow:snow"})
							--minetest.spawn_falling_node(superpos)

						end
				  end
			  end
	end
	]]
end
--this function actually puts snow and rain on the ground
snow.make_snow_fall = function(pos)
	local range = snowfallradius
	local height = snowfallheight
	local air = minetest.get_content_id("air")
	local snowblock = minetest.get_content_id("snow:snow")
	local water = minetest.get_content_id("default:water_source")
	local ice = minetest.get_content_id("default:ice")

	local min = {x=pos.x-range,y=pos.y-height,z=pos.z-range}
	local max = {x=pos.x+range,y=pos.y+height,z=pos.z+range}
	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map(min,max)
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()
	local lightdata = vm:get_light_data()
	local content_id = minetest.get_name_from_content_id

	--this sets if snow or rain
	--[[
	local percip
	local deposit_block
	local param2er
	if is_snowing == true then
		percip = snowy
		deposit_block = snow_node
	elseif is_raining == true then
		percip = rain
		deposit_block = water_node
		param2er = 3
	end
	--save resources
	local p2data
	if param2er then
		 p2data = vm:get_param2_data()
	end
	]]
	----[[      minetest.set_node(pos,{name="default:water_flowing",param2=3}) THE PARAM2 OF WATER                             ]]-------------------------------HEY


	--this reconverts back to namestring for quick snow removal
	--local ctester = minetest.get_name_from_content_id(percip)
	print("tying")
	for x=-range, range do
	for y=-height, height do
	for z=-range, range do
		--if vector.distance(pos, vector.add(pos, {x=x, y=y, z=z})) <= range then
			--deposit snow randomly
			local test_deposit_chance = snowchance
			--if heavy_percip == true then
			--	test_deposit_chance = test_deposit_chance - 0.25 -- heavy percip
			--end
			if math.random() > test_deposit_chance then

				--the actual node being indexed
				local p_pos = area:index(pos.x+x,pos.y+y,pos.z+z)
				local l = lightdata[p_pos]

				if l ~= nil and l >= 15 then
					local n = content_id(data[p_pos])
					--the node above it (testing for place for snow and water)
					local p_pos_above = area:index(pos.x+x,pos.y+y+1,pos.z+z)
					local n_above
					if p_pos_above and data[p_pos_above] then
						n_above = content_id(data[p_pos_above])
					end

					local p_pos_below = area:index(pos.x+x,pos.y+y-1,pos.z+z)
					local n_below
					if p_pos_below and data[p_pos_below] then
						n_below = content_id(data[p_pos_below])
					end

					if n ~= "air" and n ~= "snow:snow" and n_above == "air" and minetest.registered_nodes[n]["buildable_to"] == true then
							data[p_pos] = snowblock
					elseif n == "air" and n_below ~= "air" and minetest.get_item_group(n, "liquid") == 0 and n_below ~= "snow:snow" and minetest.registered_nodes[n_below]["buildable_to"] == false then
						data[p_pos] = snowblock
					elseif n == "air" and n_below == "default:water_source" then
							data[p_pos_below] = ice
					end
				end
			end
		--end
	end
	end
	end

	vm:set_data(data)
	--if param2er then
	--	vm:set_param2_data(p2data)
	--end
	vm:write_to_map()
end
--override snow
--[[
minetest.register_on_mods_loaded(function()
	minetest.override_item("default:snow", {
		on_construct = function(pos)
				minetest.set_node(pos, {name = "snow:snow"})
		end,
	})
end)
]]--
minetest.register_lbm({
	name = "snow:replacesnow",
	nodenames = {"default:snow"},
	action = function(pos, node)
		minetest.set_node(pos, {name = "snow:snow"})
	end,
})
-------

minetest.register_node("snow:snow", {
	description = "Snow",
	tiles = {"default_snow.png"},
	inventory_image = "default_snowball.png",
	wield_image = "default_snowball.png",
	paramtype = "light",
	buildable_to = true,
	floodable = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
		},
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -7 / 16, 0.5},
		},
	},
	groups = {crumbly = 3, falling_node = 1, snowy = 1},
	sounds = default.node_sound_snow_defaults(),

	on_construct = function(pos)
		minetest.set_node(pos, {name = "default:snow"})
	end,
})
