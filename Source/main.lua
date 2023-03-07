--[[
	
	kornig
	grainy, granular
	the obstinate knot in the grain of things
	
--]]

import 'CoreLibs/sprites'
import 'CoreLibs/graphics'
import 'CoreLibs/timer'
import 'Play/play_dialog'
import 'Record/record_dialog'

import 'main_options_dialog'

local graphics <const> = playdate.graphics

--playdate.display.setInverted(true)

graphics.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.graphics.fillRect(0, 0, 400, 240)
end)

local sysBoldFont = playdate.graphics.getSystemFont(playdate.graphics.font.kVariantBold)
playdate.graphics.setFont(sysBoldFont)

playdate.setMenuImage(playdate.graphics.image.new("Images/playdate_test_card"), 100)

local recordDialog = nil
local playDialog = nil

local menu = playdate.getSystemMenu()
local patchMenuItem, error = menu:addOptionsMenuItem("Patch:", {"new", "open", "save"}, "new", function(value)
	if value == "new" then
		showRecordDialog()
	elseif value == "open" then
		print("todo: open existing")
	elseif value == "save" then
		print("todo: save current")
	end
end)

MainOptionDialog():show(function(option) 
	if option == "record" then
		showRecordDialog()
	elseif option == "open" then
		
	end
end)

function showRecordDialog()
	recordDialog = RecordDialog()
	recordDialog:show(function(parentPath)
		if parentPath == nil then
			--record cancelled
			print("Recording cancelled")
		else
			-- set up everything
			playDialog = PlayDialog()
			print("Showing play dialog")
			playDialog:show(parentPath)
		end
	end)
end

function playdate.update()
	if recordDialog ~= nil and recordDialog:isShowing() then recordDialog:update() end
	if playDialog ~= nil and playDialog:isShowing() then playDialog:update() end
	
	playdate.graphics.sprite.update()
	playdate.timer.updateTimers()
	
	if recordDialog ~= nil and recordDialog:isShowing() then recordDialog:updatePost() end
end