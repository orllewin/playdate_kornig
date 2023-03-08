--[[
	
	Encapsulates the entire recording flow.
	
--]]

import 'CoracleViews/label_left'
import 'CoracleViews/label_centre'
import 'CoracleViews/label_right'
import 'CoracleViews/button'
import 'Coracle/math'
import 'Record/scrub_view'

class('RecordDialog').extends(playdate.graphics.sprite)

local graphics <const> = playdate.graphics
local sound <const> = playdate.sound
local sprites = {}
local sin <const> = math.sin
local cos <const> = math.cos
local min <const> = math.min
local max <const> = math.max

local frame = 0

local MAX_SECONDS = 30
 
function RecordDialog:init(maxSeconds)
	RecordDialog.super.init(self)
	self.showing = false
	
	frame = 0
	
	self.recording = false
	
	self.maxSeconds = MAX_SECONDS
	if maxSeconds ~= nil then self.maxSeconds = maxSeconds end
	
	self.buffer = sound.sample.new(self.maxSeconds, playdate.sound.kFormat16bitMono)
	self.samplePlayer = sound.sampleplayer.new(self.buffer)
end

function RecordDialog:show(onSampleReady)
	self.onSampleReady = onSampleReady
	
	self.recording = false
	sound.micinput.startListening()

	local background = graphics.image.new(400, 240, graphics.kColorWhite)
	self:moveTo(200, 120)
	self:setImage(background)
	self:add()
	
	graphics.setImageDrawMode(graphics.kDrawModeFillBlack)

	self.titleLabel = LabelLeft("Record Sample", 6, 12)
	self:addSprite(self.titleLabel)
	self.div = DividerHorizontal(6, 42, 388, 0.2)
	
	
	self.scrubView = ScrubView(52)
	self:addSprites(self.scrubView:getSprites())
	
	self.recordToggleButton = Button("Start Recording", 82, 137, function() 
		self.recording = not self.recording
		if self.recording then
			self.recordToggleButton:setText("Stop Recording")
			self:startRecording()
		else
			self.recordToggleButton:setText("Start Recording")
			self.previewButton:setFocus(true)
			self.saveButton:setActive(true)
			self.recordToggleButton:setFocus(false)
			sound.micinput.stopRecording()
		end	
	end)
	self.recordToggleButton:setFocus(true)
	self:addSprites(self.recordToggleButton:getSprites())
	
	
	self.remainingLabel = LabelLeft("Remaining buffer: " .. self.maxSeconds, 8, 165, 0.2)
	self:addSprite(self.remainingLabel)
	
	self.levelLabel = LabelLeft("", 8, 190, 1.0)
	self:addSprite(self.levelLabel)
	
	self.sourceLabel = LabelLeft("Source: " .. sound.micinput.getSource(), 8, 215, 1.0)
	self:addSprite(self.sourceLabel)
	
	self.previewButton = Button("Preview", 355, 137, function() 
		print("Playing sample...")
		self:calculateSubsample()
		self:playSubsample()
	end)
	self.previewButton:setActive(false)
	self:addSprites(self.previewButton:getSprites())
	
	self.cancelButton = Button("Cancel", 294, 215, function() 
		self.onSampleReady(nil)
		self:dismiss()
	end)
	self:addSprites(self.cancelButton:getSprites())
	
	self.saveButton = Button("Save", 366, 215, function() 
		local finalSample = self:generateSubsample()
		assert(finalSample ~= nil, "Error generating final subsample")
		finalSample:save("recording.pda")
		onSampleReady("recording.pda")
		self:dismiss()
	end)
	self.saveButton:setActive(false)
	self:addSprites(self.saveButton:getSprites())
	
	playdate.inputHandlers.push(self:getInputHandler())
	self.showing = true
end

function RecordDialog:startRecording()
	local countdownMs = self.maxSeconds * 1000
	print("startRecording() ms: " .. countdownMs)
	self.recordCountdownTimer = playdate.timer.new(countdownMs, 0, countdownMs)
	self.recording = true
	self.remainingLabel:setAlpha(1)

	sound.micinput.recordToSample(self.buffer, function()
		self:sampleRecorded()
	end)
end

function RecordDialog:sampleRecorded()
	print("sampleRecorded()")
	self.remainingLabel:setAlpha(0.2)
	self.recording = false
	self.recordCountdownTimer:remove()
	self.samplePlayer:setSample(self.buffer)
	local sampleLength, bufferLength = self.buffer:getLength()
	self.scrubView:setSampleLength(sampleLength)
end

function RecordDialog:calculateSubsample()
	local sampleRate = playdate.sound.getSampleRate()
	local totalFrames = self.samplePlayer:getLength() * sampleRate
	
	local subsampleStart = self.scrubView:getSubsampleStartMilliseconds()/1000
	local startFrame = math.floor(subsampleStart * sampleRate)
	
	local subsampleEnd = self.scrubView:getSubsampleEndMilliseconds()/1000
	local endFrame = math.floor(subsampleEnd * sampleRate)
	
	assert(startFrame >= 0, "Start frame is less than 0")
	assert(startFrame < totalFrames, "Start frame is greater than total frames")
	assert(endFrame > 0, "End frame is less than 0")
	assert(endFrame <= totalFrames, "End frame is greater than total frames")
	assert(startFrame < endFrame, "Start frame is greater than end frame")

	self.samplePlayer:setPlayRange(startFrame, endFrame)
end

function RecordDialog:generateSubsample()
	local sampleRate = playdate.sound.getSampleRate()
	local subsampleStart = self.scrubView:getSubsampleStartMilliseconds()/1000
	local startFrame = math.floor(subsampleStart * sampleRate)
	
	local subsampleEnd = self.scrubView:getSubsampleEndMilliseconds()/1000
	local endFrame = math.floor(subsampleEnd * sampleRate)
	
	local subsample = self.buffer:getSubsample(startFrame, endFrame)
	assert(subsample ~= nil, "Error getting subsample")
	return subsample
end

function RecordDialog:playSubsample()
	print("Playing subsample...")
	if self.samplePlayer:isPlaying() then
		self.samplePlayer:stop()
	end
	self.samplePlayer:setFinishCallback(function()
		self.scrubView:stop()
	end)
	self.samplePlayer:play()
	self.scrubView:play()
end

function RecordDialog:update()
	if not self.showing then return end
	frame += 1
	
	-- Mic level update. Every 10th frame
	if math.fmod(frame, 10) == 0 then
		self.levelLabel:setText("Input level: " .. round((sound.micinput.getLevel() * 100), 2))
	end
	
	-- Update remaining sample time when recording
	if self.recording then
		self.remainingLabel:setText("Remaining buffer: " .. (self.maxSeconds - (self.recordCountdownTimer.value/1000)))
		self:updateAnimation()
	end
	
	if self.scrubView:isPlaying() then self.scrubView:update() end
end

function RecordDialog:updatePost()
	if self.recording then
		self:updateAnimation()
	end
end

function RecordDialog:isShowing()
	return self.showing
end

function RecordDialog:dismiss()
	self.showing = false
	playdate.inputHandlers.pop()
	
	for i=1,#sprites do
		print("removin sprite: " .. tostring(sprites[i]))
		sprites[i]:remove()
	end

	self:remove()
end

function RecordDialog:addSprites(_sprites)
	for i=1,#_sprites do
		self:addSprite(_sprites[i])
	end
end

function RecordDialog:addSprite(sprite)
	table.insert(sprites, sprite)
end

local x = 0.0
local y = -1.00
local z = -1.00
local ii = 0

local frame = 0
local change = 0

local inputLevel = 1

local lx = 5

function RecordDialog:updateAnimation()
	frame = frame + 2

	z = -1.00
	y = -1.00
	
	inputLevel = sound.micinput.getLevel() * 250
	
	playdate.graphics.drawCircleAtPoint(200, 88, 5 * inputLevel) 
	lx = math.max(5, math.floor(10 * inputLevel))
	playdate.graphics.drawLine(lx, 55, lx, 120)
	playdate.graphics.drawLine(400 - lx, 55, 400 - lx, 120)

	-- for i = 490, 1050, 4 do
	-- 	ii = i*0.001
	-- 	x = ii + sin(z*0.02) * 0.1
	-- 	y = (2 + inputLevel) * cos(ii * y - 2)
	-- 	z = 8 + y * sin(12 * ii + (frame*0.03)) * 25.0
	-- 	playdate.graphics.drawPixel(-130 + 425 * x, max(42, min(105, map(123 + z+y, 0, 400, 40, 130))))
	-- end
end

-- See https://sdk.play.date/1.12.3/Inside%20Playdate.html#M-inputHandlers
function RecordDialog:getInputHandler()
	return {
		cranked = function(change, acceleratedChange)
			if self.scrubView:isFocused() then
				self.scrubView:crank(change)
			end
		end,
		BButtonDown = function()
			if self.scrubView:isFocused() then
				self.scrubView:setBDown(true)
			else
				self:dismiss()
			end
		end,
		BButtonUp = function()
			if self.scrubView:isFocused() then
				self.scrubView:setBDown(false)
				self:calculateSubsample()
				self:playSubsample()
			end
		end,
		AButtonDown = function()
			if self.saveButton:isFocused() then
				self.saveButton:tap()
			elseif self.scrubView:isFocused() then
				self.scrubView:setADown(true)
			elseif self.recordToggleButton:isFocused() then
				self.recordToggleButton:tap()
			elseif self.previewButton:isFocused() then
				self.previewButton:tap()
			elseif self.cancelButton:isFocused() then
				self.cancelButton:tap()
			end
		end,
		AButtonUp = function()
			if self.scrubView:isFocused() then
				self.scrubView:setADown(false)
				self:calculateSubsample()
				self:playSubsample()
			end
		end,
		leftButtonDown = function()
			if self.saveButton:isFocused() then
				self.saveButton:setFocus(false)
				self.cancelButton:setFocus(true)
			elseif self.previewButton:isFocused() then
				self.recordToggleButton:setFocus(true)
				self.previewButton:setFocus(false)
			elseif self.cancelButton:isFocused() then
					self.recordToggleButton:setFocus(true)
					self.cancelButton:setFocus(false)
			end		
		end,
		rightButtonDown = function()
			if self.recordToggleButton:isFocused() and self.previewButton:isActive() then
				self.recordToggleButton:setFocus(false)
				self.previewButton:setFocus(true)
			elseif self.cancelButton:isFocused() and self.saveButton:isActive() then
				self.saveButton:setFocus(true)
				self.cancelButton:setFocus(false)
			end
		end,
		upButtonDown = function()
			if self.saveButton:isFocused() then
				self.saveButton:setFocus(false)
				self.previewButton:setFocus(true)
			elseif self.previewButton:isFocused() then
				self.scrubView:setFocus(true)
				self.previewButton:setFocus(false)
			elseif self.cancelButton:isFocused() then
				self.recordToggleButton:setFocus(true)
				self.cancelButton:setFocus(false)
			end	
		end,
		downButtonDown = function()
			if self.previewButton:isFocused() then
				self.saveButton:setFocus(true)
				self.previewButton:setFocus(false)
			elseif self.scrubView:isFocused() then
				self.scrubView:setFocus(false)
				self.previewButton:setFocus(true)
			elseif self.recordToggleButton:isFocused() then
				self.recordToggleButton:setFocus(false)
				self.cancelButton:setFocus(true)
			end			
		end
	}
end
