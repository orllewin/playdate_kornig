import 'Play/grain_player'
import 'Play/grain_control'
import 'CoracleViews/focus_manager'
import 'CoracleViews/pop_manager'
import 'CoracleViews/divider_horizontal'
import 'CoracleViews/mini_slider'

class('PlayDialog').extends(playdate.graphics.sprite)

local graphics <const> = playdate.graphics
local grainPlayer = GrainPlayer()
local focusManager = FocusManager()
local popManager = PopManager()

function PlayDialog:init()
	PlayDialog.super.init(self)
	self.showing = false
	
	local font = playdate.graphics.font.new("Fonts/font-rains-1x")
	playdate.graphics.setFont(font)
end

function PlayDialog:show(parentPath)
	print("Play diualog initialising graimPlayer")
	grainPlayer:initialise(parentPath)

	local background = graphics.image.new(400, 240, graphics.kColorWhite)
	self:moveTo(200, 120)
	self:setImage(background)
	self:add()
	
	self.topDiv = DividerHorizontal(6, 75, 388, 0.4)
	popManager:add(self.topDiv)
	
	self.control1 = GrainControl(1, function(index, value) 
		print("GrainControl: " .. index .. " percent: " .. value)
		grainPlayer:move(index, value)
	end)
	popManager:add(self.control1)
	focusManager:addView(self.control1:getRow1View(), 1)
	
	self.control2 = GrainControl(2, function(index, value) 
			print("GrainControl: " .. index .. " percent: " .. value)
		end)
	popManager:add(self.control2)
	focusManager:addView(self.control2:getRow1View(), 1)
	
	self.control3 = GrainControl(3, function(index, value) 
			print("GrainControl: " .. index .. " percent: " .. value)
		end)
	popManager:add(self.control3)
	focusManager:addView(self.control3:getRow1View(), 1)
	
	self.control4 = GrainControl(4, function(index, value) 
			print("GrainControl: " .. index .. " percent: " .. value)
		end)
	popManager:add(self.control4)
	focusManager:addView(self.control4:getRow1View(),1)
	
	self.control5 = GrainControl(5, function(index, value) 
			print("GrainControl: " .. index .. " percent: " .. value)
		end)
	popManager:add(self.control5)
	focusManager:addView(self.control5:getRow1View(), 1)
	
	focusManager:start()
	
	--Previous dialog hasn't popped yet, so wait:
	playdate.timer.performAfterDelay(1500, function() 
		focusManager:push()
	end)

	self.showing = true
end

function PlayDialog:isShowing()
	return self.showing
end

function PlayDialog:update()
	if self.showing == false then return end
	grainPlayer:update()
end

function PlayDialog:dismiss()
	popManager:popAll()
end
