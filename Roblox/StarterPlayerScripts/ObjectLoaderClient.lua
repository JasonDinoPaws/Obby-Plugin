local Collection = game:GetService("CollectionService")
local UserInput = game:GetService("UserInputService")
local Run = game:GetService("RunService")

local tags = {}
local Funs = {
	Loop = {},
	InputBegan = {},
	InputEnded = {},
	JumpRequest = {},
}

task.wait(2)
-- Loads all the modules/tags into a table
for _,x in game.ReplicatedStorage:WaitForChild("Objects"):GetChildren() do
	if x:GetAttribute("Server") then continue end
	tags[x.Name] = require(x)
	Collection:GetInstanceAddedSignal(x.Name):Connect(tags[x.Name].New)
	Collection:GetInstanceRemovedSignal(x.Name):Connect(tags[x.Name].Destroy)
	for _,p in Collection:GetTagged(x.Name) do
		tags[x.Name].New(p)
	end

	-- Checks if the object has a specific type of function
	for F,_ in Funs do
		if tags[x.Name][F] ~= nil then
			table.insert(Funs[F],tags[x.Name][F])
		end
	end

end

function SendToObjects(tab,...)
	for _,x in tab do
		x(...)
	end
end

-- User Inputs
UserInput.InputBegan:Connect(function(input,process)
	if process then return end
	SendToObjects(Funs.InputBegan,input)
end)

UserInput.InputEnded:Connect(function(input,process)
	if process then return end
	SendToObjects(Funs.InputEnded,input)
end)

UserInput.JumpRequest:Connect(function()
	SendToObjects(Funs.JumpRequest)
end)


-- if there are any that need to run constanly runs them givnign them deltatime
Run.PreRender:Connect(function(dt) SendToObjects(Funs.Loop,dt) end)