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

local listener = nil

local childCount = 5
local children = {}

local SPD = 0.25

local rate = SPD

local playChance = 5

function GrainPlayer:init()
	GrainPlayer.super.init(self)
end

function GrainPlayer:save(filename)
	pSample:save(filename)
end

function GrainPlayer:initialise(samplePath, onReady)
	print("loading parent sample from path.." .. samplePath)
	pSample:load(samplePath)
	pPlayer:setSample(pSample)
	pLengthMs = pSample:getLength() * 1000
	
	local configs = {}
	
	self.stopped = false
	
	for i=1,childCount do 
		print("adding child " .. i)
		local config = self:getRandomSubsampleConfig()

		local headFrame = self:frame(config.head)
		local tailFrame = self:frame(config.tail)
		local sample = pSample:getSubsample(headFrame, tailFrame)

		local channel = sound.channel.new()
		
		local player = sound.sampleplayer.new(sample)
		channel:addSource(player)
		
		local lowpass = sound.twopolefilter.new(sound.kFilterLowPass)
		channel:addEffect(lowpass)
		lowpass:setMix(0)
		lowpass:setFrequency(5000)
		
		local delay = sound.delayline.new(0.5)
		delay:setFeedback(0.1)
		delay:setMix(0.0)
		channel:addEffect(delay)
		
		print("Channel created and source added")
		
		local grainSample = {
			channel = channel,
			config = config,
			sample = sample,
			player = player,
			delay = delay,
			lowpass = lowpass
		}
		children[i] = grainSample
		configs[i] = config
		print("Child " .. i .. " added")
	end
	
	onReady(configs)
	print("grain player ready")
end

function GrainPlayer:getRandomSubsampleConfig()
	local randomMidPointMs = math.random(math.floor(pLengthMs))
	local maxWidthMs = pLengthMs/5
	local widthMs = math.random(math.floor(maxWidthMs))
	
	if widthMs < 65 then widthMs = 65 end
	
	--Ensure subsample is within sample range
	if randomMidPointMs - widthMs/2 < 0 then
		randomMidPointMs = widthMs/2
	elseif randomMidPointMs + widthMs/2 > math.floor(pLengthMs) then
		randomMidPointMs = math.floor(pLengthMs) - widthMs/2
	end
	
	local subsampleStartMs = randomMidPointMs - (widthMs/2)
	local subsampleStartFrame = self:frame(subsampleStartMs)

	local subsampleEndMs = randomMidPointMs + (widthMs/2)
	local subsampleEndFrame = self:frame(subsampleStartMs)

	return {
		midpoint = randomMidPointMs,
		width = widthMs,
		head = subsampleStartMs,
		tail = subsampleEndMs,
		parentLength = pLengthMs,
		driftAmount = 0,
		jump = false,
		reverse = false,
		delayMix = 0.0,
		delayFeedback = 0.1,
		loActive = false,
		loFreq = 5000,
		loRes = 0.5,
		rate0125 = false,
		rate025 = true,
		rate05 = false,
		rate1 = false
	}
end

function GrainPlayer:update()
	if self.stopped then return end
	
	if math.random(100) < playChance then
		local index = math.random(childCount)
		
		local config = children[index].config
		
		local rRate = rate--global rate
		
		if config.rate0125 and math.random(100) < 5 then
			rRate = 0.125
		elseif config.rate025 and math.random(100) < 5 then
			rRate = 0.25
		elseif config.rate05 and math.random(100) < 8 then
			rRate = 0.5
		elseif config.rate1 and math.random(100) < 12 then
			rRate = 1.0
		end
				
		if config.reverse then
			if math.random(100) < 33 then
				children[index].player:setRate(-rRate)
			else
				children[index].player:setRate(rRate)
			end
			children[index].player:play()
		else
			children[index].player:setRate(rRate)
			children[index].player:play()
		end
	end
	
	for i=1,#children do
		if math.random(100) < 3 and children[i].config.jump then
			self:doJump(i)
		end
		
		local driftAmount = children[i].config.driftAmount
		if driftAmount < -0.1 or driftAmount > 0.1 then
			self:doDrift(i, driftAmount)
		end
	end
	
end

function GrainPlayer:changeTempo(tempo) playChance = map(tempo, 0.0, 1.0, 1, 10) end
function GrainPlayer:getNormalisedTempo() return map(playChance, 1, 10, 0.0, 1.0) end

function GrainPlayer:changeRate(_rate)
	rate = _rate
end

function GrainPlayer:stop()
	self.stopped = true
	
	for i=1,#children do
		children[i].player:stop()
	end
end

function GrainPlayer:children()
	return childCount
end

function GrainPlayer:frame(ms)
	return math.floor(ms/1000 * sampleRate)
end

--  Children params:
function GrainPlayer:getNormalisedFxValues(index)
	local config = children[index].config
	return{
		delayMix = config.delayMix,
		delayFeedback = config.delayFeedback,
		loActive = config.loActive,
		loFreq = map(config.loFreq, 100, 10000, 0.0, 1.0),
		loRes = config.loRes,
		rate0125 = config.rate0125,
		rate025 = config.rate025,
		rate05 = config.rate05,
		rate1 = config.rate1,
		globalRate = rate
	}
end
function GrainPlayer:getGlobalRate()
	return rate
end
function GrainPlayer:setRateActiveByIndex(index, rateIndex, active)
	if rateIndex == 1 then
		self:setRate0125Active(index, active)
	elseif rateIndex == 2 then
		self:setRate025Active(index, active)
	elseif rateIndex == 3 then
		self:setRate05Active(index, active)
	elseif rateIndex == 4 then
		self:setRate1Active(index, active)
	end
end
function GrainPlayer:setRate0125Active(index, active)
	children[index].config.rate0125 = active
end
function GrainPlayer:setRate025Active(index, active)
	children[index].config.rate025 = active
end
function GrainPlayer:setRate05Active(index, active)
	children[index].config.rate05 = active
end
function GrainPlayer:setRate1Active(index, active)
	children[index].config.rate1 = active
end
function GrainPlayer:setDelayLevel(index, delayLevel) 
	local delayMix = delayLevel/2
	children[index].config.delayMix = delayMix
	children[index].delay:setMix(delayMix) 
end
function GrainPlayer:setDelayFeedback(index, feedbackLevel) 
	children[index].config.delayFeedback = feedbackLevel
	children[index].delay:setFeedback(feedbackLevel)
end
function GrainPlayer:setLoActive(index, active)
	children[index].config.loActive = active
	if active then
		children[index].lowpass:setMix(1.0)
	else
		children[index].lowpass:setMix(0.0)
	end
end
function GrainPlayer:setLoFreq(index, freq) 
	local loFreq = map(freq, 0.0, 1.0, 100, 10000)
	children[index].config.loFreq = loFreq
	children[index].lowpass:setFrequency(loFreq) 
end
function GrainPlayer:setLoRes(index, res) 
	children[index].config.loRes = res
	children[index].lowpass:setResonance(res) 
end
function GrainPlayer:setReverse(index, reverseActive)
	if #children == 0 then return end
	children[index].config.reverse = reverseActive
end

function GrainPlayer:setJump(index, jumpActive)
	if #children == 0 then return end
	children[index].config.jump = jumpActive
end

function GrainPlayer:setWidth(index, nWidth)
	if #children == 0 then return end

	local maxWidthMs = pLengthMs/5
	local widthMs = map(nWidth, 0.0, 1.0, 65, maxWidthMs)
	
	local config = children[index].config
	local midpoint = config.midpoint
	
	if midpoint - widthMs/2 < 0 then
		midpoint = widthMs/2
	elseif midpoint + widthMs/2 > math.floor(pLengthMs) then
		midpoint = math.floor(pLengthMs) - widthMs/2
	end
	
	config.midpoint = midpoint
	config.width = widthMs
	config.head = midpoint - widthMs/2
	config.tail = midpoint + widthMs/2
	
	local headFrame = self:frame(config.head)
	local tailFrame = self:frame(config.tail)
	local sample = pSample:getSubsample(headFrame, tailFrame)
	
	children[index].sample = sample
	children[index].player:setSample(children[index].sample)
	children[index].config = config
	if listener ~= nil then listener(index, config) end
end

function GrainPlayer:setDrift(index, driftAmount)
	if #children == 0 then return end
	children[index].config.driftAmount = driftAmount
end

function GrainPlayer:doJump(index)
	local config = children[index].config
	
	local randomMidPointMs = math.random(math.floor(pLengthMs))
	config.midpoint = randomMidPointMs
	
	local widthMs = config.width
	
	--Ensure subsample is within sample range
	if randomMidPointMs - widthMs/2 < 0 then
		randomMidPointMs = widthMs/2
	elseif randomMidPointMs + widthMs/2 > math.floor(pLengthMs) then
		randomMidPointMs = math.floor(pLengthMs) - widthMs/2
	end
	
	local subsampleStartMs = randomMidPointMs - (widthMs/2)
	config.head = subsampleStartMs
	local headFrame = self:frame(subsampleStartMs)

	local subsampleEndMs = randomMidPointMs + (widthMs/2)
	config.tail = subsampleEndMs
	local tailFrame = self:frame(subsampleEndMs)

	local sample = pSample:getSubsample(headFrame, tailFrame)
	
	children[index].sample = sample
	children[index].player:setSample(children[index].sample)
	children[index].config = config
	if listener ~= nil then listener(index, config) end
end


function GrainPlayer:doDrift(index, driftAmount)
	
	local config = children[index].config
	
	local midpoint = config.midpoint += (driftAmount * 10)

	local width = config.width
	
	--Ensure subsample is within sample range
	if midpoint - width/2 < 0 then
		midpoint = math.floor(pLengthMs) - width/2
	elseif midpoint + width/2 > math.floor(pLengthMs) then
		midpoint = width/2
	end
	
	config.midpoint = midpoint
	
	local subsampleStartMs = midpoint - (width/2)
	local subsampleEndMs = midpoint + (width/2)
	
	config.head = subsampleStartMs
	config.tail = subsampleEndMs
	
	local headFrame = self:frame(subsampleStartMs)
	local tailFrame = self:frame(subsampleEndMs)
	local sample = pSample:getSubsample(headFrame, tailFrame)
	
	children[index].sample = sample
	children[index].player:setSample(children[index].sample)
	children[index].config = config
	children[index].player:setRate(SPD)
	if listener ~= nil then listener(index, config) end
end

function GrainPlayer:move(index, value)
	local midpoint = map(value, 0, 100, 0, pLengthMs)
	local config = children[index].config
	local width = config.width
	
	--Ensure subsample is within sample range
	if midpoint - width/2 < 0 then
		midpoint = width/2
	elseif midpoint + width/2 > math.floor(pLengthMs) then
		midpoint = math.floor(pLengthMs) - width/2
	end
	
	config.midpoint = midpoint
	
	local subsampleStartMs = midpoint - (width/2)
	local subsampleEndMs = midpoint + (width/2)
	
	config.head = subsampleStartMs
	config.tail = subsampleEndMs
	
	local headFrame = self:frame(subsampleStartMs)
	local tailFrame = self:frame(subsampleEndMs)
	local sample = pSample:getSubsample(headFrame, tailFrame)
	
	children[index].sample = sample
	children[index].player:setSample(children[index].sample)
	children[index].config = config
	if listener ~= nil then listener(index, config) end
end

function GrainPlayer:setListener(_listener)
	listener = _listener
end