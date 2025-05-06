-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local text <const> = gfx.getLocalizedText

class('howtoplay').extends(gfx.sprite) -- Create the scene's class
function howtoplay:init(...)
	howtoplay.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here
	gfx.sprite.setAlwaysRedraw(true) -- Should this scene redraw the sprites constantly?
	pd.display.setScale(1)
	pd.datastore.write(save)
	show_crank = false

	function pd.gameWillPause() -- When the game's paused...
		local menu = pd.getSystemMenu()
		menu:removeAllMenuItems()
		if not scenemanager.transitioning then
			menu:addMenuItem(text('back'), function()
				scenemanager:transitionscene(title)
				if save.sfx then assets.back:play() end
			end)
		end
	end

	assets = {
		cutout = gfx.font.new('fonts/cutout'),
		pedallica = gfx.font.new('fonts/pedallica'),
		bitmore = gfx.font.new('fonts/bitmore'),
		stars_s = gfx.image.new('images/stars_s'),
		stars_l = gfx.image.new('images/stars_l'),
		select = smp.new('audio/sfx/select'),
		move = smp.new('audio/sfx/move'),
		back = smp.new('audio/sfx/back'),
	}

	vars = {
		stars_s = pd.timer.new(25000, 0, -400),
		stars_l = pd.timer.new(20000, 0, -400),
		selection = 1,
		selections = 6,
	}
	vars.howtoplayHandlers = {
		leftButtonDown = function()
			if vars.selection ~= 0 then
				if vars.keytimer ~= nil then vars.keytimer:remove() end
				vars.keytimer = pd.timer.keyRepeatTimerWithDelay(500, 200, function()
					if vars.selection > 1 then
						vars.selection -= 1
					else
						vars.selection = vars.selections
					end
					if save.sfx then assets.move:play() end
				end)
			end
		end,

		leftButtonUp = function()
			if vars.keytimer ~= nil then vars.keytimer:remove() end
		end,

		rightButtonDown = function()
			if vars.selection ~= 0 then
				if vars.keytimer ~= nil then vars.keytimer:remove() end
				vars.keytimer = pd.timer.keyRepeatTimerWithDelay(500, 200, function()
					if vars.selection < vars.selections then
						vars.selection += 1
					else
						vars.selection = 1
					end
					if save.sfx then assets.move:play() end
				end)
			end
		end,

		rightButtonUp = function()
			if vars.keytimer ~= nil then vars.keytimer:remove() end
		end,

		BButtonDown = function()
			scenemanager:transitionscene(title)
		end,
	}
	pd.timer.performAfterDelay(scenemanager.transitiontime, function()
		pd.inputHandlers.push(vars.howtoplayHandlers)
	end)

	vars.stars_s.repeats = true
	vars.stars_l.repeats = true

	gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
		assets.stars_s:draw(vars.stars_s.value, 0)
		assets.stars_l:draw(vars.stars_l.value, 0)
		assets.cutout:drawText('how to play', 10, 10)
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		assets.pedallica:drawText('<' .. vars.selection .. '/' .. vars.selections .. '>', 10, 215)
		assets.pedallica:drawTextAligned(text('howtoplays' .. vars.selection), 390, 215, kTextAlignment.right)
		assets.pedallica:drawText(text('howtoplay' .. vars.selection), 10, 40)
		if vars.selection == 5 then
			assets.pedallica:drawTextAligned(text('howtoplay' .. vars.selection .. 'r'), 390, 40, kTextAlignment.right)
		end
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end)

	newmusic('audio/music/gameover', false)
	self:add()
end