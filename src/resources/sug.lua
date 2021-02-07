--- Self Updating Gauge, extends <a href="https://www.mudlet.org/geyser/files/geyser/GeyserGauge.html">Geyser.Gauge</a>
--@classmod SUG
--@author Damian Monogue <demonnic@gmail.com>
--@copyright 2020 Damian Monogue
--@license MIT, see LICENSE.lua

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

-- ========== Copied from demontools.lua in order to cut the dependency for just this small functionality ==========
-- internal function, recursively digs for a value within subtables if possible
local function digForValue(dataFrom, tableTo)
  if digForValue == nil or table.size(tableTo) == 0 then
    return dataFrom
  else
    local newData = dataFrom[tableTo[1]]
    table.remove(tableTo, 1)
    return digForValue(newData, tableTo)
  end
end

-- Internal function, used to turn a string variable name into a value
local function getValueAt(accessString)
  if accessString == "" then return nil end
  local tempTable = accessString:split("%.")
  local accessTable = {}
  for i,v in ipairs(tempTable) do
    if tonumber(v) then
      accessTable[i] = tonumber(v)
    else
      accessTable[i] = v
    end
  end
  return digForValue(_G, accessTable)
end

-- ========== End section copied from demontools.lua

--- Creates a new Self Updating Gauge.
--@tparam table cons table of options which control the Gauge's behaviour. In addition to all valid contraints for Geyser.Gauge, SUG adds:
--<br>
--<table class="tg">
--<tr>
--  <th>name</th>
--  <th>description</th>
--  <th>default</th>
--</tr>
--<tr>
--  <td class="tg-odd">active</td>
--  <td class="tg-odd">boolean, if true starts the timer updating</td>
--  <td class="tg-odd">true</td>
--</tr>
--<tr>
--  <td class="tg-even">updateTime</td>
--  <td class="tg-even">How often should the gauge autoupdate? Milliseconds</td>
--  <td class="tg-even">333</td>
--</tr>
--<tr>
--  <td class="tg-odd">currentVariable</td>
--  <td class="tg-odd">What variable will hold the 'current' value of the gauge? Pass the name as a string, IE "currentHP" or "gmcp.Char.Vitals.hp"</td>
--  <td class="tg-odd">""</td>
--</tr>
--<tr>
--  <td class="tg-even">maxVariable</td>
--  <td class="tg-even">What variable will hold the 'current' value of the gauge? Pass the name as a string, IE "maxHP" or "gmcp.Char.Vitals.maxhp"</td>
--  <td class="tg-even">""</td>
--</tr>
--<tr>
--  <td class="tg-odd">textTemplate</td>
--  <td class="tg-odd">Template to use for the text on the gauge. "|c" replaced with current value, "|m" replaced with max value, "|p" replaced with the % full the gauge should be</td>
--  <td class="tg-odd">" |c/|m |p%"</td>
--</tr>
--<tr>
--  <td class="tg-even">defaultCurrent</td>
--  <td class="tg-even">What value to use if the currentVariable points to nil or something which cannot be made a number?</td>
--  <td class="tg-even">50</td>
--</tr>
--<tr>
--  <td class="tg-odd">defaultMax</td>
--  <td class="tg-odd">What value to use if the maxVariable points to nil or something which cannot be made a number?</td>
--  <td class="tg-odd">100</td>
--</tr>
--</table>
--@param container The Geyser container for this gauge
--@usage local SUG = require("MDK-1.sug") --the following will watch "gmcp.Char.Vitals.hp" and "gmcp.Char.Vitals.maxhp" and update itself every 333 milliseconds
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
  if me.active then me:start() end
  return me
end

--- Set the name of the variable the Self Updating Gauge watches for the 'current' value of the gauge
--@tparam string variableName The name of the variable to get the current value for the gauge. For instance "currentHP", "gmcp.Char.Vitals.hp" etc
function SUG:setCurrentVariable(variableName)
  local nameType = type(variableName)
  local funcName = "SUG:setCurrentVariable(variableName)"
  assert(nameType == "string", string.format("%s: variableName as string expected, got: %s",funcName, nameType))
  local val = getValueAt(variableName)
  local valType = type(tonumber(val))
  assert(valType == "number", string.format("%s: variableName must point to a variable which is a number or coercable into one. %s points to a %s", funcName, variableName, type(val)))
  self.currentVariable = variableName
  self:update()
end

--- Set the name of the variable the Self Updating Gauge watches for the 'max' value of the gauge
--@tparam string variableName The name of the variable to get the max value for the gauge. For instance "maxHP", "gmcp.Char.Vitals.maxhp" etc. Set to "" to only check the current value
function SUG:setMaxVariable(variableName)
  if variableName == "" then
    self.maxVariable = variableName
    self:update()
    return
  end
  local nameType = type(variableName)
  local funcName = "SUG:setMaxVariable(variableName)"
  assert(nameType == "string", string.format("%s: variableName as string expected, got: %s",funcName, nameType))
  local val = getValueAt(variableName)
  local valType = type(tonumber(val))
  assert(valType == "number", string.format("%s: variableName must point to a variable which is a number or coercable into one. %s points to a %s", funcName, variableName, type(val)))
  self.maxVariable = variableName
  self:update()
end

--- Set the template for the Self Updating Gauge to set the text with. "|c" is replaced by the current value, "|m" is replaced by the max value, and "|p" is replaced by the percentage current/max
--@tparam string template The template to use for the text on the gauge. If the max value is 200 and current is 68, then |c will be replace by 68, |m replaced by 200, and |p replaced by 34.
function SUG:setTextTemplate(template)
  local templateType = type(template)
  local funcName = "SUG:setTextTemplate(template)"
  assert(templateType == "string", string.format("%s: template as string expected, got %s", funcName, templateType))
  self.textTemplate = template
  self:update()
end

--- Stops the Self Updating Gauge from updating
function SUG:stop()
  self.active = false
  if self.timer then
    killTimer(self.timer)
    self.timer = nil
  end
end

--- Starts the Self Updating Gauge updating. If it is already updating, it will restart it.
function SUG:start()
  SUG:stop()
  self.active = true
  self.timer = tempTimer(self.updateTime / 1000, function() self:update() end, true)
end

--- Reads the values from currentVariable and maxVariable, and updates the gauge's value and text.
function SUG:update()
  local current = getValueAt(self.currentVariable)
  local max = getValueAt(self.maxVariable)
  current = tonumber(current)
  max = tonumber(max)
  if current == nil then
    current = self.defaultCurrent
    debugc(string.format("Self Updating Gauge named %s is trying to update with an invalid current value. Using the defaultCurrent instead. currentVariable: '%s' maxVariable: '%s'", self.name, self.currentVariable, self.maxVariable))
  end
  if max == nil then
    max = self.defaultMax
    if self.maxVariable ~= "" then
      debugc(string.format("Self Updating Gauge named %s is trying to update with an invalid max value. Using the defaultCurrent instead. currentVariable: '%s' maxVariable: '%s'", self.name, self.currentVariable, self.maxVariable))
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
