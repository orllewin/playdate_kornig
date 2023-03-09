--[[
	Config object:
	{midpoint, width, head, tail, parentLength}
--]]

import 'Coracle/math'
import 'CoracleViews/divider_vertical'

class('TrackView').extends()

local trackheight = 11
local margin = 5
 
function TrackView:init(yy)
	TrackView.super.init(self)
	self.yy = yy
	self.headDiv = DividerVertical(200, yy, trackheight, 0.4)
	self.midpointDiv = DividerVertical(200, yy, trackheight, 1)
	self.tailDiv = DividerVertical(200, yy, trackheight, 0.4)
end


function TrackView:update(config)
	local newX = map(config.midpoint, 0, config.parentLength, margin, 400-margin)	
	local widthPixels = map(config.width, 0, config.parentLength, margin, 400-margin)
	self.midpointDiv:moveTo(newX, self.yy)
	self.headDiv:moveTo(newX - (widthPixels/2), self.yy)
	self.tailDiv:moveTo(newX + (widthPixels/2), self.yy)
end