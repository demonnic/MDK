--- MiniConsole with logging capabilities
-- @classmod LoggingConsole
-- @author Damian Monogue <demonnic@gmail.com>
-- @copyright 2020 Damian Monogue
-- @license MIT, see LICENSE.lua
local homedir = getMudletHomeDir():gsub("\\", "/")
local pathOfThisFile = (...):match("(.-)[^%.]+$")
local dt = require(pathOfThisFile .. "demontools")
local exists, htmlHeader, htmlHeaderPattern = dt.exists, dt.htmlHeader, dt.htmlHeaderPattern

local LoggingConsole = {log = true, logFormat = "h", path = "|h/log/consoleLogs/|y/|m/|d/", fileName = "|n.|e"}

--- Creates and returns a new LoggingConsole.
-- @param cons table of constraints. Includes all the valid Geyser.MiniConsole constraints, plus
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
--     <td class="tg-1">log</td>
--     <td class="tg-1">Should the miniconsole be logging?</td>
--     <td class="tg-1">true</td>
--   </tr>
--   <tr>
--     <td class="tg-2">logFormat</td>
--     <td class="tg-2">"h" for html, "t" for plaintext, "l" for log (with ansi)</td>
--     <td class="tg-2">h</td>
--   </tr>
--   <tr>
--     <td class="tg-1">path</td>
--     <td class="tg-1">The path the file lives in. It is templated.<br>|h is replaced by the profile homedir.<br>|y by 4 digit year.<br>|m by 2 digit month<br>|d by 2 digit day<br>|n by the name constraint<br>|e by the file extension (html for h logType, log for others)</td>
--     <td class="tg-1">"|h/log/consoleLogs/|y/|m/|d/"</td>
--   </tr>
--   <tr>
--     <td class="tg-2">fileName</td>
--     <td class="tg-2">The name of the log file. It is templated, same as path above</td>
--     <td class="tg-2">"|n.|e"</td>
--   </tr>
-- </tbody>
-- </table>
-- @param container the container for the console
-- @usage
-- local LoggingConsole = require("MDK.loggingconsole")
-- myLoggingConsole = LoggingConsole:new({
-- name = "my logging console",
--   x = 0,
--   y = 0,
--   height = 200,
--   width = 400,
-- }) -- just like making a miniconsole, really
function LoggingConsole:new(cons, container)
  cons = cons or {}
  local consType = type(cons)
  assert(consType == "table", "LoggingConsole:new(cons, container): cons must be a valid table of constraints. Got: " .. consType)
  local me = Geyser.MiniConsole:new(cons, container)
  setmetatable(me, self)
  self.__index = self
  return me
end

--- Returns the file extension of the logfile this console will log to
function LoggingConsole:getExtension()
  local extension = "log"
  if table.contains({"h", "html"}, self.logFormat) then
    extension = "html"
  end
  return extension
end

--- Returns a string with all templated items replaced
---@tparam string str The templated string to transform
---@local
function LoggingConsole:transformTemplate(str)
  local ttbl = getTime()
  local year = ttbl.year
  local month = string.format("%02d", ttbl.month)
  local day = string.format("%02d", ttbl.day)
  local name = self.name
  local extension = self:getExtension()
  str = str:gsub("|h", homedir)
  str = str:gsub("|y", year)
  str = str:gsub("|m", month)
  str = str:gsub("|d", day)
  str = str:gsub("|n", name)
  str = str:gsub("|e", extension)
  return str
end

--- Returns the path to the logfile for this console
function LoggingConsole:getPath()
  local path = self:transformTemplate(self.path)
  if not path:ends("/") then
    path = path .. "/"
  end
  return path
end

--- Sets the path to use for the log file.
-- @param path the path to put the log file in. It is templated.<br>|h is replaced by the profile homedir.<br>|y by 4 digit year.<br>|m by 2 digit month<br>|d by 2 digit day<br>|n by the name constraint<br>|e by the file extension (html for h logType, log for others)
function LoggingConsole:setPath(path)
  self.path = path
end

--- Returns the filename for the logfile for this console
function LoggingConsole:getFileName()
  local fileName = self:transformTemplate(self.fileName)
  fileName = fileName:gsub("[<>:'\"/\\?*]", "_")
  return fileName
end

--- Sets the fileName to use for the log file.
-- @param fileName the fileName to use for the logfile. It is templated.<br>|h is replaced by the profile homedir.<br>|y by 4 digit year.<br>|m by 2 digit month<br>|d by 2 digit day<br>|n by the name constraint<br>|e by the file extension (html for h logType, log for others)
function LoggingConsole:setFileName(fileName)
  self.fileName = fileName
end

--- Returns the pull path and filename for the logfile for this console
function LoggingConsole:getFullFilename()
  local path = self:getPath()
  local fileName = self:getFileName()
  local fullPath = path .. fileName
  fullPath = fullPath:gsub("|", "_")
  return fullPath
end

--- Turns logging for this console on
function LoggingConsole:enableLogging()
  self.log = true
end

--- Turns logging for this console off
function LoggingConsole:disableLogging()
  self.log = false
end

--- Creates the path for the logfile for this console if necessary
---@local
function LoggingConsole:createPathIfNotExists()
  local path = self:transformTemplate(self.path)
  if not path:ends("/") then
    path = path .. "/"
  end
  if not exists(path) then
    local ok, err = dt.mkdir_p(path)
    if not ok then
      assert(false, "Could not create directory for log files:" .. path .. "\n Reason was: " .. err)
    end
  end
  return true
end

--- Handles actually writing to the log file
---@local
function LoggingConsole:writeToLog(str)
  local fileName = self:getFullFilename()
  self:createPathIfNotExists()
  if self:getExtension() == "html" then
    if not io.exists(fileName) then
      str = htmlHeader .. str
    end
    str = str
  end
  local file, err = io.open(fileName, "a")
  if not file then
    echo(err .. "\n")
    return
  end
  file:write(str)
  file:close()
end

local parent = Geyser.MiniConsole
--- Handler function which does the lifting for c/d/h/echo and appendBuffer to provide the logfile writing functionality
---@param str the string to echo. Use "" for appends
---@param etype the type of echo. Valid are "c", "d", "h", "e", and "a"
---@param log Allows you to override the default behaviour defined by the .log property. Pass true to definitely log, false to skip logging.
---@local
function LoggingConsole:xEcho(str, etype, log)
  if log == nil then
    log = self.log
  end
  local logStr
  local logType = self.logFormat
  if logType:find("h") then
    logType = "h"
  elseif logType ~= "t" then
    logType = "l"
  end
  if etype == "d" then -- decho
    if logType == "h" then
      logStr = dt.decho2html(str)
    elseif logType == "t" then
      logStr = dt.decho2string(str)
    else
      logStr = dt.decho2ansi(str)
    end
    parent.decho(self, str)
  elseif etype == "c" then -- cecho
    if logType == "h" then
      logStr = dt.cecho2html(str)
    elseif logType == "t" then
      logStr = dt.cecho2string(str)
    else
      logStr = dt.cecho2ansi(str)
    end
    parent.cecho(self, str)
  elseif etype == "h" then -- hecho
    if logType == "h" then
      logStr = dt.hecho2html(str)
    elseif logType == "t" then
      logStr = dt.hecho2string(str)
    else
      logStr = dt.hecho2ansi(str)
    end
    parent.hecho(self, str)
  elseif etype == "a" then -- append
    str = dt.append2decho()
    str = str .. "\n"
    if logType == "h" then
      logStr = dt.decho2html(str)
    elseif logType == "t" then
      logStr = dt.decho2string(str)
    else
      logStr = dt.decho2ansi(str)
    end
    parent.appendBuffer(self)
  elseif etype == "e" then -- echo
    if logType == "h" then
      logStr = dt.decho2html(str)
    else
      logStr = str
    end
    parent.echo(self, str)
  end
  if log then
    self:writeToLog(logStr)
  end
end

--- Does the actual lifting of echoing links/popups
-- @local
function LoggingConsole:xEchoLink(text, lType, command, hint, useFormat, log)
  if log == nil then
    log = self.log
  end
  local logStr = ""
  if lType:starts("c") then
    if self.logFormat == "h" then
      logStr = dt.cecho2html(text)
    elseif self.logFormat == "l" then
      logStr = dt.cecho2ansi(text)
    elseif self.logFormat == "t" then
      logStr = dt.cecho2string(text)
    end
    if lType:ends("p") then
      parent.cechoPopup(self, text, command, hint, useFormat)
    else
      parent.cechoLink(self, text, command, hint, useFormat)
    end
  elseif lType:starts("d") then
    if self.logFormat == "h" then
      logStr = dt.decho2html(text)
    elseif self.logFormat == "l" then
      logStr = dt.decho2ansi(text)
    elseif self.logFormat == "t" then
      logStr = dt.decho2string(text)
    end
    if lType:ends("p") then
      parent.dechoPopup(self, text, command, hint, useFormat)
    else
      parent.dechoLink(self, text, command, hint, useFormat)
    end
  elseif lType:starts("h") then
    if self.logFormat == "h" then
      logStr = dt.hecho2html(text)
    elseif self.logFormat == "l" then
      logStr = dt.hecho2ansi(text)
    elseif self.logFormat == "t" then
      logStr = dt.hecho2string(text)
    end
    if lType:ends("p") then
      parent.hechoPopup(self, text, command, hint, useFormat)
    else
      parent.hechoLink(self, text, command, hint, useFormat)
    end
  elseif lType:starts("e") then
    logStr = text
    if lType:ends("p") then
      parent.echoPopup(self, text, command, hint, useFormat)
    else
      parent.echoLink(self, text, command, hint, useFormat)
    end
  end
  if log then
    self:writeToLog(logStr)
  end
end

--- cechoLink for LoggingConsole
-- @param text the text to use for the link
-- @param command the command to send when the link is clicked, as text. IE [[send("sleep")]]
-- @param hint A tooltip which is displayed when the mouse is over the link
-- @param log Should we log this line? Defaults to self.log if not passed.
function LoggingConsole:cechoLink(text, command, hint, log)
  self:xEchoLink(text, "c", command, hint, true, log)
end

--- dechoLink for LoggingConsole
-- @param text the text to use for the link
-- @param command the command to send when the link is clicked, as text. IE [[send("sleep")]]
-- @param hint A tooltip which is displayed when the mouse is over the link
-- @param log Should we log this line? Defaults to self.log if not passed.
function LoggingConsole:dechoLink(text, command, hint, log)
  self:xEchoLink(text, "d", command, hint, true, log)
end

--- hechoLink for LoggingConsole
-- @param text the text to use for the link
-- @param command the command to send when the link is clicked, as text. IE [[send("sleep")]]
-- @param hint A tooltip which is displayed when the mouse is over the link
-- @param log Should we log this line? Defaults to self.log if not passed.
function LoggingConsole:hechoLink(text, command, hint, log)
  self:xEchoLink(text, "h", command, hint, true, log)
end

--- echoLink for LoggingConsole
-- @param text the text to use for the link
-- @param command the command to send when the link is clicked, as text. IE [[send("sleep")]]
-- @param hint A tooltip which is displayed when the mouse is over the link
-- @param useCurrentFormat If set to true, will look like the text around it. If false it will be blue and underline.
-- @param log Should we log this line? Defaults to self.log if not passed. If you want to pass this you must pass in useCurrentFormat
-- @usage myLoggingConsole:echoLink("This is a link!", [[send("sleep")]], "sleep") -- text "This is a link" will send("sleep") when clicked and be blue w/ underline. Defaut log behaviour (self.log)
-- @usage myLoggingConsole:echoLink("This is a link!", [[send("sleep")]], "sleep", false, false) -- same as above, but forces it not to log regardless of self.log setting
-- @usage myLoggingConsole:echoLink("This is a link!", [[send("sleep")]], "sleep", true, true) -- same as above, but forces it to log regardless of self.log setting and the text will look like anything else echoed to the console.
function LoggingConsole:echoLink(text, command, hint, useCurrentFormat, log)
  self:xEchoLink(text, "e", command, hint, useCurrentFormat, log)
end

--- cechoPopup for LoggingConsole
-- @param text the text to use for the link
-- @param commands the commands to send when the popup is activated, as table. IE {[[send("sleep")]], [[send("stand")]]}
-- @param hints A tooltip which is displayed when the mouse is over the link. IE {{"sleep", "stand"}}
-- @param log Should we log this line? Defaults to self.log if not passed.
function LoggingConsole:cechoPopup(text, commands, hints, log)
  self:xEchoLink(text, "cp", commands, hints, true, log)
end

--- dechoPopup for LoggingConsole
-- @param text the text to use for the link
-- @param commands the commands to send when the popup is activated, as table. IE {[[send("sleep")]], [[send("stand")]]}
-- @param hints A tooltip which is displayed when the mouse is over the link. IE {{"sleep", "stand"}}
-- @param log Should we log this line? Defaults to self.log if not passed.
function LoggingConsole:dechoPopup(text, commands, hints, log)
  self:xEchoLink(text, "dp", commands, hints, true, log)
end

--- hechoPopup for LoggingConsole
-- @param text the text to use for the link
-- @param commands the commands to send when the popup is activated, as table. IE {[[send("sleep")]], [[send("stand")]]}
-- @param hints A tooltip which is displayed when the mouse is over the link. IE {{"sleep", "stand"}}
-- @param log Should we log this line? Defaults to self.log if not passed.
function LoggingConsole:hechoPopup(text, commands, hints, log)
  self:xEchoLink(text, "hp", commands, hints, true, log)
end

--- echoPopup for LoggingConsole
-- @param text the text to use for the link
-- @param commands the commands to send when the popup is activated, as table. IE {[[send("sleep")]], [[send("stand")]]}
-- @param hints A tooltip which is displayed when the mouse is over the link. IE {{"sleep", "stand"}}
-- @param useCurrentFormat If set to true, will look like the text around it. If false it will be blue and underline.
-- @param log Should we log this line? Defaults to self.log if not passed. If you want to pass this you must pass in useCurrentFormat
-- @usage myLoggingConsole:echoPopup("This is a link!", {[[send("sleep")]], [[send("stand")]], {"sleep", "stand"}) -- text "This is a link" will send("sleep") when clicked and be blue w/ underline. Defaut log behaviour (self.log)
-- @usage myLoggingConsole:echoPopup("This is a link!", {[[send("sleep")]], [[send("stand")]], {"sleep", "stand"}, false, false) -- same as above, but forces it not to log regardless of self.log setting
-- @usage myLoggingConsole:echoPopup("This is a link!", {[[send("sleep")]], [[send("stand")]], {"sleep", "stand"}, true, true) -- same as above, but forces it to log regardless of self.log setting and the text will look like anything else echoed to the console.
function LoggingConsole:echoPopup(text, commands, hints, useCurrentFormat, log)
  self:xEchoLink(text, "ep", commands, hints, useCurrentFormat, log)
end

--- Append copy()ed text to the console
-- @param log should we log this?
function LoggingConsole:appendBuffer(log)
  self:xEcho("", "a", log)
end

--- Append copy()ed text to the console
-- @param log should we log this?
function LoggingConsole:append(log)
  self:xEcho("", "a", log)
end

--- echo's a string to the console.
-- @param str the string to echo
-- @param log should this be logged? Used to override the .log constraint
function LoggingConsole:echo(str, log)
  self:xEcho(str, "e", log)
end

--- hecho's a string to the console.
-- @param str the string to hecho
-- @param log should this be logged? Used to override the .log constraint
function LoggingConsole:hecho(str, log)
  self:xEcho(str, "h", log)
end

--- decho's a string to the console.
-- @param str the string to decho
-- @param log should this be logged? Used to override the .log constraint
function LoggingConsole:decho(str, log)
  self:xEcho(str, "d", log)
end

--- cecho's a string to the console.
-- @param str the string to cecho
-- @param log should this be logged? Used to override the .log constraint
function LoggingConsole:cecho(str, log)
  self:xEcho(str, "c", log)
end

--- Replays the last X lines from the console's log file, if it exists
-- @param numberOfLines The number of lines to replay from the end of the file
function LoggingConsole:replay(numberOfLines)
  local fileName = self:getFullFilename()
  if not exists(fileName) then
    return
  end
  local file = io.open(fileName, "r")
  local lines = file:read("*a")
  if self:getExtension() == "html" then
    for _, line in ipairs(htmlHeaderPattern:split("\n")) do
      if line ~= "" then
        lines = lines:gsub(line .. "\n", "")
      end
    end
    lines = dt.html2decho(lines)
  else
    lines = ansi2decho(lines)
  end
  local linesTbl = lines:split("\n")
  local result
  if #linesTbl <= numberOfLines then
    result = lines
  else
    result = ""
    local start = #linesTbl - numberOfLines
    for index, str in ipairs(linesTbl) do
      if index >= start then
        result = string.format("%s\n%s", result, str)
      end
    end
  end
  self:decho(result, false)
end

setmetatable(LoggingConsole, parent)

return LoggingConsole
