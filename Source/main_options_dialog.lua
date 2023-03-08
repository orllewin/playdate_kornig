--[[
	
	Welcome screen.
	
--]]

import 'CoracleViews/label_left'
import 'CoracleViews/label_centre'
import 'CoracleViews/label_right'
import 'CoracleViews/divider_horizontal'
import 'CoracleViews/button'

class('MainOptionDialog').extends(playdate.graphics.sprite)

local graphics <const> = playdate.graphics

function MainOptionDialog:init()
	MainOptionDialog.super.init(self)
end

function MainOptionDialog:show(onOption)
	
	self.onOption = onOption
	
	local background = graphics.image.new(400, 240, graphics.kColorWhite)
	self:moveTo(200, 120)
	self:setImage(background)
	self:add()
	
	graphics.setImageDrawMode(graphics.kDrawModeFillBlack)
	
	self.titleLabel = LabelLeft("Kornig", 6, 12)
	self.introLabel = LabelLeft("An experimental grain sampler.", 6, 54)
	self.div = DividerHorizontal(6, 42, 388, 0.2)
	
	self.recordSampleButton = Button("Record Sample", 76, 90, function() 
		playdate.inputHandlers.pop()
		self.onOption("record")
		self:dismiss()
	end)
	self.recordSampleButton:setFocus(true)
	
	self.loadSampleButton = Button("Load Sample", 66, 125, function() 
		playdate.inputHandlers.pop()
		self.onOption("open")
		self:dismiss()
	end)
	
	self.orlLabel = LabelRight("ORLLEWIN, YORKSHIRE", 394, 217, 0.40)

	
	playdate.inputHandlers.push(self:getInputHandler())
end

function MainOptionDialog:dismiss()
	
	self.titleLabel:remove()
	self.introLabel:remove()
	self.orlLabel:remove()
	self.div:remove()
	self.loadSampleButton:removeAll()
	self.recordSampleButton:removeAll()
	self:remove()
end

-- See https://sdk.play.date/1.12.3/Inside%20Playdate.html#M-inputHandlers
function MainOptionDialog:getInputHandler()
	return {
		AButtonDown = function()
			if self.loadSampleButton:isFocused() then
				self.loadSampleButton:tap()
			elseif self.recordSampleButton:isFocused() then
				self.recordSampleButton:tap()
			end
		end,
		upButtonDown = function()
			if self.loadSampleButton:isFocused() then
				self.loadSampleButton:setFocus(false)
				self.recordSampleButton:setFocus(true)
			end	
		end,
		downButtonDown = function()
			if self.recordSampleButton:isFocused() then
				self.loadSampleButton:setFocus(true)
				self.recordSampleButton:setFocus(false)
			end			
		end
	}
end