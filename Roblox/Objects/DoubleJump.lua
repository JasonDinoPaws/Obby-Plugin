local plr = game.Players.LocalPlayer
local con = {
	objs = {},
	Attributes = {
        Buffer = 0,
        JumpPower = 50
    }
}
local Last:BasePart = nil

function GetClosedPos(part,pos)
	local objectSpacePos = part.CFrame:pointToObjectSpace(pos)
	local halfSize = part.Size * 0.5
	local clampedObjectPos = CFrame.new(
		math.clamp(objectSpacePos.X, -halfSize.X, halfSize.X), 
		math.clamp(objectSpacePos.Y, -halfSize.Y, halfSize.Y), 
		math.clamp(objectSpacePos.Z, -halfSize.Z, halfSize.Z))
	
	return part.CFrame:toWorldSpace(clampedObjectPos).Position
end

function con.New(part:BasePart)
	if not part:IsA("BasePart") or con.objs[part] then return end

	con.objs[part] = part.Touched:Connect(function(other)
		Last = part
	end)
end

function con.Destroy(part:BasePart)
	if con.objs[part] == nil then return end
	con.objs[part]:Disconnect()
	con.objs[part] = nil
end

function con.JumpRequest()
	if not Last then return end
	local Buffer = Last:GetAttribute("Buffer") or 0
	local default = plr.Character.Humanoid.JumpPower
	local JumpPower = Last:GetAttribute("JumpPower") or default
	local Pos = plr.Character.PrimaryPart.Position
	local closest = GetClosedPos(Last,Pos)
	Last = nil
	
	if (Pos-closest).Magnitude > Buffer then return end
	plr.Character.Humanoid.JumpPower = JumpPower
	plr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	task.wait()
	plr.Character.Humanoid.JumpPower = default
end

return con