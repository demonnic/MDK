--- Alias Manager
-- @classmod aliasmgr
-- @author Damian Monogue <demonnic@gmail.com>
-- @copyright 2022 Damian Monogue
-- @license MIT, see LICENSE.lua
local aliasmgr = {}
aliasmgr.__index = aliasmgr

--- Creates a new alias manager
function aliasmgr:new()
  local mgr = {
    aliases = {}
  }
  setmetatable(mgr, self)
  return mgr
end

local function argError(funcName, argument, expected, actual)
  local msg = string.format("%s: %s as %s expected, got %s", funcName, argument, expected, actual)
  printError(msg, true, true)
end

--- Registers an alias with the alias manager
-- @param name the name for the alias
-- @param regex the regular expression the alias matches against
-- @param func The code to run when the alias matches. Can wrap code in [[ ]] or pass an actual function
function aliasmgr:register(name, regex, func)
  local funcName = "aliasmgr:register(name, regex, func)"
  if func == nil then 
    printError(f"{funcName} takes 3 arguments and you have provided less than that", true, true)
  end
  local nameType = type(name)
  if nameType ~= "string" then
    argError(funcName, "name", "string", nameType)
  end
  local regexType = type(regex)
  if regexType ~= "string" then
    argError(funcName, "regex", "string", regexType)
  end
  local funcType = type(func)
  if funcType ~= "string" and funcType ~= "function" then
    argError(funcName, "func", "string or function", funcType)
  end
  local object = {
    regex = regex,
    func = func
  }
  self:kill(name)
  local ok, err = pcall(tempAlias, regex, func)
  if not ok then
    return nil, err
  end
  object.handlerID = err
  self.aliases[name] = object
  return true
end

--- Registers an alias with the alias manager. Alias for register
-- @param name the name for the alias
-- @param regex the regular expression the alias matches against
-- @param func The code to run when the alias matches. Can wrap code in [[ ]] or pass an actual function
-- @see register
function aliasmgr:add(name, regex, func)
  self:register(name, regex, func)
end

--- Disables an alias, but does not delete it so it can be enabled later without being redefined
-- @param name the name of the alias to disable
-- @return true if the alias exists and gets disabled, false if it does not exist or is already disabled
function aliasmgr:disable(name)
  local funcName = "aliasmgr:disable(name)"
  local nameType = type(name)
  if nameType ~= "string" then
    argError(funcName, "name", "string", nameType)
  end
  local object = self.aliases[name]
  if not object or object.handlerID == -1 then
    return false
  end
  killAlias(object.handlerID)
  object.handlerID = -1
  return true
end

--- Disables all aliases registered with the manager
function aliasmgr:disableAll()
  local aliases = self.aliases
  for name, object in pairs(aliases) do
    self:disable(name)
  end
end

--- Enables an alias by name
-- @param name the name of the alias to enable
-- @return true if the alias exists and was enabled, false if it does not exist. 
function aliasmgr:enable(name)
  local funcName = "aliasmgr:enable(name)"
  local nameType = type(name)
  if nameType ~= "string" then
    argError(funcName, "name", "string", nameType)
  end
  local object = self.aliases[name]
  if not object then
    return false
  end
  self:register(name, object.regex, object.func)
end

--- Enables all aliases registered with the manager
function aliasmgr:enableAll()
  local aliases = self.aliases
  for name,_ in pairs(aliases) do
    self:enable(name)
  end
  return true
end

--- Kill an alias, deleting it from the manager
-- @param name the name of the alias to kill
-- @return true if the alias exists and gets deleted, false if the alias does not exist
function aliasmgr:kill(name)
  local funcName = "aliasmgr:kill(name)"
  local nameType = type(name)
  if nameType ~= "string" then
    argError(funcName, "name", "string", nameType)
  end
  local object = self.aliases[name]
  if not object then
    return false
  end
  self:disable(name)
  self.aliases[name] = nil
  return true
end

--- Kills all aliases registered with the manager, clearing it out
function aliasmgr:killAll()
  local aliases = self.aliases
  for name, _ in pairs(aliases) do
    self:kill(name)
  end
end

--- Kills an alias, deleting it from the manager
-- @param name the name of the alias to delete
-- @return true if the alias exists and gets deleted, false if the alias does not exist
-- @see kill
function aliasmgr:delete(name)
  return self:kill(name)
end

--- Kills all aliases, deleting them from the manager
-- @see killAll
function aliasmgr:deleteAll()
  return self:killAll()
end

--- Returns the list of aliases and the information being tracked for them
-- @return the table of alias information, with names as keys and a table of information as the values.
function aliasmgr:getAliases()
  return self.aliases
end

return aliasmgr