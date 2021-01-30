return function (registry)
	registry:RegisterHook("BeforeRun", function(context)
		if game:GetService("RunService"):IsStudio() then return end
		
		if context.Group ~= 'client' and tostring(context.Executor.UserId) ~= tostring(game.CreatorId) then
			return "only server owners can use this command"
		end
	end)
end