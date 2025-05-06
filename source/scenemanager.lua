local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local floor <const> = math.floor

class('scenemanager').extends()

function scenemanager:init()
    self.transitiontime = 500
    self.transitioning = false
	self.transimage = gfx.imagetable.new('images/transition')
	self.iris = gfx.imagetable.new('images/iris')
	self.spray = smp.new('audio/sfx/spray')
end

function scenemanager:switchscene(scene, ...)
    self.newscene = scene
    self.sceneargs = {...}
    -- Pop any rogue input handlers, leaving the default one.
    local inputsize = #playdate.inputHandlers - 1
    for i = 1, inputsize do
        pd.inputHandlers.pop()
    end
    self:loadnewscene()
    self.transitioning = false
end

-- This function will transition the scene with an animated effect.
function scenemanager:transitionscene(scene, ...)
	if self.transitioning then return end -- If there's already a scene transition, go away.
	self.transitioning = true -- Set this to true
	self.newscene = scene
	if save.sfx then self.spray:play() end
	self.sceneargs = {...}
	-- Pop any rogue input handlers, leaving the default one.
	local inputsize = #playdate.inputHandlers - 1
	for i = 1, inputsize do
		pd.inputHandlers.pop()
	end
	-- IMPORTANT! These two numbers in the timer determine which frames of
	-- your image table will play during the FIRST HALF of transition period. It
	-- should be able to go backwards, but they MUST be whole numbers and it
	-- MUST be within the range of your image table's image count.
	local transitiontimer = self:transition(1, 12)
	-- After the first timer ends...
	transitiontimer.timerEndedCallback = function()
		-- Load the scene, and create a second timer for the other half.
		self:loadnewscene()
		-- These two numbers work the same way as the previous, but will
		-- determine which frames of your image table will play during
		-- the SECOND HALF of the transition period.
		transitiontimer = self:transition(13, 19)
		transitiontimer.timerEndedCallback = function()
			self.sprite_added = false
			self.sprite:remove()
			-- After this timer's over, remove the transition and the sprites.
			self.transitioning = false
		end
	end
end

function scenemanager:transition(table_start, table_end)
	self.sprite = self:newsprite()
	local newtimer = pd.timer.new(self.transitiontime, table_start, table_end)
	newtimer.updateCallback = function(timer) self.sprite:setImage(self.transimage[floor(timer.value)]) end
	self.sprite_added = true
	return newtimer
end

function scenemanager:newsprite()
	local loading = gfx.sprite.new()
	-- If there's already a sprite from the first half, set the start image to the last image of the table.
	-- This prevents any unwanted jitter when passing the baton from the first half to the second.
	if self.sprite_added then
		loading:setImage(self.sprite:getImage())
	else
		loading:setImage(self.transimage[1])
	end
	loading:setZIndex(26000) -- Putting it above every other sprite,
	loading:moveTo(0, 0)
	loading:setCenter(0, 0)
	loading:setIgnoresDrawOffset(true) -- Making sure it draws regardless of display offset.
	loading:add()
	return loading
end

-- This function will transition the scene with an animated effect.
function scenemanager:irisscene(scene, ...)
	if self.transitioning then return end -- If there's already a scene transition, go away.
	self.transitioning = true -- Set this to true
	self.newscene = scene
	self.sceneargs = {...}
	-- Pop any rogue input handlers, leaving the default one.
	local inputsize = #playdate.inputHandlers - 1
	for i = 1, inputsize do
		pd.inputHandlers.pop()
	end
	-- IMPORTANT! These two numbers in the timer determine which frames of
	-- your image table will play during the FIRST HALF of transition period. It
	-- should be able to go backwards, but they MUST be whole numbers and it
	-- MUST be within the range of your image table's image count.
	local transitiontimer = self:iristransition(1, 10)
	-- After the first timer ends...
	transitiontimer.timerEndedCallback = function()
		-- Load the scene, and create a second timer for the other half.
		self:loadnewscene()
		-- These two numbers work the same way as the previous, but will
		-- determine which frames of your image table will play during
		-- the SECOND HALF of the transition period.
		transitiontimer = self:iristransition(11, 20)
		transitiontimer.timerEndedCallback = function()
			self.sprite_added = false
			self.sprite:remove()
			-- After this timer's over, remove the transition and the sprites.
			self.transitioning = false
		end
	end
end

-- This function will transition the scene with an animated effect.
function scenemanager:irissceneout(scene, ...)
	if self.transitioning then return end -- If there's already a scene transition, go away.
	self.transitioning = true -- Set this to true
	self.newscene = scene
	self.sceneargs = {...}
	-- Pop any rogue input handlers, leaving the default one.
	local inputsize = #playdate.inputHandlers - 1
	for i = 1, inputsize do
		pd.inputHandlers.pop()
	end
	-- IMPORTANT! These two numbers in the timer determine which frames of
	-- your image table will play during the FIRST HALF of transition period. It
	-- should be able to go backwards, but they MUST be whole numbers and it
	-- MUST be within the range of your image table's image count.
	local transitiontimer = self:iristransition(20, 11)
	-- After the first timer ends...
	transitiontimer.timerEndedCallback = function()
		-- Load the scene, and create a second timer for the other half.
		self:loadnewscene()
		-- These two numbers work the same way as the previous, but will
		-- determine which frames of your image table will play during
		-- the SECOND HALF of the transition period.
		transitiontimer = self:iristransition(10, 1)
		transitiontimer.timerEndedCallback = function()
			self.sprite_added = false
			self.sprite:remove()
			-- After this timer's over, remove the transition and the sprites.
			self.transitioning = false
		end
	end
end

function scenemanager:iristransition(table_start, table_end)
	self.sprite = self:newirissprite()
	local newtimer = pd.timer.new(self.transitiontime, table_start, table_end)
	newtimer.updateCallback = function(timer) self.sprite:setImage(self.iris[floor(timer.value)]) end
	self.sprite_added = true
	return newtimer
end

function scenemanager:newirissprite()
	local loading = gfx.sprite.new()
	-- If there's already a sprite from the first half, set the start image to the last image of the table.
	-- This prevents any unwanted jitter when passing the baton from the first half to the second.
	if self.sprite_added then
		loading:setImage(self.sprite:getImage())
	else
		loading:setImage(self.iris[1])
	end
	loading:setZIndex(26000) -- Putting it above every other sprite,
	loading:moveTo(0, 0)
	loading:setCenter(0, 0)
	loading:setIgnoresDrawOffset(true) -- Making sure it draws regardless of display offset.
	loading:add()
	return loading
end

function scenemanager:loadnewscene()
    self:cleanupscene()
    self.newscene(table.unpack(self.sceneargs))
end

function scenemanager:cleanupscene()
	if classes ~= nil then
		for i = #classes, 1, -1 do
			classes[i] = nil
		end
		classes = nil
	end
	classes = {}
    gfx.sprite:removeAll()
    if sprites ~= nil then
        for i = 1, #sprites do
            sprites[i] = nil
        end
    end
    sprites = {}
    if assets ~= nil then
        for i = 1, #assets do
            assets[i] = nil
        end
        assets = nil -- Nil all the assets,
    end
    if vars ~= nil then
        for i = 1, #vars do
            vars[i] = nil
        end
    end
    vars = nil -- and nil all the variables.
    self:removealltimers() -- Remove every timer,
    collectgarbage('collect') -- and collect the garbage.
    gfx.setDrawOffset(0, 0) -- Lastly, reset the drawing offset. just in case.
end

function scenemanager:removealltimers()
    local alltimers = pd.timer.allTimers()
    for _, timer in ipairs(alltimers) do
        timer:remove()
        timer = nil
    end
end