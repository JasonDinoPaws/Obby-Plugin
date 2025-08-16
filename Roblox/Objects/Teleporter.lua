local con = {
	objs = {},
	Attributes = {
        KeepVelocity = false,
        SetInvis = false,
        TelePlr = true,
        TeleTransition = 0
    }
}


local getpart = {
	plr = function(hit:BasePart)
		local model = hit.Parent
		if game.Players:GetPlayerFromCharacter(model) then
			return model
		end
	end,
}

function Teleport(hit:BasePart,dest:BasePart,transtion,velocity)
	if not dest or not hit then return end
	local part = hit
	if hit:IsA("Model") and hit.PrimaryPart ~= nil then
		part = hit.PrimaryPart
	end
	
	local Vel = part.AssemblyLinearVelocity
	local angu = part.AssemblyAngularVelocity
	
	part.AssemblyLinearVelocity = Vector3.zero
	part.AssemblyAngularVelocity = Vector3.zero
	
	if transtion > 0 then
		part.Anchored = true
		local twn = game.TweenService:Create(part,TweenInfo.new(transtion),{CFrame = dest.CFrame})
		twn:Play()
		twn.Completed:Wait()
		part.Anchored = false
	else
		part.CFrame = dest.CFrame
	end
	
	if velocity then
		part.AssemblyLinearVelocity = Vel
		part.AssemblyAngularVelocity = angu
	end

	hit:SetAttribute("Teleporting",false)
end

function con.New(object:Model)
	if not object:IsA("Model") or con.objs[object] then return end
	local Destinations = {}
	local SetInvs = object:GetAttribute("SetInvis") or script:GetAttribute("SetInvis")
	local Velocity = object:GetAttribute("KeepVelocity") or script:GetAttribute("KeepVelocity")
	local Transition = object:GetAttribute("TeleTransition") or script:GetAttribute("TeleTransition")
	local TeleTypes = {
		plr = (object:GetAttribute("TelePlr") or script:GetAttribute("TelePlr")) or nil
	}
	
	con.objs[object] = {}
	
	for _,x in object:GetChildren() do
		if not x:IsA("BasePart") then continue end
		
		if x.Name:lower() == "destination" then
			table.insert(Destinations,x)
		elseif x.Name:lower() == "teleporter" then
			local connect = x.Touched:Connect(function(hit:BasePart)
				local part = false
				for t,_ in TeleTypes do
					part = getpart[t](hit)
					if part and not part:GetAttribute("Teleporting") then
						break
					end
				end
				
				
				if part then
					part:SetAttribute("Teleporting",true)
					Teleport(part,Destinations[math.random(#Destinations)],Transition,Velocity)
				end
			end)
			table.insert(con.objs[object],connect)
		end
		
		if SetInvs then
			x.Transparency = 1
			x.CanCollide = false
		end
	end
	
end

function con.Destroy(object:Model)
	if con.objs[object] == nil then return end
	
	for _,x in con.objs[object] do
		x:Disconnect()
	end
	
	con.objs[object] = nil
end

return con