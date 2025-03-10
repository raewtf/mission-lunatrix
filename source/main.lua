classes = {}

-- Importing things
import 'CoreLibs/math'
import 'CoreLibs/timer'
import 'CoreLibs/crank'
import 'CoreLibs/object'
import 'CoreLibs/sprites'
import 'CoreLibs/graphics'
import 'CoreLibs/animation'
import 'scenemanager'
import 'title'
scenemanager = scenemanager()

-- Setting up basic SDK params
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local text <const> = gfx.getLocalizedText

pd.display.setRefreshRate(30)
gfx.setBackgroundColor(gfx.kColorBlack)
gfx.setLineWidth(2)

-- Save check
function savecheck()
    save = pd.datastore.read()
    if save == nil then save = {} end
	if save.music == nil then save.music = true end
	if save.sfx == nil then save.sfx = true end
	save.score = save.score or 0
	save.lifetime_score = save.lifetime_score or 0
	save.highest_planet = save.highest_planet or 0
	save.arcade_runs = save.arcade_runs or 0
	save.best_combo = save.best_combo or 0
end

-- ... now we run that!
savecheck()

-- When the game closes...
function pd.gameWillTerminate()
    pd.datastore.write(save)
	if pd.display.getScale() == 1 then
		local img = gfx.getDisplayImage()
		local byebye = gfx.imagetable.new('images/exit')
		local spray = smp.new('audio/sfx/spray')
		if save.sfx then spray:play() end
		local byebyeanim = gfx.animator.new(1400, 1, #byebye)
		gfx.setDrawOffset(0, 0)
		while not byebyeanim:ended() do
			img:draw(0, 0)
			byebye:drawImage(math.floor(byebyeanim:currentValue()), 0, 0)
			pd.display.flush()
		end
	end
end

function pd.deviceWillSleep()
    pd.datastore.write(save)
end

-- Setting up music
music = nil

-- Fades the music out, and trashes it when finished. Should be called alongside a scene change, only if the music is expected to change. Delay can set the delay (in seconds) of the fade
function fademusic(delay)
    delay = delay or 1000
    if music ~= nil then
        music:setVolume(0, 0, delay/1000, function()
            music:stop()
            music = nil
        end)
    end
end

function stopmusic()
    if music ~= nil then
        music:stop()
        music = nil
    end
end

-- New music track. This should be called in a scene's init, only if there's no track leading into it. File is a path to an audio file in the PDX. Loop, if true, will loop the audio file. Range will set the loop's starting range.
function newmusic(file, loop, range)
    if save.music and music == nil then -- If a music file isn't actively playing...then go ahead and set a new one.
        music = fle.new(file)
        if loop then -- If set to loop, then ... loop it!
            music:setLoopRange(range or 0)
            music:play(0)
        else
            music:play()
            music:setFinishCallback(function()
                music = nil
            end)
        end
    end
end

function pd.timer:resetnew(duration, startValue, endValue, easingFunction)
    self.duration = duration
    if startValue ~= nil then
        self._startValue = startValue
        self.originalValues.startValue = startValue
        self._endValue = endValue or 0
        self.originalValues.endValue = endValue or 0
        self._easingFunction = easingFunction or pd.easingFunctions.linear
        self.originalValues.easingFunction = easingFunction or pd.easingFunctions.linear
        self._currentTime = 0
        self.value = self._startValue
    end
    self._lastTime = nil
    self.active = true
    self.hasReversed = false
    self.reverses = false
    self.repeats = false
    self.remainingDelay = self.delay
    self._calledOnRepeat = nil
    self.discardOnCompletion = false
    self.paused = false
    self.timerEndedCallback = self.timerEndedCallback
end

-- This function shakes the screen. int is a number representing intensity. time is a number representing duration
function shakies(time, int)
	if pd.getReduceFlashing() or perf then -- If reduce flashing is enabled, then don't shake.
		return
	end
	anim_shakies = pd.timer.new(time or 500, int or 10, 0, pd.easingFunctions.outElastic)
end

function shakies_y(time, int)
	if pd.getReduceFlashing() or perf then
		return
	end
	anim_shakies_y = pd.timer.new(time or 750, int or 10, 0, pd.easingFunctions.outElastic)
end

scenemanager:switchscene(title)

function pd.update()
	-- Screen shake update logic
	if anim_shakies ~= nil then
		pd.display.setOffset(anim_shakies.value, offsety)
	end
	offsetx, offsety = pd.display.getOffset()
	if anim_shakies_y ~= nil then
		pd.display.setOffset(offsetx, anim_shakies_y.value)
	end
	-- Catch-all stuff ...
	gfx.sprite.update()
	pd.timer.updateTimers()
end