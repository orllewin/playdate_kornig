import 'CoracleViews/divider_vertical'

class('ScrubView').extends()

local graphics <const> = playdate.graphics
local scrubHeight = 70
local margin = 5
 
function ScrubView:init(yy)
	ScrubView.super.init(self)
	
	self.y = yy
	
	self.hasFocus = false
	
	self.playing = false
	self.length = 1
	self.timer = nil
	
	self.bDown = false
	self.aDown = false
	
	local borderImage = playdate.graphics.image.new(400, scrubHeight)
	playdate.graphics.pushContext(borderImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(1)
	playdate.graphics.drawRoundRect(margin, 1, 400 - (margin * 2), scrubHeight-1, 3) 
	playdate.graphics.popContext()
	self.borderSprite = playdate.graphics.sprite.new(borderImage)
	self.borderSprite:moveTo(200, yy + (scrubHeight/2))
	self.borderSprite:add()
	
	local focusImage = playdate.graphics.image.new(400, scrubHeight)
	playdate.graphics.pushContext(focusImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(3)
	playdate.graphics.drawRoundRect(margin, 1, 400 - (margin * 2), scrubHeight-2, 5) 
	playdate.graphics.setLineWidth(1)
	playdate.graphics.popContext()
	self.focusSprite = playdate.graphics.sprite.new(focusImage)
	self.focusSprite:moveTo(200, yy + (scrubHeight/2))
	self.focusSprite:add()
	self.focusSprite:setVisible(false)
	
	self.caretSprite = DividerVertical(margin, yy +1, 69, 0.8)
	self.caretSprite:hide()
	
	self.startSprite = DividerVertical(margin, yy +1, 69, 0.8)
	self.startSprite:hide()
	
	self.endSprite = DividerVertical(400-margin, yy +1, 69, 0.8)
	self.endSprite:hide()
end

function ScrubView:setSampleLength(length)
	print("ScrubView:setSampleLength(): " .. length)
	self.length = length
end

function ScrubView:play()
	local startMS = self:getSubsampleStartMilliseconds()
	local endMS = self:getSubsampleEndMilliseconds()
	self.timer = playdate.timer.new(endMS - startMS, self.startSprite:getX(), self.endSprite:getX())
	self.playing = true
	self.caretSprite:show()
end

function ScrubView:stop()
	self.playing = false
	self.caretSprite:hide()
end

function ScrubView:isPlaying()
	return self.playing
end

function ScrubView:update()
	self.caretSprite:moveToX(self.timer.value)
end

function ScrubView:getSubsampleStartMilliseconds()
	local lengthMs = self.length * 1000
	local startMS = map(self.startSprite:getX(), margin, 400-margin, 0, lengthMs)
	return startMS
end

function ScrubView:getSubsampleEndMilliseconds()
	local lengthMs = self.length * 1000
	local endMS = map(self.endSprite:getX(), margin, 400-margin, 0, lengthMs)
	return endMS
end

function ScrubView:crank(change)
	if self.bDown then
		self.startSprite:show()
		if change > 0 then
			self.startSprite:moveXBy(1)
		elseif change < 0 then
			self.startSprite:moveXBy(-1)
		end
	elseif self.aDown then
		self.endSprite:show()
		if change > 0 then
			self.endSprite:moveXBy(1)
		elseif change < 0 then
			self.endSprite:moveXBy(-1)
	end
	end
end

function ScrubView:getSprites()
	return {self.borderSprite, self.focusedSprite}
end

function ScrubView:isFocused()
	return self.hasFocus
end

function ScrubView:setADown(down)
	self.aDown = down
end

function ScrubView:setBDown(down)
	self.bDown = down
end

function ScrubView:setFocus(focus)
	self.hasFocus = focus
	self.focusSprite:setVisible(focus)
end