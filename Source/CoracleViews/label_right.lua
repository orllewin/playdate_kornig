--[[
	LabelRight draws a label in the current default font (set via playdate.graphics.setFont(font))
	with right edge at x, and top edge at y, LabelRight("Hello", 400, 0) will draw in the top right corner of the screen.
	The alpha argument is optional with a default of 1 but can also be changed later.
	_____________________
	|              Hello|
	|                   |
	|                   |
	|___________________|
]]--

class('LabelRight').extends(playdate.graphics.sprite)

function LabelRight:init(text, x, y, alpha)
	LabelRight.super.init(self)
	
	self.xx = x
	self.yy = y
	
	if alpha == nil then
		self.alpha = 1
	else
		self.alpha = alpha
	end
	
	self:setText(text)
	self:add()
end

function LabelRight:setAlpha(alpha)
	self.alpha = alpha
	self:forceRedraw()
end

function LabelRight:forceRedraw()
	local text = self.text
	self.text = ""
	self:setText(text)
end

function LabelRight:setText(text)
	if text == self.text then return end -- only redraw if text has changed
	self.text = text
	local nWidth, nHeight = playdate.graphics.getTextSize(self.text)
	local image = playdate.graphics.image.new(nWidth, nHeight)
	playdate.graphics.pushContext(image)
	playdate.graphics.drawText(self.text, 0, 0)
	playdate.graphics.popContext()
	
	if(self.alpha == 1) then
		self:setImage(image)
	else
		local base = playdate.graphics.image.new(nWidth, nHeight)
		playdate.graphics.pushContext(base)
		image:drawFaded(0, 0, self.alpha, playdate.graphics.image.kDitherTypeBayer2x2)
		playdate.graphics.popContext()
		self:setImage(base)
	end

	self:moveTo(self.xx - (nWidth/2), self.yy + (nHeight/2))
end
