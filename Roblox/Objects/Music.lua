local plr = game.Players.LocalPlayer
local Tser = game:GetService("TweenService")
local last = Instance.new("Folder",game.SoundService)
local new = Instance.new("Folder",game.SoundService)
local Radio = {}
local Radioinx = 1
local Song = nil

local con = {
	objs = {},
	Attributes = {
        MusicFade = 0
    }
}


last.Name = "Last"
new.Name = "Current"

--unpacks a object
function Unpack(ob)
	if type(ob) == "table" then
		return table.unpack(ob)
	end
	return ob
end

-- Makes eveything 1 table
function OneTab(...)
	local curr = {...}
	local fin = {}

	for _,x in curr do
		if type(x) == "table" then
			for _,a in x do
				table.insert(fin,a)
			end
		else
			table.insert(fin,x)
		end
	end
	return fin
end


-- Checking if it is a clone
function isClone(org,sus)
	if org == sus then return false end
	if org.ClassName ~= sus.ClassName then return false end
	if org.Name ~= sus.Name then return false end
	if org.SoundId ~= sus.SoundId then return false end
	if org.PlaybackSpeed ~= sus.PlaybackSpeed then return false end
	return true
end

-- Finding Clones
function FindClones(tolook,dodic,...)
	local org = OneTab(...)
	local clones = {}

	for _,c in tolook:GetDescendants() do
		for _,o in org do
			if isClone(o,c) then
				if dodic then
					clones[o] = c
				else
					table.insert(clones,c)
				end
				break
			end
		end
	end

	return clones
end

-- Making Clones
function MakeClones(...)
	local orgs = {...}
	local clones = FindClones(new,true,...)

	for _,x in orgs do
		if clones[x] ~= nil then continue end
		if type(x) == "table" then
			MakeClones(table.unpack(x))
			continue
		end
		local c = x:Clone()
		c.Parent = new
		table.insert(clones,c)
	end

	if #clones == 1  then
		return clones[1]
	end
	return clones
end

function DestroyClones(tolook,fade,...)
	local clones = FindClones(tolook,false,...)
	for _,x in clones do
		if type(x) == "table" then DestroyClones(Unpack(x)) end
		Tser:Create(x,TweenInfo.new(fade or 0),{Volume = 0}):Play()
		x.Parent = last
	end
end

--Is Clone playing
function IsClonePlaying(tolook,song)
	local clone = FindClones(tolook,false,song)[1]
	if not clone then return false end
	return clone.IsPlaying
end

-- Playing a Clone
function PlayClone(toplay,wat:boolean,fade,Vol,...)
	local clones = FindClones(toplay,false,...)
	if #clones == 0 then return end
	for _,audio:Sound in clones do
		audio:Play()

		local AuVal = audio.Volume
		if Vol > 0 then
			audio.Volume = 0
		else
			fade = audio.TimeLength - fade
		end
		Tser:Create(audio,TweenInfo.new(fade or 0),{Volume = AuVal*Vol}):Play()

		if not audio.Looped and Vol > 0 and audio.TimeLength > 0 then
			task.spawn(function()
				task.wait(audio.TimeLength - fade)
				Tser:Create(audio,TweenInfo.new(fade or 0),{Volume = 0}):Play()
			end)
		end
	end
	if wat then
		clones[1].Ended:Wait()
		for _,x in clones do
			x.Parent = last
		end
	end
end

-- Gets a sound from a instance weatehr it is part for folder
function GetSound(inst,get)
	local obs = {}
	for _,s:Instance in inst:GetChildren() do
		if get == "bg" then
			if table.find({"intro","outro","radio"},s.Name:lower()) then
				continue 
			end
		elseif s.Name:lower() ~= get then
			continue
		end  

		if s:IsA("Sound")  then
			table.insert(obs,s)
		elseif s:IsA("Folder") and #s:GetChildren() > 0 then
			local s2 = s:FindFirstChildOfClass("Sound")
			if not s2 then continue end
			local isinx = type(tonumber(s2.Name)) == "number"

			if isinx then
				for i = 1, #s:GetChildren() do
					obs[i] = GetSound(s,tostring(i))
				end
			else
				local tab = s:GetChildren()
				repeat wait() 
					local num = math.random(#tab)
					table.insert(obs,tab[num])
					table.remove(tab,num)
				until #tab <= 0
			end
		end
	end

	if #obs == 0 then
		return nil
	elseif #obs == 1  then
		return obs[1]
	end
	return obs
end

-- Setting the state of the music box
function SetState(part,state,count)
	if part:GetAttribute("On") == state then return end
	part:SetAttribute("On",state)
	local fade = part:GetAttribute("Fade") or script:GetAttribute("MusicFade")
	local intro = GetSound(part,"intro")
	local outro = GetSound(part,"outro")
	local radio = GetSound(part,"radio")
	local background = GetSound(part,"bg")
	local clones



	if state then
		DestroyClones(new,fade,Unpack(outro))
		clones = MakeClones(Unpack(intro),Unpack(background),Unpack(radio))
		PlayClone(new,true,fade,1,Unpack(intro))
		PlayClone(new,false,fade,1,Unpack(background))
		Radio = radio
		Radioinx = 1
	else
		Radio = {}
		Radioinx = 1
		Song = nil
		DestroyClones(new,fade,Unpack(intro),Unpack(background),Unpack(radio))
		clones = MakeClones(Unpack(outro))
		PlayClone(new,true,fade,0,Unpack(outro))
	end

end

-- Checking it its descendants has a sound
function HasSound(part)
	for _,x in part:GetDescendants() do
		if x:IsA("Sound") then
			return true
		end
	end
	return false
end

-- New part added
function con.New(part:BasePart)
	if not part:IsA("BasePart") or table.find(con.objs,part) or not HasSound(part) then return end
	part.CanCollide = false
	part.CanQuery = true
	part:SetAttribute("On",false)
	table.insert(con.objs,part)
end

-- Kill the part
function con.Destroy(part:BasePart)
	if not table.find(con.objs,part) then return end
	table.remove(con.objs,table.find(con.objs,part))
end

-- Run Service
local overlap = OverlapParams.new()
overlap.FilterType = Enum.RaycastFilterType.Include
function con.Loop(DT)
	if not plr.Character then return end
	overlap.FilterDescendantsInstances = plr.Character:GetChildren()

	for _,part in con.objs do
		local isin = workspace:GetPartsInPart(part,overlap)
		local ison =  part:GetAttribute("On")

		if #isin > 0 then
			coroutine.wrap(SetState)(part,true,#isin)
		elseif ison then
			coroutine.wrap(SetState)(part,false,0)
		end

	end

	-- Playing Songs in a radio
	if Radio and #Radio > 0 and (not Song or not IsClonePlaying(new,Song)) then
		Song = Radio[Radioinx]
		if type(Song) == "table" then
			Song = Song[math.random(#Song)]
		end
		PlayClone(new,false,1,1,Song)
		Radioinx += 1
		if Radioinx > #Radio then
			Radioinx = 1
		end
	end

	-- Destroying anything in last
	for _,x:Sound in last:GetDescendants() do
		if x:IsA("Sound") and (not x.IsPlaying or x.Volume == 0) then
			x:Destroy()
		end
	end
end

return con