local con = {
	objs = {},
	Attributes = {
		ConDir = Vector3.new(1, 0, 0),
		ConSpeed = 16
	}
}

function UpdatePart(part:BasePart)
	local speed = (part:GetAttribute("ConSpeed") or script:GetAttribute("ConSpeed"))/2
	local dirrection = part:GetAttribute("ConDir") or script:GetAttribute("ConDir")
	dirrection += Vector3.new(2,2,2)
	dirrection = dirrection*part.CFrame.LookVector
	part.AssemblyLinearVelocity = dirrection*speed


	-- Beam configuration
	local Beam = part:FindFirstChildOfClass("Beam")
	if Beam then
		Beam.TextureSpeed = (part.Size.X/Beam.TextureLength) * (speed / 2)
	end
end

function con.New(part:BasePart)
	if not part:IsA("BasePart") or table.find(con.objs,part) then return end

	-- Removing Temp to show dirrection
	local tempdir = part:FindFirstChildOfClass("Decal")
	if tempdir and tempdir.Name == "temp" then
		tempdir:Destroy()
	end


	UpdatePart(part)
	part:GetAttributeChangedSignal("Speed"):Connect(function()
		UpdatePart(part)
	end)
	part:GetAttributeChangedSignal("ConDir"):Connect(function()
		UpdatePart(part)
	end)


	table.insert(con.objs,part)
end

function con.Destroy(part:BasePart)
	if not table.find(con.objs,part) then return end
	table.remove(con.objs,table.find(con.objs,part))
	part.AssemblyLinearVelocity = Vector3.new()
end

return con