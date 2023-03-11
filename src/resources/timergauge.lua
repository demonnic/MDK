--- Animated countdown timer, extends <a href="https://www.mudlet.org/geyser/files/geyser/GeyserGauge.html">Geyser.Gauge</a>
-- @classmod TimerGauge
-- @author Damian Monogue <demonnic@gmail.com>
-- @copyright 2020 Damian Monogue
-- @license MIT, see LICENSE.lua
local TimerGauge = {
  name = "TimerGaugeClass",
  active = true,
  showTime = true,
  prefix = "",
  timeFormat = "S.t",
  suffix = "",
  updateTime = "10",
  autoHide = true,
  autoShow = true,
  manageContainer = false,
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
  -- self.gauge:setStyleSheet(cssFront, cssBack, cssText)
  self.cssFront = cssFront
  self.cssBack = cssBack
  self.cssText = cssText
end

--- Shows the TimerGauge. If the manageContainer property is true, then will add it back to its container
function TimerGauge:show2()
  if self.manageContainer and self.savedContainer then
    self.savedContainer:add(self)
    self.savedContainer = nil
  end
  self:show()
end

--- Hides the TimerGauge. If manageContainer property is true, then it will remove it from its container and if the container is an HBox or VBox it will initiate size/position management
function TimerGauge:hide2()
  if self.manageContainer and self.container.name ~= Geyser.name then
    self.savedContainer = self.container
    Geyser:add(self)
    self.savedContainer:remove(self)
    if self.savedContainer.type == "VBox" or self.savedContainer.type == "HBox" then
      if self.savedContainer.organize then
        self.savedContainer:organize()
      else
        self.savedContainer:reposition()
      end
    end
  end
  self:hide()
end

--- Starts the timergauge. Works whether the timer is stopped or not. Does not start a timer which is already at 0
-- @tparam[opt] boolean show override the autoShow property. True will always show, false will never show.
-- @usage myTimerGauge:start() --starts the timer, will show or not based on autoShow property
-- myTimerGauge:start(false) --starts the timer, will not change hidden status, regardless of autoShow property
-- myTimerGauge:start(true) --starts the timer, will show it regardless of autoShow property
function TimerGauge:start(show)
  if show == nil then
    show = self.autoShow
  end
  self.active = true
  if self.timer then
    killTimer(self.timer)
    self.timer = nil
  end
  startStopWatch(self.stopWatchName)
  self:update()
  self.timer = tempTimer(self.updateTime / 1000, function()
    self:update()
  end, true)
  if show then
    self:show2()
  end
end

--- Stops the timergauge. Works whether the timer is started or not.
-- @tparam[opt] boolean hide override the autoHide property. True will always hide, false will never hide.
-- @usage myTimerGauge:stop() --stops the timer, will hide or not based on autoHide property
-- myTimerGauge:stop(false) --stops the timer, will not change hidden status, regardless of autoHide property
-- myTimerGauge:stop(true) --stops the timer, will hide it regardless of autoHide property
function TimerGauge:stop(hide)
  if hide == nil then
    hide = self.autoHide
  end
  self.active = false
  if self.timer then
    killTimer(self.timer)
    self.timer = nil
  end
  stopStopWatch(self.stopWatchName)
  if hide then
    self:hide2()
  end
end

--- Alias for stop.
-- @tparam[opt] boolean hide override the autoHide property. True will always hide, false will never hide.
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
-- @tparam[opt] boolean show override the autoShow property. true will always show, false will never show
-- @usage myTimerGauge:restart() --restarts the timer, will show or not based on autoShow property
-- myTimerGauge:restart(false) --restarts the timer, will not change hidden status, regardless of autoShow property
-- myTimerGauge:restart(true) --restarts the timer, will show it regardless of autoShow property
function TimerGauge:restart(show)
  self:reset()
  self:start(show)
end

--- Get the amount of time remaining on the timer, in seconds
-- @tparam string format Format string for how to return the time. If not provided defaults to self.timeFormat(which defaults to "S.t").<br>
--                      If "" is passed will return "" as the time. See below table for formatting codes<br>
-- <table class="tg">
-- <tr>
--  <th>format code</th>
--  <th>what it is replaced with</th>
-- </tr>
-- <tr>
--  <td class="tg-1">S</td>
--  <td class="tg-1">Time left in seconds, unbroken down. Does not include milliseconds.<br>
--      IE a timer with 2 minutes left it would replace S with 120
--  </td>
-- </tr>
-- <tr>
--  <td class="tg-2">dd</td>
--  <td class="tg-2">Days, with 1 leading 0 (0, 01, 02-...)</td>
-- </tr>
-- <tr>
--  <td class="tg-1">d</td>
--  <td class="tg-1">Days, with no leading 0 (1,2,3-...)</td>
-- </tr>
-- <tr>
--  <td class="tg-2">hh</td>
--  <td class="tg-2">hours, with leading 0 (00-24)</td>
-- </tr>
-- <tr>
--  <td class="tg-1">h</td>
--  <td class="tg-1">hours, without leading 0 (0-24)</td>
-- </tr>
-- <tr>
--  <td class="tg-2">MM</td>
--  <td class="tg-2">minutes, with a leading 0 (00-59)</td>
-- </tr>
-- <tr>
--  <td class="tg-1">M</td>
--  <td class="tg-1">minutes, no leading 0 (0-59)</td>
-- </tr>
-- <tr>
--  <td class="tg-2">ss</td>
--  <td class="tg-2">seconds, with leading 0 (00-59)</td>
-- </tr>
-- <tr>
--  <td class="tg-1">s</td>
--  <td class="tg-1">seconds, no leading 0 (0-59)</td>
-- </tr>
-- <tr>
--  <td class="tg-2">t</td>
--  <td class="tg-2">tenths of a second<br>
--      timer with 12.345 seconds left, t would<br>
--      br replaced by 3.
--  </td>
-- </tr>
-- <tr>
--  <td class="tg-1">mm</td>
--  <td class="tg-1">milliseconds with leadings 0s (000-999)</td>
-- </tr>
-- <tr>
--  <td class="tg-2">m</td>
--  <td class="tg-2">milliseconds with no leading 0s (0-999)</td>
-- </tr>
-- </table><br>
-- @usage myTimerGauge:getTime() --returns the time using myTimerGauge.format
-- myTimerGauge:getTime("hh:MM:ss") --returns the time as hours, minutes, and seconds, with leading 0s (01:23:04)
-- myTimerGauge:getTime("S.mm") --returns the time as the total number of seconds, including milliseconds (114.004)
function TimerGauge:getTime(format)
  format = format or self.timeFormat
  local time = getStopWatchTime(self.stopWatchName)
  local timerTable = getStopWatchBrokenDownTime(self.stopWatchName)
  if time > 0 then
    self:stop(self.autoHide)
    resetStopWatch(self.stopWatchName)
    time = getStopWatchTime(self.stopWatchName)
    timerTable = getStopWatchBrokenDownTime(self.stopWatchName)
    self.active = false
  end
  if format == "" then
    return format
  end
  local totalSeconds = string.split(math.abs(time), "%.")[1]
  local tenths = string.sub(string.format("%03d", timerTable.milliSeconds), 1, 1)
  format = format:gsub("S", totalSeconds)
  format = format:gsub("t", tenths)
  format = format:gsub("mm", string.format("%03d", timerTable.milliSeconds))
  format = format:gsub("m", timerTable.milliSeconds)
  format = format:gsub("MM", string.format("%02d", timerTable.minutes))
  format = format:gsub("M", timerTable.minutes)
  format = format:gsub("dd", string.format("%02d", timerTable.days))
  format = format:gsub("d", timerTable.days)
  format = format:gsub("ss", string.format("%02d", timerTable.seconds))
  format = format:gsub("s", timerTable.seconds)
  format = format:gsub("hh", string.format("%02d", timerTable.hours))
  format = format:gsub("h", timerTable.hours)
  return format
end

-- Execute the timer's hook, if there is one. Internal function
function TimerGauge:executeHook()
  local hook = self.hook
  if not hook then
    return
  end
  local hooktype = type(hook)
  if hooktype == "string" then
    local f, e = loadstring("return " .. hook)
    if not f then
      f, e = loadstring(hook)
    end
    if not f then
      debugc(string.format("TimerGauge encountered an error while executing the hook for TimerGauge with name: %s error: %s", self.name, tostring(e)))
      return
    end
    hook = f
  end
  hooktype = type(hook)
  if hooktype ~= "function" then
    debugc(string.format(
             "TimerGauge with name: %s was given a hook which is neither a function nor a string which can be made into one. Provided type was %s",
             self.name, hooktype))
    return
  end
  local worked, err = pcall(hook)
  if not worked then
    debugc(string.format("TimerGauge named %s encountered the following error while executing its hook: %s", self.name, err))
  end
end

--- Sets the timer's remaining time to 0, stops it, and executes the hook if one exists.
-- @tparam[opt] boolean skipHook use true to have it set the timer to 0 and stop, but not execute the hook.
-- @usage myTimerGauge:finish() --executes the hook if it has one
-- myTimerGauge:finish(false) --will not execute the hook
function TimerGauge:finish(skipHook)
  resetStopWatch(self.stopWatchName)
  self:update(skipHook)
end

-- Internal function, no ldoc
-- Updates the gauge based on time remaining.
-- @tparam[opt] boolean skipHook use true if you do not want to execute the hook if the timer is at 0.
function TimerGauge:update(skipHook)
  local time = self.showTime and self:getTime(self.timeFormat) or ""
  local current = tonumber(self:getTime("S.mm"))
  local suffix = self.suffix or ""
  local prefix = self.prefix or ""
  local text = string.format("%s%s%s", prefix, time, suffix)
  self:setValue(current, self.time, text)
  if current == 0 then
    if self.timer then
      killTimer(self.timer)
      self.timer = nil
    end
    if not skipHook then
      self:executeHook()
    end
  end
end

--- Sets the amount of time the timer will run for. Make sure to call :reset() or :restart() 
-- if you want to cause the timer to run for that amount of time. If you set it to a time lower
-- than the time left on the timer currently, it will reset the current time, otherwise it is left alone
-- @tparam number time how long in seconds the timer should run for
-- @usage myTimerGauge:setTime(50) -- sets myTimerGauge's max time to 50.
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
  local currentTime = tonumber(self:getTime("S.t"))
  self.time = time
  if time < currentTime then
    self:reset()
  else
    self:update(currentTime == 0)
  end
end

--- Changes the time between gauge updates.
-- @tparam number updateTime amount of time in milliseconds between gauge updates. Must be a positive number.
function TimerGauge:setUpdateTime(updateTime)
  local updateTimeType = type(updateTime)
  assert(updateTimeType == "number",
         string.format("TimerGauge:setUpdateTime(updateTime): name: %s updateTime as number expected, got %s", self.name, updateTimeType))
  assert(updateTime > 0,
         string.format("TimerGauge:setUpdateTime(updateTime): name: %s updateTime must be a positive number. You gave %d", self.name, updateTime))
  self.updateTime = updateTime
  if self.timer then
    killTimer(self.timer)
    self.timer = nil
  end
  if self.active then
    self.timer = tempTimer(updateTime / 1000, function()
      self:update()
    end, true)
  end
end

TimerGauge.parent = Geyser.Gauge
setmetatable(TimerGauge, Geyser.Gauge)
--- Creates a new TimerGauge instance.
-- @tparam table cons a table of options (or constraints) for how the TimerGauge will behave. Valid options include:
-- <br>
-- <table class="tg">
-- <tr>
--  <th>name</th>
--  <th>description</th>
--  <th>default</th>
-- </tr>
-- <tr>
--  <td class="tg-1">time</td>
--  <td class="tg-1">how long the timer should run for</td>
--  <td class="tg-1"></td>
-- </tr>
-- <tr>
--  <td class="tg-2">active</td>
--  <td class="tg-2">whether the timer should run or not</td>
--  <td class="tg-2">true</td>
-- </tr>
-- <tr>
--  <td class="tg-1">showTime</td>
--  <td class="tg-1">should we show the time remaining on the gauge?</td>
--  <td class="tg-1">true</td>
-- </tr>
-- <tr>
--  <td class="tg-2">prefix</td>
--  <td class="tg-2">text you want shown before the time.</td>
--  <td class="tg-2">""</td>
-- </tr>
-- <tr>
--  <td class="tg-1">suffix</td>
--  <td class="tg-1">text you want shown after the time.</td>
--  <td class="tg-1">""</td>
-- </tr>
-- <tr>
--  <td class="tg-2">timerCaption</td>
--  <td class="tg-2">Alias for suffix. Deprecated and may be remove in the future</td>
--  <td class="tg-2"/>
-- </tr>
-- <tr>
--  <td class="tg-1">updateTime</td>
--  <td class="tg-1">number of milliseconds between gauge updates.</td>
--  <td class="tg-1">10</td>
-- </tr>
-- <tr>
--  <td class="tg-2">autoHide</td>
--  <td class="tg-2">should the timer :hide() itself when it runs out/you stop it?</td>
--  <td class="tg-2">true</td>
-- </tr>
-- <tr>
--  <td class="tg-1">autoShow</td>
--  <td class="tg-1">should the timer :show() itself when you start it?</td>
--  <td class="tg-1">true</td>
-- </tr>
-- <tr>
--  <td class="tg-2">manageContainer</td>
--  <td class="tg-2">should the timer remove itself from its container when you call <br>:hide() and add itself back when you call :show()?</td>
--  <td class="tg-2">false</td>
-- </tr>
-- <tr>
--  <td class="tg-1">timeFormat</td>
--  <td class="tg-1">how should the time be displayed/returned if you call :getTime()? <br>See table below for more information</td>
--  <td class="tg-1">"S.t"</td>
-- </tr>
-- </table>
-- <br>Table of time format options
-- <table class="tg">
-- <tr>
--  <th>format code</th>
--  <th>what it is replaced with</th>
-- </tr>
-- <tr>
--  <td class="tg-1">S</td>
--  <td class="tg-1">Time left in seconds, unbroken down. Does not include milliseconds.<br>
--      IE a timer with 2 minutes left it would replace S with 120
--  </td>
-- </tr>
-- <tr>
--  <td class="tg-2">dd</td>
--  <td class="tg-2">Days, with 1 leading 0 (0, 01, 02-...)</td>
-- </tr>
-- <tr>
--  <td class="tg-1">d</td>
--  <td class="tg-1">Days, with no leading 0 (1,2,3-...)</td>
-- </tr>
-- <tr>
--  <td class="tg-2">hh</td>
--  <td class="tg-2">hours, with leading 0 (00-24)</td>
-- </tr>
-- <tr>
--  <td class="tg-1">h</td>
--  <td class="tg-1">hours, without leading 0 (0-24)</td>
-- </tr>
-- <tr>
--  <td class="tg-2">MM</td>
--  <td class="tg-2">minutes, with a leading 0 (00-59)</td>
-- </tr>
-- <tr>
--  <td class="tg-1">M</td>
--  <td class="tg-1">minutes, no leading 0 (0-59)</td>
-- </tr>
-- <tr>
--  <td class="tg-2">ss</td>
--  <td class="tg-2">seconds, with leading 0 (00-59)</td>
-- </tr>
-- <tr>
--  <td class="tg-1">s</td>
--  <td class="tg-1">seconds, no leading 0 (0-59)</td>
-- </tr>
-- <tr>
--  <td class="tg-2">t</td>
--  <td class="tg-2">tenths of a second<br>
--      timer with 12.345 seconds left, t would<br>
--      br replaced by 3.
--  </td>
-- </tr>
-- <tr>
--  <td class="tg-1">mm</td>
--  <td class="tg-1">milliseconds with leadings 0s (000-999)</td>
-- </tr>
-- <tr>
--  <td class="tg-2">m</td>
--  <td class="tg-2">milliseconds with no leading 0s (0-999)</td>
-- </tr>
-- </table><br>
-- @param parent The Geyser parent for this TimerGauge
-- @usage
-- local TimerGauge = require("MDK.timergauge")
-- myTimerGauge = TimerGauge:new({
--   name = "testGauge",
--   x = 100,
--   y = 100,
--   height = 40,
--   width = 200,
--   time = 10
-- })
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
    local err = string.format(
                  "TimerGauge:new(options, parent): options table must include a time entry, which must be a number. We received: %s which is type: %s",
                  cons.time or tostring(cons.time), timetype)
    debugc(err)
    return nil, err
  end
  cons.time = math.abs(time)
  if cons.time == 0 then
    local err = "TimerGauge:new(options, parent): time entry in options table must be non-0"
    debugc(err)
    return nil, err
  end

  if cons.timerCaption and (not cons.suffix) then
    cons.suffix = cons.timerCaption
  end
  cons.type = cons.type or "timergauge"
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
