MDKExample = MDKExample or { version = "1.0.3" }
function MDKExample.exampleFText()
  local fText = require("@PKGNAME@.ftext")
  cecho(fText.fText("Testing!", {width = 40, formatType = 'c', textColor = '<orange>', capColor = '<purple>', cap = '[TEST]'}))
end
function MDKExample.exampleEMCO()
  local EMCO = require("@PKGNAME@.EMCO")
  MDKExample.UW = Geyser.UserWindow:new({name = "TestWindow"})
  local stylesheet = [[background-color: rgb(0,180,0,255); border-width: 1px; border-style: solid; border-color: gold; border-radius: 10px;]]
  local istylesheet = [[background-color: rgb(60,60,60,255); border-width: 1px; border-style: solid; border-color: gold; border-radius: 10px;]]
  MDKExample.EMCO = EMCO:new({
    name = "MDKExampleEMCO",
    x = "0",
    y = "0",
    width = "100%",
    height = "100%",
    allTab = true,
    allTabName = "All",
    gap = 2,
    consoleColor = "black",
    consoles = {
      "Guild",
      "All",
      "Local",
      "Map",
    },
    mapTabName = "Map",
    mapTab = true,
    activeTabCSS = stylesheet,
    inactiveTabCSS = istylesheet,
    preserveBackground = true
  }, MDKExample.UW)
end
