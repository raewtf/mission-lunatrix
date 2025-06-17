-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local text <const> = gfx.getLocalizedText

class('scoreboards').extends(gfx.sprite) -- Create the scene's class
function scoreboards:init(...)
	scoreboards.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here
	gfx.sprite.setAlwaysRedraw(true) -- Should this scene redraw the sprites constantly?
	pd.display.setScale(1)
	pd.datastore.write(save)
	show_crank = false

	function pd.gameWillPause() -- When the game's paused...
		local menu = pd.getSystemMenu()
		menu:removeAllMenuItems()
		pd.setMenuImage(nil)
		if not scenemanager.transitioning then
			if not vars.loading then
				menu:addMenuItem(text('refresh'), function()
					self:refreshboards(vars.mode)
				end)
			end
			menu:addMenuItem(text('back'), function()
				scenemanager:transitionscene(title)
				if save.sfx then assets.back:play() end
			end)
		end
	end

	assets = {
		cutout = gfx.font.new('fonts/cutout'),
		pedallica = gfx.font.new('fonts/pedallica'),
		back = smp.new('audio/sfx/back'),
		stars_s = gfx.image.new('images/stars_s'),
		stars_l = gfx.image.new('images/stars_l'),
		avatar = gfx.imagetable.new('images/avatar'),
	}

	vars = {
		stars_s = pd.timer.new(25000, 0, -400),
		stars_l = pd.timer.new(20000, 0, -400),
		mode = args[1] or "arcade",
		result = {},
		best = {},
		loading = false,
	}
	vars.scoreboardsHandlers = {
		AButtonDown = function()
			if vars.mode == "arcade" then
				self:refreshboards("daily")
			elseif vars.mode == "daily" then
				self:refreshboards("arcade")
			end
		end,

		BButtonDown = function()
			scenemanager:transitionscene(title)
			if save.sfx then assets.back:play() end
		end,
	}
	pd.timer.performAfterDelay(scenemanager.transitiontime, function()
		pd.inputHandlers.push(vars.scoreboardsHandlers)
	end)

	vars.stars_s.repeats = true
	vars.stars_l.repeats = true

	self:refreshboards(vars.mode)

	gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
		assets.stars_s:draw(vars.stars_s.value, 0)
		assets.stars_l:draw(vars.stars_l.value, 0)
		gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer2x2)
		gfx.fillRect(0, 0, 400, 240)
		gfx.setColor(gfx.kColorBlack)
		assets.cutout:drawTextAligned(text('scoreboards'), 200, 10, kTextAlignment.center)
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		if vars.mode == "arcade" then
			if save.score > 0 then
				assets.pedallica:drawText(text('yourscore') .. commalize(save.score), 10, 10)
			end
			assets.pedallica:drawText(text('pressAdaily'), 10, 215)
			assets.pedallica:drawTextAligned(text('arcademode'), 390, 215, kTextAlignment.right)
		elseif vars.mode == "daily" then
			if save.lastdaily.score > 0 then
				assets.pedallica:drawText(text('yourscore') .. commalize(save.lastdaily.score), 10, 10)
			end
			assets.pedallica:drawText(text('pressAarcade'), 10, 215)
			local gmttime = pd.getGMTTime()
			if gmttime.hour < 23 then
				assets.pedallica:drawTextAligned(text('dailyorbit') .. ' - ' .. text('timer') .. (24 - gmttime.hour) .. text('hours'), 390, 215, kTextAlignment.right)
			else
				if gmttime.minute < 59 then
					assets.pedallica:drawTextAligned(text('dailyorbit') .. ' - ' .. text('timer') .. (60 - gmttime.minute) .. text('minutes'), 390, 215, kTextAlignment.right)
				else
					assets.pedallica:drawTextAligned(text('dailyorbit') .. ' - ' .. text('timer') .. (60 - gmttime.second) .. text('seconds'), 390, 215, kTextAlignment.right)
				end
			end
		end
		if vars.best.rank ~= nil then
			if string.len(vars.best.player) == 16 and tonumber(vars.best.player) then
				assets.pedallica:drawTextAligned(text('updateusername'), 200, 220, kTextAlignment.center)
			end
			assets.pedallica:drawTextAligned(text('yourrank') .. ordinal(vars.best.rank), 390, 10, kTextAlignment.right)
		end
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
		if vars.result.scores ~= nil and next(vars.result.scores) ~= nil and not vars.loading then
			for i = 1, 10 do
				if i <= 5 then
					assets.avatar[11]:draw(30, 22 + (i * 30))
					assets.cutout:drawTextAligned(i, 32, 20 + (i * 30), kTextAlignment.right)
				else
					assets.avatar[11]:draw(346, -128 + (i * 30))
					assets.cutout:drawText(i, 368, -130 + (i * 30))
				end
			end
			for _, v in ipairs(vars.result.scores) do
				if v.rank <= 5 then
					assets.avatar[(math.floor(v.value % 10) == 0 and 11) or (math.floor(v.value % 10))]:draw(30, 22 + (v.rank * 30))
					assets.cutout:drawTextAligned(v.rank, 32, 20 + (v.rank * 30), kTextAlignment.right)
					gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
					assets.pedallica:drawText(v.player, 62, 20 + (v.rank * 30))
					assets.pedallica:drawText(commalize(v.value - math.floor(v.value % 10)), 62, 33 + (v.rank * 30))
					gfx.setImageDrawMode(gfx.kDrawModeCopy)
				else
					assets.avatar[(math.floor(v.value % 10) == 0 and 11) or (math.floor(v.value % 10))]:draw(346, -128 + (v.rank * 30))
					assets.cutout:drawText(v.rank, 368, -130 + (v.rank * 30))
					gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
					assets.pedallica:drawTextAligned(commalize(v.value - math.floor(v.value % 10)), 338, -128 + (v.rank * 30), kTextAlignment.right)
					assets.pedallica:drawTextAligned(v.player, 338, -118 + (v.rank * 30), kTextAlignment.right)
					gfx.setImageDrawMode(gfx.kDrawModeCopy)
				end
			end
		elseif vars.result == "fail" then
			gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			assets.pedallica:drawTextAligned(text('fail'), 200, 120, kTextAlignment.center)
			gfx.setImageDrawMode(gfx.kDrawModeCopy)
		elseif vars.loading then
			gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			assets.pedallica:drawTextAligned(text('loading'), 200, 120, kTextAlignment.center)
			gfx.setImageDrawMode(gfx.kDrawModeCopy)
		else
			gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			assets.pedallica:drawTextAligned(text('empty'), 200, 120, kTextAlignment.center)
			gfx.setImageDrawMode(gfx.kDrawModeCopy)
		end
	end)

	newmusic('audio/music/title', true, 1.591)
	self:add()
end

function scoreboards:refreshboards(mode)
	if not vars.loading then
		vars.result = {}
		vars.best = {}
		vars.loading = true
		vars.mode = mode
		if vars.mode == "arcade" and save.score ~= 0 then
			pd.scoreboards.addScore("arcade", 0)
		elseif vars.mode == "daily" and save.lastdaily.score ~= 0 and save.lastdaily.sent == false and (save.lastdaily.year == pd.getGMTTime().year and save.lastdaily.month == pd.getGMTTime().month and save.lastdaily.day == pd.getGMTTime().day) then
			pd.scoreboards.addScore("daily", 0)
		end
		pd.scoreboards.getScores(vars.mode, function(status, result)
			if status.code == "OK" then
				vars.result = result
				pd.scoreboards.getPersonalBest(vars.mode, function(status, result)
					vars.loading = false
					if status.code == "OK" then
						vars.best = result
					end
				end)
			else
				vars.loading = false
				vars.result = "fail"
			end
		end)
	end
end

function scoreboards:update()
	local gmt = pd.getGMTTime()
	if gmt.hour == 0 and gmt.minute == 0 and gmt.second == 0 and not vars.loading and vars.mode == "daily" then
		self:refreshboards(vars.mode)
	end
end