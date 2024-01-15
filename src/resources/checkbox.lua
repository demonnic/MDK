local checkbox = {
  parent = Geyser.Container,
  name = 'CheckboxClass',
  checkboxLocation = "https://demonnic.github.io/image-assets/checkbox-25px.png",
  uncheckedLocation = "https://demonnic.github.io/image-assets/unchecked-25px.png",
  noLabel = false
}

checkbox.__index = checkbox
setmetatable(checkbox, checkbox.parent)


--local gss = Geyser.StyleSheet
local directory = getMudletHomeDir() .. "/checkbox/"
local saveFile = directory .. "fileLocations.lua"
if not io.exists(directory) then
  lfs.mkdir(directory)
end


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


function checkbox:createComponents()

  self:obtainImages()
  self:createDisplay()

end


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


function checkbox:getFileLocs()
  local locations = {}
  if io.exists(saveFile) then
    table.load(saveFile, locations)
  end
  return locations
end


function checkbox:isChecked()

  if self.checkboxButton.state == "down" then
    return true
  end

  return false

end

function checkbox:setChecked(state)

  assert(type(state) == "boolean", "Parameter in setChecked(state) should be boolean")

  if state then
    self.checkboxButton:setState("down")
  else  
    self.checkboxButton:setState("up")
  end
  
end


function checkbox:echo(message, color, format)

  assert(not self.noLabel, "No label associated with this checkbox.")

  self.checkboxLabel:echo(message, color, format)

end

return checkbox
