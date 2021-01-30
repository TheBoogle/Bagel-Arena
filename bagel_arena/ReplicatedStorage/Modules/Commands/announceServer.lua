local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

return function (context, text)

	for _, player in ipairs(Players:GetPlayers()) do
		context:SendEvent(player, "Message", text, context.Executor)
	end

	return "Created announcement."
end