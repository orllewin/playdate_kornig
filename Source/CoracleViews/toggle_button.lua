class('ToggleButton').extends(playdate.graphics.sprite)

TOGGLE_LABEL_HEIGHT = 10

function ToggleButton:init(label, x, y, width, height, active, listener)
	LabelRight.super.init(self)
	
	self.label = label
	self.xx = x
	self.yy = y
	
	self.width = width
	self.height = height
	
	self.active = active
	self.hasFocus = false
	
	self.listener = listener
	
	self.label = LabelLeft(label, x - width/2, y - height/2)
	self.statusLabel = LabelRight("Off", x + width/2, y - height/2 + 4 + TOGGLE_LABEL_HEIGHT)
		
	self:draw()
	self:moveTo(x, y)
	self:add()
	
	local focusedImage = playdate.graphics.image.new(width + 14, height + TOGGLE_LABEL_HEIGHT -4)
	playdate.graphics.pushContext(focusedImage)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.graphics.setLineWidth(2)
	playdate.graphics.drawRoundRect(1, 1, width + 10, height + TOGGLE_LABEL_HEIGHT - 7, 5) 
	playdate.graphics.setLineWidth(1)
	playdate.graphics.popContext()
	self.focusedSprite = playdate.graphics.sprite.new(focusedImage)
	self.focusedSprite:moveTo(x, y + 1)
	self.focusedSprite:add()
	self.focusedSprite:setVisible(false)
	
end

function ToggleButton:draw()
	local image = playdate.graphics.image.new(self.width, self.height + TOGGLE_LABEL_HEIGHT)
	playdate.graphics.pushContext(image)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)

	if(self.active)then
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRect(0, TOGGLE_LABEL_HEIGHT + self.height/2 - 12/2, 16, 12)
	else
		playdate.graphics.setDitherPattern(0.8, playdate.graphics.image.kDitherTypeScreen)
		playdate.graphics.fillRect(0, TOGGLE_LABEL_HEIGHT + self.height/2 - 12/2, 16, 12)
	end
	playdate.graphics.popContext()
	
	self:setImage(image)
end

function ToggleButton:setActive(active)
	if self:getActive() == active then return end
	self.active = active
	self:draw()
end

function ToggleButton:getActive()
	return self.active
end

function ToggleButton:setFocus(focus)
	self.hasFocus = focus
	self.focusedSprite:setVisible(focus)
	
	if focus then
		self.label:setAlpha(1)
	else
		self.label:setAlpha(0.4)
	end
end

function ToggleButton:tap()
	self.active = not self.active
	
	if self.active then
		self.statusLabel:setText("On")
	else
		self.statusLabel:setText("Off")
	end
	
	self:draw()
	
	self.listener(self.active)
end