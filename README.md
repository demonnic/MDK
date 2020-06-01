# the demonnic MDK and You

This is a collection of lua modules I wrote which you can include in your Mudlet package. If your package is called MyPackage, and the files it installs with it live in `getMudletHomeDir() .. "/MyPackage"`, and ftext.lua is in that base MyPackage directory, then you can include ftext by simply doing
```lua
local fText = require("MyPackage.ftext")
```

# list of files
These files contain the modules in the MDK. You only need to include those files which you intend to use, except as noted in the descriptions below. If you include any of the modules from the MDK, you should also include LICENSE.lua. It contains the licenses for my modules and for luaunit and lua-schema which are not my original works.

* EMCO.lua
  * EMCO. Documentation at https://github.com/demonnic/EMCO/wiki

* ftext.lua
  * basic fText. Documentation at https://github.com/demonnic/fText/wiki

* textformatter.lua
  * TextFormatter, a reusable fText object. Must have ftext.lua in the same directory. Documentation at https://github.com/demonnic/fText/wiki/TextFormatter

* tablemaker.lua
  * TableMaker, creates formatted tables out of monospace text. Must have textformatter.lua and ftext.lua in the same directory. Documentation at https://github.com/demonnic/fText/wiki/TableMaker

* TextGauges.lua
  * TextGauges, what it says on the tin. Documentation at https://github.com/demonnic/TextGauges/wiki

* luaunit.lua
  * LuaUnit, for writing unit tests for your packages. Modified slightly for use with Mudlet. Documentation at https://github.com/bluebird75/luaunit

* schema.lua
  * lua-schema, for defining table schema. Documentation at https://github.com/sschoener/lua-schema

* LICENSE.lua
  * Contains the license information for MDK, as well as lua-schema and luaunit which have been included.
