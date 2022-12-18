--- Collection of miscellaneous functions and tools which don't necessarily warrant their own module/class
-- @module demontools
-- @author Damian Monogue <demonnic@gmail.com>
-- @copyright 2020 Damian Monogue
-- @license MIT, see LICENSE.lua
local DemonTools = {}
local cheatConsole = Geyser.MiniConsole:new({name = "DemonnicCheatConsole", width = 4000, wrapWidth = 10000, color = "black"})
cheatConsole:hide()
local function exists(path)
  path = path:gsub([[\$]], "")
  path = path:gsub([[/$]], "")
  return io.exists(path)
end

local function isWindows()
  return package.config:sub(1, 1) == [[\]]
end

local function isDir(path)
  if not exists(path) then return false end
    path = path:gsub([[\]], "/")
  if path:ends("/") then
    path = path:sub(1,-2)
  end
  local ok, err, code = lfs.attributes(path, "mode")
  if ok then
    if ok == "directory" then
      return true
    else
      return false
    end
  end
  return ok, err, code
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

local htmlHeader = [=[  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" >
    <link href='http://fonts.googleapis.com/css?family=Droid+Sans+Mono' rel='stylesheet' type='text/css'>
    <style type="text/css">
      body {
        background-color: black;
        font-family: 'Droid Sans Mono';
        white-space: pre; 
        font-size: 12px;
      }
    </style>
  </head>
<body><span>
]=]

local htmlHeaderPattern = [=[  <!DOCTYPE HTML PUBLIC "%-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
  <head>
    <meta http%-equiv="Content%-Type" content="text/html;charset=utf%-8" >
    <link href='http://fonts.googleapis.com/css%?family=Droid%+Sans%+Mono' rel='stylesheet' type='text/css'>
    <style type="text/css">
      body {
        background%-color: black;
        font%-family: 'Droid Sans Mono';
        white%-space: pre; 
        font%-size: 12px;
      }
    </style>
  </head>
<body><span>
]=]

-- internal function, recursively digs for a value within subtables if possible
local function digForValue(dataFrom, tableTo)
  if dataFrom == nil or table.size(tableTo) == 0 then
    return dataFrom
  else
    local newData = dataFrom[tableTo[1]]
    table.remove(tableTo, 1)
    return digForValue(newData, tableTo)
  end
end

-- Internal function, used to turn a string variable name into a value
local function getValueAt(accessString)
  if accessString == "" then
    return nil
  end
  local tempTable = accessString:split("%.")
  local accessTable = {}
  for i, v in ipairs(tempTable) do
    if tonumber(v) then
      accessTable[i] = tonumber(v)
    else
      accessTable[i] = v
    end
  end
  return digForValue(_G, accessTable)
end

-- internal sorting function, sorts first by hue, then luminosity, then value
local function sortColorsByHue(lhs, rhs)
  local lh, ll, lv = unpack(lhs.sort)
  local rh, rl, rv = unpack(rhs.sort)
  if lh < rh then
    return true
  elseif lh > rh then
    return false
  elseif ll < rl then
    return true
  elseif ll > rl then
    return false
  else
    return lv < rv
  end
end

-- internal sorting function, removes _ from snake_case and compares to camelCase
local function sortColorsByName(a, b)
  local aname = string.gsub(string.lower(a.name), "_", "")
  local bname = string.gsub(string.lower(b.name), "_", "")
  return aname < bname
end

-- internal function used to turn sorted colors table into columns
local function chunkify(tbl, num_chunks)
  local pop = function(t)
    return table.remove(t, 1)
  end
  tbl = table.deepcopy(tbl)
  local tblsize = #tbl
  local base_chunk_size = tblsize / num_chunks
  local chunky_chunks = tblsize % num_chunks
  local chunks = {}
  for i = 1, num_chunks do
    local chunk_size = base_chunk_size
    if i <= chunky_chunks then
      chunk_size = chunk_size + 1
    end
    local chunk = {}
    for j = 1, chunk_size do
      chunk[j] = pop(tbl)
    end
    chunks[i] = chunk
  end
  return chunks
end

-- internal function, converts rgb to hsv
-- found at https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua#L89
local function rgbToHsv(r, g, b)
  r, g, b = r / 255, g / 255, b / 255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, v
  v = max
  local d = max - min
  if max == 0 then
    s = 0
  else
    s = d / max
  end
  if max == min then
    h = 0
    -- achromatic
  else
    if max == r then
      h = (g - b) / d
      if g < b then
        h = h + 6
      end
    elseif max == g then
      h = (b - r) / d + 2
    elseif max == b then
      h = (r - g) / d + 4
    end
    h = h / 6
  end
  return h, s, v
end

-- internal stepping function, removes some of the noise for a more pleasing sort
-- cribbed from the python on https://www.alanzucconi.com/2015/09/30/colour-sorting/
local function step(r, g, b)
  local lum = math.sqrt(.241 * r + .691 * g + .068 * b)
  local reps = 8
  local h, s, v = rgbToHsv(r, g, b)
  local h2 = math.floor(h * reps)
  local lum2 = math.floor(lum * reps)
  local v2 = math.floor(v * reps)
  if h2 % 2 == 1 then
    v2 = reps - v2
    lum2 = reps - lum2
  end
  return h2, lum2, v2
end

local function calc_luminosity(r, g, b)
  r = r < 11 and r / (255 * 12.92) or ((0.055 + r / 255) / 1.055) ^ 2.4
  g = g < 11 and g / (255 * 12.92) or ((0.055 + g / 255) / 1.055) ^ 2.4
  b = b < 11 and b / (255 * 12.92) or ((0.055 + b / 255) / 1.055) ^ 2.4
  return (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
end

local function include(color, options)
  if options.removeDupes and (string.find(color, "_") and not color:starts("ansi")) or string.find(color:lower(), 'gray') then
    return false
  end
  if options.removeAnsi255 and string.find(color, "ansi_%d%d%d") then
    return false
  end
end

local function echoColor(color, options)
  local rgb = color.rgb
  local fgc = "white"
  if calc_luminosity(unpack(rgb)) > 0.5 then
    fgc = "black"
  end
  local colorString
  if options.justText then
    colorString = string.format('<%s:%s> %-23s<reset> ', color.name, 'black', color.name)
  else
    colorString = string.format('<%s:%s> %-23s<reset> ', fgc, color.name, color.name)
  end
  if options.window == "main" then
    if options.echoOnly then
      cecho(colorString)
    else
      cechoLink(colorString, [[appendCmdLine("]] .. color.name .. [[")]], table.concat(rgb, ", "), true)
    end
  else
    if options.echoOnly then
      cecho(options.window, colorString)
    else
      cechoLink(options.window, colorString, [[appendCmdLine("]] .. color.name .. [[")]], table.concat(rgb, ", "), true)
    end
  end
end

local cnames = {}

local function _color_name(rgb)
  if cnames[rgb] then
    return cnames[rgb]
  end
  local least_distance = math.huge
  local cname = ""
  for name, color in pairs(color_table) do
    local color_distance = math.sqrt((color[1] - rgb[1]) ^ 2 + (color[2] - rgb[2]) ^ 2 + (color[3] - rgb[3]) ^ 2)
    if color_distance < least_distance then
      least_distance = color_distance
      cname = name
    end
  end
  cnames[rgb] = cname
  return cname
end

-- converts decho color information to ansi escape sequences
local function rgbToAnsi(rgb)
  local result = ""
  local cols = rgb:split(":")
  local fore = cols[1]
  local back = cols[2]
  if fore ~= "" then
    local components = fore:split(",")
    result = string.format("%s\27[38:2::%s:%s:%sm", result, components[1] or "0", components[2] or "0", components[3] or "0")
  end
  if back then
    local components = back:split(",")
    result = string.format("%s\27[48:2::%s:%s:%sm", result, components[1] or "0", components[2] or "0", components[3] or "0")
  end
  return result
end

-- converts a 6 digit hex color code to ansi escape sequence
local function hexToAnsi(hexcode)
  local result = ""
  local cols = hexcode:split(",")
  local fore = cols[1]
  local back = cols[2]
  if fore ~= "" then
    local components = {tonumber(fore:sub(1, 2), 16), tonumber(fore:sub(3, 4), 16), tonumber(fore:sub(5, 6), 16)}
    result = string.format("%s\27[38:2::%s:%s:%sm", result, components[1] or "0", components[2] or "0", components[3] or "0")
  end
  if back then
    local components = {tonumber(back:sub(1, 2), 16), tonumber(back:sub(3, 4), 16), tonumber(back:sub(5, 6), 16)}
    result = string.format("%s\27[48:2::%s:%s:%sm", result, components[1] or "0", components[2] or "0", components[3] or "0")
  end
  return result
end

local function hexToRgb(hexcode)
  local result = "<"
  local cols = hexcode:split(",")
  local fore = cols[1]
  local back = cols[2]
  if fore ~= "" then
    local r, g, b = Geyser.Color.parse("#" .. fore)
    result = string.format("%s%s,%s,%s", result, r, g, b)
  end
  if back then
    local r, g, b = Geyser.Color.parse("#" .. back)
    result = string.format("%s:%s,%s,%s", result, r, g, b)
  end
  return string.format("%s>", result)
end

local function rgbToHex(rgb)
  local result = "#"
  local cols = rgb:split(":")
  local fore = cols[1]
  local back = cols[2]
  if fore ~= "" then
    local r, g, b = unpack(string.split(fore, ","))
    result = string.format("%s%02x%02x%02x", result, r, g, b)
  end
  if back then
    local r, g, b = unpack(string.split(back, ","))
    result = string.format("%s,%02x%02x%02x", result, r, g, b)
  end
  return result
end

local function rgbToCname(rgb)
  local result = "<"
  local cols = rgb:split(":")
  local fore = cols[1]
  local back = cols[2]
  if fore ~= "" then
    result = string.format("%s%s", result, _color_name(fore:split(",")))
  end
  if back then
    result = string.format("%s:%s", result, _color_name(back:split(",")))
  end
  return string.format("%s>", result)
end

local function cnameToRgb(cname)
  local result = "<"
  local cols = cname:split(":")
  local fore = cols[1]
  local back = cols[2]
  if fore ~= "" then
    local rgb = color_table[fore] or {0, 0, 0}
    result = string.format("%s%s", result, table.concat(rgb, ","))
  end
  if back then
    local rgb = color_table[back] or {0, 0, 0}
    result = string.format("%s:%s", result, table.concat(rgb, ","))
  end
  return string.format("%s>", result)
end

local function toFromDecho(from, to, text)
  local patterns = {d = _Echos.Patterns.Decimal[1], c = _Echos.Patterns.Color[1], h = _Echos.Patterns.Hex[1]}
  local funcs = {d = {c = rgbToCname, h = rgbToHex, a = rgbToAnsi}, c = {d = cnameToRgb}, h = {d = hexToRgb}}
  local resetCodes = {d = "<r>", h = "#r", c = "<reset>", a = "\27[39;49m"}

  local colorPattern = patterns[from]
  local func = funcs[from][to]
  local reset = resetCodes[to]
  local result = ""
  for str, color, res in rex.split(text, colorPattern) do
    result = result .. str
    if color then
      if color:sub(1, 1) == "|" then
        color = color:gsub("|c", "#")
      end
      if from == "h" then
        result = result .. func(color:sub(2, -1))
      else
        result = result .. func(color:match("<(.+)>"))
      end
    end
    if res then
      result = result .. reset
    end
  end
  return result
end

local function decho2cecho(text)
  return toFromDecho("d", "c", text)
end

local function cecho2decho(text)
  return toFromDecho("c", "d", text)
end

local function decho2hecho(text)
  return toFromDecho("d", "h", text)
end

local function hecho2decho(text)
  return toFromDecho("h", "d", text)
end

local function cecho2ansi(text)
  local dtext = cecho2decho(text)
  return decho2ansi(dtext)
end

local function cecho2hecho(text)
  local dtext = cecho2decho(text)
  return decho2hecho(dtext)
end

local function hecho2cecho(text)
  local dtext = hecho2decho(text)
  return decho2cecho(dtext)
end

local function ansi2decho(tstring)
  local cpattern = [=[\e\[([0-9;:]+)m]=]
  local result = ""
  local resets = {"39;49", "00", "0"}
  local colours = {
    [0] = color_table.ansiBlack,
    [1] = color_table.ansiRed,
    [2] = color_table.ansiGreen,
    [3] = color_table.ansiYellow,
    [4] = color_table.ansiBlue,
    [5] = color_table.ansiMagenta,
    [6] = color_table.ansiCyan,
    [7] = color_table.ansiWhite,
  }
  local lightColours = {
    [0] = color_table.ansiLightBlack,
    [1] = color_table.ansiLightRed,
    [2] = color_table.ansiLightGreen,
    [3] = color_table.ansiLightYellow,
    [4] = color_table.ansiLightBlue,
    [5] = color_table.ansiLightMagenta,
    [6] = color_table.ansiLightCyan,
    [7] = color_table.ansiLightWhite,
  }

  local function colorCodeToRGB(color, parts)
    local rgb
    if color ~= 8 then
      rgb = colours[color]
    else
      if parts[2] == "5" then
        local color_number = tonumber(parts[3])
        if color_number < 8 then
          rgb = colours[color_number]
        elseif color_number > 7 and color_number < 16 then
          rgb = lightColours[color_number - 8]
        else
          rgb = color_table["ansi_" .. color_number]
        end
      elseif parts[2] == "2" then
        local r = parts[4] or 0
        local g = parts[5] or 0
        local b = parts[6] or 0
        if r == "" then
          r = 0
        end
        if g == "" then
          g = 0
        end
        if b == "" then
          b = 0
        end
        rgb = {r, g, b}
      end
    end
    return rgb
  end

  for str, color in rex.split(tstring, cpattern) do
    result = result .. str
    if color then
      if table.contains(resets, color) then
        result = result .. "<r>"
      else
        local parts
        if color:find(";") then
          parts = color:split(";")
        else
          parts = color:split(":")
        end
        local code = parts[1]
        if code:starts("3") then
          color = tonumber(code:sub(2, 2))
          local rgb = colorCodeToRGB(color, parts)
          result = string.format("%s<%s,%s,%s>", result, rgb[1], rgb[2], rgb[3])
        elseif code:starts("4") then
          color = tonumber(code:sub(2, 2))
          local rgb = colorCodeToRGB(color, parts)
          result = string.format("%s<:%s,%s,%s>", result, rgb[1], rgb[2], rgb[3])
        elseif tonumber(code) >= 90 and tonumber(code) <= 97 then
          local rgb = colours[tonumber(code) - 90]
          result = string.format("%s<%s,%s,%s>", result, rgb[1], rgb[2], rgb[3])
        elseif tonumber(code) >= 100 and tonumber(code) <= 107 then
          local rgb = colours[tonumber(code) - 100]
          result = string.format("%s<:%s,%s,%s>", result, rgb[1], rgb[2], rgb[3])
        end
      end
    end
  end
  return result
end

local function decho2ansi(text)
  local colorPattern = _Echos.Patterns.Decimal[1]
  local result = ""
  for str, color, res in rex.split(text, colorPattern) do
    result = result .. str
    if color then
      result = result .. rgbToAnsi(color:match("<(.+)>"))
    end
    if res then
      result = result .. "\27[39;49m"
    end
  end
  return result
end

local function hecho2ansi(text)
  local colorPattern = _Echos.Patterns.Hex[1]
  local result = ""
  for str, color, res in rex.split(text, colorPattern) do
    result = result .. str
    if color then
      if color:sub(1, 1) == "|" then
        color = color:gsub("|c", "#")
      end
      result = result .. hexToAnsi(color:sub(2, -1))
    end
    if res then
      result = result .. "\27[39;49m"
    end
  end
  return result
end

local function ansi2hecho(text)
  local dtext = ansi2decho(text)
  return decho2hecho(dtext)
end

local function displayColors(options)
  options = options or {}
  local optionsType = type(options)
  assert(optionsType == "table", "displayColors(options) argument error: options as table expects, got " .. optionsType)
  options.cols = options.cols or 4
  options.search = options.search or ""
  options.sort = options.sort or false
  if options.removeDupes == nil then
    options.removeDupes = true
  end
  if options.removeAnsi255 == nil then
    options.removeAnsi255 = true
  end
  if options.columnSort == nil then
    options.columnSort = true
  end
  if type(options.window) == "table" then
    options.window = options.window.name
  end
  options.window = options.window or "main"
  local color_table = options.color_table or color_table
  local cols, search, sort = options.cols, options.search, options.sort
  local colors = {}
  for k, v in pairs(color_table) do
    local color = {}
    color.rgb = v
    color.name = k
    color.sort = {step(unpack(v))}
    if include(k, options) and k:lower():find(search) then
      table.insert(colors, color)
    end
  end
  if sort then
    table.sort(colors, sortColorsByName)
  else
    table.sort(colors, sortColorsByHue)
  end
  if options.columnSort then
    local columns_table = chunkify(colors, cols)
    local lines = #columns_table[1]
    for i = 1, lines do
      for j = 1, cols do
        local color = columns_table[j][i]
        if color then
          echoColor(color, options)
        end
      end
      echo(options.window, "\n")
    end
  else
    local i = 1
    for _, k in ipairs(colors) do
      echoColor(k, options)
      if i == cols then
        echo(options.window, "\n")
        i = 1
      else
        i = i + 1
      end
    end
    if i ~= 1 then
      echo(options.window, "\n")
    end
  end
end

local function cecho2string(text)
  local pattern = _Echos.Patterns.Color[2]
  local result = rex.gsub(text, pattern, "")
  return result
end

local function decho2string(text)
  local pattern = _Echos.Patterns.Decimal[2]
  local result = rex.gsub(text, pattern, "")
  return result
end

local function hecho2string(text)
  local pattern = _Echos.Patterns.Hex[2]
  local result = rex.gsub(text, pattern, "")
  return result
end

local function append2decho()
  cheatConsole:clear()
  cheatConsole:appendBuffer()
  local str = copy2decho(cheatConsole.name)
  cheatConsole:clear()
  return str
end

local function html2decho(text)
  text = text:gsub(htmlHeaderPattern, "")
  text = text:gsub("<span style='color: rgb%((%d+,%d+,%d+)%);background: rgb%((%d+,%d+,%d+)%);'>", "<%1:%2>")
  text = text:gsub("<br>", "\n")
  text = text:gsub("</span>", "")
  return text
end

local function html2cecho(text)
  local dtext = html2decho(text)
  return decho2cecho(dtext)
end

local function html2hecho(text)
  local dtext = html2decho(text)
  return decho2hecho(dtext)
end

local function html2ansi(text)
  local dtext = html2decho(text)
  return decho2ansi(dtext)
end

local function html2string(text)
  local dtext = html2decho(text)
  return decho2string(text)
end

local function consoleToString(options)
  options = options or {}
  options.win = options.win or "main"
  options.format = options.format or "d"
  options.start_line = options.start_line or 0
  if options.includeHtmlWrapper == nil then
    options.includeHtmlWrapper = true
  end
  local console_line_count = options.win == "main" and getLineCount() or getLineCount(options.win)
  if not options.end_line then
    options.end_line = console_line_count
  end
  if options.end_line > console_line_count then
    options.end_line = console_line_count
  end
  local start, finish, format = options.start_line, options.end_line, options.format
  local current_x, current_y
  if options.win == "main" then
    current_x = getColumnNumber()
    current_y = getLineNumber()
  else
    current_x = getColumnNumber(options.win)
    current_y = getLineNumber(options.win)
  end

  local function move(x, y)
    if options.win == "main" then
      return moveCursor(x, y)
    else
      return moveCursor(options.win, x, y)
    end
  end
  local function gcl()
    local win, raw
    if options.win ~= "main" then
      win = options.win
      raw = getCurrentLine(win)
    else
      win = nil
      raw = getCurrentLine()
    end
    if raw == "" then
      return ""
    end
    if format == "h" then
      return copy2html(win)
    elseif format == "d" then
      return copy2decho(win)
    elseif format == "a" then
      return decho2ansi(copy2decho(win))
    elseif format == "c" then
      return decho2cecho(copy2decho(win))
    elseif format == "x" then
      return decho2hecho(copy2decho(win))
    elseif format == "r" then
      return raw
    end
  end
  local lines = {}
  if format == "h" and options.includeHtmlWrapper then
    lines[#lines + 1] = htmlHeader
  end
  for line_number = start, finish do
    move(0, line_number)
    lines[#lines + 1] = gcl()
  end
  if format == "h" and options.includeHtmlWrapper then
    lines[#lines + 1] = "</span></body></html>"
  end
  moveCursor(current_x, current_y)
  return table.concat(lines, "\n")
end

local function decho2html(text)
  cheatConsole:clear()
  text = text:gsub("\n", "<br>")
  cheatConsole:decho(text)
  local html = copy2html(cheatConsole.name)
  cheatConsole:clear()
  return html
end

local function cecho2html(text)
  local dtext = cecho2decho(text)
  return decho2html(dtext)
end

local function hecho2html(text)
  local dtext = hecho2decho(text)
  return decho2html(dtext)
end

local function ansi2html(text)
  local dtext = ansi2decho(text)
  return decho2html(dtext)
end

local function scientific_round(number, sigDigits)
  local decimalPlace = string.find(number, "%.")
  if not decimalPlace or (sigDigits < decimalPlace) then
    local numberTable = {}
    local count = 1
    for digit in string.gmatch(number, "%d") do
      table.insert(numberTable, digit)
    end
    local endNumber = ""
    for i, digit in ipairs(numberTable) do
      if i < sigDigits then
        endNumber = endNumber .. digit
      end
      if i == sigDigits then
        if tonumber(numberTable[i + 1]) >= 5 then
          endNumber = endNumber .. digit + 1
        else
          endNumber = endNumber .. digit
        end
      end
      if i > sigDigits and (not decimalPlace or (i < decimalPlace)) then
        endNumber = endNumber .. "0"
      end
    end
    return tonumber(endNumber)
  else
    local decimalDigits = sigDigits - decimalPlace + 1
    return tonumber(string.format("%" .. decimalPlace - 1 .. "." .. decimalDigits .. "f", number))
  end
end

local function roundInt(number)
  return math.floor(number + 0.5)
end

function string.tobyte(self)
  return (self:gsub('.', function(c)
    return string.byte(c)
  end))
end

function string.tocolor(self)
  -- This next bit takes the string and 'unshuffles' it, breaking it into odds and evens
  -- reverses the evens, then adds the odds to the new even set. So demonnic becomes cnoedmni
  -- this makes sure that names which are similar in the beginning don't color the same
  -- especially since we have to cut the number for the random seed due to OSX using a default
  -- randomseed if you feed it something too large, which made every name longer than 7 characters
  -- always the same color, no matter what it was.
  local strTable = {}
  local part1 = {}
  local part2 = {}
  self:gsub(".", function(c)
    table.insert(strTable, c)
  end)
  for index, value in ipairs(strTable) do
    if (index % 2 == 0) then
      table.insert(part1, value)
    else
      table.insert(part2, value)
    end
  end
  local newStr = string.reverse(table.concat(part1)) .. table.concat(part2)
  -- end munging of the original string to get more uniqueness
  math.randomseed(string.cut(newStr:tobyte(), 18))
  local r = math.random(0, 255)
  local g = math.random(0, 255)
  local b = math.random(0, 255)
  math.randomseed(os.time())
  return {r, g, b}
end

local function colorMunge(strForColor, strToEcho, format)
  format = format or 'd'
  local rgb = strForColor:tocolor()
  local color
  if format == "d" then
    color = string.format("<%s>", table.concat(rgb, ","))
  elseif format == "c" then
    color = string.format("<%s>", _color_name(rgb))
  elseif format == "h" then
    color = string.format("#%02x%02x%02x", rgb[1], rgb[2], rgb[3])
  end
  return color .. strToEcho
end

local function colorMungeEcho(strForColor, strToEcho, format, win)
  format = format or "d"
  win = win or "main"
  local str = colorMunge(strForColor, strToEcho, format)
  local func
  if format == "d" then
    func = decho
  end
  if format == "c" then
    func = cecho
  end
  if format == "h" then
    func = hecho
  end
  if win == "main" then
    func(str)
  else
    func(win, str)
  end
end

local function milliToHuman(milliseconds)
  local totalseconds = math.floor(milliseconds / 1000)
  milliseconds = milliseconds % 1000
  local seconds = totalseconds % 60
  local minutes = math.floor(totalseconds / 60)
  local hours = math.floor(minutes / 60)
  minutes = minutes % 60
  return string.format("%02d:%02d:%02d:%03d", hours, minutes, seconds, milliseconds)
end

--- Takes a list table and returns it as a table of 'chunks'. If the table has 12 items and you ask for 3 chunks, each chunk will have 4 items in it
-- @tparam table tbl The table you want to turn into chunks. Must be traversable using ipairs()
-- @tparam number num_chunks The number of chunks to turn the table into
-- @usage local dt = require("MDK.demontools")
-- testTable = { "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten" }
-- display(dt.chunkify(testTable, 3))
-- --displays the following
-- {
--   {
--     "one",
--     "two",
--     "three",
--     "four"
--   },
--   {
--     "five",
--     "six",
--     "seven"
--   },
--   {
--     "eight",
--     "nine",
--     "ten"
--   }
-- }

function DemonTools.chunkify(tbl, num_chunks)
  return chunkify(tbl, num_chunks)
end

--- Takes an ansi colored text string and returns a cecho colored one
-- @tparam string text the text to convert
-- @usage   dt.ansi2cecho("[31mTest")
-- --returns "<ansiRed>Test"
function DemonTools.ansi2cecho(text)
  local dtext = ansi2decho(text)
  return decho2cecho(dtext)
end

--- Takes an ansi colored text string and returns a decho colored one. Handles 256 color SGR codes better than Mudlet's ansi2decho
-- @tparam string text the text to convert
-- @usage   dt.ansi2decho("[31mTest") --returns "<128,0,0>Test"
-- @usage dt.ansi2decho("[38:2::127:0:0mTest") --returns "<127,0,0>Test"
-- @usage ansi2decho("[38:2::127:0:0mTest") -- doesn't parse this format of colors and so returns "[38:2::127:0:0mTest"
function DemonTools.ansi2decho(text)
  return ansi2decho(text)
end

--- Takes an ansi colored text string and returns a hecho colored one
-- @tparam string text the text to convert
-- @usage   dt.ansi2hecho("[31mTest")
-- --returns "#800000Test"
function DemonTools.ansi2hecho(text)
  return ansi2hecho(text)
end

--- Takes an cecho colored text string and returns a decho colored one
-- @tparam string text the text to convert
-- @usage  dt.cecho2decho("<green>Test") --returns "<0,255,0>Test"
function DemonTools.cecho2decho(text)
  return cecho2decho(text)
end

--- Takes an cecho colored text string and returns an ansi colored one
-- @tparam string text the text to convert
-- @usage dt.cecho2ansi("<green>Test") --returns "[38:2::0:255:0mTest"
function DemonTools.cecho2ansi(text)
  return cecho2ansi(text)
end

--- Takes an cecho colored text string and returns a hecho colored one
-- @tparam string text the text to convert
-- @usage dt.cecho2hecho("<green>Test") --returns "#00ff00Test"
function DemonTools.cecho2hecho(text)
  return cecho2hecho(text)
end

--- Takes an decho colored text string and returns a cecho colored one
-- @tparam string text the text to convert
-- @usage   dt.decho2cecho("<127,0,0:0,0,127>Test") --returns "<ansiRed:ansi_blue>Test"
function DemonTools.decho2cecho(text)
  return decho2cecho(text)
end

--- Takes an decho colored text string and returns an ansi colored one
-- @tparam string text the text to convert
-- @usage dt.decho2ansi("<127,0,0:0,0,127>Test") --returns "[38:2::127:0:0m[48:2::0:0:127mTest"
function DemonTools.decho2ansi(text)
  return decho2ansi(text)
end

--- Takes an decho colored text string and returns an hecho colored one
-- @tparam string text the text to convert
-- @usage dt.decho2hecho("<127,0,0:0,0,127>Test") --returns "#7f0000,00007fTest"
function DemonTools.decho2hecho(text)
  return decho2hecho(text)
end

--- Takes a decho colored text string and returns html.
-- @tparam string text the text to convert
function DemonTools.decho2html(text)
  return decho2html(text)
end

--- Takes a cecho colored text string and returns html.
-- @tparam string text the text to convert
function DemonTools.cecho2html(text)
  return cecho2html(text)
end

--- Takes a hecho colored text string and returns html.
-- @tparam string text the text to convert
function DemonTools.hecho2html(text)
  return hecho2html(text)
end

--- Takes an ansi colored text string and returns html.
-- @tparam string text the text to convert
function DemonTools.ansi2html(text)
  return ansi2html(text)
end

--- Takes an html colored string of the sort turned out by the DemonTools *2html functions and returns a cecho string
-- @tparam string text the text to convert
function DemonTools.html2cecho(text)
  return html2cecho(text)
end

--- Takes an html colored string of the sort turned out by the DemonTools *2html functions and returns a decho string
-- @tparam string text the text to convert
function DemonTools.html2decho(text)
  return html2decho(text)
end

--- Takes an html colored string of the sort turned out by the DemonTools *2html functions and returns an ansi string
-- @tparam string text the text to convert
function DemonTools.html2ansi(text)
  return html2ansi(text)
end

--- Takes an html colored string of the sort turned out by the DemonTools *2html functions and returns an hecho string
-- @tparam string text the text to convert
function DemonTools.html2hecho(text)
  return html2hecho(text)
end

--- Takes a cecho string and returns it without the formatting
-- @param text the text to transform
function DemonTools.cecho2string(text)
  return cecho2string(text)
end

--- Takes a decho string and returns it without the formatting
-- @param text the text to transform
function DemonTools.decho2string(text)
  return decho2string(text)
end

--- Takes a hecho string and returns it without the formatting
-- @param text the text to transform
function DemonTools.hecho2string(text)
  return hecho2string(text)
end

--- Takes an html colored string of the sort turned out by the DemonTools *2html functions and returns a clean string
function DemonTools.html2string(text)
  return html2string(text)
end

--- Takes an hecho colored text string and returns a ansi colored one
-- @tparam string text the text to convert
-- @usage dt.hecho2ansi("#7f0000,00007fTest") --returns "[38:2::127:0:0m[48:2::0:0:127mTest"
function DemonTools.hecho2ansi(text)
  return hecho2ansi(text)
end

--- Takes an hecho colored text string and returns a cecho colored one
-- @tparam string text the text to convert
-- @usage   dt.hecho2cecho("#7f0000,00007fTest") --returns "<ansiRed:ansi_blue>Test"
function DemonTools.hecho2cecho(text)
  return hecho2cecho(text)
end

--- Takes an hecho colored text string and returns a decho colored one
-- @tparam string text the text to convert
-- @usage   dt.hecho2decho("#7f0000,00007fTest") --returns "<127,0,0:0,0,127>Test"
function DemonTools.hecho2decho(text)
  return hecho2decho(text)
end

--- Takes the currently copy()ed item and returns it as a decho string
function DemonTools.append2decho()
  return append2decho()
end

--- Dump the contents of a miniconsole, user window, or the main window in one of several formats, as determined by a table of options
-- @tparam table options Table of options which controls which console and how it returns the data.
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
--     <td class="tg-odd">format</td>
--     <td class="tg-odd">What format to return the text as? 'h' for html, 'c' for cecho, 'a' for ansi, 'd' for decho, and 'x' for hecho</td>
--     <td class="tg-odd">"d"</td>
--   </tr>
--   <tr>
--     <td class="tg-even">win</td>
--     <td class="tg-even">what console/window to dump the buffer of?</td>
--     <td class="tg-even">"main"</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">start_line</td>
--     <td class="tg-odd">What line to start dumping the buffer from?</td>
--     <td class="tg-odd">0</td>
--   </tr>
--   <tr>
--     <td class="tg-even">end_line</td>
--     <td class="tg-even">What line to stop dumping the buffer on?</td>
--     <td class="tg-even">Last line of the console</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">includeHtmlWrapper</td>
--     <td class="tg-odd">If the format is html, should it include the front and back portions required to make it a functioning html page?</td>
--     <td class="tg-odd">true</td>
--   </tr>
-- </tbody>
-- </table>
function DemonTools.consoleToString(options)
  return consoleToString(options)
end

--- Alternative to Mudlet's showColors(), this one has additional options.
-- @tparam table options table of options which control the output of displayColors
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
--     <td class="tg-odd">cols</td>
--     <td class="tg-odd">Number of columsn wide to display the colors in</td>
--     <td class="tg-odd">4</td>
--   </tr>
--   <tr>
--     <td class="tg-even">search</td>
--     <td class="tg-even">If not the empty string, will check colors against string.find using this property.<br>IE if set to "blue" only colors which include the word 'blue' would be listed</td>
--     <td class="tg-even">""</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">sort</td>
--     <td class="tg-odd">If true, sorts alphabetically. Otherwise sorts based on the color value</td>
--     <td class="tg-odd">false</td>
--   </tr>
--   <tr>
--     <td class="tg-even">echoOnly</td>
--     <td class="tg-even">If true, colors will not be clickable links</td>
--     <td class="tg-even">false</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">window</td>
--     <td class="tg-odd">What window/console to echo the colors out to.</td>
--     <td class="tg-odd">"main"</td>
--   </tr>
--   <tr>
--     <td class="tg-even">removeDupes</td>
--     <td class="tg-even">If true, will remove snake_case entries and 'gray' in favor of 'grey'</td>
--     <td class="tg-even">true</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">columnSort</td>
--     <td class="tg-odd">If true, will print top-to-bottom, then left-to-right. false is like showColors</td>
--     <td class="tg-odd">true</td>
--   </tr>
--   <tr>
--     <td class="tg-even">justText</td>
--     <td class="tg-even">If true, will echo the text in the color and leave the background black.<br>If false, the background will be the colour(like showColors).</td>
--     <td class="tg-even">false</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">color_table</td>
--     <td class="tg-odd">Table of colors to display. If you provide your own table, it must be in the same format as Mudlet's own color_table</td>
--     <td class="tg-odd">color_table</td>
--   </tr>
-- </tbody>
-- </table>
function DemonTools.displayColors(options)
  return displayColors(options)
end

--- Rounds a number to the nearest whole integer
-- @param number the number to round off
-- @usage dt.roundInt(8.3) -- returns 8
-- @usage dt.roundInt(10.7) -- returns 11
function DemonTools.roundInt(number)
  local num = tonumber(number)
  local numType = type(num)
  assert(numType == "number", string.format("DemonTools.roundInt(number): number as number expected, got %s", type(number)))
  return roundInt(num)
end

--- Rounds a number to a specified number of significant digits
-- @tparam number number the number to round
-- @tparam number sig_digits the number of significant digits to keep
-- @usage dt.scientific_round(1348290, 3) -- will return 1350000
-- @usage dt.scientific_found(123.3452, 5) -- will return 123.34
function DemonTools.scientific_round(number, sig_digits)
  return scientific_round(number, sig_digits)
end

--- Returns a color table {r,g,b} derived from str. Will return the same color every time for the same string.
-- @tparam string str the string to turn into a color.
-- @usage   dt.string2color("Demonnic") --returns { 131, 122, 209 }
function DemonTools.string2color(str)
  return string.tocolor(str)
end

--- Returns a colored string where strForColor is run through DemonTools.string2color and applied to strToColor based on format.
-- @tparam string strForColor the string to turn into a color using DemonTools.string2color
-- @tparam string strToColor the string you want to color based on strForColor
-- @param format What format to use for the color portion. "d" for decho, "c" for cecho, or "h" for hecho. Defaults to "d"
-- @usage   dt.colorMunge("Demonnic", "Test") --returns "<131,122,209>Test"
function DemonTools.colorMunge(strForColor, strToColor, format)
  return colorMunge(strForColor, strToColor, format)
end

--- Like colorMunge but also echos the result to win. 
-- @tparam string strForColor the string to turn into a color using DemonTools.string2color
-- @tparam string strToEcho the string you want to color and echo based on strForColor
-- @param format What format to use for the color portion. "d" for decho, "c" for cecho, or "h" for hecho. Defaults to "d"
-- @param win the window to echo to. You must provide the format if you want to change the window. Defaults to "main"
function DemonTools.colorMungeEcho(strForColor, strToEcho, format, win)
  colorMungeEcho(strForColor, strToEcho, format, win)
end

--- Converts milliseconds to hours:minutes:seconds:milliseconds
-- @tparam number milliseconds the number of milliseconds to convert
-- @tparam boolean tbl if true, returns the time as a key/value table instead
-- @usage dt.milliToHuman(37194572) --returns "10:19:54:572"
-- @usage display(dt.milliToHuman(37194572, true))
-- {
--   minutes = 19,
--   original = 37194572,
--   hours = 10,
--   milliseconds = 572,
--   seconds = 54
-- }
function DemonTools.milliToHuman(milliseconds, tbl)
  local human = milliToHuman(milliseconds)
  local output
  if tbl then
    local timetbl = human:split(":")
    output = {
      hours = tonumber(timetbl[1]),
      minutes = tonumber(timetbl[2]),
      seconds = tonumber(timetbl[3]),
      milliseconds = tonumber(timetbl[4]),
      original = milliseconds,
    }
  else
    output = human
  end
  return output
end

--- Takes the name of a variable as a string and returns the value. "health" will return the value in varable health, "gmcp.Char.Vitals" will return the table at gmcp.Char.Vitals, etc
-- @tparam string variableString the string name of the variable you want the value of
-- @usage currentHP = 50
-- dt.getValueAt("currentHP") -- returns 50
function DemonTools.getValueAt(variableString)
  return getValueAt(variableString)
end

--- Returns if a file or directory exists on the filesystem
-- @tparam string path the path to the file or directory to check
function DemonTools.exists(path)
  return exists(path)
end

--- Returns if a path is a directory or not
-- @tparam string path the path to check
function DemonTools.isDir(path)
  return isDir(path)
end

--- Returns true if running on windows, false otherwise
function DemonTools.isWindows()
  return isWindows()
end

--- Creates a directory, creating each directory as necessary along the way.
-- @tparam string path the path to create
function DemonTools.mkdir_p(path)
  return mkdir_p(path)
end

DemonTools.htmlHeader = htmlHeader
DemonTools.htmlHeaderPattern = htmlHeaderPattern

return DemonTools
