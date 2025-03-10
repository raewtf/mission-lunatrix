import 'game'
import 'options'
import 'credits'

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
		select = smp.new('audio/sfx/select'),
		move = smp.new('audio/sfx/move'),
	}

	vars = {
		selection = 1,
		selections = {'newgame', 'options', 'credits'},
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
			if save.sfx then assets.select:play() end
			if vars.keytimer ~= nil then vars.keytimer:remove() end
			if vars.selections[vars.selection] == "newgame" then
				scenemanager:irisscene(game)
				fademusic(300)
				save.arcade_runs += 1
			elseif vars.selections[vars.selection] == "options" then
				scenemanager:transitionscene(options)
			elseif vars.selections[vars.selection] == "credits" then
				scenemanager:transitionscene(credits)
			end
		end,
	}
	pd.inputHandlers.push(vars.titleHandlers)

	for i = 1, #vars.selections do
		vars['selectiontarget' .. i] = 0
		vars['selectionx' .. i] = -1000
	end
	vars.selectiontarget1 = 20
	vars.metadatatarget = 0
	vars.metadatay = 100

	vars.stars_s.repeats = true
	vars.stars_l.repeats = true

	gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
		assets.stars_s:draw(vars.stars_s.value, 0)
		assets.stars_l:draw(vars.stars_l.value, 0)
		assets.logo:draw(26, 10)
		assets.highlight:draw(-10 + vars['selectionx' .. vars.selection], 45 + (30 * vars.selection))
		assets.cutout:drawText(text('startgame'), 23 + vars.selectionx1, 95)
		assets.cutout:drawText(text('options'), 23 + vars.selectionx2, 125)
		assets.cutout:drawText(text('credits'), 23 + vars.selectionx3, 155)
		assets.moon:draw(0, 196)
		assets.pedallica:drawText(text('copyright'), 23, 217 + vars.metadatay)
		assets.pedallica:drawTextAligned('v' .. pd.metadata.version, 377, 217 + vars.metadatay, kTextAlignment.right)
	end)

	newmusic('audio/music/title', true, 1.591)
	pd.getCrankTicks(4)
	self:add()
end

function title:update()
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