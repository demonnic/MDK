--- Creates a text based gauge, for use in miniconsoles and the like.
-- @classmod TextGauge
-- @author Damian Monogue <demonnic@gmail.com>
-- @copyright 2020 Damian Monogue
-- @copyright 2021 Damian Monogue
-- @license MIT, see LICENSE.lua
local TextGauge = {width = 24, fillCharacter = ":", emptyCharacter = "-", showPercent = true, showPercentSymbol = true, format = "c", value = 50}

--- Creates a new TextGauge.
-- @tparam[opt] table options The table of options you would like the TextGauge to start with.
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
--     <td class="tg-1">width</td>
--     <td class="tg-1">How many characters wide to make the gauge</td>
--     <td class="tg-1">24</td>
--   </tr>
--   <tr>
--     <td class="tg-2">fillCharacter</td>
--     <td class="tg-2">What character to use for the 'full' part of the gauge</td>
--     <td class="tg-2">:</td>
--   </tr>
--   <tr>
--     <td class="tg-1">overflowCharacter</td>
--     <td class="tg-1">What character to use for >100% part of the gauge</td>
--     <td class="tg-1">if not set, it uses whatever you set fillCharacter to</td>
--   </tr>
--   <tr>
--     <td class="tg-2">emptyCharacter</td>
--     <td class="tg-2">What character to use for the 'empty' part of the gauge</td>
--     <td class="tg-2">-</td>
--   </tr>
--   <tr>
--     <td class="tg-1">showPercentSymbol</td>
--     <td class="tg-1">Should we show the % sign itself?</td>
--     <td class="tg-1">true</td>
--   </tr>
--   <tr>
--     <td class="tg-2">showPercent</td>
--     <td class="tg-2">Should we show what % of the gauge is filled?</td>
--     <td class="tg-2">true</td>
--   </tr>
--   <tr>
--     <td class="tg-1">value</td>
--     <td class="tg-1">How much of the gauge should be filled</td>
--     <td class="tg-1">50</td>
--   </tr>
--   <tr>
--     <td class="tg-2">format</td>
--     <td class="tg-2">What type of color formatting to use? 'c' for cecho, 'd' for decho, 'h' for hecho</td>
--     <td class="tg-2">c</td>
--   </tr>
--   <tr>
--     <td class="tg-1">fillColor</td>
--     <td class="tg-1">What color to make the full part of the bar?</td>
--     <td class="tg-1">"DarkOrange" or equivalent for your format type</td>
--   </tr>
--   <tr>
--     <td class="tg-2">emptyColor</td>
--     <td class="tg-2">what color to use for the empty part of the bar?</td>
--     <td class="tg-2">"white" or format appropriate equivalent</td>
--   </tr>
--   <tr>
--     <td class="tg-1">percentColor</td>
--     <td class="tg-1">What color to print the percentage numvers in, if shown?</td>
--     <td class="tg-1">"white" or fortmat appropriate equivalent</td>
--   </tr>
--   <tr>
--     <td class="tg-2">percentSymbolColor</td>
--     <td class="tg-2">What color to make the % if shown?</td>
--     <td class="tg-2">If not set, uses what percentColor is set to.</td>
--   </tr>
--   <tr>
--     <td class="tg-1">overflowColor</td>
--     <td class="tg-1">What color to make the >100% portion of the bar?</td>
--     <td class="tg-1">If not set, will use the same color as fillColor</td>
--   </tr>
-- </tbody>
-- </table>
-- @usage
-- local TextGauge = require("MDK.textgauge")
-- myTextGauge = TextGauge:new()
-- gaugeText = myTextGauge:setValue(382, 830)
function TextGauge:new(options)
  options = options or {}
  local optionsType = type(options)
  assert(optionsType == "table" or optionsType == "nil", "TextGauge:new(options): options expected as table, got " .. optionsType)
  local me = table.deepcopy(options)
  setmetatable(me, self)
  self.__index = self
  me:setDefaultColors()
  return me
end

--- Sets the width in characters of the gauge
-- @tparam number width number of characters wide to make the gauge
function TextGauge:setWidth(width)
  local widthType = type(width)
  assert(widthType == "number", string.format("TextGauge:setWidth(width): width as number expected, got %s", widthType))
  self.width = width
end

function TextGauge:setFormat(format)
  self.format = self:getColorType(format)
  self:setDefaultColors()
end

--- Sets the character to use for the 'full' part of the gauge
-- @tparam string character the character to use.
function TextGauge:setFillCharacter(character)
  assert(character ~= nil, "TextGauge:setFillCharacter(character): character required, got nil")
  assert(utf8.len(character) == 1, "TextGauge:setFillCharacter(character): character must be a single character")
  self.fillCharacter = character
end

--- Sets the character to use for the 'overflow' (>100%) part of the gauge
-- @tparam string character the character to use.
function TextGauge:setOverflowCharacter(character)
  assert(character ~= nil, "TextGauge:setOverflowCharacter(character): character required, got nil")
  assert(utf8.len(character) == 1, "TextGauge:setOverflowCharacter(character): character must be a single character")
  self.overflowCharacter = character
end

--- Sets the character to use for the 'full' part of the gauge
-- @tparam string character the character to use.
function TextGauge:setEmptyCharacter(character)
  assert(character ~= nil, "TextGauge:setEmptyCharacter(character): character required, got nil")
  assert(utf8.len(character) == 1, "TextGauge:setEmptyCharacter(character): character must be a single character")
  self.emptyCharacter = character
end

--- Sets the fill color for the gauge.
-- @tparam string color the color to use for the full portion of the gauge. Will be run through Geyser.Golor
function TextGauge:setFillColor(color)
  assert(color ~= nil, "TextGauge:setFillColor(color): color required, got nil")
  self.fillColor = color
end

--- Sets the overflow color for the gauge.
-- @tparam string color the color to use for the full portion of the gauge. Will be run through Geyser.Golor
function TextGauge:setOverflowColor(color)
  assert(color ~= nil, "TextGauge:setOverflowColor(color): color required, got nil")
  self.overflowColor = color
end

--- Sets the empty color for the gauge.
-- @tparam string color the color to use for the empty portion of the gauge. Will be run through Geyser.Golor
function TextGauge:setEmptyColor(color)
  assert(color ~= nil, "TextGauge:setEmptyColor(color): color required, got nil")
  self.emptyColor = color
end

--- Sets the fill color for the gauge.
-- @tparam string color the color to use for the numeric value. Will be run through Geyser.Golor
function TextGauge:setPercentColor(color)
  assert(color ~= nil, "TextGauge:setPercentColor(color): color required, got nil")
  self.percentColor = color
end
--- Sets the fill color for the gauge.
-- @tparam string color the color to use for the numeric value. Will be run through Geyser.Golor
function TextGauge:setPercentSymbolColor(color)
  assert(color ~= nil, "TextGauge:setPercentSymbolColor(color): color required, got nil")
  self.percentSymbolColor = color
end

--- Enables reversing the fill direction (right to left instead of the usual left to right)
function TextGauge:enableReverse()
  self.reverse = true
end

--- Disables reversing the fill direction (go back to the usual left to right)
function TextGauge:disableReverse()
  self.reverse = false
end

--- Enables showing the percent value of the gauge
function TextGauge:enableShowPercent()
  self.showPercent = true
end

--- Disables showing the percent value of the gauge
function TextGauge:disableShowPercent()
  self.showPercent = false
end

--- Enables showing the percent symbol (appears after the value)
function TextGauge:enableShowPercentSymbol()
  self.showPercentSymbol = true
end

--- Enables showing the percent symbol (appears after the value)
function TextGauge:disableShowPercentSymbol()
  self.showPercentSymbol = false
end

function TextGauge:getColorType(format)
  format = format or self.format
  local dec = {"d", "decimal", "dec", "decho"}
  local hex = {"h", "hexidecimal", "hex", "hecho"}
  local col = {"c", "color", "colour", "col", "name", "cecho"}
  if table.contains(col, format) then
    return "c"
  elseif table.contains(dec, format) then
    return "d"
  elseif table.contains(hex, format) then
    return "h"
  else
    return ""
  end
end

-- internal function, used at instantiation to ensure some colors are set
function TextGauge:setDefaultColors()
  local colorType = self:getColorType()
  if colorType == "c" then
    self.percentColor = self.percentColor or "white"
    self.percentSymbolColor = self.percentSymbolColor or self.percentColor
    self.fillColor = self.fillColor or "DarkOrange"
    self.emptyColor = self.emptyColor or "white"
    self.resetColor = "<reset>"
  elseif colorType == "d" then
    self.percentColor = self.percentColor or "<255,255,255>"
    self.percentSymbolColor = self.percentSymbolColor or self.percentColor
    self.fillColor = self.fillColor or "<255,140,0>"
    self.emptyColor = self.emptyColor or "<255,255,255>"
    self.resetColor = "<r>"
  elseif colorType == "h" then
    self.percentColor = self.percentColor or "#ffffff"
    self.percentSymbolColor = self.percentSymbolColor or self.percentColor
    self.fillColor = self.fillColor or "#ff8c00"
    self.emptyColor = self.emptyColor or "#ffffff"
    self.resetColor = "#r"
  else
    self.percentColor = self.percentColor or ""
    self.percentSymbolColor = self.percentSymbolColor or self.percentColor
    self.fillColor = self.fillColor or ""
    self.emptyColor = self.emptyColor or ""
    self.resetColor = ""
  end
  self.overflowColor = self.overflowColor or self.fillColor
end

-- Internal function used to route Geyser.Color based on internally stored format
function TextGauge:getColor(color)
  local colorType = self:getColorType()
  if colorType == "c" then
    return string.format("<%s>", color) -- pass the color back in <> for cecho
  elseif colorType == "d" then
    return Geyser.Color.hdec(color) -- return it in decho format
  elseif colorType == "h" then
    return Geyser.Color.hex(color) -- return it in hex format
  else
    return "" -- return an empty string for noncolored output
  end
end

--- Used to set the gauge's value and return the string representation of the gauge
-- @tparam[opt] number current current value. If no value is passed it will use the stored value. Defaults to 50 to prevent errors.
-- @tparam[opt] number max maximum value. If not passed, the internally stored one will be used. Defaults to 100 so that it can be used with single values as a percent
-- @usage myGauge:setValue(55) -- sets the gauge to 55% full
-- @usage myGauge:setValue(2345, 2780) -- will figure out what the percentage fill is based on the given current/max values
function TextGauge:setValue(current, max)
  current = current or self.value
  assert(type(current) == "number", "TextGauge:setValue(current,max) current as number expected, got " .. type(current))
  assert(max == nil or type(max) == "number", "TextGauge:setValue(current, max) option max as number expected, got " .. type(max))
  if current < 0 then
    current = 0
  end
  max = max or 100
  local value = math.floor(current / max * 100)
  self.value = value
  local width = self.width
  local percentString = ""
  local percentSymbolString = ""
  local fillCharacter = self.fillCharacter
  local overflowCharacter = self.overflowCharacter or fillCharacter
  local emptyCharacter = self.emptyCharacter
  local fillColor = self:getColor(self.fillColor)
  local overflowColor = self:getColor(self.overflowColor)
  local emptyColor = self:getColor(self.emptyColor)
  local percentColor = self:getColor(self.percentColor)
  local percentSymbolColor = self:getColor(self.percentSymbolColor)
  local resetColor = self.resetColor
  if self.showPercent then
    percentString = string.format("%s%02d%s", percentColor, value, resetColor)
    width = width - 2
  end
  if self.showPercentSymbol then
    percentSymbolString = string.format("%s%s%s", percentSymbolColor, "%", resetColor)
    width = width - 1
  end
  local perc = value / 100
  local overflow = perc - 1
  if overflow < 0 then
    overflow = 0
  end
  if overflow > 1 then
    perc = 2
    overflow = 1
  end
  local overflowWidth = math.floor(overflow * width)
  local fillWidth = math.floor((perc - overflow) * width)
  local emptyWidth = width - fillWidth
  fillWidth = fillWidth - overflowWidth
  if value >= 100 and self.showPercent then
    fillWidth = fillWidth - 1
  end
  if value >= 200 and self.showPercent then
    overflowWidth = overflowWidth - 1
  end
  local result = ""
  if self.reverse then
    result = string.format("%s%s%s%s%s%s%s%s%s%s%s", emptyColor, string.rep(emptyCharacter, emptyWidth), resetColor,fillColor, string.rep(fillCharacter, fillWidth), resetColor, overflowColor, string.rep(overflowCharacter, overflowWidth), resetColor, percentString, percentSymbolString, resetColor)
  else
    result = string.format("%s%s%s%s%s%s%s%s%s%s%s", overflowColor, string.rep(overflowCharacter, overflowWidth), fillColor,
                  string.rep(fillCharacter, fillWidth), resetColor, emptyColor, string.rep(emptyCharacter, emptyWidth), resetColor,
                  percentString, percentSymbolString, resetColor)
  end
  return result
end

--- Synonym for setValue
function TextGauge:print(...)
  self:setValue(...)
end

return TextGauge
