--[[
	Label draws one of LabelLeft, LabelCentre, LabelRight. 
	gravity should one of:
	
			-1 - LabelLeft
 			 0 - LabelCentre
 			 1 - LabelRight
	 
	The alpha argument is optional with a default of 1 but can also be changed later.
]]--

import 'CoracleViews/label_left'
import 'CoracleViews/label_centre'
import 'CoracleViews/label_right'

class('Label').extends()

function LabelCentre:init(text, x, y, gravity, alpha)
	assert(gravity == -1 or gravity == 0 or gravity == 1, "IllegalArument: gravity must be -1, 0, or 1")
	if gravity == -1 then
		self.label = LabelLeft(text, x, y, alpha)
	elseif gravity == 0 then
		self.label = LabelCentre(text, x, y, alpha)
	elseif gravity == 1 then
		self.label = LabelRight(text, x, y, alpha)
	end
end
