--[[
	
	kornig
	grainy, granular
	the obstinate knot in the grain of things
	
--]]

import 'CoreLibs/sprites'
import 'CoreLibs/graphics'
import 'CoreLibs/timer'
import 'Play/grain_player'
import 'Record/record_dialog'

local graphics <const> = playdate.graphics

local sysBoldFont = playdate.graphics.getSystemFont(playdate.graphics.font.kVariantBold)
playdate.graphics.setFont(sysBoldFont)

playdate.setMenuImage(playdate.graphics.image.new("Images/playdate_test_card"), 100)

local recordDialog = RecordDialog()
recordDialog:show(function(parentPath)
	if parentPath == nil then
		--record cancelled
	else
		-- set up everything
	end
end)

function playdate.update()
	if recordDialog:isShowing() then recordDialog:update() end
	
	playdate.graphics.sprite.update()
	playdate.timer.updateTimers()
end