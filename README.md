# the demonnic MDK and You

This is a collection of lua modules I wrote which you can include in your Mudlet package. If your package is called MyPackage, and the files it installs with it live in `getMudletHomeDir() .. "/MyPackage"`, and ftext.lua is in that base MyPackage directory, then you can include ftext by simply doing
```lua
local fText = require("MyPackage.ftext")
```

# documentation

Starting with alpha2 of the MDK, I will be including the ldocs I generate from my code in the zipped releases. The current release's ldocs can always be viewed at https://demonnic.github.io/mdk/current/

# list of files
These files contain the modules in the MDK. You only need to include those files which you intend to use, except as noted in the descriptions below. If you include any of the modules from the MDK, you should also include LICENSE.lua. It contains the licenses for my modules and for luaunit and lua-schema which are not my original works.

* EMCO.lua
  * EMCO. Documentation at https://github.com/demonnic/EMCO/wiki

* gradientmaker.lua
  * Functions for creating color gradients for use with c/d/hecho. Documentation at https://github.com/demonnic/MDK/wiki/gradientmaker

* ftext.lua
  * basic fText. Documentation at https://github.com/demonnic/fText/wiki

* textformatter.lua
  * TextFormatter, a reusable fText object. Must have ftext.lua in the same directory. Documentation at https://github.com/demonnic/fText/wiki/TextFormatter

* tablemaker.lua
  * TableMaker, creates formatted tables out of monospace text. Must have textformatter.lua and ftext.lua in the same directory. Documentation at https://github.com/demonnic/fText/wiki/TableMaker

* TextGauges.lua
  * TextGauges, what it says on the tin. Documentation at https://github.com/demonnic/TextGauges/wiki

* timergauge.lua
  * TimerGauge, an extension of Geyser.Gauge which serves as an animated countdown timer. Overview at https://github.com/demonnic/MDK/wiki/TimerGauge

* sortbox.lua
  * SortBox, an alternative to H/VBox which can be either, and also provides options for sorting its contents. Overview at https://github.com/demonnic/MDK/wiki/SortBox

* luaunit.lua
  * LuaUnit, for writing unit tests for your packages. Modified slightly for use with Mudlet. Documentation at https://github.com/bluebird75/luaunit

* schema.lua
  * lua-schema, for defining table schema. Documentation at https://github.com/sschoener/lua-schema

* LICENSE.lua
  * Contains the license information for MDK, as well as lua-schema and luaunit which have been included.
