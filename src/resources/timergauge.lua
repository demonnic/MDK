local TimerGauge = Geyser.Container:new({
  name = "TimerGaugeClass",
  active = true,
  showTime = true,
  timerCaption = "",
  updateTime = "10",
  autoHide = true,
})

function TimerGauge:setStyleSheet(cssFront, cssBack, cssText)
  cssFront = cssFront or self.cssFront
  cssBack = cssBack or self.cssBack
  cssBack = cssBack or self.cssFront .. "background-color: black;"
  cssText = cssText or self.cssText
  self.gauge:setStyleSheet(cssFront, cssBack, cssText)
  self.cssFront = cssFront
  self.cssBack = cssBack
  self.cssText = cssText
end

function TimerGauge:start(show)
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

function TimerGauge:stop(hide)
  if not self.active then return end
  self.active = false
  if self.timer then
    killTimer(self.timer)
    self.timer = nil
  end
  stopStopWatch(self.stopWatchName)
  if hide then self:hide() end
end

function TimerGauge:pause(hide)
  self:stop(hide)
end

function TimerGauge:reset(show)
  resetStopWatch(self.stopWatchName)
  adjustStopWatch(self.stopWatchName, self.time * -1)
  if show then self:show() end
end

function TimerGauge:restart(show)
  self:reset()
  self:start(show)
end

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

function TimerGauge:executeHook()
  local hook = self.hook
  if not hook then return end
  local hooktype = type(hook)
  if hooktype == "string" then
    local f,e = loadstring("return " .. hook)
    if not f then
      f,e = loadstring(hook)
    end
    assert(f, string.format("TimerGauge encountered an error while executing the hook for TimerGauge with name: %s error: %s", self.name, tostring(e)))
    hook = f
  end
  hooktype = type(hook)
  assert(hooktype == "function", string.format("TimerGauge with name: %s was given a hook which is neither a function nor a string which can be made into one. Provided type was %s", self.name, hooktype))
  local worked, err = pcall(hook)
  if not worked then
    error(string.format("TimerGauge named %s encountered the following error while executing its hook: %s", self.name, err))
  end
end

function TimerGauge:setToolTip(...)
  self.gauge:setToolTip(...)
end

function TimerGauge:setColor(...)
  self.gauge:setColor(...)
end

function TimerGauge:setFormat(...)
  self.gauge:setFormat(...)
end

function TimerGauge:setBold(...)
  self.gauge:setBold(...)
end

function TimerGauge:setItalics(...)
  self.gauge:setItalics(...)
end

function TimerGauge:setUnderline(...)
  self.gauge:setUnderline(...)
end

function TimerGauge:setStrikethrough(...)
  self.gauge:setStrikethrough(...)
end

function TimerGauge:setFontSize(...)
  self.gauge:setFontSize(...)
end

function TimerGauge:setAlignment(...)
  self.gauge:setAlignment(...)
end

function TimerGauge:setFgColor(...)
  self.gauge:setFgColor(...)
end

function TimerGauge:enableClickthrough(...)
  self.gauge:enableClickthrough(...)
end

function TimerGauge:disableClickthrough(...)
  self.gauge:disableClickthrough(...)
end

function TimerGauge:resetToolTip(...)
  self.gauge:resetToolTip(...)
end

function TimerGauge:setValue(...)
  self.gauge:setValue(...)
end

function TimerGauge:update()
  if self.active then
    local time = self:getTime()
    local caption = self.timerCaption or ""
    local text = (self.showTime and string.format("%.1f %s", time, caption)) or caption
    self:setValue(time, self.time, text)
    if time == 0 then
      self:stop(self.autoHide)
      resetStopWatch(self.stopWatchName)
      self:executeHook()
    end
  else
    if self.timer then
      killTimer(self.timer)
      self.timer = nil
    end
  end
end

TimerGauge.parent = Geyser.Gauge

function TimerGauge:new(cons, parent)
  -- type checking and error handling
  local consType = type(cons)
  assert(consType == "table", string.format("TimerGauge:new(options, parent): options must be provided as a table, received: %s", consType))
  local time = tonumber(cons.time)
  assert(time, "TimerGauge:new(options, parent): options table must include a time entry, which must be a number")
  cons.time = math.abs(time)

  -- make a container
  local me = self.parent:new(cons, parent)
  -- add TimerGauge as the metatable/index
  setmetatable(me, self)
  self.__index = self

  -- copy the constraints used for the TimerGauge
  local gaugeCons = table.deepcopy(cons)
  -- adjust some properties since the container has the positioning information
  gaugeCons.x = 0
  gaugeCons.y = 0
  gaugeCons.height = "100%"
  gaugeCons.width = "100%"
  gaugeCons.name = me.name .. "_timergauge"
  -- make the gauge
  me.gauge = Geyser.Gauge:new({
    x = 0,
    y = 0,
    height = "100%",
    width = "100%",
    name = me.name .. "_timergauge"
  }, me)
  -- and apply any styling requested
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
  -- activate?
  if me.active then
    me:start()
  end
  me:update()
  return me
end

return TimerGauge
