--[[
	
	granular
	grainy, 
	the obstinate knot in the grain of things
	
--]]

import 'CoreLibs/sprites'
import 'CoreLibs/graphics'
import 'CoreLibs/timer'
import 'Play/play_dialog'
import 'main_options_dialog'

local graphics <const> = playdate.graphics
local inverted = true
playdate.display.setInverted(inverted)

graphics.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.graphics.fillRect(0, 0, 400, 240)
end)

local font = playdate.graphics.font.new("Fonts/font-rains-1x")
playdate.graphics.setFont(font)

playdate.setMenuImage(playdate.graphics.image.new("Images/elderwean"), 100)

local optionsDialog = nil
local playDialog = nil

local menu = playdate.getSystemMenu()

local invertMenuItem, error = menu:addMenuItem("Invert Display", function() 
	inverted = not inverted
	playdate.display.setInverted(inverted)
end)

function playFile(path)
	playDialog = PlayDialog()
	print("Showing play dialog")
	playDialog:show(path, function(normalisedTempo)
			showSettings(normalisedTempo)
	end)
end

local cachePath = "recording.pda"

if playdate.file.exists(cachePath) then
	playFile(cachePath)
else
	optionsDialog = MainOptionDialog()
	optionsDialog:show(function(path) 
		playFile(path)
	end)
end

function playdate.update()
	if optionsDialog ~= nil and optionsDialog:isShowing() then optionsDialog:update() end
	if playDialog ~= nil and playDialog:isShowing() then playDialog:update() end
	
	playdate.graphics.sprite.update()
	playdate.timer.updateTimers()
	
	if playDialog ~= nil and playDialog:isShowing() then playDialog:updatePost() end
	if optionsDialog ~= nil and optionsDialog:isShowing() then optionsDialog:updatePost() end
end