--- Creates a label with a scrolling text element. It is highly recommended you use a monospace font for this label.
-- @classmod Chyron
-- @author Delra
-- @copyright 2019
-- @author Damian Monogue
-- @copyright 2020
local Chyron = {
  name = "ChyronClass",
  text = "",
  displayWidth = 28,
  updateTime = 200,
  font = "Bitstream Vera Sans Mono",
  fontSize = "9",
  autoWidth = true,
  delimiter = "|",
  pos = 1,
  enabled = true,
  alignment = "center",
}

--- Creates a new Chyron label
-- @tparam table cons table of constraints which configures the EMCO.
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
--     <td class="tg-1">text</td>
--     <td class="tg-1">The text to scroll on the label</td>
--     <td class="tg-1">""</td>
--   </tr>
--   <tr>
--     <td class="tg-2">updateTime</td>
--     <td class="tg-2">Milliseconds between movements (one letter shift)</td>
--     <td class="tg-2">200</td>
--   </tr>
--   <tr>
--     <td class="tg-1">displayWidth</td>
--     <td class="tg-1">How many chars wide to display the text</td>
--     <td class="tg-1">28</td>
--   </tr>
--   <tr>
--     <td class="tg-2">delimiter</td>
--     <td class="tg-2">This character will be inserted with a space either side to mark the stop/start of the message</td>
--     <td class="tg-2">"|"</td>
--   </tr>
--   <tr>
--     <td class="tg-1">enabled</td>
--     <td class="tg-1">Should the chyron scroll?</td>
--     <td class="tg-1">true</td>
--   </tr>
--   <tr>
--     <td class="tg-2">font</td>
--     <td class="tg-2">What font to use for the Chyron? Available in Geyser.Label but we define a default.</td>
--     <td class="tg-2">"Bitstream Vera Sans Mono"</td>
--   </tr>
--   <tr>
--     <td class="tg-1">fontSize</td>
--     <td class="tg-1">What font size to use for the Chyron? Available in Geyser.Label but we define a default.</td>
--     <td class="tg-1">9</td>
--   </tr>
--   <tr>
--     <td class="tg-2">autoWidth</td>
--     <td class="tg-2">Should the Chyron resize to just fit the text?</td>
--     <td class="tg-2">true</td>
--   </tr>
--   <tr>
--     <td class="tg-1">alignment</td>
--     <td class="tg-1">What alignment(left/right/center) to use for the Chyron text? Available in Geyser.Label but we define a default.</td>
--     <td class="tg-1">"center"</td>
--   </tr>
-- </tbody>
-- </table>
-- @tparam GeyserObject container The container to use as the parent for the Chyron
function Chyron:new(cons, container)
  cons = cons or {}
  cons.type = cons.type or "Chyron"
  local me = self.parent:new(cons, container)
  setmetatable(me, self)
  self.__index = self
  me.pos = 0
  me:setDisplayWidth(me.displayWidth)
  me:setMessage(me.text)
  if me.enabled then
    me:start()
  else
    me:stop()
  end
  return me
end

--- Sets the numver of characters of the text to display at once
-- @tparam number displayWidth number of characters to show at once
function Chyron:setDisplayWidth(displayWidth)
  displayWidth = displayWidth or self.displayWidth
  self.displayWidth = displayWidth
  if self.autoWidth then
    local width = calcFontSize(self.fontSize, self.font)
    self:resize(width * (displayWidth + 2), self.height)
  end
  if not self.enabled then
    self.pos = self.pos - 1
    self:doScroll()
  end
end

--- Override setFontSize to call setDisplayWidth in order to resize if necessary
-- @local
function Chyron:setFontSize(fontSize)
  Geyser.Label.setFontSize(self, fontSize)
  self:setDisplayWidth()
end

--- Override setFont to call setDisplayWidth in order to resize if necessary
-- @local
function Chyron:setFont(font)
  Geyser.Label.setFont(self, font)
  self:setDisplayWidth()
end

--- Returns the proper section of text
-- @local
-- @param start number the character to start at
-- @param length number the length of the text you want to extract
function Chyron:scrollText(start, length)
  local t = self.textTable
  local s = ''
  local e = start + length
  for i = start - 1, e - 2 do
    local n = (i % #t) + 1
    s = s .. t[n]
  end
  return s
end

--- scroll the text
-- @local
function Chyron:doScroll()
  self.pos = self.pos + 1
  local displayString = self:scrollText(self.pos, self.displayWidth)
  self:echo('&lt;' .. displayString .. '&gt;')
  self.message = self.text
end

--- Sets the Chyron from the first position, without changing enabled status
function Chyron:reset()
  self.pos = 0
  if not self.enabled then
    self:doScroll()
  end
end

--- Stops the Chyron with its current display
function Chyron:pause()
  self.enabled = false
  if self.timer then
    killTimer(self.timer)
  end
end

--- Start the Chyron back up from wherever it currently is
function Chyron:start()
  self.enabled = true
  if self.timer then
    killTimer(self.timer)
  end
  self.timer = tempTimer(self.updateTime / 1000, function()
    self:doScroll()
  end, true)
end

--- Change the update time for the Chyron
-- @param updateTime number new updateTime in milliseconds
function Chyron:setUpdateTime(updateTime)
  self.updateTime = updateTime or self.updateTime
  if self.timer then
    killTimer(self.timer)
  end
  if self.enabled then
    self:start()
  end
end

--- Enable autoWidth adjustment
function Chyron:enableAutoWidth()
  self.autoWidth = true
  self:setDisplayWidth()
end

--- Disable autoWidth adjustment
function Chyron:disableAutoWidth()
  self.autoWidth = false
end

--- Stop the Chyron, and reset it to the original position
function Chyron:stop()
  if self.timer then
    killTimer(self.timer)
  end
  self.enabled = false
  self.pos = 0
  self:doScroll()
end

--- Change the text being scrolled on the Chyron
-- @param message string message the text you want to have scroll on the Chyron
function Chyron:setMessage(message)
  self.text = message
  self.pos = 0
  message = string.format("%s %s ", message, self.delimiter)
  local t = {}
  for i = 1, #message do
    t[i] = message:sub(i, i)
  end
  self.textTable = t
  if not self.enabled then
    self:doScroll()
  end
end

--- Change the delimiter used to show the beginning and end of the message
-- @param delimiter string the new delimiter to use. I recommend using one character.
function Chyron:setDelimiter(delimiter)
  self.delimiter = delimiter
end

Chyron.parent = Geyser.Label
setmetatable(Chyron, Geyser.Label)

return Chyron
