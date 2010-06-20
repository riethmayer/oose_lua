require("sm_loader")
require("Source.Dispatcher")

--================================================================================
local MoveArgRegEx = "%d%d?%s%d%d?"
--================================================================================

Class{"FrontEnd", mDisp = Dispatcher}

----------------------------------------------------------------------------------

function FrontEnd:new(rDisp)
   local New = FrontEnd._super.new(self, rDisp)
   New.mDisp = rDisp
   return New
end

----------------------------------------------------------------------------------

function FrontEnd:start(Interactive)
   if Interactive then
      self._class = Parser
      self:Init()
      self:BeginParsing()
   else
      self._class = Commander
   end
end

--================================================================================

Class{"Pattern", mPat = String, mFuncName = String, mGetArgs = Function}

----------------------------------------------------------------------------------

function Pattern:new(rPat, rFunc, rGetArgsFunc)
   local New = Pattern._super.new(self)
   New.mPat = rPat
   New.mFuncName = rFunc   
   if rGetArgsFunc then
      New.mGetArgs = rGetArgsFunc
   end
   return New
end

--================================================================================

local function StringToNumberForMove(input)
   local l_space = input:find("%s")
   local first = tonumber(input:sub(1,l_space - 1))
   local sec = tonumber(input:sub(l_space - input:len()))
   return first, sec
end

----------------------------------------------------------------------------------

Class{"Parser", FrontEnd, mParsing = Boolean, mPatterns = Array}

----------------------------------------------------------------------------------

function Parser:new(Disp)
   New = Parser._super.new(self, Disp)
   New:Init(Disp)
   return New
end

----------------------------------------------------------------------------------

function Parser:Init()
   self.mParsing = false
   self.mPatterns = Parser.InitPatterns()
end

----------------------------------------------------------------------------------

function Parser.InitPatterns()
   local patterns = Array:new(Pattern)
   patterns:push_back(Pattern:new(MoveArgRegEx, "MoveStone", StringToNumberForMove))
   patterns:push_back(Pattern:new("restart", "RestartGame"))
   patterns:push_back(Pattern:new("end", "EndGame"))
   patterns:push_back(Pattern:new("next", "NextPlayer"))
   patterns:push_back(Pattern:new("check", "ToggleCheck"))
   patterns:push_back(Pattern:new("log", "ToggleLog"))
   return patterns
end

----------------------------------------------------------------------------------

function Parser:BeginParsing()
   self.mParsing = true
   local input = io.stdin:read()
   while input do
      self:TranslateInput(input)
      input = io.stdin:read()
   end
end

----------------------------------------------------------------------------------

function Parser:TranslateInput(input)
   local l_PattIter = self.mPatterns:fwd_iterator()
   local l_Pattern = l_PattIter()
   while l_Pattern  do
      local l_Match = self:FindPattern(input, l_Pattern.mPat)
      if l_Match then
	 self:Excecute(input, l_Pattern)
      end
      l_Pattern = l_PattIter()
   end   
end

----------------------------------------------------------------------------------

function Parser:FindPattern(str, pattern)
   return str:find(pattern) ~= nil
end

----------------------------------------------------------------------------------

function Parser:Excecute(input, pattern)
   local l_FuncName = pattern.mFuncName
   local l_Match = input:match(pattern.mPat)
   local l_Args = { pattern.mGetArgs(l_Match) }
   self.mDisp[l_FuncName](self.mDisp, unpack(l_Args))
end

--================================================================================

Aspect{"ParserCheck",
       adapts = { Parser, Commander},
       before = { MisMatch = "Excecute"}}

----------------------------------------------------------------------------------

function ParserCheck:MisMatch(str, pattern)
   print("Syntax", str, pattern.mPat)
   if str:match(pattern.mPat) ~= str then
      error("Syntax error, expected "..pattern.mPat.." got "..str)
   end
end

--================================================================================

----------------------------------------------------------------------------------

Class{"Commander", FrontEnd}

----------------------------------------------------------------------------------

function Commander:setDice(first, sec)
   self.mDisp:SetDices(first, sec)
   return first, sec
end

----------------------------------------------------------------------------------

function Commander:moveStone(inp)
   self.mDisp:MoveStone(StringToNumberForMove(inp))
end

----------------------------------------------------------------------------------

function Commander:print()
   self.mDisp:UpdateView()
end

--================================================================================

Aspect{"CommanderCheck",
       adapts = { Commander },
       before = { MoveArgs = "moveStone",
		  DiceArgs = "setDice",
		  PrintArgs = "print"}}

----------------------------------------------------------------------------------

function CommanderCheck:MoveArgs(...)
   local l_args = {...}
   local l_str = l_args[1]

   local l_confirmed =
      #l_args == 1
      and type(l_str) == "string"
      and l_str:match(MoveArgRegEx) == l_str

   if not l_confirmed then
      print("Syntax error on command moveStone expected e.g.(\"12 25\") got (\""..unpack(l_args).."\")")
      return false
   end
end

----------------------------------------------------------------------------------

function CommanderCheck:DiceArgs(...)
   local l_args = {...}
   local l_first, l_sec = l_args[1], l_args[2]

   local l_confirmed =
      #l_args == 2
      and type(l_first) == "number"
      and type(l_sec) == "number"

   if not l_confirmed then
      error("Syntax error on command setDice expected e.g.(1, 5) got "..unpack(l_args))
   end   
end

----------------------------------------------------------------------------------

function CommanderCheck:PrintArgs(...)
   local l_args = {...}

   local l_confirmed =
      #l_args == 0

   if not l_confirmed then
      error("Syntax error on command print expected no arguments got "..unpack(l_args))
   end
end

--================================================================================

Class{"MoveChecker"}

function MoveChecker:enable()
   ParserCheck:enable()
   CommanderCheck:enable()
   RuleCheck:enable()
end

function MoveChecker:disable()
   RuleCheck:disable()
   CommanderCheck:disable()
   ParserCheck:disable()
end