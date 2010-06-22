require("sm_loader")
root_require("aufgabe3.Source.Dispatcher")

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
   self.mDisp:InitGame()
   if Interactive then
      self._class = Parser
      local l_EndParse = 
	 function() self:EndParsing() end
      self.mDisp:SetEndParseCallback(Function:new(l_EndParse))
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

local function FuncMap()
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
   self.mPatterns = FuncMap()
end

----------------------------------------------------------------------------------

function Parser:BeginParsing()
   self.mParsing = true
   local input = self.GetLine()
   while input and self.mParsing do
      self:TranslateInput(input)
      input = self.GetLine()
   end
end

----------------------------------------------------------------------------------

function Parser:EndParsing()
   self.mParsing = false
end

----------------------------------------------------------------------------------

function Parser.GetLine()
   return io.stdin:read()
end

----------------------------------------------------------------------------------

function Parser:TranslateInput(input)
   for patt in self.mPatterns:fwd_iterator() do
      if self:FindPattern(input, patt.mPat) then
	 self:Excecute(input, patt)
      end
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
   if str:match(pattern.mPat) ~= str then
      print("Syntax error, expected "..pattern.mPat.." got "..str)
      return false
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

----------------------------------------------------------------------------------

function Commander:restart()
   self.mDisp:RestartGame()
end

--================================================================================

Aspect{"CommanderCheck",
       adapts = { Commander },
       before = { _CheckArgs = "[^_].*"}}

----------------------------------------------------------------------------------

function CommanderCheck:_CheckArgs(...)
   local l_args = {...}
   local l_FuncName = table.remove(l_args)
   local l_ArgTypes = {}
   for _, v in pairs(l_args) do
      table.insert(l_ArgTypes, type(v))
   end
   
   local l_confirmed = ""
   local l_expected = ""
   if l_FuncName == "print" then
      l_confirmed = #l_ArgTypes == 0
      l_expected = "print()"      
   elseif l_FuncName == "setDice" then
      l_confirmed = #l_ArgTypes == 2
         and l_ArgTypes[1] == "number"
         and l_ArgTypes[2] == "number"
      l_expected = "setDice(12, 5)"
   elseif l_FuncName == "moveStone" then
      l_confirmed = #l_ArgTypes == 1
	 and l_ArgTypes[1] == "string"
         and l_args[1]:match(MoveArgRegEx) == l_args[1]
      l_expected = "moveStone(\"14 18\")"
   elseif l_FuncName == "restart" then
      l_confirmed = #l_ArgTypes == 0
      l_expected = "restart()"
   end

   if not l_confirmed then
      print("Syntax error on command "..l_FuncName.."(\""..unpack(l_args).."\") expected "
	 ..l_expected..".")
      return false
   end
end

--================================================================================

Class{"MoveChecker"}
----------------------------------------------------------------------------------
local l_Enabled = false
----------------------------------------------------------------------------------

function MoveChecker:enable()
   l_Enabled = true
   ParserCheck:enable()
   CommanderCheck:enable()
   RuleCheck:enable()
end

----------------------------------------------------------------------------------

function MoveChecker:disable()
   RuleCheck:disable()
   CommanderCheck:disable()
   ParserCheck:disable()
   l_Enabled = false
end

----------------------------------------------------------------------------------

function MoveChecker:Toggle()
   if l_Enabled then
      self:disable()
   else
      self:enable()
   end
end