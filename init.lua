--Spawn mod for Minetest
--Originally written by VanessaE (I think), rewritten by cheapie
--WTFPL

--Banish command
--Copyright 2016 Gabriel Pérez-Cerezo
--WTFPL

local spawn_spawnpos = minetest.setting_get_pos("static_spawnpoint")
local banish_pos = {x=5000, y=2, z=5000}
banish = {}
banish.spawn = {}
local modpath = minetest.get_modpath("banish")

minetest.register_chatcommand("spawn", {
	params = "",
	privs = {teleport=true},
	description = "Teleport to the spawn point",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		if spawn_spawnpos then
			player:setpos(spawn_spawnpos)
			return true, "Teleporting to spawn..."
		else
			return false, "The spawn point is not set!"
		end
	end,
})

function banish.banish(param, time)
      local player = minetest.get_player_by_name(param)
      if player == nil then
         return false
      end
      player:setpos(banish_pos)
      if beds.spawn[param] then
	 banish.spawn[param] = beds.spawn[param]
      else
	 banish.spawn[param] = spawn_spawnpos
      end
      banish.save_spawns()
      beds.spawn[param] = banish_pos
      beds.save_spawns()
      local privs = minetest.get_player_privs(param)
      privs.teleport = false;
      minetest.set_player_privs(param, {interact=true, shout=true})
--      minetest.register_on_respawnplayer(function(player)
--	    player:setpos(banish_pos)
--      end)
      minetest.chat_send_player(param, "You were banished! You can try to walk back. You will be able to return to spawn in 5 minutes using the /spawn command.")
      if not time == nil then -- infinite banishment
	 minetest.after(time, banish.revert, param)
      end
      return true
end

function banish.revert (player)
      local privs = minetest.get_player_privs(player);
      privs.teleport = true;
      privs.home = true;
      minetest.set_player_privs(player, privs)
      minetest.chat_send_player(player, "You recovered your teleport privilege. Use /spawn to return to the spawn point")
      if banish.spawn[player] then
	 beds.spawn[player] = banish.spawn[player]
      end
      beds.save_spawns()      
--      minetest.register_on_respawnplayer(function(player)
--	    player:setpos(spawn_spawnpos)
--      end)
end

minetest.register_chatcommand("banish", {
   params = "<person>",
   description = "Banishes griefers to a far away location",
   privs = {kick=true},
   func = function(name, param)
      if banish.banish(param, 300) then
	 minetest.chat_send_player(name, "Banished player " .. param)
      else
	 minetest.chat_send_player(name, "Player " .. param .. " not found")
      end
   end,
})

minetest.register_on_joinplayer(function(player)
	banish.read_spawns()
end)

dofile(modpath .. "/spawns.lua")
