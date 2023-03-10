class('Switch').extends(playdate.graphics.sprite)

TOGGLE_LABEL_HEIGHT = 14

function Switch:init(label, xx, yy, w, active, listener)
	Switch.super.init(self)
	
	self.xx = xx
	self.yy = yy
	
	self.w = w
	self.h = TOGGLE_LABEL_HEIGHT
	
	self.active = active
	self.hasFocus = false
	self.clickable = true
	
	self.listener = listener
	
	self.label = LabelLeft(label, xx - w/2, yy - TOGGLE_LABEL_HEIGHT/2 + 4)
	self.label:setAlpha(0.4)
	
	self:draw()
	self:moveTo(xx, yy)
	self:add()
	
	local focusedImage = playdate.graphics.image.new(w + 12, TOGGLE_LABEL_HEIGHT + TOGGLE_LABEL_HEIGHT -4)
	playdate.graphics.pushContext(focusedImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(2)
	playdate.graphics.drawRoundRect(1, 1, w + 6, TOGGLE_LABEL_HEIGHT + TOGGLE_LABEL_HEIGHT -  10, 5) 
	playdate.graphics.setLineWidth(1)
	playdate.graphics.popContext()
	self.focusedSprite = playdate.graphics.sprite.new(focusedImage)
	self.focusedSprite:moveTo(xx, yy + 1)
	self.focusedSprite:add()
	self.focusedSprite:setVisible(false)
	
end

function Switch:removeAll()
	self.label:remove()
	self.focusedSprite:remove()
	self:remove()
	
end

function Switch:draw()
	local image = playdate.graphics.image.new(self.w, self.h + TOGGLE_LABEL_HEIGHT)
	playdate.graphics.pushContext(image)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)

	if self.clickable == false then 
		print("UNCLICKABLE")
		playdate.graphics.fillRect(self.w - 20, (TOGGLE_LABEL_HEIGHT-12)/2 + 6, 16, 12)
	elseif(self.active)then
		playdate.graphics.fillRect(self.w - 20, (TOGGLE_LABEL_HEIGHT-12)/2 + 6, 16, 12)
	else
		playdate.graphics.drawRect(self.w - 20, (TOGGLE_LABEL_HEIGHT-12)/2 + 6, 16, 12)
	end
	playdate.graphics.popContext()
	
	if self.clickable == false then
		local fadeImage = playdate.graphics.image.new(self.w, self.h + TOGGLE_LABEL_HEIGHT)
		playdate.graphics.pushContext(fadeImage)
		image:drawFaded(0, 0, 0.4, playdate.graphics.image.kDitherTypeBayer2x2)
		playdate.graphics.popContext()
		self:setImage(fadeImage)
	else
		self:setImage(image)
	end
	
	
end

function Switch:setUnclickable()
	print("Switch:setUnclickable()")
	self.clickable = false
	self:draw()
end

function Switch:setActive(active)
	if self:getActive() == active then return end
	self.active = active
	self:draw()
end

function Switch:getActive()
	return self.active
end

function Switch:setFocus(focus)
	self.hasFocus = focus
	self.focusedSprite:setVisible(focus)
	
	if focus then
		self.label:setAlpha(1)
	else
		self.label:setAlpha(0.4)
	end
end

function Switch:tap()
	print("switch tap")
	if self.clickable == false then return end
	self.active = not self.active	
	self:draw()
	
	self.listener(self.active)
end