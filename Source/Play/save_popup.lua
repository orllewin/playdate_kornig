import 'CoracleViews/label_centre'
import 'CoreLibs/keyboard'

class('SavePopup').extends(playdate.graphics.sprite)

local graphics <const> = playdate.graphics
local sprites = {}

local instance = nil

local FILENAME_PREFIX = "gnlr-"
local filename = FILENAME_PREFIX
 
function SavePopup:init()
	SavePopup.super.init(self)
	self.showing = false
	instance = self
end

function SavePopup:show(onSave)	
	self.onSave = onSave
	playdate.keyboard.show(filename)
end

function playdate.keyboard.keyboardDidShowCallback()
	local keyboardWidth = playdate.keyboard.width()
	local windowWidth = 400 - keyboardWidth
	
	print("Keyboard width: " .. keyboardWidth)
	
	instance.showing = true
	local background = graphics.image.new(windowWidth, 240, graphics.kColorWhite)
	playdate.graphics.pushContext(background)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.drawRoundRect(0, 0, windowWidth, 240, 3)
	playdate.graphics.popContext()
	instance:moveTo(windowWidth/2, 120)
	instance:setImage(background)
	instance:add()
	
	instance.filenameLabel = LabelCentre(filename, windowWidth/2, 120)
end

function playdate.keyboard.textChangedCallback()
	filename = playdate.keyboard.text
	print("save filename: " .. filename)
	instance.filenameLabel:setText(filename)
end

function playdate.keyboard.keyboardDidHideCallback()
	print("keyboardDidHideCallback()|: filename: " .. filename)
	
	instance.filenameLabel:remove()
	instance:remove()
	
	if filename == FILENAME_PREFIX then
		print("save cancelled")

	else
		--save
		
		instance.onSave(filename)
	end
end
