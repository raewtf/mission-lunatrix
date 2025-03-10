-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local text <const> = gfx.getLocalizedText

class('credits').extends(gfx.sprite) -- Create the scene's class
function credits:init(...)
	credits.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here
	gfx.sprite.setAlwaysRedraw(true) -- Should this scene redraw the sprites constantly?
	pd.display.setScale(1)
	pd.datastore.write(save)

	assets = {
		cutout = gfx.font.new('fonts/cutout'),
		pedallica = gfx.font.new('fonts/pedallica'),
		credits = gfx.image.new('images/credits'),
		back = smp.new('audio/sfx/back'),
	}

	vars = {
	}
	vars.creditsHandlers = {
		BButtonDown = function()
			scenemanager:transitionscene(title)
			if save.sfx then assets.back:play() end
		end,
	}
	pd.inputHandlers.push(vars.creditsHandlers)

	gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
		assets.credits:draw(0, 0)
		assets.cutout:drawTextAligned(text('credits'), 200, 10, kTextAlignment.center)
		assets.pedallica:drawTextAligned(text('fullcredits'), 200, 60, kTextAlignment.center)
	end)

	self:add()
end

function credits:update()
end