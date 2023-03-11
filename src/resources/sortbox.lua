---An H/VBox alternative which can be set to either vertical or horizontal, and will autosort the windows
-- @classmod SortBox
-- @author Damian Monogue <demonnic@gmail.com>
-- @copyright 2020 Damian Monogue
-- @license MIT, see LICENSE.lua
local SortBox = Geyser.Container:new({
  name = "SortBoxClass",
  autoSort = true,
  timerSort = true,
  sortInterval = 500,
  elastic = false,
  maxHeight = 0,
  maxWidth = 0,
  boxType = "v",
  sortFunction = "gaugeValue",
})
local BIGNUMBER = 999999999

--- Sorting functions for spairs, should you wish
-- @table SortFunctions
-- @field gaugeValue sorts Geyser gauges by value, ascending
-- @field reverseGaugeValue sorts Geyser gauges by value, descending
-- @field timeLeft sorts TimerGauges by how much time is left, ascending
-- @field reverseTimeLeft sorts TimerGauges by how much time is left, descending.
-- @field name sorts Geyser objects by name, ascending
-- @field reverseName sorts Geyser objects by name, descending
-- @field message sorts Geyser labels and gauges by their echoed text, ascending
-- @field reverseMessage sorts Geyser labels and gauges by their echoed text, descending
SortBox.SortFunctions = {
  gaugeValue = function(t, a, b)
    local avalue = t[a].value or BIGNUMBER
    local bvalue = t[b].value or BIGNUMBER
    return avalue < bvalue
  end,
  reverseGaugeValue = function(t, a, b)
    local avalue = t[a].value or BIGNUMBER
    local bvalue = t[b].value or BIGNUMBER
    return avalue > bvalue
  end,
  timeLeft = function(t, a, b)
    a = t[a]
    b = t[b]
    local avalue = a.getTime and tonumber(a:getTime("S.mm")) or BIGNUMBER
    local bvalue = b.getTime and tonumber(b:getTime("S.mm")) or BIGNUMBER
    return avalue < bvalue
  end,
  reverseTimeLeft = function(t, a, b)
    a = t[a]
    b = t[b]
    local avalue = a.getTime and tonumber(a:getTime("S.mm")) or BIGNUMBER
    local bvalue = b.getTime and tonumber(b:getTime("S.mm")) or BIGNUMBER
    return avalue > bvalue
  end,
  name = function(t, a, b)
    return t[a].name < t[b].name
  end,
  reverseName = function(t, a, b)
    return t[a].name > t[b].name
  end,
  message = function(t, a, b)
    a = t[a]
    b = t[b]
    local avalue = a.text and a.text.message or a.message
    local bvalue = b.text and b.text.message or b.message
    avalue = avalue or ""
    bvalue = bvalue or ""
    return avalue < bvalue
  end,
  reverseMessage = function(t, a, b)
    a = t[a]
    b = t[b]
    local avalue = a.text and a.text.message or a.message
    local bvalue = b.text and b.text.message or b.message
    avalue = avalue or ""
    bvalue = bvalue or ""
    return avalue > bvalue
  end,
}
--- Creates a new SortBox
-- @usage 
-- local SortBox = require("MDK.sortbox")
-- mySortBox = SortBox:new({
--   name = "mySortBox",
--   x = 400,
--   y = 100,
--   height = 150,
--   width = 300,
--   sortFunction = "timeLeft"
-- })
-- @tparam table options the options to use for the SortBox. See table below for added options
-- @param[opt] container the container to add the SortBox into
-- <br><br>Table of new options
-- <table class="tg">
-- <thead>
--   <tr>
--     <th>option name</th>
--     <th>description</th>
--     <th>default</th>
--   </tr>
-- </thead>
-- <tbody>
--   <tr>
--     <td class="tg-1">autoSort</td>
--     <td class="tg-1">should the SortBox perform function based sorting? If false, will behave like a normal H/VBox</td>
--     <td class="tg-1">true</td>
--   </tr>
--   <tr>
--     <td class="tg-2">timerSort</td>
--     <td class="tg-2">should the SortBox automatically perform sorting on a timer?</td>
--     <td class="tg-2">true</td>
--   </tr>
--   <tr>
--     <td class="tg-1">sortInterval</td>
--     <td class="tg-1">how frequently should we sort on a timer if timerSort is true, in milliseconds</td>
--     <td class="tg-1">500</td>
--   </tr>
--   <tr>
--     <td class="tg-2">boxType</td>
--     <td class="tg-2">Should we stack like an HBox or VBox? use 'h' for hbox and 'v' for vbox</td>
--     <td class="tg-2">v</td>
--   </tr>
--   <tr>
--     <td class="tg-1">sortFunction</td>
--     <td class="tg-1">how should we sort the items in the SortBox? see setSortFunction for valid options</td>
--     <td class="tg-1">gaugeValue</td>
--   </tr>
--   <tr>
--     <td class="tg-2">elastic</td>
--     <td class="tg-2">Should this container stretch to fit its contents? boxType v stretches in height, h stretches in width.</td>
--     <td class="tg-2">false</td>
--   </tr>
--   <tr>
--     <td class="tg-1">maxHeight</td>
--     <td class="tg-1">If elastic, what's the biggest a 'v' style box should grow in height? Use 0 for unlimited</td>
--     <td class="tg-1">0</td>
--   </tr>
--   <tr>
--     <td class="tg-2">maxWidth</td>
--     <td class="tg-2">If elastic, what's the biggest a 'h' style box should grow in width? Use 0 for unlimited</td>
--     <td class="tg-2">0</td>
--   </tr>
-- </tbody>
-- </table>
function SortBox:new(options, container)
  options = options or {}
  options.type = options.type or "SortBox"
  local me = self.parent:new(options, container)
  setmetatable(me, self)
  self.__index = self
  if me.timerSort then
    me:enableTimer()
  end
  me:setBoxType(me.boxType)
  return me
end

--- Iterates a key:value pair table in a sorted fashion
-- @local
-- I first found this on https://stackoverflow.com/questions/15706270/sort-a-table-in-lua
-- modified slightly, as Mudlet already has table.keys to collect keys, and I don't want
-- to sort if no function to sort with is given. In this case, I want it to work like pairs.
local function spairs(t, order)
  local keys = table.keys(t)
  if order then
    table.sort(keys, function(a, b)
      return order(t, a, b)
    end)
  end

  local i = 0
  return function()
    i = i + 1
    if keys[i] then
      return keys[i], t[keys[i]]
    end
  end
end

function SortBox:add(window, cons)
  if self.useAdd2 then
    Geyser.add2(self, window, cons)
  else
    Geyser.add(self, window, cons)
  end
  if not self.defer_updates then
    self:organize()
  end
end

function SortBox:remove(window)
  Geyser.remove(self, window)
  self:organize()
end

--- Calling this will cause the SortBox to reposition/resize everything
function SortBox:organize()
  -- make sure we don't divide by zero later
  if self:get_width() == 0 then
    self:resize("0.9px", nil)
  end
  if self:get_height() == 0 then
    self:resize(nil, "0.9px")
  end
  -- handle the individual boxType organization
  if self.boxType == "v" then
    self:vorganize()
  else
    self:horganize()
  end
  -- shrink/grow if needed
  self:handleElastic()
end

--- replicates Geyser.HBox functionality, but with the option of sorting
-- @local
function SortBox:horganize()
  local window_width = (self:calculate_dynamic_window_size().width / self:get_width()) * 100
  local start_x = 0
  local sortFunction = (self.autoSort and self.sortFunction) and SortBox.SortFunctions[self.sortFunction] or nil
  if sortFunction then
    for _, window in spairs(self.windowList, sortFunction) do
      start_x = start_x + self:handleWindow(window, start_x, window_width)
    end
  else
    for _, window_name in ipairs(self.windows) do
      local window = self.windowList[window_name]
      start_x = start_x + self:handleWindow(window, start_x, window_width)
    end
  end
end

--- replicates Geyser.VBox functionality, but with the option of sorting
-- @local
function SortBox:vorganize()
  local window_height = (self:calculate_dynamic_window_size().height / self:get_height()) * 100
  local start_y = 0
  local sortFunction = (self.autoSort and self.sortFunction) and SortBox.SortFunctions[self.sortFunction] or nil
  if sortFunction then
    for _, window in spairs(self.windowList, sortFunction) do
      start_y = start_y + self:handleWindow(window, start_y, window_height)
    end
  else
    for _, window_name in ipairs(self.windows) do
      local window = self.windowList[window_name]
      start_y = start_y + self:handleWindow(window, start_y, window_height)
    end
  end
end

--- handles a single window during the shuffle process
-- @local
function SortBox:handleWindow(window, start, window_dimension)
  local width = (window:get_width() / self:get_width()) * 100
  local height = (window:get_height() / self:get_height()) * 100
  if window.h_policy == Geyser.Fixed or window.v_policy == Geyser.Fixed then
    self.contains_fixed = true
  end
  if self.boxType == "v" then
    window:move("0%", start .. "%")
    if window.h_policy == Geyser.Dynamic then
      width = 100
      if window.width ~= width then
        window:resize(width .. "%", nil)
      end
    end
    if window.v_policy == Geyser.Dynamic then
      height = window_dimension * window.v_stretch_factor
      if window.height ~= height then
        window:resize(nil, height .. "%")
      end
    end
    return height
  else
    window:move(start .. "%", "0%")
    if window.h_policy == Geyser.Dynamic then
      width = window_dimension * window.h_stretch_factor
      if window.width ~= width then
        window:resize(width .. "%", nil)
      end
    end
    if window.v_policy == Geyser.Dynamic then
      height = 100
      if window.height ~= height then
        window:resize(nil, height .. "%")
      end
    end
    return width
  end
end

---handles actually resizing the window if elastic
-- @local
function SortBox:handleElastic()
  if not self.elastic or table.is_empty(self.windows) then
    return
  end
  if self.boxType == "v" then
    local contentHeight, canElastic = self:getContentHeight()
    if not canElastic then
      debugc(string.format("SortBox named %s cannot properly elasticize, as it contains at least one item with a dynamic v_policy", self.name))
      return
    end
    local currentHeight = self:get_height()
    local maxHeight = self.maxHeight
    if maxHeight > 0 and contentHeight > maxHeight then
      contentHeight = maxHeight
    end
    if contentHeight ~= currentHeight then
      self:resize(nil, contentHeight)
    end
  else
    local contentWidth, canElastic = self:getContentWidth()
    if not canElastic then
      debugc(string.format("SortBox named %s cannot properly elasticize, as it contains at least one item with a dynamic h_policy", self.name))
      return
    end
    local currentWidth = self:get_width()
    local maxWidth = self.maxWidth
    if maxWidth > 0 and contentWidth > maxWidth then
      contentWidth = maxWidth
    end
    if contentWidth ~= currentWidth then
      self:resize(contentWidth, nil)
    end
  end
end

---prevents gaps from forming during resize if it doesn't autoorganize on a timer.
-- @local
function SortBox:reposition()
  Geyser.Container.reposition(self)
  if self.contains_fixed then
    self:organize()
  end
end

--- Returns the sum of the heights of the contents, and whether this SortBox can be elastic in height
-- @local
function SortBox:getContentHeight()
  if self.boxType ~= "v" then
    return self:get_height()
  end
  local canElastic = true
  local contentHeight = 0
  for _, window in pairs(self.windowList) do
    contentHeight = contentHeight + window:get_height()
    if window.v_policy == Geyser.Dynamic then
      canElastic = false
    end
  end
  return contentHeight, canElastic
end

--- Returns the sum of the widths of the contents, and whether this SortBox can be elastic in width.
-- @local
function SortBox:getContentWidth()
  if self.boxType == "v" then
    return self:get_width()
  end
  local canElastic = true
  local contentWidth = 0
  for _, window in pairs(self.windowList) do
    contentWidth = contentWidth + window:get_width()
    if window.h_policy == Geyser.Dynamic then
      canElastic = false
    end
  end
  return contentWidth, canElastic
end

--- Enables elasticity for the SortBox.
function SortBox:enableElastic()
  self:setElastic(true)
end

--- Disables elasticity for the SortBox
function SortBox:disableElastic()
  self:setElastic(false)
end

--- Set elasticity specifically
-- @tparam boolean enabled if true, enable elasticity. If false, disable it.
function SortBox:setElastic(enabled)
  self.elastic = enabled and true or false
end

--- Set the max width of the SortBox if it's elastic
-- @tparam number maxWidth The maximum width in pixels to resize the SortBox to. Use 0 for unlimited.
function SortBox:setMaxWidth(maxWidth)
  local mwtype = type(maxWidth)
  assert(mwtype == "number", string.format("SortBox:setMaxWidth(maxWidth): SortBox: %s maxWidth as number expected, got %s", self.name, mwtype))
  assert(maxWidth >= 0, string.format("SortBox:setMaxWidth(maxWidth): SortBox: %s maxWidth must be >= 0, %d", self.name, maxWidth))
  self.maxWidth = maxWidth
end

--- Set the max height of the SortBox if it's elastic
-- @tparam number maxHeight The maximum height in pixels to resize the SortBox to. Use 0 for unlimited.
function SortBox:setMaxHeight(maxHeight)
  local mhtype = type(maxHeight)
  assert(mhtype == "number", string.format("SortBox:setMaxHeight(maxHeight): SortBox: %s maxHeight as number expected, got %s", self.name, mhtype))
  assert(maxHeight >= 0, string.format("SortBox:setMaxHeight(maxHeight): SortBox: %s maxHeight must be >= 0, %d", self.name, maxHeight))
  self.maxHeight = maxHeight
end

--- Starts the SortBox sorting and organizing itself on a timer
function SortBox:enableTimer()
  if self.timerID then
    self:disableTimer()
  end
  self.timerSort = true
  self.timerID = tempTimer(self.sortInterval / 1000, function()
    self:organize()
  end, true)
end

--- Stops the SortBox from sorting and organizing itself on a timer
function SortBox:disableTimer()
  killTimer(self.timerID)
  self.timerID = nil
  self.timerSort = false
end

--- Sets the sortInterval, or amount of time in milliseconds between auto sorting on a timer if timerSort is true
-- @tparam number sortInterval time in milliseconds between auto sorting if timerSort is true
function SortBox:setSortInterval(sortInterval)
  local sitype = type(sortInterval)
  assert(sitype == "number", string.format("SortBox:setSortInterval(sortInterval): sortInterval as number expected, got %s", sitype))
  assert(sortInterval > 0, string.format("SortBox:setSortInterval(sortInterval): sortInterval must be positive"))
  self.sortInterval = sortInterval
  if self.timerSort then
    self:enableTimer()
  end
end

--- Enables sorting when items are added/removed, or if timerSort is true, every sortInterval milliseconds
function SortBox:enableSort()
  self.autoSort = true
  self:organize()
end

--- Disables sorting when items are added or removed
function SortBox:disableSort()
  self.autoSort = false
end

---Set whether the SortBox acts as a VBox or HBox.
-- @tparam string boxType If you pass 'h' or 'horizontal' it will act like an HBox. Anything else it will act like a VBox.
-- @usage mySortBox:setBoxType("v") -- behave like a VBox
-- mySortBox:setBoxType("h") -- behave like an HBox
-- mySortBox:setBoxType("beeblebrox") -- why?! Why would you do this? It'll behave like a VBox
function SortBox:setBoxType(boxType)
  boxType = boxType:lower()
  if boxType == "h" or boxType == "horizontal" then
    self.boxType = "h"
  else
    self.boxType = "v"
  end
end

---Sets the type of sorting in use by this SortBox.
-- <br>If an item in the box does not have the appropriate property or function, then 999999999 is used for sorting except as otherwise noted.
-- <br>If an invalid option is given, then existing H/VBox behaviour is maintained, just like if autoSort is false.
-- @usage mySortBox:setSortFunction("gaugeValue")
-- @tparam string functionName what type of sorting should we use? See table below for valid options and their descriptions.
-- <table class="tg">
-- <thead>
--   <tr>
--     <th>sort type</th>
--     <th>description</th>
--   </tr>
-- </thead>
-- <tbody>
--   <tr>
--     <td class="tg-1">gaugeValue</td>
--     <td class="tg-1">sort gauges based on how full the gauge is, from less full to more</td>
--   </tr>
--   <tr>
--     <td class="tg-2">reverseGaugeValue</td>
--     <td class="tg-2">sort gauges based on how full the gauge is, from more full to less</td>
--   </tr>
--   <tr>
--     <td class="tg-1">timeLeft</td>
--     <td class="tg-1">sort TimerGauges based on the total time left in the gauge, from less time to more</td>
--   </tr>
--   <tr>
--     <td class="tg-2">reverseTimeLeft</td>
--     <td class="tg-2">sort TimerGauges based on the total time left in the gauge, from more time to less</td>
--   </tr>
--   <tr>
--     <td class="tg-1">name</td>
--     <td class="tg-1">sort any item (and mixed types) by name, alphabetically.</td>
--   </tr>
--   <tr>
--     <td class="tg-2">reverseName</td>
--     <td class="tg-2">sort any item (and mixed types) by name, reverse alphabetically.</td>
--   </tr>
--   <tr>
--     <td class="tg-1">message</td>
--     <td class="tg-1">sorts Labels based on their echoed message, alphabetically. If not a label, the empty string will be used</td>
--   </tr>
--   <tr>
--     <td class="tg-2">reverseMessage</td>
--     <td class="tg-2">sorts Labels based on their echoed message, reverse alphabetically. If not a label, the empty string will be used</td>
--   </tr>
-- </tbody>
-- </table>

function SortBox:setSortFunction(functionName)
  self.sortFunction = functionName
end

SortBox.parent = Geyser.Container

return SortBox
