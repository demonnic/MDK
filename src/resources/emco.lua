--- Embeddable Multi Console Object.
-- This is essentially YATCO, but with some tweaks, updates, and it returns an object
-- similar to Geyser so that you can a.) have multiple of them and b.) easily embed it
-- into your existing UI as you would any other Geyser element.
-- @classmod EMCO
-- @author Damian Monogue <demonnic@gmail.com>
-- @copyright 2020 Damian Monogue
-- @copyright 2021 Damian Monogue
-- @license MIT, see LICENSE.lua
local EMCO = Geyser.Container:new({
  name = "TabbedConsoleClass",
  timestampExceptions = {},
  path = "|h/log/|E/|y/|m/|d/",
  fileName = "|N.|e",
  bufferSize = "100000",
  deleteLines = "1000",
  blinkTime = 3,
  tabFontSize = 8,
  tabAlignment = "c",
  fontSize = 9,
  activeTabCSS = "",
  inactiveTabCSS = "",
  activeTabFGColor = "purple",
  inactiveTabFGColor = "white",
  activeTabBGColor = "<0,180,0>",
  inactiveTabBGColor = "<60,60,60>",
  consoleColor = "black",
  tabBoxCSS = "",
  tabBoxColor = "black",
  consoleContainerCSS = "",
  consoleContainerColor = "black",
  tabHeight = 25,
  leftMargin = 0,
  rightMargin = 0,
  topMargin = 0,
  bottomMargin = 0,
  gap = 1,
  wrapAt = 300,
  autoWrap = true,
  logExclusions = {},
  logFormat = "h",
  gags = {},
  notifyTabs = {},
  notifyWithFocus = false,
  cmdLineStyleSheet = [[
    QPlainTextEdit {
      border: 1px solid grey;
    }
  ]]
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

local pathOfThisFile = (...):match("(.-)[^%.]+$")
local ok, content = pcall(require, pathOfThisFile .. "loggingconsole")
local LC
if ok then
  LC = content
else
  debugc("EMCO tried to require loggingconsole but could not because: " .. content)
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
--     <td class="tg-1">timestamp</td>
--     <td class="tg-1">display timestamps on the miniconsoles?</td>
--     <td class="tg-1">false</td>
--   </tr>
--   <tr>
--     <td class="tg-2">blankLine</td>
--     <td class="tg-2">put a blank line between appends/echos?</td>
--     <td class="tg-2">false</td>
--   </tr>
--   <tr>
--     <td class="tg-1">scrollbars</td>
--     <td class="tg-1">enable scrollbars for the miniconsoles?</td>
--     <td class="tg-1">false</td>
--   </tr>
--   <tr>
--     <td class="tg-2">customTimestampColor</td>
--     <td class="tg-2">if showing timestamps, use a custom color?</td>
--     <td class="tg-2">false</td>
--   </tr>
--   <tr>
--     <td class="tg-1">mapTab</td>
--     <td class="tg-1">should we attach the Mudlet Mapper to this EMCO?</td>
--     <td class="tg-1">false</td>
--   </tr>
--   <tr>
--     <td class="tg-2">mapTabName</td>
--     <td class="tg-2">Which tab should we attach the map to?
--                     <br>If mapTab is true and you do not set this, it will throw an error</td>
--     <td class="tg-2"></td>
--   </tr>
--   <tr>
--     <td class="tg-1">blinkFromAll</td>
--     <td class="tg-1">should tabs still blink, even if you're on the 'all' tab?</td>
--     <td class="tg-1">false</td>
--   </tr>
--   <tr>
--     <td class="tg-2">preserveBackground</td>
--     <td class="tg-2">preserve the miniconsole background color during append()?</td>
--     <td class="tg-2">false</td>
--   </tr>
--   <tr>
--     <td class="tg-1">gag</td>
--     <td class="tg-1">when running :append(), should we also gag the line?</td>
--     <td class="tg-1">false</td>
--   </tr>
--   <tr>
--     <td class="tg-2">timestampFormat</td>
--     <td class="tg-2">Format string for the timestamp. Uses getTime()</td>
--     <td class="tg-2">"HH:mm:ss"</td>
--   </tr>
--   <tr>
--     <td class="tg-1">timestampBGColor</td>
--     <td class="tg-1">Custom BG color to use for timestamps. Any valid Geyser.Color works.</td>
--     <td class="tg-1">"blue"</td>
--   </tr>
--   <tr>
--     <td class="tg-2">timestampFGColor</td>
--     <td class="tg-2">Custom FG color to use for timestamps. Any valid Geyser.Color works</td>
--     <td class="tg-2">"red"</td>
--   </tr>
--   <tr>
--     <td class="tg-1">allTab</td>
--     <td class="tg-1">Should we send everything to an 'all' tab?</td>
--     <td class="tg-1">false</td>
--   </tr>
--   <tr>
--     <td class="tg-2">allTabName</td>
--     <td class="tg-2">And which tab should we use for the 'all' tab?</td>
--     <td class="tg-2">"All"</td>
--   </tr>
--   <tr>
--     <td class="tg-1">blink</td>
--     <td class="tg-1">Should we blink tabs that have been written to since you looked at them?</td>
--     <td class="tg-1">false</td>
--   </tr>
--   <tr>
--     <td class="tg-2">blinkTime</td>
--     <td class="tg-2">How long to wait between blinks, in seconds?</td>
--     <td class="tg-2">3</td>
--   </tr>
--   <tr>
--     <td class="tg-1">fontSize</td>
--     <td class="tg-1">What font size to use for the miniconsoles?</td>
--     <td class="tg-1">9</td>
--   </tr>
--   <tr>
--     <td class="tg-2">font</td>
--     <td class="tg-2">What font to use for the miniconsoles?</td>
--     <td class="tg-2"></td>
--   </tr>
--   <tr>
--     <td class="tg-1">tabFont</td>
--     <td class="tg-1">What font to use for the tabs?</td>
--     <td class="tg-1"></td>
--   </tr>
--   <tr>
--     <td class="tg-2">activeTabCss</td>
--     <td class="tg-2">What css to use for the active tab?</td>
--     <td class="tg-2">""</td>
--   </tr>
--   <tr>
--     <td class="tg-1">inactiveTabCSS</td>
--     <td class="tg-1">What css to use for the inactive tabs?</td>
--     <td class="tg-1">""</td>
--   </tr>
--   <tr>
--     <td class="tg-2">activeTabFGColor</td>
--     <td class="tg-2">What color to use for the text on the active tab. Any Geyser.Color works.</td>
--     <td class="tg-2">"purple"</td>
--   </tr>
--   <tr>
--     <td class="tg-1">inactiveTabFGColor</td>
--     <td class="tg-1">What color to use for the text on the inactive tabs. Any Geyser.Color works.</td>
--     <td class="tg-1">"white"</td>
--   </tr>
--   <tr>
--     <td class="tg-2">activeTabBGColor</td>
--     <td class="tg-2">What BG color to use for the active tab? Any Geyser.Color works. Overriden by activeTabCSS</td>
--     <td class="tg-2">"<0,180,0>"</td>
--   </tr>
--   <tr>
--     <td class="tg-1">inactiveTabBGColor</td>
--     <td class="tg-1">What BG color to use for the inactavie tabs? Any Geyser.Color works. Overridden by inactiveTabCSS</td>
--     <td class="tg-1">"<60,60,60>"</td>
--   </tr>
--   <tr>
--     <td class="tg-2">consoleColor</td>
--     <td class="tg-2">Default background color for the miniconsoles. Any Geyser.Color works</td>
--     <td class="tg-2">"black"</td>
--   </tr>
--   <tr>
--     <td class="tg-1">tabBoxCSS</td>
--     <td class="tg-1">tss for the entire tabBox (not individual tabs)</td>
--     <td class="tg-1">""</td>
--   </tr>
--   <tr>
--     <td class="tg-2">tabBoxColor</td>
--     <td class="tg-2">What color to use for the tabBox? Any Geyser.Color works. Overridden by tabBoxCSS</td>
--     <td class="tg-2">"black"</td>
--   </tr>
--   <tr>
--     <td class="tg-1">consoleContainerCSS</td>
--     <td class="tg-1">CSS to use for the container holding the miniconsoles</td>
--     <td class="tg-1">""</td>
--   </tr>
--   <tr>
--     <td class="tg-2">consoleContainerColor</td>
--     <td class="tg-2">Color to use for the container holding the miniconsole. Any Geyser.Color works. Overridden by consoleContainerCSS</td>
--     <td class="tg-2">"black"</td>
--   </tr>
--   <tr>
--     <td class="tg-1">gap</td>
--     <td class="tg-1">How many pixels to place between the tabs and the miniconsoles?</td>
--     <td class="tg-1">1</td>
--   </tr>
--   <tr>
--     <td class="tg-2">consoles</td>
--     <td class="tg-2">List of the tabs for this EMCO in table format</td>
--     <td class="tg-2">{ "All" }</td>
--   </tr>
--   <tr>
--     <td class="tg-1">allTabExclusions</td>
--     <td class="tg-1">List of the tabs which should never echo to the 'all' tab in table format</td>
--     <td class="tg-1">{}</td>
--   </tr>
--   <tr>
--     <td class="tg-2">tabHeight</td>
--     <td class="tg-2">How many pixels high should the tabs be?</td>
--     <td class="tg-2">25</td>
--   </tr>
--   <tr>
--     <td class="tg-1">autoWrap</td>
--     <td class="tg-1">Use autoWrap for the miniconsoles?</td>
--     <td class="tg-1">true</td>
--   </tr>
--   <tr>
--     <td class="tg-2">wrapAt</td>
--     <td class="tg-2">How many characters to wrap it, if autoWrap is turned off?</td>
--     <td class="tg-2">300</td>
--   </tr>
--   <tr>
--     <td class="tg-1">leftMargin</td>
--     <td class="tg-1">Number of pixels to put between the left edge of the EMCO and the miniconsole?</td>
--     <td class="tg-1">0</td>
--   </tr>
--   <tr>
--     <td class="tg-2">rightMargin</td>
--     <td class="tg-2">Number of pixels to put between the right edge of the EMCO and the miniconsole?</td>
--     <td class="tg-2">0</td>
--   </tr>
--   <tr>
--     <td class="tg-1">bottomMargin</td>
--     <td class="tg-1">Number of pixels to put between the bottom edge of the EMCO and the miniconsole?</td>
--     <td class="tg-1">0</td>
--   </tr>
--   <tr>
--     <td class="tg-2">topMargin</td>
--     <td class="tg-2">Number of pixels to put between the top edge of the miniconsole container, and the miniconsole? This is in addition to gap</td>
--     <td class="tg-2">0</td>
--   </tr>
--   <tr>
--     <td class="tg-1">timestampExceptions</td>
--     <td class="tg-1">Table of tabnames which should not get timestamps even if timestamps are turned on</td>
--     <td class="tg-1">{}</td>
--   </tr>
--   <tr>
--     <td class="tg-2">tabFontSize</td>
--     <td class="tg-2">Font size for the tabs</td>
--     <td class="tg-2">8</td>
--   </tr>
--   <tr>
--     <td class="tg-1">tabBold</td>
--     <td class="tg-1">Should the tab text be bold? Boolean value</td>
--     <td class="tg-1">false</td>
--   </tr>
--   <tr>
--     <td class="tg-2">tabItalics</td>
--     <td class="tg-2">Should the tab text be italicized?</td>
--     <td class="tg-2">false</td>
--   </tr>
--   <tr>
--     <td class="tg-1">tabUnderline</td>
--     <td class="tg-1">Should the tab text be underlined?</td>
--     <td class="tg-1">false</td>
--   </tr>
--   <tr>
--     <td class="tg-2">tabAlignment</td>
--     <td class="tg-2">Valid alignments are 'c', 'center', 'l', 'left', 'r', 'right', or '' to not include the alignment as part of the echo (to allow the stylesheet to handle it)</td>
--     <td class="tg-2">'c'</td>
--   </tr>
--   <tr>
--     <td class="tg-1">commandLine</td>
--     <td class="tg-1">Should we enable commandlines for the miniconsoles?</td>
--     <td class="tg-1">false</td>
--   </tr>
--   <tr>
--     <td class="tg-2">cmdActions</td>
--     <td class="tg-2">A table with console names as keys, and values which are templates for the command to send. see the setCustomCommandline function for more</td>
--     <td class="tg-2">{}</td>
--   </tr>
--   <tr>
--     <td class="tg-1">cmdLineStyleSheet</td>
--     <td class="tg-1">What stylesheet to use for the command lines.</td>
--     <td class="tg-1">"QPlainTextEdit {\n      border: 1px solid grey;\n    }\n"</td>
--   </tr>
--   <tr>
--     <td class="tg-2">backgroundImages</td>
--     <td class="tg-2">A table containing definitions for the background images. Each entry should have a key the same name as the tab it applies to, with entries "image" which is the path to the image file,<br>and "mode" which determines how it is displayed. "border" stretches, "center" center, "tile" tiles, and "style". See Mudletwikilink for details.</td>
--     <td class="tg-2">{}</td>
--   </tr>
--   <tr>
--     <td class="tg-1">bufferSize</td>
--     <td class="tg-1">Number of lines of scrollback to keep for the miniconsoles</td>
--     <td class="tg-1">100000</td>
--   </tr>
--   <tr>
--     <td class="tg-2">deleteLines</td>
--     <td class="tg-2">Number of lines to delete if a console's buffer fills up.</td>
--     <td class="tg-2">1000</td>
--   </tr>
--   <tr>
--     <td class="tg-1">gags</td>
--     <td class="tg-1">A table of Lua patterns you wish to gag from being added to the EMCO. Useful for removing mob says and such example: {[[^A green leprechaun says, ".*"$]], "^Bob The Dark Lord of the Keep mutters darkly to himself.$"} see <a href="http://lua-users.org/wiki/PatternsTutorial">this tutorial</a> on Lua patterns for more information.</td>
--     <td class="tg-1">{}</td>
--   </tr>
--   <tr>
--     <td class="tg-2">notifyTabs</td>
--     <td class="tg-2">Tables containing the names of all tabs you want to send notifications. IE {"Says", "Tells", "Org"}</td>
--     <td class="tg-2">{}</td>
--   </tr>
--   <tr>
--     <td class="tg-1">notifyWithFocus</td>
--     <td class="tg-1">If true, EMCO will send notifications even if Mudlet has focus. If false, it will only send them when Mudlet does NOT have focus.</td>
--     <td class="tg-1">false</td>
--   </tr>
-- </tbody>
-- </table>
-- @tparam GeyserObject container The container to use as the parent for the EMCO
-- @return the newly created EMCO
function EMCO:new(cons, container)
  local funcName = "EMCO:new(cons, container)"
  cons = cons or {}
  cons.type = cons.type or "tabbedConsole"
  cons.consoles = cons.consoles or {"All"}
  if cons.mapTab then
    if not type(cons.mapTabName) == "string" then
      self:ce(funcName, [["mapTab" is true, thus constraint "mapTabName" as string expected, got ]] .. type(cons.mapTabName))
    elseif not table.contains(cons.consoles, cons.mapTabName) then
      self:ce(funcName, [["mapTabName" must be one of the consoles contained within constraint "consoles". Valid option for tha mapTab are: ]] ..
                table.concat(cons.consoles, ","))
    end
  end
  cons.allTabExclusions = cons.allTabExclusions or {}
  if not type(cons.allTabExclusions) == "table" then
    self:se(funcName, "allTabExclusions must be a table if it is provided")
  end
  local me = self.parent:new(cons, container)
  setmetatable(me, self)
  self.__index = self
  -- set some defaults. Almost all the defaults we had for YATCO, plus a few new ones
  me.cmdActions = cons.cmdActions or {}
  if not type(me.cmdActions) == "table" then
    self:se(funcName, "cmdActions must be a table if it is provided")
  end
  me.backgroundImages = cons.backgroundImages or {}
  if not type(me.backgroundImages) == "table" then
    self:se(funcName, "backgroundImages must be a table if provided.")
  end
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
  if me:fuzzyBoolean(cons.gag) then
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
  me.tabUnderline = me:fuzzyBoolean(cons.tabUnderline) and true or false
  me.tabBold = me:fuzzyBoolean(cons.tabBold) and true or false
  me.tabItalics = me:fuzzyBoolean(cons.tabItalics) and true or false
  me.commandLine = me:fuzzyBoolean(cons.commandLine) and true or false
  me.consoles = cons.consoles
  me.font = cons.font
  me.tabFont = cons.tabFont
  me.currentTab = ""
  me.tabs = {}
  me.tabsToBlink = {}
  me.mc = {}
  if me.blink then
    me:enableBlink()
  end
  me.gags = {}
  for _,pattern in ipairs(cons.gags or {}) do
    me:addGag(pattern)
  end
  for _,tname in ipairs(cons.notifyTabs or {}) do
    me:addNotifyTab(tname)
  end
  if me:fuzzyBoolean(cons.notifyWithFocus) then
    self:enableNotifyWithFocus()
  end
  me:reset()
  if me.allTab then
    me:setAllTabName(me.allTabName or me.consoles[1])
  end
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
    for _, channel in ipairs(config.channels) do
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
  constraints = string.format("%s  activeTabBGColor = \"<%s,%s,%s>\",\n", constraints, config.activeColors.r, config.activeColors.g,
                              config.activeColors.b)
  constraints = string.format("%s  inactiveTabBGColor = \"<%s,%s,%s>\",\n", constraints, config.inactiveColors.r, config.inactiveColors.g,
                              config.inactiveColors.b)
  constraints =
    string.format("%s  consoleColor = \"<%s,%s,%s>\",\n", constraints, config.windowColors.r, config.windowColors.g, config.windowColors.b)
  constraints = string.format("%s  activeTabFGColor = \"%s\",\n", constraints, config.activeTabText)
  constraints = string.format("%s  inactiveTabFGColor = \"%s\"", constraints, config.inactiveTabText)
  constraints = string.format("%s\n})", constraints)
  return constraints
end

--- Scans for the old YATCO configuration values and prints out a set of constraints to use.
-- with EMCO to achieve the same effect. Is just the invocation
function EMCO:miniConvertYATCO()
  local constraints = self:readYATCO()
  cecho(
    "<white>(<blue>EMCO<white>)<reset> Found a YATCO config. Here are the constraints to use with EMCO(x,y,width, and height have been converted to their absolute values):\n\n")
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
-- @tparam string tabName the name of the tab you want to display to
-- @param tabName string the tab to displayu to
-- @param item any The thing to display()
-- @param[opt] any item2 another thing to display()
function EMCO:display(tabName, ...)
  local funcName = "EMCO:display(tabName, item)"
  if not table.contains(self.consoles, tabName) then
    self.ae(funcName, "tabName must be a tab which exists in this EMCO. valid options are: " .. table.concat(self.consoles, ","))
  end
  self.mc[tabName]:display(...)
end

--- Remove a tab from the EMCO
-- @param tabName string the name of the tab you want to remove from the EMCO
function EMCO:removeTab(tabName)
  local funcName = "EMCO:removeTab(tabName)"
  if not table.contains(self.consoles, tabName) then
    self.ae(funcName, "tabName must be a tab which exists in this EMCO. valid options are: " .. table.concat(self.consoles, ","))
  end
  if self.currentTab == tabName then
    if self.allTab and self.allTabName then
      self:switchTab(self.allTabName)
    else
      self:switchTab(self.consoles[1])
    end
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
  self.tabs[tabName] = nil
end

--- Adds a tab to the EMCO object
-- @tparam string tabName the name of the tab to add
-- @tparam[opt] number position position in the tab switcher to put this tab
function EMCO:addTab(tabName, position)
  local funcName = "EMCO:addTab(tabName, position)"
  position = self:checkTabPosition(position)
  if type(position) == "string" then
    self.ae(funcName, "position as number expected, got " .. position)
  end
  local tabCheck = self:checkTabName(tabName)
  if tabCheck ~= "clear" then
    self.ae(funcName, tabCheck)
  end
  if position == 0 then
    table.insert(self.consoles, tabName)
    self:createComponentsForTab(tabName)
  else
    table.insert(self.consoles, position, tabName)
    self:reset()
  end
end

--- Switches the active, visible tab of the EMCO to tabName
-- @param tabName string the name of the tab to show
function EMCO:switchTab(tabName)
  local oldTab = self.currentTab
  self.currentTab = tabName
  if oldTab ~= tabName and oldTab ~= "" then
    self.mc[oldTab]:hide()
    self:adjustTabBackground(oldTab)
    self.tabs[oldTab]:echo(oldTab, self.inactiveTabFGColor)
    if self.blink then
      if self.allTab and tabName == self.allTabName then
        self.tabsToBlink = {}
      elseif self.tabsToBlink[tabName] then
        self.tabsToBlink[tabName] = nil
      end
    end
  end
  self:adjustTabBackground(tabName)
  self.tabs[tabName]:echo(tabName, self.activeTabFGColor)
  -- if oldTab and self.mc[oldTab] then
  --   self.mc[oldTab]:hide()
  -- end
  self.mc[tabName]:show()
  if oldTab ~= tabName then
    raiseEvent("EMCO tab change", self.name, oldTab, tabName)
  end
end

--- Cycles between the tabs in order
-- @tparam boolean reverse Defaults to false. When true, moves backward through the tab list rather than forward.
function EMCO:cycleTab(reverse)
  -- add the property to demonnic.chat
  local consoles = self.consoles
  local cycleIndex = table.index_of(consoles, self.currentTab)

  local maxIndex = #consoles
  cycleIndex = reverse and cycleIndex - 1 or cycleIndex + 1
  if cycleIndex > maxIndex then cycleIndex = 1 end
  if cycleIndex < 1 then cycleIndex = maxIndex end
  self:switchTab(consoles[cycleIndex])
end

function EMCO:createComponentsForTab(tabName)
  local tab = Geyser.Label:new({name = string.format("%sTab%s", self.name, tabName)}, self.tabBox)
  if self.tabFont then
    tab:setFont(self.tabFont)
  end
  tab:setAlignment(self.tabAlignment)
  tab:setFontSize(self.tabFontSize)
  tab:setItalics(self.tabItalics)
  tab:setBold(self.tabBold)
  tab:setUnderline(self.tabUnderline)
  tab:setClickCallback(self.switchTab, self, tabName)
  self.tabs[tabName] = tab
  self:adjustTabBackground(tabName)
  tab:echo(tabName, self.inactiveTabFGColor)
  local window
  local windowConstraints = {
    x = self.leftMargin,
    y = self.topMargin,
    height = string.format("-%dpx", self.bottomMargin),
    width = string.format("-%dpx", self.rightMargin),
    name = string.format("%sWindow%s", self.name, tabName),
    commandLine = self.commandLine,
    cmdLineStyleSheet = self.cmdLineStyleSheet,
    path = self:processTemplate(self.path, tabName),
    fileName = self:processTemplate(self.fileName, tabName),
    logFormat = self.logFormat
  }
  if table.contains(self.logExclusions, tabName) then
    windowConstraints.log = false
  end
  local parent = self.consoleContainer
  local mapTab = self.mapTab and tabName == self.mapTabName
  if mapTab then
    window = Geyser.Mapper:new(windowConstraints, parent)
  else
    if LC then
      window = LC:new(windowConstraints, parent)
    else
      window = Geyser.MiniConsole:new(windowConstraints, parent)
    end
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
    window:setBufferSize(self.bufferSize, self.deleteLines)
  end
  self.mc[tabName] = window
  if not mapTab then
    self:setCmdAction(tabName, nil)
  end
  window:hide()
  self:processImage(tabName)
  self:switchTab(tabName)
end

--- Sets the buffer size and number of lines to delete for all managed miniconsoles.
--- @tparam number bufferSize number of lines of scrollback to maintain in the miniconsoles. Uses current value if nil is passed
--- @tparam number deleteLines number of line to delete if the buffer filles up. Uses current value if nil is passed
function EMCO:setBufferSize(bufferSize, deleteLines)
  bufferSize = bufferSize or self.bufferSize
  deleteLines = deleteLines or self.deleteLines
  self.bufferSize = bufferSize
  self.deleteLines = deleteLines
  for tabName, window in pairs(self.mc) do
    local mapTab = self.mapTab and tabName == self.mapTabName
    if not mapTab then
      window:setBufferSize(bufferSize, deleteLines)
    end
  end
end

--- Sets the background image for a tab's console. use EMCO:resetBackgroundImage(tabName) to remove an image.
--- @tparam string tabName the tab to change the background image for.
--- @tparam string imagePath the path to the image file to use.
--- @tparam string mode the mode to use. Will default to "center" if not provided.
function EMCO:setBackgroundImage(tabName, imagePath, mode)
  mode = mode or "center"
  local tabNameType = type(tabName)
  local imagePathType = type(imagePath)
  local modeType = type(mode)
  local funcName = "EMCO:setBackgroundImage(tabName, imagePath, mode)"
  if tabNameType ~= "string" or not table.contains(self.consoles, tabName) then
    self.ae(funcName, "tabName must be a string and an existing tab")
  end
  if imagePathType ~= "string" or not io.exists(imagePath) then
    self.ae(funcName, "imagePath must be a string and point to an existing image file")
  end
  if modeType ~= "string" or not table.contains({"border", "center", "tile", "style"}, mode) then
    self.ae(funcName, "mode must be one of 'border', 'center', 'tile', or 'style'")
  end
  local image = {image = imagePath, mode = mode}
  self.backgroundImages[tabName] = image
  self:processImage(tabName)
end

--- Resets the background image on a tab's console, returning it to the background color
--- @tparam string tabName the tab to change the background image for.
function EMCO:resetBackgroundImage(tabName)
  local tabNameType = type(tabName)
  local funcName = "EMCO:resetBackgroundImage(tabName)"
  if tabNameType ~= "string" or not table.contains(self.consoles, tabName) then
    self.ae(funcName, "tabName must be a string and an existing tab")
  end
  self.backgroundImages[tabName] = nil
  self:processImage(tabName)
end

--- Does the work of actually setting/resetting the background image on a tab
--- @tparam string tabName the name of the tab to process the image for.
--- @local
function EMCO:processImage(tabName)
  if self.mapTab and tabName == self.mapTabName then
    return
  end
  local image = self.backgroundImages[tabName]
  local window = self.mc[tabName]
  if image then
    if image.image and io.exists(image.image) then
      window:setBackgroundImage(image.image, image.mode)
    end
  else
    window:resetBackgroundImage()
  end
end

--- Replays the last numLines lines from the log for tabName
-- @param tabName the name of the tab to replay
-- @param numLines the number of lines to replay
function EMCO:replay(tabName, numLines)
  if not LC then
    return
  end
  if self.mapTab and tabName == self.mapTabName then
    return
  end
  numLines = numLines or 10
  self.mc[tabName]:replay(numLines)
end

--- Replays the last numLines in all miniconsoles
-- @param numLines
function EMCO:replayAll(numLines)
  if not LC then
    return
  end
  numLines = numLines or 10
  for _, tabName in ipairs(self.consoles) do
    self:replay(tabName, numLines)
  end
end

--- Formats the string through EMCO's template. |E is replaced with the EMCO's name. |N is replaced with the tab's name.
-- @param str the string to replace tokens in
-- @param tabName optional, if included will be used for |N in the templated string.
function EMCO:processTemplate(str, tabName)
  local safeName = self.name:gsub("[<>:'\"?*]", "_")
  local safeTabName = tabName and tabName:gsub("[<>:'\"?*]", "_") or ""
  str = str:gsub("|E", safeName)
  str = str:gsub("|N", safeTabName)
  return str
end

--- Sets the path for the EMCO for logging
-- @param path the template for the path. @see EMCO:new()
function EMCO:setPath(path)
  if not LC then
    return
  end
  path = path or self.path
  self.path = path
  path = self:processTemplate(path)
  for name, window in pairs(self.mc) do
    if not (self.mapTab and self.mapTabName == name) then
      window:setPath(path)
    end
  end
end

--- Sets the fileName for the EMCO for logging
-- @param fileName the template for the path. @see EMCO:new()
function EMCO:setFileName(fileName)
  if not LC then
    return
  end
  fileName = fileName or self.fileName
  self.fileName = fileName
  fileName = self:processTemplate(fileName)
  for name, window in pairs(self.mc) do
    if not (self.mapTab and self.mapTabName == name) then
      window:setFileName(fileName)
    end
  end
end

--- Sets the stylesheet for command lines in this EMCO
-- @tparam string styleSheet the stylesheet to use for the command line. See https://wiki.mudlet.org/w/Manual:Lua_Functions#setCmdLineStyleSheet for examples
function EMCO:setCmdLineStyleSheet(styleSheet)
  self.cmdLineStyleSheet = styleSheet
  if not styleSheet then
    return
  end
  for _, window in pairs(self.mc) do
    window:setCmdLineStyleSheet(styleSheet)
  end
end
--- Enables the commandLine on the specified tab.
-- @tparam string tabName the name of the tab to turn the commandLine on for
-- @param template the template for the commandline to use, or the function to run when enter is hit.
-- @usage myEMCO:enableCmdLine(tabName, template)
function EMCO:enableCmdLine(tabName, template)
  if not table.contains(self.consoles, tabName) then
    return nil, f"{self.name}:enableCmdLine(tabName,template) tabName is not in the console list. Valid options are {table.concat(self.consoles, 'm')}"
  end
  local window = self.mc[tabName]
  window:enableCommandLine()
  if self.cmdLineStyleSheet then
    window:setCmdLineStyleSheet(self.cmdLineStyleSheet)
  end
  self:setCmdAction(tabName, template)
end

--- Enables all command lines, using whatever template they may currently have set
function EMCO:enableAllCmdLines()
  for _, tabName in ipairs(self.consoles) do
    self:enableCmdLine(tabName, self.cmdActions[tabName])
  end
end

--- Disables all commands line, but does not change their template
function EMCO:disableAllCmdLines()
  for _, tabName in ipairs(self.consoles) do
    self:disableCmdLine(tabName)
  end
end

--- Disables the command line for a particular tab
-- @tparam string tabName the name of the tab to disable the command line of.
function EMCO:disableCmdLine(tabName)
  if not table.contains(self.consoles, tabName) then
    return nil, f"{self.name}:disableCmdLine(tabName,template) tabName is not in the console list. Valid options are {table.concat(self.consoles, 'm')}"
  end
  local window = self.mc[tabName]
  window:disableCommandLine()
end

--- Sets the command action for a tab's command line. Can either be a template string to send where '|t' is replaced by the text sent, or a funnction which takes the text
--- @tparam string tabName the name of the tab to set the command action on
--- @param template the template for the commandline to use, or the function to run when enter is hit.
--- @usage myEMCO:setCmdAction("CT", "ct |t") -- will send everything in the CT tab's command line to CT by doing "ct Hi there!" if you type "Hi there!" in CT's command line
--- @usage myEMCO:setCmdAction("CT", function(txt) send("ct " .. txt) end) -- functionally the same as the above
function EMCO:setCmdAction(tabName, template)
  template = template or self.cmdActions[tabName]
  if template == "" then
    template = nil
  end
  self.cmdActions[tabName] = template
  local window = self.mc[tabName]
  if template then
    if type(template) == "string" then
      window:setCmdAction(function(txt)
        txt = template:gsub("|t", txt)
        send(txt)
      end)
    elseif type(template) == "function" then
      window:setCmdAction(template)
    else
      debugc(string.format(
               "EMCO:setCmdAction(tabName, template): template must be a string or function if provided. Leaving CmdAction for tab %s be. Template type was: %s",
               tabName, type(template)))
    end
  else
    window:resetCmdAction()
  end
end

--- Resets the command action for tabName's miniconsole, which makes it work like the normal commandline
--- @tparam string tabName the name of the tab to reset the cmdAction for
function EMCO:resetCmdAction(tabName)
  self.cmdActions[tabName] = nil
  self.mc[tabName]:resetCmdAction()
end

--- Gets the contents of tabName's cmdLine
--- @param tabName the name of the tab to get the commandline of
function EMCO:getCmdLine(tabName)
  return self.mc[tabName]:getCmdLine()
end

--- Prints to tabName's command line
--- @param tabName the tab whose command line you want to print to
--- @param txt the text to print to the command line
function EMCO:printCmd(tabName, txt)
  return self.mc[tabName]:printCmd(txt)
end

--- Clears tabName's command line
--- @tparam string tabName the tab whose command line you want to clear
function EMCO:clearCmd(tabName)
  return self.mc[tabName]:clearCmd()
end

--- Appends text to tabName's command line
--- @tparam string tabName the tab whose command line you want to append to
--- @tparam string txt the text to append to the command line
function EMCO:appendCmd(tabName, txt)
  return self.mc[tabName]:appendCmd(txt)
end

--- resets the object, redrawing everything
function EMCO:reset()
  self:createContainers()
  for _, tabName in ipairs(self.consoles) do
    self:createComponentsForTab(tabName)
  end

  local default = self.allTabName or self.consoles[1]
  self:switchTab(default)
end

function EMCO:createContainers()
  self.tabBoxLabel = Geyser.Label:new({
    x = 0,
    y = 0,
    width = "100%",
    height = tostring(tonumber(self.tabHeight) + 2) .. "px",
    name = self.name .. "TabBoxLabel",
  }, self)
  self.tabBox = Geyser.HBox:new({x = 0, y = 0, width = "100%", height = "100%", name = self.name .. "TabBox"}, self.tabBoxLabel)
  self.tabBoxLabel:setStyleSheet(self.tabBoxCSS)
  self.tabBoxLabel:setColor(self.tabBoxColor)

  local heightPlusGap = tonumber(self.tabHeight) + tonumber(self.gap)
  self.consoleContainer = Geyser.Label:new({
    x = 0,
    y = tostring(heightPlusGap) .. "px",
    width = "100%",
    height = "-0px",
    name = self.name .. "ConsoleContainer",
  }, self)
  self.consoleContainer:setStyleSheet(self.consoleContainerCSS)
  self.consoleContainer:setColor(self.consoleContainerColor)
end

function EMCO:stripTimeChars(str)
  return string.gsub(string.trim(str), '[ThHmMszZaApPdy0-9%-%+:. ]', '')
end

--- Expands boolean definitions to be more flexible.
-- <br>True values are "true", "yes", "0", 0, and true
-- <br>False values are "false", "no", "1", 1, false, and nil
-- @param bool item to test for truthiness
function EMCO:fuzzyBoolean(bool)
  if type(bool) == "boolean" or bool == nil then
    return bool
  elseif tostring(bool) then
    local truth = {"yes", "true", "0"}
    local untruth = {"no", "false", "1"}
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
  for _, tabName in ipairs(self.consoles) do
    if not self.mapTab or (tabName ~= self.mapTabName) then
      self:clear(tabName)
    end
  end
end

--- sets the font for all tabs
--- @tparam string font the font to use.
function EMCO:setTabFont(font)
  self.tabFont = font
  for _, tab in pairs(self.tabs) do
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
    local err = "EMCO:setFont(font): attempt to call setFont with font '" .. font ..
                  "' which is not available, see getAvailableFonts() for valid options\n"
    err = err .. "In the meantime, we will use a similar font which isn't the one you asked for but we hope is close enough"
    debugc(err)
  end
  self.font = font
  for _, tabName in pairs(self.consoles) do
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
    local err = "EMCO:setSingleWindowFont(tabName, font): attempt to call setFont with font '" .. font ..
                  "' which is not available, see getAvailableFonts() for valid options\n"
    err = err .. "In the meantime, we will use a similar font which isn't the one you asked for but we hope is close enough"
    debugc(err)
  end
  self.mc[tabName]:setFont(font)
end

--- sets the font size for all tabs
--- @tparam number fontSize the font size to use for the tabs
function EMCO:setTabFontSize(fontSize)
  self.tabFontSize = fontSize
  for _, tab in pairs(self.tabs) do
    tab:setFontSize(fontSize)
  end
end

--- Sets the alignment for all the tabs
-- @param alignment Valid alignments are 'c', 'center', 'l', 'left', 'r', 'right', or '' to not include the alignment as part of the echo
function EMCO:setTabAlignment(alignment)
  self.tabAlignment = alignment
  for _, tab in pairs(self.tabs) do
    tab:setAlignment(self.tabAlignment)
  end
end

--- enables underline on all tabs
function EMCO:enableTabUnderline()
  self.tabUnderline = true
  for _, tab in pairs(self.tabs) do
    tab:setUnderline(self.tabUnderline)
  end
end

--- disables underline on all tabs
function EMCO:disableTabUnderline()
  self.tabUnderline = false
  for _, tab in pairs(self.tabs) do
    tab:setUnderline(self.tabUnderline)
  end
end

--- enables italics on all tabs
function EMCO:enableTabItalics()
  self.tabItalics = true
  for _, tab in pairs(self.tabs) do
    tab:setItalics(self.tabItalics)
  end
end

--- enables italics on all tabs
function EMCO:disableTabItalics()
  self.tabItalics = false
  for _, tab in pairs(self.tabs) do
    tab:setItalics(self.tabItalics)
  end
end

--- enables bold on all tabs
function EMCO:enableTabBold()
  self.tabBold = true
  for _, tab in pairs(self.tabs) do
    tab:setBold(self.tabBold)
  end
end

--- disables bold on all tabs
function EMCO:disableTabBold()
  self.tabBold = false
  for _, tab in pairs(self.tabs) do
    tab:setBold(self.tabBold)
  end
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
    self.ae(funcName,
            "format contains invalid time format characters. Please see https://wiki.mudlet.org/w/Manual:Lua_Functions#getTime for formatting information")
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
  if allTabNameType ~= "string" then
    self.ae(funcName, "allTabName expected as string, got" .. allTabNameType)
  end
  if not table.contains(self.consoles, allTabName) then
    self.ae(funcName, "allTabName must be the name of one of the console tabs. Valid options are: " .. table.concat(self.consoles, ","))
  end
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
    error(funcName ..
            ": cannot enable the map tab, mapTabName not set. try running :setMapTabName(mapTabName) first with the name of the tab you want to bind the map to")
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
  if not self.blinkTimerID then
    self.blinkTimerID = tempTimer(self.blinkTime, function()
      self:doBlink()
    end, true)
  end
end

--- Disables tab blinking when new information comes in to an inactive tab
function EMCO:disableBlink()
  self.blink = false
  if self.blinkTimerID then
    killTimer(self.blinkTimerID)
    self.blinkTimerID = nil
  end
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
    self.ae(funcName, "blinkTime as number expected, got " .. type(blinkTime))
  else
    self.blinkTime = blinkTimeNumber
    if self.blinkTimerID then
      killTimer(self.blinkTimerID)
    end
    self.blinkTimerID = tempTimer(blinkTimeNumber, function()
      self:blink()
    end, true)
  end
end

function EMCO:doBlink()
  if self.hidden or self.auto_hidden or not self.blink then
    return
  end
  for tab, _ in pairs(self.tabsToBlink) do
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
    for _, tabName in ipairs(self.consoles) do
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
  for _, console in ipairs(self.consoles) do
    if console == self.currentTab then
      self.tabs[console]:echo(console, self.activTabFGColor, 'c')
    else
      self.tabs[console]:echo(console, self.inactiveTabFGColor, 'c')
    end
  end
end

function EMCO:adjustTabBackground(console)
  local tab = self.tabs[console]
  local activeTabCSS = self.activeTabCSS
  local inactiveTabCSS = self.inactiveTabCSS
  local activeTabBGColor = self.activeTabBGColor
  local inactiveTabBGColor = self.inactiveTabBGColor
  if console == self.currentTab then
    if activeTabCSS and activeTabCSS ~= "" then
      tab:setStyleSheet(activeTabCSS)
    elseif activeTabBGColor then
      tab:setColor(activeTabBGColor)
    end
  else
    if inactiveTabCSS and inactiveTabCSS ~= "" then
      tab:setStyleSheet(inactiveTabCSS)
    elseif inactiveTabBGColor then
      tab:setColor(inactiveTabBGColor)
    end
  end
end

function EMCO:adjustTabBackgrounds()
  for _, console in ipairs(self.consoles) do
    self:adjustTabBackground(console)
  end
end

--- Sets the inactiveTabCSS
-- @tparam string stylesheet the stylesheet to use for inactive tabs.
function EMCO:setInactiveTabCSS(stylesheet)
  self.inactiveTabCSS = stylesheet
  self:adjustTabBackgrounds()
end

--- Sets the activeTabCSS
-- @tparam string stylesheet the stylesheet to use for active tab.
function EMCO:setActiveTabCSS(stylesheet)
  self.activeTabCSS = stylesheet
  self:adjustTabBackgrounds()
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
  for _, console in ipairs(self.consoles) do
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
    self.ae(funcName, "tabHeight as number expected, got " .. tabHeightType)
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
  for _, console in ipairs(self.consoles) do
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
  for _, console in ipairs(self.consoles) do
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
    for _, console in ipairs(self.consoles) do
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
    self.ae(funcName, "tabName as string expected, got " .. tabNameType)
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

--- Adds a tab to the list of tabs to send OS toast/popup notifications for
--@tparam string tabName the name of a tab to enable notifications for
--@return true if it was added, false if it was already included, nil if the tab does not exist.
function EMCO:addNotifyTab(tabName)
  if not table.contains(self.consoles, tabName) then
    return nil, "Tab does not exist"
  end
  if self.notifyTabs[tabName] then
    return false
  end
  self.notifyTabs[tabName] = true
  return true
end

--- Removes a tab from the list of tabs to send OS toast/popup notifications for
--@tparam string tabName the name of a tab to disable notifications for
--@return true if it was removed, false if it wasn't enabled to begin with, nil if the tab does not exist.
function EMCO:removeNotifyTab(tabName)
  if not table.contains(self.consoles, tabName) then
    return nil, "Tab does not exist"
  end
  if not self.notifyTabs[tabName] then
    return false
  end
  self.notifyTabs[tabName] = nil
  return true
end

--- Adds a pattern to the gag list for the EMCO
--@tparam string pattern a Lua pattern to gag. http://lua-users.org/wiki/PatternsTutorial
--@return true if it was added, false if it was already included.
function EMCO:addGag(pattern)
  if self.gags[pattern] then
    return false
  end
  self.gags[pattern] = true
  return true
end

--- Removes a pattern from the gag list for the EMCO
--@tparam string pattern a Lua pattern to no longer gag. http://lua-users.org/wiki/PatternsTutorial
--@return true if it was removed, false if it was not there to remove.
function EMCO:removeGag(pattern)
  if self.gags[pattern] then
    self.gags[pattern] = nil
    return true
  end
  return false
end

--- Checks if a string matches any of the EMCO's gag patterns
--@tparam string str The text you're testing against the gag patterns
--@return false if it does not match any gag patterns. true and the matching pattern if it does match.
function EMCO:matchesGag(str)
  for pattern,_ in pairs(self.gags) do
    if str:match(pattern) then
      return true, pattern
    end
  end
  return false
end

--- Enables sending OS notifications even if Mudlet has focus
function EMCO:enableNotifyWithFocus()
  self.notifyWithFocus = true
end

--- Disables sending OS notifications if Mudlet has focus
function EMCO:disableNotifyWithFocus()
  self.notifyWithFocus = false
end

function EMCO:strip(message, xtype)
  local strippers = {
    a = function(msg) return msg end,
    echo = function(msg) return msg end,
    cecho = cecho2string,
    decho = decho2string,
    hecho = hecho2string,
  }
  local result = strippers[xtype](message)
  return result
end

function EMCO:sendNotification(tabName, msg)
  if self.notifyWithFocus or not hasFocus() then
    if self.notifyTabs[tabName] then
      showNotification(f'{self.name}:{tabName}', msg)
    end
  end
end

function EMCO:xEcho(tabName, message, xtype, excludeAll)
  if self.mapTab and self.mapTabName == tabName then
    error("You cannot send text to the Map tab")
  end
  local console = self.mc[tabName]
  local allTab = (self.allTab and not excludeAll and not table.contains(self.allTabExclusions, tabName) and tabName ~= self.allTabName) and
                   self.mc[self.allTabName] or false
  local ofr, ofg, ofb, obr, obg, obb
  if xtype == "a" then
    local line = getCurrentLine()
    local mute, reason = self:matchesGag(line)
    if mute then
      debugc(f"{self.name}:append(tabName) denied because current line matches the pattern '{reason}'")
      return
    end
    selectCurrentLine()
    ofr, ofg, ofb = getFgColor()
    obr, obg, obb = getBgColor()
    if self.preserveBackground then
      local r, g, b = Geyser.Color.parse(self.consoleColor)
      setBgColor(r, g, b)
    end
    copy()
    if self.preserveBackground then
      setBgColor(obr, obg, obb)
    end
    deselect()
    resetFormat()
  else
    local mute, reason = self:matchesGag(message)
    if mute then
      debugc(f"{self.name}:{xtype}(tabName, msg, excludeAll) denied because msg matches '{reason}'")
      return
    end
    ofr, ofg, ofb = Geyser.Color.parse("white")
    obr, obg, obb = Geyser.Color.parse(self.consoleColor)
  end
  if self.timestamp then
    local colorString = ""
    if self.customTimestampColor then
      local tfr, tfg, tfb = Geyser.Color.parse(self.timestampFGColor)
      local tbr, tbg, tbb = Geyser.Color.parse(self.timestampBGColor)
      colorString = string.format("<%s,%s,%s:%s,%s,%s>", tfr, tfg, tfb, tbr, tbg, tbb)
    else
      colorString = string.format("<%s,%s,%s:%s,%s,%s>", ofr, ofg, ofb, obr, obg, obb)
    end
    local timestamp = getTime(true, self.timestampFormat)
    local fullTimestamp = string.format("%s%s<r> ", colorString, timestamp)
    if not table.contains(self.timestampExceptions, tabName) then
      console:decho(fullTimestamp)
    end
    if allTab and tabName ~= self.allTabName and not table.contains(self.timestampExceptions, self.allTabName) then
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
    local txt = self:strip(getCurrentLine(), xtype)
    self:sendNotification(tabName, txt)
    if allTab then
      allTab:appendBuffer()
    end
    if self.gag then
      deleteLine()
      if self.gagPrompt then
        tempPromptTrigger(function()
          deleteLine()
        end, 1)
      end
    end
  else
    console[xtype](console, message)
    self:sendNotification(tabName, self:strip(message, xtype))
    if allTab then
      allTab[xtype](allTab, message)
    end
  end
  if self.blankLine then
    console:echo("\n")
    if allTab then
      allTab:echo("\n")
    end
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
  local gag, reason = self:matchesGag(text)
  if gag then
    debugc(f"{self.name}:{linkType}(tabName, text, command, hint, excludeAll) denied because text matches '{reason}'")
    return
  end
  local console = self.mc[tabName]
  local allTab = (self.allTab and not excludeAll and not table.contains(self.allTabExclusions, tabName) and tabName ~= self.allTabName) and
                   self.mc[self.allTabName] or false
  local arguments = {text, commands, hints, useCurrentFormat}
  if self.timestamp then
    local colorString = ""
    if self.customTimestampColor then
      local tfr, tfg, tfb = Geyser.Color.parse(self.timestampFGColor)
      local tbr, tbg, tbb = Geyser.Color.parse(self.timestampBGColor)
      colorString = string.format("<%s,%s,%s:%s,%s,%s>", tfr, tfg, tfb, tbr, tbg, tbb)
    else
      local ofr, ofg, ofb = Geyser.Color.parse("white")
      local obr, obg, obb = Geyser.Color.parse(self.consoleColor)
      colorString = string.format("<%s,%s,%s:%s,%s,%s>", ofr, ofg, ofb, obr, obg, obb)
    end
    local timestamp = getTime(true, self.timestampFormat)
    local fullTimestamp = string.format("%s%s<r> ", colorString, timestamp)
    if not table.contains(self.timestampExceptions, tabName) then
      console:decho(fullTimestamp)
    end
    if allTab and tabName ~= self.allTabName and not table.contains(self.timestampExceptions, self.allTabName) then
      allTab:decho(fullTimestamp)
    end
  end
  console[linkType](console, unpack(arguments))
  if allTab then
    allTab[linkType](allTab, unpack(arguments))
  end
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
  self:validTabNameOrError(tabName, funcName)
  if not table.contains(self.allTabExclusions, tabName) then
    table.insert(self.allTabExclusions, tabName)
  end
end

--- removess a tab from the exclusion list for echoing to the allTab
-- @tparam string tabName the name of the tab to remove from the exclusion list
function EMCO:removeAllTabExclusion(tabName)
  local funcName = "EMCO:removeAllTabExclusion(tabName)"
  self:validTabNameOrError(tabName, funcName)
  local index = table.index_of(self.allTabExclusions, tabName)
  if index then
    table.remove(self.allTabExclusions, index)
  end
end

function EMCO:validTabNameOrError(tabName, funcName)
  local ae = self.ae
  local tabNameType = type(tabName)
  local validTabName = table.contains(self.consoles, tabName)
  if tabNameType ~= "string" then
    ae(funcName, "tabName as string expected, got " .. tabNameType)
  elseif not validTabName then
    ae(funcName, string.format("tabName %s does not exist in this EMCO. valid tabs: " .. table.concat(self.consoles, ",")))
  end
end

function EMCO:addTimestampException(tabName)
  local funcName = "EMCO:addTimestampException(tabName)"
  self:validTabNameOrError(tabName, funcName)
  if not table.contains(self.timestampExceptions, tabName) then
    table.insert(self.timestampExceptions, tabName)
  end
end

function EMCO:removeTimestampException(tabName)
  local funcName = "EMCO:removeTimestampTabException(tabName)"
  self:validTabNameOrError(tabName, funcName)
  local index = table.index_of(self.timestampExceptions, tabName)
  if index then
    table.remove(self.timestampExceptions, index)
  end
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
  for _, console in ipairs(self.consoles) do
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

--- Save an EMCO's configuration for reloading later. Filename is based on the EMCO's name property.
function EMCO:save()
  local configtable = {
    timestamp = self.timestamp,
    blankLine = self.blankLine,
    scrollbars = self.scrollbars,
    customTimestampColor = self.customTimestampColor,
    mapTab = self.mapTab,
    mapTabName = self.mapTabName,
    blinkFromAll = self.blinkFromAll,
    preserveBackground = self.preserveBackground,
    gag = self.gag,
    timestampFormat = self.timestampFormat,
    timestampFGColor = self.timestampFGColor,
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
    timestampExceptions = self.timestampExceptions,
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
    tabFontSize = self.tabFontSize,
    tabBold = self.tabBold,
    tabItalics = self.tabItalics,
    tabUnderline = self.tabUnderline,
    tabAlignment = self.tabAlignment,
    bufferSize = self.bufferSize,
    deleteLines = self.deleteLines,
    logExclusions = self.logExclusions,
    gags = self.gags,
    notifyTabs = self.notifyTabs,
    notifyWithFocus = self.notifyWithFocus,
    cmdLineStyleSheet = self.cmdLineStyleSheet,
  }
  local dirname = getMudletHomeDir() .. "/EMCO/"
  local filename = dirname .. self.name:gsub("[<>:'\"/\\|?*]", "_") .. ".lua"
  if not (io.exists(dirname)) then
    lfs.mkdir(dirname)
  end
  table.save(filename, configtable)
end

--- Load and apply a saved config for this EMCO
function EMCO:load()
  local dirname = getMudletHomeDir() .. "/EMCO/"
  local filename = dirname .. self.name .. ".lua"
  local configTable = {}
  if io.exists(filename) then
    table.load(filename, configTable)
  else
    debugc(string.format("Attempted to load config for EMCO named %s but the file could not be found. Filename: %s", self.name, filename))
    return
  end

  self.timestamp = configTable.timestamp
  self.blankLine = configTable.blankLine
  self.scrollbars = configTable.scrollbars
  self.customTimestampColor = configTable.customTimestampColor
  self.mapTab = configTable.mapTab
  self.mapTabName = configTable.mapTabName
  self.blinkFromAll = configTable.blinkFromAll
  self.preserveBackground = configTable.preserveBackground
  self.gag = configTable.gag
  self.timestampFormat = configTable.timestampFormat
  self.timestampFGColor = configTable.timestampFGColor
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
  self.timestampExceptions = configTable.timestampExceptions
  self.tabHeight = configTable.tabHeight
  self.wrapAt = configTable.wrapAt
  self.leftMargin = configTable.leftMargin
  self.rightMargin = configTable.rightMargin
  self.bottomMargin = configTable.bottomMargin
  self.topMargin = configTable.topMargin
  self.tabFontSize = configTable.tabFontSize
  self.tabBold = configTable.tabBold
  self.tabItalics = configTable.tabItalics
  self.tabUnderline = configTable.tabUnderline
  self.tabAlignment = configTable.tabAlignment
  self.bufferSize = configTable.bufferSize
  self.deleteLines = configTable.deleteLines
  self.logExclusions = configTable.logExclusions
  self.gags = configTable.gags
  self.notifyTabs = configTable.notifyTabs
  self.notifyWithFocus = configTable.notifyWithFocus
  self.cmdLineStyleSheet = configTable.cmdLineStyleSheet
  self:move(configTable.x, configTable.y)
  self:resize(configTable.width, configTable.height)
  self:reset()
  if configTable.fontSize then
    self:setFontSize(configTable.fontSize)
  end
  if configTable.font then
    self:setFont(configTable.font)
  end
  if configTable.tabFont then
    self:setTabFont(configTable.tabFont)
  end
  if configTable.autoWrap then
    self:enableAutoWrap()
  else
    self:disableAutoWrap()
  end
end

--- Enables logging for tabName
--@tparam string tabName the name of the tab you want to enable logging for
function EMCO:enableTabLogging(tabName)
  local console = self.mc[tabName]
  if not console then
    debugc(f"EMCO:enableTabLogging(tabName): tabName {tabName} not found.")
    return
  end
  console.log = true
  local logDisabled = table.index_of(self.logExclusions, tabName)
  if logDisabled then table.remove(self.logExclusions, logDisabled) end
end

--- Disables logging for tabName
--@tparam string tabName the name of the tab you want to disable logging for
function EMCO:disableTabLogging(tabName)
  local console = self.mc[tabName]
  if not console then
    debugc(f"EMCO:disableTabLogging(tabName): tabName {tabName} not found.")
    return
  end
  console.log = false
  local logDisabled = table.index_of(self.logExclusions, tabName)
  if not logDisabled then table.insert(self.logExclusions, tabName) end
end

--- Enables logging on all EMCO managed consoles
function EMCO:enableAllLogging()
  for _,console in pairs(self.mc) do
    console.log = true
  end
  self.logExclusions = {}
end

--- Disables logging on all EMCO managed consoles
function EMCO:disableAllLogging()
  self.logExclusions = {}
  for tabName,console in pairs(self.mc) do
    console.log = false
    self.logExclusions[#self.logExclusions+1] = tabName
  end
end

EMCO.parent = Geyser.Container

return EMCO
