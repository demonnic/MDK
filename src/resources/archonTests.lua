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

  function ta:test_string_full_entry_validation_failure()
    local string_entry = {
      type = "string",
      display = "Test String"
    }
    local expected = "Type mismatch: 'displayName' should be string, is nil\nSuperfluous value: 'display' does not appear in the record schema"
    local actual = Archon.verify_entry(string_entry)
    assertEquals(expected, actual)
  end

  function ta:test_config_validation_success()
    Archon.config = {
      name = {
        type = "string",
        displayName = "name",
        default = "Default"
      },
      queues = {
        type = "int",
        displayName = "queues",
        default = 2,
        min = 1,
        max = 4,
        step = 1
      },
      items = {
        type = "list",
        displayName = "items",
        allowedTypes = "string",
      },
    }
    assertNil(Archon:checkConfig())
  end

  function ta:test_config_validation_failure()
  end
  lu.LuaUnit.run('--pattern', 'Archon')
  TestArchon = nil
end
return Archon
