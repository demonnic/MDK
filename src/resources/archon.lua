local Archon = {
  formatType = "d",
  headCharacter = "*",
  footCharacter = "*",
  edgeCharacter = "*",
  frameColor = "white",
  rowSeparator = "-",
  separator = "|",
  separatorColor = "white",
  configOptions = {},
}

local pathOfThisFile = (...):match("(.-)[^%.]+$")
local s = require(pathOfThisFile .. "schema")
local sint = s.Integer
local sstring = s.String
local snum = s.Number
local sbool = s.Boolean
local scol = s.Collection
local snil = s.Nil
local srec = s.Record
local oneOf = s.OneOf
local allOf = s.AllOf
local scs = s.CheckSchema
local sfo = s.FormatOutput
local stbl = s.Table
local tsize = table.size
local stest = s.Test
local valid_types =oneOf("string", "list", "int", "float", "map", "boolean")
local no_index_gaps = function(obj) return #obj == tsize(obj) end
local snogap = stest(no_index_gaps, "Table has noninteger keys or a gap in its indices, must be parseable using ipairs")
local slist = allOf(stbl, snogap)

local type_int_schema = srec {
  type = "int",
  default = sint,
  min = sint,
  max = sint,
  step = sint,
  displayName = sstring
}

local type_float_schema = srec {
  type = "float",
  default = snum,
  min = snum,
  max = snum,
  step = snum,
  displayName = sstring
}

local type_string_schema = srec {
  type = "string",
  default = oneOf(snil,sstring),
  allowedValues = oneOf(snil, allOf(scol(sstring), slist)),
  displayName = sstring
}

local type_map_schema = srec {
  type = "map",
  default = stbl,
  displayName = sstring
}

local type_list_schema = srec {
  type = "list",
  default = oneOf(snil, slist),
  allowedTypes = oneOf(snil, scol(valid_types), valid_types),
  minSize = oneOf(snil, sint),
  displayName = sstring
}

local type_boolean_schema = srec {
  type = "boolean",
  default = oneOf(snil, sbool),
  displayName = sstring
}

local function verify_string_entry(entry)
  local err = scs(entry, type_string_schema)
  if err then return sfo(err) end
end

local function verify_map_entry(entry)
  local err = scs(entry, type_map_schema)
  if err then return sfo(err) end
end

local function verify_list_entry(entry)
  local err = scs(entry, type_list_schema)
  if err then return sfo(err) end
end

local function verify_int_entry(entry)
  local err = scs(entry, type_int_schema)
  if err then return sfo(err) end
end

local function verify_float_entry(entry)
  local err = scs(entry, type_float_schema)
  if err then return sfo(err) end
end

local function verify_boolean_entry(entry)
  local err = scs(entry, type_boolean_schema)
  if err then return sfo(err) end
end

local function verify_entry(entry)
  local entry_type = entry.type
  if entry_type == "string" then
    return verify_string_entry(entry)
  elseif entry_type == "map" then
    return verify_map_entry(entry)
  elseif entry_type == "list" then
    return verify_list_entry(entry)
  elseif entry_type == "int" then
    return verify_int_entry(entry)
  elseif entry_type == "float" then
    return verify_float_entry(entry)
  elseif entry_type == "boolean" then
    return verify_boolean_entry(entry)
  else
    return "Entry is not a known type, please select from 'string', 'map', 'list', 'int', and 'float'"
  end
end

function Archon.verify_entry(entry)
  local err = scs(entry, stbl)
  if err then return err end
  err = scs(entry.type, valid_types)
  if err then return err end
  return verify_entry(entry)
end

local function digForValue(dataFrom, tableTo)
  if table.size(tableTo) == 0 then
	  return dataFrom
	else
	  local newData = dataFrom[tableTo[1]]
		table.remove(tableTo, 1)
		return digForValue(newData, tableTo)
	end
end

function Archon.getValueAt(accessString)
  local tempTable = accessString:split("%.")
	local accessTable = {}
	for i,v in ipairs(tempTable) do
	  if tonumber(v) then
	    accessTable[i] = tonumber(v)
		else
		  accessTable[i] = v
		end
	end
	return digForValue(_G, accessTable)
end

return Archon
