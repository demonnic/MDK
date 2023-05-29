# the demonnic MDK and You

This is a collection of Lua 'classes' and modules I wrote for Mudlet. It is largely targeted at scripters, and comes packaged in two ways depending on how you intend to use/distribute your work. Please see [Installation](#installation) for more details

## Documentation

The [MDK wiki](https://github.com/demonnic/MDK/wiki) contains an entry for each module or class, as well as examples.

Starting with alpha2 of the MDK, the ldocs generated from code are included in the zipped releases. The current release's ldocs can always be viewed at <https://demonnic.github.io/mdk/current/>

## Installation

How you 'install' the MDK depends on how you intend to use it.

### I just want to install the MDK for my own personal use

You just want to get your hands on the goods, and aren't looking to use any MDK items in an exported package for sharing or anything like that.
Well, you are who the mdk mpackage is for! Download the MDK.mpackage from your desired release on the [Releases](https://github.com/demonnic/MDK/releases) page and install it in the package manager. The examples in the [wiki](https://demonnic.github.io/mdk/current/) are written with this in mind, and you would require the items you need as `local EMCO = require("MDK.emco")`

### I am a package author looking to include/use one of the MDK modules or classes in my package

You should download the `demonnic-MDK-<version>.zip` file for your desired release on the [Releases](https://github.com/demonnic/MDK/releases) page.
Inside are the individual .lua files for the modules and classes described in the [wiki](https://demonnic.github.io/mdk/current/) and [API docs](https://demonnic.github.io/mdk/current/).
You can include all of them if you wish, or only the ones you actually make use of. I ask that you include the LICENSE.lua or LICENSE-MDK.lua file (depending on the release) file in addition.
They should go in the root of your package, so that when your package is installed the files can be found at `getMudletHomeDir() .. "/<packagename>/emco.lua"`. You would then use `local EMCO = require("<mypackagename>.emco")`
So for example if your package name is "MySuperCoolPackage" and it installs to `getMudletHomeDir() .. "/MySuperCoolPackage/"` then you use `local EMCO = require("MySuperCoolPackage.emco")` and the emco.lua file should be at `getMudletHomeDir() .. "/MySuperCoolPackage/emco.lua"`

## Files (Modules/Classes)

These files contain the modules in the MDK. You only need to include those files which you intend to use, except as noted in the descriptions below.
If you include any of the modules from the MDK, you should also include LICENSE.lua or LICENSE-MDK.lua. It contains the licenses for my modules and for luaunit and lua-schema which are not my original works.
You should maybe also include demontools.lua, as it notes below several other of the MDK modules make use of items within it.

* aliasmgr.ua
  * Object to manage tempAliases programmatically. <https://github.com/demonnic/MDK/wiki/AliasMgr>
  
* chyron.lua
  * Label which moves a message across its face from right to left, like a stock ticker or the news chyrons. Documentation at <https://github.com/demonnic/MDK/wiki/Chyron>

* demontools.lua
  * Collection of miscellaneous useful functions. You should include this file if you use the MDK, as several other modules make use of it. Include functions for converting c/d/hecho, html, and ansi colored strings between each other, mkdir_p, and some others. <https://github.com/demonnic/MDK/wiki/DemonTools>

* emco.lua
  * EMCO. Documentation at <https://github.com/demonnic/MDK/wiki/EMCO> Will make use of LoggingConsole if loggingconsole.lua and demontools.lua are included

* figlet.lua
  * Creates FIGlets from strings
  * Reference package with multiple fonts and color gradients at <https://github.com/demonnic/figinator>

* ftext.lua
  * basic fText. Documentation at <https://github.com/demonnic/MDK/wiki/fText>
  * now includes TextFormatter and TableMaker as ftext.TextFormatter and ftext.TableMaker

* gradientmaker.lua
  * Functions for creating color gradients for use with c/d/hecho. Documentation at <https://github.com/demonnic/MDK/wiki/GradientMaker>

* loggingconsole.lua
  * Self logging extension to the mini console. Works just like a Geyser.MiniConsole but adds a templated path and fileName constraint, as well as logFormat so it can log what is echod or appended to it. Requires demontools.lua in order to work.

* loginator.lua
  * Creates objects for logging messages to disk. <https://github.com/demonnic/MDK/wiki/Loginator>

* mastermindsolver.lua
  * A class which will help you solve Master Mind puzzles. <https://github.com/demonnic/MDK/wiki/MasterMindSolver>

* revisionator.lua
  * A class which aims to make upgrading between package versions easier by storing and running patch functions. <https://github.com/demonnic/MDK/wiki/Revisionator>

* sortbox.lua
  * SortBox, an alternative to H/VBox which can be either, and also provides options for sorting its contents. Overview at <https://github.com/demonnic/MDK/wiki/SortBox>

* spinbox.lua
  * SpinBox, a Geyser element for adjusting numbers with your mouse. Overview at <https://github.com/demonnic/MDK/wiki/SpinBox>

* sug.lua
  * Self Updating Gauges, will watch a set of variables and update itself on a timer based on what values those variables hold. Documentation at <https://github.com/demonnic/MDK/wiki/SelfUpdatingGauge>

* textgauge.lua
  * TextGauges, what it says on the tin. Documentation at <https://github.com/demonnic/MDK/wiki/TextGauge>

* timergauge.lua
  * TimerGauge, an extension of Geyser.Gauge which serves as an animated countdown timer. Overview at <https://github.com/demonnic/MDK/wiki/TimerGauge>

## Others people's work I depend upon

* schema.lua
  * lua-schema, for defining table schema. Documentation at <https://github.com/sschoener/lua-schema>
  * will be used by Archon for ensuring configuration tables are as they should be.

* LICENSE.lua
  * Contains the license information for MDK, as well as lua-schema and luaunit which have been included.
