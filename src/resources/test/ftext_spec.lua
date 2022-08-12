local ftext = require("MDK.ftext")

describe("ftext:", function()
  describe("ftext.fText:", function()
    local fText = ftext.fText

    it("Should properly center text", function()
      local expected = "     some text      "
      local actual = fText("some text", {width = 20})
      assert.equals(expected, actual)
      assert.equals(20, actual:len())
    end)

    it("Should properly pad left aligned text", function()
      local expected = "some text           "
      local actual = fText("some text", {width = 20, alignment = "left"})
      assert.equals(expected, actual)
      assert.equals(20, actual:len())
    end)

    it("Should properly pad right aligned text", function()
      local expected = "           some text"
      local actual = fText("some text", {width = 20, alignment = "right"})
      assert.equals(expected, actual)
      assert.equals(20, actual:len())
    end)

    it("Should wrap lines to the correct length", function()
      local str = "This is a test of the emergency broadcast system. This is only a test"
      local options = {width = 10, alignment = "centered"}
      local actual = fText(str, options)
      for _, line in ipairs(actual:split("\n")) do
        assert.equals(line:len(), 10)
      end
      options.width = 15
      actual = fText(str, options)
      for _, line in ipairs(actual:split("\n")) do
        assert.equals(line:len(), 15)
      end
    end)

    describe("non-space spacer character:", function()
      local str = "some text"
      local options = {width = "20", alignment = "left", spacer = "="}
      it("Should work with left align", function()
        local expected = "some text =========="
        local actual = fText(str, options)
        assert.equals(expected, actual)
        assert.equals(20, actual:len())
      end)

      it("Should work with right align", function()
        local expected = "========== some text"
        options.alignment = "right"
        local actual = fText(str, options)
        assert.equals(expected, actual)
        assert.equals(20, actual:len())
      end)

      it("Should work with center align", function()
        local expected = ("==== some text =====")
        options.alignment = "center"
        local actual = fText(str, options)
        assert.equals(expected, actual)
        assert.equals(20, actual:len())
      end)
    end)

    describe("nogap option:", function()
      local str = "some text"
      local options = {width = "20", alignment = "left", spacer = "=", nogap = true}

      it("Should work with left align", function()
        local expected = "some text==========="
        local actual = fText(str, options)
        assert.equals(expected, actual)
        assert.equals(20, actual:len())
      end)

      it("Should work with right align", function()
        local expected = "===========some text"
        options.alignment = "right"
        local actual = fText(str, options)
        assert.equals(expected, actual)
        assert.equals(20, actual:len())
      end)

      it("Should work with center align", function()
        local expected = "=====some text======"
        options.alignment = "center"
        local actual = fText(str, options)
        assert.equals(expected, actual)
        assert.equals(20, actual:len())
      end)
    end)

    describe("cap functionality", function()
      local str = "some text"
      local options = {width = 20, spacer = "=", cap = "|"}

      it("Should place the spacer outside the cap by default", function()
        local expected = "===| some text |===="
        local actual = fText(str, options)
        assert.equals(expected, actual)
        assert.equals(20, actual:len())
      end)

      it("Should place it inside the cap if inside option is true", function()
        local expected = "|=== some text ====|"
        options.inside = true
        local actual = fText(str, options)
        options.inside = nil
        assert.equals(expected, actual)
        assert.equals(20, actual:len())
      end)

      it("Should mirror certain characters with their opposites", function()
        local expected = "===[ some text ]===="
        options.mirror = true
        options.cap = "["
        local actual = fText(str, options)
        assert.equals(expected, actual)
        options.inside = true
        expected = "[=== some text ====]"
        actual = fText(str, options)
        assert.equals(expected, actual)
        options.inside = nil
        options.cap = "<"
        expected = "===< some text >===="
        actual = fText(str, options)
        assert.equals(expected, actual)
        options.cap = "{"
        expected = "==={ some text }===="
        actual = fText(str, options)
        assert.equals(expected, actual)
        options.cap = "("
        expected = "===( some text )===="
        actual = fText(str, options)
        assert.equals(expected, actual)
        options.cap = "|"
        expected = "===| some text |===="
        actual = fText(str, options)
        assert.equals(expected, actual)
      end)
    end)
  end)

  describe("ftext.cfText", function()
    local cfText = ftext.cfText
    local str = "some text"
    local options = {
      width = 20,
      spacer = "=",
      cap = "[",
      inside = true,
      mirror = true,
      capColor = "<purple>",
      spacerColor = "<green>",
      textColor = "<red>",
    }
    it("Should handle cecho colored text", function()
      local expectedStripped = "[=== some text ====]"
      local expected = "<purple>[<reset><green>===<reset><red> some text <reset><green>====<reset><purple>]<reset>"
      local actual = cfText(str, options)
      local actualStripped = cecho2string(actual)
      assert.equals(expected, actual)
      assert.equals(expectedStripped, actualStripped)
      assert.equals(20, actualStripped:len())
      expectedStripped = "===[ some text ]===="
      expected = "<green>===<reset><purple>[<reset><red> some text <reset><purple>]<reset><green>====<reset>"
      options.inside = false
      actual = cfText(str, options)
      actualStripped = cecho2string(actual)
      assert.equals(expected, actual)
      assert.equals(expectedStripped, actualStripped)
      assert.equals(20, actualStripped:len())
    end)

    it("Should wrap cecho lines to the correct length", function()
      local str = "This is a test of the emergency broadcast system. This is only a test"
      local options = {width = 10, alignment = "centered"}
      local actual = cfText(str, options)
      for _, line in ipairs(actual:split("\n")) do
        assert.equals(cecho2string(line):len(), 10)
      end
      options.width = 15
      actual = cfText(str, options)
      for _, line in ipairs(actual:split("\n")) do
        assert.equals(cecho2string(line):len(), 15)
      end
    end)

  end)

  describe("ftext.dfText", function()
    local dfText = ftext.dfText
    local str = "some text"
    local options = {
      width = 20,
      spacer = "=",
      cap = "[",
      inside = true,
      mirror = true,
      capColor = "<160,32,240>",
      spacerColor = "<0,255,0>",
      textColor = "<255,0,0>",
    }
    it("Should handle decho colored text", function()
      local expectedStripped = "[=== some text ====]"
      local expected = "<160,32,240>[<r><0,255,0>===<r><255,0,0> some text <r><0,255,0>====<r><160,32,240>]<r>"
      local actual = dfText(str, options)
      local actualStripped = decho2string(actual)
      assert.equals(expected, actual)
      assert.equals(expectedStripped, actualStripped)
      assert.equals(20, actualStripped:len())
      expectedStripped = "===[ some text ]===="
      expected = "<0,255,0>===<r><160,32,240>[<r><255,0,0> some text <r><160,32,240>]<r><0,255,0>====<r>"
      options.inside = false
      actual = dfText(str, options)
      actualStripped = decho2string(actual)
      assert.equals(expected, actual)
      assert.equals(expectedStripped, actualStripped)
      assert.equals(20, actualStripped:len())
    end)

    it("Should wrap decho lines to the correct length", function()
      local str = "This is a test of the emergency broadcast system. This is only a test"
      local options = {width = 10, alignment = "centered"}
      local actual = dfText(str, options)
      for _, line in ipairs(actual:split("\n")) do
        assert.equals(decho2string(line):len(), 10)
      end
      options.width = 15
      actual = dfText(str, options)
      for _, line in ipairs(actual:split("\n")) do
        assert.equals(decho2string(line):len(), 15)
      end
    end)
  end)

  describe("ftext.hfText", function()
    local hfText = ftext.hfText
    local str = "some text"
    local options = {
      width = 20,
      spacer = "=",
      cap = "[",
      inside = true,
      mirror = true,
      capColor = "#a020f0",
      spacerColor = "#00ff00",
      textColor = "#ff0000",
    }
    it("Should handle hecho colored text", function()
      local expectedStripped = "[=== some text ====]"
      local expected = "#a020f0[#r#00ff00===#r#ff0000 some text #r#00ff00====#r#a020f0]#r"
      local actual = hfText(str, options)
      local actualStripped = hecho2string(actual)
      assert.equals(expected, actual)
      assert.equals(expectedStripped, actualStripped)
      assert.equals(20, actualStripped:len())
      expectedStripped = "===[ some text ]===="
      expected = "#00ff00===#r#a020f0[#r#ff0000 some text #r#a020f0]#r#00ff00====#r"
      options.inside = false
      actual = hfText(str, options)
      actualStripped = hecho2string(actual)
      assert.equals(expected, actual)
      assert.equals(expectedStripped, actualStripped)
      assert.equals(20, actualStripped:len())
    end)

    it("Should wrap hecho lines to the correct length", function()
      local str = "This is a test of the emergency broadcast system. This is only a test"
      local options = {width = 10, alignment = "centered"}
      local actual = hfText(str, options)
      for _, line in ipairs(actual:split("\n")) do
        assert.equals(hecho2string(line):len(), 10)
      end
      options.width = 15
      actual = hfText(str, options)
      for _, line in ipairs(actual:split("\n")) do
        assert.equals(hecho2string(line):len(), 15)
      end
    end)
  end)

  describe("ftext.TextFormatter", function()
    local tf = ftext.TextFormatter
    local str = "some text"
    local formatter

    before_each(function()
      formatter = tf:new({width = 20})
    end)

    it("Should let you change width using :setWidth", function()
      formatter:setWidth(80)
      local expected =
        "<white><reset><white>                                  <reset><white> some text <reset><white>                                   <reset><white><reset>"
      local actual = formatter:format(str)
      assert.equals(expected, actual)
      assert.equals(80, cecho2string(actual):len())
    end)

    it("Should format for cecho by default", function()
      local expected = "<white><reset><white>    <reset><white> some text <reset><white>     <reset><white><reset>"
      local expectedStripped = "     some text      "
      local actual = formatter:format(str)
      local actualStripped = cecho2string(actual)
      assert.equals(expected, actual)
      assert.equals(expectedStripped, actualStripped)
      assert.equals(20, actualStripped:len())
    end)

    it("Should produce the same line as cfText given the same options", function()
      local expected = ftext.cfText(str, formatter.options)
      local actual = formatter:format(str)
      assert.equals(expected, actual)
    end)

    it("Should let you change type using :setType", function()
      formatter:setType("h")
      local expected = ftext.hfText(str, formatter.options)
      local actual = formatter:format(str)
      assert.equals(expected, actual)
      formatter:setType("d")
      expected = ftext.dfText(str, formatter.options)
      actual = formatter:format(str)
      assert.equals(expected, actual)
      formatter:setType("")
      expected = ftext.fText(str, formatter.options)
      actual = formatter:format(str)
      assert.equals(expected, actual)
    end)

    it("Should default to word wrapping, and let you change it with :setWrap", function()
      formatter:setWidth(10)
      local expected =
        "<white><reset><white>  <reset><white> some <reset><white>  <reset><white><reset>\n<white><reset><white>  <reset><white> text <reset><white>  <reset><white><reset>"
      local actual = formatter:format(str)
      assert.equals(expected, actual)
      expected = "<white><reset><white><reset><white> some text <reset><white><reset><white><reset>"
      formatter:setWrap(false)
      actual = formatter:format(str)
      assert.equals(expected, actual)
    end)

    it("Should allow you to change the cap using :setCap", function()
      formatter:setCap('|')
      local expected = "<white>|<reset><white>   <reset><white> some text <reset><white>    <reset><white>|<reset>"
      local actual = formatter:format(str)
      assert.equals(expected, actual)
    end)

    it("Should allow you to change the capColor using :setCapColor", function()
      formatter:setCapColor('<red>')
      local expected = "<red><reset><white>    <reset><white> some text <reset><white>     <reset><red><reset>"
      local actual = formatter:format(str)
      assert.equals(expected, actual)
    end)

    it("Should allow you to change the spacer color using :setSpacerColor", function()
      formatter:setSpacerColor("<red>")
      local expected = "<white><reset><red>    <reset><white> some text <reset><red>     <reset><white><reset>"
      local actual = formatter:format(str)
      assert.equals(expected, actual)
    end)

    it("Should allow you to change the text color using :setTextColor", function()
      formatter:setTextColor("<red>")
      local expected = "<white><reset><white>    <reset><red> some text <reset><white>     <reset><white><reset>"
      local actual = formatter:format(str)
      assert.equals(expected, actual)
    end)

    it("Should allow you to change the spacer using :setSpacer", function()
      formatter:setSpacer("=")
      -- local expected = "<white><reset><white>    <reset><white> some text <reset><white>     <reset><white><reset>"
      local expected = "<white><reset><white>====<reset><white> some text <reset><white>=====<reset><white><reset>"
      local actual = formatter:format(str)
      assert.equals(expected, actual)
    end)

    it("Should allow you to set the alignment using :setAlignment", function()
      formatter:setAlignment("left")
      local expected = "<white><reset><white><reset><white>some text <reset><white>          <reset><white><reset>"
      local actual = formatter:format(str)
      assert.equals(expected, actual)
      formatter:setAlignment("right")
      expected = "<white><reset><white>          <reset><white> some text<reset><white><reset><white><reset>"
      actual = formatter:format(str)
      assert.equals(expected, actual)
    end)

    it("Should allow you to change the 'inside' option using :setInside", function()
      formatter:setInside(false)
      local expected = "<white>    <reset><white><reset><white> some text <reset><white><reset><white>     <reset>"
      local actual = formatter:format(str)
      assert.equals(expected, actual)
    end)

    it("Should allow you to change the mirror option using :setMirror", function()
      formatter:setCap('<')
      formatter:setMirror(true)
      local expected = "<white><<reset><white>   <reset><white> some text <reset><white>    <reset><white>><reset>"
      local actual = formatter:format(str)
      assert.equal(expected, actual)
    end)
  end)

  describe("ftext.TableMaker", function()
    local TableMaker = ftext.TableMaker
    local tm
    before_each(function()
      tm = TableMaker:new()
      tm:addColumn({name = "col1", width = 15, textColor = "<red>"})
      tm:addColumn({name = "col2", width = 15, textColor = "<blue>"})
      tm:addColumn({name = "col3", width = 15, textColor = "<green>"})
      tm:addRow({"some text", "more text", "other text"})
      tm:addRow({"little text", "bigger text", "text"})
    end)

    it("Should assemble a formatted table given default options", function()
      local expected = [[<white>*************************************************<reset>
<white>*<reset><white><reset><white>    <reset><red> col1 <reset><white>     <reset><white><reset><white>|<reset><white><reset><white>    <reset><blue> col2 <reset><white>     <reset><white><reset><white>|<reset><white><reset><white>    <reset><green> col3 <reset><white>     <reset><white><reset><white>*<reset>
<white>*<reset><white>---------------<reset><white>|<reset><white>---------------<reset><white>|<reset><white>---------------<reset><white>*<reset>
<white>*<reset><white><reset><white>  <reset><red> some text <reset><white>  <reset><white><reset><white>|<reset><white><reset><white>  <reset><blue> more text <reset><white>  <reset><white><reset><white>|<reset><white><reset><white> <reset><green> other text <reset><white>  <reset><white><reset><white>*<reset>
<white>*<reset><white>---------------<reset><white>|<reset><white>---------------<reset><white>|<reset><white>---------------<reset><white>*<reset>
<white>*<reset><white><reset><white> <reset><red> little text <reset><white> <reset><white><reset><white>|<reset><white><reset><white> <reset><blue> bigger text <reset><white> <reset><white><reset><white>|<reset><white><reset><white>    <reset><green> text <reset><white>     <reset><white><reset><white>*<reset>
<white>*************************************************<reset>
]]
      local actual = tm:assemble()
      assert.equals(expected, actual)
    end)

    it("TableMaker:getCell should return the text and formatter for a specific cell", function()
      local expectedText = "more text"
      local expectedFormatter = tm.columns[2]
      local actualText, actualFormatter = tm:getCell(1, 2)
      assert.equals(expectedText, actualText)
      assert.equals(expectedFormatter, actualFormatter)
      local expectedFormatted = "<white><reset><white>  <reset><blue> more text <reset><white>  <reset><white><reset>"
      local actualFormatted = actualFormatter:format(actualText)
      assert.equals(expectedFormatted, actualFormatted)
    end)
  end)
end)
