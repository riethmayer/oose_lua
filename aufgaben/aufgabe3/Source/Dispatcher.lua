require("sm_loader")
root_require("aufgabe3.Source.Controller")

--================================================================================

Class{"Command", mCmdName = String}

----------------------------------------------------------------------------------

Class{"Dispatcher", mController = Controller, mEndParse = Function}

----------------------------------------------------------------------------------

function Dispatcher:new(rController)
   New = Dispatcher._super.new(self)
   New.mController = rController
   return New
end

----------------------------------------------------------------------------------

function Dispatcher:SetEndParseCallback(cb)
   self.mEndParse = cb
end

----------------------------------------------------------------------------------

function Dispatcher:SetDices(first, sec)
   self.mController:SetDices(first, sec)
end

----------------------------------------------------------------------------------

function Dispatcher:MoveStoneUpdateView(from, to)
   local l_res = self:MoveStone(from, to)
   if l_res then
      self:UpdateView()
   end
end

----------------------------------------------------------------------------------

function Dispatcher:MoveStone(from, to)
   return self.mController:MoveStone(from, to)
end

----------------------------------------------------------------------------------

function Dispatcher:InitGame()   
   self.mController:InitGame()
   self:UpdateView()
end

----------------------------------------------------------------------------------

function Dispatcher:RestartGame()
  self.mController:InitGame()
  self:UpdateView()
end

----------------------------------------------------------------------------------

function Dispatcher:EndGame()
   self.mEndParse()
   self.mController:Finish()
end

----------------------------------------------------------------------------------

function Dispatcher:NextPlayer()
   self.mController:TogglePlayer()
   self:UpdateView()
end

----------------------------------------------------------------------------------

function Dispatcher:ToggleCheck()
   MoveChecker:Toggle()
end

----------------------------------------------------------------------------------

function Dispatcher:ToggleLog()
   MoveLogger:Toggle()
end

----------------------------------------------------------------------------------

function Dispatcher:UpdateView()
   self.mController:UpdateView()
end

--================================================================================

Class{"File", mFileName = String, mOpen = Boolean}

----------------------------------------------------------------------------------

function File:new(FileName)
   local New = File._super.new(self)
   New.mFileName = FileName
   return New
end

----------------------------------------------------------------------------------

function File:_get_handle()
   return rawget(self, "handle")
end

----------------------------------------------------------------------------------

function File:_set_handle(handle)
   rawset(self, "handle", handle)
end

----------------------------------------------------------------------------------

function File:open()
   if self:_get_handle() then
      self:close()
   end

   self:_set_handle(io.open(self.mFileName, "a+"))
end

----------------------------------------------------------------------------------

function File:close()
   local l_h = self:_get_handle()
   if l_h then
      if l_h:close() then
	 self:_set_handle(nil)
      else
	 error("Error while closing file")
      end
   end
end
   
----------------------------------------------------------------------------------

function File:write(...)
   self:_get_handle():write(...)
end

--================================================================================

local l_File = File:new("BgLog.txt")

Aspect{"DispatchLogger",
       adapts = { Dispatcher },
       before = { _LogMove = "MoveStone", _LogGame = "[^_][%a]*Game"}}

function DispatchLogger:_LogMove(from, to)
   l_File:write(self:CurrentPlayer()..
	     " moved stone from "..from.." to "..to..
	     " at time: "..self:Time().."\n")
end

function DispatchLogger:_LogGame(CmdName)
   l_File:write(CmdName.." at time: "..self:Time().."\n")
end

function DispatchLogger:CurrentPlayer()
   return self.mController:CurrentPlayer()
end

function DispatchLogger:Time()
   return self.mController:TimeDiff()
end

--================================================================================

Class{"MoveLogger"}
----------------------------------------------------------------------------------
local l_Enabled = false
----------------------------------------------------------------------------------

function MoveLogger:enable()
   l_File:open()
   l_Enabled = true
   DispatchLogger:enable()
end

----------------------------------------------------------------------------------

function MoveLogger:disable()
   l_File:close()
   l_Enabled = false
   DispatchLogger:disable()
end

----------------------------------------------------------------------------------

function MoveLogger:Toggle()
   if l_Enabled then
      self:disable()
   else
      self:enable()
   end
end
