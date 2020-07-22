--- Embeddable Multi Console Object.
-- This is essentially YATCO, but with some tweaks, updates, and it returns an object
-- similar to Geyser so that you can a.) have multiple of them and b.) easily embed it
-- into your existing UI as you would any other Geyser element.
--@classmod EMCO
--@author Damian Monogue <demonnic@gmail.com>
--@copyright 2020 Damian Monogue
--@license MIT, see LICENSE.lua
local EMCO = Geyser.Container:new({
  name = "TabbedConsoleClass",
})

-- patch Geyser.MiniConsole if it does not have its own display method defined
if Geyser.MiniConsole.display == Geyser.display then
  function Geyser.MiniConsole:display(...)
    local arg = {...}
    arg.n = table.maxn(arg)
    if arg.n > 1 then
      for i = 1, arg.n do
        self:display(arg[i])
      end
    else
      self:echo((prettywrite(arg[1], '  ') or 'nil') .. '\n')
    end
  end
end

--- Creates a new Embeddable Multi Console Object.
-- <br>see https://github.com/demonnic/EMCO/wiki for information on valid constraints and defaults
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
--     <td class="tg-odd">timeStamp</td>
--     <td class="tg-odd">display timestamps on the miniconsoles?</td>
--     <td class="tg-odd">false</td>
--   </tr>
--   <tr>
--     <td class="tg-even">blankLine</td>
--     <td class="tg-even">put a blank line between appends/echos?</td>
--     <td class="tg-even">false</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">scrollbars</td>
--     <td class="tg-odd">enable scrollbars for the miniconsoles?</td>
--     <td class="tg-odd">false</td>
--   </tr>
--   <tr>
--     <td class="tg-even">customTimestampColor</td>
--     <td class="tg-even">if showing timestamps, use a custom color?</td>
--     <td class="tg-even">false</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">mapTab</td>
--     <td class="tg-odd">should we attach the Mudlet Mapper to this EMCO?</td>
--     <td class="tg-odd">false</td>
--   </tr>
--   <tr>
--     <td class="tg-even">mapTabName</td>
--     <td class="tg-even">Which tab should we attach the map to?
--                     <br>If mapTab is true and you do not set this, it will throw an error</td>
--     <td class="tg-even"></td>
--   </tr>
--   <tr>
--     <td class="tg-odd">blinkFromAll</td>
--     <td class="tg-odd">should tabs still blink, even if you're on the 'all' tab?</td>
--     <td class="tg-odd">false</td>
--   </tr>
--   <tr>
--     <td class="tg-even">preserveBackground</td>
--     <td class="tg-even">preserve the miniconsole background color during append()?</td>
--     <td class="tg-even">false</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">gag</td>
--     <td class="tg-odd">when running :append(), should we also gag the line?</td>
--     <td class="tg-odd">false</td>
--   </tr>
--   <tr>
--     <td class="tg-even">timestampFormat</td>
--     <td class="tg-even">Format string for the timestamp. Uses getTime()</td>
--     <td class="tg-even">"HH:mm:ss"</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">timestampBGColor</td>
--     <td class="tg-odd">Custom BG color to use for timestamps. Any valid Geyser.Color works.</td>
--     <td class="tg-odd">"blue"</td>
--   </tr>
--   <tr>
--     <td class="tg-even">timestampFGColor</td>
--     <td class="tg-even">Custom FG color to use for timestamps. Any valid Geyser.Color works</td>
--     <td class="tg-even">"red"</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">allTab</td>
--     <td class="tg-odd">Should we send everything to an 'all' tab?</td>
--     <td class="tg-odd">false</td>
--   </tr>
--   <tr>
--     <td class="tg-even">allTabName</td>
--     <td class="tg-even">And which tab should we use for the 'all' tab?</td>
--     <td class="tg-even">"All"</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">blink</td>
--     <td class="tg-odd">Should we blink tabs that have been written to since you looked at them?</td>
--     <td class="tg-odd">false</td>
--   </tr>
--   <tr>
--     <td class="tg-even">blinkTime</td>
--     <td class="tg-even">How long to wait between blinks, in seconds?</td>
--     <td class="tg-even">3</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">fontSize</td>
--     <td class="tg-odd">What font size to use for the miniconsoles?</td>
--     <td class="tg-odd">9</td>
--   </tr>
--   <tr>
--     <td class="tg-even">font</td>
--     <td class="tg-even">What font to use for the miniconsoles?</td>
--     <td class="tg-even"></td>
--   </tr>
--   <tr>
--     <td class="tg-odd">tabFont</td>
--     <td class="tg-odd">What font to use for the tabs?</td>
--     <td class="tg-odd"></td>
--   </tr>
--   <tr>
--     <td class="tg-even">activeTabCss</td>
--     <td class="tg-even">What css to use for the active tab?</td>
--     <td class="tg-even">""</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">inactiveTabCSS</td>
--     <td class="tg-odd">What css to use for the inactive tabs?</td>
--     <td class="tg-odd">""</td>
--   </tr>
--   <tr>
--     <td class="tg-even">activeTabFGColor</td>
--     <td class="tg-even">What color to use for the text on the active tab. Any Geyser.Color works.</td>
--     <td class="tg-even">"purple"</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">inactiveTabFGColor</td>
--     <td class="tg-odd">What color to use for the text on the inactive tabs. Any Geyser.Color works.</td>
--     <td class="tg-odd">"white"</td>
--   </tr>
--   <tr>
--     <td class="tg-even">activeTabBGColor</td>
--     <td class="tg-even">What BG color to use for the active tab? Any Geyser.Color works. Overriden by activeTabCSS</td>
--     <td class="tg-even">"<0,180,0>"</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">inactiveTabBGColor</td>
--     <td class="tg-odd">What BG color to use for the inactavie tabs? Any Geyser.Color works. Overridden by inactiveTabCSS</td>
--     <td class="tg-odd">"<60,60,60>"</td>
--   </tr>
--   <tr>
--     <td class="tg-even">consoleColor</td>
--     <td class="tg-even">Default background color for the miniconsoles. Any Geyser.Color works</td>
--     <td class="tg-even">"black"</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">tabBoxCSS</td>
--     <td class="tg-odd">tss for the entire tabBox (not individual tabs)</td>
--     <td class="tg-odd">""</td>
--   </tr>
--   <tr>
--     <td class="tg-even">tabBoxColor</td>
--     <td class="tg-even">What color to use for the tabBox? Any Geyser.Color works. Overridden by tabBoxCSS</td>
--     <td class="tg-even">"black"</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">consoleContainerCSS</td>
--     <td class="tg-odd">CSS to use for the container holding the miniconsoles</td>
--     <td class="tg-odd">""</td>
--   </tr>
--   <tr>
--     <td class="tg-even">consoleContainerColor</td>
--     <td class="tg-even">Color to use for the container holding the miniconsole. Any Geyser.Color works. Overridden by consoleContainerCSS</td>
--     <td class="tg-even">"black"</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">gap</td>
--     <td class="tg-odd">How many pixels to place between the tabs and the miniconsoles?</td>
--     <td class="tg-odd">1</td>
--   </tr>
--   <tr>
--     <td class="tg-even">consoles</td>
--     <td class="tg-even">List of the tabs for this EMCO in table format</td>
--     <td class="tg-even">{ "All" }</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">allTabExclusions</td>
--     <td class="tg-odd">List of the tabs which should never echo to the 'all' tab in table format</td>
--     <td class="tg-odd">{}</td>
--   </tr>
--   <tr>
--     <td class="tg-even">tabHeight</td>
--     <td class="tg-even">How many pixels high should the tabs be?</td>
--     <td class="tg-even">25</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">autoWrap</td>
--     <td class="tg-odd">Use autoWrap for the miniconsoles?</td>
--     <td class="tg-odd">true</td>
--   </tr>
--   <tr>
--     <td class="tg-even">wrapAt</td>
--     <td class="tg-even">How many characters to wrap it, if autoWrap is turned off?</td>
--     <td class="tg-even">300</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">leftMargin</td>
--     <td class="tg-odd">Number of pixels to put between the left edge of the EMCO and the miniconsole?</td>
--     <td class="tg-odd">0</td>
--   </tr>
--   <tr>
--     <td class="tg-even">rightMargin</td>
--     <td class="tg-even">Number of pixels to put between the right edge of the EMCO and the miniconsole?</td>
--     <td class="tg-even">0</td>
--   </tr>
--   <tr>
--     <td class="tg-odd">bottomMargin</td>
--     <td class="tg-odd">Number of pixels to put between the bottom edge of the EMCO and the miniconsole?</td>
--     <td class="tg-odd">0</td>
--   </tr>
--   <tr>
--     <td class="tg-even">topMargin</td>
--     <td class="tg-even">Number of pixels to put between the top edge of the miniconsole container, and the miniconsole? This is in addition to gap</td>
--     <td class="tg-even">0</td>
--   </tr>
-- </tbody>
-- </table>
-- @tparam GeyserObject container The container to use as the parent for the EMCO
-- @return the newly created EMCO
function EMCO:new(cons, container)
  local funcName = "EMCO:new(cons, container)"
  cons = cons or {}
  cons.type = cons.type or "tabbedConsole"
  cons.consoles = cons.consoles or { "All" }
  if cons.mapTab then
    if not type(cons.mapTabName) == "string" then
      self:ce(funcName, [["mapTab" is true, thus constraint "mapTabName" and string expected, got ]] .. type(cons.mapTabName))
    elseif not table.contains(cons.consoles, cons.mapTabName) then
      self:ce(funcName, [["mapTabName" must be one of the consoles contained within constraint "consoles". Valid option for tha mapTab are: ]] .. table.concat(cons.consoles, ","))
    end
  end
  cons.allTabExclusions = cons.allTabExclusions or {}
  if not type(cons.allTabExclusions) == "table" then self:se(funcName, "allTabExclusions must be a table if it is provided") end
  local me = self.parent:new(cons, container)
  setmetatable(me, self)
  self.__index = self
  -- set some defaults. Almost all the defaults we had for YATCO, plus a few new ones
  if me:fuzzyBoolean(cons.timestamp) then
    me:enableTimestamp()
  else
    me:disableTimestamp()
  end
  if me:fuzzyBoolean(cons.customTimestampColor) then
    me:enableCustomTimestampColor()
  else
    me:disableCustomTimestampColor()
  end
  if me:fuzzyBoolean(cons.mapTab) then
    me.mapTab = true
  else
    me.mapTab = false
  end
  if me:fuzzyBoolean(cons.blinkFromAll) then
    me:enableBlinkFromAll()
  else
    me:disableBlinkFromAll()
  end
  if me:fuzzyBoolean(cons.preserveBackground) then
    me:enablePreserveBackground()
  else
    me:disablePreserveBackground()
  end
  if me:fuzzyBoolean(cons.gag)then
    me:enableGag()
  else
    me:disableGag()
  end
  me:setTimestampFormat(cons.timestampFormat or "HH:mm:ss")
  me:setTimestampBGColor(cons.timestampBGColor or "blue")
  me:setTimestampFGColor(cons.timestampFGColor or "red")
  if me:fuzzyBoolean(cons.allTab) then
    me:enableAllTab(cons.allTab)
  else
    me:disableAllTab()
  end
  if me:fuzzyBoolean(cons.blink) then
    me:enableBlink()
  else
    me:disableBlink()
  end
  if me:fuzzyBoolean(cons.blankLine) then
    me:enableBlankLine()
  else
    me:disableBlankLine()
  end
  if me:fuzzyBoolean(cons.scrollbars) then
    me.scrollbars = true
  else
    me.scrollbars = false
  end
  me.blinkTime = cons.blinkTime or 3
  me.fontSize = cons.fontSize or 9
  me.activeTabCSS = cons.activeTabCSS or ""
  me.inactiveTabCSS = cons.inactiveTabCSS or ""
  me.activeTabFGColor = cons.activeTabFGColor or "purple"
  me.inactiveTabFGColor = cons.inactiveTabFGColor or "white"
  me.activeTabBGColor = cons.activeTabBGColor or "<0,180,0>"
  me.inactiveTabBGColor = cons.inactiveTabBGColor or "<60,60,60>"
  me.consoleColor = cons.consoleColor or "black"
  me.tabBoxCSS = cons.tabBoxCSS or ""
  me.tabBoxColor = cons.tabBoxColor or "black"
  me.consoleContainerCSS = cons.consoleContainerCSS or ""
  me.consoleContainerColor = cons.consoleContainerColor or "black"
  me.gap = cons.gap or 1
  me.consoles = cons.consoles
  me.tabHeight = cons.tabHeight or 25
  me.leftMargin = cons.leftMargin or 0
  me.rightMargin = cons.rightMargin or 0
  me.topMargin = cons.topMargin or 0
  me.bottomMargin = cons.bottomMargin or 0
  if cons.autoWrap == nil then
    me.autoWrap = true
  else
    me.autoWrap = cons.autoWrap
  end
  me.font = cons.font
  me.tabFont = cons.tabFont
  me.wrapAt = cons.wrapAt or 300
  me.currentTab = ""
  me.tabs = {}
  me.tabsToBlink = {}
  me.mc = {}
  self.blinkTimerID = tempTimer(me.blinkTime, function() me:doBlink() end, true)
  me:reset()
  if me.allTab then me:setAllTabName(me.allTabName or me.consoles[1]) end
  table.insert(EMCOHelper.items, me)
  return me
end

function EMCO:readYATCO()
  local config
  if demonnic and demonnic.chat and demonnic.chat.config then
    config = demonnic.chat.config
  else
    cecho("<white>(<blue>EMCO<white>)<reset> Could not find demonnic.chat.config, nothing to convert\n")
    return
  end
  local constraints = "EMCO:new({\n"
  constraints = string.format("%s  x = %d,\n", constraints, demonnic.chat.container.get_x())
  constraints = string.format("%s  y = %d,\n", constraints, demonnic.chat.container.get_y())
  constraints = string.format("%s  width = %d,\n", constraints, demonnic.chat.container.get_width())
  constraints = string.format("%s  height = %d,\n", constraints, demonnic.chat.container.get_height())
  if config.timestamp then
    constraints = string.format("%s  timestamp = true,\n  timestampFormat = \"%s\",\n", constraints, config.timestamp)
  else
    constraints = string.format("%s  timestamp = false,\n", constraints)
  end
  if config.timestampColor then
    constraints = string.format("%s  customTimestampColor = true,\n", constraints)
  else
    constraints = string.format("%s  customTimestampColor = false,\n", constraints)
  end
  if config.timestampFG then
    constraints = string.format("%s  timestampFGColor = \"%s\",\n", constraints, config.timestampFG)
  end
  if config.timestampBG then
    constraints = string.format("%s  timestampBGColor = \"%s\",\n", constraints, config.timestampBG)
  end
  if config.channels then
    local channels = "consoles = {\n"
    for _,channel in ipairs(config.channels) do
      if _ == #config.channels then
        channels = string.format("%s    \"%s\"", channels, channel)
      else
        channels = string.format("%s    \"%s\",\n", channels, channel)
      end
    end
    channels = string.format("%s\n  },\n", channels)
    constraints = string.format([[%s  %s]], constraints, channels)
  end
  if config.Alltab then
    constraints = string.format("%s  allTab = true,\n", constraints)
    constraints = string.format("%s  allTabName = \"%s\",\n", constraints, config.Alltab)
  else
    constraints = string.format("%s  allTab = false,\n", constraints)
  end
  if config.Maptab and config.Maptab ~= "" then
    constraints = string.format("%s  mapTab = true,\n", constraints)
    constraints = string.format("%s  mapTabName = \"%s\",\n", constraints, config.Maptab)
  else
    constraints = string.format("%s  mapTab = false,\n", constraints)
  end
  constraints = string.format("%s  blink = %s,\n", constraints, tostring(config.blink))
  constraints = string.format("%s  blinkFromAll = %s,\n", constraints, tostring(config.blinkFromAll))
  if config.fontSize then
    constraints = string.format("%s  fontSize = %d,\n", constraints, config.fontSize)
  end
  constraints = string.format("%s  preserveBackground = %s,\n", constraints, tostring(config.preserveBackground))
  constraints = string.format("%s  gag = %s,\n", constraints, tostring(config.gag))
  constraints = string.format("%s  activeTabBGColor = \"<%s,%s,%s>\",\n", constraints, config.activeColors.r, config.activeColors.g, config.activeColors.b)
  constraints = string.format("%s  inactiveTabBGColor = \"<%s,%s,%s>\",\n", constraints, config.inactiveColors.r, config.inactiveColors.g, config.inactiveColors.b)
  constraints = string.format("%s  consoleColor = \"<%s,%s,%s>\",\n", constraints, config.windowColors.r, config.windowColors.g, config.windowColors.b)
  constraints = string.format("%s  activeTabFGColor = \"%s\",\n", constraints, config.activeTabText)
  constraints = string.format("%s  inactiveTabFGColor = \"%s\"", constraints, config.inactiveTabText)
  constraints = string.format("%s\n})", constraints)
  return constraints
end

--- Scans for the old YATCO configuration values and prints out a set of constraints to use.
-- with EMCO to achieve the same effect. Is just the invocation
function EMCO:miniConvertYATCO()
  local constraints = self:readYATCO()
  cecho("<white>(<blue>EMCO<white>)<reset> Found a YATCO config. Here are the constraints to use with EMCO(x,y,width, and height have been converted to their absolute values):\n\n")
  echo(constraints .. "\n")
end

--- Echos to the main console a script object you can add which will fully convert YATCO to EMCO.
-- This replaces the demonnic.chat variable with a newly created EMCO object, so that the main
-- functions used to place information on the consoles (append(), cecho(), etc) should continue to
-- work in the user's triggers and events.
function EMCO:convertYATCO()
  local invocation = self:readYATCO()
  local header = [[
  <white>(<blue>EMCO<white>)<reset> Found a YATCO config. Make a new script, then copy and paste the following output into it.
  <white>(<blue>EMCO<white>)<reset> Afterward, uninstall YATCO (you can leave YATCOConfig until you're sure everything is right) and restart Mudlet
  <white>(<blue>EMCO<white>)<reset> If everything looks right, you can uninstall YATCOConfig. 


-- Copy everything below this line until the next line starting with --
demonnic = demonnic or {}
demonnic.chat = ]]
  cecho(string.format("%s%s\n--- End script\n", header, invocation))
end

function EMCO:checkTabPosition(position)
  if position == nil then
    return 0
  end
  return tonumber(position) or type(position)
end

function EMCO:checkTabName(tabName)
  if not tostring(tabName) then
    return "tabName as string expected, got" .. type(tabName)
  end
  tabName = tostring(tabName)
  if table.contains(self.consoles, tabName) then
    return "tabName must be unique, and we already have a tab named " .. tabName
  else
    return "clear"
  end
end

function EMCO.ae(funcName, message)
  error(string.format("%s: Argument Error: %s", funcName, message))
end

function EMCO:ce(funcName, message)
  error(string.format("%s:gg Constraint Error: %s", funcName, message))
end

--- Display the contents of one or more variables to an EMCO tab. like display() but targets the miniconsole
--@tparam string tabName the name of the tab you want to display to
--@param item The thing to display()
--@param[opt] item2 another thing to display()
--@param[optchain] item_n and so on and so on
function EMCO:display(tabName, ...)
  local funcName = "EMCO:display(tabName, item)"
  if not table.contains(self.consoles, tabName) then
    self.ae(funcName, "tabName must be a tab which exists in this EMCO. valid options are: " .. table.concat(self.consoles, ","))
  end
  self.mc[tabName]:display(...)
end

--- Remove a tab from the EMCO
--@tparam string tabName the name of the tab you want to remove from the EMCO
function EMCO:removeTab(tabName)
  local funcName = "EMCO:removeTab(tabName)"
  if not table.contains(self.consoles, tabName) then
    self.ae(funcName, "tabName must be a tab which exists in this EMCO. valid options are: " .. table.concat(self.consoles, ","))
  end
  table.remove(self.consoles, table.index_of(self.consoles, tabName))
  local window = self.mc[tabName]
  local tab = self.tabs[tabName]
  window:hide()
  tab:hide()
  self.tabBox:remove(tab)
  self.tabBox:organize()
  self.consoleContainer:remove(window)
  self.mc[tabName] = nil
end

--- Adds a tab to the EMCO object
-- @tparam string tabName the name of the tab to add
-- @tparam[opt] number position position in the tab switcher to put this tab
function EMCO:addTab(tabName, position)
  local funcName = "EMCO:addTab(tabName, position)"
  position = self:checkTabPosition(position)
  if type(position) == "string" then self.ae(funcName, "position as number expected, got " .. position) end
  local tabCheck = self:checkTabName(tabName)
  if tabCheck ~= "clear" then self.ae(funcName, tabCheck) end
  if position == 0 then
    table.insert(self.consoles, tabName)
    self:createComponentsForTab(tabName)
  else
    table.insert(self.consoles, position, tabName)
    self:reset()
  end
end

function EMCO:switchTab(tabName)
  local oldTab = self.currentTab
  if oldTab ~= tabName and oldTab ~= "" then
    self.mc[oldTab]:hide()
    self.tabs[oldTab]:setStyleSheet(self.inactiveTabCSS)
    self.tabs[oldTab]:setColor(self.inactiveTabBGColor)
    self.tabs[oldTab]:echo(oldTab, self.inactiveTabFGColor, "c")
    if self.blink then
      if self.allTab and tabName == self.allTabName then
        self.tabsToBlink = {}
      elseif self.tabsToBlink[tabName] then
        self.tabsToBlink[tabName] = nil
      end
    end
  end
  self.tabs[tabName]:setStyleSheet(self.activeTabCSS)
  self.tabs[tabName]:setColor(self.activeTabBGColor)
  self.tabs[tabName]:echo(tabName, self.activeTabFGColor, "c")
  if oldTab and self.mc[oldTab] then
    self.mc[oldTab]:hide()
  end
  self.mc[tabName]:show()
  self.currentTab = tabName
end

function EMCO:createComponentsForTab(tabName)
  local tab = Geyser.Label:new({
    name = string.format("%sTab%s", self.name, tabName)
  }, self.tabBox)
  if self.tabFont then
    tab:setFont(self.tabFont)
  end
  tab:echo(tabName, self.inactiveTabFGColor, 'c')
  -- use the inactive CSS. It's "" if unset, which is ugly, but
  tab:setStyleSheet(self.inactiveTabCSS)
  -- set the BGColor if set. if the CSS is set it overrides the setColor, but if it's "" then the setColor actually covers that.
  -- and we set a default for the inactiveBGColor
  tab:setColor(self.inactiveTabBGColor)
  tab:setClickCallback("EMCOHelper.switchTab", nil, string.format("%s+%s",self.name, tabName))
  self.tabs[tabName] = tab
  local window
  local windowConstraints = {
    x = self.leftMargin,
    y = self.topMargin,
    height = string.format("-%dpx", self.bottomMargin),
    width = string.format("-%dpx", self.rightMargin),
    name = string.format("%sWindow%s", self.name, tabName)
  }
  local parent = self.consoleContainer
  if self.mapTab and tabName == self.mapTabName then
    window = Geyser.Mapper:new(windowConstraints, parent)
  else
    window = Geyser.MiniConsole:new(windowConstraints, parent)
    if self.font then
      window:setFont(self.font)
    end
    window:setFontSize(self.fontSize)
    window:setColor(self.consoleColor)
    if self.autoWrap then
      window:enableAutoWrap()
    else
      window:setWrap(self.wrapAt)
    end
    if self.scrollbars then
      window:enableScrollBar()
    else
      window:disableScrollBar()
    end
  end
  self.mc[tabName] = window
  window:hide()
end

--- resets the object, redrawing everything
function EMCO:reset()
  self:createContainers()
  for _,tabName in ipairs(self.consoles) do
    self:createComponentsForTab(tabName)
  end
  local default
  if self.currentTab == "" then
    default = self.allTabName or self.consoles[1]
  else
    default = self.currentTab
  end
  self:switchTab(default)
end

function EMCO:createContainers()
  self.tabBoxLabel = Geyser.Label:new({
    x=0,
    y=0,
    width = "100%",
    height = tostring(tonumber(self.tabHeight) + 2) .. "px",
    name = self.name .. "TabBoxLabel"
  }, self)
  self.tabBox = Geyser.HBox:new({
    x=0,
    y=0,
    width = "100%",
    height = "100%",
    name = self.name .. "TabBox"
  }, self.tabBoxLabel)
  self.tabBoxLabel:setStyleSheet(self.tabBoxCSS)
  self.tabBoxLabel:setColor(self.tabBoxColor)

  local heightPlusGap = tonumber(self.tabHeight) + tonumber(self.gap)
  self.consoleContainer = Geyser.Label:new({
    x = 0,
    y = tostring(heightPlusGap) .. "px",
    width = "100%",
    height = "-0px",
    name = self.name .. "ConsoleContainer"
  }, self)
  self.consoleContainer:setStyleSheet(self.consoleContainerCSS)
  self.consoleContainer:setColor(self.consoleContainerColor)
end

function EMCO:stripTimeChars(str)
  return string.gsub(string.trim(str), '[hHmMszZaApPdy:. ]', '')
end

--- Expands boolean definitions to be more flexible.
-- <br>True values are "true", "yes", "0", 0, and true
-- <br>False values are "false", "no", "1", 1, false, and nil
-- @param bool item to test for truthiness
function EMCO:fuzzyBoolean(bool)
  if type(bool) == "boolean" or bool == nil then
    return bool
  elseif tostring(bool) then
    local truth = {
      "yes",
      "true",
      "0"
    }
    local untruth = {
      "no",
      "false",
      "1"
    }
    local boolstr = tostring(bool)
    if table.contains(truth, boolstr) then
      return true
    elseif table.contains(untruth, boolstr) then
      return false
    else
      return nil
    end
  else
    return nil
  end
end

--- clears a specific tab
--- @tparam string tabName the name of the tab to clear
function EMCO:clear(tabName)
  local funcName = "EMCO:clear(tabName)"
  if not table.contains(self.consoles, tabName) then
    self.ae(funcName, "tabName must be an existing tab")
  end
  if self.mapTab and self.mapTabName == tabName then
    self.ae(funcName, "Cannot clear the map tab")
  end
  self.mc[tabName]:clear()
end

--- clears all the tabs
function EMCO:clearAll()
  for _,tabName in ipairs(self.consoles) do
    if not self.mapTab or (tabName ~= self.mapTabName) then
      self:clear(tabName)
    end
  end
end

--- sets the font for all tabs
--- @tparam string font the font to use.
function EMCO:setTabFont(font)
  self.tabFont = font
  for _,tab in pairs(self.tabs) do
    tab:setFont(font)
  end
end

--- sets the font for a single tab. If you use setTabFont this will be overridden
--- @tparam string tabName the tab to change the font of
--- @tparam string font the font to use for that tab
function EMCO:setSingleTabFont(tabName, font)
  local funcName = "EMCO:setSingleTabFont(tabName, font)"
  if not table.contains(self.consoles, tabName) then
    self.ae(funcName, "tabName must be an existing tab")
  end
  self.tabs[tabName]:setFont(font)
end

--- sets the font for all the miniconsoles
--- @tparam string font the name of the font to use
function EMCO:setFont(font)
  local af = getAvailableFonts()
  if not (af[font] or font == "") then
    local err = "EMCO:setFont(font): attempt to call setFont with font '" .. font .. "' which is not available, see getAvailableFonts() for valid options\n"
    err = err .. "In the meantime, we will use a similar font which isn't the one you asked for but we hope is close enough"
    debugc(err)
  end
  self.font = font
  for _,tabName in pairs(self.consoles) do
    if not self.mapTab or tabName ~= self.mapTabName then
      self.mc[tabName]:setFont(font)
    end
  end
end

--- sets the font for a specific miniconsole. If setFont is called this will be overridden
--- @tparam string tabName the name of window to set the font for
--- @tparam string font the name of the font to use
function EMCO:setSingleWindowFont(tabName, font)
  local funcName = "EMCO:setSingleWindowFont(tabName, font)"
  if not table.contains(self.consoles, tabName) then
    self.ae(funcName, "tabName must be an existing tab")
  end
  local af = getAvailableFonts()
  if not (af[font] or font == "") then
    local err = "EMCO:setSingleWindowFont(tabName, font): attempt to call setFont with font '" .. font .. "' which is not available, see getAvailableFonts() for valid options\n"
    err = err .. "In the meantime, we will use a similar font which isn't the one you asked for but we hope is close enough"
    debugc(err)
  end
  self.mc[tabName]:setFont(font)
end

--- enables custom colors for the timestamp, if displayed
function EMCO:enableCustomTimestampColor()
  self.customTimestampColor = true
end

--- disables custom colors for the timestamp, if displayed
function EMCO:disableCustomTimestampColor()
  self.customTimestampColor = false
end

--- enables the display of timestamps
function EMCO:enableTimestamp()
  self.timestamp = true
end

--- disables the display of timestamps
function EMCO:disableTimestamp()
  self.timestamp = false
end

--- Sets the formatting for the timestamp, if enabled
-- @tparam string format Format string which describes the display of the timestamp. See: https://wiki.mudlet.org/w/Manual:Lua_Functions#getTime
function EMCO:setTimestampFormat(format)
  local funcName = "EMCO:setTimestampFormat(format)"
  local strippedFormat = self:stripTimeChars(format)
  if strippedFormat ~= "" then
    self.ae(funcName, "format contains invalid time format characters. Please see https://wiki.mudlet.org/w/Manual:Lua_Functions#getTime for formatting information")
  else
    self.timestampFormat = format
  end
end

--- Sets the background color for the timestamp, if customTimestampColor is enabled.
-- @param color Color string suitable for decho or hecho, or color name eg "purple", or table of colors {r,g,b}
function EMCO:setTimestampBGColor(color)
  self.timestampBGColor = color
end
--- Sets the foreground color for the timestamp, if customTimestampColor is enabled.
-- @param color Color string suitable for decho or hecho, or color name eg "purple", or table of colors {r,g,b}
function EMCO:setTimestampFGColor(color)
  self.timestampFGColor = color
end

--- Sets the 'all' tab name.
-- <br>This is the name of the tab itself
-- @tparam string allTabName name of the tab to use as the all tab. Must be a tab which exists in the object.
function EMCO:setAllTabName(allTabName)
  local funcName = "EMCO:setAllTabName(allTabName)"
  local allTabNameType = type(allTabName)
  if allTabNameType ~= "string" then self.ae(funcName, "allTabName expected as string, got" .. allTabNameType) end
  if not table.contains(self.consoles, allTabName) then self.ae(funcName, "allTabName must be the name of one of the console tabs. Valid options are: " .. table.concat(self.containers, ",")) end
  self.allTabName = allTabName
end

--- Enables use of the 'all' tab
function EMCO:enableAllTab()
  self.allTab = true
end

--- Disables use of the 'all' tab
function EMCO:disableAllTab()
  self.allTab = false
end

--- Enables tying the Mudlet Mapper to one of the tabs.
-- <br>mapTabName must be set, or this will error. Forces a redraw of the entire object
function EMCO:enableMapTab()
  local funcName = "EMCO:enableMapTab()"
  if not self.mapTabName then
    error(funcName .. ": cannot enable the map tab, mapTabName not set. try running :setMapTabName(mapTabName) first with the name of the tab you want to bind the map to")
  end
  self.mapTab = true
  self:reset()
end

--- disables binding the Mudlet Mapper to one of the tabs.
-- <br>CAUTION: this may have unexpected behaviour, as you can only open one Mapper console per profile
-- so you can't really unbind it. Binding of the Mudlet Mapper is best decided at instantiation.
function EMCO:disableMapTab()
  self.mapTab = false
end

--- sets the name of the tab to bind the Mudlet Map.
-- <br>Forces a redraw of the object
-- <br>CAUTION: Mudlet only allows one Map object to be open at one time, so if you are going to attach the map to an object
-- you should probably do it at instantiation.
-- @tparam string mapTabName name of the tab to connect the Mudlet Map to.
function EMCO:setMapTabName(mapTabName)
  local funcName = "EMCO:setMapTabName(mapTabName)"
  local mapTabNameType = type(mapTabName)
  if mapTabNameType ~= "string" then
    self.ae(funcName, "mapTabName as string expected, got" .. mapTabNameType)
  end
  if not table.contains(self.consoles, mapTabName) and mapTabName ~= "" then
    self.ae(funcName, "mapTabName must be one of the existing console tabs. Current tabs are: " .. table.concat(self.consoles, ","))
  end
  self.mapTabName = mapTabName
end

--- Enables tab blinking even if you're on the 'all' tab
function EMCO:enableBlinkFromAll()
  self.enableBlinkFromAll = true
end

--- Disables tab blinking when you're on the 'all' tab
function EMCO:disableBlinkFromAll()
  self.enableBlinkFromAll = false
end

--- Enables gagging of the line passed in to :append(tabName)
function EMCO:enableGag()
  self.gag = true
end

--- Disables gagging of the line passed in to :append(tabName)
function EMCO:disableGag()
  self.gag = false
end

--- Enables tab blinking when new information comes in to an inactive tab
function EMCO:enableBlink()
  self.blink = true
end

--- Disables tab blinking when new information comes in to an inactive tab
function EMCO:disableBlink()
  self.blink = false
end

--- Enables preserving the chat's background over the background of an incoming :append()
function EMCO:enablePreserveBackground()
  self.preserveBackground = true
end

--- Enables preserving the chat's background over the background of an incoming :append()
function EMCO:disablePreserveBackground()
  self.preserveBackground = false
end

--- Sets how long in seconds to wait between blinks
-- @tparam number blinkTime time in seconds to wait between blinks
function EMCO:setBlinkTime(blinkTime)
  local funcName = "EMCO:setBlinkTime(blinkTime)"
  local blinkTimeNumber = tonumber(blinkTime)
  if not blinkTimeNumber then
    self.ae(funcName, "blinkTime as number expected, got ".. type(blinkTime))
  else
    self.blinkTime = blinkTimeNumber
    if self.blinkTimerID then
      killTimer(self.blinkTimerID)
    end
    self.blinkTimerID = tempTimer(blinkTimeNumber, function() self:blink() end, true)
  end
end

function EMCO:doBlink()
  if self.hidden or self.auto_hidden or not self.blink then
    return
  end
  for tab,_ in pairs(self.tabsToBlink) do
    self.tabs[tab]:flash()
  end
end

--- Sets the font size of the attached consoles
-- @tparam number fontSize font size for attached consoles
function EMCO:setFontSize(fontSize)
  local funcName = "EMCO:setFontSize(fontSize)"
  local fontSizeNumber = tonumber(fontSize)
  local fontSizeType = type(fontSize)
  if not fontSizeNumber then
    self.ae(funcName, "fontSize as number expected, got " .. fontSizeType)
  else
    self.fontSize = fontSizeNumber
    for _,tabName in ipairs(self.consoles) do
      if self.mapTab and tabName == self.mapTabName then
        -- skip this one
      else
        local window = self.mc[tabName]
        window:setFontSize(fontSizeNumber)
      end
    end
  end
end

function EMCO:adjustTabNames()
  for _,console in ipairs(self.consoles) do
    if console == self.currentTab then
      self.tabs[console]:echo(console, self.activTabFGColor, 'c')
    else
      self.tabs[console]:echo(console, self.inactiveTabFGColor, 'c')
    end
  end
end

function EMCO:adjustTabBackgrounds()
  for _, console in ipairs(self.consoles) do
    local tab = self.tabs[console]
    if console == self.currentTab then
      tab:setStyleSheet(self.activeTabCSS)
      tab:setColor(self.activeBGColor)
    else
      tab:setStyleSheet(self.inactiveTabCSS)
      tab:setColor(self.inactiveBGColor)
    end
  end
end

--- Sets the FG color for the active tab
-- @param color Color string suitable for decho or hecho, or color name eg "purple", or table of colors {r,g,b}
function EMCO:setActiveTabFGColor(color)
  self.activeTabFGColor = color
  self:adjustTabNames()
end

--- Sets the FG color for the inactive tab
-- @param color Color string suitable for decho or hecho, or color name eg "purple", or table of colors {r,g,b}
function EMCO:setInactiveTabFGColor(color)
  self.inactiveTabFGColor = color
  self:adjustTabNames()
end

--- Sets the BG color for the active tab.
-- <br>NOTE: If you set CSS for the active tab, it will override this setting.
-- @param color Color string suitable for decho or hecho, or color name eg "purple", or table of colors {r,g,b}
function EMCO:setActiveTabBGColor(color)
  self.activeTabBGColor = color
  self:adjustTabBackgrounds()
end

--- Sets the BG color for the inactive tab.
-- <br>NOTE: If you set CSS for the inactive tab, it will override this setting.
-- @param color Color string suitable for decho or hecho, or color name eg "purple", or table of colors {r,g,b}
function EMCO:setInactiveTabBGColor(color)
  self.inactiveTabBGColor = color
  self:adjustTabBackgrounds()
end

--- Sets the BG color for the consoles attached to this object
-- @param color Color string suitable for decho or hecho, or color name eg "purple", or table of colors {r,g,b}
function EMCO:setConsoleColor(color)
  self.consoleColor = color
  self:adjustConsoleColors()
end

function EMCO:adjustConsoleColors()
  for _,console in ipairs(self.consoles) do
    if self.mapTab and self.mapTabName == console then
      -- skip Map
    else
      self.mc[console]:setColor(self.consoleColor)
    end
  end
end

--- Sets the CSS to use for the tab box which contains the tabs for the object
-- @tparam string css The css styling to use for the tab box
function EMCO:setTabBoxCSS(css)
  local funcName = "EMCHO:setTabBoxCSS(css)"
  local cssType = type(css)
  if cssType ~= "string" then
    self.ae(funcName, "css as string expected, got " .. cssType)
  else
    self.tabBoxCSS = css
    self:adjustTabBoxBackground()
  end
end

--- Sets the color to use for the tab box background
-- @param color Color string suitable for decho or hecho, or color name eg "purple", or table of colors {r,g,b}
function EMCO:setTabBoxColor(color)
  self.tabBoxColor = color
  self:adjustTabBoxBackground()
end

function EMCO:adjustTabBoxBackground()
    self.tabBoxLabel:setStyleSheet(self.tabBoxCSS)
    self.tabBoxLabel:setColor(self.tabBoxColor)
end

--- Sets the color for the container which holds the consoles attached to this object.
-- @param color Color string suitable for decho or hecho, or color name eg "purple", or table of colors {r,g,b}
function EMCO:setConsoleContainerColor(color)
  self.consoleContainerColor = color
  self:adjustConsoleContainerBackground()
end

--- Sets the CSS to use for the container which holds the consoles attached to this object
-- @tparam string css CSS to use for the container
function EMCO:setConsoleContainerCSS(css)
  self.consoleContainerCSS = css
  self:adjustConsoleContainerBackground()
end

function EMCO:adjustConsoleContainerBackground()
  self.consoleContainer:setStyleSheet(self.consoleContainerCSS)
  self.consoleContainer:setColor(self.consoleContainerColor)
end

--- Sets the amount of space to use between the tabs and the consoles
-- @tparam number gap Number of pixels to keep between the tabs and consoles
function EMCO:setGap(gap)
  local gapNumber = tonumber(gap)
  local funcName = "EMCO:setGap(gap)"
  local gapType = type(gap)
  if not gapNumber then
    self.ae(funcName, "gap expected as number, got " .. gapType)
  else
    self.gap = gapNumber
    self:reset()
  end
end

--- Sets the height of the tabs in pixels
-- @tparam number tabHeight the height of the tabs for the object, in pixels
function EMCO:setTabHeight(tabHeight)
  local tabHeightNumber = tonumber(tabHeight)
  local funcName = "EMCO:setTabHeight(tabHeight)"
  local tabHeightType = type(tabHeight)
  if not tabHeightNumber then
    self.ae(funcName, "tabHeight as number expected, got ".. tabHeightType)
  else
    self.tabHeight = tabHeightNumber
    self:reset()
  end
end

--- Enables autowrap for the object, and by extension all attached consoles.
-- <br>To enable autoWrap for a specific miniconsole only, call myEMCO.windows[tabName]:enableAutoWrap()
-- but be warned if you do this it may be overwritten by future calls to EMCO:enableAutoWrap() or :disableAutoWrap()
function EMCO:enableAutoWrap()
  self.autoWrap = true
  for _,console in ipairs(self.consoles) do
    if self.mapTab and console == self.mapTabName then
      -- skip the map
    else
      self.mc[console]:enableAutoWrap()
    end
  end
end

--- Disables autowrap for the object, and by extension all attached consoles.
-- <br>To disable autoWrap for a specific miniconsole only, call myEMCO.windows[tabName]:disableAutoWrap()
-- but be warned if you do this it may be overwritten by future calls to EMCO:enableAutoWrap() or :disableAutoWrap()
function EMCO:disableAutoWrap()
  self.autoWrap = false
  for _,console in ipairs(self.consoles) do
    if self.mapTab and self.mapTabName == console then
      -- skip Map
    else
      self.mc[console]:disableAutoWrap()
    end
  end
end

--- Sets the number of characters to wordwrap the attached consoles at.
-- <br>it is generally recommended to make use of autoWrap unless you need
-- a specific width for some reason
function EMCO:setWrap(wrapAt)
  local funcName = "EMCO:setWrap(wrapAt)"
  local wrapAtNumber = tonumber(wrapAt)
  local wrapAtType = type(wrapAt)
  if not wrapAtNumber then
    self.ae(funcName, "wrapAt as number expect, got " .. wrapAtType)
  else
    self.wrapAt = wrapAtNumber
    for _,console in ipairs(self.consoles) do
      if self.mapTab and self.mapTabName == console then
        -- skip the Map
      else
        self.mc[console]:setWrap(wrapAtNumber)
      end
    end
  end
end

--- Appends the current line from the MUD to a tab.
-- <br>depending on this object's configuration, may gag the line
-- <br>depending on this object's configuration, may gag the next prompt
-- @tparam string tabName The name of the tab to append the line to
-- @tparam boolean excludeAll if true, will exclude this from being mirrored to the allTab
function EMCO:append(tabName, excludeAll)
  local funcName = "EMCO:append(tabName, excludeAll)"
  local tabNameType = type(tabName)
  local validTab = table.contains(self.consoles, tabName)
  if tabNameType ~= "string" then
    self.ae(funcName, "tabName as string expected, got ".. tabNameType)
  elseif not validTab then
    self.ae(funcName, "tabName must be a tab which is contained in this object. Valid tabnames are: " .. table.concat(self.consoles, ","))
  end
  self:xEcho(tabName, nil, 'a', excludeAll)
end

function EMCO:checkEchoArgs(funcName, tabName, message, excludeAll)
  local tabNameType = type(tabName)
  local messageType = type(message)
  local validTabName = table.contains(self.consoles, tabName)
  local excludeAllType = type(excludeAll)
  local ae = self.ae
  if tabNameType ~= "string" then
    ae(funcName, "tabName as string expected, got " .. tabNameType)
  elseif messageType ~= "string" then
    ae(funcName, "message as string expected, got " .. messageType)
  elseif not validTabName then
    ae(funcName, "tabName must be the name of a tab attached to this object. Valid names are: " .. table.concat(self.consoles, ","))
  elseif excludeAllType ~= "nil" and excludeAllType ~= "boolean" then
    ae(funcName, "optional argument excludeAll expected as boolean, got " .. excludeAllType)
  end
end

function EMCO:xEcho(tabName, message, xtype, excludeAll)
  if self.mapTab and self.mapTabName == tabName then
    error("You cannot send text to the Map tab")
  end
  local console = self.mc[tabName]
  local allTab = (self.allTab and not excludeAll and not table.contains(self.allTabExclusions, tabName) and tabName ~= self.allTabName) and self.mc[self.allTabName] or false
  local ofr,ofg,ofb,obr,obg,obb
  if xtype == "a" then
    selectCurrentLine()
    ofr,ofg,ofb = getFgColor()
    obr,obg,obb = getBgColor()
    if self.preserveBackground then
      local r,g,b = Geyser.Color.parse(self.consoleColor)
      setBgColor(r,g,b)
    end
    copy()
    if self.preserveBackground then
      setBgColor(obr, obg, obb)
    end
    deselect()
    resetFormat()
  else
    ofr,ofg,ofb = Geyser.Color.parse("white")
    obr,obg,obb = Geyser.Color.parse(self.consoleColor)
  end
  if self.timestamp then
    local colorString = ""
    if self.customTimestampColor then
      local tfr,tfg,tfb = Geyser.Color.parse(self.timestampFGColor)
      local tbr,tbg,tbb = Geyser.Color.parse(self.timestampBGColor)
      colorString = string.format("<%s,%s,%s:%s,%s,%s>", tfr,tfg,tfb,tbr,tbg,tbb)
    else
      colorString = string.format("<%s,%s,%s:%s,%s,%s>", ofr,ofg,ofb,obr,obg,obb)
    end
    local timestamp = getTime(true, self.timestampFormat)
    local fullTimestamp = string.format("%s%s<r> ", colorString, timestamp)
    console:decho(fullTimestamp)
    if allTab and tabName ~= self.allTabName then
      allTab:decho(fullTimestamp)
    end
  end
  if self.blink and tabName ~= self.currentTab then
    if not (self.allTabName == self.currentTab and not self.blinkFromAll) then
      self.tabsToBlink[tabName] = true
    end
  end
  if xtype == "a" then
    console:appendBuffer()
    if allTab then
      allTab:appendBuffer()
    end
    if self.gag then
      deleteLine()
      if self.gagPrompt then
        tempPromptTrigger(function() deleteLine() end, 1)
      end
    end
  else
    console[xtype](console, message)
    if allTab then allTab[xtype](allTab, message) end
  end
  if self.blankLine then
    console:echo("\n")
    if allTab then allTab:echo("\n") end
  end
end

--- cecho to a tab, maintaining functionality
-- @tparam string tabName the name of the tab to cecho to
-- @tparam string message the message to cecho to that tab's console
-- @tparam boolean excludeAll if true, will exclude this from being mirrored to the allTab
function EMCO:cecho(tabName, message, excludeAll)
  local funcName = "EMCO:cecho(tabName, message, excludeAll)"
  self:checkEchoArgs(funcName, tabName, message, excludeAll)
  self:xEcho(tabName, message, 'cecho', excludeAll)
end

--- decho to a tab, maintaining functionality
-- @tparam string tabName the name of the tab to decho to
-- @tparam string message the message to decho to that tab's console
-- @tparam boolean excludeAll if true, will exclude this from being mirrored to the allTab
function EMCO:decho(tabName, message, excludeAll)
  local funcName = "EMCO:decho(console, message, excludeAll)"
  self:checkEchoArgs(funcName, tabName, message, excludeAll)
  self:xEcho(tabName, message, 'decho', excludeAll)
end

--- hecho to a tab, maintaining functionality
-- @tparam string tabName the name of the tab to hecho to
-- @tparam string message the message to hecho to that tab's console
-- @tparam boolean excludeAll if true, will exclude this from being mirrored to the allTab
function EMCO:hecho(tabName, message, excludeAll)
  local funcName = "EMCO:hecho(console, message, excludeAll)"
  self:checkEchoArgs(funcName, tabName, message, excludeAll)
  self:xEcho(tabName, message, 'hecho', excludeAll)
end

--- echo to a tab, maintaining functionality
-- @tparam string tabName the name of the tab to echo to
-- @tparam string message the message to echo to that tab's console
-- @tparam boolean excludeAll if true, will exclude this from being mirrored to the allTab
function EMCO:echo(tabName, message, excludeAll)
  local funcName = "EMCO:echo(console, message, excludeAll)"
  self:checkEchoArgs(funcName, tabName, message, excludeAll)
  self:xEcho(tabName, message, 'echo', excludeAll)
end

-- internal function used for type checking echoLink/Popup arguments
function EMCO:checkLinkArgs(funcName, tabName, text, commands, hints, excludeAll, popup)
  local expectedType = popup and "table" or "string"
  local textType = type(text)
  local commandsType = type(commands)
  local hintsType = type(hints)
  local tabNameType = type(tabName)
  local validTabName = table.contains(self.consoles, tabName)
  local excludeAllType = type(excludeAll)
  local sf = string.format
  local ae = self.ae
  if textType ~= "string" then
    ae(funcName, "text as string expected, got " .. textType)
  elseif commandsType ~= expectedType then
    ae(funcName, sf("commands as %s expected, got %s", expectedType, commandsType))
  elseif hintsType ~= expectedType then
    ae(funcName, sf("hints as %s expected, got %s", expectedType, hintsType))
  elseif tabNameType ~= "string" then
    ae(funcName, "tabName as string expected, got " .. tabNameType)
  elseif not validTabName then
    ae(funcName, sf("tabName must be a tab which exists, tab %s could not be found", tabName))
  elseif self.mapTab and tabName == self.mapTabName then
    ae(funcName, sf("You cannot echo to the map tab, and %s is configured as the mapTabName", tabName))
  elseif excludeAllType ~= "nil" and excludeAllType ~= "boolean" then
    ae(funcName, "Optional argument excludeAll expected as boolean, got " .. excludeAllType)
  end
end

-- internal function used for handling echoLink/popup
function EMCO:xLink(tabName, linkType, text, commands, hints, useCurrentFormat, excludeAll)
  local console = self.mc[tabName]
  local allTab = (self.allTab and not excludeAll and not table.contains(self.allTabExclusions, tabName) and tabName ~= self.allTabName) and self.mc[self.allTabName] or false
  local arguments = {text, commands, hints, useCurrentFormat}
  if self.timestamp then
    local colorString = ""
    if self.customTimestampColor then
      local tfr,tfg,tfb = Geyser.Color.parse(self.timestampFGColor)
      local tbr,tbg,tbb = Geyser.Color.parse(self.timestampBGColor)
      colorString = string.format("<%s,%s,%s:%s,%s,%s>", tfr,tfg,tfb,tbr,tbg,tbb)
    else
      local ofr,ofg,ofb = Geyser.Color.parse("white")
      local obr,obg,obb = Geyser.Color.parse(self.consoleColor)
      colorString = string.format("<%s,%s,%s:%s,%s,%s>", ofr,ofg,ofb,obr,obg,obb)
    end
    local timestamp = getTime(true, self.timestampFormat)
    local fullTimestamp = string.format("%s%s<r> ", colorString, timestamp)
    console:decho(fullTimestamp)
    if allTab then
      allTab:decho(fullTimestamp)
    end
  end
  console[linkType](console, unpack(arguments))
  if allTab then allTab[linkType](allTab, unpack(arguments)) end
end

--- cechoLink to a tab
-- @tparam string tabName the name of the tab to cechoLink to
-- @tparam string text the text underlying the link
-- @tparam string command the lua code to run in string format
-- @tparam string hint the tooltip hint to use for the link
-- @tparam boolean excludeAll if true, will exclude this from being mirrored to the allTab
function EMCO:cechoLink(tabName, text, command, hint, excludeAll)
  local funcName = "EMCO:cechoLink(tabName, text, command, hint)"
  self:checkLinkArgs(funcName, tabName, text, command, hint, excludeAll)
  self:xLink(tabName, "cechoLink", text, command, hint, true, excludeAll)
end

--- dechoLink to a tab
-- @tparam string tabName the name of the tab to dechoLink to
-- @tparam string text the text underlying the link
-- @tparam string command the lua code to run in string format
-- @tparam string hint the tooltip hint to use for the link
-- @tparam boolean excludeAll if true, will exclude this from being mirrored to the allTab
function EMCO:dechoLink(tabName, text, command, hint, excludeAll)
  local funcName = "EMCO:dechoLink(tabName, text, command, hint)"
  self:checkLinkArgs(funcName, tabName, text, command, hint, excludeAll)
  self:xLink(tabName, "dechoLink", text, command, hint, true, excludeAll)
end

--- hechoLink to a tab
-- @tparam string tabName the name of the tab to hechoLink to
-- @tparam string text the text underlying the link
-- @tparam string command the lua code to run in string format
-- @tparam string hint the tooltip hint to use for the link
-- @tparam boolean excludeAll if true, will exclude this from being mirrored to the allTab
function EMCO:hechoLink(tabName, text, command, hint, excludeAll)
  local funcName = "EMCO:hechoLink(tabName, text, command, hint)"
  self:checkLinkArgs(funcName, tabName, text, command, hint, excludeAll)
  self:xLink(tabName, "hechoLink", text, command, hint, true, excludeAll)
end

--- echoLink to a tab
-- @tparam string tabName the name of the tab to echoLink to
-- @tparam string text the text underlying the link
-- @tparam string command the lua code to run in string format
-- @tparam string hint the tooltip hint to use for the link
-- @tparam boolean useCurrentFormat use the format for the window or blue on black (hyperlink colors)
-- @tparam boolean excludeAll if true, will exclude this from being mirrored to the allTab
function EMCO:echoLink(tabName, text, command, hint, useCurrentFormat, excludeAll)
  local funcName = "EMCO:echoLink(tabName, text, command, hint, useCurrentFormat)"
  self:checkLinkArgs(funcName, tabName, text, command, hint, excludeAll)
  self:xLink(tabName, "echoLink", text, command, hint, useCurrentFormat, excludeAll)
end

--- cechoPopup to a tab
-- @tparam string tabName the name of the tab to cechoPopup to
-- @tparam string text the text underlying the link
-- @tparam table commands the lua code to run in string format
-- @tparam table hints the tooltip hint to use for the link
-- @tparam boolean excludeAll if true, will exclude this from being mirrored to the allTab
function EMCO:cechoPopup(tabName, text, commands, hints, excludeAll)
  local funcName = "EMCO:cechoPopup(tabName, text, commands, hints)"
  self:checkLinkArgs(funcName, tabName, text, commands, hints, excludeAll, true)
  self:xLink(tabName, "cechoPopup", text, commands, hints, true, excludeAll)
end

--- dechoPopup to a tab
-- @tparam string tabName the name of the tab to dechoPopup to
-- @tparam string text the text underlying the link
-- @tparam table commands the lua code to run in string format
-- @tparam table hints the tooltip hint to use for the link
-- @tparam boolean excludeAll if true, will exclude this from being mirrored to the allTab
function EMCO:dechoPopup(tabName, text, commands, hints, excludeAll)
  local funcName = "EMCO:dechoPopup(tabName, text, commands, hints)"
  self:checkLinkArgs(funcName, tabName, text, commands, hints, excludeAll, true)
  self:xLink(tabName, "dechoPopup", text, commands, hints, true, excludeAll)
end

--- hechoPopup to a tab
-- @tparam string tabName the name of the tab to hechoPopup to
-- @tparam string text the text underlying the link
-- @tparam table commands the lua code to run in string format
-- @tparam table hints the tooltip hint to use for the link
-- @tparam boolean excludeAll if true, will exclude this from being mirrored to the allTab
function EMCO:hechoPopup(tabName, text, commands, hints, excludeAll)
  local funcName = "EMCO:hechoPopup(tabName, text, commands, hints)"
  self:checkLinkArgs(funcName, tabName, text, commands, hints, excludeAll, true)
  self:xLink(tabName, "hechoPopup", text, commands, hints, true, excludeAll)
end

--- echoPopup to a tab
-- @tparam string tabName the name of the tab to echoPopup to
-- @tparam string text the text underlying the link
-- @tparam table commands the lua code to run in string format
-- @tparam table hints the tooltip hint to use for the link
-- @tparam boolean useCurrentFormat use the format for the window or blue on black (hyperlink colors)
-- @tparam boolean excludeAll if true, will exclude this from being mirrored to the allTab
function EMCO:echoPopup(tabName, text, commands, hints, useCurrentFormat, excludeAll)
  local funcName = "EMCO:echoPopup(tabName, text, commands, hints, useCurrentFormat)"
  self:checkLinkArgs(funcName, tabName, text, commands, hints, excludeAll, true)
  self:xLink(tabName, "echoPopup", text, commands, hints, useCurrentFormat, excludeAll)
end

--- adds a tab to the exclusion list for echoing to the allTab
-- @tparam string tabName the name of the tab to add to the exclusion list
function EMCO:addAllTabExclusion(tabName)
  local funcName = "EMCO:addAllTabExclusion(tabName)"
  local ae = self.ae
  local tabNameType = type(tabName)
  local validTabName = table.contains(self.consoles, tabName)
  if tabNameType ~= "string" then
    ae(funcName, "tabName as string expected, got " .. tabNameType)
  elseif not validTabName then
    ae(funcName, string.format("tabName %s does not exist in this EMCO. valid tabs: " .. table.concat(self.consoles, ",")))
  end
  if not table.contains(self.allTabExclusions, tabName) then table.insert(self.allTabExclusions, tabName) end
end

--- removess a tab from the exclusion list for echoing to the allTab
-- @tparam string tabName the name of the tab to remove from the exclusion list
function EMCO:removeAllTabExclusion(tabName)
  local funcName = "EMCO:removeAllTabExclusion(tabName)"
  local ae = self.ae
  local tabNameType = type(tabName)
  local validTabName = table.contains(self.consoles, tabName)
  if tabNameType ~= "string" then
    ae(funcName, "tabName as string expected, got " .. tabNameType)
  elseif not validTabName then
    ae(funcName, string.format("tabName %s does not exist in this EMCO. valid tabs: " .. table.concat(self.consoles, ",")))
  end
  local index = table.index_of(self.allTabExclusions, tabName)
  if index then table.remove(self.allTabExclusions, index) end
end

--- Enable placing a blank line between all messages.
function EMCO:enableBlankLine()
  self.blankLine = true
end

--- Enable placing a blank line between all messages.
function EMCO:disableBlankLine()
  self.blankLine = false
end

--- Enable scrollbars for the miniconsoles
function EMCO:enableScrollbars()
  self.scrollbars = true
  self:adjustScrollbars()
end

--- Disable scrollbars for the miniconsoles
function EMCO:disableScrollbars()
  self.scrollbars = false
  self:adjustScrollbars()
end

function EMCO:adjustScrollbars()
  for _,console in ipairs(self.consoles) do
    if self.mapTab and self.mapTabName == console then
      -- skip the Map tab
    else
      if self.scrollbars then
        self.mc[console]:enableScrollBar()
      else
        self.mc[console]:disableScrollBar()
      end
    end
  end
end

EMCOHelper = EMCOHelper or {}
EMCOHelper.items = EMCOHelper.items or {}
function EMCOHelper:switchTab(designator)
  local args = string.split(designator, "+")
  local emcoName = args[1]
  local tabName = args[2]
  for _,emco in ipairs(EMCOHelper.items) do
    if emco.name == emcoName then
      emco:switchTab(tabName)
      return
    end
  end
end

--- Save an EMCO's configuration for reloading later. Filename is based on the EMCO's name property.
function EMCO:save()
  local configtable = {
    timeStamp = self.timeStamp,
    blankLine = self.blankLine,
    scrollbars = self.scrollbars,
    customTimestampColor = self.customTimestampColor,
    mapTab = self.mapTab,
    mapTabName = self.mapTabName,
    blinkFromAll = self.blinkFromAll,
    preserveBackground = self.preserveBackground,
    gag = self.gag,
    timestampFormat = self.timestampFormat,
    timestampBGColor = self.timestampBGColor,
    allTab = self.allTab,
    allTabName = self.allTabName,
    blink = self.blink,
    blinkTime = self.blinkTime,
    fontSize = self.fontSize,
    font = self.font,
    tabFont = self.tabFont,
    activeTabCSS = self.activeTabCSS,
    inactiveTabCSS = self.inactiveTabCSS,
    activeTabFGColor = self.activeTabFGColor,
    activeTabBGColor = self.activeTabBGColor,
    inactiveTabFGColor = self.inactiveTabFGColor,
    inactiveTabBGColor = self.inactiveTabBGColor,
    consoleColor = self.consoleColor,
    tabBoxCSS = self.tabBoxCSS,
    tabBoxColor = self.tabBoxColor,
    consoleContainerCSS = self.consoleContainerCSS,
    consoleContainerColor = self.consoleContainerColor,
    gap = self.gap,
    consoles = self.consoles,
    allTabExclusions = self.allTabExclusions,
    tabHeight = self.tabHeight,
    autoWrap = self.autoWrap,
    wrapAt = self.wrapAt,
    leftMargin = self.leftMargin,
    rightMargin = self.rightMargin,
    bottomMargin = self.bottomMargin,
    topMargin = self.topMargin,
    x = self.x,
    y = self.y,
    height = self.height,
    width = self.width,
  }
  local dirname = getMudletHomeDir().."/EMCO/"
  local filename = dirname .. self.name .. ".lua"
  if not(io.exists(dirname)) then lfs.mkdir(dirname) end
  table.save(filename, configtable)
end

--- Load and apply a saved config for this EMCO
function EMCO:load()
  local dirname = getMudletHomeDir().."/EMCO/"
  local filename = dirname .. self.name .. ".lua"
  local configTable = {}
  if io.exists(filename) then
    table.load(filename, configTable)
  else
    debugc(string.format("Attempted to load config for EMCO named %s but the file could not be found. Filename: %s", self.name, filename))
  end
  self.timeStamp = configTable.timeStamp
  self.blankLine = configTable.blankLine
  self.scrollbars = configTable.scrollbars
  self.customTimestampColor = configTable.customTimestampColor
  self.mapTab = configTable.mapTab
  self.mapTabName = configTable.mapTabName
  self.blinkFromAll = configTable.blinkFromAll
  self.preserveBackground = configTable.preserveBackground
  self.gag = configTable.gag
  self.timestampFormat = configTable.timestampFormat
  self.timestampBGColor = configTable.timestampBGColor
  self.allTab = configTable.allTab
  self.allTabName = configTable.allTabName
  self.blink = configTable.blink
  self.blinkTime = configTable.blinkTime
  self.activeTabCSS = configTable.activeTabCSS
  self.inactiveTabCSS = configTable.inactiveTabCSS
  self.activeTabFGColor = configTable.activeTabFGColor
  self.activeTabBGColor = configTable.activeTabBGColor
  self.inactiveTabFGColor = configTable.inactiveTabFGColor
  self.inactiveTabBGColor = configTable.inactiveTabBGColor
  self.consoleColor = configTable.consoleColor
  self.tabBoxCSS = configTable.tabBoxCSS
  self.tabBoxColor = configTable.tabBoxColor
  self.consoleContainerCSS = configTable.consoleContainerCSS
  self.consoleContainerColor = configTable.consoleContainerColor
  self.gap = configTable.gap
  self.consoles = configTable.consoles
  self.allTabExclusions = configTable.allTabExclusions
  self.tabHeight = configTable.tabHeight
  self.wrapAt = configTable.wrapAt
  self.leftMargin = configTable.leftMargin
  self.rightMargin = configTable.rightMargin
  self.bottomMargin = configTable.bottomMargin
  self.topMargin = configTable.topMargin
  self:move(configTable.x, configTable.y)
  self:resize(configTable.width, configTable.height)
  self:reset()
  if configTable.fontSize then self:setFontSize(configTable.fontSize) end
  if configTable.font then self:setFont(configTable.font) end
  if configTable.tabFont then self:setTabFont(configTable.tabFont) end
  if configTable.autoWrap then self:enableAutoWrap() else self:disableAutoWrap() end
end

EMCO.parent = Geyser.Container

return EMCO
