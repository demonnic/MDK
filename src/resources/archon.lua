local Archon = {
  name = "ArchonClass",
  formatType = "d",
  headCharacter = "*",
  footCharacter = "*",
  edgeCharacter = "*",
  frameColor = "white",
  rowSeparator = "-",
  separator = "|",
  separatorColor = "white",
  configDescription = {},
  location = "",
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
local valid_types = oneOf("string", "list", "int", "float", "map", "boolean")
local no_index_gaps = function(obj) return #obj == tsize(obj) end
local snogap = stest(no_index_gaps, "Table has noninteger keys or a gap in its indices, must be parseable using ipairs")
local slist = allOf(stbl, snogap)

local type_schema = {
  int = srec {
    type = "int",
    default = sint,
    min = sint,
    max = sint,
    step = sint,
    displayName = sstring
  },
  float = srec {
    type = "float",
    default = snum,
    min = snum,
    max = snum,
    step = snum,
    displayName = sstring
  },
  string = srec {
    type = "string",
    default = oneOf(snil,sstring),
    allowedValues = oneOf(snil, allOf(scol(sstring), slist)),
    displayName = sstring
  },
  map = srec {
    type = "map",
    default = stbl,
    displayName = sstring
  },
  list = srec {
    type = "list",
    default = oneOf(snil, slist),
    allowedTypes = oneOf(snil, scol(valid_types), valid_types),
    minSize = oneOf(snil, sint),
    displayName = sstring
  },
  boolean = srec {
    type = "boolean",
    default = oneOf(snil, sbool),
    displayName = sstring
  },
}
local function verify_entry(entry)
  local entry_type = entry.type
  if scs(entry_type, valid_types) then
    return "Entry is not a known type, please select from 'string', 'map', 'list', 'int', and 'float'. You provided: " .. entry_type
  end
  local err = scs(entry, type_schema[entry_type])
  if err then return sfo(err) end
end

function Archon.verify_entry(entry)
  local err = scs(entry, stbl)
  if err then return err end
  err = scs(entry.type, valid_types)
  if err then return err end
  return verify_entry(entry)
end

local function validate_config(config)
  local errors = {}
  for _,descriptor in pairs(config) do
    local err = Archon.verify_entry(descriptor)
    if err ~= nil then
      errors[#errors+1] = err
    end
  end
  if not table.is_empty(errors) then
    return table.concat(errors, "\n")
  end
  return nil
end

function Archon:checkConfig()
  return validate_config(self.config)
end

function Archon:getConfig()
  return Archon.getValueAt(self.location)
end

function Archon:load()
  local savedConfig = {}
  table.load(self.saveFile, savedConfig)
  local config = self:getConfig()
  if not config then 
    self:createDefaultConfig()
    config = self:getConfig()
  end
  table.update(config, savedConfig)
  Archon:verify()
end

function Archon:save()
  local config = self:getConfig()
  table.save(self.saveFile, config)
end

function Archon:verify()
end

local function digForValue(dataFrom, tableTo)
  if dataFrom == nil or table.size(tableTo) == 0 then
	  return dataFrom
	else
	  local newData = dataFrom[tableTo[1]]
		table.remove(tableTo, 1)
		return digForValue(newData, tableTo)
	end
end

function Archon.getValueAt(accessString)
  if accessString == "" then return nil end
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
