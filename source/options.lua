-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local text <const> = gfx.getLocalizedText

class('options').extends(gfx.sprite) -- Create the scene's class
function options:init(...)
	options.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here
	gfx.sprite.setAlwaysRedraw(true) -- Should this scene redraw the sprites constantly?
	pd.display.setScale(1)
	pd.datastore.write(save)

	assets = {
		cutout = gfx.font.new('fonts/cutout'),
		pedallica = gfx.font.new('fonts/pedallica'),
		highlight = gfx.image.new('images/highlight'),
		options = gfx.image.new('images/options'),
		select = smp.new('audio/sfx/select'),
		move = smp.new('audio/sfx/move'),
		back = smp.new('audio/sfx/back'),
	}

	vars = {
		selection = 1,
		selections = {'music', 'sfx'},
	}
	vars.optionsHandlers = {
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

		BButtonDown = function()
			scenemanager:transitionscene(title)
			if save.sfx then assets.back:play() end
		end,

		AButtonDown = function()
			if vars.keytimer ~= nil then vars.keytimer:remove() end
			if vars.selections[vars.selection] == "music" then
				save.music = not save.music
				if save.music then
					newmusic('audio/music/title', true, 1.591)
				else
					stopmusic()
				end
			elseif vars.selections[vars.selection] == "sfx" then
				save.sfx = not save.sfx
			end
			if save.sfx then assets.select:play() end
		end,
	}
	pd.inputHandlers.push(vars.optionsHandlers)

	for i = 1, #vars.selections do
		vars['selectiontarget' .. i] = 0
		vars['selectionx' .. i] = 0
	end
	vars.selectiontarget1 = 20

	gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
		assets.options:draw(0, 0)
		assets.cutout:drawTextAligned(text('options'), 200, 10, kTextAlignment.center)
		assets.highlight:draw(-10 + vars['selectionx' .. vars.selection], 15 + (30 * vars.selection))
		if save.music then
			assets.cutout:drawText(text('musicon'), 23 + vars.selectionx1, 65)
		else
			assets.cutout:drawText(text('musicoff'), 23 + vars.selectionx1, 65)
		end
		if save.sfx then
			assets.cutout:drawText(text('sfxon'), 23 + vars.selectionx2, 95)
		else
			assets.cutout:drawText(text('sfxoff'), 23 + vars.selectionx2, 95)
		end
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		assets.pedallica:drawText(text('bestscore') .. save.score .. text('pts'), 23, 185)
		assets.pedallica:drawText(text('lifetimescore') .. save.lifetime_score .. text('pts'), 23, 205)
		assets.pedallica:drawTextAligned(text('mostmoons') .. save.highest_planet, 377, 185, kTextAlignment.right)
		assets.pedallica:drawTextAligned(text('totalruns') .. save.arcade_runs, 377, 205, kTextAlignment.right)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end)

	pd.getCrankTicks(4)
	self:add()
end

function options:update()
	for i = 1, #vars.selections do
		vars['selectionx' .. i] += (vars['selectiontarget' .. i] - vars['selectionx' .. i]) * 0.5
	end
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