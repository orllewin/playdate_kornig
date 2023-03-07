class('MiniSlider').extends(playdate.graphics.sprite)

LABEL_HEIGHT = 12
MSLIDER_HEIGHT = 10

function MiniSlider:init(label, xx, yy, w, value, rangeStart, rangeEnd, segments, showValue, listener)
	MiniSlider.super.init(self)

	self.label = label
	self.value = value
	self.segments = segments
	self.showValue = showValue
	self.xx = xx
	self.yy = yy
	self.w = w
	self.rangeStart = rangeStart
	self.rangeEnd = rangeEnd
	self.listener = listener
	self.labelIsFloat = labelIsFloat
	self.hasFocus = false
	
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	
	local backplateImage = playdate.graphics.image.new(w, MSLIDER_HEIGHT + LABEL_HEIGHT)
	
	--Start backplate drawing
	playdate.graphics.pushContext(backplateImage)
	playdate.graphics.setLineWidth(1)

	for i=1,self.segments do
		local x = map(i, 1, self.segments, 0, w)
		playdate.graphics.drawLine(x, LABEL_HEIGHT, x, MSLIDER_HEIGHT/2 - 2 + LABEL_HEIGHT) 
		playdate.graphics.drawLine(x, LABEL_HEIGHT + MSLIDER_HEIGHT/2 + 2, x, MSLIDER_HEIGHT + LABEL_HEIGHT) 
	end	
	playdate.graphics.setLineWidth(1)
	playdate.graphics.popContext()
	--End backplate drawing
	
	self:setImage(backplateImage)
		
	self:moveTo(xx, yy)
	self:add()
	
	self.label = LabelLeft(label, xx - w/2, yy - MSLIDER_HEIGHT - 1, 0.4)
	
	local knobImage = playdate.graphics.image.new(10, MSLIDER_HEIGHT + 6)
	playdate.graphics.pushContext(knobImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)

	playdate.graphics.fillRoundRect(0, 0, 10, MSLIDER_HEIGHT + 6, 2) 
	playdate.graphics.popContext()
	self.knobSprite = playdate.graphics.sprite.new(knobImage)
	self.knobSprite:moveTo(xx - (w/2) + map(value, rangeStart, rangeEnd, 5, self.w - 10), yy + LABEL_HEIGHT - 6)
	self.knobSprite:add()
	
	if showValue then 
		self.valueLabel = LabelRight("" .. self.value, xx - (w/2) + w - 4, yy - MSLIDER_HEIGHT - 3) 
	end
	
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

end

function MiniSlider:turn(degrees)
	
	if(degrees == 0.0)then return end --indicates no change from crank in this frame
	-- self:setRotation(math.max(0, (math.min(300, self:getRotation() + degrees))))
	if degrees > 0 and self.value < self.rangeEnd then
		self.value += 1
	elseif self.value > self.rangeStart then
		self.value -= 1
	end
	print("minislider turn: " .. self.value)
	self.knobSprite:moveTo(self.xx - (self.w/2) + map(self.value, self.rangeStart, self.rangeEnd, 5, self.w - 10), self.yy + LABEL_HEIGHT - 6)
	
	print("showValue: " .. tostring(self.showValue))
	if self.showValue then
		print("show labelllll" .. self.value)
		self.valueLabel:setText(self.value)
	end
		
	if self.listener ~= nil then self.listener(self.value) end
end

function MiniSlider:setFocus(focus)
	self.hasFocus = focus
	self.focusedSprite:setVisible(focus)
	
	if focus then
		self.label:setAlpha(1)
	else
		self.label:setAlpha(0.4)
	end
end