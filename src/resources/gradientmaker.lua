--- Module which provides for creating color gradients for your text.
-- Original functions found on <a href="https://forums.lusternia.com/discussion/3261/anyone-want-text-gradients">the Lusternia Forums</a>
-- <br> I added functions to work with hecho.
-- <br> I also made performance enhancements by storing already calculated gradients after first use for the session and only including the colorcode in the returned string if the color changed.
-- @module GradientMaker
-- @author Sylphas on the Lusternia forums
-- @author Damian Monogue <demonnic@gmail.com>
-- @copyright 2018 Sylphas
-- @copyright 2020 Damian Monogue
local GradientMaker = {}
local gradient_table = {}

local function _clamp(num1, num2, num3)
  local smaller = math.min(num2, num3)
  local larger = math.max(num2, num3)
  local minimum = math.max(0, smaller)
  local maximum = math.min(255, larger)
  return math.min(maximum, math.max(minimum, num1))
end

local function _gradient(length, rgb1, rgb2)
  assert(length > 0)
  if length == 1 then
    return {rgb1}
  elseif length == 2 then
    return {rgb1, rgb2}
  else
    local step = {}
    for color = 1, 3 do
      step[color] = (rgb2[color] - rgb1[color]) / (length - 2)
    end
    local gradient = {rgb1}
    for iter = 1, length - 2 do
      gradient[iter + 1] = {}
      for color = 1, 3 do
        gradient[iter + 1][color] = math.ceil(rgb1[color] + (iter * step[color]))
      end
    end
    gradient[length] = rgb2
    for index, color in ipairs(gradient) do
      for iter = 1, 3 do
        gradient[index][iter] = _clamp(color[iter], rgb1[iter], rgb2[iter])
      end
    end
    return gradient
  end
end

local function gradient_to_string(gradient)
  local gradstring = ""
  for _, grad in ipairs(gradient) do
    local nodestring = ""
    for _, col in ipairs(grad) do
      nodestring = string.format("%s%03d", nodestring, col)
    end
    if _ == 1 then
      gradstring = nodestring
    else
      gradstring = gradstring .. "|" .. nodestring
    end
  end
  return gradstring
end

local function _gradients(length, ...)
  local arg = {...}
  local argkey = gradient_to_string(arg)
  local gradients_for_length = gradient_table[length]
  if not gradients_for_length then
    gradient_table[length] = {}
    gradients_for_length = gradient_table[length]
  end
  local grads = gradients_for_length[argkey]
  if grads then
    return grads
  end
  if #arg == 0 then
    gradients_for_length[argkey] = {}
    return {}
  elseif #arg == 1 then
    gradients_for_length[argkey] = arg[1]
    return arg[1]
  elseif #arg == 2 then
    gradients_for_length[argkey] = _gradient(length, arg[1], arg[2])
    return gradients_for_length[argkey]
  else
    local quotient = math.floor(length / (#arg - 1))
    local remainder = length % (#arg - 1)
    local gradients = {}
    for section = 1, #arg - 1 do
      local slength = quotient
      if section <= remainder then
        slength = slength + 1
      end
      local gradient = _gradient(slength, arg[section], arg[section + 1])
      for _, rgb in ipairs(gradient) do
        table.insert(gradients, rgb)
      end
    end
    gradients_for_length[argkey] = gradients
    return gradients
  end
end

local function _color_name(rgb)
  local least_distance = math.huge
  local cname = ""
  for name, color in pairs(color_table) do
    local color_distance = math.sqrt((color[1] - rgb[1]) ^ 2 + (color[2] - rgb[2]) ^ 2 + (color[3] - rgb[3]) ^ 2)
    if color_distance < least_distance then
      least_distance = color_distance
      cname = name
    end
  end
  return cname
end

local function errorIfEmpty(text, funcName)
  assert(#text > 0, string.format("%s: you passed in an empty string, and I cannot make a gradient out of an empty string", funcName))
end

local function dgradient_table(text, ...)
  errorIfEmpty(text, "dgradient_table")
  local gradients = _gradients(#text, ...)
  local dgrads = {}
  for character = 1, #text do
    table.insert(dgrads, {gradients[character], text:sub(character, character)})
  end
  return dgrads
end

local function dgradient(text, ...)
  errorIfEmpty(text, "dgradient")
  local gradients = _gradients(#text, ...)
  local dgrad = ""
  local current_color = ""
  for character = 1, #text do
    local new_color = "<" .. table.concat(gradients[character], ",") .. ">"
    local char = text:sub(character, character)
    if new_color == current_color then
      dgrad = dgrad .. char
    else
      dgrad = dgrad .. new_color .. char
      current_color = new_color
    end
  end
  return dgrad
end

local function cgradient_table(text, ...)
  errorIfEmpty(text, "cgradient_table")
  local gradients = _gradients(#text, ...)
  local cgrads = {}
  for character = 1, #text do
    table.insert(cgrads, {_color_name(gradients[character]), text:sub(character, character)})
  end
  return cgrads
end

local function cgradient(text, ...)
  errorIfEmpty(text, "cgradient")
  local gradients = _gradients(#text, ...)
  local cgrad = ""
  local current_color = ""
  for character = 1, #text do
    local new_color = "<" .. _color_name(gradients[character]) .. ">"
    local char = text:sub(character, character)
    if new_color == current_color then
      cgrad = cgrad .. char
    else
      cgrad = cgrad .. new_color .. char
      current_color = new_color
    end
  end
  return cgrad
end

local hex = Geyser.Color.hex

local function hgradient_table(text, ...)
  errorIfEmpty(text, "hgradient_table")
  local grads = _gradients(#text, ...)
  local hgrads = {}
  for character = 1, #text do
    table.insert(hgrads, {hex(unpack(grads[character])):sub(2, -1), text:sub(character, character)})
  end
  return hgrads
end

local function hgradient(text, ...)
  errorIfEmpty(text, "hgradient")
  local grads = _gradients(#text, ...)
  local hgrads = ""
  local current_color = ""
  for character = 1, #text do
    local new_color = hex(unpack(grads[character]))
    local char = text:sub(character, character)
    if new_color == current_color then
      hgrads = hgrads .. char
    else
      hgrads = hgrads .. new_color .. char
      current_color = new_color
    end
  end
  return hgrads
end

local function color_name(...)
  local arg = {...}
  if #arg == 1 then
    return _color_name(arg[1])
  elseif #arg == 3 then
    return _color_name(arg)
  else
    local errmsg =
      "color_name: You must pass either a table of r,g,b values: color_name({r,g,b})\nor the three r,g,b values separately: color_name(r,g,b)"
    error(errmsg)
  end
end

--- Returns the closest color name to a given r,g,b color
-- @param r The red component. Can also pass the full color as a table, IE { 255, 0, 0 }
-- @param g The green component. If you pass the color as a table as noted above, this param should be empty
-- @param b the blue components. If you pass the color as a table as noted above, this param should be empty
-- @usage
-- closest_color = GradientMaker.color_name(128,200,30) -- returns "ansi_149"
-- closest_color = GradientMaker.color_name({128, 200, 30}) -- this is functionally equivalent to the first one
function GradientMaker.color_name(...)
  return color_name(...)
end

--- Returns the text, with the defined color gradients applied and formatted for us with decho. Usage example below produces the following text
-- <br><img src="https://demonnic.github.io/mdk/images/dechogradient.png" alt="dgradient example">
-- @tparam string text The text you want to apply the color gradients to
-- @param first_color The color you want it to start at. Table of colors in { r, g, b } format
-- @param second_color The color you want the gradient to transition to first. Table of colors in { r, g, b } format
-- @param next_color Keep repeating if you want it to transition from the second color to a third, then a third to a fourth, etc
-- @see cgradient
-- @see hgradient
-- @usage
-- decho(GradientMaker.dgradient("a luminescent butterly floats about lazily on brillant blue and lilac wings\n", {255,0,0}, {255,128,0}, {255,255,0}, {0,255,0}, {0,255,255}, {0,128,255}, {128,0,255}))
-- decho(GradientMaker.dgradient("a luminescent butterly floats about lazily on brillant blue and lilac wings\n", {255,0,0}, {0,0,255}))
-- decho(GradientMaker.dgradient("a luminescent butterly floats about lazily on brillant blue and lilac wings\n", {50,50,50}, {0,255,0}, {50,50,50}))
function GradientMaker.dgradient(text, ...)
  return dgradient(text, ...)
end

--- Returns the text, with the defined color gradients applied and formatted for us with cecho. Usage example below produces the following text
-- <br><img src="https://demonnic.github.io/mdk/images/cechogradient.png" alt="cgradient example">
-- @tparam string text The text you want to apply the color gradients to
-- @param first_color The color you want it to start at. Table of colors in { r, g, b } format
-- @param second_color The color you want the gradient to transition to first. Table of colors in { r, g, b } format
-- @param next_color Keep repeating if you want it to transition from the second color to a third, then a third to a fourth, etc
-- @see dgradient
-- @see hgradient
-- @usage
-- cecho(GradientMaker.cgradient("a luminescent butterly floats about lazily on brillant blue and lilac wings\n", {255,0,0}, {255,128,0}, {255,255,0}, {0,255,0}, {0,255,255}, {0,128,255}, {128,0,255}))
-- cecho(GradientMaker.cgradient("a luminescent butterly floats about lazily on brillant blue and lilac wings\n", {255,0,0}, {0,0,255}))
-- cecho(GradientMaker.cgradient("a luminescent butterly floats about lazily on brillant blue and lilac wings\n", {50,50,50}, {0,255,0}, {50,50,50}))
function GradientMaker.cgradient(text, ...)
  return cgradient(text, ...)
end

--- Returns the text, with the defined color gradients applied and formatted for us with hecho. Usage example below produces the following text
-- <br><img src="https://demonnic.github.io/mdk/images/hechogradient.png" alt="hgradient example">
-- @tparam string text The text you want to apply the color gradients to
-- @param first_color The color you want it to start at. Table of colors in { r, g, b } format
-- @param second_color The color you want the gradient to transition to first. Table of colors in { r, g, b } format
-- @param next_color Keep repeating if you want it to transition from the second color to a third, then a third to a fourth, etc
-- @see cgradient
-- @see dgradient
-- @usage
-- hecho(GradientMaker.hgradient("a luminescent butterly floats about lazily on brillant blue and lilac wings\n", {255,0,0}, {255,128,0}, {255,255,0}, {0,255,0}, {0,255,255}, {0,128,255}, {128,0,255}))
-- hecho(GradientMaker.hgradient("a luminescent butterly floats about lazily on brillant blue and lilac wings\n", {255,0,0}, {0,0,255}))
-- hecho(GradientMaker.hgradient("a luminescent butterly floats about lazily on brillant blue and lilac wings\n", {50,50,50}, {0,255,0}, {50,50,50}))
function GradientMaker.hgradient(text, ...)
  return hgradient(text, ...)
end

--- Returns a table, each element of which is a table, the first element of which is the color name to use and the character which should be that color
-- @tparam string text The text you want to apply the color gradients to
-- @param first_color The color you want it to start at. Table of colors in { r, g, b } format
-- @param second_color The color you want the gradient to transition to first. Table of colors in { r, g, b } format
-- @param next_color Keep repeating if you want it to transition from the second color to a third, then a third to a fourth, etc
-- @see cgradient
function GradientMaker.cgradient_table(text, ...)
  return cgradient_table(text, ...)
end

--- Returns a table, each element of which is a table, the first element of which is the color({r,g,b} format) to use and the character which should be that color
-- @tparam string text The text you want to apply the color gradients to
-- @param first_color The color you want it to start at. Table of colors in { r, g, b } format
-- @param second_color The color you want the gradient to transition to first. Table of colors in { r, g, b } format
-- @param next_color Keep repeating if you want it to transition from the second color to a third, then a third to a fourth, etc
-- @see dgradient
function GradientMaker.dgradient_table(text, ...)
  return dgradient_table(text, ...)
end

--- Returns a table, each element of which is a table, the first element of which is the color(in hex) to use and the second element of which is the character which should be that color
-- @tparam string text The text you want to apply the color gradients to
-- @param first_color The color you want it to start at. Table of colors in { r, g, b } format
-- @param second_color The color you want the gradient to transition to first. Table of colors in { r, g, b } format
-- @param next_color Keep repeating if you want it to transition from the second color to a third, then a third to a fourth, etc
-- @see hgradient
function GradientMaker.hgradient_table(text, ...)
  return hgradient_table(text, ...)
end

--- Creates global copies of the c/d/hgradient(_table) functions and color_name for use without accessing the module table
-- @usage
-- GradientMaker.install_global()
-- cecho(cgradient(...)) -- use cgradient directly now
function GradientMaker.install_global()
  _G["hgradient"] = function(...)
    return hgradient(...)
  end
  _G["dgradient"] = function(...)
    return dgradient(...)
  end
  _G["cgradient"] = function(...)
    return cgradient(...)
  end
  _G["hgradient_table"] = function(...)
    return hgradient_table(...)
  end
  _G["dgradient_table"] = function(...)
    return dgradient_table(...)
  end
  _G["cgradient_table"] = function(...)
    return cgradient_table(...)
  end
  _G["color_name"] = function(...)
    return color_name(...)
  end
end

-- function GradientMaker.getGrads()
--   return gradient_table
-- end

return GradientMaker
