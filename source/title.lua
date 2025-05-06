import 'game'
import 'options'
import 'credits'
import 'howtoplay'
import 'scoreboards'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local text <const> = gfx.getLocalizedText

class('title').extends(gfx.sprite) -- Create the scene's class
function title:init(...)
	title.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here
	gfx.sprite.setAlwaysRedraw(true) -- Should this scene redraw the sprites constantly?
	pd.display.setScale(1)
	pd.datastore.write(save)
	show_crank = false

	function pd.gameWillPause() -- When the game's paused...
		local menu = pd.getSystemMenu()
		menu:removeAllMenuItems()
		if not scenemanager.transitioning then
			menu:addMenuItem(text('howtoplay'), function()
				if save.sfx then assets.select:play() end
				scenemanager:transitionscene(howtoplay)
			end)
			menu:addMenuItem(text('credits'), function()
				if save.sfx then assets.select:play() end
				scenemanager:transitionscene(credits)
			end)
		end
	end

	assets = {
		logo = gfx.image.new('images/logo'),
		wheel1 = gfx.image.new('images/wheel1'),
		wheel2 = gfx.image.new('images/wheel2'),
		cutout = gfx.font.new('fonts/cutout'),
		pedallica = gfx.font.new('fonts/pedallica'),
		moon = gfx.image.new('images/moon'),
		stars_s = gfx.image.new('images/stars_s'),
		stars_l = gfx.image.new('images/stars_l'),
		highlight = gfx.image.new('images/highlight'),
		move = smp.new('audio/sfx/move'),
		select = smp.new('audio/sfx/select'),
		back = smp.new('audio/sfx/back'),
		flag = gfx.image.new('images/flag'),
	}

	vars = {
		do_anim = args[1] or false,
		selection = 1,
		selections = {'newgame', 'dailyorbit', 'scoreboards', 'options'},
		daily_orbitable = false,
		stars_s = pd.timer.new(25000, 0, -400),
		stars_l = pd.timer.new(20000, 0, -400),
	}
	vars.titleHandlers = {
		upButtonDown = function()
			if vars.selection ~= 0 then
				if vars.keytimer ~= nil then vars.keytimer:remove() end
				vars.keytimer = pd.timer.keyRepeatTimerWithDelay(150, 75, function()
					if vars.selection > 1 then
						vars.selection -= 1
					else
						vars.selection = #vars.selections
					end
					for i = 1, #vars.selections do
						vars['selectiontarget' .. i] = 0
					end
					vars['selectiontarget' .. vars.selection] = 20
					if save.sfx then assets.move:play() end
				end)
			end
		end,

		upButtonUp = function()
			if vars.keytimer ~= nil then vars.keytimer:remove() end
		end,

		downButtonDown = function()
			if vars.selection ~= 0 then
				if vars.keytimer ~= nil then vars.keytimer:remove() end
				vars.keytimer = pd.timer.keyRepeatTimerWithDelay(150, 75, function()
					if vars.selection < #vars.selections then
						vars.selection += 1
					else
						vars.selection = 1
					end
					for i = 1, #vars.selections do
						vars['selectiontarget' .. i] = 0
					end
					vars['selectiontarget' .. vars.selection] = 20
					if save.sfx then assets.move:play() end
				end)
			end
		end,

		downButtonUp = function()
			if vars.keytimer ~= nil then vars.keytimer:remove() end
		end,

		AButtonDown = function()
			if vars.keytimer ~= nil then vars.keytimer:remove() end
			if vars.selections[vars.selection] == "newgame" then
				title_memorize = 'newgame'
				if save.sfx then assets.select:play() end
				scenemanager:irisscene(game)
				fademusic(300)
				save.arcade_runs += 1
			elseif vars.selections[vars.selection] == 'dailyorbit' then
				if vars.daily_orbitable then
					title_memorize = 'dailyorbit'
					if save.sfx then assets.select:play() end
					scenemanager:irisscene(game, 0, 1, 0, true)
					fademusic(300)
					pd.timer.performAfterDelay(450, function()
						save.lastdaily = pd.getGMTTime()
						save.lastdaily.score = 0
						save.lastdaily.sent = false
					end)
				else
					shakies()
					if save.sfx then assets.back:play() end
				end
				save.daily_runs += 1
			elseif vars.selections[vars.selection] == "scoreboards" then
				title_memorize = 'scoreboards'
				if save.sfx then assets.select:play() end
				scenemanager:transitionscene(scoreboards)
			elseif vars.selections[vars.selection] == "options" then
				title_memorize = 'options'
				if save.sfx then assets.select:play() end
				scenemanager:transitionscene(options)
			end
		end,
	}
	pd.timer.performAfterDelay(scenemanager.transitiontime + 100, function()
		if not scenemanager.transitioning then
			pd.inputHandlers.push(vars.titleHandlers)
		end
	end)

	for i = 1, #vars.selections do
		vars['selectiontarget' .. i] = 0
		if vars.do_anim then
			vars['selectionx' .. i] = -1000
		else
			vars['selectionx' .. i] = 0
		end
		if vars.selections[i] == title_memorize then
			vars.selection = i
		end
	end
	vars['selectiontarget' .. vars.selection] = 20
	vars.metadatatarget = 0
	if vars.do_anim then
		vars.metadatay = 100
	else
		vars.metadatay = 0
		vars['selectionx' .. vars.selection] = 20
	end

	vars.stars_s.repeats = true
	vars.stars_l.repeats = true

	gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
		assets.stars_s:draw(vars.stars_s.value, 0)
		assets.stars_l:draw(vars.stars_l.value, 0)
		assets.highlight:draw(-10 + vars['selectionx' .. vars.selection], 25 + (30 * vars.selection))
		assets.cutout:drawText(text('arcademode'), 23 + vars.selectionx1, 75)
		assets.cutout:drawText(text('dailyorbit'), 23 + vars.selectionx2, 105)
		assets.cutout:drawText(text('scoreboards'), 23 + vars.selectionx3, 135)
		assets.cutout:drawText(text('options'), 23 + vars.selectionx4, 165)
		if vars.selections[vars.selection] == 'newgame' and save.score > 0 then
			local startsize = assets.cutout:getTextWidth(text('arcademode'))
			gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			assets.pedallica:drawText(text('crown') .. commalize(save.score) .. text('pts'), startsize + vars.selectionx1 + 33, 81)
			gfx.setImageDrawMode(gfx.kDrawModeCopy)
		end
		if vars.selections[vars.selection] == 'dailyorbit' then
			local dailysize = assets.cutout:getTextWidth(text('dailyorbit'))
			local gmttime = pd.getGMTTime()
			gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			if vars.daily_orbitable then
				if gmttime.hour < 23 then
					assets.pedallica:drawText(text('timer') .. (24 - gmttime.hour) .. text('hours'), dailysize + vars.selectionx2 + 33, 111)
				else
					if gmttime.minute < 59 then
						assets.pedallica:drawText(text('timer') .. (60 - gmttime.minute) .. text('minutes'), dailysize + vars.selectionx2 + 33, 111)
					else
						assets.pedallica:drawText(text('timer') .. (60 - gmttime.second) .. text('seconds'), dailysize + vars.selectionx2 + 33, 111)
					end
				end
			else
				if gmttime.hour < 23 then
					assets.pedallica:drawText(text('crown') .. commalize(save.lastdaily.score) .. text('pts') .. text('dash') .. text('timer') .. (24 - gmttime.hour) .. text('hours'), dailysize + vars.selectionx2 + 33, 111)
				else
					if gmttime.minute < 59 then
						assets.pedallica:drawText(text('crown') .. commalize(save.lastdaily.score) .. text('pts') .. text('dash') .. text('timer') .. (60 - gmttime.minute) .. text('minutes'), dailysize + vars.selectionx2 + 3, 111)
					else
						assets.pedallica:drawText(text('crown') .. commalize(save.lastdaily.score) .. text('pts') .. text('dash') .. text('timer') .. (60 - gmttime.second) .. text('seconds'), dailysize + vars.selectionx2 + 33, 111)
					end
				end
			end
			gfx.setImageDrawMode(gfx.kDrawModeCopy)
		end
		assets.logo:draw(26, 10)
		if save.flags > 0 then
			assets.flag:draw(285, 140 + vars.metadatay)
			if save.flags > 1 then
				assets.pedallica:drawTextAligned(commalize(save.flags), 311, 146 + vars.metadatay, kTextAlignment.center)
			end
		end
		assets.moon:draw(0, 196)
		assets.pedallica:drawText(text('copyright'), 23, 217 + vars.metadatay)
		assets.pedallica:drawTextAligned('v' .. pd.metadata.version, 377, 217 + vars.metadatay, kTextAlignment.right)
	end)

	newmusic('audio/music/title', true, 1.591)
	pd.getCrankTicks(4)
	self:add()
end

function title:update()
	if save.lastdaily.year == pd.getGMTTime().year and save.lastdaily.month == pd.getGMTTime().month and save.lastdaily.day == pd.getGMTTime().day then
		vars.daily_orbitable = false
	else
		vars.daily_orbitable = true
	end
	for i = 1, #vars.selections do
		vars['selectionx' .. i] += (vars['selectiontarget' .. i] - vars['selectionx' .. i]) * 0.5
	end
	vars.metadatay += (vars.metadatatarget - vars.metadatay) * 0.5
	local ticks = pd.getCrankTicks(4)
	if ticks ~= 0 and vars.selection > 0 then
		vars.selection += ticks
		if vars.selection < 1 then
			vars.selection = #vars.selections
		elseif vars.selection > #vars.selections then
			vars.selection = 1
		end
		for i = 1, #vars.selections do
			vars['selectiontarget' .. i] = 0
		end
		vars['selectiontarget' .. vars.selection] = 20
		if save.sfx then assets.move:play() end
	end
end