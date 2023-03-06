import 'CoracleViews/label_centre'

class('Button').extends()

function Button:init(label, xx, yy, listener)
	Button.super.init(self)
	
	self.hasFocus = false
	self.active = true
	
	self.listener = listener
	
	self.label = LabelCentre(label, xx, yy, 1)
	
	local nWidth, nHeight = playdate.graphics.getTextSize(label)
	
	local borderImage = playdate.graphics.image.new(nWidth + 20, nHeight + 6)
	playdate.graphics.pushContext(borderImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(1)
	playdate.graphics.drawRoundRect(1, 1, nWidth + 18, nHeight + 4, 3) 
	playdate.graphics.setLineWidth(1)
	playdate.graphics.popContext()
	self.borderSprite = playdate.graphics.sprite.new(borderImage)
	self.borderSprite:moveTo(xx, yy + (nHeight/2) - 2)
	self.borderSprite:add()
	self.borderSprite:setVisible(true)
	
	local focusedImage = playdate.graphics.image.new(nWidth + 20, nHeight + 6)
	playdate.graphics.pushContext(focusedImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(3)
	playdate.graphics.drawRoundRect(1, 1, nWidth + 18, nHeight + 4, 5) 
	playdate.graphics.setLineWidth(1)
	playdate.graphics.popContext()
	self.focusedSprite = playdate.graphics.sprite.new(focusedImage)
	self.focusedSprite:moveTo(xx, yy + (nHeight/2) - 2)
	self.focusedSprite:add()
	self.focusedSprite:setVisible(false)
end

function Button:setText(label)
	self.label:setText(label)
end

function Button:removeAll()
	self.label:remove()
	self.borderSprite:remove()
	self.focusedSprite:remove()
end

function Button:getSprites()
	return {self.label, self.borderSprite, self.focusedSprite}
end

function Button:isFocused()
	return self.hasFocus
end

function Button:setActive(active)
	self.active = active
	
	if active then
		self.label:setAlpha(1)
	else
		self.label:setAlpha(0.2)
	end
end

function Button:isActive()
	return self.active
end

function Button:setFocus(focus)
	self.hasFocus = focus
	self.focusedSprite:setVisible(focus)
	
	if focus then
		self:setActive(true)
	end
end

function Button:tap()	
	self.focusedSprite:moveBy(0, 1)
	playdate.timer.new(200, function()
		self.focusedSprite:moveBy(0, -1)
		if self.listener ~= nil then self.listener() end
	end)
end
