--[[
	
	
--]]

import 'CoracleViews/label_left'
import 'CoracleViews/label_centre'
import 'CoracleViews/label_right'
import 'CoracleViews/rotary_encoder'
import 'CoracleViews/button_minimal'
import 'CoracleViews/button'

class('SettingsDialog').extends(playdate.graphics.sprite)

local graphics <const> = playdate.graphics
local sprites = {}
 
function SettingsDialog:init(maxSeconds)
	SettingsDialog.super.init(self)
	self.showing = false
end

function SettingsDialog:show(onTempoChange, onRateChange)	
	
	self.onTempoChange = onTempoChange
	self.onRateChange = onRateChange
	
	self.showing = true
	local background = graphics.image.new(300, 140, graphics.kColorWhite)
	playdate.graphics.pushContext(background)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.drawRoundRect(0, 0, 300, 140, 3)
	playdate.graphics.popContext()
	self:moveTo(200, 120)
	self:setImage(background)
	self:add()
	
	self.tempoKnob = RotaryEncoder("Tempo", 200, 100, 100, function(value) 
		if self.onTempoChange ~= nil then self.onTempoChange(value) end
	end)
	self.tempoKnob:setFocus(true)
	
	self.dismissButton = ButtonMinimal("Done", 303, 170, 80, 12, function()
		--dismiss
		self:pop()
	end)
	
	
	
	playdate.inputHandlers.push(self:getInputHandler())
	
end

function SettingsDialog:pop()
	playdate.inputHandlers.pop()
	self.dismissButton:removeAll()
	self:remove()
end

-- See https://sdk.play.date/1.12.3/Inside%20Playdate.html#M-inputHandlers
function SettingsDialog:getInputHandler()
	return {
		cranked = function(change, acceleratedChange)
			if self.tempoKnob:isFocused() then
				self.tempoKnob:turn(change)
			end
		end,
		BButtonDown = function()
			
		end,
		BButtonUp = function()
			
		end,
		AButtonDown = function()
			if self.dismissButton:isFocused() then
				self.dismissButton:tap()
			end
		end,
		AButtonUp = function()
			
		end,
		leftButtonDown = function()
			
		end,
		rightButtonDown = function()
		
		end,
		upButtonDown = function()
		
		end,
		downButtonDown = function()
			if self.tempoKnob then
				self.dismissButton:setFocus(true)
				self.tempoKnob:setFocus(false)
			end
		end
	}
end
	