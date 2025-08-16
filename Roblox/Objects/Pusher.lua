local con = {
	objs = {},
	Attributes = {
        Distance = 1,
        InDelay = 1,
		InSpeed = 20,
		OutDelay = 1,
		OutSpeed = 20
    }
}

function con.New(object:Model)
	if not object:IsA("Model") or con.objs[object] then return end
	
	local base = object:WaitForChild("BasePos")
	local prams = base:FindFirstChildOfClass("PrismaticConstraint")
	prams.UpperLimit = object:GetAttribute("Distance") or script:GetAttribute("Distance")
	prams.ServoMaxForce = 100000

	
	con.objs[object] = {
		pris = prams,
		distance = prams.UpperLimit,
		indelay = object:GetAttribute("InDelay") or script:GetAttribute("InDelay"),
		inspeed = object:GetAttribute("InSpeed") or script:GetAttribute("InSpeed"),
		outdelay = object:GetAttribute("OutDelay") or script:GetAttribute("OutDelay"),
		outspeed = object:GetAttribute("OutSpeed") or script:GetAttribute("OutSpeed"),
		on = false,
		dend = 0,
	}
end

function con.Destroy(part:Model)
	if con.objs[part] == nil then return end
	con.objs[part] = nil
end


function con.Loop(deltatime:number)
	local ctime = tick()
	for obj,data in con.objs do
		local dely = if data.on then data.indelay else data.outdelay
		local speed = if data.on then data.inspeed else data.outspeed
		local tpos = if data.on then 0 else data.distance
		
		if ctime >= data.dend then
			data.on = not data.on
			data.dend = ctime+dely
			data.pris.LinearResponsiveness = speed
			data.pris.Speed = speed
			data.pris.TargetPosition= tpos
		end
	end
end

return con