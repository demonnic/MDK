--- ftext
-- functions to format and print text, and the objects which use them
-- @module ftext
-- @author Damian Monogue <demonnic@gmail.com>
-- @copyright 2020 Damian Monogue
-- @copyright 2021 Damian Monogue
-- @copyright 2022 Damian Monogue
-- @license MIT, see LICENSE.lua
local ftext = {}
local dec = {"d", "decimal", "dec"}
local hex = {"h", "hexidecimal", "hex"}
local col = {"c", "color", "colour", "col", "name"}

--- Performs wordwrapping on a string, given a length limit. Does not understand colour tags and will count them as characters in the string
-- @tparam string str the string to wordwrap
-- @tparam number limit the line length to wrap at
function ftext.wordWrap(str, limit, indent, indent1)
  -- pulled from http://lua-users.org/wiki/StringRecipes
  indent = indent or ""
  indent1 = indent1 or indent
  limit = limit or 72
  local here = 1 - #indent1
  local function check(sp, st, word, fi)
    if fi - here > limit then
      here = st - #indent
      return "\n" .. indent .. word
    end
  end
  return indent1 .. str:gsub("(%s+)()(%S+)()", check)
end

--- Performs wordwrapping on a string, while ignoring color tags of a given type.
-- @tparam string text the string you are wordwrapping
-- @tparam number limit the line length to wrap at
-- @tparam string type What type of color codes to ignore. 'c' for cecho, 'd' for decho, 'h' for hecho, and anything else or nil to pass the string on to wordWrap
function ftext.xwrap(text, limit, type)
  local colorPattern
  if table.contains(dec, type) then
    colorPattern = _Echos.Patterns.Decimal[1]
  elseif table.contains(hex, type) then
    colorPattern = _Echos.Patterns.Hex[1]
  elseif table.contains(col, type) then
    colorPattern = _Echos.Patterns.Color[1]
  else
    return ftext.wordWrap(text, limit)
  end
  local strippedString = rex.gsub(text, colorPattern, "")
  local strippedLines = ftext.wordWrap(strippedString, limit):split("\n")
  local lineIndex = 1
  local line = ""
  local strLine = ""
  local lines = {}
  local strLines = {}
  local workingLine = strippedLines[lineIndex]:split("")
  local workingLineLength = #workingLine
  local lineColumn = 0
  for str, color, res in rex.split(text, colorPattern) do
    if res then
      if type == "Hex" then
        color = "#r"
      elseif type == "Dec" then
        color = "<r>"
      elseif type == "Color" then
        color = "<reset>"
      end
    end
    color = color or ""
    local strLen = str:len()
    if lineColumn + strLen <= workingLineLength then
      strLine = strLine .. str
      line = line .. str .. color
      lineColumn = lineColumn + strLen
    else
      local neededChars = workingLineLength - lineColumn
      local take = str:sub(1, neededChars)
      local leave = str:sub(neededChars + 1, -1)
      strLine = strLine .. take
      line = line .. take
      table.insert(lines, line)
      table.insert(strLines, strLine)
      line = ""
      strLine = ""
      lineIndex = lineIndex + 1
      workingLine = strippedLines[lineIndex]:split("")
      workingLineLength = #workingLine
      lineColumn = 0
      if leave:sub(1, 1) == " " then
        leave = leave:sub(2, -1)
      end
      while leave ~= "" do
        take = leave:sub(1, workingLineLength)
        leave = leave:sub(workingLineLength + 1, -1)
        if leave:sub(1, 1) == " " then
          leave = leave:sub(2, -1)
        end
        if take:len() < workingLineLength then
          lineColumn = take:len()
          line = line .. take .. color
          strLine = strLine .. take
        else
          lineIndex = lineIndex + 1
          workingLine = strippedLines[lineIndex]
          if workingLine then
            workingLine = strippedLines[lineIndex]:split("")
            workingLineLength = #workingLine
          end
          table.insert(lines, take)
          table.insert(strLines, take)
        end
        if leave == "\n" then
          table.insert(lines, leave)
          table.insert(strLines, leave)
          leave = ""
        end
      end
    end
  end
  if line ~= "" then
    table.insert(lines, line)
  end
  return table.concat(lines, "\n")
end

--- The main course, this function returns a formatted string, based on a table of options
-- @tparam string str the string to format
-- @tparam table opts the table of options which control the formatting
-- <br><br>Table of options
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
--     <td class="tg-1">wrap</td>
--     <td class="tg-1">Should it wordwrap to multiple lines?</td>
--     <td class="tg-1">true</td>
--   </tr>
--   <tr>
--     <td class="tg-2">formatType</td>
--     <td class="tg-2">Determines how it formats for color. 'c' for cecho, 'd' for decho, 'h' for hecho, and anything else for no colors</td>
--     <td class="tg-2">""</td>
--   </tr>
--   <tr>
--     <td class="tg-1">width</td>
--     <td class="tg-1">How wide should we format the text?</td>
--     <td class="tg-1">80</td>
--   </tr>
--   <tr>
--     <td class="tg-2">cap</td>
--     <td class="tg-2">what characters to use for the endcap.</td>
--     <td class="tg-2">""</td>
--   </tr>
--   <tr>
--     <td class="tg-1">capColor</td>
--     <td class="tg-1">what color to make the endcap?</td>
--     <td class="tg-1">the correct 'white' for your formatType</td>
--   </tr>
--   <tr>
--     <td class="tg-2">spacer</td>
--     <td class="tg-2">What character to use for empty space. Must be a single character</td>
--     <td class="tg-2">" "</td>
--   </tr>
--   <tr>
--     <td class="tg-1">spacerColor</td>
--     <td class="tg-1">what color should the spacer be?</td>
--     <td class="tg-1">the correct 'white' for your formatType</td>
--   </tr>
--   <tr>
--     <td class="tg-2">textColor</td>
--     <td class="tg-2">what color should the text itself be?</td>
--     <td class="tg-2">the correct 'white' for your formatType</td>
--   </tr>
--   <tr>
--     <td class="tg-1">alignment</td>
--     <td class="tg-1">How should the text be aligned within the width. "center", "left", or "right"</td>
--     <td class="tg-1">"center"</td>
--   </tr>
--   <tr>
--     <td class="tg-2">nogap</td>
--     <td class="tg-2">Should we put a literal space between the spacer character and the text?</td>
--     <td class="tg-2">false</td>
--   </tr>
--   <tr>
--     <td class="tg-1">inside</td>
--     <td class="tg-1">Put the spacers inside the caps?</td>
--     <td class="tg-1">false</td>
--   </tr>
--   <tr>
--     <td class="tg-2">mirror</td>
--     <td class="tg-2">Should the endcap be reversed on the right? IE [[ becomes ]]</td>
--     <td class="tg-2">true</td>
--   </tr>
--     <td class="tg-1">truncate</td>
--     <td class="tg-1">Cut the string to width. Is superceded by wrap being true.</td>
--     <td class="tg-1">false</td>
--   </tr>
-- </tbody>
-- </table>
function ftext.fText(str, opts)
  local options = ftext.fixFormatOptions(str, opts)
  if options.wrap and (options.strLen > options.effWidth) then
    local wrapped = ""
    if str:find("\n") then
      for _,line in ipairs(str:split("\n")) do
        local newline = "\n"
        if _ == 1 then newline = "" end
        wrapped = wrapped .. newline .. ftext.xwrap(line, options.effWidth, options.formatType)
      end
    else
      wrapped = ftext.xwrap(str, options.effWidth, options.formatType)
    end
    local lines = wrapped:split("\n")
    local formatted = {}
    options.fixed = false
    for _, line in ipairs(lines) do
      table.insert(formatted, ftext.fLine(line, options))
    end
    return table.concat(formatted, "\n")
  else
    return ftext.fLine(str, options)
  end
end

-- internal function, used to set defaults and type correct the options table
function ftext.fixFormatOptions(str, opts)
  if opts.fixed then
    return table.deepcopy(opts)
  end
  -- Set up all the things we might call the different echo types
  if opts == nil then
    opts = {}
  end -- don't overwrite options if they passed them
  -- but if they passed something other than a table as the options than oopsie!
  if type(opts) ~= "table" then
    error("Improper argument: options expected to be passed as table")
  end
  -- now we make a copy of the table, so we don't edit the original during all this
  local options = table.deepcopy(opts)
  if options.wrap == nil then
    options.wrap = true
  end -- wrap by default.
  if options.truncate == nil then
    options.truncate = false
  end -- do not truncate by default
  options.formatType = options.formatType or "" -- by default, no color formatting.
  options.width = options.width or 80 -- default 80 width
  options.cap = options.cap or "" -- no cap by default
  options.spacer = options.spacer or " " -- default spacer is the space character
  options.alignment = options.alignment or "center" -- default alignment is centered
  if options.nogap == nil then
    options.nogap = false
  end
  if options.inside == nil then
    options.inside = false
  end -- by default, we don't put the spacer inside
  if not options.mirror == false then
    options.mirror = options.mirror or true
  end -- by default, we do want to use mirroring for the caps
  -- setup default options for colors based on the color formatting type
  if table.contains(dec, options.formatType) then
    options.capColor = options.capColor or "<255,255,255>"
    options.spacerColor = options.spacerColor or "<255,255,255>"
    options.textColor = options.textColor or "<255,255,255>"
    options.colorReset = "<r>"
    options.colorPattern = _Echos.Patterns.Decimal[1]
  elseif table.contains(hex, options.formatType) then
    options.capColor = options.capColor or "#FFFFFF"
    options.spacerColor = options.spacerColor or "#FFFFFF"
    options.textColor = options.textColor or "#FFFFFF"
    options.colorReset = "#r"
    options.colorPattern = _Echos.Patterns.Hex[1]
  elseif table.contains(col, options.formatType) then
    options.capColor = options.capColor or "<white>"
    options.spacerColor = options.spacerColor or "<white>"
    options.textColor = options.textColor or "<white>"
    options.colorReset = "<reset>"
    options.colorPattern = _Echos.Patterns.Color[1]
  else
    options.capColor = ""
    options.spacerColor = ""
    options.textColor = ""
    options.colorReset = ""
    options.colorPattern = ""
  end
  options.originalString = str
  options.strippedString = rex.gsub(tostring(str), options.colorPattern, "")
  options.strLen = string.len(options.strippedString)
  options.leftCap = options.cap
  options.rightCap = options.cap
  options.capLen = string.len(options.cap)
  local gapSpaces = 0
  if not options.nogap then
    if options.alignment == "center" then
      gapSpaces = 2
    else
      gapSpaces = 1
    end
  end
  options.nontextlength = options.width - options.strLen - gapSpaces
  options.leftPadLen = math.floor(options.nontextlength / 2)
  options.rightPadLen = options.nontextlength - options.leftPadLen
  options.effWidth = options.width - ((options.capLen * gapSpaces) + gapSpaces)
  if options.capLen > options.leftPadLen then
    options.cap = options.cap:sub(1, options.leftPadLen)
    options.capLen = string.len(options.cap)
  end
  options.fixed = true
  return options
end

-- internal function, processes a single line of the wrapped string.
function ftext.fLine(str, opts)
  local options = ftext.fixFormatOptions(str, opts)
  local truncate, strLen, width = options.truncate, options.strLen, options.width
  if truncate and strLen > width then
    local wrapped = ftext.xwrap(str, options.effWidth, options.formatType)
    local lines = wrapped:split("\n")
    str = lines[1]
  end
  local leftCap = options.leftCap
  local rightCap = options.rightCap
  local leftPadLen = options.leftPadLen
  local rightPadLen = options.rightPadLen
  local capLen = options.capLen

  if options.alignment == "center" then -- we're going to center something
    if options.mirror then -- if we're reversing the left cap and the right cap (IE {{[[ turns into ]]}} )
      rightCap = string.gsub(rightCap, "<", ">")
      rightCap = string.gsub(rightCap, "%[", "%]")
      rightCap = string.gsub(rightCap, "{", "}")
      rightCap = string.gsub(rightCap, "%(", "%)")
      rightCap = string.reverse(rightCap)
    end -- otherwise, they'll be the same, so don't do anything
    if not options.nogap then
      str = string.format(" %s ", str)
    end

  elseif options.alignment == "right" then -- we'll right-align the text
    leftPadLen = leftPadLen + rightPadLen
    rightPadLen = 0
    rightCap = ""
    if not options.nogap then
      str = string.format(" %s", str)
    end

  else -- Ok, so if it's not center or right, we assume it's left. We don't do justified. Sorry.
    rightPadLen = rightPadLen + leftPadLen
    leftPadLen = 0
    leftCap = ""
    if not options.nogap then
      str = string.format("%s ", str)
    end
  end -- that's it, took care of both left, right, and center formattings, now to output the durn thing.
  local fullLeftCap = string.format("%s%s%s", options.capColor, leftCap, options.colorReset)
  local fullLeftSpacer = string.format("%s%s%s", options.spacerColor, string.rep(options.spacer, (leftPadLen - capLen)), options.colorReset)
  local fullText = string.format("%s%s%s", options.textColor, str, options.colorReset)
  local fullRightSpacer = string.format("%s%s%s", options.spacerColor, string.rep(options.spacer, (rightPadLen - capLen)), options.colorReset)
  local fullRightCap = string.format("%s%s%s", options.capColor, rightCap, options.colorReset)

  if options.inside then
    -- "endcap===== some text =====endcap"
    -- "endcap===== some text =====pacdne"
    -- "endcap================= some text"
    -- "some text =================endcap"
    local finalString = string.format("%s%s%s%s%s", fullLeftCap, fullLeftSpacer, fullText, fullRightSpacer, fullRightCap)
    return finalString
  else
    -- "=====endcap some text endcap====="
    -- "=====endcap some text pacdne====="
    -- "=================endcap some text"
    -- "some text endcap================="

    local finalString = string.format("%s%s%s%s%s", fullLeftSpacer, fullLeftCap, fullText, fullRightCap, fullRightSpacer)
    return finalString
  end
end

-- Functions below here are honestly for backwards compatibility and subject to removal soon. 
-- They just force some options table overrides for the most part.

-- no colors, no wrap
function ftext.align(str, opts)
  local options = {}
  if opts == nil then
    opts = {}
  end
  if type(opts) == "table" then
    options = table.deepcopy(opts)
    options.formatType = ""
    options.wrap = false
  else
    error("Improper argument: options expected to be passed as table")
  end
  options = ftext.fixFormatOptions(str, options)
  return ftext.fLine(str, options)
end

-- decho formatting, no wrap
function ftext.dalign(str, opts)
  local options = {}
  if opts == nil then
    opts = {}
  end
  if type(opts) == "table" then
    options = table.deepcopy(opts)
    options.formatType = "d"
    options.wrap = false
  else
    error("Improper argument: options expected to be passed as table")
  end
  options = ftext.fixFormatOptions(str, options)
  return ftext.fLine(str, options)
end

-- cecho formatting, no wrap
function ftext.calign(str, opts)
  local options = {}
  if opts == nil then
    opts = {}
  end
  if type(opts) == "table" then
    options = table.deepcopy(opts)
    options.formatType = "c"
    options.wrap = false
  else
    error("Improper argument: options expected to be passed as table")
  end
  options = ftext.fixFormatOptions(str, options)
  return ftext.fLine(str, options)
end

-- hecho formatting, no wrap
function ftext.halign(str, opts)
  local options = {}
  if opts == nil then
    opts = {}
  end
  if type(opts) == "table" then
    options = table.deepcopy(opts)
    options.formatType = "h"
    options.wrap = false
  else
    error("Improper argument: options expected to be passed as table")
  end
  options = ftext.fixFormatOptions(str, options)
  return ftext.fLine(str, options)
end

-- literally just fText but forces cecho formatting
function ftext.cfText(str, opts)
  local options = {}
  if opts == nil then
    opts = {}
  end
  if type(opts) == "table" then
    options = table.deepcopy(opts)
    options.formatType = "c"
  else
    error("Improper argument: options expected to be passed as table")
  end
  options = ftext.fixFormatOptions(str, options)
  return ftext.fText(str, options)
end

-- fText but forces decho formatting
function ftext.dfText(str, opts)
  local options = {}
  if opts == nil then
    opts = {}
  end
  if type(opts) == "table" then
    options = table.deepcopy(opts)
    options.formatType = "d"
  else
    error("Improper argument: options expected to be passed as table")
  end
  options = ftext.fixFormatOptions(str, options)
  return ftext.fText(str, options)
end

-- fText but forces hecho formatting
function ftext.hfText(str, opts)
  local options = {}
  if opts == nil then
    opts = {}
  end
  if type(opts) == "table" then
    options = table.deepcopy(opts)
    options.formatType = "h"
  else
    error("Improper argument: options expected to be passed as table")
  end
  options = ftext.fixFormatOptions(str, options)
  return ftext.fText(str, options)
end

--- Stand alone text formatter object. Remembers the options you set and can be adjusted as needed
-- @type ftext.TextFormatter
-- @author Damian Monogue <demonnic@gmail.com>
-- @copyright 2020 Damian Monogue
-- @license MIT, see LICENSE.lua

local TextFormatter = {}
TextFormatter.validFormatTypes = {'d', 'dec', 'decimal', 'h', 'hex', 'hexidecimal', 'c', 'color', 'colour', 'col', 'name', 'none', 'e', 'plain', ''}

--- Set's the formatting type whether it's for cecho, decho, or hecho
-- @tparam string typeToSet What type of formatter is this? Valid options are { 'd', 'dec', 'decimal', 'h', 'hex', 'hexidecimal', 'c', 'color', 'colour', 'col', 'name'}
function TextFormatter:setType(typeToSet)
  local isNotValid = not table.contains(self.validFormatTypes, typeToSet)
  if isNotValid then
    error("TextFormatter:setType: Invalid argument, valid types are:" .. table.concat(self.validFormatTypes, ", "))
  end
  self.options.formatType = typeToSet
end

function TextFormatter:toBoolean(thing)
  if type(thing) ~= "boolean" then
    if thing == "true" then
      thing = true
    elseif thing == "false" then
      thing = false
    else
      return nil
    end
  end
  return thing
end

function TextFormatter:checkString(str)
  if type(str) ~= "string" then
    if tostring(str) then
      str = tostring(str)
    else
      return nil
    end
  end
  return str
end

--- Sets whether or not we should do word wrapping.
-- @tparam boolean shouldWrap should we do wordwrapping?
function TextFormatter:setWrap(shouldWrap)
  local argumentType = type(shouldWrap)
  shouldWrap = self:toBoolean(shouldWrap)
  if shouldWrap == nil then
    error("TextFormatter:setWrap(shouldWrap) Argument error, boolean expected, got " .. argumentType ..
            ", if you want to set the number of characters wide to format for, use setWidth()")
  end
  self.options.wrap = shouldWrap
end

--- Sets the width we should format for
-- @tparam number width the width we should format for
function TextFormatter:setWidth(width)
  if type(width) ~= "number" then
    if tonumber(width) then
      width = tonumber(width)
    else
      error("TextFormatter:setWidth(width): Argument error, number expected, got " .. type(width))
    end
  end
  self.options.width = width
end

--- Sets the cap for the formatter
-- @tparam string cap the string to use for capping the formatted string.
function TextFormatter:setCap(cap)
  local argumentType = type(cap)
  local cap = self:checkString(cap)
  if cap == nil then
    error("TextFormatter:setCap(cap): Argument error, string expect, got " .. argumentType)
  end
  self.options.cap = cap
end

--- Sets the color for the format cap
-- @tparam string capColor Color which can be formatted via Geyser.Color.parse()
function TextFormatter:setCapColor(capColor)
  local argumentType = type(capColor)
  local capColor = self:checkString(capColor)
  if capColor == nil then
    error("TextFormatter:setCapColor(capColor): Argument error, string expected, got " .. argumentType)
  end
  self.options.capColor = capColor
end

--- Sets the color for spacing character
-- @tparam string spacerColor Color which can be formatted via Geyser.Color.parse()
function TextFormatter:setSpacerColor(spacerColor)
  local argumentType = type(spacerColor)
  local spacerColor = self:checkString(spacerColor)
  if spacerColor == nil then
    error("TextFormatter:setSpacerColor(spacerColor): Argument error, string expected, got " .. argumentType)
  end
  self.options.spacerColor = spacerColor
end

--- Sets the color for formatted text
-- @tparam string textColor Color which can be formatted via Geyser.Color.parse()
function TextFormatter:setTextColor(textColor)
  local argumentType = type(textColor)
  local textColor = self:checkString(textColor)
  if textColor == nil then
    error("TextFormatter:setTextColor(textColor): Argument error, string expected, got " .. argumentType)
  end
  self.options.textColor = textColor
end

--- Sets the spacing character to use. Should be a single character
-- @tparam string spacer the character to use for spacing
function TextFormatter:setSpacer(spacer)
  local argumentType = type(spacer)
  local spacer = self:checkString(spacer)
  if spacer == nil then
    error("TextFormatter:setSpacer(spacer): Argument error, string expect, got " .. argumentType)
  end
  self.options.spacer = spacer
end

--- Set the alignment to format for
-- @tparam string alignment How to align the formatted string. Valid options are 'left', 'right', or 'center'
function TextFormatter:setAlignment(alignment)
  local validAlignments = {"left", "right", "center"}
  if not table.contains(validAlignments, alignment) then
    error("TextFormatter:setAlignment(alignment): Argument error: Only valid arguments for setAlignment are 'left', 'right', or 'center'. You sent" ..
            alignment)
  end
  self.options.alignment = alignment
end

--- Set whether the the spacer should go inside the the cap or outside of it
-- @tparam boolean spacerInside 
function TextFormatter:setInside(spacerInside)
  local argumentType = type(spacerInside)
  spacerInside = self:toBoolean(spacerInside)
  if spacerInside == nil then
    error("TextFormatter:setInside(spacerInside) Argument error, boolean expected, got " .. argumentType)
  end
  self.options.inside = spacerInside
end

--- Set whether we should mirror/reverse the caps. IE << becomes >> if set to true
-- @tparam boolean shouldMirror
function TextFormatter:setMirror(shouldMirror)
  local argumentType = type(shouldMirror)
  shouldMirror = self:toBoolean(shouldMirror)
  if shouldMirror == nil then
    error("TextFormatter:setMirror(shouldMirror): Argument error, boolean expected, got " .. argumentType)
  end
  self.options.mirror = shouldMirror
end

--- Set whether we should remove the gap spaces between the text and spacer characters. "===some text===" if set to true, "== some text ==" if set to false
-- @tparam boolean noGap
function TextFormatter:setNoGap(noGap)
  local argumentType = type(noGap)
  noGap = self:toBoolean(noGap)
  if noGap == nil then
    error("TextFormatter:setNoGap(noGap): Argument error, boolean expected, got " .. argumentType)
  end
  self.options.noGap = noGap
end

--- Enables truncation (cutting to length). You still need to ensure wrap is disabled, as it supercedes.
function TextFormatter:enableTruncate()
  self.options.truncate = true
end

--- Disables truncation (cutting to length). You still need to ensure wrap is enabled if you want it to wrap.
function TextFormatter:disableTruncate()
  self.options.truncate = false
end

--- Format a string based on the stored options
-- @tparam string str The string to format
function TextFormatter:format(str)
  return ftext.fText(str, self.options)
end

--- Creates and returns a new TextFormatter.
-- @tparam table options the options for the text formatter to use when running format()
-- <br><br>Table of options
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
--     <td class="tg-1">wrap</td>
--     <td class="tg-1">Should it wordwrap to multiple lines?</td>
--     <td class="tg-1">true</td>
--   </tr>
--   <tr>
--     <td class="tg-2">formatType</td>
--     <td class="tg-2">Determines how it formats for color. 'c' for cecho, 'd' for decho, 'h' for hecho, and anything else for no colors</td>
--     <td class="tg-2">"c"</td>
--   </tr>
--   <tr>
--     <td class="tg-1">width</td>
--     <td class="tg-1">How wide should we format the text?</td>
--     <td class="tg-1">80</td>
--   </tr>
--   <tr>
--     <td class="tg-2">cap</td>
--     <td class="tg-2">what characters to use for the endcap.</td>
--     <td class="tg-2">""</td>
--   </tr>
--   <tr>
--     <td class="tg-1">capColor</td>
--     <td class="tg-1">what color to make the endcap?</td>
--     <td class="tg-1">the correct 'white' for your formatType</td>
--   </tr>
--   <tr>
--     <td class="tg-2">spacer</td>
--     <td class="tg-2">What character to use for empty space. Must be a single character</td>
--     <td class="tg-2">" "</td>
--   </tr>
--   <tr>
--     <td class="tg-1">spacerColor</td>
--     <td class="tg-1">what color should the spacer be?</td>
--     <td class="tg-1">the correct 'white' for your formatType</td>
--   </tr>
--   <tr>
--     <td class="tg-2">textColor</td>
--     <td class="tg-2">what color should the text itself be?</td>
--     <td class="tg-2">the correct 'white' for your formatType</td>
--   </tr>
--   <tr>
--     <td class="tg-1">alignment</td>
--     <td class="tg-1">How should the text be aligned within the width. "center", "left", or "right"</td>
--     <td class="tg-1">"center"</td>
--   </tr>
--   <tr>
--     <td class="tg-2">nogap</td>
--     <td class="tg-2">Should we put a literal space between the spacer character and the text?</td>
--     <td class="tg-2">false</td>
--   </tr>
--   <tr>
--     <td class="tg-1">inside</td>
--     <td class="tg-1">Put the spacers inside the caps?</td>
--     <td class="tg-1">false</td>
--   </tr>
--   <tr>
--     <td class="tg-2">mirror</td>
--     <td class="tg-2">Should the endcap be reversed on the right? IE [[ becomes ]]</td>
--     <td class="tg-2">true</td>
--   </tr>
--     <td class="tg-1">truncate</td>
--     <td class="tg-1">Cut the string to width. Is superceded by wrap being true.</td>
--     <td class="tg-1">false</td>
--   </tr>
-- </tbody>
-- </table>
-- @usage
-- local TextFormatter = require("MDK.ftext").TextFormatter
-- myFormatter = TextFormatter:new( {
--   width = 40, 
--   cap = "[CAP]",
--   capColor = "<orange>",
--   textColor = "<light_blue>"
-- })
-- myMessage = "This is a test of the emergency broadcasting system. This is only a test"
-- cecho(myFormatter:format(myMessage))

function TextFormatter:new(options)
  if options == nil then
    options = {}
  end
  if options and type(options) ~= "table" then
    error("TextFormatter:new(options): Argument error, table expected, got " .. type(options))
  end
  local me = {}
  me.options = {formatType = "c", wrap = true, width = 80, cap = "", spacer = " ", alignment = "center", inside = true, mirror = false}
  for option, value in pairs(options) do
    me.options[option] = value
  end
  setmetatable(me, self)
  self.__index = self
  return me
end
ftext.TextFormatter = TextFormatter

--- Easy formatting for text tables
-- @type ftext.TableMaker
-- @author Damian Monogue <demonnic@gmail.com>
-- @copyright 2020 Damian Monogue
-- @license MIT, see LICENSE.lua

local TableMaker = {
  headCharacter = "*",
  footCharacter = "*",
  edgeCharacter = "*",
  rowSeparator = "-",
  separator = "|",
  separateRows = true,
  colorReset = "<reset>",
  formatType = "c",
  printHeaders = true,
  autoEcho = false,
  title = "",
  printTitle = false,
  headerTitle = false,
  forceHeaderSeparator = false,
  autoEchoConsole = "main",
}

function TableMaker:checkPosition(position, func)
  if position == nil then
    position = 0
  end
  if type(position) ~= "number" then
    if tonumber(position) then
      position = tonumber(position)
    else
      error(func .. ": Argument error: position expected as number, got " .. type(position))
    end
  end
  return position
end

function TableMaker:insert(tbl, pos, item)
  if pos ~= 0 then
    table.insert(tbl, pos, item)
  else
    table.insert(tbl, item)
  end
end

--- Get the TextFormatter which defines the format of a specific column
-- @tparam number position The position of the column you're getting, counting from the left. If not provided will return the last column.
function TableMaker:getColumn(position)
  position = position or #self.columns
  position = self:checkPosition(position, "TableMaker:getColumn(position)")
  return self.columns[position]
end

--- Adds a column definition for the table.
-- @tparam table options Table of options suitable for a TextFormatter object. See https://github.com/demonnic/fText/wiki/fText
-- @tparam number position The position of the column you're adding, counting from the left. If not provided will add it as the last column
function TableMaker:addColumn(options, position)
  if options == nil then
    options = {}
  end
  if not type(options) == "table" then
    error("TableMaker:addColumn(options, position): Argument error: options expected as table, got " .. type(options))
  end
  local options = table.deepcopy(options)
  position = self:checkPosition(position, "TableMaker:addColumn(options, position)")
  options.width = options.width or 20
  options.name = options.name or ""
  local formatter = TextFormatter:new(options)
  self:insert(self.columns, position, formatter)
end

--- Deletes a column at the given position
-- @tparam number position the column you wish to delete
function TableMaker:deleteColumn(position)
  if position == nil then
    error("TableMaker:deleteColumn(position): Argument Error: position as number expected, got nil")
  end
  position = self:checkPosition(position)
  local maxColumn = #self.columns
  if position > maxColumn then
    error(
      "TableMaker:deleteColumn(position): Argument Error: position provided was larger than number of columns in the table. Number of columns: " ..
        #self.columns)
  end
  table.remove(self.columns, position)
end

--- Replaces a column at a specific position with the newly provided formatting
-- @tparam table options table of options suitable for a TextFormatter object. See https://github.com/demonnic/fText/wiki/fText
-- @tparam number position which column you are replacing, counting from the left.
function TableMaker:replaceColumn(options, position)
  if position == nil then
    error("TableMaker:replaceColumn(options, position): Argument error: position as number expected, got nil")
  end
  position = self:checkPosition(position)
  if type(options) ~= "table" then
    error("TableMaker:replaceColumn(options, position): Argument error: options as table expected, got " .. type(options))
  end
  if #self.columns < position then
    error(
      "TableMaker:replaceColumn(options, position): you cannot specify a position higher than the number of columns currently in the TableMaker. You sent:" ..
        position .. " and there are: " .. #self.columns .. "columns in the TableMaker")
  end
  options.width = options.width or 20
  options.name = options.name or ""
  local formatter = TextFormatter:new(options)
  self.columns[position] = formatter
end

--- Gets the row of output at a specific position
-- @tparam number position The position of the row you want to get, coutning from the top down. If not provided defaults to the last row in the table
-- @return table of entries in the specified row
function TableMaker:getRow(position)
  position = position or #self.rows
  position = self:checkPosition(position, "TableMaker:getRow(position)")
  return self.rows[position]
end

--- Adds a row of output to the table
-- @tparam table columnEntries This indexed table contains an entry for each column in the table. Entries in the table must be strings, a table of options for insertPopup or insertLink, or a function which returns one of these things
-- @tparam number position position for the row you want to add, counting from the top down. If not provided defaults to the last line in the table.
function TableMaker:addRow(columnEntries, position)
  local columnEntriesType = type(columnEntries)
  if columnEntriesType ~= "table" then
    error("TableMaker:addRow(columnEntries, position): Argument error, columnEntries expected as table, got " .. columnEntriesType)
  end
  for _, entry in ipairs(columnEntries) do
    local entryCheck = self:checkEntry(entry)
    if entryCheck == 0 then
      if type(entry) == "function" then
        error(
          "TableMaker:addRow(columnEntries, position): Argument Error, you provided a function for a columnEntry but it does not return a string. We need a string. It was entry number " ..
            _ .. "in columnEntries")
      else
        error("TableMaker:addRow(columnEntries, position): Argument error, columnEntries items expected as string, got:" .. type(entry))
      end
    end
  end
  position = self:checkPosition(position, "TableMaker:addRow(columnEntries, position)")
  self:insert(self.rows, position, columnEntries)
end

--- Deletes the row at the given position
-- @tparam number position the row to delete
function TableMaker:deleteRow(position)
  if position == nil then
    error("TableMaker:deleteRow(position): Argument Error: position as number expected, got nil")
  end
  position = self:checkPosition(position, "TableMaker:deleteRow(position)")
  local maxRow = #self.rows
  if position > maxRow then
    error("TableMaker:deleteRow(position): Argument Error: position given was > the number of rows we have # of rows is:" .. maxRow)
  end
  table.remove(self.rows, position)
end

--- Replaces a row of output in the table
-- @tparam table columnEntries This indexed table contains an entry for each column in the table. Entries in the table must be strings, a table of options for insertPopup or insertLink, or a function which returns one of these things
-- @tparam number position position for the row you want to add, counting from the top down.
function TableMaker:replaceRow(columnEntries, position)
  if position == nil then
    error("TableMaker:replaceRow(columnEntries, position): ArgumentError: position expected as number, received nil")
  end
  position = self:checkPosition(position, "TableMaker:replaceRow(columnEntries, position)")
  if #self.rows < position then
    error(
      "TableMaker:replaceRow(columnEntries, position): position cannot be greater than the number of rows already in the tablemaker. You provided: " ..
        position .. " and there are " .. #self.rows .. "rows in the TableMaker")
  end
  for _, entry in ipairs(columnEntries) do
    local entryCheck = self:checkEntry(entry)
    if entryCheck == 0 then
      if type(entry) == "function" then
        error(
          "TableMaker:replaceRow(columnEntries, position): Argument Error: you provided a function for a columnEntry but it does not return a string. We need a string. It was entry number " ..
            _ .. "in columnEntries")
      else
        error("TableMaker:replaceRow(columnEntries, position): Argument error: columnEntries items expected as string, got:" .. type(entry))
      end
    end
  end
  self.rows[position] = columnEntries
end

function TableMaker:checkEntry(entry)
  local allowedTypes = {"string"}
  if self.allowPopups then
    table.insert(allowedTypes, "table")
  end
  local entryType = type(entry)
  if entryType == "function" then
    entryType = type(entry())
  end
  if table.contains(allowedTypes, entryType) then
    return entry
  else
    return 0
  end
end

function TableMaker:checkNumber(num)
  if num == nil then
    num = 0
  end
  if not tonumber(num) then
    num = 0
  end
  return tonumber(num)
end

--- Get the contents and formatter for a specific cell
-- @tparam number row the row number of the cell, counted top down.
-- @tparam number column the column number of the cell, counted from the left.
-- @return the base text and TextFormatter for the cell at the specific row and column number
function TableMaker:getCell(row, column)
  local rowType = type(row)
  local columnType = type(column)
  local maxRow = #self.rows
  local maxColumn = #self.columns
  local ae = "TableMaker:getCell(row, column): Argument error:"
  row = self:checkNumber(row)
  column = self:checkNumber(column)
  if row == 0 then
    if rowType ~= "number" then
      printError(f"{ae} row as number expected, got {rowType}", true, true)
    else
      printError(f"{ae} rows start at 1, and you asked for row 0", true, true)
    end
  elseif column == 0 then
    if columnType ~= "number" then
      printError(f"{ae} column as number expected, got {columnType}", true, true)
    else
      printError(f"{ae} columns start at 1, and you asked for column 0", true, true)
    end
  elseif row > maxRow then
    printError(f"{ae} row exceeds number of rows in table ({maxRow})")
  elseif column > maxColumn then
    printError(f"{ae} column exceeds number of columns in table ({maxColumn})", true, true)
  end
  return self.rows[row][column], self.columns[column]
end

--- Sets a specific cell's display information
-- @tparam number row the row number of the cell, counted from the top down
-- @tparam number column the column number of the cell, counted from the left
-- @param entry What to set the entry to. Must be a string, or a table of options for insertLink/insertPopup if allowPopups is set. Or a function which returns one of these things
function TableMaker:setCell(row, column, entry)
  local maxRow = #self.rows
  local maxColumn = #self.columns
  local ae = "TableMaker:setCell(row, column, entry): Argument Error:"
  row = self:checkNumber(row)
  if row == 0 then
    error(ae .. " row must be a number, you provided " .. type(row))
  end
  column = self:checkNumber(column)
  if column == 0 then
    error(ae .. " column must be a number, you provided " .. type(column))
  end
  if row > maxRow then
    error(ae .. " row is higher than the number of rows in the table. Highest row:" .. maxRow)
  end
  if column > maxColumn then
    error(ae .. " column is higher than the number of columns in the table. Highest column:" .. maxColumn)
  end
  local entryType = type(entry)
  entry = self:checkEntry(entry)
  if entry == 0 then
    if entryType == "function" then
      error(ae .. " entry was provided as a function, but does not return a string. We need a string in the end")
    else
      error("TableMaker:setCell(row, column, entry): Argument Error: entry must be a string, or a function which returns a string. You provided a " .. entryType)
    end
  end
  self.rows[row][column] = entry
end

function TableMaker:totalWidth()
  local width = 0
  local numberOfColumns = #self.columns
  local separatorWidth = string.len(self.separator)
  local edgeWidth = string.len(self.edgeCharacter) * 2
  for _, column in ipairs(self.columns) do
    width = width + column.options.width
  end
  separatorWidth = separatorWidth * (numberOfColumns - 1)
  width = width + edgeWidth + separatorWidth
  return width
end

function TableMaker:getType()
  local dec = {"d", "decimal", "dec"}
  local hex = {"h", "hexidecimal", "hex"}
  local col = {"c", "color", "colour", "col", "name"}
  if table.contains(dec, self.formatType) then
    return 'd'
  elseif table.contains(hex, self.formatType) then
    return 'h'
  elseif table.contains(col, self.formatType) then
    return 'c'
  else
    return ''
  end
end

function TableMaker:echo(message, echoType, ...)
  local fType = self:getType()
  local consoleType = type(self.autoEchoConsole)
  local console = ""
  if echoType == nil then
    echoType = ""
  end
  if consoleType == "string" then
    console = self.autoEchoConsole
  elseif consoleType == "nil" then
    console = "main"
  else
    console = self.autoEchoConsole.name
  end
  local functionName = string.format("%secho%s", fType, echoType)
  local func = _G[functionName]
  if echoType == "" then
    func(console, message)
  else
    func(console, message, ...)
  end
end

function TableMaker:scanRow(rowToScan)
  local row = table.deepcopy(rowToScan)
  local rowEntries = #row
  local numberOfColumns = #self.columns
  local columns = {}
  local linesInRow = 0
  local rowText = ""
  local ec = self.frameColor .. self.edgeCharacter .. self.colorReset
  local sep = self.separatorColor .. self.separator .. self.colorReset

  if rowEntries < numberOfColumns then
    local entriesNeeded = numberOfColumns - rowEntries
    for i = 1, entriesNeeded do
      table.insert(row, "")
    end
  end
  for index, formatter in ipairs(self.columns) do
    local str = row[index]
    local column = ""
    if type(str) == "function" then
      str = str()
    end
    column = formatter:format(str)
    table.insert(columns, column:split("\n"))
  end
  for _, rowLines in ipairs(columns) do
    if linesInRow < #rowLines then
      linesInRow = #rowLines
    end
  end
  for index, rowLines in ipairs(columns) do
    if #rowLines < linesInRow then
      local neededLines = linesInRow - #rowLines
      for i = 1, neededLines do
        table.insert(rowLines, self.columns[index]:format(""))
      end
    end
  end
  for i = 1, linesInRow do
    local thisLine = ec
    for index, column in ipairs(columns) do
      if index == 1 then
        thisLine = string.format("%s%s", thisLine, column[i])
      else
        thisLine = string.format("%s%s%s", thisLine, sep, column[i])
      end
    end
    thisLine = string.format("%s%s", thisLine, ec)
    if rowText == "" then
      rowText = thisLine
    else
      rowText = string.format("%s\n%s", rowText, thisLine)
    end
  end
  return rowText
end

function TableMaker:echoRow(rowToScan)
  local row = table.deepcopy(rowToScan)
  local rowEntries = #row
  local numberOfColumns = #self.columns
  local columns = {}
  local linesInRow = 0
  local ec = self.frameColor .. self.edgeCharacter .. self.colorReset
  local sep = self.separatorColor .. self.separator .. self.colorReset
  if rowEntries < numberOfColumns then
    local entriesNeeded = numberOfColumns - rowEntries
    for i = 1, entriesNeeded do
      table.insert(row, "")
    end
  end
  for index, formatter in ipairs(self.columns) do
    local str = row[index]
    local column = ""
    if type(str) == "function" then
      str = str()
    end
    if type(str) == "table" then
      str = str[1]
    end
    column = formatter:format(str)
    table.insert(columns, column:split("\n"))
  end
  for _, rowLines in ipairs(columns) do
    if linesInRow < #rowLines then
      linesInRow = #rowLines
    end
  end
  for index, rowLines in ipairs(columns) do
    if #rowLines < linesInRow then
      local neededLines = linesInRow - #rowLines
      for i = 1, neededLines do
        table.insert(rowLines, self.columns[index]:format(""))
      end
    end
  end
  for i = 1, linesInRow do
    self:echo(ec)
    for index, column in ipairs(columns) do
      local message = column[i]
      if index ~= 1 then
        self:echo(sep)
      end
      if type(row[index]) == "string" then
        self:echo(message)
      elseif type(row[index]) == "table" then
        local rowEntry = row[index]
        local echoType = ""
        if type(rowEntry[2]) == "string" then
          echoType = "Link"
        elseif type(rowEntry[2]) == "table" then
          echoType = "Popup"
        end
        self:echo(message, echoType, rowEntry[2], rowEntry[3], rowEntry[4] or true)
      end
    end
    self:echo(ec)
    self:echo("\n")
  end
end

function TableMaker:makeHeader()
  local totalWidth = self:totalWidth()
  local ec = self.frameColor .. self.edgeCharacter .. self.colorReset
  local sep = self.separatorColor .. self.separator .. self.colorReset
  local header = self.frameColor .. string.rep(self.headCharacter, totalWidth) .. self.colorReset
  local columnHeaders = ""
  if self.printHeaders then
    local columnEntries = {}
    for _, v in ipairs(self.columns) do
      table.insert(columnEntries, v:format(v.options.name))
    end
    local divWithNewlines = self.headerTitle and header or self:createRowDivider()
    divWithNewlines = "\n" .. divWithNewlines
    columnHeaders = string.format("\n%s%s%s%s", ec, table.concat(columnEntries, sep), ec, (self.separateRows or self.forceHeaderSeparator) and divWithNewlines or '')
  end
  local title = self:makeTitle(totalWidth, header)
  header = string.format("%s%s%s", header, title, columnHeaders)
  return header
end

function TableMaker:makeTitle(totalWidth, header)
  if not self.printTitle then
    return ""
  end
  local title = ftext.fText(self.title, {width = totalWidth, alignment = "center", cap = self.headCharacter, capColor = self.frameColor, inside = true, textColor = self.titleColor, formatType = self.formatType})
  title = string.format("\n%s\n%s", title, header)
  return title
end

function TableMaker:createRowDivider()
  local columnPieces = {}
  for _, v in ipairs(self.columns) do
    local piece = string.format("%s%s%s", self.separatorColor, string.rep(self.rowSeparator, v.options.width), self.colorReset)
    table.insert(columnPieces, piece)
  end
  local ec = self.frameColor .. self.edgeCharacter .. self.colorReset
  local sep = self.separatorColor .. self.separator .. self.colorReset
  return string.format("%s%s%s", ec, table.concat(columnPieces, sep), ec)
end

--- set the title of the table
-- @tparam string title The title of the table.
function TableMaker:setTitle(title)
  self.title = title
  if self.autoEcho then self:assemble() end
end

--- set the rowSeparator for the table
-- @tparam string char The row separator to use
function TableMaker:setRowSeparator(char)
  self.rowSeparator = char
  if self.autoEcho then self:assemble() end
end

--- set the edgeCharacter for the table
-- @tparam string char The edge character to use
function TableMaker:setEdgeCharacter(char)
  self.edgeCharacter = char
  if self.autoEcho then self:assemble() end
end

--- set the foot character for the table
-- @tparam string char The foot character to use
function TableMaker:setFootCharacter(char)
  self.footCharacter = char
  if self.autoEcho then self:assemble() end
end

--- set the head character for the table
-- @tparam string char The head character to use
function TableMaker:setHeadCharacter(char)
  self.headCharacter = char
  if self.autoEcho then self:assemble() end
end

--- set the column separator character for the table
-- @tparam string char The separator character to use
function TableMaker:setSeparator(char)
  self.separator = char
  if self.autoEcho then self:assemble() end
end

--- set the title color for the table
-- @tparam string color The title color to use. Should match the color type of the tablemaker (cecho by default)
function TableMaker:setTitleColor(color)
  self.titleColor = color
  if self.autoEcho then self:assemble() end
end

--- set the title color for the table
-- @tparam string color The separator color to use. Should match the color type of the tablemaker (cecho by default)
function TableMaker:setSeparatorColor(color)
  self.separatorColor = color
  if self.autoEcho then self:assemble() end
end

--- set the title color for the table
-- @tparam string color The frame color to use. Should match the color type of the tablemaker (cecho by default)
function TableMaker:setFrameColor(color)
  self.frameColor = color
  if self.autoEcho then self:assemble() end
end

--- Force a separator between the header and first row, even if the row separator is disabled for the overall table
function TableMaker:enableForceHeaderSeparator()
  self.forceHeaderSeparator = true
  if self.autoEcho then self:assemble() end
end

--- Do not force a separator between the header and first row, even if the row separator is disabled for the overall table
function TableMaker:disableForceHeaderSeparator()
  self.forceHeaderSeparator = false
  if self.autoEcho then self:assemble() end
end

--- Enable using the title separator for the column headers as well
function TableMaker:enableHeaderTitle()
  self.headerTitle = true
  if self.autoEcho then self:assemble() end
end

--- Disable using the title separator for the column headers as well
function TableMaker:disableHeaderTitle()
  self.headerTitle = false
  if self.autoEcho then self:assemble() end
end

--- enable printing the title of the table
function TableMaker:enablePrintTitle()
  self.printTitle = true
  if self.autoEcho then self:assemble() end
end

--- disable printing the title of the table
function TableMaker:disablePrintTitle()
  self.printTitle = false
  if self.autoEcho then self:assemble() end
end

--- enable printing of the column headers
function TableMaker:enablePrintHeaders()
  self.printHeaders = true
  if self.autoEcho then self:assemble() end
end

--- disable printing of the column headers
function TableMaker:disablePrintHeaders()
  self.printHeaders = false
  if self.autoEcho then self:assemble() end
end

--- enable printing the separator line between rows
function TableMaker:enableRowSeparator()
  self.separateRows = true
  if self.autoEcho then self:assemble() end
end

--- enable printing the separator line between rows
function TableMaker:disableRowSeparator()
  self.separateRows = false
  if self.autoEcho then self:assemble() end
end

--- enables making cells which incorporate insertLink/insertPopup
function TableMaker:enablePopups()
  self.autoEcho = true
  self.allowPopups = true
  if self.autoEcho then self:assemble() end
end

--- enables autoEcho so that when assemble is called it echos automatically
function TableMaker:enableAutoEcho()
  self.autoEcho = true
  self:assemble()
end

--- disables autoecho. Cannot be used if allowPopups is set
function TableMaker:disableAutoEcho()
  if self.allowPopups then
    error("TableMaker:disableAutoEcho(): you cannot disable autoEcho once you have enabled popups.")
  else
    self.autoEcho = false
  end
end

--- Enables automatically clearing the miniconsole we echo to
function TableMaker:enableAutoClear()
  self.autoClear = true
  if self.autoEcho then self:assemble() end
end

--- Disables automatically clearing the miniconsole we echo to
function TableMaker:disableAutoClear()
  self.autoClear = false
end

--- Set the miniconsole to echo to
-- @param console The miniconsole to autoecho to. Set to "main" or do not pass the parameter to autoecho to the main console. Can be a string name of the console, or a Geyser MiniConsole
function TableMaker:setAutoEchoConsole(console)
  local funcName = "TableMaker:setAutoEchoConsole(console)"
  if console == nil then
    console = "main"
  end
  local consoleType = type(console)
  if consoleType ~= "string" and consoleType ~= "table" then
    error(funcName .. " ArgumentError: console as string or a Geyser MiniConsole or UserWindow expected, got " .. consoleType)
  elseif consoleType == "table" and not (console.type == "miniConsole" or console.type == "userwindow") then
    error(funcName .. " ArgumentError: console received was a table and may be a Geyser object, but console.type is not miniConsole, it is " ..
            console.type)
  end
  self.autoEchoConsole = console
  if self.autoEcho then self:assemble() end
end

--- Assemble the table. If autoEcho is enabled/set to true, will automatically echo. Otherwise, returns the formatted string to echo the table
function TableMaker:assemble()
  if self.allowPopups and self.autoEcho then
    self:popupAssemble()
  else
    return self:textAssemble()
  end
end

function TableMaker:popupAssemble()
  if self.autoClear then
    local console = self.autoEchoConsole
    if console and console ~= "main" then
      if type(console) == "table" then
        console = console.name
      end
      clearWindow(console)
    end
  end
  local divWithNewLines = string.format("%s\n", self:createRowDivider())
  local header = self:makeHeader() .. "\n"
  local footer = string.format("%s%s%s\n", self.frameColor, string.rep(self.footCharacter, self:totalWidth()), self.colorReset)
  self:echo(header)
  for _, row in ipairs(self.rows) do
    if _ ~= 1 and self.separateRows then
      self:echo(divWithNewLines)
    end
    self:echoRow(row)
  end
  self:echo(footer)
end

function TableMaker:textAssemble()
  local sheet = ""
  local rows = {}
  for _, row in ipairs(self.rows) do
    table.insert(rows, self:scanRow(row))
  end
  local divWithNewlines = string.format("\n%s\n", self:createRowDivider())
  local footer = string.format("%s%s%s", self.frameColor, string.rep(self.footCharacter, self:totalWidth()), self.colorReset)
  sheet = string.format("%s\n%s\n%s\n", self:makeHeader(), table.concat(rows, self.separateRows and divWithNewlines or "\n"), footer)
  if self.autoEcho then
    local console = self.autoEchoConsole or "main"
    if type(console) == "table" then
      console = console.name
    end
    if self.autoClear and console ~= "main" then
      clearWindow(console)
    end
    self:echo(sheet)
  end
  return sheet
end

--- Creates and returns a new TableMaker. 
-- see https://github.com/demonnic/MDK/wiki/fText%3A-TableMaker%3A-Examples for usage
-- @tparam table options table of options for the TableMaker object
-- <br><br>Table of new options
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
--     <td class="tg-1">formatType</td>
--     <td class="tg-1">Determines how it formats for color. 'c' for cecho, 'd' for decho, 'h' for hecho, and anything else for no colors</td>
--     <td class="tg-1">c</td>
--   </tr>
--   <tr>
--     <td class="tg-2">printHeaders</td>
--     <td class="tg-2">print top row as header</td>
--     <td class="tg-2">true</td>
--   </tr>
--   <tr>
--     <td class="tg-1">headCharacter</td>
--     <td class="tg-1">The character used to construct the very top of the table. A solid line of these characters is used</td>
--     <td class="tg-1">"*"</td>
--   </tr>
--   <tr>
--     <td class="tg-2">footCharacter</td>
--     <td class="tg-2">The character used to construct the very bottom of the table. A solid line of these characters is used</td>
--     <td class="tg-2">"*"</td>
--   </tr>
--   <tr>
--     <td class="tg-1">edgeCharacter</td>
--     <td class="tg-1">the character used to form the left and right edges of the table. There is one on either side of every line</td>
--     <td class="tg-1">"*"</td>
--   </tr>
--   <tr>
--     <td class="tg-2">frameColor</td>
--     <td class="tg-2">The color to use for the frame. The frame is the border around the outside edge of the table (headCharacter, footCharacter, and edgeCharacters will all be this color).</td>
--     <td class="tg-2">the correct 'white' for your formatType</td>
--   </tr>
--   <tr>
--     <td class="tg-1">rowSeparator</td>
--     <td class="tg-1">the character used to form the lines between rows of text</td>
--     <td class="tg-1">"-"</td>
--   </tr>
--   <tr>
--     <td class="tg-2">separator</td>
--     <td class="tg-2">Character used between columns.</td>
--     <td class="tg-2">"|"</td>
--   </tr>
--   <tr>
--     <td class="tg-1">separatorColor</td>
--     <td class="tg-1">the color used for the separators, the things which divide the rows and columns internally. (separator and rowSeparator will be this color)</td>
--     <td class="tg-1">frameColor</td>
--   </tr>
--   <tr>
--     <td class="tg-2">autoEcho</td>
--     <td class="tg-2">echo the table automatically in addition to returning the string representation?</td>
--     <td class="tg-2">false</td>
--   </tr>
--   <tr>
--     <td class="tg-1">autoEchoConsole</td>
--     <td class="tg-1">MiniConsole to autoEcho to</td>
--     <td class="tg-1">"main"</td>
--   </tr>
--   <tr>
--     <td class="tg-2">autoClear</td>
--     <td class="tg-2">If autoEchoing, and not echoing to the main console, should we clear the console before outputting?</td>
--     <td class="tg-2">false</td>
--   </tr>
--   <tr>
--     <td class="tg-1">allowPopups</td>
--     <td class="tg-1">setting this to true allows you to make cells in the table clickable, as well as give them right-click menus.<br>
--                        Please see Clickable Tables <a href="https://github.com/demonnic/fText/wiki/ClickableTables">HERE</a></td>
--     <td class="tg-1">false</td>
--   </tr>
--   <tr>
--     <td class="tg-2">separateRows</td>
--     <td class="tg-2">When false, will not print the separator line between rows</td>
--     <td class="tg-2">true</td>
--   </tr>
--   <tr>
--     <td class="tg-1">title</td>
--     <td class="tg-1">The overall title of the table. Displayed at the top</td>
--     <td class="tg-1">""</td>
--   </tr>
--   <tr>
--     <td class="tg-2">titleColor</td>
--     <td class="tg-2">What color to use for the title text</td>
--     <td class="tg-2">formatColor</td>
--   </tr>
--   <tr>
--     <td class="tg-1">printTitle</td>
--     <td class="tg-1">Should we print the title of the table at the very tip-top?</td>
--     <td class="tg-1">false</td>
--   </tr>
--   <tr>
--     <td class="tg-2">headerTitle</td>
--     <td class="tg-2">Use the same separator for the column headers as the title/top, rather than the row separator</td>
--     <td class="tg-2">formatColor</td>
--   </tr>
--   <tr>
--     <td class="tg-1">forceHeaderSeparator</td>
--     <td class="tg-1">Force a separator between the column headers and the first row, even if rowSeparator is false.</td>
--     <td class="tg-1">false</td>
--   </tr>
-- </tbody>
-- </table>
function TableMaker:new(options)
  local funcName = "TableMaker:new(options)"
  local me = {}
  setmetatable(me, self)
  self.__index = self
  if options == nil then
    options = {}
  end
  if type(options) ~= "table" then
    error("TableMaker:new(options): ArgumentError: options expected as table, got " .. type(options))
  end
  local options = table.deepcopy(options)
  if options.allowPopups == true then
    options.autoEcho = true
  else
    options.allowPopups = false
  end
  local columns = false
  if options.columns then
    if type(options.columns) ~= "table" then
      error("TableMaker:new(options): option error: You provided an options.columns entry of type " .. type(options.columns) ..
              " and columns must a table with entries suitable for TableFormatter:addColumn().")
    end
    columns = table.deepcopy(options.columns)
    options.columns = nil
  end
  local rows = false
  if options.rows then
    if type(options.rows) ~= "table" then
      error("TableMaker:new(options): option error: You provided an options.rows entry of type " .. type(options.rows) ..
              " and rows must be a table with entrys suitable for TableFormatter:addRow()")
    end
    rows = table.deepcopy(options.rows)
    options.rows = nil
  end
  for option, value in pairs(options) do
    me[option] = value
  end
  local dec = {"d", "decimal", "dec"}
  local hex = {"h", "hexidecimal", "hex"}
  local col = {"c", "color", "colour", "col", "name"}
  if table.contains(dec, me.formatType) then
    me.frameColor = me.frameColor or "<255,255,255>"
    me.separatorColor = me.separatorColor or me.frameColor
    me.titleColor = me.titleColor or me.frameColor
    me.colorReset = "<r>"
  elseif table.contains(hex, me.formatType) then
    me.frameColor = me.frameColor or "#ffffff"
    me.separatorColor = me.separatorColor or me.frameColor
    me.titleColor = me.titleColor or me.frameColor
    me.colorReset = "#r"
  elseif table.contains(col, me.formatType) then
    me.frameColor = me.frameColor or "<white>"
    me.separatorColor = me.separatorColor or me.frameColor
    me.titleColor = me.titleColor or me.frameColor
    me.colorReset = "<reset>"
  else
    me.frameColor = ""
    me.separatorColor = ""
    me.titleColor = ""
    me.colorReset = ""
  end
  me.columns = {}
  me.rows = {}
  if columns then
    for _, column in ipairs(columns) do
      me:addColumn(column)
    end
  end
  if rows then
    for _, row in ipairs(rows) do
      me:addRow(row)
    end
  end
  return me
end
ftext.TableMaker = TableMaker

return ftext
