require("sm_loader")
require("Source.Controller")

--================================================================================

Class{"Command", mCmdName = String}

----------------------------------------------------------------------------------

Class{"Dispatcher", mController = Controller}

----------------------------------------------------------------------------------

function Dispatcher:new(rController)
   New = Dispatcher._super.new(self)
   New.mController = rController
   return New
end

----------------------------------------------------------------------------------

function Dispatcher:SetDices(first, sec)
   self.mController:SetDices(first, sec)
end

----------------------------------------------------------------------------------

function Dispatcher:MoveStone(from, to)
   self.mController:MoveStone(from, to)
end

----------------------------------------------------------------------------------

function Dispatcher:RestartGame()
--   self.mController:Restart()
end

----------------------------------------------------------------------------------

function Dispatcher:EndGame()
--   self.mController:move(from, to)
end

----------------------------------------------------------------------------------

function Dispatcher:NextPlayer()
--   self.mController:move(from, to)
end

----------------------------------------------------------------------------------

function Dispatcher:ToggleCheck()
--   self.mController:move(from, to)
end

----------------------------------------------------------------------------------

function Dispatcher:ToggleLog()
   MoveLogger:ToggleEnabled(from, to)
end

----------------------------------------------------------------------------------

function Dispatcher:UpdateView()
   self.mController:UpdateView()
end

--================================================================================

Class{"File", mFileName = String}

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
       before = { LogMove = "MoveStone", LogRestart = "RestartGame"}}

function DispatchLogger:LogMove(from, to)
   l_File:write("Moved stone from "..from.." to "..to.."\n")
end

--================================================================================

Class{"MoveLogger", mEnabled = Boolean}

----------------------------------------------------------------------------------

function MoveLogger:new(FileName)
   local New = MoveLogger._super.new(self)
   New.mEnabled = false
   return New
end

----------------------------------------------------------------------------------

function MoveLogger:   local l_var = {...})
   if self.mEnabled then
      self:disable()
   else
      self:enable()
   end
end

----------------------------------------------------------------------------------

function MoveLogger:enable()
   l_File:open()
   DispatchLogger:enable()
end

----------------------------------------------------------------------------------

function MoveLogger:disable()
   l_File:close()
   DispatchLogger:disable()
end
