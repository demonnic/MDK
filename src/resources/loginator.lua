--- Loginator creates an object which allows you to log things to file at
-- various severity levels, with the ability to only log items above a specific
-- severity to file.
-- @classmod Loginator
-- @author Damian Monogue <demonnic@gmail.com>
-- @copyright 2021 Damian Monogue
-- @license MIT, see LICENSE.lua
local Loginator = {
  format = "h",
  name = "logname",
  fileNameTemplate = "|p/log/Loginator/|y-|M-|d-|n.|e",
  entryTemplate = "|y-|M-|d |h:|m:|s.|x [|c|l|r] |t",
  level = "warn",
  bgColor = "black",
  fontSize = 12,
  fgColor = "white",
}

local levelColors = {error = "red", warn = "DarkOrange", info = "ForestGreen", debug = "ansi_yellow"}
local loggerLevels = {error = 1, warn = 2, info = 3, debug = 4}

local function exists(path)
  local ok, err, code = os.rename(path, path)
  if not ok and code == 13 then
    return true
  end
  return ok, err
end

local function isWindows()
  return package.config:sub(1, 1) == [[\]]
end

local function mkdir_p(path)
  path = path:gsub("\\", "/")
  local pathTbl = path:split("/")
  local cwd = "/"
  if isWindows() then
    cwd = ""
  end
  for index, dirName in ipairs(pathTbl) do
    if index == 1 then
      cwd = cwd .. dirName
    else
      cwd = cwd .. "/" .. dirName
      cwd = cwd:gsub("//", "/")
    end
    if not table.contains({"/", "C:"}, cwd) and not exists(cwd) then
      local ok, err = lfs.mkdir(cwd)
      if not ok then
        return ok, err
      end
    end
  end
  return true
end

local htmlHeaderTemplate = [=[  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" >
    <link href='http://fonts.googleapis.com/css?family=Droid+Sans+Mono' rel='stylesheet' type='text/css'>
    <style type="text/css">
      body {
        background-color: |b;
        color: |c;
        font-family: 'Droid Sans Mono';
        white-space: pre; 
        font-size: |fpx;
      }
    </style>
  </head>
<body><span>
]=]

--- Creates a new Loginator object
--@tparam table options table of options for the logger
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
--     <td class="tg-1">format</td>
--     <td class="tg-1">What format to log in? "h" for html, "a" for ansi, anything else for plaintext.</td>
--     <td class="tg-1">"h"</td>
--   </tr>
--   <tr>
--     <td class="tg-2">name</td>
--     <td class="tg-2">What is the name of the logger? Will replace |n in templates</td>
--     <td class="tg-2">logname</td>
--   </tr>
--   <tr>
--     <td class="tg-1">level</td>
--     <td class="tg-1">What level should the logger operate at? This will control what level the log function defaults to, as well as what logs will actually be written<br>
--                        Only items of an equal or higher severity to this will be written to the log file.</td>
--     <td class="tg-1">"info"</td>
--   </tr>
--   <tr>
--     <td class="tg-2">bgColor</td>
--     <td class="tg-2">What background color to use for html logs</td>
--     <td class="tg-2">"black"</td>
--   </tr>
--   <tr>
--     <td class="tg-1">fgColor</td>
--     <td class="tg-1">What color to use for the main text in html logs</td>
--     <td class="tg-1">"white"</td>
--   </tr>
--   <tr>
--     <td class="tg-2">fontSize</td>
--     <td class="tg-2">What font size to use in html logs</td>
--     <td class="tg-2">12</td>
--   </tr>
--   <tr>
--     <td class="tg-1">levelColors</td>
--     <td class="tg-1">Table with the log level as the key, and the color which corresponds to it as the value</td>
--     <td class="tg-1">{ error = "red", warn = "DarkOrange", info = "ForestGreen", debug = "ansi_yellow" }</td>
--   </tr>
--   <tr>
--     <td class="tg-2">fileNameTemplate</td>
--     <td class="tg-2">A template which will be transformed into the full filename, with path. See template options below for replacements</td>
--     <td class="tg-2">"|p/log/Loginator/|y-|M-|d-|n.|e"</td>
--   </tr>
--   <tr>
--     <td class="tg-1">entryTemplate</td>
--     <td class="tg-1">The template which controls the look of each log entry. See template options below for replacements</td>
--     <td class="tg-1">"|y-|M-|d |h:|m:|s.|x [|c|l|r] |t"</td>
--   </tr>
-- </tbody>
-- </table><br>
-- Table of template options
-- <table class="tg">
-- <thead>
--   <tr>
--     <th>template code</th>
--     <th>what it is replaced with</th>
--     <th>example</th>
--   </tr>
-- </thead>
-- <tbody>
--   <tr>
--     <td class="tg-1">|y</td>
--     <td class="tg-1">the year in 4 digits</td>
--     <td class="tg-1">2021</td>
--   </tr>
--   <tr>
--     <td class="tg-2">|p</td>
--     <td class="tg-2">getMudletHomeDir()</td>
--     <td class="tg-2">/home/demonnic/.config/mudlet/profiles/testprofile</td>
--   </tr>
--   <tr>
--     <td class="tg-1">|M</td>
--     <td class="tg-1">Month as 2 digits</td>
--     <td class="tg-1">05</td>
--   </tr>
--   <tr>
--     <td class="tg-2">|d</td>
--     <td class="tg-2">day, as 2 digits</td>
--     <td class="tg-2">23</td>
--   </tr>
--   <tr>
--     <td class="tg-1">|h</td>
--     <td class="tg-1">hour in 24hr time format, 2 digits</td>
--     <td class="tg-1">03</td>
--   </tr>
--   <tr>
--     <td class="tg-2">|m</td>
--     <td class="tg-2">minute as 2 digits</td>
--     <td class="tg-2">42</td>
--   </tr>
--   <tr>
--     <td class="tg-1">|s</td>
--     <td class="tg-1">seconds as 2 digits</td>
--     <td class="tg-1">34</td>
--   </tr>
--   <tr>
--     <td class="tg-2">|x</td>
--     <td class="tg-2">milliseconds as 3 digits</td>
--     <td class="tg-2">194</td>
--   </tr>
--   <tr>
--     <td class="tg-1">|e</td>
--     <td class="tg-1">Filename extension expected. "html" for html format, "log" for everything else</td>
--     <td class="tg-1">html</td>
--   </tr>
--   <tr>
--     <td class="tg-2">|l</td>
--     <td class="tg-2">The logging level of the entry, in ALLCAPS</td>
--     <td class="tg-2">WARN</td>
--   </tr>
--   <tr>
--     <td class="tg-1">|c</td>
--     <td class="tg-1">The color which corresponds with the logging level. Set via the levelColors table in the options. Example not included.</td>
--     <td class="tg-1"></td>
--   </tr>
--   <tr>
--     <td class="tg-2">|r</td>
--     <td class="tg-2">Reset back to standard color. Used to close |c. Example not included</td>
--     <td class="tg-2"></td>
--   </tr>
--   <tr>
--     <td class="tg-1">|n</td>
--     <td class="tg-1">The name of the logger, set via the options when you have Loginator create it.</td>
--     <td class="tg-1">CoolPackageLog</td>
--   </tr>
--</tbody>
--</table>
--@return newly created logger object
function Loginator:new(options)
  options = options or {}
  local optionsType = type(options)
  if optionsType ~= "table" then
    return nil, f "Loginator:new(options) options as table expected, got {optionsType}"
  end
  local me = table.deepcopy(options)
  me.levelColors = me.levelColors or {}
  local lcType = type(me.levelColors)
  if lcType ~= "table" then
    return nil, f "Loginator:new(options) provided options.levelColors must be a table, but you provided a {lcType}"
  end
  for lvl,clr in pairs(levelColors) do
    me.levelColors[lvl] = me.levelColors[lvl] or clr
  end
  setmetatable(me, self)
  self.__index = self
  return me
end

---@local
function Loginator:processTemplate(str, level)
  local lvl = level or self.level
  local timeTable = getTime()
  for what, with in pairs({
    ["|y"] = function()
      return timeTable.year
    end,
    ["|p"] = getMudletHomeDir,
    ["|M"] = function()
      return string.format("%02d", timeTable.month)
    end,
    ["|d"] = function()
      return string.format("%02d", timeTable.day)
    end,
    ["|h"] = function()
      return string.format("%02d", timeTable.hour)
    end,
    ["|m"] = function()
      return string.format("%02d", timeTable.min)
    end,
    ["|s"] = function()
      return string.format("%02d", timeTable.sec)
    end,
    ["|x"] = function()
      return string.format("%03d", timeTable.msec)
    end,
    ["|e"] = function()
      return (self.format:starts("h") and "html" or "log")
    end,
    ["|l"] = function()
      return lvl:upper()
    end,
    ["|c"] = function()
      return self:getColor(lvl)
    end,
    ["|r"] = function()
      return self:getReset()
    end,
    ["|n"] = function()
      return self.name
    end,
  }) do
    if str:find(what) then
      str = str:gsub(what, with())
    end
  end
  return str
end

--- Set the color to associate with a logging level post-creation
--@param color The color to set for the level, as a string. Can be any valid color string for cecho, decho, or hecho.
--@param level The level to set the color for. Must be one of 'error', 'warn', 'info', or 'debug'
--@return true if the color is updated, or nil+error if it could not be updated for some reason.
function Loginator:setColorForLevel(color, level)
  if not color then
    return nil, "You must provide a color to set"
  end
  if not level then
    return nil, "You must provide a level to set the color for"
  end
  if not loggerLevels[level] then
    return nil, "Invalid level. Valid levels are 'error', 'warn', 'info', or 'debug'"
  end
  if not Geyser.Color.parse(color) then
    return nil, "You must provide a color which can be parsed by Geyser.Color.parse. Examples are 'blue' (cecho), '<128,0,0>' (decho), '#aa3388' (hecho), or {128,0,0} (table of r,g,b values)"
  end
  self.levelColors[level] = color
  return true
end

---@local
function Loginator:getColor(level)
  if self.format == "t" then
    return ""
  end
  local r, g, b = Geyser.Color.parse((self.levelColors[level] or {128, 128, 128}))
  if self.format == "h" then
    return string.format("<span style='color: rgb(%d,%d,%d);'>", r, g, b)
  elseif self.format == "a" then
    return string.format("\27[38:2::%d:%d:%dm", r, g, b)
  end
  return ""
end

---@local
function Loginator:getReset()
  if self.format == "t" then
    return ""
  elseif self.format == "h" then
    return "</span>"
  elseif self.format == "a" then
    return "\27[39;49m"
  end
  return ""
end

--- Returns the full path and filename to the logfile
function Loginator:getFullFilename()
  return self:processTemplate(self.fileNameTemplate)
end

--- Write an error level message to the logfile. Error level messages are always written.
--@param msg the message to log
--@return true if msg written, nil+error if error
function Loginator:error(msg)
  return self:log(msg, "error")
end

--- Write a warn level message to the logfile.
-- Msg is only written if the logger level is <= warn
-- From most to least severe the levels are:
-- error > warn > info > debug
--@param msg the message to log
--@return true if msg written, false if skipped due to level, nil+error if error
function Loginator:warn(msg)
  return self:log(msg, "warn")
end

--- Write an info level message to the logfile.
-- Msg is only written if the logger level is <= info
-- From most to least severe the levels are:
-- error > warn > info > debug
--@param msg the message to log
--@return true if msg written, false if skipped due to level, nil+error if error
function Loginator:info(msg)
  return self:log(msg, "info")
end

--- Write a debug level message to the logfile.
-- Msg is only written if the logger level is debug
-- From most to least severe the levels are:
-- error > warn > info > debug
--@param msg the message to log
--@return true if msg written, false if skipped due to level, nil+error if error
function Loginator:debug(msg)
  return self:log(msg, "debug")
end

--- Write a message to the log file and optionally specify the level
--@param msg the message to log
--@param level the level to log the message at. Defaults to the level of the logger itself if not provided.
--@return true if msg written, false if skipped due to level, nil+error if error
function Loginator:log(msg, level)
  level = level or self.level
  local levelNumber = loggerLevels[level]
  if not levelNumber then
    return nil, f"Unknown logging level: {level}. Valid levels are 'error', 'warn', 'info', and 'debug'"
  end
  local displayLevelNumber = loggerLevels[self.level]
  if levelNumber > displayLevelNumber then
    return false
  end
  local filename = self:getFullFilename()
  local filteredMsg = self:processTemplate(self.entryTemplate, level):gsub("|t", msg)
  local ok, err = self:createPathIfNotExists(filename)
  if err then
    debugc(err)
    return ok, err
  end
  if self.format == "h" and not io.exists(filename) then
    filteredMsg = self:getHtmlHeader() .. filteredMsg
  end
  local file, err = io.open(filename, "a")
  if not file then
    err = string.format("Logger %s failed to open %s because: %s\n", self.name, filename, err)
    debugc(err)
    return nil, err
  end
  file:write(filteredMsg .. "\n")
  file:close()
  return true
end

--- Uses openUrl() to request your OS open the logfile in the appropriate application. Usually your web browser for html and text editor for all others.
function Loginator:open()
  openUrl(self:getFullFilename())
end

--- Uses openUrl() to request your OS open the directory the logfile resides in. This allows for easier browsing if you have more than one file.
function Loginator:openDir()
  openUrl(self:getPath())
end

--- Returns the path to the log file (directory in which the file resides) as a string
--@param filename optional filename to return the path of. If not supplied, with use the logger's current filename
function Loginator:getPath(filename)
  filename = filename or self:getFullFilename()
  filename = filename:gsub([[\]], "/")
  local filenameTable = filename:split("/")
  filenameTable[#filenameTable] = nil
  local path = table.concat(filenameTable, "/")
  return path
end

---@local
function Loginator:createPathIfNotExists(filename)
  if exists(filename) then
    return false
  end
  filename = filename:gsub([[\]], "/")
  local path = self:getPath(filename)
  if exists(path) then
    return false
  end
  local ok, err = mkdir_p(path)
  if not ok then
    err = string.format("Could not create directory for log files: %s\n Reason was: %s", path, err)
    return nil, err
  end
  return true
end

---@local
function Loginator:getHtmlHeader()
  local header = htmlHeaderTemplate
  header = header:gsub("|b", self.bgColor)
  header = header:gsub("|c", self.fgColor)
  header = header:gsub("|f", self.fontSize)
  return header
end

return Loginator
