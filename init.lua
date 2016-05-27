--Spawn mod for Minetest
--Originally written by VanessaE (I think), rewritten by cheapie
--WTFPL

--Banish command
--Copyright 2016 Gabriel Pérez-Cerezo
--WTFPL

local spawn_spawnpos = minetest.setting_get_pos("static_spawnpoint")
local banish_pos = {x=5000, y=2, z=5000}
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

function revert (player)
      local privs = minetest.get_player_privs(player);
      privs.teleport = true;
      minetest.set_player_privs(player, privs)
      minetest.chat_send_player(player, "You recovered your teleport privilege. Use /spawn to return to the spawn point")
      minetest.register_on_respawnplayer(function(player)
	    player:setpos(spawn_spawnpos)
      end)
end

minetest.register_chatcommand("banish", {
   params = "<person>",
   description = "Banishes griefers to a far away location",
   privs = {server=true},
   func = function(name, param)
      local player = minetest.get_player_by_name(param)
      if player == nil then
         return false, "Player not found"
      end
      player:setpos(banish_pos)
      local privs = minetest.get_player_privs(param)
      privs.teleport = false;
      minetest.set_player_privs(param, {interact=true, shout=true})
      minetest.register_on_respawnplayer(function(player)
	    player:setpos(banish_pos)
      end)
      minetest.chat_send_player(name, "Banished player " .. param)
      minetest.chat_send_player(param, "You were banished! You can try to walk back. You will be able to return to spawn in 5 minutes using the /spawn command.")
      minetest.after(300, revert, param)
   end,
})
