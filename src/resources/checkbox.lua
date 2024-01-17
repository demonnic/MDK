--- A Geyser object to create a yes/no or true/false checkbox
-- @classmod checkbox
-- @author Zooka
local checkbox = {
  parent = Geyser.Container,
  name = 'CheckboxClass',
  checkboxLocation = "https://demonnic.github.io/image-assets/checkbox-25px.png",
  uncheckedLocation = "https://demonnic.github.io/image-assets/unchecked-25px.png",
  noLabel = false
}

checkbox.__index = checkbox
setmetatable(checkbox, checkbox.parent)

local directory = getMudletHomeDir() .. "/checkbox/"
local saveFile = directory .. "fileLocations.lua"
if not io.exists(directory) then
  lfs.mkdir(directory)
end

--- Creates a new checkbox. 
-- @tparam table cons a table containing the options for this checkbox.
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
--     <td>noLabel</td>
--     <td>Do not assign a label associated this checkbox</td>
--     <td>false</td>
--   </tr>
--   <tr>
--     <td>checkboxLocation</td>
--     <td>The location of the checked checkbox image representing true. Either a web URL where it can be downloaded, or the location on disk to read it from</td>
--     <td>https://demonnic.github.io/image-assets/checkbox-25px.png</td>
--   </tr>
--   <tr>
--     <td>uncheckedLocation</td>
--     <td>The location of the unchecked checkbox image representing false. Either a web URL where it can be downloaded, or the location on disk to read it from</td>
--     <td>https://demonnic.github.io/image-assets/unchecked-25px.png</td>
--   </tr>
--</tbody>
--</table>
-- @param container The Geyser container for this checkbox
function checkbox:new(cons, container)
  cons = cons or {}
  local consType = type(cons)
  if consType ~= "table" then
    printError(f"checkbox:new(cons, container): cons as table of options expected, got {consType}!", true, true)
  end
  cons.name = cons.name or Geyser.nameGen("checkbox")
  local me = self.parent:new(cons, container)
  setmetatable(me, self)
  me:createComponents()
  return me
end

--- Create the checkbox components.
-- @local
-- Creates self.checkboxLabel to hold a display message.
-- Creates self.checkboxButton, a Geyser.Button with a true/false state.
function checkbox:createDisplay()

  if checkbox.noLabel then
    self.checkboxLabel = Geyser.Label:new({ 
                                message = self.labelText or "Checkbox Label",
                                x = 0, y = 0,
                                width = "100%-25px",
                                height = "100%",
                                color = "white",
                                fgColor = "black"
                          }, self)
  end
  
  self.checkboxButton = Geyser.Button:new({
                              name = "Checkbox",
                              x = "-25r",
                              y = 0,
                              width = 25,
                              height = 25,
                              color = "white",
                              downColor = "white",
                              downStyle = "background-color: white; border-image: url("..self.checkboxFile..");",
                              style = "background-color: white; border-image: url("..self.uncheckedFile..");",
                              downCommand = "unticked",
                              clickCommand = "ticked",
                              msg = "",
                              downMsg = "",
                              tooltip = "",
                              downTooltip = "",
                              twoState = true,
                              state = "up",
                              toolTipDuration = 0
                          }, self)

end

--- Creates the components that make up the checkbox UI. 
-- @local
-- Obtains the checked and unchecked images specified in the checkbox options.
-- Generate white styling for the checkbox.
-- @todo user generated CSS styling
function checkbox:createComponents()

  self:obtainImages()
  self:createDisplay()

end

--- Obtains the checked and unchecked images for the checkbox.
-- @local
-- Gets the previously saved file locations.
-- Checks if the checked image exists at the checkboxLocation. 
-- If not, it will download the image from a URL or copy a local file. It saves 
-- the new location.
-- Does the same for the unchecked image at teh uncheckedLocation.
-- Saves any new locations to the save file.
-- Sets self.checkboxFile and self.uncheckedFile to the locations of the images.
function checkbox:obtainImages()
  local locations = self:getFileLocs()
  local checkboxURL = self.checkboxLocation
  local uncheckedURL = self.uncheckedLocation
  local checkboxFile = locations[checkboxURL]
  local uncheckedFile = locations[uncheckedURL]
  local locationsChanged = false
  if not (checkboxFile and io.exists(checkboxFile)) then
    if not checkboxFile then
      checkboxFile = directory .. self.name .. "/checkbox-25px.png"
      locations[checkboxURL] = checkboxFile
      locationsChanged = true
    end
    if checkboxURL:match("^http") then
      self:downloadFile(checkboxURL, checkboxFile)
    elseif io.exists(checkboxURL) then
      checkboxFile = checkboxURL
      locations[checkboxURL] = checkboxFile
      locationsChanged = true
    end
  end
  if not (uncheckedFile and io.exists(uncheckedFile)) then
    if not uncheckedFile then
      uncheckedFile = directory .. self.name .. "/unchecked-25px.png"
      locations[uncheckedURL] = uncheckedFile
      locationsChanged = true
    end
    if uncheckedURL:match("^http") then
      self:downloadFile(uncheckedURL, uncheckedFile)
    elseif io.exists(uncheckedURL) then
      uncheckedFile = uncheckedURL
      locations[uncheckedURL] = uncheckedFile
      locationsChanged = true
    end
  end
  self.checkboxFile = checkboxFile
  self.uncheckedFile = uncheckedFile
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
function checkbox:downloadFile(url, fileName)
  local parts = fileName:split("/")
  parts[#parts] = nil
  local dirName = table.concat(parts, "/") .. "/"
  if not io.exists(dirName) then
    lfs.mkdir(dirName)
  end
  local uname = "checkbox"
  local handlerName = self.name .. url
  local handler = function(event, ...)
    local args = {...}
    local file = #args == 1 and args[1] or args[2]
    if file ~= fileName then
      return true
    end
    if event == "sysDownloadDone" then
      debugc(f"INFO:Checkbox successfully downloaded {file}")
      stopNamedEventHandler(uname, handlerName .. "error")
      return false
    end
    cecho(f"\n<red>ERROR:<reset>Checkbox had an issue downloading an image file to {file}: {args[1]}\n")
    stopNamedEventHandler(uname, handlerName .. "done")
  end
  registerNamedEventHandler(uname, handlerName .. "done", "sysDownloadDone", handler, true)
  registerNamedEventHandler(uname, handlerName .. "error", "sysDownloadError", handler, true)
  downloadFile(fileName, url)
end

--- Responsible for reading the file locations from disk and returning them
-- @local
function checkbox:getFileLocs()
  local locations = {}
  if io.exists(saveFile) then
    table.load(saveFile, locations)
  end
  return locations
end

--- Return the value of the checkbox.
-- @return boolean of the checkbox, true if checked, false otherwise
function checkbox:isChecked()

  if self.checkboxButton.state == "down" then
    return true
  end

  return false

end

--- Set the state of the checkbox.
-- @param state boolean, true to checked, false to unchecked
function checkbox:setChecked(state)

  assert(type(state) == "boolean", "Parameter in setChecked(state) should be boolean")

  if state then
    self.checkboxButton:setState("down")
  else  
    self.checkboxButton:setState("up")
  end
  
end

--- Set the label text associated with this checkbox.
-- @raise error thrown if noLabel = true
-- @param message the message to display next to the checkbox
-- @param color the color of the text
-- @param format the format of the text; bold, italic, etc
function checkbox:echo(message, color, format)

  assert(not self.noLabel, "No label associated with this checkbox.")

  self.checkboxLabel:echo(message, color, format)

end

return checkbox
