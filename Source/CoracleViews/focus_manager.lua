class('FocusManager').extends()

-- Handles navigation. 
-- Any view added to this class must have a setFocus(bool)
-- Views that work with the crank should have a turn(degrees) method
function FocusManager:init(_unhandledListener)
	FocusManager.super.init(self)
	
	if _unhandledListener ~= nil then _unhandledListener(0) end
	
	self.unhandledListener = _unhandledListener
	
	if self.unhandledListener ~= nil then self.unhandledListener(10) end
	
	self.viewMatrix = {}
	self.activeRow = 1
	self.activeIndex = 1
	self.handlingInput = false
	self.started = false
end

function FocusManager:start()
	assert(#self.viewMatrix[1] > 0, "You havn't added any views")
	self.viewMatrix[1][1]:setFocus(true)
	self.started = true
end

function FocusManager:hasStarted()
	return self.started
end

function FocusManager:unfocus()
	self:getFocusedView():setFocus(false)
end

function FocusManager:refocus()
	self:getFocusedView():setFocus(true)
end

function FocusManager:addView(view, row)
	assert(view.setFocus ~= nil, "Views added to FocusManager must have a setFocus(bool) method")
	view:setFocus(false)
	if(#self.viewMatrix < row) then self.viewMatrix[row] = {} end
	table.insert(self.viewMatrix[row], view)
end

function FocusManager:getView(row, index)
	return self.viewMatrix[row][index]
end

function FocusManager:getFocusedView()
	return self.viewMatrix[self.activeRow][self.activeIndex]
end

function FocusManager:getActiveRow()
	return self.viewMatrix[self.activeRow]
end

function FocusManager:getRowSize(row)
	return #self.viewMatrix[row]
end

function FocusManager:turnFocusedView(degrees)
	if(degrees == 0.0 or self:isHandlingInput() == false)then return end --indicates no change from crank in this frame
	local active = self:getFocusedView()
	if(active.turn ~= nill) then active:turn(degrees) end
end

function FocusManager:tapFocusedView()
	local active = self:getFocusedView()
	if(active.tap ~= nill) then active:tap() end
end

function FocusManager:push() 
	print("FocusManager push inputHandler")
	playdate.inputHandlers.push(self:getInputHandler())
	self.handlingInput = true
end

function FocusManager:pop() 
	playdate.inputHandlers.pop() 
	self.handlingInput = false
end

function FocusManager:isHandlingInput()
	return self.handlingInput
end

-- See https://sdk.play.date/1.12.3/Inside%20Playdate.html#M-inputHandlers
function FocusManager:getInputHandler()
	return {
		cranked = function(change, acceleratedChange)
			print("cha cha changes'; " .. change)
			local focused = self:getFocusedView()
			if focused.turn ~= nil then focused:turn(change) end
		end,
		leftButtonDown = function()
			if(self.activeIndex > 1) then
				self:getFocusedView():setFocus(false)
				self.activeIndex -= 1
				self:getFocusedView():setFocus(true)
			else
				if self.unhandledListener ~= nil then self.unhandledListener(-1) end
			end
		end,
		rightButtonDown = function()
			if(self.activeIndex < #self:getActiveRow()) then
				self:getFocusedView():setFocus(false)
				self.activeIndex += 1
				self:getFocusedView():setFocus(true)
			else
				if self.unhandledListener ~= nil then self.unhandledListener(1) end
			end
		end,
		upButtonDown = function()
			local focusedView = self:getFocusedView()
			if focusedView.canGoUp ~= nil and focusedView:canGoUp() then
				focusedView:goUp()
			elseif(self.activeRow > 1)then
				self:getFocusedView():setFocus(false)
				local prevRowCount = self:getRowSize(self.activeRow - 1)
				if(prevRowCount < self.activeIndex)then self.activeIndex = prevRowCount end
				self.activeRow -= 1
				self:getFocusedView():setFocus(true)
			end
		end,
		downButtonDown = function()
			local focusedView = self:getFocusedView()
			if focusedView.canGoDown ~= nil and focusedView:canGoDown() then
				focusedView:goDown()
			elseif(self.activeRow < #self.viewMatrix)then
				self:getFocusedView():setFocus(false)
				local nextRowCount = self:getRowSize(self.activeRow + 1)
				if(nextRowCount < self.activeIndex)then self.activeIndex = nextRowCount end
				self.activeRow += 1
				self:getFocusedView():setFocus(true)
			end
		end
	}
end
