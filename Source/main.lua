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
import 'Settings/settings_dialog'

import 'main_options_dialog'

local graphics <const> = playdate.graphics
local inverted = true
playdate.display.setInverted(inverted)

graphics.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.graphics.fillRect(0, 0, 400, 240)
end)

local font = playdate.graphics.font.new("Fonts/Roobert-11-Medium")
playdate.graphics.setFont(font)

--local sysBoldFont = playdate.graphics.getSystemFont(playdate.graphics.font.kVariantBold)
--playdate.graphics.setFont(sysBoldFont)

playdate.setMenuImage(playdate.graphics.image.new("Images/playdate_test_card"), 100)

local recordDialog = nil
local playDialog = nil

local menu = playdate.getSystemMenu()

local recordMenuItem, error = menu:addMenuItem("Record", function() 
	if playDialog ~= nil and playDialog:isShowing() then playDialog:stop() end
	showRecordDialog()
end)
local invertMenuItem, error = menu:addMenuItem("Invert Display", function() 
	inverted = not inverted
	playdate.display.setInverted(inverted)
end)

local cachePath = "recording.pda"

if playdate.file.exists(cachePath) then
	playDialog = PlayDialog()
	print("Showing play dialog")
	playDialog:show(cachePath, function()
			showSettings()
	end)
else
	MainOptionDialog():show(function(option) 
		if option == "record" then
			if playDialog ~= nil and playDialog:isShowing() then playDialog:stop() end
			showRecordDialog()
		elseif option == "open" then
			
		end
	end)
end

function showSettings()
	local settingsDialog = SettingsDialog()
	settingsDialog:show(function(tempo) 
		-- onTempoChange 0.0 to 1.0
		print("onTempoChange: " .. tempo)
		if playDialog ~= nil and playDialog:isShowing() then playDialog:changeTempo(tempo) end
	end, function(rate) 
		-- onRateChange
		print("onRateChange: " .. rate)
		if playDialog ~= nil and playDialog:isShowing() then playDialog:changeRate(rate) end
	end)
end

function showRecordDialog()
	playdate.graphics.sprite.removeAll()
	recordDialog = RecordDialog()
	recordDialog:show(function(parentPath)
		if parentPath == nil then
			--record cancelled
			print("Recording cancelled")
		else
			-- set up everything
			playDialog = PlayDialog()
			print("Showing play dialog", function()
				showSettings()
			end)
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