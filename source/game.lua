import 'gameover'
import 'interstition'
import 'dailyorbit'

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
local format <const> = string.format
local find <const> = string.find

class('game').extends(gfx.sprite) -- Create the scene's class
function game:init(...)
	game.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here
	gfx.sprite.setAlwaysRedraw(true) -- Should this scene redraw the sprites constantly?
	pd.display.setScale(2)
	pd.datastore.write(save)
	show_crank = true

	function pd.gameWillPause() -- When the game's paused...
		local pause_img = gfx.image.new(200, 120, gfx.kColorBlack)
		gfx.pushContext(pause_img)
		if vars.combo > 1 then
			assets.cutout:drawText('©'  .. commalize(vars.combo), max(assets.pedallica:getTextWidth(commalize(vars.score)) - 11, 2), 4)
		end
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		assets.pedallica:drawText(commalize(vars.score), 5, 5)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
		if vars.combo_timer.value > 0 then
			gfx.setLineWidth(1)
			gfx.setColor(gfx.kColorWhite)
			gfx.drawRect(5, 30, 50, 5)
			gfx.fillRect(7, 32, 46 * vars.combo_timer.value, 1)
			gfx.setColor(gfx.kColorBlack)
			gfx.setLineWidth(2)
		end
		if vars.daily then
			assets.bitmore:drawText(text('hash') .. vars.gmttime.year .. '-' .. format("%02d", vars.gmttime.month) .. '-' .. format("%02d", vars.gmttime.day) .. '\n' .. text('moony_start_' .. ((vars.seed % 50) + 1)) .. '\n' .. text('moony_end_' .. ceil((vars.seed % 125) / 2.5)), 4, 60)
		else
			assets.bitmore:drawText(text('hash') .. vars.planet .. ' - ' .. text('moony_start_' .. ((vars.seed % 50) + 1)) .. '\n' .. text('moony_end_' .. ceil((vars.seed % 125) / 2.5)), 4, 75)
		end
		assets.bitmore:drawText(text('total') .. vars.total_score .. text('pts'), 4, 104)
		assets.o2[floor(1 + ((33 - 1) / (0 - vars.o2_start)) * (vars.o2.value - vars.o2_start))]:draw(100 - 33, 0)
		--pause_img:drawScaled(0, 0, 2)
		gfx.popContext()
		pd.setMenuImage(pause_img:scaledImage(2))
		local menu = pd.getSystemMenu()
		menu:removeAllMenuItems()
		if not scenemanager.transitioning and not vars.dead and not vars.won then
			if not save.perf then
				menu:addCheckmarkMenuItem('radar', save.radar, function(val)
					save.radar = val
				end)
			end
			menu:addMenuItem(text('endgame'), function()
				vars.o2:resetnew(1, 1, 0)
			end)
		end
	end

	assets = {
		surface = gfx.image.new('images/surface'),
		stars_small = gfx.image.new('images/stars_s2'),
		stars_large = gfx.image.new('images/stars_l2'),
		backplate = gfx.image.new('images/backplate'),
		dark_side = gfx.image.new('images/dark_side'),
		o2 = gfx.imagetable.new('images/o2'),
		crater = gfx.imagetable.new('images/crater'),
		o22 = gfx.imagetable.new('images/o22'),
		rover = gfx.imagetable.new('images/rover'),
		flag = gfx.imagetable.new('images/flag'),
		ufo = gfx.imagetable.new('images/ufo'),
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
		aufo = smp.new('audio/sfx/ufo'),
		hit = smp.new('audio/sfx/hit'),
		bitmore = gfx.font.new('fonts/bitmoreoutline'),
		radar_crater = gfx.image.new('images/radar_crater'),
		radar_o2 = gfx.image.new('images/radar_o2'),
		radar_rover = gfx.image.new('images/radar_rover'),
		trick = gfx.imagetable.new('images/trick'),
		trickster = gfx.imagetable.new('images/trickster'),
		prompts = gfx.imagetable.new('images/prompts'),
		good1 = smp.new('audio/sfx/vo/good1'),
		good2 = smp.new('audio/sfx/vo/good2'),
		good3 = smp.new('audio/sfx/vo/good3'),
		good4 = smp.new('audio/sfx/vo/good4'),
		good5 = smp.new('audio/sfx/vo/good5'),
		good6 = smp.new('audio/sfx/vo/good6'),
		good7 = smp.new('audio/sfx/vo/good7'),
		good8 = smp.new('audio/sfx/vo/good8'),
		good9 = smp.new('audio/sfx/vo/good9'),
		good10 = smp.new('audio/sfx/vo/good10'),
		bad1 = smp.new('audio/sfx/vo/bad1'),
		bad2 = smp.new('audio/sfx/vo/bad2'),
		bad3 = smp.new('audio/sfx/vo/bad3'),
		bad4 = smp.new('audio/sfx/vo/bad4'),
		bad5 = smp.new('audio/sfx/vo/bad5'),
		bad6 = smp.new('audio/sfx/vo/bad6'),
		bad7 = smp.new('audio/sfx/vo/bad7'),
		bad8 = smp.new('audio/sfx/vo/bad8'),
		bad9 = smp.new('audio/sfx/vo/bad9'),
		bad10 = smp.new('audio/sfx/vo/bad10'),
		moreo2 = smp.new('audio/sfx/vo/moreo2'),
		duuude = smp.new('audio/sfx/vo/duuude'),
		what = smp.new('audio/sfx/vo/what'),
		escape = smp.new('audio/sfx/vo/escape'),
		burst_l = gfx.imagetable.new('images/burst_l'),
		burst_r = gfx.imagetable.new('images/burst_r'),
	}

	gfx.setFont(assets.bitmore)

	vars = {
		total_score = args[1] or 0,
		planet = args[2] or 1,
		best_combo = args[3] or 0,
		daily = args[4] or false,
		score = 0,
		combo = 1,
		combo_timer = pd.timer.new(1, 0, 0),
		player_x = 0,
		player_y = 0,
		player_tile_x = 1,
		player_tile_y = 1,
		dead = false,
		player_rotation = rad(pd.getCrankPosition()),
		camera_rotation = rad(pd.getCrankPosition()),
		test_camera_rotation = rad(pd.getCrankPosition()),
		show_moon = true,
		jumping = false,
		crashed = false,
		won = false,
		minijumping = false,
		trick_button_queue = '',
		trick_crank = 0,
		tricks_done = 0,
		trick_stack = '',
		overlay = '',
		eligible_to_win = false,
		trick_overlay = pd.timer.new(300, 1.01, 4.99),
		trick_slide = 0,
		trick_lerp = 0,
		jump = pd.timer.new(1, 0, 0),
		crank = pd.getCrankPosition(),
		crank2 = pd.getCrankPosition(),
		origin = pd.getCrankPosition(),
		crater = pd.timer.new(2000, 1, 30),
		seed = 0,
		flash = pd.timer.new(250, 2.99, 1),
		trick_cooldown = pd.timer.new(1, 0, 0),
		trickster_timer = pd.timer.new(500, 1.01, 4.99),
		burst = pd.timer.new(0, 7, 7),
		map = {
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		},
		items_x = {},
		items_y = {},
		point = pd.geometry.point.new(0, 0),
	}
	vars.gameHandlers = {
		upButtonDown = function()
			if not vars.minijumping and not vars.dead and not vars.jumping and not vars.crashed and not vars.won then
				vars.minijumping = true
				if save.sfx then assets.take:play() end
				assets.roll:stop()
				if not vars.crashed then
					vars.player_speed *= 0.75
				end
				vars.jump:resetnew(vars.jump_base * 0.25, vars.jump.value, 30, pd.easingFunctions.outCirc)
				pd.timer.performAfterDelay(vars.jump_base * 0.25, function()
					vars.jump:resetnew(vars.jump_base * 0.2, vars.jump.value, 0, pd.easingFunctions.inCirc)
					pd.timer.performAfterDelay(vars.jump_base * 0.2, function()
						if save.spin_camera then
							vars.player_rotation = vars.camera_rotation
						end
						if save.sfx then
							assets.land:play()
							assets.roll:play(0)
						end
						vars.minijumping = false
						if vars.dead then
							game:die()
						else
							vars.player_speed = vars.player_start_speed
						end
					end)
				end)
			end
		end,
	}
	pd.inputHandlers.push(vars.gameHandlers)

	vars.burst.discardOnCompletion = false
	vars.jump.discardOnCompletion = false
	vars.flash.repeats = true
	vars.point_threshold = 8000 + (vars.planet * 1000)
	vars.o2_start = max(70000 - (vars.planet * 3000), 20000)
	vars.o2 = pd.timer.new(vars.o2_start, vars.o2_start, 0)
	vars.combo_timer.discardOnCompletion = false
	vars.trick_cooldown.discardOnCompletion = false
	vars.trick_overlay.repeats = true
	vars.trickster_timer.timerEndedCallback = function()
		vars.trickster_timer:resetnew(500, 1.01, 4.99)
	end
	vars.combo_timer.timerEndedCallback = function()
		if vars.combo_timer.value == 0 then
			if save.sfx and vars.combo ~= 1 then assets.back:play() end
			vars.combo = 1
		end
	end
	vars.oldo2 = vars.o2_start
	vars.o2.timerEndedCallback = function() -- die function
		vars.dead = true
		if not vars.jumping and not vars.minijumping then
			game:die()
		end
	end
	if save.sfx then assets.roll:play(0) end

	if vars.daily then
		vars.gmttime = pd.getGMTTime()
		vars.seed = vars.gmttime.year .. vars.gmttime.month .. vars.gmttime.day
	else
		vars.seed = playdate.getSecondsSinceEpoch()
	end
	math.randomseed(vars.seed)

	vars.player_start_speed = random(7, 10)
	vars.player_speed = vars.player_start_speed
	vars.jump_base = math.random(1800, 2200)

	pd.timer.performAfterDelay(3000, function()
		vars.show_moon = false
	end)

	vars.target_craters = random(5, 10)
	if math.random(1, 6) < 6 then
		if vars.daily then
			vars.target_o2s = random(5, 8)
		else
			vars.target_o2s = random(3, 6)
		end
	else
		vars.target_o2s = 0
	end
	if math.random(1, 2) < 2 then
		vars.target_rovers = random(4, 6)
	else
		vars.target_rovers = 0
	end
	vars.target_flags = floor(random(0, 5) / 5)
	vars.target_ufos = floor(random(0, 10) / 10)
	vars.craters = 0
	vars.o2s = 0
	vars.rovers = 0
	vars.flags = 0
	vars.ufos = 0
	vars.ufoindex = {}

	local randx
	local randy

	while vars.craters < vars.target_craters do
		randx = random(2, 25)
		randy = random(2, 25)
		if vars.map[(randx)+((randy-1)*25)] == 0 and vars.map[(randx+1)+((randy-1)*25)] == 0 and vars.map[(randx-1)+((randy-1)*25)] == 0 and vars.map[(randx)+((randy)*25)] == 0 and vars.map[(randx)+((randy-2)*25)] == 0 and vars.map[(randx+1)+((randy)*25)] == 0 and vars.map[(randx-1)+((randy)*25)] == 0 and vars.map[(randx+1)+((randy-2)*25)] == 0 and vars.map[(randx-1)+((randy-2)*25)] == 0 then
			vars.map[randx+((randy-1)*25)] = 1
			vars.craters += 1
			table.insert(vars.items_x, randx)
			table.insert(vars.items_y, randy)
		end
	end
	while vars.o2s < vars.target_o2s do
		randx = random(2, 25)
		randy = random(2, 25)
		if vars.map[(randx)+((randy-1)*25)] == 0 and vars.map[(randx+1)+((randy-1)*25)] == 0 and vars.map[(randx-1)+((randy-1)*25)] == 0 and vars.map[(randx)+((randy)*25)] == 0 and vars.map[(randx)+((randy-2)*25)] == 0 and vars.map[(randx+1)+((randy)*25)] == 0 and vars.map[(randx-1)+((randy)*25)] == 0 and vars.map[(randx+1)+((randy-2)*25)] == 0 and vars.map[(randx-1)+((randy-2)*25)] == 0 then
			vars.map[randx+((randy-1)*25)] = 2
			vars.o2s += 1
			table.insert(vars.items_x, randx)
			table.insert(vars.items_y, randy)
		end
	end
	while vars.rovers < vars.target_rovers do
		randx = random(2, 25)
		randy = random(2, 25)
		if vars.map[(randx)+((randy-1)*25)] == 0 and vars.map[(randx+1)+((randy-1)*25)] == 0 and vars.map[(randx-1)+((randy-1)*25)] == 0 and vars.map[(randx)+((randy)*25)] == 0 and vars.map[(randx)+((randy-2)*25)] == 0 and vars.map[(randx+1)+((randy)*25)] == 0 and vars.map[(randx-1)+((randy)*25)] == 0 and vars.map[(randx+1)+((randy-2)*25)] == 0 and vars.map[(randx-1)+((randy-2)*25)] == 0 then
			vars.map[randx+((randy-1)*25)] = 3
			vars.rovers += 1
			table.insert(vars.items_x, randx)
			table.insert(vars.items_y, randy)
		end
	end
	while vars.flags < vars.target_flags do
		randx = random(2, 25)
		randy = random(2, 25)
		if vars.map[(randx)+((randy-1)*25)] == 0 and vars.map[(randx+1)+((randy-1)*25)] == 0 and vars.map[(randx-1)+((randy-1)*25)] == 0 and vars.map[(randx)+((randy)*25)] == 0 and vars.map[(randx)+((randy-2)*25)] == 0 and vars.map[(randx+1)+((randy)*25)] == 0 and vars.map[(randx-1)+((randy)*25)] == 0 and vars.map[(randx+1)+((randy-2)*25)] == 0 and vars.map[(randx-1)+((randy-2)*25)] == 0 then
			vars.map[randx+((randy-1)*25)] = 4
			vars.flags += 1
			table.insert(vars.items_x, randx)
			table.insert(vars.items_y, randy)
		end
	end
	while vars.ufos < vars.target_ufos do
		randx = random(2, 25)
		randy = random(2, 25)
		if vars.map[(randx)+((randy-1)*25)] == 0 and vars.map[(randx+1)+((randy-1)*25)] == 0 and vars.map[(randx-1)+((randy-1)*25)] == 0 and vars.map[(randx)+((randy)*25)] == 0 and vars.map[(randx)+((randy-2)*25)] == 0 and vars.map[(randx+1)+((randy)*25)] == 0 and vars.map[(randx-1)+((randy)*25)] == 0 and vars.map[(randx+1)+((randy-2)*25)] == 0 and vars.map[(randx-1)+((randy-2)*25)] == 0 then
			vars.map[randx+((randy-1)*25)] = 5
			vars.ufos += 1
			table.insert(vars.items_x, randx)
			table.insert(vars.items_y, randy)
			table.insert(vars.ufoindex, randx)
		end
	end
	for i = 1, vars.ufos do
		vars['ufotimer_' .. vars.ufoindex[i]] = pd.timer.new(1, 0, 0)
		vars['ufotimer_' .. vars.ufoindex[i]].discardOnCompletion = false
	end

	gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
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
		assets.backplate:draw(0 + (vars.trick_lerp / 2), 0 + (vars.jump.value/2))
		assets.stars_small:draw(-deg(vars.camera_rotation)/1.1 % -200 + (vars.trick_lerp / 2), -70 + (vars.jump.value / 3))
		assets.stars_large:draw(-deg(vars.camera_rotation) % -200 + (vars.trick_lerp / 2), -70 + (vars.jump.value / 3))
		assets.surface:drawSampled(0 + (vars.trick_lerp / 2), z, 200, h, 0.5, 0.92, dxx, dyx, dxy, dyy, dx, dy, p, t, true)
		--assets.test:drawSampled(0 + (vars.trick_lerp / 2), z, 200, h, 0.5, 0.92, dxx2, dyx2, dxy2, dyy2, dx2, dy2, p, t, true)
		if save.radar and not save.perf then
			gfx.setColor(gfx.kColorWhite)
			gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer2x2)
			gfx.drawLine(0 + (vars.trick_lerp / 2), 46 + ((vars.jump.value//4) * 2), 200 + (vars.trick_lerp / 2), 46 + ((vars.jump.value//4) * 2))
			gfx.setColor(gfx.kColorBlack)
		end
		assets.dark_side:draw(0 + (vars.trick_lerp / 2), 0 + (vars.jump.value/2))
		gfx.setDitherPattern(0.5 + (vars.jump.value / 140), gfx.image.kDitherTypeBayer4x4)
		gfx.fillEllipseInRect(84 - (vars.jump.value / 8) + (vars.trick_lerp / 2), 100 + (vars.jump.value / 8), 32 + (vars.jump.value / 4), 16 + (vars.jump.value / 8))
		gfx.setColor(gfx.kColorBlack)
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
		if not save.perf then
			if vars.player_tile_x <= 5 and vars.player_tile_y <= 5 then
				game:drawitems(2500, 2500)
			elseif vars.player_tile_x <= 20 and vars.player_tile_y <= 5 then
				game:drawitems(-2500, 2500)
			elseif vars.player_tile_x <= 5 and vars.player_tile_y <= 20 then
				game:drawitems(2500, -2500)
			elseif vars.player_tile_x <= 20 and vars.player_tile_y <= 20 then
				game:drawitems(-2500, -2500)
			end
			game:adjust(gfx.getWorkingImage(), false)
		end
		if vars.burst.value < 7 then
			assets.burst_l[floor(vars.burst.value)]:draw(0, 0)
			assets.burst_r[floor(vars.burst.value)]:draw(155, 0)
		end
		if vars.show_moon then
			if vars.daily then
				assets.bitmore:drawTextAligned(text('moon') .. vars.gmttime.year .. '-' .. format("%02d", vars.gmttime.month) .. '-' .. format("%02d", vars.gmttime.day) .. '\n' .. text('moony_start_' .. ((vars.seed % 50) + 1)) .. text('moony_end_' .. ceil((vars.seed % 125) / 2.5)), 100 + (vars.trick_lerp / 2), 5, kTextAlignment.center)
			else
				assets.bitmore:drawTextAligned(text('moon') .. vars.planet .. '\n' .. text('moony_start_' .. ((vars.seed % 50) + 1)) .. text('moony_end_' .. ceil((vars.seed % 125) / 2.5)), 100 + (vars.trick_lerp / 2), 5, kTextAlignment.center)
			end
		end
		if vars.overlay ~= '' then
			if find(vars.overlay, "bad") then
				gfx.setImageDrawMode(gfx.kDrawModeInverted)
			end
			assets.cutout:drawTextAligned(text(vars.overlay), 100 + (vars.trick_lerp / 2), 40, kTextAlignment.center)
		end
		if vars.combo > 1 then
			assets.cutout:drawText('©'  .. commalize(vars.combo), max(assets.pedallica:getTextWidth(commalize(vars.score)) - 11, 2), 4)
		end
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		assets.pedallica:drawText(commalize(vars.score), 5, 5)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
		if vars.combo_timer.value > 0 then
			gfx.setLineWidth(1)
			gfx.setColor(gfx.kColorWhite)
			gfx.drawRect(5, 30, 50, 5)
			gfx.fillRect(7, 32, 46 * vars.combo_timer.value, 1)
			gfx.setColor(gfx.kColorBlack)
			gfx.setLineWidth(2)
		end
		gfx.setColor(gfx.kColorXOR)
		gfx.fillRect(0, 118, (vars.score / vars.point_threshold) * (200 + vars.trick_lerp), 2)
		gfx.setColor(gfx.kColorBlack)
		if not vars.jumping and not vars.dead and not vars.minijumping and not vars.crashed and not vars.won then
			assets.prompts[1]:draw(4, 97)
		else
			assets.prompts[2]:draw(4, 97)
		end
		assets.o2[floor(1 + ((33 - 1) / (0 - vars.o2_start)) * (vars.o2.value - vars.o2_start))]:draw(167 + vars.trick_lerp, 0)
	end)

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
		if vars.jumping or vars.minijumping then
			if not save.spin_camera and vars.jumping then
				local rotation = (vars.crank % 360)
				if (rotation > -30 and rotation <= 30) or (rotation > 330 and rotation <= 30) then
					self:setImage(assets.skater[11])
				elseif rotation > 30 and rotation <= 90 then
					self:setImage(assets.skater[16])
				elseif rotation > 90 and rotation <= 150 then
					self:setImage(assets.skater[15])
				elseif rotation > 150 and rotation <= 210 then
					self:setImage(assets.skater[14])
				elseif rotation > 210 and rotation <= 270 then
					self:setImage(assets.skater[13])
				elseif rotation > 270 and rotation <= 330 then
					self:setImage(assets.skater[12])
				end
			else
				self:setImage(assets.skater[11])
			end
		elseif vars.dead then
			self:setImage(assets.skater[17])
		else
			if change >= 4 then
				if floor(vars.flash.value) >= 2 then
					self:setImage(assets.skater[9])
				else
					self:setImage(assets.skater[10])
				end
			elseif change >= 2 then
				if floor(vars.flash.value) >= 2 then
					self:setImage(assets.skater[7])
				else
					self:setImage(assets.skater[8])
				end
			elseif change <= -4 then
				if floor(vars.flash.value) >= 2 then
					self:setImage(assets.skater[5])
				else
					self:setImage(assets.skater[6])
				end
			elseif change <= -2 then
				if floor(vars.flash.value) >= 2 then
					self:setImage(assets.skater[3])
				else
					self:setImage(assets.skater[4])
				end
			else
				if floor(vars.flash.value) >= 2 then
					self:setImage(assets.skater[1])
				else
					self:setImage(assets.skater[2])
				end
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
		vars.crank += change
		if (vars.origin >= vars.crank + 30 or vars.origin <= vars.crank - 30) and show_crank then
			show_crank = false
		end
		if not vars.dead then
			if (not vars.jumping or (vars.jumping and save.spin_camera)) and not vars.won and (not vars.minijumping or (vars.minijumping and save.spin_camera)) then
				vars.crank2 += change
				vars.camera_rotation += (rad(vars.crank2) - vars.camera_rotation) * 0.1
			end
			if not vars.jumping and not vars.won and not vars.minijumping then
				vars.player_rotation += (vars.camera_rotation - vars.player_rotation) * 0.1
			end
		end
		vars.player_x += sin(vars.player_rotation) * vars.player_speed
		vars.player_y -= cos(vars.player_rotation) * vars.player_speed
		if vars.dead and not vars.jumping then
			vars.player_speed += (0 - vars.player_speed) * 0.1
		end
		vars.player_x %= 2500
		vars.player_y %= 2500
		vars.player_tile_x = ceil((vars.player_x) / 100)
		vars.player_tile_y = ceil((vars.player_y) / 100)
		self:moveTo(100 + (vars.trick_lerp / 2), 110 - vars.jump.value)
	end

	class('trick', _, classes).extends(gfx.sprite)
	function classes.trick:init()
		classes.trick.super.init(self)
		self:setSize(105, 120)
		self:setCenter(1, 0)
		self:moveTo(200, 0)
		self:setZIndex(2)
		self:add()
	end
	function classes.trick:update()
		self:moveTo(300 + vars.trick_lerp + ((vars.trick_lerp / 20) + 5), 0)
	end
	function classes.trick:draw()
		assets.trick[floor(vars.trick_overlay.value)]:draw(0, 0)
		gfx.setColor(gfx.kColorWhite)
		gfx.setDitherPattern(0.8, gfx.image.kDitherTypeBayer4x4)
		gfx.fillRect(5, 120, 100, -(vars.trick_cooldown.value * 120))
		gfx.setColor(gfx.kColorBlack)
		if vars.burst.value < 7 then
			assets.burst_r[floor(vars.burst.value)]:draw(59, 0)
		end
		assets.trickster[floor(vars.trickster_timer.value)]:draw(0, 0)
		if vars.trick_stack ~= '' then
			local _, h = gfx.getTextSize(vars.trick_stack)
			assets.bitmore:drawText(vars.trick_stack, 16, 133 - h)
		end
	end

	sprites.player = classes.player()
	sprites.trick = classes.trick()
	newmusic('audio/music/game', true)
	self:add()
end

function game:adjust(workingimage, wobble)
	for i = 0, 20 do
		local rand = wobble and random(8, 10) or 10
		gfx.setClipRect((i^3/103) - rand + (vars.trick_lerp / 2), 0, 200 + (rand*2 - (i^3/103*2)), 150)
		workingimage:draw(0, 20-(i))
	end
	gfx.clearClipRect()
end

function game:drawitems(offx, offy)
	local player_x = vars.player_x + offx
	local player_y = vars.player_y + offy
	local player_tile_x = vars.player_tile_x
	local player_tile_y = vars.player_tile_y
	local range = 10
	if save.perf then range = 5 end
	local c = cos(-vars.camera_rotation)
	local s = sin(-vars.camera_rotation)
	for i = 1, #vars.items_x do
		for n = 1, #vars.items_y do
			local xi = vars.items_x[i]
			local yn = vars.items_y[n]
			if (xi <= player_tile_x + range + (offx / 100) and xi >= player_tile_x - range + (offx / 100)) and (yn >= player_tile_y - range + (offy / 100) and yn <= player_tile_y + range + (offy / 100)) then
				if vars.map[xi+((yn-1)*25)] == 1 then
					local offsetx = (xi * 100) - player_x - 33
					local offsety = (yn * 100) - player_y - 33
					local x = 100 + (c*offsetx - s*offsety) * 2
					local y = 110 + (s*offsetx + c*offsety) * 2
					local yadjust = min(((y/60)+22.5) * 2, 60)
					if yadjust > 1 then
						assets.crater[floor(yadjust)]:draw(((x-100)/5) + (vars.trick_lerp / 2), 0 + (vars.jump.value/2))
					elseif save.radar and not save.perf then
						assets.radar_crater:draw((x/5)+70 + (vars.trick_lerp / 2), 20 + (vars.jump.value/2))
					end
					if vars.player_tile_x == xi and vars.player_tile_y == yn and not vars.jumping and not vars.dead and not vars.minijumping then
						if vars.eligible_to_win then
							vars.jumping = true
							vars.won = true
							vars.overlay = ''
							assets.roll:stop()
							vars.combo_timer:pause()
							if save.sfx then
								assets.slide:play()
								assets.take:play()
							end
							vars.jump:resetnew(1500, vars.jump.value, 200, pd.easingFunctions.outSine)
							fademusic(2000)
							pd.timer.performAfterDelay(2750, function()
								if save.skip_interstition then
									scenemanager:irisscenetwo(game, vars.total_score, vars.planet + 1, vars.best_combo)
								else
									scenemanager:irissceneout(interstition, vars.total_score, vars.planet, vars.best_combo)
								end
							end)
						else
							vars.jumping = true
							vars.trick_slide = -100
							vars.trick_button_queue = ''
							vars.trick_crank = 0
							vars.overlay = ''
							vars.tricks_done = 0
							vars.trick_stack = ''
							vars.combo_timer:pause()
							if save.sfx then assets.take:play() end
							assets.roll:stop()
							if vars.combo_timer.value > 0 then
								vars.combo_timer:resetnew(500, vars.combo_timer.value, 1)
							end
							if not vars.crashed then
								vars.player_speed *= 0.75
							end
							vars.jump:resetnew(vars.jump_base, vars.jump.value, 50, pd.easingFunctions.outCirc)
							pd.timer.performAfterDelay(vars.jump_base, function()
								vars.jump:resetnew(vars.jump_base * 0.75, vars.jump.value, 0, pd.easingFunctions.inCirc)
								pd.timer.performAfterDelay(vars.jump_base * 0.75, function()
									if save.sfx then
										assets.land:play()
										assets.roll:play(0)
									end
									vars.jumping = false
									vars.trick_slide = 0
									vars.trick_stack = ''
									if vars.dead then
										game:die()
									else
										vars.player_speed = vars.player_start_speed
										if vars.trick_cooldown.timeLeft > 0 then
											if vars.eligible_to_win then
												vars.overlay = 'escape'
												vars.burst:resetnew(500, 1, 6.99)
												vars.burst.repeats = true
												if save.sfx then assets[vars.overlay]:play() end
												pd.timer.performAfterDelay(2000, function()
													if vars.overlay == 'escape' then
														vars.overlay = ''
													end
												end)
											else
												vars.overlay = tostring('bad' .. math.random(1, 10))
												if save.sfx then assets[vars.overlay]:play() end
												pd.timer.performAfterDelay(1000, function()
													if vars.overlay:find('^bad') ~= nil then
														vars.overlay = ''
													end
												end)
											end
											if save.sfx then assets.crash:play() end
											vars.crashed = true
											vars.player_speed /= 2
											shakies()
											shakies_y()
											vars.combo_timer:resetnew(1, 0, 0)
											pd.timer.performAfterDelay(2000, function()
												vars.crashed = false
												vars.player_speed *= 2
												sprites.player:setVisible(true)
											end)
										else
											if vars.eligible_to_win then
												vars.overlay = 'escape'
												vars.burst:resetnew(500, 1, 6.99)
												vars.burst.repeats = true
												if save.sfx then assets[vars.overlay]:play() end
												pd.timer.performAfterDelay(2000, function()
													if vars.overlay == 'escape' then
														vars.overlay = ''
													end
												end)
											else
												if vars.tricks_done > 0 then
													vars.overlay = tostring('good' .. math.random(1, 10))
													if save.sfx then assets[vars.overlay]:play() end
													pd.timer.performAfterDelay(1000, function()
														if vars.overlay:find('^good') ~= nil then
															vars.overlay = ''
														end
													end)
												end
											end
											vars.combo += 1
											if vars.combo > vars.best_combo then vars.best_combo = vars.combo end
											vars.combo_timer:resetnew(5000, 1, 0)
											vars.player_rotation = vars.camera_rotation
											if not vars.crashed and vars.tricks_done > 0 then
												vars.player_start_speed *= 1.1
												vars.player_speed = vars.player_start_speed
											end
										end
									end
									vars.tricks_done = 0
								end)
							end)
						end
					end
				elseif vars.map[xi+((yn-1)*25)] == 2 then
					local offsetx = (xi * 100) - player_x - 39
					local offsety = (yn * 100) - player_y - 39
					local x = 100 + (c*offsetx - s*offsety) * 2
					local y = 110 + (s*offsetx + c*offsety) * 2
					local yadjust = min(((y/60)+24) * 2, 60)
					if yadjust > 1 then
						assets.o22[floor(yadjust)]:draw((x-100)/5 + (vars.trick_lerp / 2), 0 + (vars.jump.value/2))
					elseif save.radar and not save.perf then
						assets.radar_o2:draw((x/5)+70 + (vars.trick_lerp / 2), 20 + (vars.jump.value/2))
					end
					if vars.player_tile_x == xi and vars.player_tile_y == yn and not vars.jumping and not vars.dead and not vars.minijumping then
						vars.map[xi+((yn-1)*25)] = 0
						vars.ufos -= 1
						if save.sfx then assets.select:play() end
						vars.overlay = 'moreo2'
						if save.sfx then assets[vars.overlay]:play() end
						pd.timer.performAfterDelay(1000, function()
							if vars.overlay == 'moreo2' then
								vars.overlay = ''
							end
						end)
						vars.o2:resetnew(min(vars.o2.value * 1.5, vars.o2_start), min(vars.o2.value * 1.5, vars.o2_start), 0)
					end
				elseif vars.map[xi+((yn-1)*25)] == 3 then
					local offsetx = (xi * 100) - player_x - 33
					local offsety = (yn * 100) - player_y - 33
					local x = 100 + (c*offsetx - s*offsety) * 2
					local y = 110 + (s*offsetx + c*offsety) * 2
					local yadjust = min(((y/80)+24) * 2, 60)
					if yadjust > 1 then
						assets.rover[floor(yadjust)]:draw(((x-100)/5) + (vars.trick_lerp / 2), 0 + (vars.jump.value/2))
					elseif save.radar and not save.perf then
						assets.radar_rover:draw((x/5)+70 + (vars.trick_lerp / 2), 20 + (vars.jump.value/2))
					end
					if vars.player_tile_x == xi and vars.player_tile_y == yn and not vars.crashed and not vars.jumping and not vars.dead and not vars.minijumping then
						if save.sfx then assets.crash:play() end
						vars.crashed = true
						vars.player_speed = vars.player_start_speed / 2
						shakies()
						shakies_y()
						vars.combo_timer:resetnew(1, 0, 0)
						pd.timer.performAfterDelay(2000, function()
							vars.crashed = false
							vars.player_start_speed /= 1.1
							vars.player_speed = vars.player_start_speed
							sprites.player:setVisible(true)
						end)
					end
				elseif vars.map[xi+((yn-1)*25)] == 4 then
					local offsetx = (xi * 100) - player_x - 33
					local offsety = (yn * 100) - player_y - 33
					local x = 100 + (c*offsetx - s*offsety) * 2
					local y = 110 + (s*offsetx + c*offsety) * 2
					local yadjust = min(((y/60)+24) * 2, 60)
					if yadjust > 1 then
						assets.flag[floor(yadjust)]:draw((x-100)/5 + (vars.trick_lerp / 2), 0 + (vars.jump.value/2))
					end
					if vars.player_tile_x == xi and vars.player_tile_y == yn and not vars.crashed and not vars.jumping and not vars.dead then
						vars.map[xi+((yn-1)*25)] = 0
						if save.sfx then assets.select:play() end
						vars.overlay = 'what'
						if save.sfx then assets[vars.overlay]:play() end
						pd.timer.performAfterDelay(1000, function()
							if vars.overlay == 'what' then
								vars.overlay = ''
							end
						end)
						save.flags += 1
						vars.flags -= 1
					end
				elseif vars.map[xi+((yn-1)*25)] == 5 then
					local offsetx = (xi * 100) - player_x - 33
					local offsety = (yn * 100) - player_y - 33
					local x = 100 + (c*offsetx - s*offsety) * 2
					local y = 110 + (s*offsetx + c*offsety) * 2
					local yadjust = min(((y/60)+22) * 2, 60)
					if yadjust > 1 then
						if vars['ufotimer_' .. xi].timeLeft > 0 then
							assets.ufo[math.min(floor(yadjust), 23 * 2)]:draw((x-100)/5 + (vars.trick_lerp / 2), 0 + (vars.jump.value/2) + vars['ufotimer_' .. xi].value)
						else
							assets.ufo[floor(yadjust)]:draw((x-100)/5 + (vars.trick_lerp / 2), 0 + (vars.jump.value/2))
						end
					end
					if vars.player_tile_x == xi and vars.player_tile_y == yn and not vars.crashed and not vars.jumping and not vars.dead then
						if vars['ufotimer_' .. xi].timeLeft == 0 then
							if save.sfx then assets.aufo:play() end
							vars['ufotimer_' .. xi]:resetnew(500, 0, -200, pd.easingFunctions.inSine)
							vars.score += 3000
							vars.total_score += 3000
							vars.overlay = 'duuude'
							if save.sfx then assets[vars.overlay]:play() end
							pd.timer.performAfterDelay(1000, function()
								if vars.overlay == 'duuude' then
									vars.overlay = ''
								end
							end)
							pd.timer.performAfterDelay(490, function()
								vars.map[xi+((yn-1)*25)] = 0
							end)
							save.ufos += 1
						end
					end
				end
			end
		end
	end
end

function game:update()
	vars.trick_lerp += (vars.trick_slide - vars.trick_lerp) * 0.4
	if vars.jumping and not vars.won and not vars.dead and vars.trick_cooldown.timeLeft == 0 then
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
		if vars.trick_crank > 360 then
			if pd.buttonIsPressed('up') then
				vars.trickster_timer:resetnew(400, 5.01, 8.99)
				vars.trick_stack = text('rebound') .. '\n' .. vars.trick_stack
				vars.score += 500 * vars.combo
				vars.total_score += 500 * vars.combo
				vars.trick_cooldown:resetnew(500, 1, 0)
			elseif pd.buttonIsPressed('down') then
				vars.trickster_timer:resetnew(400, 9.01, 12.99)
				vars.trick_stack = text('spinturn') .. '\n' .. vars.trick_stack
				vars.score += 600 * vars.combo
				vars.total_score += 600 * vars.combo
				vars.trick_cooldown:resetnew(600, 1, 0)
			elseif pd.buttonIsPressed('left') then
				vars.trickster_timer:resetnew(400, 13.01, 16.99)
				vars.trick_stack = text('widdershin') .. '\n' .. vars.trick_stack
				vars.score += 800 * vars.combo
				vars.total_score += 800 * vars.combo
				vars.trick_cooldown:resetnew(600, 1, 0)
			elseif pd.buttonIsPressed('right') then
				vars.trickster_timer:resetnew(400, 17.01, 20.99)
				vars.trick_stack = text('clocky') .. '\n' .. vars.trick_stack
				vars.score += 700 * vars.combo
				vars.total_score += 700 * vars.combo
				vars.trick_cooldown:resetnew(700, 1, 0)
			elseif vars.trick_button_queue == 'up' then
				vars.trickster_timer:resetnew(400, 21.01, 24.99)
				vars.trick_stack = text('takeoff') .. '\n' .. vars.trick_stack
				vars.score += 1000 * vars.combo
				vars.total_score += 1000 * vars.combo
				vars.trick_cooldown:resetnew(750, 1, 0)
			elseif vars.trick_button_queue == 'down' then
				vars.trickster_timer:resetnew(400, 25.01, 28.99)
				vars.trick_stack = text('weeble') .. '\n' .. vars.trick_stack
				vars.score += 900 * vars.combo
				vars.total_score += 900 * vars.combo
				vars.trick_cooldown:resetnew(750, 1, 0)
			elseif vars.trick_button_queue == 'left' then
				vars.trickster_timer:resetnew(400, 29.01, 32.99)
				vars.trick_stack = text('highroad') .. '\n' .. vars.trick_stack
				vars.score += 1100 * vars.combo
				vars.total_score += 1100 * vars.combo
				vars.trick_cooldown:resetnew(750, 1, 0)
			elseif vars.trick_button_queue == 'right' then
				vars.trickster_timer:resetnew(400, 33.01, 36.99)
				vars.trick_stack = text('snapflip') .. '\n' .. vars.trick_stack
				vars.score += 1050 * vars.combo
				vars.total_score += 1050 * vars.combo
				vars.trick_cooldown:resetnew(750, 1, 0)
			else
				vars.trickster_timer:resetnew(400, 37.01, 40.99)
				vars.trick_stack = text('360') .. '\n' .. vars.trick_stack
				vars.score += 300 * vars.combo
				vars.total_score += 300 * vars.combo
				vars.trick_cooldown:resetnew(300, 1, 0)
			end
			if save.sfx then assets.hit:play(1, 1 + (vars.tricks_done * 0.2)) end
			vars.burst:resetnew(300, 1, 7)
			vars.tricks_done += 1
			vars.trick_crank = 0
			vars.trick_button_queue = ''
		elseif vars.trick_crank < -360 then
			if pd.buttonIsPressed('up') then
				vars.trickster_timer:resetnew(400, 5.01, 8.99)
				vars.trick_stack = text('reverserebound') .. '\n' .. vars.trick_stack
				vars.score += 600 * vars.combo
				vars.total_score += 600 * vars.combo
				vars.trick_cooldown:resetnew(600, 1, 0)
			elseif pd.buttonIsPressed('down') then
				vars.trickster_timer:resetnew(400, 9.01, 12.99)
				vars.trick_stack = text('reversespinturn') .. '\n' .. vars.trick_stack
				vars.score += 700 * vars.combo
				vars.total_score += 700 * vars.combo
				vars.trick_cooldown:resetnew(700, 1, 0)
			elseif pd.buttonIsPressed('left') then
				vars.trickster_timer:resetnew(400, 13.01, 16.99)
				vars.trick_stack = text('reversewiddershin') .. '\n' .. vars.trick_stack
				vars.score += 900 * vars.combo
				vars.total_score += 900 * vars.combo
				vars.trick_cooldown:resetnew(750, 1, 0)
			elseif pd.buttonIsPressed('right') then
				vars.trickster_timer:resetnew(400, 17.01, 20.99)
				vars.trick_stack = text('reverseclocky') .. '\n' .. vars.trick_stack
				vars.score += 800 * vars.combo
				vars.total_score += 800 * vars.combo
				vars.trick_cooldown:resetnew(750, 1, 0)
			elseif vars.trick_button_queue == 'up' then
				vars.trickster_timer:resetnew(400, 21.01, 24.99)
				vars.trick_stack = text('reversetakeoff') .. '\n' .. vars.trick_stack
				vars.score += 1100 * vars.combo
				vars.total_score += 1100 * vars.combo
				vars.trick_cooldown:resetnew(750, 1, 0)
			elseif vars.trick_button_queue == 'down' then
				vars.trickster_timer:resetnew(400, 25.01, 28.99)
				vars.trick_stack = text('reverseweeble') .. '\n' .. vars.trick_stack
				vars.score += 1000 * vars.combo
				vars.total_score += 1000 * vars.combo
				vars.trick_cooldown:resetnew(750, 1, 0)
			elseif vars.trick_button_queue == 'left' then
				vars.trickster_timer:resetnew(400, 29.01, 32.99)
				vars.trick_stack = text('reversehighroad') .. '\n' .. vars.trick_stack
				vars.score += 1200 * vars.combo
				vars.total_score += 1200 * vars.combo
				vars.trick_cooldown:resetnew(750, 1, 0)
			elseif vars.trick_button_queue == 'right' then
				vars.trickster_timer:resetnew(400, 33.01, 36.99)
				vars.trick_stack = text('reversesnapflip') .. '\n' .. vars.trick_stack
				vars.score += 1150 * vars.combo
				vars.total_score += 1150 * vars.combo
				vars.trick_cooldown:resetnew(750, 1, 0)
			else
				vars.trickster_timer:resetnew(400, 37.01, 40.99)
				vars.trick_stack = text('reverse360') .. '\n' .. vars.trick_stack
				vars.score += 400 * vars.combo
				vars.total_score += 400 * vars.combo
				vars.trick_cooldown:resetnew(400, 1, 0)
			end
			if save.sfx then assets.hit:play(1, 1 + (vars.tricks_done * 0.2)) end
			vars.burst:resetnew(300, 1, 7)
			vars.tricks_done += 1
			vars.trick_crank = 0
			vars.trick_button_queue = ''
		end
	end
	if vars.oldo2 > 20000 and vars.o2.value < 20000 then self:beep(0.1) end
	if vars.oldo2 > 19000 and vars.o2.value < 19000 then self:beep(0.2) end
	if vars.oldo2 > 18000 and vars.o2.value < 18000 then self:beep(0.3) end
	if vars.oldo2 > 17000 and vars.o2.value < 17000 then self:beep(0.4) end
	if vars.oldo2 > 16000 and vars.o2.value < 16000 then self:beep(0.5) end
	if vars.oldo2 > 15000 and vars.o2.value < 15000 then self:beep(0.6) end
	if vars.oldo2 > 14000 and vars.o2.value < 14000 then self:beep(0.7) end
	if vars.oldo2 > 13000 and vars.o2.value < 13000 then self:beep(0.8) end
	if vars.oldo2 > 12000 and vars.o2.value < 12000 then self:beep(0.9) end
	if vars.oldo2 > 11000 and vars.o2.value < 11000 then self:beep(1) end
	if vars.oldo2 > 10000 and vars.o2.value < 10000 then self:beep(1) end
	if vars.oldo2 > 9000 and vars.o2.value < 9000 then self:beep(1) end
	if vars.oldo2 > 8000 and vars.o2.value < 8000 then self:beep(1) end
	if vars.oldo2 > 7000 and vars.o2.value < 7000 then self:beep(1) end
	if vars.oldo2 > 6000 and vars.o2.value < 6000 then self:beep(1) end
	if vars.oldo2 > 5000 and vars.o2.value < 5000 then self:beep(1) end
	if vars.oldo2 > 4000 and vars.o2.value < 4000 then self:beep(1) end
	if vars.oldo2 > 3000 and vars.o2.value < 3000 then self:beep(1) end
	if vars.oldo2 > 2000 and vars.o2.value < 2000 then self:beep(1) end
	if vars.oldo2 > 1000 and vars.o2.value < 1000 then self:beep(1) end
	if vars.score > vars.point_threshold and not vars.eligible_to_win and not vars.daily then
		vars.eligible_to_win = true
		if save.sfx then assets.powerup:play() end
		stopmusic()
		newmusic('audio/music/escape', true, 1.596)
	end
	vars.oldo2 = vars.o2.value
end

function game:beep(intensity)
	if not vars.won then
		vars.burst:resetnew(250, 1, 7)
		shakies(500, intensity * 10)
		shakies_y(750, intensity * 10)
		if save.sfx then
			assets.beep:setVolume(intensity)
			assets.beep:play()
		end
	end
end

function game:die()
	if save.sfx then assets.crash:play() end
	assets.roll:stop()
	fademusic(900)
	pd.timer.performAfterDelay(1000, function()
		if vars.daily then
			scenemanager:irissceneout(dailyorbit, vars.total_score, vars.best_combo)
		else
			scenemanager:irissceneout(gameover, vars.total_score, vars.planet, vars.best_combo)
		end
	end)
end