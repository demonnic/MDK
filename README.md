# the demonnic MDK and You

This is a collection of lua modules I wrote which you can include in your Mudlet package. If your package is called MyPackage, and the files it installs with it live in `getMudletHomeDir() .. "/MyPackage"`, and ftext.lua is in that base MyPackage directory, then you can include ftext by simply doing

```lua
local fText = require("MyPackage.ftext")
```

## documentation

Starting with alpha2 of the MDK, I will be including the ldocs I generate from my code in the zipped releases. The current release's ldocs can always be viewed at <https://demonnic.github.io/mdk/current/>

## list of files

These files contain the modules in the MDK. You only need to include those files which you intend to use, except as noted in the descriptions below. If you include any of the modules from the MDK, you should also include LICENSE.lua. It contains the licenses for my modules and for luaunit and lua-schema which are not my original works.
You should also include demontools.lua, as it notes below several other of the MDK modules make use of items within it.

* chyron.lua
  * Label which moves a message across its face from right to left, like a stock ticker or the news chyrons. Documentation at <https://github.com/demonnic/MDK/wiki/Chyron>

* demontools.lua
  * Collection of miscellaneous useful functions. You should include this file if you use the MDK, as several other modules make use of it. Include functions for converting c/d/hecho, html, and ansi colored strings between each other, mkdir_p, and some others. Documented at the API docs linked above.

* emco.lua
  * EMCO. Documentation at <https://github.com/demonnic/EMCO/wiki> Will make use of LoggingConsole if loggingconsole.lua and demontools.lua are included

* ftext.lua
  * basic fText. Documentation at <https://github.com/demonnic/fText/wiki>
  * now includes TextFormatter and TableMaker as ftext.TextFormatter and ftext.TableMaker

* gradientmaker.lua
  * Functions for creating color gradients for use with c/d/hecho. Documentation at <https://github.com/demonnic/MDK/wiki/gradientmaker>

* loggingconsole.lua
  * Self logging extension to the mini console. Works just like a Geyser.MiniConsole but adds a templated path and fileName constraint, as well as logFormat so it can log what is echod or appended to it. Requires demontools.lua in order to work.

* sortbox.lua
  * SortBox, an alternative to H/VBox which can be either, and also provides options for sorting its contents. Overview at <https://github.com/demonnic/MDK/wiki/SortBox>

* sug.lua
  * Self Updating Gauges, will watch a set of variables and update itself on a timer based on what values those variables hold. Documentation at <https://demonnic.github.io/mdk/current/classes/SUG.html>

* textgauge.lua
  * TextGauges, what it says on the tin. Documentation at <https://github.com/demonnic/TextGauges/wiki>

* timergauge.lua
  * TimerGauge, an extension of Geyser.Gauge which serves as an animated countdown timer. Overview at <https://github.com/demonnic/MDK/wiki/TimerGauge>

## Others people's work I depend upon

* luaunit.lua
  * LuaUnit, for writing unit tests for your packages. Modified slightly for use with Mudlet. Documentation at <https://github.com/bluebird75/luaunit>
  * Where I have been a good boy and written tests, this is what I've done it with.

* schema.lua
  * lua-schema, for defining table schema. Documentation at <https://github.com/sschoener/lua-schema>
  * will be used by Archon for ensuring configuration tables are as they should be.

* LICENSE.lua
  * Contains the license information for MDK, as well as lua-schema and luaunit which have been included.
