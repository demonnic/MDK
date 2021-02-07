# Contributing

## I do accept pull requests

So please don't hesitate to open one if you've made an improvement or fixed a bug. That being said, it will be helpful to consider the following

* I include a .luaformatter file which I use for luaformatter. Using this before submitting your PR will help ensure style consistency. ish.
  * [Lua Formatter on github](https://github.com/Koihik/LuaFormatter)
  * [VSCode extension](https://github.com/Koihik/vscode-lua-format)
  * [vim plugin](https://github.com/andrejlevkovitch/vim-lua-format)
  * [Sublime plugin](https://github.com/Koihik/sublime-lua-format)
* I use [muddler](https://github.com/demonnic/muddler) for building the MDK mpackage
  * it would be nice if you made sure your changes muddle and work properly in mudlet
  * but if you don't want to install muddler, do at least test it in Mudlet
* I use ldoc for generating the API docs. It would be super sweet if anything you added was similarly documented, to save me the time
  * If you are so awesome as to do that, check out doc_table_template for an easy way to add tables to the ldoc. You can see it in use above most of the :new() functions.

## Do not be intimidated

It's just Lua code, afterall, and if you don't do any of the above I can do most of it pretty quickly, and show you how. =)
