require("sm_loader")
require("Source.Dispatcher")

--================================================================================

----------------------------------------------------------------------------------

Class{"Commander", mDisp = Dispatcher, mParsing = Boolean, mPatterns = Array}

----------------------------------------------------------------------------------

function Commander:new(Disp)
   New = Commander._super.new(self)
   New.mDisp = Disp
   New.mParsing = false
   New.mPatterns = Commander.InitPatterns()
   return New
end

----------------------------------------------------------------------------------

function Commander:setDice(first, sec)
   self.mDisp:SetDices(first, sec)
   return first, sec
end

----------------------------------------------------------------------------------

function Commander:moveStone(
