--[[
	
	One parent sample.
	Five child subsamples.
	Children have variable width controlled by ui.
	Children sit within main sample length, position controlled by ui.
	Children can move, drift, randomise, controlled by ui.
	
          1   2          3         4        5          
	----------------------------------------------------	
	|      [|][ | ]     [  |  ]     [|]   [   |   ]    |
	|      [|][ | ]     [  |  ]     [|]   [   |   ]    |
	|      [|][ | ]     [  |  ]     [|]   [   |   ]    |
	|      [|][ | ]     [  |  ]     [|]   [   |   ]    |
	|      [|][ | ]     [  |  ]     [|]   [   |   ]    |
	----------------------------------------------------
	
	Each sample exists in its own channel with independent fx/filters
	
--]]
	class('GrainPlayer').extends(playdate.graphics.sprite)
	 
	function GrainPlayer:init()
		GrainPlayer.super.init(self)
		
	end
	
	function GrainPlayer:setParent(samplePath)
		
	end