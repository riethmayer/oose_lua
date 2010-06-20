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
--   self.mController:move(from, to)
end

----------------------------------------------------------------------------------

function Dispatcher:UpdateView()
   self.mController:UpdateView()
end

--================================================================================

Aspect{"MoveLogger",
       adapts = { Dispatcher }}