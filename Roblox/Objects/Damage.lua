local con = {
	objs = {},
    Attributes = {
        Damage = 10,
        Server = true
    }
}

function con.New(part:BasePart)
	if not part:IsA("BasePart") or con.objs[part] then return end
	local dam = part:GetAttribute("Damage") or script:GetAttribute("Damage")

	con.objs[part] = part.Touched:Connect(function(part)
		local plr = game.Players:GetPlayerFromCharacter(part:FindFirstAncestorOfClass("Model"))
		if plr then
			local Hum:Humanoid = plr.Character.Humanoid

			if Hum.Health-dam < 0 or Hum.Health-dam > Hum.MaxHealth then
				Hum.Health = math.clamp(Hum.Health-dam,0,Hum.MaxHealth)
			else
				plr.Character.Humanoid:TakeDamage(dam)
			end

		end
	end)
end

function con.Destroy(part:BasePart)
	if con.objs[part] == nil then return end
	con.objs[part]:Disconnect()
	con.objs[part] = nil
end

return con