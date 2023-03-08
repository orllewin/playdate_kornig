import 'CoracleViews/label_centre'
import 'CoracleViews/mini_slider'
import 'CoracleViews/rotary_encoder'

class('GrainControl').extends()

local w = 80
local h = 150

function GrainControl:init(index, onPosition, onDrift, onWidth)
	GrainControl.super.init(self)
	
	self.index = index
	self.onPosition = onPosition
	self.onDrift = onDrift
	self.onWidth = onWidth
	
	local xx = (index - 1) * w + (w/2)
		
	self.positionSlider = MiniSlider("Pos.", xx + 3, 90, w - 15, 50, 0, 100, 8, false, function(value) 
		print("position slider " .. index .. ": " .. value)
		if self.onPosition ~= nil then self.onPosition(index, value) end
	end)
	
	self.widthKnob = RotaryEncoder("Size", xx, 125, w - 15, function(value) 
		-- 0.0 to 1.0
		if self.onWidth ~= nil then self.onWidth(index, value) end
	end)
	self.driftKnob = RotaryEncoder("Drft", xx, 160, w - 15, function(value)
		-- 0.5 == 0 drift, 0.0 == full left drift, 1.0 == full right drift
		print("Drift: " .. value)
		if self.onDrift ~= nil then self.onDrift(index, map(value, 0.0, 1.0, -1.0, 1.0)) end
	end)
	self.driftKnob:setValue(0.5)
end

function GrainControl:getSprites()
	return { }
end

function GrainControl:getRow1View() return self.positionSlider end
function GrainControl:getRow2View() return self.widthKnob end
function GrainControl:getRow3View() return self.driftKnob end