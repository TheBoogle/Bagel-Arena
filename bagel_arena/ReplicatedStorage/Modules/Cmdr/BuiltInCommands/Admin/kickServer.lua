return function (_, players)
	for _, player in pairs(players) do
		player:Kick("Connection Terminated")
	end

	return ("Kicked %d players."):format(#players)
end