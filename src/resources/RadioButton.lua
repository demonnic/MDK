--- A Geyser object to create a single selection radiobox
-- @classmod RadioButton
-- @author Zooka
local RadioButton = {
  parent = Geyser.Container,
  name = 'RadioButtonClass',
  radioButtonLocation = "https://demonnic.github.io/image-assets/radio-button.png",
  radioButtonSelectedLocation = "https://demonnic.github.io/image-assets/radio-button-selected.png",
  selected = 0,
  amount = 2,
  buttons = {},
  labels = {},
  labelMessages = {}
}

RadioButton.__index = RadioButton
setmetatable(RadioButton, RadioButton.parent)

local directory = getMudletHomeDir() .. "/radiobutton/"
local saveFile = directory .. "fileLocations.lua"
if not io.exists(directory) then
  lfs.mkdir(directory)
end

--- Creates a new radio button. 
-- @tparam table cons a table containing the options for this radiobutton.
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
--     <td>amount</td>
--     <td>The amount of buttons in this radio button.</td>
--     <td>2</td>
--   </tr>
--   <tr>
--     <td>labelMessages</td>
--     <td>The text to assign to a specific button.  Should be equals to the amount of buttons.</td>
--     <td>{"Label 1", "Label 2"}</td>
--   </tr>
--</tbody>
--</table>
-- @param container The Geyser container for this checkbox
function RadioButton:new(cons, container)
  cons = cons or {}
  local consType = type(cons)
  if consType ~= "table" then
    printError(f"RadioButton:new(cons, container): cons as table of options expected, got {consType}!", true, true)
  end
  cons.name = cons.name or Geyser.nameGen("RadioButton")
  RadioButton.amount = cons.amount or 2
  RadioButton.labelMessages = cons.labelMessages or {"Label 1", "Label 2"}
  local me = self.parent:new(cons, container)
  setmetatable(me, self)
  me:createComponents()
  return me
end


--- Create the radiobutton components.
-- @local
-- Creates self.labels[] to hold a display messages.
-- Creates self.buttons[], an amount of Geyser.Buttons with a true/false state.
function RadioButton:createDisplay()


  local labelContainer = Geyser.VBox:new({ x = 0, y = 0,
                                              width = "100%-25px",
                                              height = "100%"
                                              }, self)  

  local buttonContainer = Geyser.VBox:new({ x = "-25r", y = 0,
                                              width = "25px",
                                              height = "100%"
                                              }, self)
                                              
  for i = 1,RadioButton.amount do 

    RadioButton.labels[i] = Geyser.Label:new({
                                name = "RadioLabel" .. i,
                                message = RadioButton.labelMessages[i],
                                color = "white",
                                fgColor = "black"
                            }, labelContainer)

    RadioButton.buttons[i] = Geyser.Button:new({
                                name = "Radio" .. i,
                                x = 0,
                                y = (i-1)*25,
                                width = 25,
                                height = 25,
                                color = "white",
                                style = "background-color: white; border-image: url("..self.radioButtonFile..");",
                                msg             = "",
                                tooltip         = "",
                                clickFunction    = function() self:setSelected(i) end,
                                twoState        = false,
                                state           = "up",
                                toolTipDuration = 0
                            }, buttonContainer)
    end
  
end


--- Creates the components that make up the radiobutton UI. 
-- @local
-- Obtains the radiobutton images.
-- Generate white styling for the radiobutton.
-- @todo user generated CSS styling
function RadioButton:createComponents()

  self:obtainImages()
  self:createDisplay()

end


--- Obtains the selected and unselected images for the radiobutton.
-- @local
-- Gets the previously saved file locations.
-- Checks if the selected image exists at the radioButtonSelectedLocation. 
-- If not, it will download the image from a URL or copy a local file. It saves 
-- the new location.
-- Does the same for the unselected image at the radioButtonLocation.
-- Saves any new locations to the save file.
-- Sets self.radioButtonFile and self.radioButtonSelectedFile to the locations of the images.
function RadioButton:obtainImages()
  local locations = self:getFileLocs()
  local radioButtonURL = self.radioButtonLocation
  local radioButtonSelectedURL = self.radioButtonSelectedLocation
  local radioButtonFile = locations[radioButtonURL]
  local radioButtonSelectedFile = locations[radioButtonSelectedURL]
  local locationsChanged = false
  if not (radioButtonFile and io.exists(radioButtonFile)) then
    if not radioButtonFile then
      radioButtonFile = directory .. self.name .. "/radio-button.png"
      locations[radioButtonURL] = radioButtonFile
      locationsChanged = true
    end
    if radioButtonURL:match("^http") then
      self:downloadFile(radioButtonURL, radioButtonFile)
    elseif io.exists(radioButtonURL) then
      radioButtonFile = radioButtonURL
      locations[radioButtonURL] = radioButtonFile
      locationsChanged = true
    end
  end
  if not (radioButtonSelectedFile and io.exists(radioButtonSelectedFile)) then
    if not radioButtonSelectedFile then
      radioButtonSelectedFile = directory .. self.name .. "/radio-button-selected.png"
      locations[radioButtonSelectedURL] = radioButtonSelectedFile
      locationsChanged = true
    end
    if radioButtonSelectedURL:match("^http") then
      self:downloadFile(radioButtonSelectedURL, radioButtonSelectedFile)
    elseif io.exists(radioButtonSelectedURL) then
      radioButtonSelectedFile = radioButtonSelectedURL
      locations[radioButtonSelectedURL] = radioButtonSelectedFile
      locationsChanged = true
    end
  end
  self.radioButtonFile = radioButtonFile
  self.radioButtonSelectedFile = radioButtonSelectedFile
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
function RadioButton:downloadFile(url, fileName)
  local parts = fileName:split("/")
  parts[#parts] = nil
  local dirName = table.concat(parts, "/") .. "/"
  if not io.exists(dirName) then
    lfs.mkdir(dirName)
  end
  local uname = "radiobutton"
  local handlerName = self.name .. url
  local handler = function(event, ...)
    local args = {...}
    local file = #args == 1 and args[1] or args[2]
    if file ~= fileName then
      return true
    end
    if event == "sysDownloadDone" then
      debugc(f"INFO:RadioButton successfully downloaded {file}")
      stopNamedEventHandler(uname, handlerName .. "error")
      return false
    end
    cecho(f"\n<red>ERROR:<reset>RadioButton had an issue downloading an image file to {file}: {args[1]}\n")
    stopNamedEventHandler(uname, handlerName .. "done")
  end
  registerNamedEventHandler(uname, handlerName .. "done", "sysDownloadDone", handler, true)
  registerNamedEventHandler(uname, handlerName .. "error", "sysDownloadError", handler, true)
  downloadFile(fileName, url)
end


--- Responsible for reading the file locations from disk and returning them
-- @local
function RadioButton:getFileLocs()
  local locations = {}
  if io.exists(saveFile) then
    table.load(saveFile, locations)
  end
  return locations
end


--- Set the state of the radiobutton.
-- @param clicked integer, the button position number as referenced in the constructor
function RadioButton:setSelected(clicked)

  -- set all buttons unselected
  for i = 1,#RadioButton.buttons do
    RadioButton.buttons[i]:setStyle("background-color: white; border-image: url(".. self.radioButtonFile ..");")
  end

  -- then set the appropriate one
  RadioButton.buttons[clicked]:setStyle("background-color: white; border-image: url(".. self.radioButtonSelectedFile ..");")
  RadioButton.selected = clicked
  
--  echo("DEBUG: " .. RadioButton.selected .. " selected\n")

end

--- Return which button is selected
-- @return the integer of the button currently selected
function RadioButton:getSelected()

  return RadioButton.selected

end

--- Set the labels of the buttons to new ones.
-- @param labelMessages table of strings containing the messages
function RadioButton:setLabels(labelMessages)

  RadioButton.labelMessages = labelMessages
  for i = 1, RadioButton.amount do
    RadioButton.labels[i]:echo(RadioButton.labelMessages[i])
  end
  
end


return RadioButton
