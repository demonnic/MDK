--- set of functions for echoing files to things. Uses a slightly hacked up version of f-strings for interpolation/templating
-- @module echofile
-- @author Damian Monogue <demonnic@gmail.com>
-- @copyright 2021 Damian Monogue
-- @copyright 2016 Hisham Muhammad (https://github.com/hishamhm/f-strings/blob/master/LICENSE)
-- @license MIT, see LICENSE.lua
local echofile = {}

-- following functions fiddled with from https://github.com/hishamhm/f-strings/blob/master/F.lua and https://hisham.hm/2016/01/04/string-interpolation-in-lua/
-- it seems to work :shrug:
local load = load

if _VERSION == "Lua 5.1" then
  load = function(code, name, _, env)
    local fn, err = loadstring(code, name)
    if fn then
      setfenv(fn, env)
      return fn
    end
    return nil, err
  end
end

local function f(str)
  local outer_env = _ENV or getfenv(1)
  return (str:gsub("%b{}", function(block)
    local code = block:match("{(.*)}")
    local exp_env = {}
    setmetatable(exp_env, {
      __index = function(_, k)
        local stack_level = 5
        while debug.getinfo(stack_level, "") ~= nil do
          local i = 1
          repeat
            local name, value = debug.getlocal(stack_level, i)
            if name == k then
              return value
            end
            i = i + 1
          until name == nil
          stack_level = stack_level + 1
        end
        return rawget(outer_env, k)
      end,
    })
    local fn, err = load("return " .. code, "expression `" .. code .. "`", "t", exp_env)
    if fn then
      return tostring(fn())
    else
      error(err, 0)
    end
  end))
end

local function xechoFile(options)
  local filename = options.filename
  local window = options.window
  local func = options.func
  local functionName = options.functionName
  local fntype = type(filename)
  if fntype ~= "string" then
    return nil, f("{functionName}: filename as string expected, got {fnType}")
  end
  if not io.exists(filename) then
    return nil, f("{functionName}: {filename} not found")
  end
  local file, err = io.open(filename, "r")
  if not file then
    return nil, err
  end
  local lines = file:read("*a")
  if options.ansi then
    lines = ansi2decho(lines)
  end
  if options.filter then
    lines = f(lines)
  end
  return func(window, lines)
end

local function getOptions(etype, filter, window, filename)
  if filename == nil then
    filename = window
    window = "main"
  end
  local ansi = false
  if etype == "a" then
    etype = 'd'
    ansi = true
  end
  local options = {
    filename = filename,
    window = window,
    func = _G[etype .. "echo"],
    functionName = etype .. "echoFile([window,] filename)",
    ansi = ansi,
    filter = filter,
  }
  return options
end

--- Takes a string and performs interpolation
--- Uses {} as the delimiter. Expressions will be evaluated
---@param str string: The string to interpolate
---@usage echofile = require("MDK.echofile")
--- echofile.f("{1+1}") -- returns "2"
--- local x = 4
--- echofile.f"4+3 = {x+3}" -- returns "4+3 = 7"
function echofile.f(str)
  return f(str)
end

--- reads the contents of a file, converts it to decho and then dechos it
---@param window string: Optional window to cecho to
---@param filename string: Full path to file
---@see echofile.f
---@see echofile.cechoFile
---@usage local ec = require("MDK.echofile")
--- local cechoFile,f = ec.cechoFile, ec.f
--- cechoFile("C:/path/to/file") -- windows1
--- cechoFile("C:\\path\\to\\file") -- windows2
--- cechoFile("/path/to/file") -- Linux/MacOS
--- cechoFile("aMiniConsole", f"{getMudletHomeDir()}/myPkgName/helpfile") -- cecho a file from your pkg to a miniconsole
function echofile.aechoFile(window, filename)
  local options = getOptions("a", false, window, filename)
  return xechoFile(options)
end

--- reads the contents of a file and then cechos it
---@param window string: Optional window to cecho to
---@param filename string: Full path to file
---@see echofile.f
---@see echofile.cechoFilef
---@usage local ec = require("MDK.echofile")
--- local cechoFile,f = ec.cechoFile, ec.f
--- cechoFile("C:/path/to/file") -- windows1
--- cechoFile("C:\\path\\to\\file") -- windows2
--- cechoFile("/path/to/file") -- Linux/MacOS
--- cechoFile("aMiniConsole", f"{getMudletHomeDir()}/myPkgName/helpfile") -- cecho a file from your pkg to a miniconsole
function echofile.aechoFilef(window, filename)
  local options = getOptions("a", true, window, filename)
  return xechoFile(options)
end

--- reads the contents of a file and then cechos it
---@param window string: Optional window to cecho to
---@param filename string: Full path to file
---@see echofile.f
---@usage local ec = require("MDK.echofile")
--- local cechoFile,f = ec.cechoFile, ec.f
--- cechoFile("C:/path/to/file") -- windows1
--- cechoFile("C:\\path\\to\\file") -- windows2
--- cechoFile("/path/to/file") -- Linux/MacOS
--- cechoFile("aMiniConsole", f"{getMudletHomeDir()}/myPkgName/helpfile") -- cecho a file from your pkg to a miniconsole
function echofile.cechoFile(window, filename)
  local options = getOptions("c", false, window, filename)
  return xechoFile(options)
end

--- reads the contents of a file, interpolates it as per echofile.f and then cechos it
---@param window string: Optional window to cecho to
---@param filename string: Full path to file
---@see echofile.f
---@usage local ec = require("MDK.echofile")
--- local cechoFile,f = ec.cechoFile, ec.f
--- cechoFile("C:/path/to/file") -- windows1
--- cechoFile("C:\\path\\to\\file") -- windows2
--- cechoFile("/path/to/file") -- Linux/MacOS
--- cechoFile("aMiniConsole", f"{getMudletHomeDir()}/myPkgName/helpfile") -- cecho a file from your pkg to a miniconsole
function echofile.cechoFilef(window, filename)
  local options = getOptions("c", true, window, filename)
  return xechoFile(options)
end

--- reads the contents of a file and then dechos it
---@param window string: Optional window to decho to
---@param filename string: Full path to file
---@see echofile.f
---@see echofile.cechoFile
function echofile.dechoFile(window, filename)
  local options = getOptions("d", false, window, filename)
  return xechoFile(options)
end

--- reads the contents of a file, interpolates it as per echofile.f and then dechos it
---@param window string: Optional window to decho to
---@param filename string: Full path to file
---@see echofile.f
---@see echofile.cechoFile
function echofile.dechoFilef(window, filename)
  local options = getOptions("d", true, window, filename)
  return xechoFile(options)
end

--- reads the contents of a file and then hechos it
---@param window string: Optional window to hecho to
---@param filename string: Full path to file
---@see echofile.f
---@see echofile.cechoFile
function echofile.hechoFile(window, filename)
  local options = getOptions("h", false, window, filename)
  return xechoFile(options)
end

--- reads the contents of a file, interpolates it as per echofile.f and then hechos it
---@param window string: Optional window to hecho to
---@param filename string: Full path to file
---@see echofile.f
---@see echofile.cechoFile
function echofile.hechoFilef(window, filename)
  local options = getOptions("h", true, window, filename)
  return xechoFile(options)
end

--- reads the contents of a file, interpolates it as per echofile.f and then echos it
---@param window string: Optional window to echo to
---@param filename string: Full path to file
---@see echofile.f
---@see echofile.cechoFile
function echofile.echoFile(window, filename)
  local options = getOptions("", false, window, filename)
  return xechoFile(options)
end

--- reads the contents of a file, interpolates it as per echofile.f and then echos it
---@param window string: Optional window to echo to
---@param filename string: Full path to file
---@see echofile.f
---@see echofile.cechoFile
function echofile.echoFilef(window, filename)
  local options = getOptions("", true, window, filename)
  return xechoFile(options)
end

--- Adds c/d/h/echoFile functions to Geyser miniconsole and userwindow objects
---@usage require("MDK.echofile").patchGeyser()
--- myMC = Geyser.MiniConsole:new({name = "myMC"})
--- myMC:cechoFile(f"{getMudletHomeDir()}/helpfile")
function echofile.patchGeyser()
  if Geyser.MiniConsole.echoFile then
    return
  end
  function Geyser.MiniConsole:echoFile(filename)
    return echofile.echoFile(self.name, filename)
  end
  function Geyser.MiniConsole:echoFilef(filename)
    return echofile.echoFilef(self.name, filename)
  end
  function Geyser.MiniConsole:aechoFile(filename)
    return echofile.aechoFile(self.name, filename)
  end
  function Geyser.MiniConsole:aechoFilef(filename)
    return echofile.aechoFilef(self.name, filename)
  end
  function Geyser.MiniConsole:cechoFile(filename)
    return echofile.cechoFile(self.name, filename)
  end
  function Geyser.MiniConsole:cechoFilef(filename)
    return echofile.cechoFilef(self.name, filename)
  end
  function Geyser.MiniConsole:dechoFile(filename)
    return echofile.dechoFile(self.name, filename)
  end
  function Geyser.MiniConsole:dechoFilef(filename)
    return echofile.dechoFilef(self.name, filename)
  end
  function Geyser.MiniConsole:hechoFile(filename)
    return echofile.hechoFile(self.name, filename)
  end
  function Geyser.MiniConsole:hechoFilef(filename)
    return echofile.hechoFilef(self.name, filename)
  end
end

--- Installs c/d/h/echoFile and f to the global namespace, and adds functions to Geyser
---@usage require("MDK.echofile").installGlobal()
--- f"{1+2}" -- returns "2"
--- dechoFile(f"{getMudletHomeDir()}/fileWithDechoLines.txt") 
--- -- reads contents of fileWithDechoLines.txt from profile directory 
--- -- and dechos them to the main console
function echofile.installGlobal()
  _G.f = f
  _G.echoFile = echofile.echoFile
  _G.echoFilef = echofile.echoFilef
  _G.aechoFile = echofile.aechoFile
  _G.aechoFilef = echofile.aechoFilef
  _G.cechoFile = echofile.cechoFile
  _G.cechoFilef = echofile.cechoFilef
  _G.dechoFile = echofile.dechoFile
  _G.dechoFilef = echofile.dechoFilef
  _G.hechoFile = echofile.hechoFile
  _G.hechoFilef = echofile.hechoFilef
  echofile.patchGeyser()
end

return echofile
