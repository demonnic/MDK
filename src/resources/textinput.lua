--- A Geyser object for creating a labeled text input box to set a variable
-- @classmod TextInput
-- @author Damian Monogue <demonnic@gmail.com>
-- @copyright 2024 Damian Monogue
-- @license MIT, see LICENSE.lua
local TextInput = {
  parent = Geyser.Container,
  name = "TextInputClass",
  message = "Enter:",
  alignment = "right",
  fontSize = "10",
  font = "Ubuntu Mono",
  labelWidth = "25%",
  value = "Replace this with what you want to set",
  color = "#202020",
  fgColor = "white"
}
setmetatable(TextInput, TextInput.parent)
TextInput.__index = TextInput
local gss = Geyser.StyleSheet
local Label = Geyser.Label
local CommandLine = Geyser.CommandLine

-- Create a new TextInput object
function TextInput:new(cons, container)
  local me = self.parent:new(cons, container)
  setmetatable(me, self)
  me:createComponents()
  return me
end

--- internal function responsible for creating the underlying Geyser objects
-- @local
function TextInput:createComponents()
  self.label = Label:new({
    name = self.name .. "Label",
    x = 0,
    y = 0,
    height = "100%",
    width = self.labelWidth,
    message = self.message,
    font = self.font,
    fontSize = self.fontSize,
    alignment = self.alignment,
  }, self)
  self.label:setAlignment(self.alignment)
  self.label:echo()
  self.input = CommandLine:new({
    name = self.name .. "Input",
    x = self.labelWidth,
    y = 0,
    height = "100%",
    width = "-" .. self.labelWidth,
  }, self)
  self.inputStyleSheet = gss:new({}, nil, "QPlainTextEdit")
  self:adjustInputStyle()
  self.input:print(self.value)
  local function handleInput(input)
    self:setValue(input)
  end
  self.input:setAction(handleInput)
end

--- Sets the value for the TextInput object.
--- This will also raise an event and if a callback is defined call that
-- @tparam string value The value to set the TextInput to
-- @tparam boolean skipHook If true, the event and callback will not be called
function TextInput:setValue(value, skipHook)
  self.oldValue = self.value
  self.value = value
  tempTimer(0, function() self.input:print(value) end)
  if not skipHook then
    self:handleCallBacks()
  end
end

--- Internal function which raises the event when the value is changed
--- and also calls the callback if one is defined
-- @local
function TextInput:handleCallBacks()
  raiseEvent("TextInput updated", self.name, self.value, self.oldValue)
  if self.callBack then
    local ok, err = pcall(self.callBack, self.name, self.value, self.oldValue)
    if not ok then
      printError(f"Had an issue running the callback handler for TextInput named {self.name}: {err}", true, true)
    end
  end
end

--- Sets the message or prompt for the TextInput object
-- @tparam string msg The message to set the TextInput's label to
function TextInput:setMessage(msg)
  self.message = msg
  self.label:echo(msg)
end

--- Sets the font for the TextInput object
-- @tparam string font The font to use
function TextInput:setFont(font)
  self.label:setFont(font)
  self:adjustInputStyle()
end

--- Sets the font size for the TextInput object
-- @tparam number fontSize The font size to use
function TextInput:setFontSize(fontSize)
  self.label:setFontSize(fontSize)
  self:adjustInputStyle()
end

--- Sets the color for the TextInput object
-- @tparam string color The color to use. Can be anything parsable by Geyser.Color
function TextInput:setColor(color)
  self.color = color
  self.label:setColor(color)
  self:adjustInputStyle()
end

--- Sets the foreground color for the TextInput object
-- @tparam string color The color to use. Can be anything parsable by Geyser.Color
function TextInput:setFgColor(color)
  self.fgColor = color
  self.label:setFgColor(color)
  self:adjustInputStyle()
end

--- Sets the alignment for the TextInput object
-- @tparam string alignment The alignment to use
function TextInput:setAlignment(alignment)
  self.label:setAlignment(alignment)
end

--- Sets the label width for the TextInput object
--- the input box takes up whatever is left over
-- @tparam number width The width to set the label portion to
function TextInput:setLabelWidth(width)
  self.label:resize(width, "100%")
  self.input:resize("-" .. width, "100%")
end

--- Internal function responsible for taking the TextInput's settings
--- and creating a suitable stylesheet for the input box
-- @local
function TextInput:adjustInputStyle()
  local style = self.inputStyleSheet
  local color = Geyser.Color.hex(self.color)
  local fgColor = Geyser.Color.hex(self.fgColor)
  local _, fontHeight = calcFontSize(self.fontSize, self.font)
  -- we add padding for half the height, minus half the fontheight and an additional 2 pixels which seems to make it line up better
  -- magic number arrived at after much testing.
  local padding = (self:get_height() / 2) - (fontHeight / 2) - 2
  style:set("font", f[[{self.fontSize}pt "{self.font}"]])
  style:set("background-color", color)
  style:set("color", fgColor)
  style:set("padding", padding .. "px 5px")
  self.input:setStyleSheet(style:getCSS())
  self.input:print(self.value)
end

--- Overrides the resize function to adjust the input stylesheet when resized
-- @local
function TextInput:resize(width, height)
  self.parent.resize(self, width, height)
  self:adjustInputStyle()
end

return TextInput