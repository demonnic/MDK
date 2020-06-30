--- Stand alone text formatter object. Remembers the options you set and can be adjusted as needed
-- @classmod TextFormatter
--@author Damian Monogue <demonnic@gmail.com>
--@copyright 2020 Damian Monogue
--@license MIT, see LICENSE.lua

local TextFormatter = {}
TextFormatter.validFormatTypes = { 'd', 'dec', 'decimal', 'h', 'hex', 'hexidecimal', 'c', 'color', 'colour', 'col', 'name'}
local pathOfThisFile = (...):match("(.-)[^%.]+$")
local ftext = require(pathOfThisFile .. "ftext")
local fText = ftext.fText

--- Set's the formatting type whether it's for cecho, decho, or hecho
--@tparam string typeToSet What type of formatter is this? Valid options are { 'd', 'dec', 'decimal', 'h', 'hex', 'hexidecimal', 'c', 'color', 'colour', 'col', 'name'}
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
--@tparam boolean shouldWrap should we do wordwrapping?
function TextFormatter:setWrap(shouldWrap)
  local argumentType = type(shouldWrap)
  shouldWrap = self:toBoolean(shouldWrap)
  if shouldWrap == nil then
    error("TextFormatter:setWrap(shouldWrap) Argument error, boolean expected, got " .. argumentType .. ", if you want to set the number of characters wide to format for, use setWidth()")
  end
  self.options.wrap = shouldWrap
end

--- Sets the width we should format for
--@tparam number width the width we should format for
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
--@tparam string cap the string to use for capping the formatted string.
function TextFormatter:setCap(cap)
  local argumentType = type(cap)
  local cap = self:checkString(cap)
  if cap == nil then error("TextFormatter:setCap(cap): Argument error, string expect, got " .. argumentType) end
  self.options.cap = cap
end

--- Sets the color for the format cap
--@tparam string capColor Color which can be formatted via Geyser.Color.parse()
function TextFormatter:setCapColor(capColor)
  local argumentType = type(capColor)
  local capColor = self:checkString(capColor)
  if capColor == nil then error("TextFormatter:setCapColor(capColor): Argument error, string expected, got " .. argumentType) end
  self.options.capColor = capColor
end

--- Sets the color for spacing character
--@tparam string spacerColor Color which can be formatted via Geyser.Color.parse()
function TextFormatter:setSpacerColor(spacerColor)
  local argumentType = type(spacerColor)
  local spacerColor = self:checkString(spacerColor)
  if spacerColor == nil then error("TextFormatter:setSpacerColor(spacerColor): Argument error, string expected, got " .. argumentType) end
  self.options.spacerColor = spacerColor
end

--- Sets the color for formatted text
--@tparam string textColor Color which can be formatted via Geyser.Color.parse()
function TextFormatter:setTextColor(textColor)
  local argumentType = type(textColor)
  local textColor = self:checkString(textColor)
  if textColor == nil then error("TextFormatter:setTextColor(textColor): Argument error, string expected, got " .. argumentType) end
  self.options.textColor = textColor
end

--- Sets the spacing character to use. Should be a single character
--@tparam string spacer the character to use for spacing
function TextFormatter:setSpacer(spacer)
  local argumentType = type(spacer)
  local spacer = self:checkString(spacer)
  if spacer == nil then error("TextFormatter:setSpacer(spacer): Argument error, string expect, got " .. argumentType) end
  self.options.spacer = spacer
end

--- Set the alignment to format for
--@tparam string alignment How to align the formatted string. Valid options are 'left', 'right', or 'center'
function TextFormatter:setAlignment(alignment)
  local validAlignments = {
    "left",
    "right",
    "center"
  }
  if not table.contains(validAlignments, alignment) then
    error("TextFormatter:setAlignment(alignment): Argument error: Only valid arguments for setAlignment are 'left', 'right', or 'center'. You sent" .. alignment)
  end
  self.options.alignment = alignment
end

--- Set whether the the spacer should go inside the the cap or outside of it
--@tparam boolean spacerInside 
function TextFormatter:setInside(spacerInside)
  local argumentType = type(spacerInside)
  spacerInside = self:toBoolean(spacerInside)
  if spacerInside == nil then
    error("TextFormatter:setInside(spacerInside) Argument error, boolean expected, got " .. argumentType)
  end
  self.options.inside = spacerInside
end

--- Set whether we should mirror/reverse the caps. IE << becomes >> if set to true
--@tparam boolean shouldMirror
function TextFormatter:setMirror(shouldMirror)
  local argumentType = type(shouldMirror)
  shouldMirror = self:toBoolean(shouldMirror)
  if shouldMirror == nil then
    error("TextFormatter:setMirror(shouldMirror): Argument error, boolean expected, got " .. argumentType)
  end
  self.options.mirror = shouldMirror
end

--- Format a string based on the stored options
--@tparam string str The string to format
function TextFormatter:format(str)
  return fText(str, self.options)
end

--- Creates and returns a new TextFormatter. For valid options, please see https://github.com/demonnic/fText/wiki/fText
--@tparam table options the options for the text formatter to use when running format()
--<br><br>Table of options
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
--     <td class="tg-odd">wrap</td>
--     <td class="tg-odd">Should it wordwrap to multiple lines?</td>
--     <td class="tg-odd">true</td>
--   </tr>
--   <tr>
--     <td class="tg-even">formatType</td>
--     <td class="tg-even">Determines how it formats for color. 'c' for cecho, 'd' for decho, 'h' for hecho, and anything else for no colors</td>
--     <td class="tg-even">"c"</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">width</td>
--     <td class="tg-odd">How wide should we format the text?</td>
--     <td class="tg-odd">80</td>
--   </tr>
--   <tr>
--     <td class="tg-even">cap</td>
--     <td class="tg-even">what characters to use for the endcap.</td>
--     <td class="tg-even">""</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">capColor</td>
--     <td class="tg-odd">what color to make the endcap?</td>
--     <td class="tg-odd">the correct 'white' for your formatType</td>
--   </tr>
--   <tr>
--     <td class="tg-even">spacer</td>
--     <td class="tg-even">What character to use for empty space. Must be a single character</td>
--     <td class="tg-even">" "</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">spacerColor</td>
--     <td class="tg-odd">what color should the spacer be?</td>
--     <td class="tg-odd">the correct 'white' for your formatType</td>
--   </tr>
--   <tr>
--     <td class="tg-even">textColor</td>
--     <td class="tg-even">what color should the text itself be?</td>
--     <td class="tg-even">the correct 'white' for your formatType</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">alignment</td>
--     <td class="tg-odd">How should the text be aligned within the width. "center", "left", or "right"</td>
--     <td class="tg-odd">"center"</td>
--   </tr>
--   <tr>
--     <td class="tg-even">nogap</td>
--     <td class="tg-even">Should we put a literal space between the spacer character and the text?</td>
--     <td class="tg-even">false</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">inside</td>
--     <td class="tg-odd">Put the spacers inside the caps?</td>
--     <td class="tg-odd">false</td>
--   </tr>
--   <tr>
--     <td class="tg-even">mirror</td>
--     <td class="tg-even">Should the endcap be reversed on the right? IE [[ becomes ]]</td>
--     <td class="tg-even">true</td>
--   </tr>
-- </tbody>
-- </table>

function TextFormatter:new(options)
  if options == nil then options = {} end
  if options and type(options) ~= "table" then
    error("TextFormatter:new(options): Argument error, table expected, got " .. type(options))
  end
  local me = {}
  me.options = {
    formatType = "c",
    wrap = true,
    width = 80,
    cap = "",
    spacer = " ",
    alignment = "center",
    inside = true,
    mirror = false,
  }
  for option, value in pairs(options) do
    me.options[option] = value
  end
  setmetatable(me, self)
  self.__index = self
  return me
end

return TextFormatter
