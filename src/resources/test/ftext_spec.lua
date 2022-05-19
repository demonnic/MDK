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
      local options = {
        width = 10,
        alignment = "centered",
      }
      local actual = fText(str, options)
      for _,line in ipairs(actual:split("\n")) do
        assert.equals(line:len(), 10)
      end
      options.width = 15
      actual = fText(str, options)
      for _,line in ipairs(actual:split("\n")) do
        assert.equals(line:len(), 15)
      end
    end)

    describe("non-space spacer character:", function()
      local str = "some text"
      local options = {
        width = "20",
        alignment = "left",
        spacer = "="
      }
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
      local options = {
        width = "20",
        alignment = "left",
        spacer = "=",
        nogap = true,
      }

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
      local options = {
        width = 20,
        spacer = "=",
        cap = "|",
      }

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
      textColor = "<red>"
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
    it("Should handle decho colored text", function()
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
  end)
end)