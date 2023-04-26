--- A Geyser object to create a spinbox for adjusting a number
-- @classmod spinbox
-- @author Damian Monogue <demonnic@gmail.com>
-- @copyright 2023
-- @license MIT, see https://raw.githubusercontent.com/demonnic/MDK/main/src/scripts/LICENSE.lua
local spinbox = {
  parent = Geyser.Container,
  name = 'SpinboxClass',
  min = 0,
  max = 10,
  delta = 1,
  value = 0,
  activeButtonColor = "gray",
  inactiveButtonColor = "DimGray",
  integer = true,
  upArrowLocation = "https://demonnic.github.io/image-assets/uparrow.png",
  downArrowLocation = "https://demonnic.github.io/image-assets/downarrow.png",
}
spinbox.__index = spinbox
setmetatable(spinbox, spinbox.parent)

local gss = Geyser.StyleSheet
local directory = getMudletHomeDir() .. "/spinbox/"
local saveFile = directory .. "fileLocations.lua"
if not io.exists(directory) then
  lfs.mkdir(directory)
end

--- Creates a new spinbox. 
-- @tparam table cons a table containing the options for this spinbox.
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
--     <td class="tg-1">min</td>
--     <td class="tg-1">The minimum value for this spinbox</td>
--     <td class="tg-1">0</td>
--   </tr>
--   <tr>
--     <td class="tg-2">max</td>
--     <td class="tg-2">The maximum value for this spinbox</td>
--     <td class="tg-2">10</td>
--   </tr>
--   <tr>
--     <td class="tg-1">activeButtonColor</td>
--     <td class="tg-1">The color the up/down buttons should be when they are active/able to be used</td>
--     <td class="tg-1">gray</td>
--   </tr>
--   <tr>
--     <td class="tg-2">inactiveButtonColor</td>
--     <td class="tg-2">The color the up/down buttons should be when they are inactive/unable to be used</td>
--     <td class="tg-2">dimgray</td>
--   </tr>
--   <tr>
--     <td class="tg-1">integer</td>
--     <td class="tg-1">Boolean value. When true, values must always be integers (no decimal place)</td>
--     <td class="tg-1">true</td>
--   </tr>
--   <tr>
--     <td class="tg-2">delta</td>
--     <td class="tg-2">The amount to change the spinbox's value when the up or down button is pressed.</td>
--     <td class="tg-2">1</td>
--   </tr>
--   <tr>
--     <td class="tg-1">upArrowLocation</td>
--     <td class="tg-1">The location of the up arrow image. Either a web URL where it can be downloaded, or the location on disk to read it from</td>
--     <td class="tg-1">https://demonnic.github.io/image-assets/uparrow.png</td>
--   </tr>
--   <tr>
--     <td class="tg-2">downArrowLocation</td>
--     <td class="tg-2">The location of the down arrow image. Either a web URL where it can be downloaded, or the location on disk to read it from</td>
--     <td class="tg-2">https://demonnic.github.io/image-assets/downarrow.png</td>
--   </tr>
--</tbody>
--</table>
-- @param container The Geyser container for this spinbox
function spinbox:new(cons, container)
  cons = cons or {}
  local consType = type(cons)
  if consType ~= "table" then
    printError(f"spinbox:new(cons, container): cons as table of options expected, got {consType}!", true, true)
  end
  cons.name = cons.name or Geyser.nameGen("spinbox")
  local me = self.parent:new(cons, container)
  setmetatable(me, self)
  me:createComponents()
  return me
end

--- handles actually creating the pieces which make up the spinbox
-- @internal
function spinbox:createComponents()
  self:obtainImages()
  self:generateStyles()
  self.upButton = Geyser.Label:new({
    name = self.name .. "spinbox_upArrow",
    height = 12,
    width = 12,
    x = "100%-12",
    y = 0
  }, self)
  self.upButton:setClickCallback(function()
    self:increment()
  end)
  self.downButton = Geyser.Label:new({
    name = self.name .. "spinbox_downArrow",
    height = 12,
    width = 12,
    x = "100%-12",
    y = "13"
  }, self)
  self.downButton:setClickCallback(function()
    self:decrement()
  end)
  self.displayLabel = Geyser.Label:new({
    name = self.name .. "spinbox_displayLabel",
    x = 0,
    y = 0,
    width = "100%-12",
    height = "100%",
    message = self.value
  }, self)
  self.displayLabel:setAlignment("center")
  self.displayLabel:setDoubleClickCallback(function()
    self.input:show()
    self.input:print(self.value)
    self.input:selectText()
    self.displayLabel:hide()
  end)
  self.input = Geyser.CommandLine:new({
    x = 0,
    y = 0,
    width = "100%-12",
    height = "100%",
  }, self)
  self.input:setAction(function(txt)
    txt = tonumber(txt)
    if txt then
      self:setValue(txt)
      self.input:hide()
    end
    self.displayLabel:show()
    self.input:print(self.value)
  end)
  self.input:hide()
  self:applyStyles()
end

--- Used to increment the value by the increment amount
-- @internal
function spinbox:increment()
  local val = self.value + self.delta
  if val >= self.max then
    val = self.max
  end
  self.value = val
  self.displayLabel:echo(val)
  self:applyStyles()
end

--- Used to decrement the value by the increment amount
-- @internal
function spinbox:decrement()
  local val = self.value - self.delta
  if val <= self.min then
    val = self.min
  end
  self.value = val
  self.displayLabel:echo(val)
  self:applyStyles()
end

--- Used to directly set the value of the the spinbox.
-- @internal
function spinbox:setValue(value)
  if self.integer then
    value = math.floor(value)
  end
  if value >= self.max then
    value = self.max
  elseif value <= self.min then
    value = self.min
  end
  self.value = value
  self.displayLabel:echo(value)
  self:applyStyles()
end

--- Responsible for downloading the up and down arrow images the first time if web URLs.
-- remembers where it's downloaded files to and reuses them if they already exist, even if another spinbox downloaded them
-- if it's not a web URL it assumes it's just a file path.
-- @internal
function spinbox:obtainImages()
  local locations = self:getFileLocs()
  local upURL = self.upArrowLocation
  local downURL = self.downArrowLocation
  local upFile = locations[upURL]
  local downFile = locations[downURL]
  local locationsChanged = false
  if not (upFile and io.exists(upFile)) then
    if not upFile then
      upFile = directory .. self.name .. "/uparrow.png"
      locations[upURL] = upFile
      locationsChanged = true
    end
    if upURL:match("^http") then
      self:downloadFile(upURL, upFile)
    elseif io.exists(upURL) then
      upFile = upURL
      locations[upURL] = upFile
      locationsChanged = true
    end
  end
  if not (downFile and io.exists(downFile)) then
    if not downFile then
      downFile = directory .. self.name .. "/downarrow.png"
      locations[downURL] = downFile
      locationsChanged = true
    end
    if downURL:match("^http") then
      self:downloadFile(downURL, downFile)
    elseif io.exists(downURL) then
      downFile = downURL
      locations[downURL] = downFile
      locationsChanged = true
    end
  end
  self.upArrowFile = upFile
  self.downArrowFile = downFile
  if locationsChanged then
    table.save(saveFile, locations)
  end
end

--- Handles the -actual- download of a file from a url
-- @internal
function spinbox:downloadFile(url, fileName)
  local parts = fileName:split("/")
  parts[#parts] = nil
  local dirName = table.concat(parts, "/") .. "/"
  if not io.exists(dirName) then
    lfs.mkdir(dirName)
  end
  local uname = "spinbox"
  local handlerName = self.name .. url
  local handler = function(event, ...)
    local args = {...}
    local file = #args == 1 and args[1] or args[2]
    if file ~= fileName then
      return true
    end
    if event == "sysDownloadDone" then
      debugc(f"INFO:Spinbox successfully downloaded {file}")
      stopNamedEventHandler(uname, handlerName .. "error")
      return false
    end
    cecho(f"\n<red>ERROR:<reset>Spinbox had an issue downloading an image file to {file}: {args[1]}\n")
    stopNamedEventHandler(uname, handlerName .. "done")
  end
  registerNamedEventHandler(uname, handlerName .. "done", "sysDownloadDone", handler, true)
  registerNamedEventHandler(uname, handlerName .. "error", "sysDownloadError", handler, true)
  downloadFile(fileName, url)
end

--- Responsible for reading the file locations from disk and returning them
-- @internal
function spinbox:getFileLocs()
  local locations = {}
  if io.exists(saveFile) then
    table.load(saveFile, locations)
  end
  return locations
end

--- (Re)generates the stylesheets for the spinbox
-- Should not need to call but if you change something and it doesn't take effect
-- you can try calling this followed by applyStyles
function spinbox:generateStyles()
  self.baseStyle = gss:new([[
    border-radius: 2px;
  ]])
  self.activeStyle = gss:new(f[[
    background-color: {self.activeButtonColor};
  ]], self.baseStyle)
  self.inactiveStyle = gss:new(f[[
    background-color: {self.inactiveButtonColor};
  ]], self.baseStyle)
  self.upStyle = gss:new(f[[
    border-image: url("{self.upArrowFile}");
  ]])
  self.downStyle = gss:new(f[[
    border-image: url("{self.downArrowFile}");
  ]])
  self.displayStyle = gss:new(f[[
    background-color: {Geyser.Color.hex(self.color)};
    text-align: center;
  ]], self.baseStyle)
end

--- Applies updated stylesheets to the components of the spinbox
-- Should not need to call this directly
function spinbox:applyStyles()
  if self.value >= self.max then
    self.upStyle:setParent(self.inactiveStyle)
  else
    self.upStyle:setParent(self.activeStyle)
  end
  if self.value <= self.min then
    self.downStyle:setParent(self.inactiveStyle)
  else
    self.downStyle:setParent(self.activeStyle)
  end
  self.upButton:setStyleSheet(self.upStyle:getCSS())
  self.downButton:setStyleSheet(self.downStyle:getCSS())
  self.displayLabel:setStyleSheet(self.displayStyle:getCSS())
end

--- sets the color for active buttons on the spinbox
-- @param color any valid color formatting string, such a "red" or "#880000" or "<128,0,0>" or a table of colors, like {128, 0,0}. See Geyser.Color.parse at https://www.mudlet.org/geyser/files/geyser/GeyserColor.html#Geyser.Color.parse
function spinbox:setActiveButtonColor(color)
  local colorType = type(color)
  local hex
  if colorType == "table" then
    hex = Geyser.Color.hex(unpack(color))
  else
    hex = Geyser.Color.hex(color)
  end
  self.activeButtonColor = hex
  self.activeStyle:set("background-color", hex)
  self:applyStyles()
end

--- sets the color for inactive buttons on the spinbox
-- @param color any valid color formatting string, such a "<red>" or "red" or "<128,0,0>" or a table of colors, like {128, 0,0}. See Geyser.Color.parse at https://www.mudlet.org/geyser/files/geyser/GeyserColor.html#Geyser.Color.parse
function spinbox:setInactiveButtonColor(color)
  local colorType = type(color)
  local hex
  if colorType == "table" then
    hex = Geyser.Color.hex(unpack(color))
  else
    hex = Geyser.Color.hex(color)
  end
  self.inactiveButtonColor = hex
  self.inactiveStyle:set("background-color", hex)
  self:applyStyles()
end

return spinbox