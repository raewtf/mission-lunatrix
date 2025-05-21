-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local text <const> = gfx.getLocalizedText

class('avatar').extends(gfx.sprite) -- Create the scene's class
function avatar:init(...)
	avatar.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here
	gfx.sprite.setAlwaysRedraw(true) -- Should this scene redraw the sprites constantly?
	pd.display.setScale(1)
	show_crank = true

	function pd.gameWillPause() -- When the game's paused...
		local menu = pd.getSystemMenu()
		menu:removeAllMenuItems()
	end

	assets = {
		cutout = gfx.font.new('fonts/cutout'),
		pedallica = gfx.font.new('fonts/pedallica'),
		stars_s = gfx.image.new('images/stars_s'),
		stars_l = gfx.image.new('images/stars_l'),
		select = smp.new('audio/sfx/select'),
		back = smp.new('audio/sfx/back'),
		move = smp.new('audio/sfx/move'),
		avatar = gfx.imagetable.new('images/avatar'),
	}

	vars = {
		stars_s = pd.timer.new(25000, 0, -400),
		stars_l = pd.timer.new(20000, 0, -400),
		selections = {1, 2, 3, 4, 5, 6, 7, 8},
		crank = pd.getCrankPosition(),
		crank_lerp = pd.getCrankPosition(),
		origin = pd.getCrankPosition(),
	}
	vars.gameoverHandlers = {
		BButtonDown = function()
			if save.avatar ~= 11 then
				if save.sfx then assets.back:play() end
				scenemanager:transitionscene(title)
			end
		end,

		AButtonDown = function()
			if vars.selection == 0 then
				if save.sfx then assets.back:play() end
				shakies()
			else
				if save.sfx then assets.select:play() end
				math.ceil(((vars.crank_lerp + 20) % 360) / 36)
				save.avatar = vars.selection
				scenemanager:transitionscene(title)
			end
		end
	}
	pd.timer.performAfterDelay(scenemanager.transitiontime, function()
		pd.inputHandlers.push(vars.gameoverHandlers)
	end)

	vars.stars_s.repeats = true
	vars.stars_l.repeats = true

	vars.selection = vars.selections[math.ceil(((vars.crank_lerp + 20) % 360) / 36)]

	if achievements.isGranted('flag') then
		table.insert(vars.selections, 9)
	else
		table.insert(vars.selections, 0)
	end

	if achievements.isGranted('ufo') then
		table.insert(vars.selections, 10)
	else
		table.insert(vars.selections, 0)
	end

	gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
		assets.stars_s:draw(vars.stars_s.value, 0)
		assets.stars_l:draw(vars.stars_l.value, 0)
		gfx.setDitherPattern(0.25, gfx.image.kDitherTypeBayer2x2)
		gfx.fillRect(0, 0, 400, 240)
		gfx.setColor(gfx.kColorBlack)
		assets.cutout:drawTextAligned(text('chooseanicon'), 200, 10, kTextAlignment.center)
		for i = 1, 10 do
			local n = i
			if (i == 9 and vars.selections[9] == 0) or (i == 10 and vars.selections[10] == 0) then
				n = 11
			end
			if vars.selection == i then
				assets.avatar[n]:drawScaled(163 + (math.sin(math.rad(vars.crank_lerp) + (3.14 * 0.2) - (3.14 * i / 5)) * 150), 250 - 12 - (math.cos(math.rad(vars.crank_lerp) + (3.14 * 0.2) - (3.14 * i / 5)) * 150), 3)
			else
				assets.avatar[n]:drawScaled(175 + (math.sin(math.rad(vars.crank_lerp) + (3.14 * 0.2) - (3.14 * i / 5)) * 150), 250 - (math.cos(math.rad(vars.crank_lerp) + (3.14 * 0.2) - (3.14 * i / 5)) * 150), 2)
			end
		end
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		assets.pedallica:drawTextAligned(text('changeicon'), 200, 40, kTextAlignment.center)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end)

	self:add()
end

function avatar:update()
	if not scenemanager.transitioning then vars.crank += pd.getCrankChange() end
	if (vars.origin >= vars.crank + 30 or vars.origin <= vars.crank - 30) and show_crank then
		show_crank = false
	end
	vars.crank_lerp += (vars.crank - vars.crank_lerp) * 0.6
	if vars.selection ~= vars.last_selection and save.sfx and vars.selection ~= 0 then
		assets.move:play()
	end
	vars.last_selection = vars.selection
	vars.selection = vars.selections[math.ceil(((vars.crank_lerp + 20) % 360) / 36)]
end