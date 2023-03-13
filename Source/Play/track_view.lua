--[[
	Config object:
	{midpoint, width, head, tail, parentLength}
--]]

import 'Coracle/math'
import 'CoracleViews/divider_vertical'
import 'CoracleViews/divider_horizontal'
import 'CoracleViews/block'

class('TrackView').extends()

local trackheight = 11
local margin = 5
 
function TrackView:init(yy)
	TrackView.super.init(self)
	self.yy = yy
	self.midpointDiv = DividerVertical(200, yy, trackheight, 1)
	self.hDiv = DividerHorizontal(5, yy, 390, 0.1)
	self.block = Block(200, yy, 20, trackheight, 0.4)
end


function TrackView:update(config)
	local newX = map(config.midpoint, 0, config.parentLength, margin, 400-margin)	
	local widthPixels = map(config.width, 0, config.parentLength, margin, 400-margin)
	self.midpointDiv:moveTo(newX, self.yy)
	self.block:setWidth(widthPixels)
	self.block:moveTo(newX, self.yy)
end