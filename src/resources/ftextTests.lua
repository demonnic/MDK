local pathOfThisFile = (...):match("(.-)[^%.]+$")
local lum = require(pathOfThisFile .. "luaunit")
local assertEquals = lum.assertEquals
local ftext = require(pathOfThisFile .. "ftext")
local fText = ftext.fText

function ftext.testFtext()
  TestFText = {}

  function TestFText:test_ftext_width_20_centered()
    local expected = "     some text      "
    local actual = fText("some text", {width = 20})
    assertEquals(actual, expected)
    assertEquals(string.len(actual), 20)
  end

  function TestFText:test_ftext_width_20_left()
    local expected = "some text           "
    local actual = fText("some text", {width = 20, alignment = "left"})
    assertEquals(actual, expected)
    assertEquals(string.len(actual), 20)
  end

  function TestFText:test_ftext_width_20_right()
    local expected = "           some text"
    local actual = fText("some text", {width = 20, alignment = "right"})
    assertEquals(actual, expected)
    assertEquals(string.len(actual), 20)
  end

  function TestFText:test_ftext_wrap_width_10_centered()
    local str = "This is a test of the emergency broadcast system"
    local actual = fText(str, {width = 10, alignment = "centered"})
    for _,line in ipairs(actual:split("\n")) do
      assertEquals(line:len(), 10)
    end
  end

  function TestFText:test_ftext_left_align_nonspace_spacer()
    local str = "some text"
    local expected = "some text =========="
    local actual = fText(str, {width = 20, alignment = "left", spacer = "="})
    assertEquals(actual, expected)
  end

  function TestFText:test_ftext_left_align_nonspace_spacer_nogap()
    local str = "some text"
    local expected = "some text==========="
    local actual = fText(str, {width = 20, alignment = "left", spacer = "=", nogap = true})
    assertEquals(actual, expected)
  end

  function TestFText:test_ftext_right_align_nonspace_spacer()
    local str = "some text"
    local expected = "========== some text"
    local actual = fText(str, {width = 20, alignment = "right", spacer = "="})
    assertEquals(actual, expected)
  end

  function TestFText:test_ftext_right_align_nonspace_spacer_nogap()
    local str = "some text"
    local expected = "===========some text"
    local actual = fText(str, {width = 20, alignment = "right", spacer = "=", nogap = true})
    assertEquals(actual, expected)
  end

  function TestFText:test_ftext_center_align_nonspace_spacer()
    local expected = "==== some text ====="
    local actual = fText("some text", {width = 20, spacer = "="})
    assertEquals(actual, expected)
    assertEquals(string.len(actual), 20)
  end

  function TestFText:test_ftext_center_align_nonspace_spacer_nogap()
    local expected = "=====some text======"
    local actual = fText("some text", {width = 20, spacer = "=", nogap = true})
    assertEquals(actual, expected)
    assertEquals(string.len(actual), 20)
  end

  function TestFText:test_ftext_center_align_nonspace_spacer_pipe_cap()
    local expected = "===| some text |===="
    local actual = fText("some text", {width = 20, spacer = "=", cap = "|"})
    assertEquals(actual, expected)
    assertEquals(string.len(actual), 20)
  end

  function TestFText:test_ftext_center_align_nonspace_spacer_pipe_cap_inside()
    local expected = "|=== some text ====|"
    local actual = fText("some text", {width = 20, spacer = "=", cap = "|", inside = true})
    assertEquals(actual, expected)
    assertEquals(string.len(actual), 20)
  end

  function TestFText:test_ftext_center_align_nonspace_spacer_lbracket_cap_inside()
    local expected = "[=== some text ====["
    local actual = fText("some text", {width = 20, spacer = "=", cap = "[", inside = true})
    assertEquals(actual, expected)
    assertEquals(string.len(actual), 20)
  end

  function TestFText:test_ftext_center_align_nonspace_spacer_lbracket_cap_inside_mirrored()
    local expected = "[=== some text ====]"
    local actual = fText("some text", {width = 20, spacer = "=", cap = "[", inside = true, mirror = true})
    assertEquals(actual, expected)
    assertEquals(string.len(actual), 20)
  end

  function TestFText:test_cftext_center_align_nonspace_spacer_lbracket_cap_inside_mirrored()
    local expectedStripped = "[=== some text ====]"
    local expected = "<purple>[<reset><green>===<reset><white> some text <reset><green>====<reset><purple>]<reset>"
    local actual = ftext.cfText("some text", {width = 20, spacer = "=", cap = "[", inside = true, mirror = true, capColor = "<purple>", spacerColor = "<green>"})
    local colorPattern = "<%w*_?%w*:?%w*_?%w*>"
    assertEquals(actual, expected)
    local stripped = actual:gsub(colorPattern, "")
    assertEquals(stripped, expectedStripped)
    assertEquals(string.len(stripped), 20)
  end

  function TestFText:test_cftext_center_align_nonspace_spacer_lbracket_cap_mirrored()
    local expectedStripped = "===[ some text ]===="
    local expected = "<green>===<reset><purple>[<reset><white> some text <reset><purple>]<reset><green>====<reset>"
    local actual = ftext.cfText("some text", {width = 20, spacer = "=", cap = "[", mirror = true, capColor = "<purple>", spacerColor = "<green>"})
    local colorPattern = "<%w*_?%w*:?%w*_?%w*>"
    assertEquals(actual, expected)
    local stripped = actual:gsub(colorPattern, "")
    assertEquals(stripped, expectedStripped)
    assertEquals(string.len(stripped), 20)
  end

  lum.LuaUnit.run('--pattern', 'FText')
  TestFText = nil
end

return ftext
