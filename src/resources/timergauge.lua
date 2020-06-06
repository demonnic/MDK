--- TimerGauge
-- Animated countdown timer, extends <a href="https://www.mudlet.org/geyser/files/geyser/GeyserGauge.html">Geyser.Gauge</a>
--@module TimerGauge
local TimerGauge = {
  name = "TimerGaugeClass",
  active = true,
  showTime = true,
  timerCaption = "",
  updateTime = "10",
  autoHide = true,
  autoShow = true,
}

function TimerGauge:setStyleSheet(cssFront, cssBack, cssText)
  cssFront = cssFront or self.cssFront
  cssBack = cssBack or self.cssBack
  cssBack = cssBack or self.cssFront .. "background-color: black;"
  cssText = cssText or self.cssText
  if cssFront then
    self.front:setStyleSheet(cssFront)
  end
  if cssBack then
    self.back:setStyleSheet(cssBack)
  end
  if cssText then
    self.text:setStyleSheet(cssText)
  end
  --self.gauge:setStyleSheet(cssFront, cssBack, cssText)
  self.cssFront = cssFront
  self.cssBack = cssBack
  self.cssText = cssText
end

--- Starts the timergauge. Works whether the timer is stopped or not. Does not start a timer which is already at 0
-- @tparam[opt] boolean show override the autoShow property. If you pass false it will not automatically pass :show()
function TimerGauge:start(show)
  if show == nil then show = self.autoShow end
  self.active = true
  if self.timer then
    killTimer(self.timer)
    self.timer = nil
  end
  startStopWatch(self.stopWatchName)
  self:update()
  self.timer = tempTimer(self.updateTime / 1000, function() self:update() end, true)
  if show then self:show() end
end

--- Stops the timergauge. Works whether the timer is started or not.
-- @tparam[opt] boolean hide override the autoHide property. If you pass true it will ensure :hide() is called when stopped
function TimerGauge:stop(hide)
  if hide == nil then hide = self.autoHide end
  self.active = false
  if self.timer then
    killTimer(self.timer)
    self.timer = nil
  end
  stopStopWatch(self.stopWatchName)
  if hide then self:hide() end
end

--- Alias for stop.
-- @tparam[opt] boolean hide override the autoHide property. If you pass true it will ensure :hide() is called when stopped
function TimerGauge:pause(hide)
  self:stop(hide)
end

--- Resets the time on the timergauge to its original value. Does not alter the running state of the timer
function TimerGauge:reset()
  resetStopWatch(self.stopWatchName)
  adjustStopWatch(self.stopWatchName, self.time * -1)
  self:update()
end

--- Resets and starts the timergauge.
-- @tparam[opt] boolean show override the autoShow property. If you pass false it will not automatically pass :show(), if you pass true it will.
function TimerGauge:restart(show)
  self:reset()
  self:start(show)
end

--- Get the amount of time remaining on the timer, in seconds
function TimerGauge:getTime()
  local time = getStopWatchTime(self.stopWatchName)
  if time > 0 then
    time = 0
    self:stop(self.autoHide)
    resetStopWatch(self.stopWatchName)
    self.active = false
  end
  return math.abs(getStopWatchTime(self.stopWatchName))
end

--- Execute the timer's hook, if there is one.
function TimerGauge:executeHook()
  local hook = self.hook
  if not hook then return end
  local hooktype = type(hook)
  if hooktype == "string" then
    local f,e = loadstring("return " .. hook)
    if not f then
      f,e = loadstring(hook)
    end
    if not f then
      debugc(string.format("TimerGauge encountered an error while executing the hook for TimerGauge with name: %s error: %s", self.name, tostring(e)))
      return
    end
    hook = f
  end
  hooktype = type(hook)
  if hooktype ~= "function" then
    debugc(string.format("TimerGauge with name: %s was given a hook which is neither a function nor a string which can be made into one. Provided type was %s", self.name, hooktype))
    return
  end
  local worked, err = pcall(hook)
  if not worked then
    debugc(string.format("TimerGauge named %s encountered the following error while executing its hook: %s", self.name, err))
  end
end

--- Sets the timer's remaining time to 0, stops it, and executes the hook if one exists.
-- @tparam[opt] boolean skipHook use true to have it set the timer to 0 and stop, but not execute the hook.
function TimerGauge:finish(skipHook)
  resetStopWatch(self.stopWatchName)
  self:update(skipHook)
end

--- Updates the visual representation of the gauge with time remaining
-- @tparam[opt] boolean skipHook use true if you do not want to execute the hook if the timer is at 0
function TimerGauge:update(skipHook)
  local time = self:getTime()
  local caption = self.timerCaption or ""
  local text = (self.showTime and string.format("%.1f %s", time, caption)) or caption
  self:setValue(time, self.time, text)
  if time == 0 then
    self:stop(self.autoHide)
    resetStopWatch(self.stopWatchName)
    if not skipHook then self:executeHook() end
  end
end

--- Sets the amount of time the timer will run for
-- @tparam number time how long in seconds the timer should run for
function TimerGauge:setTime(time)
  local timetype = type(time)
  if timetype ~= "number" then
    local err = string.format("TimerGauge:setTime(time): time as number expected, got %s", timetype)
    debugc(err)
    return nil, err
  end
  time = math.abs(time)
  if time == 0 then
    local err = "TimerGauge:setTime(time): you cannot pass in 0 as the max time for the timer"
    debugc(err)
    return nil, err
  end
  local currentTime = self:getTime()
  self.time = time
  if time < currentTime then
    self:reset()
  else
    self:update()
  end
end

TimerGauge.parent = Geyser.Gauge
setmetatable(TimerGauge, Geyser.Gauge)

function TimerGauge:new(cons, parent)
  -- type checking and error handling
  local consType = type(cons)
  if consType ~= "table" then
    local err = string.format("TimerGauge:new(options, parent): options must be provided as a table, received: %s", consType)
    debugc(err)
    return nil, err
  end
  local timetype = type(cons.time)
  local time = tonumber(cons.time)
  if not time then
    local err = string.format("TimerGauge:new(options, parent): options table must include a time entry, which must be a number. We received: %s which is type: %s", cons.time or tostring(cons.time), timetype)
    debugc(err)
    return nil, err
  end
  cons.time = math.abs(time)
  if cons.time == 0 then
    local err = "TimerGauge:new(options, parent): time entry in options table must be non-0"
    debugc(err)
    return nil, err
  end

  -- call parent constructor
  local me = self.parent:new(cons, parent)
  -- add TimerGauge as the metatable/index
  setmetatable(me, self)
  self.__index = self

  -- apply any styling requested
  if me.cssFront then
    if not me.cssBack then
      me.cssBack = me.cssFront .. "background-color: black;"
    end
    me:setStyleSheet(me.cssFront, me.cssBack, me.cssText)
  end

  -- create and reset the driving stopwatch
  me.stopWatchName = me.name .. "_timergauge"
  createStopWatch(me.stopWatchName)
  me:reset()

  -- start it up?
  if me.active then
    me:start()
  end
  me:update()
  return me
end

return TimerGauge
