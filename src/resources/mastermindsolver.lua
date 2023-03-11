--- Interactive object which helps you solve a Master Mind puzzle.
-- @classmod MasterMindSolver
-- @author Damian Monogue <demonnic@gmail.com>
-- @copyright 2021 Damian Monogue
-- @copyright 2008,2009 Konstantinos Asimakis for code used to turn an index number into a guess (indexToGuess method)
local MasterMindSolver = {
  places = 4,
  items = {"red", "orange", "yellow", "green", "blue", "purple"},
  template = "|t",
  autoSend = false,
  singleCommand = false,
  separator = " ",
  allowDuplicates = true,
}
local mod, floor, random, randomseed = math.mod, math.floor, math.random, math.randomseed
local initialGuess = {{1}, {1, 2}, {1, 1, 2}, {1, 1, 2, 2}, {1, 1, 1, 2, 2}, {1, 1, 1, 2, 2, 2}, {1, 1, 1, 1, 2, 2, 2}, {1, 1, 1, 1, 2, 2, 2, 2}}

--- Removes duplicate elements from a list
-- @param tbl the table you want to remove dupes from
-- @local
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

--- Creates a new Master Mind solver
-- @tparam table options table of configuration options for the solver
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
--     <td class="tg-1">places</td>
--     <td class="tg-1">How many spots in the code we're breaking?</td>
--     <td class="tg-1">4</td>
--   </tr>
--   <tr>
--     <td class="tg-2">items</td>
--     <td class="tg-2">The table of colors/gemstones/whatever which can be part of the code</td>
--     <td class="tg-2">{"red", "orange", "yellow", "green", "blue", "purple"}</td>
--   </tr>
--   <tr>
--     <td class="tg-1">template</td>
--     <td class="tg-1">The string template to use for the guess. Within the template, |t is replaced by the item. Used as the command if autoSend is true</td>
--     <td class="tg-1">"|t"</td>
--   </tr>
--   <tr>
--     <td class="tg-2">autoSend</td>
--     <td class="tg-2">Should we send the guess directly to the server?</td>
--     <td class="tg-2">false</td>
--   </tr>
--   <tr>
--     <td class="tg-1">allowDuplicates</td>
--     <td class="tg-1">Can the same item be used more than once in a code?</td>
--     <td class="tg-1">true</td>
--   </tr>
--   <tr>
--     <td class="tg-2">singleCommand</td>
--     <td class="tg-2">If true, combines the guess into a single command, with each one separated by the separator</td>
--     <td class="tg-2">false</td>
--   </tr>
--   <tr>
--     <td class="tg-1">separator</td>
--     <td class="tg-1">If sending the guess as a single command, what should we put between the guesses to separate them?</td>
--     <td class="tg-1">" "</td>
--   </tr>
-- </tbody>
-- </table>
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

--- Takes a guess number (4, or 1829, or any number from 1 - <total possible combinations>) and returns the
-- actual guess.
-- @tparam number index which guess to generate
-- @local
function MasterMindSolver:indexToGuess(index)
  local guess = {}
  local options = #self.items
  for place = 1, self.places do
    guess[place] = mod(floor((index - 1) / options ^ (place - 1)), options) + 1
  end
  return guess
end

--- Compares a guess with the solution and returns the answer
-- @tparam table guess The guess you are checking, as numbers. { 1 , 1, 2, 2 } as an example
-- @tparam table solution the solution you are checking against, as numbers. { 3, 4, 1, 6 } as an example.
-- @local
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

--- Generates an initial table of all guesses from 1 to <total possible> that are valid.
-- If allowDuplicates is false, will filter out any of the possible combinations which contain duplicates
-- @local
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

--- Function used to reduce the remaining possible answers, given a guess and the answer to that guess. This is not undoable.
-- @tparam table guess guess which the answer belongs to. Uses numbers, rather than item names. IE { 1, 1, 2, 2} rather than { "blue", "blue", "green", "green" }
-- @tparam number coloredPins how many parts of the guess are both the right color and the right place
-- @tparam number whitePins how many parts of the guess are the right color, but in the wrong place
-- @return true if you solved the puzzle (coloredPins == number of positions in the code), or false otherwise
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

--- Function which assumes you used the last suggested guess from the solver, and reduces the number of possible correct solutions based on the answer given
-- @see MasterMindSolver:reducePossible
-- @tparam number coloredPins how many parts of the guess are both the right color and the right place
-- @tparam number whitePins how many parts of the guess are the right color, but in the wrong place
-- @return true if you solved the puzzle (coloredPins == number of positions in the code), or false otherwise
function MasterMindSolver:checkLastSuggestion(coloredPins, whitePins)
  return self:reducePossible(self.guess, coloredPins, whitePins)
end

--- Used to get one of the remaining valid possible guesses
-- @tparam boolean useActions if true, will return the guess as the commands which would be sent, rather than the numbered items
function MasterMindSolver:getValidGuess(useActions)
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
  if useActions then
    return self:guessToActions(guess)
  end
  return guess
end

--- Takes a guess and converts the numbers to commands/actions. IE guessToActions({1, 1, 2, 2}) might return { "blue", "blue", "green", "green" }
-- @tparam table guess the guess to convert as numbers. IE { 1, 1, 2, 2}
-- @return table of commands/actions correlating to the numbers in the guess.
-- @local
function MasterMindSolver:guessToActions(guess)
  local actions = {}
  for index, itemNumber in ipairs(guess) do
    local item = self.items[itemNumber]
    actions[index] = self.template:gsub("|t", item)
  end
  return actions
end

--- Handles sending the commands to the game for a guess
-- @local
function MasterMindSolver:sendGuess(guess)
  local actions = self:guessToActions(guess)
  if self.singleCommand then
    send(table.concat(actions, self.separator))
  else
    sendAll(unpack(actions))
  end
end

return MasterMindSolver
