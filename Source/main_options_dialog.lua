--[[
	
	Welcome screen.
	
--]]

import 'CoracleViews/label_left'
import 'CoracleViews/label_centre'
import 'CoracleViews/label_right'
import 'CoracleViews/divider_horizontal'
import 'CoracleViews/button_minimal'

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
	
	self.titleLabel = LabelLeft("Granular .. . .  .  .   .    .     .      .       .", 6, 6, 0.4)
	self.introLabel = LabelLeft("An experimental grain sampler.", 6, 54)
	self.div = DividerHorizontal(6, 25, 388, 0.2)
	
	self.recordSampleButton = ButtonMinimal("Record Sample", 72, 90, 130, 20, function() 
		playdate.inputHandlers.pop()
		self.onOption("record")
		self:dismiss()
	end)
	self.recordSampleButton:setFocus(true)
	
	self.loadSampleButton = ButtonMinimal("Load Sample", 72, 122, 130, 20, function() 
		playdate.inputHandlers.pop()
		self.onOption("open")
		self:dismiss()
	end)
	
	self.orlLabel = LabelRight("ORLLEWIN, YORKSHIRE", 394, 227, 0.4)

	
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