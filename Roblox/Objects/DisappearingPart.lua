local tweenSer = game:GetService("TweenService")

local con = {
	objs = {},
	Attributes = {
        DisFade = 1,
        DisRespawn = 1
    }
}

function con.New(part:BasePart)
	if not part:IsA("BasePart") or con.objs[part] then return end

	local fadeTime = part:GetAttribute("DisFade") or script:GetAttribute("DisFade")
	local respawnDelay = part:GetAttribute("DisRespawn") or script:GetAttribute("DisRespawn")
	
	con.objs[part] = part.Touched:Connect(function(touchPart)
		local plr = game.Players:GetPlayerFromCharacter(touchPart:FindFirstAncestorOfClass("Model"))
		if plr and not part:GetAttribute("Cooldown") and plr == game.Players.LocalPlayer then
			part:SetAttribute("Cooldown", true)

			local fadeout = tweenSer:Create(part, TweenInfo.new(fadeTime, Enum.EasingStyle.Linear), {Transparency = 1})
			fadeout:Play()
			fadeout.Completed:Wait()
			
			--[[if fadeTime > .3 then -- was testing adding a slight delay to make it feel more fair
				math.clamp(task.wait(fadeTime / 10), 0, .15)
			end]]
			
			-- Color selectionbox indicator
			if part:FindFirstChild("SelectionBox") then
				part.SelectionBox:SetAttribute("OriginalColor", part.SelectionBox.Color3)
				part.SelectionBox.Color3 = Color3.fromRGB(255,0,0)
			end
			part.CanCollide = false
			
			task.wait(respawnDelay)
			
			-- Reset part
			part.CanCollide = true
			part.Transparency = 0

			if part:FindFirstChild("SelectionBox") then
				part.SelectionBox.Color3 = part.SelectionBox:GetAttribute("OriginalColor")
			end
			part:SetAttribute("Cooldown", nil)
		end
	end)
end

function con.Destroy(part:BasePart)
	if con.objs[part] == nil then return end
	con.objs[part]:Disconnect()
	con.objs[part] = nil
end

return con