local Collection = game:GetService("CollectionService")
local tags = {}

task.wait()
-- Loads all the modules/tags into a table
for _,x in game.ReplicatedStorage:WaitForChild("Objects"):GetChildren() do
	if not x:GetAttribute("Server") then continue end
	tags[x.Name] = require(x)
	Collection:GetInstanceAddedSignal(x.Name):Connect(tags[x.Name].New)
	Collection:GetInstanceRemovedSignal(x.Name):Connect(tags[x.Name].Destroy)
	for _,p in Collection:GetTagged(x.Name) do
		tags[x.Name].New(p)
	end
end