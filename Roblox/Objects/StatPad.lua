local con = {
	objs = {},
	Attributes = {
        Server = true,
        JumpPower = 50,
        Time = 5,
        WalkSpeed = 16
    }
}

function con.New(part:BasePart)
	if not part:IsA("BasePart") or con.objs[part] then return end
	local newstat = {
		WalkSpeed = part:GetAttribute("WalkSpeed"),
		JumpPower = part:GetAttribute("JumpPower")
	}
	local Time = part:GetAttribute("Time")
	
	con.objs[part] = part.Touched:Connect(function(part)
		local plr = game.Players:GetPlayerFromCharacter(part:FindFirstAncestorOfClass("Model"))
		if plr and not plr:FindFirstChild("Touched") then
			Instance.new("BoolValue",plr).Name= "Touched"
			local Default = {}
			
			for P,v in newstat do
				Default[P] = plr.Character.Humanoid[P]
				plr.Character.Humanoid[P] = v
			end
			if Time then
				task.wait(Time)
				for P,v in Default do
					plr.Character.Humanoid[P] = v
				end
			end
			plr.Touched:Destroy()
		end
	end)
end

function con.Destroy(part:BasePart)
	if con.objs[part] == nil then return end
	con.objs[part]:Disconnect()
	con.objs[part] = nil
end

return con