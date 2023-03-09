--[[
	
	
--]]

import 'CoracleViews/focus_manager'
import 'CoracleViews/label_left'
import 'CoracleViews/label_centre'
import 'CoracleViews/label_right'
import 'CoracleViews/rotary_encoder'
import 'CoracleViews/button_minimal'
import 'CoracleViews/button'

class('SettingsDialog').extends(playdate.graphics.sprite)

local graphics <const> = playdate.graphics
local sprites = {}
 
function SettingsDialog:init()
	SettingsDialog.super.init(self)
	self.showing = false
end

function SettingsDialog:show(normalisedTempo, onTempoChange, onRateChange)	
	
	self.focusManager = FocusManager(nil, function() 
		--bListener
		self:pop()
	end)
	
	self.onTempoChange = onTempoChange
	self.onRateChange = onRateChange
	
	local dH = 138
	self.showing = true
	local background = graphics.image.new(120, dH, graphics.kColorWhite)
	playdate.graphics.pushContext(background)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.drawRoundRect(0, 0, 120, dH, 3)
	playdate.graphics.popContext()
	self:moveTo(340, dH/2)
	self:setImage(background)
	self:add()
	
	self.tempoKnob = RotaryEncoder("Tempo", 342, 23, 100, function(value) 
		if self.onTempoChange ~= nil then self.onTempoChange(value) end
	end)
	self.tempoKnob:setValue(normalisedTempo)
	self.focusManager:addView(self.tempoKnob, 1)
	
	self.rate0_1Button = ButtonMinimal("Rate: 0.125", 342, 50, 108, 12, function()
		if self.onRateChange ~= nil then self.onRateChange(0.125) end
		self:pop()
	end)
	self.focusManager:addView(self.rate0_1Button, 2)
	
	self.rate0_25Button = ButtonMinimal("Rate: 0.25", 342, 73, 108, 12, function()
		if self.onRateChange ~= nil then self.onRateChange(0.25) end
		self:pop()
	end)
	self.focusManager:addView(self.rate0_25Button, 3)
	
	self.rate0_5Button = ButtonMinimal("Rate: 0.5", 342, 96, 108, 12, function()
		if self.onRateChange ~= nil then self.onRateChange(0.5) end
		self:pop()
	end)
	self.focusManager:addView(self.rate0_5Button, 4)
	
	self.rate1Button = ButtonMinimal("Rate: 1.0", 342, 119, 108, 12, function()
		if self.onRateChange ~= nil then self.onRateChange(1.0) end
		self:pop()
	end)
	self.focusManager:addView(self.rate1Button, 5)
	
	self.focusManager:push() 
	self.focusManager:start()
		
end

function SettingsDialog:pop()
	self.focusManager:pop() 
	self.tempoKnob :removeAll()
	self.rate0_1Button:removeAll()
	self.rate0_25Button:removeAll()
	self.rate0_5Button:removeAll()
	self.rate1Button:removeAll()
	self:remove()
end