--- The revisionator provides a standardized way of migrating configurations between revisions
-- for instance, it will track what the currently applied revision number is, and when you tell
-- tell it to migrate, it will apply every individual migration between the currently applied 
-- revision and the latest/current revision. This should allow for more seamlessly moving from
-- an older version of a package to a new one.
-- @classmod revisionator
-- @author Damian Monogue <demonnic@gmail.com>
-- @copyright 2023
-- @license MIT, see https://raw.githubusercontent.com/demonnic/MDK/main/src/scripts/LICENSE.lua
local revisionator = {
  name = "Revisionator",
  patches = {},
}
revisionator.__index = revisionator
local dataDir = getMudletHomeDir() .. "/revisionator"
revisionator.dataDir = dataDir
if not io.exists(dataDir) then
  local ok,err = lfs.mkdir(dataDir)
  if not ok then
    printDebug(f"Error creating the directory for storing applied revisions: {err}", true)
  end
end

--- Creates a new revisionator
-- @tparam table options the options to create the revisionator with.
-- <table class="tg">
-- <thead>
--   <tr>
--     <th>option name</th>
--     <th>description</th>
--     <th>default</th>
--   </tr>
-- </thead>
-- <tbody>
--   <tr>
--     <td class="tg-1">name</td>
--     <td class="tg-1">The name of the revisionator. This is absolutely required, as the name is used for tracking the currently applied patch level</td>
--     <td class="tg-1">raises an error if not provided</td>
--   </tr>
--   <tr>
--     <td class="tg-2">patches</td>
--     <td class="tg-2">A table of patch functions. It is traversed using ipairs, so must be in the form of {function1, function2, function3} etc. If you do not provide it, you can add the patches by calling :addPatch for each patch in order.</td>
--     <td class="tg-2">{}</td>
--   </tr>
--</tbody>
--</table>
function revisionator:new(options)
  options = options or {}
  local optionsType = type(options)
  if optionsType ~= "table" then
    printError(f"revisionator:new bad argument #1 type, options as table expected, got {optionsType}", true, true)
  end
  if not options.name then
    printError("revisionator:new(options) options must include a 'name' key as this is used as part of tracking the applied patch level.", true, true)
  end
  local me = table.deepcopy(options)
  setmetatable(me, self)
  return me
end

--- Get the currently applied revision from file
--- @treturn[1] number the revision number currently applied, or 0 if it can't read a current version
--- @treturn[2] nil nil
--- @treturn[2] string error message
function revisionator:getAppliedPatch()
  local fileName = f"{self.dataDir}/{self.name}.txt"
  debugc(fileName)
  local revision = 0
  if io.exists(fileName) then
    local file = io.open(fileName, "r")
    local fileContents = file:read("*a")
    file:close()
    local revNumber = tonumber(fileContents)
    if revNumber then
      revision = revNumber
    else
      return nil, f"Error while attempting to read current patch version from file: {fileName}\nThe contents of the file are {fileContents} and it was unable to be converted to a revision number"
    end
  end
  return revision
end

--- go through all the patches in order and apply any which are still necessary
--- @treturn boolean true if it successfully applied patches, false if it was already at the latest patch level
--- @error error message
function revisionator:migrate()
  local applied,err = self:getAppliedPatch()
  if not applied then
    printError(err, true, true)
  end
  local patches = self.patches
  if applied >= #patches then
    return false
  end
  for revision, patch in ipairs(patches) do
    if applied < revision then
      local ok, err = pcall(patch)
      if not ok then
        self:setAppliedPatch(revision - 1)
        return nil, f"Error while running patch #{revision}: {err}"
      end
    end
  end
  self:setAppliedPatch(#patches)
  return true
end

--- add a patch to the table of patches
--- @tparam function  func the function to run as the patch
--- @number[opt] position which patch to insert it as? If not supplied, inserts it as the last patch. Which is usually what you want.
function revisionator:addPatch(func, position)
  if position then
    table.insert(self.patches, position, func)
  else
    table.insert(self.patches, func)
  end
end

--- Remove a patch from the table of patches
--- this is primarily used for testing
--- @local
--- @number[opt] patchNumber the patch number to remove. Will remove the last item if not provided.
function revisionator:removePatch(patchNumber)
  table.remove(self.patches, patchNumber)
end

--- set the currently applied patch number
-- only directly called for testing
--- @local
--- @number patchNumber the patch number to set as the currently applied patch
function revisionator:setAppliedPatch(patchNumber)
  local fileName = f"{self.dataDir}/{self.name}.txt"
  local revFile, err = io.open(fileName, "w+")
  if not revFile then
    printError(err, true, true)
  end
  revFile:write(patchNumber)
  revFile:close()
end

return revisionator