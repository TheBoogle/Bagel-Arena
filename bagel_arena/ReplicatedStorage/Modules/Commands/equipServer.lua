return function(context, newValue)
	game.ReplicatedStorage.Remotes.ForceEquip:FireClient(context.Executor, newValue)
end