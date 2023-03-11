import 'CoracleViews/text_list'
import 'Coracle/string_utils'

class('FileChooserDialog').extends(playdate.graphics.sprite)

local graphics <const> = playdate.graphics
local grainPlayer = GrainPlayer()
local focusManager = FocusManager()
local popManager = PopManager()

function FileChooserDialog:init()
	FileChooserDialog.super.init(self)
	self.showing = false
	
	local font = playdate.graphics.font.new("Fonts/font-rains-1x")
	playdate.graphics.setFont(font)
end

function FileChooserDialog:show(onCancel, onFile)	
	self.onCancel = onCancel
	self.onFile = onFile
	
	self.audioFiles = {}
	local files = playdate.file.listFiles()
	for f=1, #files do
		local file = files[f]	
		if endswith(file, ".pda") then
			--self.audioFiles[f] = file
			table.insert(self.audioFiles, file)
		end
	end
	
	local background = graphics.image.new(400, 240, graphics.kColorWhite)
	self:moveTo(200, 120)
	self:setImage(background)
	self:add()
	
	self.list = TextList(self.audioFiles, 5, 5, 290, 230, function(path)  
		print("Selected file: " .. path)
	end)
	self.list:setFocus(true)
	
	playdate.inputHandlers.push(self:getInputHandler())
	
end

function FileChooserDialog:dismiss()
	--todo pop views
	playdate.inputHandlers.pop()
end

-- See https://sdk.play.date/1.12.3/Inside%20Playdate.html#M-inputHandlers
function FileChooserDialog:getInputHandler()
	return {
		cranked = function(change, acceleratedChange)

		end,
		BButtonDown = function()

		end,
		BButtonUp = function()

		end,
		AButtonDown = function()

		end,
		AButtonUp = function()

		end,
		leftButtonDown = function()
	
		end,
		rightButtonDown = function()

		end,
		upButtonDown = function()
			if self.list:isFocused() then
				self.list:goUp()
			end
		end,
		downButtonDown = function()
			if self.list:isFocused() then
				print("list go down")
				self.list:goDown()
			end
		end
	}
end