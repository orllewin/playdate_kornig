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
	self.levelLabel = LabelLeft("", 4, 4, 1.0)
	self.titleLabel = LabelCentre("Record Sample", 200, 4, 1.0)
	self.sourceLabel = LabelRight("Source: " .. sound.micinput.getSource(), 396, 4, 1.0)
	
	self.scrubView = ScrubView(40)
	
	self.recordToggleButton = Button("Start Recording", 74, 120, function() 
		self.recording = not self.recording
		if self.recording then
			self.recordToggleButton:setText("Stop Recording")
			self:startRecording()
		else
			self.recordToggleButton:setText("Start Recording")
			self.previewButton:setFocus(true)
			self.recordToggleButton:setFocus(false)
			sound.micinput.stopRecording()
		end
		
	end)
	self:addSprites(self.recordToggleButton:getSprites())
	self.recordToggleButton:setFocus(true)
	
	self.remainingLabel = LabelLeft("Remaining buffer: " .. self.maxSeconds, 6, 150, 0.2)
	
	self.previewButton = Button("Preview", 358, 120, function() 
		print("Playing sample...")
		self.samplePlayer:setFinishCallback(function()
			self.scrubView:stop()
		end)
		self.samplePlayer:play()
		self.scrubView:play()
	end)
	self.previewButton:setActive(false)
	self:addSprites(self.recordToggleButton:getSprites())
	
	self.cancelButton = Button("Cancel", 302, 215, function() 
		self.onSampleReady(nil)
		self:dismiss()
	end)
	self:addSprites(self.cancelButton:getSprites())
	
	self.saveButton = Button("Save", 368, 215, function() 
		--onSave
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
	
	assert(startFrame > 0, "Start frame is less than 0")
	assert(startFrame < totalFrames, "Start frame is greater than total frames")
	assert(endFrame > 0, "End frame is less than 0")
	--assert(endFrame < totalFrames, "End frame is greater than total frames")
	assert(startFrame < endFrame, "Start frame is greater than end frame")
	print(self.buffer)
	self.samplePlayer:setPlayRange(startFrame, endFrame)
end

function RecordDialog:playSubsample()
	print("Playing subsample...")
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
	end
	
	if self.scrubView:isPlaying() then self.scrubView:update() end
end

function RecordDialog:isShowing()
	return self.showing
end

function RecordDialog:dismiss()
	self.showing = false
	playdate.inputHandlers.pop()
	
	for i=1,#sprites do
		sprites[i]:remove()
	end
	
	self:remove()
end

function RecordDialog:addSprites(_sprites)
	for i=1,#_sprites do
		self:addSprite(sprites[i])
	end
end

function RecordDialog:addSprite(sprite)
	table.insert(sprites, sprite)
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
			if self.scrubView:isFocused() then
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
			if self.previewButton:isFocused() then
				self.recordToggleButton:setFocus(true)
				self.previewButton:setFocus(false)
			end		
		end,
		rightButtonDown = function()

		end,
		upButtonDown = function()
			if self.previewButton:isFocused() then
				self.scrubView:setFocus(true)
				self.previewButton:setFocus(false)
			elseif self.cancelButton:isFocused() then
				self.recordToggleButton:setFocus(true)
				self.cancelButton:setFocus(false)
			end	
		end,
		downButtonDown = function()
			if self.scrubView:isFocused() then
				self.scrubView:setFocus(false)
				self.previewButton:setFocus(true)
			elseif self.recordToggleButton:isFocused() then
				self.recordToggleButton:setFocus(false)
				self.cancelButton:setFocus(true)
			end			
		end
	}
end
