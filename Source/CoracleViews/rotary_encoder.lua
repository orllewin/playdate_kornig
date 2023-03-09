--[[
	
]]--

import 'Coracle/math'
import 'CoracleViews/label_left'

class('RotaryEncoder').extends(playdate.graphics.sprite)

function RotaryEncoder:init(label, xx, yy, w, listener)
	RotaryEncoder.super.init(self)
	
	self.listener = listener

	local image = playdate.graphics.image.new(20, 20, playdate.graphics.kColorWhite)
	playdate.graphics.pushContext(image)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.drawCircleAtPoint(10, 10, 10)
	playdate.graphics.fillCircleAtPoint(7, 15, 2)
	playdate.graphics.popContext()
	
	self:setImage(image)
	self:moveTo(xx + w/2 - 15, yy)
	self:add()
	
	self.hasFocus = false
	
	local LABEL_HEIGHT = 12
	local MSLIDER_HEIGHT = 10
	local focusedImage = playdate.graphics.image.new(w + 12, MSLIDER_HEIGHT + LABEL_HEIGHT + 12)
	playdate.graphics.pushContext(focusedImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(2)
	playdate.graphics.drawRoundRect(1, 1, w + 6, MSLIDER_HEIGHT + LABEL_HEIGHT + 10, 5) 
	playdate.graphics.setLineWidth(1)
	playdate.graphics.popContext()
	self.focusedSprite = playdate.graphics.sprite.new(focusedImage)
	self.focusedSprite:moveTo(xx, yy + 1)
	self.focusedSprite:add()
	self.focusedSprite:setVisible(false)
	
	self.label = LabelLeft(label, xx - w/2, yy - 3, 0.4)

end

function RotaryEncoder:removeAll()
	self.label:remove()
	self.focusedSprite:remove()
	self:remove()
end

function RotaryEncoder:turn(degrees)
	if(degrees == 0.0)then return end --indicates no change from crank in this frame
	self:setRotation(math.max(0, (math.min(300, self:getRotation() + degrees))))
	if self.listener ~= nil then self.listener(round(self:getValue(), 2)) end
end

-- 0.0 to 1.0
function RotaryEncoder:getValue()
	return map(self:getRotation(), 0, 300, 0.0, 1.0)
end

-- 0.0 to 1.0
function RotaryEncoder:setValue(value)
	local normalised = value
	if value > 1.0 then
		normalised = 1.0
	elseif value < 0.0 then
		normalised = 0.0
	end
	self:turn(map(normalised, 0.0, 1.0, 0, 300))
	if(self.listener ~= nil)then self.listener(round(normalised, 2)) end
end

function RotaryEncoder:isFocused()
	return self.hasFocus
end

function RotaryEncoder:setFocus(focus)
	self.hasFocus = focus
	self.focusedSprite:setVisible(focus)
	
	if focus then
		self.label:setAlpha(1)
	else
		self.label:setAlpha(0.4)
	end
end