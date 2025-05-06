-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local text <const> = gfx.getLocalizedText
local floor <const> = math.floor

class('interstition').extends(gfx.sprite) -- Create the scene's class
function interstition:init(...)
	interstition.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here
	gfx.sprite.setAlwaysRedraw(true) -- Should this scene redraw the sprites constantly?
	pd.display.setScale(1)
	pd.datastore.write(save)
	show_crank = false

	assets = {
		video = gfx.imagetable.new('images/interstition'),
		land = smp.new('audio/sfx/land'),
	}

	vars = {
		score = args[1],
		planet = args[2],
		best_combo = args[3],
		timer = pd.timer.new(5950, 1, 65)
	}

	vars.timer.timerEndedCallback = function()
		if save.sfx then assets.land:play() end
		pd.timer.performAfterDelay(1500, function()
			scenemanager:switchscene(game, vars.score, vars.planet + 1, vars.best_combo)
		end)
	end
	vars.timer.delay = 500

	gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
		assets.video[floor(vars.timer.value) <= 61 and floor(vars.timer.value) or 61]:draw(0, 0)
	end)

	pd.timer.performAfterDelay(500, function()
		newmusic('audio/music/interstition')
	end)
	self:add()
end