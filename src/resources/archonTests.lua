local pathOfThisFile = (...):match("(.-)[^%.]+$")
local lu = require(pathOfThisFile .. "luaunit")
local Archon = require(pathOfThisFile .. "archon")
lu.ORDER_ACTUAL_EXPECTED=false
local assertEquals = lu.assertEquals
local assertNil = lu.assertNil
local assertIs = lu.assertIs

function Archon.runTests()
  TestArchon = {}
  local ta = TestArchon

  function ta:test_getValueAt_returns_original_reference()
    super_long_funky_name_to_avoid_collisions = {
      this = "that",
      thing1 = "thing2",
      subtbl = {}
    }
    local expected = super_long_funky_name_to_avoid_collisions
    local actual = Archon.getValueAt("super_long_funky_name_to_avoid_collisions")
    assertIs(expected, actual)
    expected = super_long_funky_name_to_avoid_collisions.subtbl
    actual = Archon.getValueAt("super_long_funky_name_to_avoid_collisions.subtbl")
    assertIs(expected, actual)
    super_long_funky_name_to_avoid_collisions = nil
  end

  function ta:test_string_entry_minimum_entry_validation()
    local string_entry = {
      type = "string",
      displayName = "Test String"
    }
    local actual = Archon.verify_entry(string_entry)
    assertNil(actual)
  end

  function ta:test_string_full_entry_validation()
    local string_entry = {
      type = "string",
      displayName = "Test String",
      allowedValues = {"test", "production"},
      default = "test"
    }
    local actual = Archon.verify_entry(string_entry)
    assertNil(actual)
  end
  lu.LuaUnit.run('--pattern', 'Archon')
  TestArchon = nil
end
return Archon
