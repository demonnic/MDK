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
  color = "#202020"
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
--   <tr>
--     <td class="tg-1">callBack</td>
--     <td class="tg-1">The function to run when the spinbox's value is updated. Is called with parameters (self.name, value, oldValue)</td>
--     <td class="tg-1">nil</td>
--   </tr>
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
  if me.callBack then
    me:setCallBack(me.callBack)
  end
  me.oldValue = me.value
  return me
end

--- Creates the components that make up the spinbox UI. 
-- @local
-- Obtains the up and down arrow images specified in the spinbox options.
-- Generates styles for the spinbox.
-- Calculates the height of the up/down buttons and any remainder space.
-- Creates:
--   `self.upButton` - A button with an up arrow image for incrementing the value
--   `self.downButton` - A button with a down arrow image for decrementing the value
--   `self.displayLabel` - A label to display the current spinbox value
--   `self.input` - A command line input to allow directly entering a value
-- Hides the input by default.
-- Applies the generated styles.
function spinbox:createComponents()
  self:obtainImages()
  self:generateStyles()
  self:calculateButtonDimensions()

  self.upButton = self:createButton("up")
  self.downButton = self:createButton("down")

  self.displayLabel = self:createDisplayLabel()

  self.input = self:createInput()
  self.input:hide()

  self:applyStyles()
end

--- Calculates the button height. We use square buttons in this house.  
-- @local
-- Calculates the height of the up/down buttons by dividing the spinbox height in half.
-- Stores the remainder (if any) in self.remainder.
-- Stores the calculated button height in self.buttonHeight.
function spinbox:calculateButtonDimensions()
  self.buttonHeight = math.floor(self.get_height() / 2)
  self.remainder = self.get_height() % 2
end

--- Creates a button (up or down arrow) for the spinbox.
-- @param type Either "up" or "down" to specify which direction the arrow should point
-- @return The created Geyser.Label button
-- @local
-- Creates a Geyser.Label button with an up or down arrow image. 
-- Positions the button at the top or bottom of the spinbox respectively.
-- Sets a click callback on the button to call increment() or decrement() depending on the type.
-- Returns the created button.
function spinbox:createButton(type)
  local button = Geyser.Label:new({
    name = self.name .. "spinbox_"..type.."Arrow",
    height = self.buttonHeight,
    width = self.buttonHeight,
    x = "100%-" .. self.buttonHeight,
    y = type == "up" and 0 or self.buttonHeight + self.remainder,
  }, self)
    
  button:setClickCallback(function()
    if type == "up" then
      self:increment()
    else
      self:decrement()
    end
  end)
  return button
end

--- Creates the display label for the spinbox value.
-- @return The created Geyser.Label display label
-- @local 
-- Creates a Geyser.Label to display the current spinbox value.
-- Centers the text in the label.
-- Sets a double click callback on the label to show the input, put the current 
-- value in it, select the text, and hide the label.
-- Returns the created display label.
function spinbox:createDisplayLabel()
  local displayLabel = Geyser.Label:new({
    name = self.name .. "spinbox_displayLabel",
    x = 0,
    y = 0,
    width = "100%-" .. self.buttonHeight,
    height = "100%",
    message = self.value
  }, self)
  displayLabel:setAlignment("center")
  displayLabel:setDoubleClickCallback(function()
    self.input:show()
    self.input:print(self.value)
    self.input:selectText()
    displayLabel:hide()
  end)
  return displayLabel
end

--- Creates the input for directly entering a spinbox value.  
-- @return The created Geyser.CommandLine input  
-- @local
-- Creates a Geyser.CommandLine input.
-- Sets an action on the input to:
--   - Attempt to convert the input text to a number
--   - If successful, call setValue() with the number to set the spinbox value
--   - Hide the input
--   - Show the display label
--   - Put the new spinbox value in the input
-- Returns the created input.
function spinbox:createInput()
  local input = Geyser.CommandLine:new({
    x = 0,
    y = 0,
    width = "100%-".. self.buttonHeight,
    height = "100%",
  }, self)
  input:setAction(function(txt)
    txt = tonumber(txt)
    if txt then
      self:setValue(txt)
      input:hide()
    end
    self.displayLabel:show()
    input:print(self.value)
  end)
  return input
end

--- Used to increment the value by the delta amount  
-- @local
-- Increments the spinbox value by the delta amount.
-- Checks if the new value would exceed the max, and if so sets it to the max.
-- Updates the display label with the new value.
-- Applies any styles that depend on the value.
function spinbox:increment()
  local val = self.value + self.delta
  if val >= self.max then
    val = self.max
  end
  self.oldValue = self.value
  self.value = val
  self.displayLabel:echo(val)
  self:applyStyles()
  self:handleCallBacks()
end

--- Used to decrement the value by the delta amount  
-- @local
-- Decrements the spinbox value by the delta amount.
-- Checks if the new value would be below the min, and if so sets it to the min.  
-- Updates the display label with the new value.
-- Applies any styles that depend on the value.
function spinbox:decrement()
  local val = self.value - self.delta
  if val <= self.min then
    val = self.min
  end
  self.oldValue = self.value
  self.value = val
  self.displayLabel:echo(val)
  self:applyStyles()
  self:handleCallBacks()
end

--- Used to directly set the value of the spinbox.  
-- @param value The new value to set
-- Rounds the value to an integer if the spinbox is integer only.
-- Checks if the new value is within the min/max range and clamps it if not.
-- Updates the display label with the new value.  
-- Applies any styles that depend on the value.
function spinbox:setValue(value)
  if self.integer then
    value = math.floor(value)
  end
  if value >= self.max then
    value = self.max
  elseif value <= self.min then
    value = self.min
  end
  self.oldValue = self.value
  self.value = value
  self.displayLabel:echo(value)
  self:applyStyles()
  self:handleCallBacks()
end

--- Obtains the up and down arrow images for the spinbox.  
-- @local
-- Gets the previously saved file locations.
-- Checks if the up arrow image exists at the upArrowLocation. 
-- If not, it will download the image from a URL or copy a local file. It saves 
-- the new location.
-- Does the same for the down arrow image and downArrowLocation.
-- Saves any new locations to the save file.
-- Sets self.upArrowFile and self.downArrowFile to the locations of the images.
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

--- Handles the actual download of a file from a url
-- @param url The url to download the file from
-- @param fileName The location to save the downloaded file
-- @local
-- Creates any missing directories in the file path.
-- Registers named event handlers to handle the download completing or erroring.
-- The completion handler stops the error handler.
-- The error handler prints an error message and stops the completion handler.
-- Downloads the file from the url to the fileName location.
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
-- @local
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
    border-color: black;
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

-- internal function that handles calling a registered callback and raising an event any time the
-- spinbox value is changed, whether using the buttons or the :set function.
function spinbox:handleCallBacks()
  raiseEvent("spinbox updated", self.name, self.value, self.oldValue)
  if self.callBack then
    local ok, err = pcall(self.callBack, self.name, self.value, self.oldValue)
    if not ok then
      printError(f"Had an issue running the callback handler for spinbox named {self.name}: {err}", true, true)
    end
  end
end

--- Set a callback function for the spinbox to call any time the value of the spinbox is changed
-- the function will be called as func(self.value, self.name)
function spinbox:setCallBack(func)
  local funcType = type(func)
  if funcType ~= "function" then
    printError(f"spinbox:setCallBack(func): func as function required, got {funcType}", true, true)
  end
  self.callBack = func
  return true
end

return spinbox