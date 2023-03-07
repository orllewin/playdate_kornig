import 'CoracleViews/label_centre'
import 'CoracleViews/mini_slider'

class('GrainControl').extends(playdate.graphics.sprite)

local w = 80
local h = 150

function GrainControl:init(index, onPosition)
	GrainControl.super.init(self)
	
	self.onPosition = onPosition
	
	local xx = (index - 1) * w + (w/2)
	
	self:moveTo(xx, 240 - 50)
	
	self.label = LabelCentre("" .. index, xx, 240 - h)
	
	self.positionSlider = MiniSlider("Pos.", xx + 3, 118, w - 15, 50, 0, 100, 8, false, function(value) 
		print("position slider " .. index .. ": " .. value)
		if self.onPosition ~= nil then self.onPosition(index, value) end
	end)
end

function GrainControl:getSprites()
	return {self.label}
end

function GrainControl:getRow1View()
	return self.positionSlider
end