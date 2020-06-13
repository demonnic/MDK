---An H/VBox alternative which can be set to either vertical or horizontal, and will autosort the windows
--@module SortBox
local SortBox = Geyser.Container:new({
  name = "SortBoxClass",
  autoSort = true,
  timerSort = true,
  sortInterval = 500,
  boxType = "v",
  sortFunction = "gaugeValue"
})
local BIGNUMBER = 999999999
SortBox.SortFunctions = {
  gaugeValue = function(t,a,b)
    local avalue = t[a].value or BIGNUMBER
    local bvalue = t[b].value or BIGNUMBER
    return avalue < bvalue
  end,
  reverseGaugeValue = function(t,a,b)
    local avalue = t[a].value or BIGNUMBER
    local bvalue = t[b].value or BIGNUMBER
    return avalue >  bvalue
  end,
  timeLeft = function(t,a,b) 
    a = t[a]
    b = t[b]
    local avalue = a.getTime and tonumber(a:getTime("S.mm")) or BIGNUMBER
    local bvalue = b.getTime and tonumber(b:getTime("S.mm")) or BIGNUMBER
    return avalue < bvalue
  end,
  reverseTimeLeft = function(t,a,b) 
    a = t[a]
    b = t[b]
    local avalue = a.getTime and tonumber(a:getTime("S.mm")) or BIGNUMBER
    local bvalue = b.getTime and tonumber(b:getTime("S.mm")) or BIGNUMBER
    return avalue > bvalue
  end,
  name = function(t,a,b) return t[a].name < t[b].name end,
  reverseName = function(t,a,b) return t[a].name > t[b].name end,
  message = function(t,a,b)
    a = t[a]
    b = t[b]
    local avalue = a.text and a.text.message or a.message
    local bvalue = b.text and b.text.message or b.message
    avalue = avalue or ""
    bvalue = bvalue or ""
    return avalue < bvalue
  end,
  reverseMessage = function(t,a,b)
    a = t[a]
    b = t[b]
    local avalue = a.text and a.text.message or a.message
    local bvalue = b.text and b.text.message or b.message
    avalue = avalue or ""
    bvalue = bvalue or ""
    return avalue > bvalue
  end,
}

-- I first found this on https://stackoverflow.com/questions/15706270/sort-a-table-in-lua
-- modified slightly, as Mudlet already has table.keys to collect keys, and I don't want
-- to sort if no function to sort with is given. In this case, I want it to work like pairs.
local function spairs(t, order)
  local keys = table.keys(t)
  if order then
    table.sort(keys, function(a,b) return order(t, a, b) end)
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
  if self.boxType == "v" then
    self:vorganize()
  else
    self:horganize()
  end
end

-- internal function, replicates Geyser.HBox functionality, but with the option of sorting
function SortBox:horganize()
  self.parent:reposition()
  local window_width = (self:calculate_dynamic_window_size().width / self:get_width()) * 100
  local start_x = 0
  local sortFunction = (self.autoSort and self.sortFunction) and SortBox.SortFunctions[self.sortFunction] or nil
  if sortFunction then
    for _, window in spairs(self.windowList, sortFunction) do
      local width = (window:get_width() / self:get_width()) * 100
      local height = (window:get_height() / self:get_height()) * 100
      window:move(start_x.."%", "0%")
      if window.h_policy == Geyser.Dynamic then
        width = window_width * window.h_stretch_factor
      end
      if window.v_policy == Geyser.Dynamic then
        height = 100
      end
      window:resize(width.."%", height.."%")
      start_x = start_x + (window:get_width() / self:get_width()) * 100
    end
  else
    if Geyser.HBox.organize then Geyser.HBox.organize(self) else Geyser.HBox.reposition(self) end
  end
end

-- internal function, replicates Geyser.VBox functionality, but with the option of sorting
function SortBox:vorganize()
  self.parent:reposition()
  local window_height = (self:calculate_dynamic_window_size().height / self.get_height()) * 100
  local start_y = 0
  local sortFunction = (self.autoSort and self.sortFunction) and SortBox.SortFunctions[self.sortFunction] or nil
  if sortFunction then
    for _, window in spairs(self.windowList, sortFunction) do
      window:move("0%", start_y.."%")
      local width = (window:get_width() / self:get_width()) * 100
      local height = (window:get_height() / self:get_height()) * 100
      if window.h_policy == Geyser.Dynamic then
        width = 100
      end
      if window.v_policy == Geyser.Dynamic then
        height = window_height * window.v_stretch_factor
      end
      window:resize(width.."%", height.."%")
      start_y = start_y + (window:get_height() / self:get_height()) * 100
    end
  else
    if Geyser.VBox.organize then Geyser.VBox.organize(self) else Geyser.VBox.reposition(self) end
  end
end

--- Starts the SortBox sorting and organizing itself on a timer
function SortBox:enableTimer()
  if self.timerID then self:disableTimer() end
  self.timerSort = true
  self.timerID = tempTimer(self.sortInterval / 1000, function() self:organize() end, true)
end

--- Stops the SortBox from sorting and organizing itself on a timer
function SortBox:disableTimer()
  killTimer(self.timerID)
  self.timerID = nil
  self.timerSort = false
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
--@tparam string boxType If you pass 'h' or anything beginning with h it will act like an HBox. Anything else it will act like a VBox.
--@usage mySortBox:setBoxType("v") -- behave like a VBox
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
--<br>If an item in the box does not have the appropriate property or function, then 999999999 is used for sorting except as otherwise noted.
--<br>If an invalid option is given, then existing H/VBox behaviour is maintained, just like if autoSort is false.
--@usage mySortBox:setSortFunction("gaugeValue")
--@tparam string functionName what type of sorting should we use? See table below for valid options and their descriptions.
-- <style type="text/css">
-- .tg  {border-collapse:collapse;border-color:#aabcfe;border-spacing:0;}
-- .tg td{background-color:#e8edff;border-color:#aabcfe;border-style:solid;border-width:1px;color:#669;
--   font-family:Arial, sans-serif;font-size:14px;overflow:hidden;padding:10px 5px;word-break:normal;}
-- .tg th{background-color:#b9c9fe;border-color:#aabcfe;border-style:solid;border-width:1px;color:#039;
--   font-family:Arial, sans-serif;font-size:14px;font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}
-- .tg .tg-phtq{background-color:#D2E4FC;border-color:inherit;text-align:left;vertical-align:top}
-- .tg .tg-hmp3{background-color:#D2E4FC;text-align:left;vertical-align:top}
-- .tg .tg-0pky{border-color:inherit;text-align:left;vertical-align:top}
-- .tg .tg-0lax{text-align:left;vertical-align:top}
-- </style>
-- <table class="tg">
-- <thead>
--   <tr>
--     <th class="tg-0pky">sort type</th>
--     <th class="tg-0pky">description</th>
--   </tr>
-- </thead>
-- <tbody>
--   <tr>
--     <td class="tg-phtq">gaugeValue</td>
--     <td class="tg-phtq">sort gauges based on how full the gauge is, from less full to more</td>
--   </tr>
--   <tr>
--     <td class="tg-0pky">reverseGaugeValue</td>
--     <td class="tg-0pky">sort gauges based on how full the gauge is, from more full to less</td>
--   </tr>
--   <tr>
--     <td class="tg-phtq">timeLeft</td>
--     <td class="tg-phtq">sort TimerGauges based on the total time left in the gauge, from less time to more</td>
--   </tr>
--   <tr>
--     <td class="tg-0lax">reverseTimeLeft</td>
--     <td class="tg-0lax">sort TimerGauges based on the total time left in the gauge, from more time to less</td>
--   </tr>
--   <tr>
--     <td class="tg-hmp3">name</td>
--     <td class="tg-hmp3">sort any item (and mixed types) by name, alphabetically.</td>
--   </tr>
--   <tr>
--     <td class="tg-0lax">reverseName</td>
--     <td class="tg-0lax">sort any item (and mixed types) by name, reverse alphabetically.</td>
--   </tr>
--   <tr>
--     <td class="tg-hmp3">message</td>
--     <td class="tg-hmp3">sorts Labels based on their echoed message, alphabetically. If not a label, the empty string will be used</td>
--   </tr>
--   <tr>
--     <td class="tg-0lax">reverseMessage</td>
--     <td class="tg-0lax">sorts Labels based on their echoed message, reverse alphabetically. If not a label, the empty string will be used</td>
--   </tr>
-- </tbody>
-- </table>

function SortBox:setSortFunction(functionName)
  self.sortFunction = functionName
end

SortBox.parent = Geyser.Container

--- Creates a new SortBox
--@usage mySortBox = SortBox:new({
--   name = "mySortBox",
--   x = 400,
--   y = 100,
--   height = 150,
--   width = 300,
--   sortFunction = "timeLeft"
-- })
--@tparam table options the options to use for the SortBox. See table below for added options
--@param[opt] container the container to add the SortBox into
--<br><br>Table of new options
-- <style type="text/css">
-- .tg  {border-collapse:collapse;border-color:#aabcfe;border-spacing:0;}
-- .tg td{background-color:#e8edff;border-color:#aabcfe;border-style:solid;border-width:1px;color:#669;
--   font-family:Arial, sans-serif;font-size:14px;overflow:hidden;padding:10px 5px;word-break:normal;}
-- .tg th{background-color:#b9c9fe;border-color:#aabcfe;border-style:solid;border-width:1px;color:#039;
--   font-family:Arial, sans-serif;font-size:14px;font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}
-- .tg .tg-phtq{background-color:#D2E4FC;border-color:inherit;text-align:left;vertical-align:top}
-- .tg .tg-hmp3{background-color:#D2E4FC;text-align:left;vertical-align:top}
-- .tg .tg-0pky{border-color:inherit;text-align:left;vertical-align:top}
-- .tg .tg-0lax{text-align:left;vertical-align:top}
-- </style>
-- <table class="tg">
-- <thead>
--   <tr>
--     <th class="tg-0pky">option name</th>
--     <th class="tg-0pky">description</th>
--     <th class="tg-0lax">default</th>
--   </tr>
-- </thead>
-- <tbody>
--   <tr>
--     <td class="tg-phtq">autoSort</td>
--     <td class="tg-phtq">should the SortBox perform function based sorting? If false, will behave like a normal H/VBox</td>
--     <td class="tg-hmp3">true</td>
--   </tr>
--   <tr>
--     <td class="tg-0pky">timerSort</td>
--     <td class="tg-0pky">should the SortBox automatically perform sorting on a timer?</td>
--     <td class="tg-0lax">true</td>
--   </tr>
--   <tr>
--     <td class="tg-phtq">sortInterval</td>
--     <td class="tg-phtq">how frequently should we sort on a timer if timerSort is true, in milliseconds</td>
--     <td class="tg-hmp3">500</td>
--   </tr>
--   <tr>
--     <td class="tg-0lax">boxType</td>
--     <td class="tg-0lax">Should we stack like an HBox or VBox? use 'h' for hbox and 'v' for vbox</td>
--     <td class="tg-0lax">v</td>
--   </tr>
--   <tr>
--     <td class="tg-hmp3">sortFunction</td>
--     <td class="tg-hmp3">how should we sort the items in the SortBox? see setSortFunction for valid options</td>
--     <td class="tg-hmp3">gaugeValue</td>
--   </tr>
-- </tbody>
-- </table>
function SortBox:new(options, container)
  options = options or {}
  options.type = options.type or "SortBox"
  local me = self.parent:new(options, container)
  setmetatable(me, self)
  self.__index = self
  if me.timerSort then me:enableTimer() end
  me:setBoxType(me.boxType)
  return me
end

return SortBox
