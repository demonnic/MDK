local RadioButton = {
  parent = Geyser.Container,
  name = 'RadioButtonClass',
  radioButtonLocation = "https://demonnic.github.io/image-assets/radio-button.png",
  radioButtonSelectedLocation = "https://demonnic.github.io/image-assets/radio-button-selected.png",
  selected = 0,
  amount = 2,
  buttons = {}
}

RadioButton.__index = RadioButton
setmetatable(RadioButton, RadioButton.parent)

local directory = getMudletHomeDir() .. "/radiobutton/"
local saveFile = directory .. "fileLocations.lua"
if not io.exists(directory) then
  lfs.mkdir(directory)
end


function RadioButton:new(cons, container)
  cons = cons or {}
  local consType = type(cons)
  if consType ~= "table" then
    printError(f"RadioButton:new(cons, container): cons as table of options expected, got {consType}!", true, true)
  end
  cons.name = cons.name or Geyser.nameGen("RadioButton")
  RadioButton.amount = cons.amount or 2
  local me = self.parent:new(cons, container)
  setmetatable(me, self)
  me:createComponents()
  return me
end


function RadioButton:createDisplay()

  local vboxContainer = Geyser.Container:new({ x = 0, y = 0,
                                              width = "100%",
                                              height = "100%"
                                              }, self)
                                              
  for i = 1,RadioButton.amount do 

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
                            }, vboxContainer)
    end
  
end


function RadioButton:createComponents()

  self:obtainImages()
  self:createDisplay()

end


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


function RadioButton:getFileLocs()
  local locations = {}
  if io.exists(saveFile) then
    table.load(saveFile, locations)
  end
  return locations
end

function RadioButton:setSelected(clicked)

  -- set all buttons unselected
  for i = 1,#RadioButton.buttons do
    RadioButton.buttons[i]:setStyle("background-color: white; border-image: url(".. self.radioButtonFile ..");")
  end

  -- then set the appropriate one
  RadioButton.buttons[clicked]:setStyle("background-color: white; border-image: url(".. self.radioButtonSelectedFile ..");")
  RadioButton.selected = clicked
  
  echo("DEBUG: " .. RadioButton.selected .. " selected\n")

end

function RadioButton:getSelected()

  return RadioButton.selected

end


return RadioButton
