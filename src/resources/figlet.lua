--- Figlet
-- A module to read figlet fonts and produce figlet ascii art from text
-- @module figlet
-- @copyright 2010,2011 Nick Gammon
-- @copyright 2022 Damian Monogue
local Figlet = {}

--[[
  Based on figlet.

  FIGlet Copyright 1991, 1993, 1994 Glenn Chappell and Ian Chai
  FIGlet Copyright 1996, 1997 John Cowan
  Portions written by Paul Burton
  Internet: <ianchai@usa.net>
  FIGlet, along with the various FIGlet fonts and documentation, is
    copyrighted under the provisions of the Artistic License (as listed
    in the file "artistic.license" which is included in this package.

--]]

--[[
   Latin-1 codes for German letters, respectively:
     LATIN CAPITAL LETTER A WITH DIAERESIS = A-umlaut
     LATIN CAPITAL LETTER O WITH DIAERESIS = O-umlaut
     LATIN CAPITAL LETTER U WITH DIAERESIS = U-umlaut
     LATIN SMALL LETTER A WITH DIAERESIS = a-umlaut
     LATIN SMALL LETTER O WITH DIAERESIS = o-umlaut
     LATIN SMALL LETTER U WITH DIAERESIS = u-umlaut
     LATIN SMALL LETTER SHARP S = ess-zed
--]]

local deutsch = {196, 214, 220, 228, 246, 252, 223}
local fcharlist = {}
local magic, hardblank, charheight, maxlen, smush, cmtlines, ffright2left, smush2

local function readfontchar(fontfile, theord)

  local t = {}
  fcharlist[theord] = t

  -- read each character line

  --[[
  
  eg.
  
  __  __ @
 |  \/  |@
 | \  / |@
 | |\/| |@
 | |  | |@
 |_|  |_|@
         @
         @@
--]]

  for i = 1, charheight do
    local line = assert(fontfile:read("*l"), "Not enough character lines for character " .. theord)
    local line = string.gsub(line, "%s+$", "") -- remove trailing spaces
    assert(line ~= "", "Unexpected empty line")

    -- find the last character (eg. @)
    local endchar = line:sub(-1) -- last character

    -- trim one or more of the last character from the end
    while line:sub(-1) == endchar do
      line = line:sub(1, #line - 1)
    end -- while line ends with endchar

    table.insert(t, line)

  end -- for each line

end -- readfontchar

--- Reads a figlet font file (.flf) into memory and readies it for use by the next figlet
-- These files are cached in memory so that future calls to load a font just read from there.
-- @param filename the full path to the file to read the font from
function Figlet.readfont(filename)
  local fontfile = assert(io.open(filename, "r"))
  local s

  fcharlist = {}

  -- header line
  s = assert(fontfile:read("*l"), "Empty FIGlet file")

  -- eg.  flf2a$ 8 6          59     15     10        0             24463   153
  --      magic  charheight  maxlen  smush  cmtlines  ffright2left  smush2  ??

  -- configuration line
  magic, hardblank, charheight, maxlen, smush, cmtlines, ffright2left, smush2 = string.match(s,
                                                                                             "^(flf2).(.) (%d+) %d+ (%d+) (%-?%d+) (%d+) ?(%d*) ?(%d*) ?(%-?%d*)")

  assert(magic, "Not a FIGlet 2 font file")

  -- convert to numbers
  charheight = tonumber(charheight)
  maxlen = tonumber(maxlen)
  smush = tonumber(smush)
  cmtlines = tonumber(cmtlines)

  -- sanity check
  if charheight < 1 then
    charheight = 1
  end -- if

  -- skip comment lines      
  for i = 1, cmtlines do
    assert(fontfile:read("*l"), "Not enough comment lines")
  end -- for

  -- get characters space to tilde
  for theord = string.byte(' '), string.byte('~') do
    readfontchar(fontfile, theord)
  end -- for

  -- get 7 German characters
  for theord = 1, 7 do
    readfontchar(fontfile, deutsch[theord])
  end -- for

  -- get extra ones like:
  -- 0x0395  GREEK CAPITAL LETTER EPSILON
  -- 246  LATIN SMALL LETTER O WITH DIAERESIS

  repeat
    local extra = fontfile:read("*l")
    if not extra then
      break
    end -- if eof

    local negative, theord = string.match(extra, "^(%-?)0[xX](%x+)")
    if theord then
      theord = tonumber(theord, 16)
      if negative == "-" then
        theord = -theord
      end -- if negative
    else
      theord = string.match(extra, "^%d+")
      assert(theord, "Unexpected line:" .. extra)
      theord = tonumber(theord)
    end -- if

    readfontchar(fontfile, theord)

  until false

  fontfile:close()

  -- remove leading/trailing spaces

  for k, v in pairs(fcharlist) do

    -- first see if all lines have a leading space or a trailing space
    local leading_space = true
    local trailing_space = true
    for _, line in ipairs(v) do
      if line:sub(1, 1) ~= " " then
        leading_space = false
      end -- if
      if line:sub(-1, -1) ~= " " then
        trailing_space = false
      end -- if
    end -- for each line

    -- now remove them if necessary
    for i, line in ipairs(v) do
      if leading_space then
        v[i] = line:sub(2)
      end -- removing leading space
      if trailing_space then
        v[i] = line:sub(1, -2)
      end -- removing trailing space
    end -- for each line
  end -- for each character
end -- readfont

-- add one character to output lines
local function addchar(which, output, kern, smush)
  local c = fcharlist[string.byte(which)]
  if not c then
    return
  end -- if doesn't exist

  for i = 1, charheight do

    if smush and output[i] ~= "" and which ~= " " then
      local lhc = output[i]:sub(-1)
      local rhc = c[i]:sub(1, 1)
      output[i] = output[i]:sub(1, -2) -- remove last character
      if rhc ~= " " then
        output[i] = output[i] .. rhc
      else
        output[i] = output[i] .. lhc
      end
      output[i] = output[i] .. c[i]:sub(2)

    else
      output[i] = output[i] .. c[i]
    end -- if 

    if not (kern or smush) or which == " " then
      output[i] = output[i] .. " "
    end -- if
  end -- for

end -- addchar

--- Returns a table of lines representing a string as figlet
-- @tparam string s the text to make into a figlet
-- @tparam boolean kern should we reduce spacing
-- @tparam boolean smush causes the letters to share edges, condensing it even further
function Figlet.ascii_art(s, kern, smush)
  assert(fcharlist)
  assert(charheight > 0)

  -- make table of output lines
  local output = {}
  for i = 1, charheight do
    output[i] = ""
  end -- for

  for i = 1, #s do
    local c = s:sub(i, i)

    if c >= " " and c < "\127" then
      addchar(c, output, kern, smush)
    end -- if in range

  end -- for

  -- fix up blank character so we can do a string.gsub on it
  local fixedblank = string.gsub(hardblank, "[%%%]%^%-$().[*+?]", "%%%1")

  for i, line in ipairs(output) do
    output[i] = string.gsub(line, fixedblank, " ")
  end -- for

  return output
end -- function ascii_art

--- Returns the figlet as a string, rather than a table
-- @tparam string str the string the make into a figlet
-- @tparam boolean kern should we reduce the space between letters?
-- @tparam boolean smush should the letters share edges, further condensing the output?
-- @see ascii_art
function Figlet.getString(str, kern, smush)
  local tbl = Figlet.ascii_art(str, kern, smush)
  return table.concat(tbl, "\n")
end

--- Returns a figlet as a string, with kern set to true.
-- @tparam string str The string to turn into a figlet
-- @see getString
function Figlet.getKern(str)
  return Figlet.getString(str, true)
end

--- Returns a figlet as a string, with smush set to true.
-- @tparam string str The string to turn into a figlet
-- @see getString
function Figlet.getSmush(str)
  return Figlet.getString(str, true, true)
end

return Figlet
