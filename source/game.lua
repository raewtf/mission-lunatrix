import 'gameover'
import 'interstition'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local text <const> = gfx.getLocalizedText
local rad <const> = math.rad
local sin <const> = math.sin
local cos <const> = math.cos
local deg <const> = math.deg
local abs <const> = math.abs
local random <const> = math.random
local floor <const> = math.floor
local ceil <const> = math.ceil
local min <const> = math.min
local max <const> = math.max

class('game').extends(gfx.sprite) -- Create the scene's class
function game:init(...)
	game.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here
	gfx.sprite.setAlwaysRedraw(false) -- Should this scene redraw the sprites constantly?
	pd.display.setScale(2)
	pd.datastore.write(save)

	assets = {
		surface = gfx.image.new('images/surface'),
		stars_small = gfx.image.new('images/stars_s'),
		stars_large = gfx.image.new('images/stars_l'),
		backplate = gfx.image.new('images/backplate'),
		dark_side = gfx.image.new('images/dark_side'),
		o2 = gfx.imagetable.new('images/o2'),
		crater = gfx.imagetable.new('images/crater/crater'),
		o22 = gfx.imagetable.new('images/o22/o2'),
		rover = gfx.imagetable.new('images/rover/rover'),
		roll = smp.new('audio/sfx/roll'),
		land = smp.new('audio/sfx/land'),
		take = smp.new('audio/sfx/take'),
		crash = smp.new('audio/sfx/crash'),
		slide = smp.new('audio/sfx/slide'),
		select = smp.new('audio/sfx/select'),
		beep = smp.new('audio/sfx/beep'),
		skater = gfx.imagetable.new('images/skater'),
		cutout = gfx.font.new('fonts/cutout'),
		pedallica = gfx.font.new('fonts/pedallica'),
		back = smp.new('audio/sfx/back'),
		powerup = smp.new('audio/sfx/powerup'),
		hit = smp.new('audio/sfx/hit'),
		bitmore = gfx.font.new('fonts/bitmore'),
	}

	vars = {
		total_score = args[1] or 0,
		planet = args[2] or 1,
		best_combo = args[3] or 0,
		score = 0,
		combo = 1,
		combo_timer = pd.timer.new(1, 0, 0),
		player_x = 0,
		player_y = 0,
		player_tile_x = 1,
		player_tile_y = 1,
		player_tile = 1,
		dead = false,
		player_rotation = rad(pd.getCrankPosition()),
		camera_rotation = rad(pd.getCrankPosition()),
		jumping = false,
		crashed = false,
		won = false,
		trick_button_queue = '',
		trick_crank = 0,
		trick_done = '',
		tricks_done = 0,
		eligible_to_win = false,
		jump = pd.timer.new(1, 0, 0),
		crank = pd.getCrankPosition(),
		crater = pd.timer.new(2000, 1, 30),
		flash = pd.timer.new(250, 2.99, 1),
		map = {
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
			{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
		},
		point = pd.geometry.point.new(0, 0),
	}

	vars.crater.repeats = true
	vars.jump.discardOnCompletion = false
	vars.flash.repeats = true
	vars.player_start_speed = 10
	vars.player_speed = 10
	vars.point_threshold = 25000 + (vars.planet * 1000)
	vars.o2_start = max(90000 - (vars.planet * 500), 20000)
	vars.o2 = pd.timer.new(vars.o2_start, vars.o2_start, 0)
	vars.combo_timer.discardOnCompletion = false
	vars.combo_timer.timerEndedCallback = function()
		if save.sfx and vars.combo ~= 1 then assets.back:play() end
		vars.combo = 1
	end
	vars.oldo2 = vars.o2_start
	vars.o2.timerEndedCallback = function() -- die function
		vars.dead = true
		if not vars.jumping then
			if save.sfx then assets.crash:play() end
			assets.roll:stop()
			fademusic(900)
			pd.timer.performAfterDelay(1000, function()
				scenemanager:irissceneout(gameover, vars.total_score, vars.planet, vars.best_combo)
			end)
		end
	end
	if save.sfx then assets.roll:play(0) end

	for i = 1, 625 do
		local rand = random(1, 300)
		if rand <= 3 then
			vars.map[i] = 1
		elseif rand == 4 then
			vars.map[i] = 2
		elseif rand == 5 then
			vars.map[i] = 3
		else
			vars.map[i] = 0
		end
	end

	class('player', _, classes).extends(gfx.sprite)
	function classes.player:init()
		classes.player.super.init(self)
		self:setZIndex(1)
		self:setCenter(0.5, 1)
		self:setImage(assets.skater[1])
		self:moveTo(100, 110)
		self:add()
	end
	function classes.player:update()
		local change = pd.getCrankChange()
		if vars.jumping then
			self:setImage(assets.skater[4])
		elseif vars.dead then
			self:setImage(assets.skater[5])
		else
			if change >= 2 then
				self:setImage(assets.skater[3])
			elseif change <= -2 then
				self:setImage(assets.skater[2])
			else
				self:setImage(assets.skater[1])
			end
		end
		if vars.crashed then
			if floor(vars.flash.value) >= 2 then
				self:setVisible(false)
			else
				self:setVisible(true)
			end
		end
		if vars.eligible_to_win then
			if floor(vars.flash.value) >= 2 then
				self:setImageDrawMode(gfx.kDrawModeInverted)
			else
				self:setImageDrawMode(gfx.kDrawModeCopy)
			end
		end
		vars.crank += pd.getCrankChange()
		if not vars.dead then
			if not vars.jumping then
				vars.player_rotation = rad(vars.crank)
			end
			vars.camera_rotation = rad(vars.crank)
			self:setRotation(change/2, 1 - (abs(change) / 250), 1 + (abs(change) / 250))
		end
		if (not vars.dead) or (vars.dead and vars.jumping) then
			vars.player_x += sin(vars.player_rotation) * vars.player_speed
			vars.player_y -= cos(vars.player_rotation) * vars.player_speed
		end
		vars.player_x %= 2500
		vars.player_y %= 2500
		vars.player_tile_x = ceil((vars.player_x  -25) / 100)
		vars.player_tile_y = ceil((vars.player_y  -25) / 100)
		vars.player_tile = vars.player_tile_x * vars.player_tile_y
		self:moveTo(100, 110 - vars.jump.value)
	end


	class('moon', _, classes).extends(gfx.sprite)
	function classes.moon:init()
		classes.moon.super.init(self)
		self:setSize(200, 120)
		self:setZIndex(0)
		self:setCenter(0.5, 1)
		self:moveTo(100, 120)
		self:add()
	end
	function classes.moon:update()
		self:markDirty()
	end
	function classes.moon:draw()
		local c = cos(vars.camera_rotation)
		local s = sin(vars.camera_rotation)
		local dxx = c / 2
		local dyx = s / 2
		local dxy = -s / 2
		local dyy = c / 2
		local dx = vars.player_x / 100
		local dy = vars.player_y / 100
		local p = 100 -- "perspective"
		local t = 53 + (vars.jump.value/4) -- "tilt"
		local z = 50 + (vars.jump.value/2)
		local h = 120 - z
		assets.backplate:draw(0, 0 + (vars.jump.value/2))
		assets.stars_small:draw(-deg(vars.camera_rotation)/1.1 % -400, -70)
		assets.stars_large:draw(-deg(vars.camera_rotation) % -400, -70)
		assets.surface:drawSampled(0, z, 200, h, 0.5, 0.92, dxx, dyx, dxy, dyy, dx, dy, p, t, true)
		game:drawitems(0, 0)
		if vars.player_tile_x <= 5 then
			game:drawitems(2500, 0)
		elseif vars.player_tile_x >= 20 then
			game:drawitems(-2500, 0)
		end
		if vars.player_tile_y <= 5 then
			game:drawitems(0, 2500)
		elseif vars.player_tile_y >= 20 then
			game:drawitems(0, -2500)
		end
		if vars.player_tile_x <= 5 and vars.player_tile_y <= 5 then
			game:drawitems(2500, 2500)
		elseif vars.player_tile_x <= 20 and vars.player_tile_y <= 5 then
			game:drawitems(-2500, 2500)
		elseif vars.player_tile_x <= 5 and vars.player_tile_y <= 20 then
			game:drawitems(2500, -2500)
		elseif vars.player_tile_x <= 20 and vars.player_tile_y <= 20 then
			game:drawitems(-2500, -2500)
		end
		game:adjust(gfx.getWorkingImage())
		assets.dark_side:draw(0, 0 + (vars.jump.value/2))
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		assets.pedallica:drawText(vars.score, 5, 5)
		if vars.trick_done ~= '' then
			assets.bitmore:drawText(text(vars.trick_done), 5, 35)
		end
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
		assets.cutout:drawText('x'  .. vars.combo, assets.pedallica:getTextWidth(vars.score) + 10, -1)
		gfx.setLineWidth(1)
		gfx.setColor(gfx.kColorWhite)
		gfx.drawRect(5, 27, 50, 5)
		gfx.fillRect(7, 29, 46 * vars.combo_timer.value, 1)
		gfx.setColor(gfx.kColorBlack)
		gfx.setLineWidth(2)
		assets.o2[floor(1 + ((33 - 1) / (0 - vars.o2_start)) * (vars.o2.value - vars.o2_start))]:draw(167, 0)
	end

	sprites.moon = classes.moon()
	sprites.player = classes.player()
	newmusic('audio/music/game', true)
	self:add()
end

function game:adjust(workingimage)
	for i = 0, 10 do
		local rand = random(8, 10)
		gfx.setClipRect((i^3/13) - rand, 0, 200 + (rand*2) - (i^3/13*2), 150)
		workingimage:draw(0, 40-(i*2))
	end
	gfx.clearClipRect()
end

function game:drawitems(offx, offy)
	local player_x = vars.player_x + offx
	local player_y = vars.player_y + offy
	local player_tile_x = vars.player_tile_x
	local player_tile_y = vars.player_tile_y
	local c = cos(-vars.camera_rotation)
	local s = sin(-vars.camera_rotation)
	local c2 = cos(-vars.camera_rotation + 0.785)
	local s2 = sin(-vars.camera_rotation + 0.785)
	local xstart = 0
	local xend = 0
	local xdir = 0
	local ystart = 0
	local yend = 0
	local ydir = 0
	if abs(c2) == c2 then
		xstart = player_tile_x + 5 + (offx / 100)
		xend = player_tile_x - 5 + (offx / 100)
		xdir = -1
	else
		xstart = player_tile_x - 5 + (offx / 100)
		xend = player_tile_x + 5 + (offx / 100)
		xdir = 1
	end
	if abs(s2) == s2 then
		ystart = player_tile_y + 5 + (offy / 100)
		yend = player_tile_y - 5 + (offy / 100)
		ydir = -1
	else
		ystart = player_tile_y - 5 + (offy / 100)
		yend = player_tile_y + 5 + (offy / 100)
		ydir = 1
	end
	for i = xstart, xend, xdir do
		for n = ystart, yend, ydir do
			i %= 25
			n %= 25
			if i == 0 then i = 25 end
			if n == 0 then n = 25 end
			if vars.map[i * n] == 1 then
				local offsetx = (i * 100) - player_x
				local offsety = (n * 100) - player_y
				local x = 100 + (c*offsetx - s*offsety) * 2
				local y = 110 + (s*offsetx + c*offsety) * 2
				local yadjust = min(max((y/60)+23, 1), 30)
				if yadjust > 1 then
					assets.crater[floor(yadjust)]:draw((x-100)/5, 0 + (vars.jump.value/2))
				end
				if vars.player_tile == i*n and not vars.jumping and not vars.dead then
					if vars.eligible_to_win then
						vars.jumping = true
						vars.won = true
						assets.roll:stop()
						vars.combo_timer:pause()
						if save.sfx then
							assets.slide:play()
							assets.take:play()
						end
						vars.jump:resetnew(1500, vars.jump.value, 200)
						fademusic(2000)
						pd.timer.performAfterDelay(2750, function()
							scenemanager:switchscene(interstition, vars.total_score, vars.planet, vars.best_combo)
						end)
					else
						vars.jumping = true
						vars.trick_button_queue = ''
						vars.trick_crank = 0
						vars.trick_done = ''
						vars.tricks_done = 0
						vars.combo_timer:pause()
						if save.sfx then assets.take:play() end
						assets.roll:stop()
						if not vars.crashed then
							vars.player_speed *= 0.75
						end
						vars.jump:resetnew(2000, vars.jump.value, 50, pd.easingFunctions.outCirc)
						pd.timer.performAfterDelay(2000, function()
							vars.jump:resetnew(1500, vars.jump.value, 0, pd.easingFunctions.inCirc)
							pd.timer.performAfterDelay(1500, function()
								if save.sfx then
									assets.land:play()
									assets.roll:play(0)
								end
								vars.jumping = false
								vars.trick_done = ''
								vars.tricks_done = 0
								if vars.dead then
									if save.sfx then assets.crash:play() end
									assets.roll:stop()
									fademusic(900)
									pd.timer.performAfterDelay(1000, function()
										scenemanager:irissceneout(gameover, vars.total_score, vars.planet, vars.best_combo)
									end)
								else
									vars.combo += 1
									vars.combo_timer:resetnew(5000, 1, 0)
									vars.player_rotation = vars.camera_rotation
									if not vars.crashed then
										vars.player_start_speed *= 1.1
										vars.player_speed = vars.player_start_speed
									end
								end
							end)
						end)
					end
				end
			elseif vars.map[i * n] == 2 then
				local offsetx = (i * 100) - player_x
				local offsety = (n * 100) - player_y
				local x = 100 + (c*offsetx - s*offsety) * 2
				local y = 110 + (s*offsetx + c*offsety) * 2
				local yadjust = min(max((y/60)+24, 1), 30)
				if yadjust > 1 then
					assets.o22[floor(yadjust)]:draw((x-100)/5, 0 + (vars.jump.value/2))
				end
				if vars.player_tile == i*n and not vars.jumping and not vars.dead then
					vars.map[i * n] = 0
					if save.sfx then assets.select:play() end
					vars.o2:resetnew(min(vars.o2.value * 1.2, vars.o2_start), min(vars.o2.value * 1.2, vars.o2_start), 0)
				end
			elseif vars.map[i * n] == 3 then
				local offsetx = (i * 100) - player_x
				local offsety = (n * 100) - player_y
				local x = 100 + (c*offsetx - s*offsety) * 2
				local y = 110 + (s*offsetx + c*offsety) * 2
				local yadjust = min(max((y/60)+23, 1), 30)
				if yadjust > 1 then
					assets.rover[floor(yadjust)]:draw((x-100)/5, 0 + (vars.jump.value/2))
				end
				if vars.player_tile == i*n and not vars.crashed and not vars.jumping and not vars.dead then
					if save.sfx then assets.crash:play() end
					vars.crashed = true
					vars.player_speed /= 2
					shakies()
					shakies_y()
					pd.timer.performAfterDelay(2000, function()
						vars.crashed = false
						vars.player_speed *= 2
						sprites.player:setVisible(true)
					end)
				end
			end
		end
	end
end

function game:update()
	if vars.jumping and not vars.won then
		if pd.buttonJustPressed('up') then
			vars.trick_button_queue = 'up'
		end
		if pd.buttonJustPressed('down') then
			vars.trick_button_queue = 'down'
		end
		if pd.buttonJustPressed('left') then
			vars.trick_button_queue = 'left'
		end
		if pd.buttonJustPressed('right') then
			vars.trick_button_queue = 'right'
		end
		vars.trick_crank += pd.getCrankChange()
		if abs(vars.trick_crank) > 360 then
			if pd.buttonIsPressed('up') then
				vars.trick_done = 'impossible'
				vars.score += 500 * vars.combo
			elseif pd.buttonIsPressed('down') then
				vars.trick_done = '360shoveit'
				vars.score += 600 * vars.combo
			elseif pd.buttonIsPressed('left') then
				vars.trick_done = 'doublekickflip'
				vars.score += 800 * vars.combo
			elseif pd.buttonIsPressed('right') then
				vars.trick_done = 'doubleheelflip'
				vars.score += 700 * vars.combo
			else
				if vars.trick_button_queue == 'up' then
					vars.trick_done = 'airwalk'
					vars.score += 1000 * vars.combo
				elseif vars.trick_button_queue == 'down' then
					vars.trick_done = '360varial'
					vars.score += 900 * vars.combo
				elseif vars.trick_button_queue == 'left' then
					vars.trick_done = '360pivot'
					vars.score += 1100 * vars.combo
				elseif vars.trick_button_queue == 'right' then
					vars.trick_done = '360fingerflip'
					vars.score += 1050 * vars.combo
				else
					vars.trick_done = '360'
					vars.score += 300 * vars.combo
				end
			end
			if save.sfx then assets.hit:play(1, 1 + (vars.tricks_done * 0.1)) end
			vars.tricks_done += 1
			vars.trick_crank = 0
			vars.trick_button_queue = ''
		end
	end
	if vars.oldo2 > 9000 and vars.o2.value <= 9000 then
		shakies(500, 2)
		shakies_y(750, 2)
		if save.sfx then
			assets.beep:setVolume(0.1)
			assets.beep:play()
		end
	end
	if vars.oldo2 > 8000 and vars.o2.value <= 8000 then
		shakies(500, 3)
		shakies_y(750, 3)
		if save.sfx then
			assets.beep:setVolume(0.2)
			assets.beep:play()
		end
	end
	if vars.oldo2 > 7000 and vars.o2.value <= 7000 then
		shakies(500, 4)
		shakies_y(750, 4)
		if save.sfx then
			assets.beep:setVolume(0.3)
			assets.beep:play()
		end
	end
	if vars.oldo2 > 6000 and vars.o2.value <= 6000 then
		shakies(500, 5)
		shakies_y(750, 5)
		if save.sfx then
			assets.beep:setVolume(0.4)
			assets.beep:play()
		end
	end
	if vars.oldo2 > 5000 and vars.o2.value <= 5000 then
		shakies(500, 6)
		shakies_y(750, 6)
		if save.sfx then
			assets.beep:setVolume(0.5)
			assets.beep:play()
		end
	end
	if vars.oldo2 > 4000 and vars.o2.value <= 4000 then
		shakies(500, 7)
		shakies_y(750, 7)
		if save.sfx then
			assets.beep:setVolume(0.6)
			assets.beep:play()
		end
	end
	if vars.oldo2 > 3000 and vars.o2.value <= 3000 then
		shakies(500, 8)
		shakies_y(750, 8)
		if save.sfx then
			assets.beep:setVolume(0.8)
			assets.beep:play()
		end
	end
	if vars.oldo2 > 2000 and vars.o2.value <= 2000 then
		shakies(500, 9)
		shakies_y(750, 9)
		if save.sfx then
			assets.beep:setVolume(0.9)
			assets.beep:play()
		end
	end
	if vars.oldo2 > 1000 and vars.o2.value <= 1000 then
		shakies(500, 10)
		shakies_y(750, 10)
		if save.sfx then
			assets.beep:setVolume(1)
			assets.beep:play()
		end
	end
	if vars.score > vars.point_threshold and not vars.eligible_to_win then
		vars.eligible_to_win = true
		if save.sfx then assets.powerup:play() end
	end
	vars.oldo2 = vars.o2.value
end