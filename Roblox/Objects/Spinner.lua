local con = {
	objs = {},
	Attributes = {
        Server = true,
        SpinDir = Vector3.new(0, 1, 0),
        SpinSpeed = 1
    }
}

local phs = game:GetService("PhysicsService")
local phsname= "Spinner"
phs:RegisterCollisionGroup(phsname)
phs:CollisionGroupSetCollidable(phsname,phsname,false)

function FindAtt(part:BasePart)
	local att = part:FindFirstChildOfClass("Attachment")
	local cylin = att and att:FindFirstChildOfClass("CylindricalConstraint")


	if not att or cylin and cylin.Attachment0 ~= nil then
		return Instance.new("Attachment",part)
	end
	return att
end

function con.New(object:Instance)
	if not (object:IsA("BasePart") or object:IsA("Model") or object:IsA("Folder")) or table.find(con.objs,object) then return end
	local att0
	local att1 = {}
	local base = object:FindFirstChild("Base")

	att0 =  (base and base:FindFirstChildOfClass("Attachment")) or Instance.new("Attachment",base or workspace.Terrain)
	if not att0 then return end
	if object:IsA("BasePart") then

		local att = FindAtt(object)
		table.insert(att1,att)
		att0.WorldCFrame = att.WorldCFrame
		object.CollisionGroup = phsname
		object.Anchored = false
	else
		att1 = {}
		for _,x in object:GetChildren() do
			if x.Name:lower() == "spinner" then
				x.Anchored = false
				x.CollisionGroup = phsname
				table.insert(att1,FindAtt(x))
			end
		end
	end

	local SumPos = Vector3.new()
	for _,att in att1 do
		local cylinder = att:FindFirstChildOfClass("CylindricalConstraint") or script.CylindricalConstraint:Clone()

		cylinder.AngularVelocity = object:GetAttribute("SpinSpeed") or script:GetAttribute("SpinSpeed")
		cylinder.Parent = att
		cylinder.Attachment0 = att0
		cylinder.Attachment1 = att
		SumPos += att.WorldCFrame.Position


		local dir = object:GetAttribute("SpinDir") or script:GetAttribute("SpinDir")
		dir = CFrame.Angles(math.rad(90*dir.X),math.rad(90*dir.Y),math.rad(90*dir.Z))
		att.CFrame *= dir
		att0.CFrame *= dir
	end
	if not base and (object:IsA("Model") or object:IsA("Folder")) then
		att0.WorldCFrame = CFrame.new(SumPos/#att1) * att0.CFrame
	end
	table.insert(con.objs,object)
end

function con.Destroy(object:BasePart)
	if not table.find(con.objs,object) then return end

	table.remove(con.objs,table.find(con.objs,object))
end

return con