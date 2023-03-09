import 'Play/grain_player'
import 'Play/grain_control'
import 'Play/track_view'
import 'CoracleViews/focus_manager'
import 'CoracleViews/pop_manager'
import 'CoracleViews/divider_horizontal'
import 'CoracleViews/button_minimal'

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

function PlayDialog:show(parentPath, onShowSettings)
	print("Play diualog initialising graimPlayer")
	
	self.onShowSettings = onShowSettings
	
	local background = graphics.image.new(400, 240, graphics.kColorWhite)
	self:moveTo(200, 120)
	self:setImage(background)
	self:add()
	
	--self.topDiv = DividerHorizontal(6, 75, 388, 0.4)
	--popManager:add(self.topDiv)
	graphics.setImageDrawMode(graphics.kDrawModeFillBlack)
	graphics.setColor(graphics.kColorBlack)
	self.trackView1 = TrackView(22)
	self.trackView2 = TrackView(33)
	self.trackView3 = TrackView(44)
	self.trackView4 = TrackView(55)
	self.trackView5 = TrackView(66)
	
	self.trackViews = {self.trackView1, self.trackView2, self.trackView3, self.trackView4, self.trackView5}
	
	self.settingsButton = ButtonMinimal("Global", 370, 4,  60, 10, function()
		self.onShowSettings()
	end)
	focusManager:addView(self.settingsButton, 1)
	
	self.control1 = GrainControl(1, function(index, value) 
		-- onMove
		grainPlayer:move(index, value)
	end, function(index, drift) 
		-- onDrift
		grainPlayer:setDrift(index, drift)
	end, function(index, width) 
		-- onWidth
		grainPlayer:setWidth(index, width)
	end, function(index, jumpActive) 
		-- onJump
		grainPlayer:setJump(index, jumpActive)
	end, function(index, reverseActive) 
		-- onReverse
		grainPlayer:setReverse(index, reverseActive)
	end)
	popManager:add(self.control1)
	focusManager:addView(self.control1:getRow1View(), 2)
	focusManager:addView(self.control1:getRow2View(), 3)
	focusManager:addView(self.control1:getRow3View(), 4)
	focusManager:addView(self.control1:getRow4View(), 5)
	focusManager:addView(self.control1:getRow5View(), 6)
	focusManager:addView(self.control1:getRow6View(), 7)
	
	self.control2 = GrainControl(2, function(index, value) 
			print("GrainControl: " .. index .. " percent: " .. value)
			grainPlayer:move(index, value)
	end, function(index, drift) 
		-- onDrift
		print("GrainControl: " .. index .. " drift: " .. drift)
		grainPlayer:setDrift(index, drift)
	end, function(index, width) 
		-- onWidth
		grainPlayer:setWidth(index, width)
	end, function(index, jumpActive) 
		-- onJump
		grainPlayer:setJump(index, jumpActive)
	end, function(index, reverseActive) 
		-- onReverse
		grainPlayer:setReverse(index, reverseActive)
	end)
	popManager:add(self.control2)
	focusManager:addView(self.control2:getRow1View(), 2)
	focusManager:addView(self.control2:getRow2View(), 3)
	focusManager:addView(self.control2:getRow3View(), 4)
	focusManager:addView(self.control2:getRow4View(), 5)
	focusManager:addView(self.control2:getRow5View(), 6)
	focusManager:addView(self.control2:getRow6View(), 7)
	
	self.control3 = GrainControl(3, function(index, value) 
			print("GrainControl: " .. index .. " percent: " .. value)
			grainPlayer:move(index, value)
	end, function(index, drift) 
		-- onDrift
		print("GrainControl: " .. index .. " drift: " .. drift)
		grainPlayer:setDrift(index, drift)
	end, function(index, width) 
		-- onWidth
		grainPlayer:setWidth(index, width)
	end, function(index, jumpActive) 
		-- onJump
		grainPlayer:setJump(index, jumpActive)
	end, function(index, reverseActive) 
		-- onReverse
		grainPlayer:setReverse(index, reverseActive)
	end)
	popManager:add(self.control3)
	focusManager:addView(self.control3:getRow1View(), 2)
	focusManager:addView(self.control3:getRow2View(), 3)
	focusManager:addView(self.control3:getRow3View(), 4)
	focusManager:addView(self.control3:getRow4View(), 5)
	focusManager:addView(self.control3:getRow5View(), 6)
	focusManager:addView(self.control3:getRow6View(), 7)
	
	self.control4 = GrainControl(4, function(index, value) 
			print("GrainControl: " .. index .. " percent: " .. value)
			grainPlayer:move(index, value)
	end, function(index, drift) 
		-- onDrift
		print("GrainControl: " .. index .. " drift: " .. drift)
		grainPlayer:setDrift(index, drift)
	end, function(index, width) 
		-- onWidth
		grainPlayer:setWidth(index, width)
	end, function(index, jumpActive) 
		-- onJump
		grainPlayer:setJump(index, jumpActive)
	end, function(index, reverseActive) 
		-- onReverse
		grainPlayer:setReverse(index, reverseActive)
	end)
	popManager:add(self.control4)
	focusManager:addView(self.control4:getRow1View(), 2)
	focusManager:addView(self.control4:getRow2View(), 3)
	focusManager:addView(self.control4:getRow3View(), 4)
	focusManager:addView(self.control4:getRow4View(), 5)
	focusManager:addView(self.control4:getRow5View(), 6)
	focusManager:addView(self.control4:getRow6View(), 7)
	
	self.control5 = GrainControl(5, function(index, value) 
			print("GrainControl: " .. index .. " percent: " .. value)
			grainPlayer:move(index, value)
	end, function(index, drift) 
		-- onDrift
		print("GrainControl: " .. index .. " drift: " .. drift)
		grainPlayer:setDrift(index, drift)
	end, function(index, width) 
		-- onWidth
		grainPlayer:setWidth(index, width)
	end, function(index, jumpActive) 
		-- onJump
		grainPlayer:setJump(index, jumpActive)
	end, function(index, reverseActive) 
		-- onReverse
		grainPlayer:setReverse(index, reverseActive)
	end)
	popManager:add(self.control5)
	focusManager:addView(self.control5:getRow1View(), 2)
	focusManager:addView(self.control5:getRow2View(), 3)
	focusManager:addView(self.control5:getRow3View(), 4)
	focusManager:addView(self.control5:getRow4View(), 5)
	focusManager:addView(self.control5:getRow5View(), 6)
	focusManager:addView(self.control5:getRow6View(), 7)
	
	focusManager:start()
	
	--Previous dialog hasn't popped yet, so wait:
	playdate.timer.performAfterDelay(1000, function() 
		focusManager:push()
	end)
	
	grainPlayer:setListener(function(index, config)
		self.trackViews[index]:update(config)
	end)
	
	grainPlayer:initialise(parentPath, function(childConfigs) 
		print("Initialising trackViews")
		for c=1,#childConfigs do
			print("init trackView " .. c)
			local cfg = childConfigs[c]
		  self.trackViews[c]:update(cfg)
		end
	end)

	self.showing = true
end

function PlayDialog:changeTempo(tempo)
	grainPlayer:changeTempo(tempo)
end

function PlayDialog:changeRate(rate)
	grainPlayer:changeRate(rate)
end

function PlayDialog:stop()
	grainPlayer:stop()
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
