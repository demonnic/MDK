--- Self Updating Gauge, extends <a href="https://www.mudlet.org/geyser/files/geyser/GeyserGauge.html">Geyser.Gauge</a>
-- @classmod SUG
-- @author Damian Monogue <demonnic@gmail.com>
-- @copyright 2020 Damian Monogue
-- @license MIT, see LICENSE.lua
local SUG = {
  name = "SelfUpdatingGaugeClass",
  active = true,
  updateTime = 333,
  currentVariable = "",
  maxVariable = "",
  defaultCurrent = 50,
  defaultMax = 100,
  textTemplate = " |c/|m |p%",
  strict = true,
}

-- Internal function, used to turn a string variable name into a value
local function getValueAt(accessString)
  local ok, err = pcall(loadstring("return " .. tostring(accessString)))
  if ok then return err end
  return nil, err
end

-- ========== End section copied from demontools.lua

--- Creates a new Self Updating Gauge.
-- @tparam table cons table of options which control the Gauge's behaviour. In addition to all valid contraints for Geyser.Gauge, SUG adds:
-- <br>
-- <table class="tg">
-- <tr>
--  <th>name</th>
--  <th>description</th>
--  <th>default</th>
-- </tr>
-- <tr>
--  <td class="tg-1">active</td>
--  <td class="tg-1">boolean, if true starts the timer updating</td>
--  <td class="tg-1">true</td>
-- </tr>
-- <tr>
--  <td class="tg-2">updateTime</td>
--  <td class="tg-2">How often should the gauge autoupdate? Milliseconds. 0 to disable the timer but still allow event updates</td>
--  <td class="tg-2">333</td>
-- </tr>
-- <tr>
--  <td class="tg-1">currentVariable</td>
--  <td class="tg-1">What variable will hold the 'current' value of the gauge? Pass the name as a string, IE "currentHP" or "gmcp.Char.Vitals.hp"</td>
--  <td class="tg-1">""</td>
-- </tr>
-- <tr>
--  <td class="tg-2">maxVariable</td>
--  <td class="tg-2">What variable will hold the 'current' value of the gauge? Pass the name as a string, IE "maxHP" or "gmcp.Char.Vitals.maxhp"</td>
--  <td class="tg-2">""</td>
-- </tr>
-- <tr>
--  <td class="tg-1">textTemplate</td>
--  <td class="tg-1">Template to use for the text on the gauge. "|c" replaced with current value, "|m" replaced with max value, "|p" replaced with the % full the gauge should be</td>
--  <td class="tg-1">" |c/|m |p%"</td>
-- </tr>
-- <tr>
--  <td class="tg-2">defaultCurrent</td>
--  <td class="tg-2">What value to use if the currentVariable points to nil or something which cannot be made a number?</td>
--  <td class="tg-2">50</td>
-- </tr>
-- <tr>
--  <td class="tg-1">defaultMax</td>
--  <td class="tg-1">What value to use if the maxVariable points to nil or something which cannot be made a number?</td>
--  <td class="tg-1">100</td>
-- </tr>
-- <tr>
--  <td class="tg-2">updateEvent</td>
--  <td class="tg-2">The name of an event to listen for to perform an update. Can be run alongside or instead of the timer updates. Empty string to turn off</td>
--  <td class="tg-2">""</td>
-- </tr>
-- <tr>
--  <td class="tg-1">updateHook</td>
--  <td class="tg-1">A function which is run each time the gauge updates. Should take 3 arguments, the gauge itself, current value, and max value. You can return new current and max values to be used, for example `return 34, 120` would cause the gauge to use 34 for current and 120 for max regardless of what the variables it reads say.</td>
--  <td class="tg-1"></td>
-- </tr>
-- </table>
-- @param container The Geyser container for this gauge
-- @usage
-- local SUG = require("MDK.sug") --the following will watch "gmcp.Char.Vitals.hp" and "gmcp.Char.Vitals.maxhp" and update itself every 333 milliseconds
-- myGauge = SUG:new({
--   name = "myGauge",
--   currentVariable = "gmcp.Char.Vitals.hp", --if this is nil, it will use the defaultCurrent of 50
--   maxVariable = "gmcp.Char.Vitals.maxhp",  --if this is nil, it will use the defaultMax of 100.
--   height = 50,
-- })
function SUG:new(cons, container)
  local funcName = "SUG:new(cons, container)"
  cons = cons or {}
  local consType = type(cons)
  assert(consType == "table", string.format("%s: cons as table expected, got %s", funcName, consType))
  local me = SUG.parent:new(cons, container)
  setmetatable(me, self)
  self.__index = self
  -- apply any styling requested
  if me.cssFront then
    if not me.cssBack then
      me.cssBack = me.cssFront .. "background-color: black;"
    end
    me:setStyleSheet(me.cssFront, me.cssBack, me.cssText)
  end
  if me.active then
    me:start()
  end
  me:update()
  return me
end

--- Set how often to update the gauge on a timer
-- @tparam number time time in milliseconds. 0 to disable the timer
function SUG:setUpdateTime(time)
  if type(time) ~= "number" then
    debugc("SUG:setUpdateTime(time) time as number expected, got " .. type(time))
    return
  end
  self.updateTime = time
  if self.active then self:start() end
end

--- Set the event to listen for to update the gauge
-- @tparam string event the name of the event to listen for, use "" to disable events without stopping any existing timers
function SUG:setUpdateEvent(event)
  if type(event) ~= string then
    debugc("SUG:setUpdateEvent(event) event name as string expected, got " .. type(event))
    return
  end
  self.updateEvent = event
  if self.active then self:start() end
end

--- Set the name of the variable the Self Updating Gauge watches for the 'current' value of the gauge
-- @tparam string variableName The name of the variable to get the current value for the gauge. For instance "currentHP", "gmcp.Char.Vitals.hp" etc
function SUG:setCurrentVariable(variableName)
  local nameType = type(variableName)
  local funcName = "SUG:setCurrentVariable(variableName)"
  assert(nameType == "string", string.format("%s: variableName as string expected, got: %s", funcName, nameType))
  local val = getValueAt(variableName)
  local valType = type(tonumber(val))
  assert(valType == "number",
         string.format("%s: variableName must point to a variable which is a number or coercable into one. %s points to a %s", funcName, variableName,
                       type(val)))
  self.currentVariable = variableName
  self:update()
end

--- Set the name of the variable the Self Updating Gauge watches for the 'max' value of the gauge
-- @tparam string variableName The name of the variable to get the max value for the gauge. For instance "maxHP", "gmcp.Char.Vitals.maxhp" etc. Set to "" to only check the current value
function SUG:setMaxVariable(variableName)
  if variableName == "" then
    self.maxVariable = variableName
    self:update()
    return
  end
  local nameType = type(variableName)
  local funcName = "SUG:setMaxVariable(variableName)"
  assert(nameType == "string", string.format("%s: variableName as string expected, got: %s", funcName, nameType))
  local val = getValueAt(variableName)
  local valType = type(tonumber(val))
  assert(valType == "number",
         string.format("%s: variableName must point to a variable which is a number or coercable into one. %s points to a %s", funcName, variableName,
                       type(val)))
  self.maxVariable = variableName
  self:update()
end

--- Set the template for the Self Updating Gauge to set the text with. "|c" is replaced by the current value, "|m" is replaced by the max value, and "|p" is replaced by the percentage current/max
-- @tparam string template The template to use for the text on the gauge. If the max value is 200 and current is 68, then |c will be replace by 68, |m replaced by 200, and |p replaced by 34.
function SUG:setTextTemplate(template)
  local templateType = type(template)
  local funcName = "SUG:setTextTemplate(template)"
  assert(templateType == "string", string.format("%s: template as string expected, got %s", funcName, templateType))
  self.textTemplate = template
  self:update()
end

--- Set the updateHook function which is run just prior to the gauge updating
-- @tparam function func The function which will be called when the gauge updates. It should take 3 arguments, the gauge itself, the current value, and the max value. If you wish to override the current or max values used for the gauge, you can return new current and max values, like `return newCurrent newMax`
function SUG:setUpdateHook(func)
  local funcType = type(func)
  if funcType ~= "function" then
    return nil, "setUpdateHook only takes functions, no strings or anything like that. You passed in: " .. funcType
  end
  self.updateHook = func
end

--- Stops the Self Updating Gauge from updating
function SUG:stop()
  self.active = false
  if self.timer then
    killTimer(self.timer)
    self.timer = nil
  end
  if self.eventHandler then
    killAnonymousEventHandler(self.eventHandler)
    self.eventHandler = nil
  end
end

--- Starts the Self Updating Gauge updating. If it is already updating, it will restart it.
function SUG:start()
  self:stop()
  self.active = true
  local update = function() self:update() end
  if self.updateTime > 0 then
    self.timer = tempTimer(self.updateTime / 1000, update, true)
  end
  local updateEvent = self.updateEvent
  if updateEvent and updateEvent ~= "" and updateEvent ~= "*" then
    self.eventHandler = registerAnonymousEventHandler(self.updateEvent, update)
  end
end

--- Reads the values from currentVariable and maxVariable, and updates the gauge's value and text.
function SUG:update()
  local current = getValueAt(self.currentVariable)
  local max = getValueAt(self.maxVariable)
  current = tonumber(current)
  max = tonumber(max)
  if current == nil then
    current = self.defaultCurrent
    debugc(string.format(
             "Self Updating Gauge named %s is trying to update with an invalid current value. Using the defaultCurrent instead. currentVariable: '%s' maxVariable: '%s'",
             self.name, self.currentVariable, self.maxVariable))
  end
  if max == nil then
    max = self.defaultMax
    if self.maxVariable ~= "" then
      debugc(string.format(
               "Self Updating Gauge named %s is trying to update with an invalid max value. Using the defaultCurrent instead. currentVariable: '%s' maxVariable: '%s'",
               self.name, self.currentVariable, self.maxVariable))
    end
  end
  if self.updateHook and type(self.updateHook) == "function" then
    local ok, newcur, newmax = pcall(self.updateHook, self, current, max)
    if ok and newcur then
      current = newcur
      max = newmax and newmax or self.defaultMax
    end
  end
  local text = self.textTemplate
  local percent = math.floor((current / max * 100) + 0.5)
  text = text:gsub("|c", current)
  text = text:gsub("|m", max)
  text = text:gsub("|p", percent)
  self:setValue(current, max, text)
end

SUG.parent = Geyser.Gauge
setmetatable(SUG, Geyser.Gauge)

return SUG
