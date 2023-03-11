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
	
	local w = 190
	local h = 172
	local background = graphics.image.new(w, h, graphics.kColorWhite)
	playdate.graphics.pushContext(background)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.drawRoundRect(0, 0, w, h, 3)
	playdate.graphics.popContext()
	self:moveTo(400-(w/2), h/2)
	self:setImage(background)
	self:add()
	
	self.list = TextList(self.audioFiles, 400-w + 6, 6, w - 12, h - 12, function(path)  
		print("Selected file: " .. path)
	end)
	self.list:setFocus(true)
	
	playdate.inputHandlers.push(self:getInputHandler())
	
end

function FileChooserDialog:dismiss()
	playdate.inputHandlers.pop()
	self.list:removeAll()
	self:remove()
end

-- See https://sdk.play.date/1.12.3/Inside%20Playdate.html#M-inputHandlers
function FileChooserDialog:getInputHandler()
	return {
		cranked = function(change, acceleratedChange)

		end,
		BButtonDown = function()
			self:dismiss()
		end,
		BButtonUp = function()

		end,
		AButtonDown = function()
			local selectedItem = self.list:getSelected()
			if self.onFile ~= nil then self.onFile(selectedItem) end
			self:dismiss()
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