class('TextList').extends(playdate.graphics.sprite)

local rowHeight = 16

function TextList:init(items, xx, yy, w, h, onChange)
	TextList.super.init(self)
	self.items = items
	self.onChange = onChange
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	self.yy = yy
	self.w = w
	self.h = h
	self.index = 1
	self.indexOffset = 0
	self.visibleRows = h/rowHeight
	if self.visibleRows > #items then self.visibleRows = #items end
	self:moveTo(xx + w/2, yy + h/2)
	self:add()
	
	--Focus caret
	local focusImage = playdate.graphics.image.new(w+8, rowHeight+6)
	playdate.graphics.pushContext(focusImage)
		playdate.graphics.setLineWidth(2)
		playdate.graphics.drawRoundRect(2, 2, w+4, rowHeight+1, 4)
	playdate.graphics.popContext()
	self.focusSprite = playdate.graphics.sprite.new(focusImage)
	self.focusSprite:moveTo(xx + w/2, yy + rowHeight/2)
	self.focusSprite:add()
	self.focusSprite:setVisible(true)
	
	self:drawRows()
	self:drawFocused()
end

function TextList:updateItems(items)
	self.index = 1
	self.indexOffset = 0
	self.items = items
	self.visibleRows = self.h/rowHeight
	if self.visibleRows > #items then self.visibleRows = #items end
	self:drawRows()
	self:drawFocused()
end

function TextList:drawRows()
	local rowsImage = playdate.graphics.image.new(self.w, self.h)
	playdate.graphics.pushContext(rowsImage)
		for i=1,self.visibleRows do
			local text = self.items[i + self.indexOffset]
			if self:endsWith(text, ".pda") then  text = text:gsub(".pda", "") end
			print("Drawing " .. text)
			playdate.graphics.drawText(text, 4, ((i - 1) * rowHeight) + rowHeight/2 - 4)
		end
	playdate.graphics.popContext()
	self:setImage(rowsImage)
end

--http://lua-users.org/wiki/StringRecipes
function TextList:endsWith(str, ending)
	 return ending == "" or str:sub(-#ending) == ending
end

function TextList:drawFocused()
	self.focusSprite:moveTo(
		self.focusSprite.x, 
		self.yy + (rowHeight * (self.index - self.indexOffset)) - rowHeight/2)
end

function TextList:removeAll()
	self:remove()
	self.focusSprite:remove()
end

function TextList:cranked(value)
	if value > 0 then
		self:goUp()
	elseif value < 0 then
		self:goDown()
	end
end

function TextList:goUp()
	if self.index > 1 then 
		self.index -= 1 
		if self.index > self.visibleRows - 1 then self.indexOffset -= 1 end
	end
	
	self:drawRows()
	self:drawFocused()
	if self.onChange then self.onChange(self.index, self.items[self.index]) end
end

function TextList:goDown()
	if self.index < #self.items then 
		self.index += 1 
		if self.index > self.visibleRows then self.indexOffset += 1 end
	end
	
	self:drawRows()
	self:drawFocused()
	if self.onChange then self.onChange(self.index, self.items[self.index]) end
end

function TextList:setFocus(focus)
	self.hasFocus = focus
	self.focusSprite:setVisible(focus)
	
	if focus then
		if self.onChange then self.onChange(self.index, self.items[self.index]) end
	end
end

function TextList:emitSelected()
	if self.onChange then self.onChange(self.index, self.items[self.index]) end
end

function TextList:isFocused()
	return self.hasFocus
end