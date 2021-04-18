--- Interactive object which helps you solve a Master Mind puzzle.
-- @classmod MasterMindSolver
-- @author Damian Monogue <demonnic@gmail.com>
-- @copyright 2021 Damian Monogue
-- @copyright 2008,2009 Konstantinos Asimakis for code used to turn an index number into a guess (indexToGuess method)

local MasterMindSolver = {
  places = 4,
  items = {"red", "orange", "yellow", "green", "blue", "purple"},
  template = "|t",
  autoSend = true,
  allowDuplicates = true,
}
local mod, floor, random, randomseed = math.mod, math.floor, math.random, math.randomseed
local initialGuess = {{1}, {1, 2}, {1, 1, 2}, {1, 1, 2, 2}, {1, 1, 1, 2, 2}, {1, 1, 1, 2, 2, 2}, {1, 1, 1, 1, 2, 2, 2}, {1, 1, 1, 1, 2, 2, 2, 2}}

local function tableUnique(tbl)
  local used = {}
  local result = {}
  for _, item in ipairs(tbl) do
    if not used[item] then
      result[#result + 1] = item
      used[item] = true
    end
  end
  return result
end

function MasterMindSolver:new(options)
  if options == nil then
    options = {}
  end
  local optionsType = type(options)
  if optionsType ~= "table" then
    error(f "MasterMindSolver:new(options): options as table expected, got {tostring(options)} of type: {optionsType}")
  end
  local me = options
  setmetatable(me, self)
  self.__index = self
  me:populateInitialSet()
  if not me.allowDuplicates then
    me.initialGuessMade = true -- skip the preset initial guess, they assume duplicates
  end
  return me
end

function MasterMindSolver:indexToGuess(index)
  local guess = {}
  local options = #self.items
  for place = 1, self.places do
    guess[place] = mod(floor((index - 1) / options ^ (place - 1)), options) + 1
  end
  return guess
end

function MasterMindSolver:compare(guess, solution)
  local coloredPins = 0
  local whitePins = 0
  local usedGuessPlace = {}
  local usedSolutionPlace = {}
  local places = self.places
  for place = 1, places do
    if guess[place] == solution[place] then
      coloredPins = coloredPins + 1
      usedGuessPlace[place] = true
      usedSolutionPlace[place] = true
    end
  end
  for guessPlace = 1, places do
    if not usedGuessPlace[guessPlace] then
      for solutionPlace = 1, places do
        if not usedSolutionPlace[solutionPlace] then
          if guess[guessPlace] == solution[solutionPlace] then
            whitePins = whitePins + 1
            usedSolutionPlace[solutionPlace] = true
            break
          end
        end
      end
    end
  end
  return coloredPins, whitePins
end

function MasterMindSolver:populateInitialSet()
  local possible = {}
  local allowDuplicates = self.allowDuplicates
  local places = self.places
  local numberOfItems = #self.items
  local totalCombos = numberOfItems ^ places
  local numberRemaining = 0
  for entry = 1, totalCombos do
    local useItem = true
    if not allowDuplicates then
      local guess = self:indexToGuess(entry)
      local guessUnique = tableUnique(guess)
      if #guessUnique ~= self.places then
        useItem = false
      end
    end
    if useItem then
      possible[entry] = true
      numberRemaining = numberRemaining + 1
    end
  end
  self.possible = possible
  self.numberRemaining = numberRemaining
end

function MasterMindSolver:reducePossible(guess, coloredPins, whitePins)
  if coloredPins == #guess then
    return true
  end
  local possible = self.possible
  local numberRemaining = 0
  for entry, _ in pairs(possible) do
    local testColor, testWhite = self:compare(guess, self:indexToGuess(entry))
    if testColor ~= coloredPins or testWhite ~= whitePins then
      possible[entry] = nil
    else
      numberRemaining = numberRemaining + 1
    end
  end
  self.possible = possible
  self.numberRemaining = numberRemaining
  return false
end

function MasterMindSolver:checkLastSuggestion(coloredPins, whitePins)
  local guess = self.guess
  if coloredPins == #guess then
    -- self:success()
    return true
  end
  return self:reducePossible(guess, coloredPins, whitePins)
end

function MasterMindSolver:getValidGuess()
  local guess
  if not self.initialGuessMade then
    self.initialGuessMade = true
    guess = initialGuess[self.places]
  end
  if not guess then
    local possible = self.possible
    local keys = table.keys(possible)
    randomseed(os.time())
    guess = self:indexToGuess(keys[random(#keys)])
  end
  self.guess = guess
  if self.autoSend then
    self:sendGuess(guess)
  end
  return guess
end

function MasterMindSolver:guessToActions(guess)
  local actions = {}
  for index = 1, #guess do
    local item = self.items[guess[index]]
    actions[index] = self.template:gsub("|t", item)
  end
  return actions
end

function MasterMindSolver:sendGuess(guess)
  sendAll(unpack(self:guessToActions(guess)))
end

return MasterMindSolver
