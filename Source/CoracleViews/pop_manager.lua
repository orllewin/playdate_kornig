--[[
	
	Add sprites here, then pop them when the screen closes.
	
--]]

class('PopManager').extends()

function PopManager:init()
	PopManager.super.init(self)
	self.sprites = {}
end

function PopManager:addAll(_sprites)
	for i=1,#_sprites do
		self:add(_sprites[i])
	end
end

function PopManager:add(sprite)
	table.insert(self.sprites, sprite)
end

function PopManager:popAll()
	for i=1,#self.sprites do
		self.sprites[i]:remove()
	end
end
