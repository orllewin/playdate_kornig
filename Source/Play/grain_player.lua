--[[
	
	One parent sample.
	Five child subsamples.
	Children have variable width controlled by ui.
	Children sit within main sample length, position controlled by ui.
	Children can move, drift, randomise, controlled by ui.
	
          1   2          3         4        5          
	----------------------------------------------------	
	|      [|][ | ]     [  |  ]     [|]   [   |   ]    |
	|      [|][ | ]     [  |  ]     [|]   [   |   ]    |
	|      [|][ | ]     [  |  ]     [|]   [   |   ]    |
	|      [|][ | ]     [  |  ]     [|]   [   |   ]    |
	|      [|][ | ]     [  |  ]     [|]   [   |   ]    |
	----------------------------------------------------
	
	Each sample exists in its own channel with independent fx/filters. 
	All time represented as milliseconds (use self:frame(ms) when creating subsamples).
	
--]]

import 'Coracle/math'

class('GrainPlayer').extends()
	
local sound <const> = playdate.sound
local rnd <const> = math.random
local pSample = sound.sample.new(30, playdate.sound.kFormat16bitMono)
local pPlayer = sound.sampleplayer.new(pSample)
local pLengthMs = -1

local sampleRate = sound.getSampleRate()

local childCount = 5
local children = {}

function GrainPlayer:init()
	GrainPlayer.super.init(self)
end

function GrainPlayer:initialise(samplePath)
	print("loading parent sample from path.." .. samplePath)
	pSample:load(samplePath)
	pPlayer:setSample(pSample)
	pLengthMs = pSample:getLength() * 1000
	
	for i=1,childCount do 
		print("adding child " .. i)
		local config = self:getRandomSubsampleConfig()

		local headFrame = self:frame(config.head)
		local tailFrame = self:frame(config.tail)
		local sample = pSample:getSubsample(headFrame, tailFrame)

		local channel = sound.channel.new()
		--channel:addSource(sample)
		print("Channel created and source added")
		local player = sound.sampleplayer.new(sample)
		player:setRate(0.5)
		local grainSample = {
			channel = channel,
			config = config,
			sample = sample,
			player = player
		}
		children[i] = grainSample
		print("Child " .. i .. " added")
	end
	
	print("grain player ready")
end

function GrainPlayer:getRandomSubsampleConfig()
	local randomMidPointMs = math.random(math.floor(pLengthMs))
	local maxWidthMs = pLengthMs/10
	local widthMs = math.random(math.floor(maxWidthMs))
	
	--Ensure subsample is within sample range
	if randomMidPointMs - widthMs/2 < 0 then
		randomMidPointMs = widthMs/2
	elseif randomMidPointMs + widthMs/2 > math.floor(pLengthMs) then
		randomMidPointMs = math.floor(pLengthMs) - widthMs/2
	end
	
	local subsampleStartMs = randomMidPointMs - (widthMs/2)
	local subsampleStartFrame = self:frame(subsampleStartMs)
	print("getRandomSubsampleConfig()2")
	local subsampleEndMs = randomMidPointMs + (widthMs/2)
	local subsampleEndFrame = self:frame(subsampleStartMs)
	print("getRandomSubsampleConfig()3 - returning")
	return {
		midpoint = randomMidPointMs,
		width = widthMs,
		head = subsampleStartMs,
		tail = subsampleEndMs
	}
end

function GrainPlayer:update()
	if math.random(100) < 5 then
		local index = math.random(childCount)
		print("playing a grain..." .. index)
		children[index].player:play()
	end
end

function GrainPlayer:children()
	return childCount
end

function GrainPlayer:frame(ms)
	return math.floor(ms/1000 * sampleRate)
end

--  Children params:
function GrainPlayer:move(index, value)
	
	local midpoint = map(value, 0, 100, 0, pLengthMs)

	local width = children[index].config.width
	
	--Ensure subsample is within sample range
	if midpoint - width/2 < 0 then
		midpoint = width/2
	elseif midpoint + width/2 > math.floor(pLengthMs) then
		midpoint = math.floor(pLengthMs) - width/2
	end
	
	children[index].config.midPoint = midpoint
	
	local subsampleStartMs = midpoint - (width/2)
	local subsampleEndMs = midpoint + (width/2)
	
	children[index].config.head = subsampleStartMs
	children[index].config.tail = subsampleEndMs
	
	local headFrame = self:frame(subsampleStartMs)
	local tailFrame = self:frame(subsampleEndMs)
	local sample = pSample:getSubsample(headFrame, tailFrame)
	
	children[index].sample = sample
	children[index].player:setSample(children[index].sample)
end