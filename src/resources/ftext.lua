--- fText processing
-- @module ftext
local ftext = {}
local dec = {"d", "decimal", "dec"}
local hex = {"h", "hexidecimal", "hex"}
local col = {"c", "color", "colour", "col", "name"}

--- Performs wordwrapping on a string, given a length limit. Does not understand colour tags and will count them as characters in the string
--@tparam string str the string to wordwrap
--@tparam number limit the line length to wrap at
function ftext.wordWrap(str, limit, indent, indent1)
  -- pulled from http://lua-users.org/wiki/StringRecipes
  indent = indent or ""
  indent1 = indent1 or indent
  limit = limit or 72
  local here = 1-#indent1
  local function check(sp, st, word, fi)
    if fi - here > limit then
      here = st - #indent
      return "\n"..indent..word
    end
  end
  return indent1..str:gsub("(%s+)()(%S+)()", check)
end

--- Performs wordwrapping on a string, while ignoring color tags of a given type.
--@tparam string text the string you are wordwrapping
--@tparam number limit the line length to wrap at
--@tparam string type What type of color codes to ignore. 'c' for cecho, 'd' for decho, 'h' for hecho, and anything else or nil to pass the string on to wordWrap
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
      local take = str:sub(1,neededChars)
      local leave = str:sub(neededChars+1, -1)
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
      if leave:sub(1,1) == " " then leave = leave:sub(2,-1) end
      while leave ~= "" do
        take = leave:sub(1, workingLineLength)
        leave = leave:sub(workingLineLength + 1, -1)
        if leave:sub(1,1) == " " then leave = leave:sub(2,-1) end
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
      end
    end
  end
  if line ~= "" then table.insert(lines, line) end
  return table.concat(lines, "\n")
end

--- The main course, this function returns a formatted string, based on a table of options
--@tparam string str the string to format
--@tparam table opts the table of options which control the formatting
function ftext.fText(str, opts)
  local options = ftext.fixFormatOptions(str, opts)
  if options.wrap and (options.strLen > options.effWidth) then
    local wrapped = ftext.xwrap(str, options.effWidth, options.formatType)
    local lines = wrapped:split("\n")
    local formatted = {}
		options.fixed = false
    for _,line in ipairs(lines) do
      table.insert(formatted, ftext.fLine(line, options))
    end
    return table.concat(formatted, "\n")
  else
    return ftext.fLine(str, options)
  end
end

-- internal function, used to set defaults and type correct the options table
function ftext.fixFormatOptions(str, opts)
  if opts.fixed then return table.deepcopy(opts) end
  --Set up all the things we might call the different echo types
  if opts == nil then opts = {} end -- don't overwrite options if they passed them
  --but if they passed something other than a table as the options than oopsie!
  if type(opts) ~= "table" then
    error("Improper argument: options expected to be passed as table")
  end
  --now we make a copy of the table, so we don't edit the original during all this
  local options = table.deepcopy(opts)
  if options.wrap == nil then options.wrap = true end --wrap by default.
  options.formatType = options.formatType or "" --by default, no color formatting.
  options.width = options.width or 80 --default 80 width
  options.cap = options.cap or "" --no cap by default
  options.spacer = options.spacer or " " --default spacer is the space character
  options.alignment = options.alignment or "center" --default alignment is centered
  if options.nogap == nil then options.nogap = false end
  if options.inside == nil then options.inside = false end --by default, we don't put the spacer inside
  if not options.mirror == false then options.mirror = options.mirror or true end--by default, we do want to use mirroring for the caps
  --setup default options for colors based on the color formatting type
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
function ftext.fLine(str,opts)
  local options = ftext.fixFormatOptions(str,opts)
  local leftCap = options.leftCap
  local rightCap = options.rightCap
  local leftPadLen = options.leftPadLen
  local rightPadLen = options.rightPadLen
  local capLen = options.capLen

  if options.alignment == "center" then --we're going to center something
    if options.mirror then --if we're reversing the left cap and the right cap (IE {{[[ turns into ]]}} )
      rightCap = string.gsub(rightCap, "<", ">")
      rightCap = string.gsub(rightCap, "%[", "%]")
      rightCap = string.gsub(rightCap, "{", "}")
      rightCap = string.gsub(rightCap, "%(", "%)")
      rightCap = string.reverse(rightCap)
    end --otherwise, they'll be the same, so don't do anything
    if not options.nogap then str = string.format(" %s ", str) end

  elseif options.alignment == "right" then --we'll right-align the text
    leftPadLen = leftPadLen + rightPadLen
    rightPadLen = 0
    rightCap = ""
    if not options.nogap then str = string.format(" %s", str) end

  else --Ok, so if it's not center or right, we assume it's left. We don't do justified. Sorry.
    rightPadLen = rightPadLen + leftPadLen
    leftPadLen = 0
    leftCap = ""
    if not options.nogap then str = string.format("%s ", str) end
  end--that's it, took care of both left, right, and center formattings, now to output the durn thing.
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
  --"=====endcap some text endcap====="
  --"=====endcap some text pacdne====="
  --"=================endcap some text"
  --"some text endcap================="

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

--cecho formatting, no wrap
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

--hecho formatting, no wrap
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
  if opts == nil then opts = {} end
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
  if opts == nil then opts = {} end
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
  if opts == nil then opts = {} end
  if type(opts) == "table" then
    options = table.deepcopy(opts)
    options.formatType = "h"
  else
    error("Improper argument: options expected to be passed as table")
  end
  options = ftext.fixFormatOptions(str, options)
  return ftext.fText(str, options)
end

return ftext
