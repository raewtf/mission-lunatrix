-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local text <const> = gfx.getLocalizedText

class('dailyorbit').extends(gfx.sprite) -- Create the scene's class
function dailyorbit:init(...)
	dailyorbit.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here
	gfx.sprite.setAlwaysRedraw(true) -- Should this scene redraw the sprites constantly?
	pd.display.setScale(1)
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
		gameover = gfx.image.new('images/gameover'),
		win = gfx.image.new('images/win'),
		stars_s = gfx.image.new('images/stars_s'),
		stars_l = gfx.image.new('images/stars_l'),
		select = smp.new('audio/sfx/select'),
		back = smp.new('audio/sfx/back'),
	}

	vars = {
		score = args[1] or 0,
		best_combo = args[2] or 0,
		stars_s = pd.timer.new(25000, 0, -400),
		stars_l = pd.timer.new(20000, 0, -400),
		float = pd.timer.new(5000, 0, 10, pd.easingFunctions.inOutSine),
	}
	vars.dailyorbitHandlers = {
		AButtonDown = function()
			fademusic(300)
			scenemanager:transitionscene(scoreboards, 'daily')
			if save.sfx then assets.select:play() end
		end,

		BButtonDown = function()
			fademusic(300)
			scenemanager:transitionscene(title)
			if save.sfx then assets.back:play() end
		end,
	}
	pd.timer.performAfterDelay(scenemanager.transitiontime, function()
		pd.inputHandlers.push(vars.dailyorbitHandlers)
	end)

	vars.float.reverses = true
	vars.float.repeats = true
	vars.stars_s.repeats = true
	vars.stars_l.repeats = true

	save.lifetime_score += vars.score
	if vars.best_combo > save.best_combo then save.best_combo = vars.best_combo end
	save.lastdaily.score = vars.score

	if save.lastdaily.year == pd.getGMTTime().year and save.lastdaily.month == pd.getGMTTime().month and save.lastdaily.day == pd.getGMTTime().day then
		save.lastdaily.score = vars.score
		if catalog then
			pd.scoreboards.addScore('daily', (save.avatar < 11 and vars.score + save.avatar) or (vars.score), function(status, result)
				if status.code == "OK" then
					save.lastdaily.sent = true
				else
					save.lastdaily.sent = false
				end
				if pd.isSimulator == 1 then
					printTable(status)
					printTable(result)
				end
			end)
		end
	end


	pd.datastore.write(save)

	gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
		assets.stars_s:draw(vars.stars_s.value, 0)
		assets.stars_l:draw(vars.stars_l.value, 0)
		gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer2x2)
		gfx.fillRect(0, 0, 400, 240)
		gfx.setColor(gfx.kColorBlack)
		assets.cutout:drawTextAligned(text('dailyorbit'), 125, 10, kTextAlignment.center)
		assets.win:draw(245, 25 + vars.float.value)
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		assets.pedallica:drawTextAligned(text('todaysscore') .. commalize(vars.score) .. text('pts'), 125, 70, kTextAlignment.center)
		assets.pedallica:drawTextAligned(text('bestcombo') .. commalize(vars.best_combo), 125, 90, kTextAlignment.center)
		assets.pedallica:drawTextAligned(text('pressAboards'), 125, 150, kTextAlignment.center)
		assets.pedallica:drawTextAligned(text('pressB'), 125, 170, kTextAlignment.center)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end)

	newmusic('audio/music/gameover', false)
	self:add()
end