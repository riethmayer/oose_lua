require("sm_loader")
require("Source.Data")
require("Source.View")

--================================================================================

----------------------------------------------------------------------------------

Class{"Controller", mData = Data, mView = View}

----------------------------------------------------------------------------------

function Controller:new(rData, rView)
   New = Controller._super.new(self)
   New.mData = rData
   New.mView = rView
   return New
end

----------------------------------------------------------------------------------

function Controller:MoveStone(from, to)
   self:DoMoveStone(from, to)
   if self:RemoveDice(from, to) == 0 then
      self:TogglePlayer()
   end
   print("Moved"..from..to)
   self:UpdateView()
end

----------------------------------------------------------------------------------

function Controller:DoMoveStone(from, to)
   self:PlaceStone(self:TakeStone(from), to)
end

----------------------------------------------------------------------------------

function Controller:TakeStone(from)
   if from == 0 then
      local l_Field = self.mData.mOutField
      return l_Field:get_stone(self.mData.mCurrentPlayer)
   else
      local l_Field = self.mData.mFields:at(from)
      return l_Field and l_Field:get_stone()
   end
end

----------------------------------------------------------------------------------

function Controller:PlaceStone(l_Stone, to)
   if l_Stone then
      if 1 <= to and to <= 24 then
	 if self.mData.mFields:at(to):has_single_opposite(l_Stone:Color()) then
	    self:DoMoveStone(to, 0)
	 end
	 self.mData.mFields:at(to):set_stone(l_Stone)
      elseif to == 0 then
	 self.mData.mOutField:set_stone(l_Stone)
      end
   end
end

----------------------------------------------------------------------------------

function Controller:RemoveDice(from, to)
   local l_Val = from < to and to - from or from - to
   return self.mData.mDices:Remove(l_Val)
end

----------------------------------------------------------------------------------

function Controller:SetDices(first, sec)
   self.mData.mDices:Set(first, sec)
end

----------------------------------------------------------------------------------

function Controller:TogglePlayer()
   local l_Curr = self.mData.mCurrentPlayer
   local l_Next = l_Curr == "black" and "white" or "black"
   self.mData.mCurrentPlayer = l_Next
   self.mData.mDices:Randomize()
end

----------------------------------------------------------------------------------
function Controller:UpdateView()
   self.mView:plot()
end


--================================================================================

----------------------------------------------------------------------------------

Aspect{"RuleCheck",
       adapts = { Controller }}