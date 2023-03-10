--[[
	
	
--]]

import 'CoracleViews/focus_manager'
import 'CoracleViews/rotary_encoder'
import 'CoracleViews/button_minimal'
import 'CoracleViews/button'
import 'CoracleViews/switch'
import 'CoracleViews/divider_horizontal'

class('TrackPopup').extends(playdate.graphics.sprite)

local graphics <const> = playdate.graphics
local sprites = {}
 
function TrackPopup:init()
	TrackPopup.super.init(self)
	self.showing = false
end

function TrackPopup:show(index, normalisedValues, xx, onDelayLevel, onDelayFeedback, onLoActive, onLoFreq, onLoRes, onRate)	
	
	self.index = index
	self.onDelayLevel = onDelayLevel
	self.onDelayFeedback = onDelayFeedback
	self.onLoActive = onLoActive
	self.onLoFreq = onLoFreq
	self.onLoRes = onLoRes
	self.onRate = onRate
	
	self.focusManager = FocusManager(nil, function() 
		self:pop()
	end)
	
	--dialog background
	local dH = 240
	local dW = 76
	self.showing = true
	local background = graphics.image.new(dW, dH, graphics.kColorWhite)
	playdate.graphics.pushContext(background)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.drawRoundRect(0, 0, dW, dH, 3)
	playdate.graphics.popContext()
	self:moveTo(xx, 240 - dH/2)
	self:setImage(background)
	self:add()
	
	local globalRate = normalisedValues.globalRate
	
	print("GLOBAL RATE: " .. globalRate)
	
	self.rate0125Switch = Switch("0.12",  xx+2, 14, 55, false, function(active)
		if self.onRate ~= nil then self.onRate(self.index, 1, active) end
	end)
	self.focusManager:addView(self.rate0125Switch, 1)
	if globalRate == 0.125 then
		self.rate0125Switch:setUnclickable()
	end
	
	self.rate025Switch = Switch("0.25",  xx+2, 14 + 20, 55, false, function(active)
		if self.onRate ~= nil then self.onRate(self.index, 2, active) end
	end)
	self.focusManager:addView(self.rate025Switch, 2)
	if globalRate == 0.25 then
		print("SETTING rate025Switch unclickable")
		self.rate025Switch:setUnclickable()
	end
	
	self.rate05Switch = Switch("0.5",  xx+2, 14 + 40, 55, false, function(active)
		if self.onRate ~= nil then self.onRate(self.index, 3, active) end
	end)
	self.focusManager:addView(self.rate05Switch, 3)
	if globalRate == 0.5 then
		self.rate05Switch:setUnclickable()
	end
	
	self.rate1Switch = Switch("1.0",  xx+2, 14 + 60, 55, false, function(active)
		if self.onRate ~= nil then self.onRate(self.index, 4, active) end
	end)
	self.focusManager:addView(self.rate1Switch, 4)
	if globalRate == 1.0 then
		self.rate1Switch:setUnclickable()
	end
	
	local yOffset = 72
	self.delayKnob = RotaryEncoder("Dly", xx+2, 27+yOffset, dW - 18, function(value) 
		if self.onDelayLevel ~= nil then self.onDelayLevel(self.index, value) end
	end)
	self.delayKnob:setValue(normalisedValues.delayMix)
	self.focusManager:addView(self.delayKnob, 5)
	
	self.feedbackKnob = RotaryEncoder("Fbk", xx+2, 60+yOffset, dW - 18, function(value) 
		if self.onDelayFeedback ~= nil then self.onDelayFeedback(self.index, value) end
	end)
	self.feedbackKnob:setValue(normalisedValues.delayFeedback)
	self.focusManager:addView(self.feedbackKnob, 6)

	self.loSwitch = Switch("Lo",  xx+2, 88+yOffset, 55, normalisedValues.loActive, function(active)
		if self.onLoActive ~= nil then self.onLoActive(self.index, active) end
	end)
	self.focusManager:addView(self.loSwitch, 7)
	
	self.loFreqKnob = RotaryEncoder("Frq", xx+2, 113+yOffset, dW - 18, function(value) 
		if self.onLoFreq ~= nil then self.onLoFreq(self.index, value) end
	end)
	self.loFreqKnob:setValue(normalisedValues.loFreq)
	self.focusManager:addView(self.loFreqKnob, 8)
	self.loResKnob = RotaryEncoder("Res", xx+2, 145+yOffset, dW - 18, function(value) 
		if self.onLoRes ~= nil then self.onLoRes(self.index, value) end
	end)
	self.loResKnob:setValue(normalisedValues.loRes)
	self.focusManager:addView(self.loResKnob,9)

	self.focusManager:push() 
	self.focusManager:startSpecific(5, 1)
		
end

function TrackPopup:pop()
	self.focusManager:pop() 
	self.rate0125Switch:removeAll()
	self.rate025Switch:removeAll()
	self.rate05Switch:removeAll()
	self.rate1Switch:removeAll()
	self.delayKnob :removeAll()
	self.loSwitch:removeAll()
	self.loFreqKnob:removeAll()
	self.loResKnob:removeAll()
	self.feedbackKnob:removeAll()
	self:remove()
end