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

function TrackPopup:show(index, xx, onDelayLevel, onDelayFeedback, onLoActive, onLoFreq, onLoRes)	
	
	self.index = index
	self.onDelayLevel = onDelayLevel
	self.onDelayFeedback = onDelayFeedback
	self.onLoActive = onLoActive
	self.onLoFreq = onLoFreq
	self.onLoRes = onLoRes
	
	self.focusManager = FocusManager()
	
	--dialog background
	local dH = 195
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
	
	local yOffset = 50
	self.delayKnob = RotaryEncoder("Dly", xx+2, 16+yOffset, dW - 18, function(value) 
		if self.onDelayLevel ~= nil then self.onDelayLevel(self.index, value) end
	end)
	self.focusManager:addView(self.delayKnob, 1)
	
	self.feedbackKnob = RotaryEncoder("Fbk", xx+2, 49+yOffset, dW - 18, function(value) 
		if self.onDelayFeedback ~= nil then self.onDelayFeedback(self.index, value) end
	end)
	self.focusManager:addView(self.feedbackKnob, 2)
	
	self.div = DividerHorizontal(xx - 29, 119, 60, 0.4)
	
	--label, xx, yy, w, active, listener
	self.loSwitch = Switch("Lo",  xx+2, 88+yOffset, 55, false, function(active)
		if self.onLoActive ~= nil then self.onLoActive(self.index, active) end
	end)
	self.focusManager:addView(self.loSwitch, 3)
	
	self.loFreqKnob = RotaryEncoder("Frq", xx+2, 113+yOffset, dW - 18, function(value) 
		if self.onLoFreq ~= nil then self.onLoFreq(self.index, value) end
	end)
	self.focusManager:addView(self.loFreqKnob, 4)
	self.loResKnob = RotaryEncoder("Res", xx+2, 145+yOffset, dW - 18, function(value) 
		if self.onLoRes ~= nil then self.onLoRes(self.index, value) end
	end)
	self.focusManager:addView(self.loResKnob, 5)
	
	self.dismissButton = ButtonMinimal("Close", xx+2, 222, dW - 12, 12, function()
		--dismiss
		self:pop()
	end)
	self.focusManager:addView(self.dismissButton, 6)
	
	self.focusManager:push() 
	self.focusManager:start()
		
end

function TrackPopup:pop()
	self.focusManager:pop() 
	self.delayKnob :removeAll()
	self.div:remove()
	self.loSwitch:removeAll()
	self.loFreqKnob:removeAll()
	self.loResKnob:removeAll()
	self.feedbackKnob:removeAll()
	self.dismissButton:removeAll()
	self:remove()
end