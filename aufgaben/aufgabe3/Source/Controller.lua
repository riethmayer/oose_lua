require("sm_loader")
root_require("aufgabe3.Source.Data")
root_require("aufgabe3.Source.View")

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
   local l_from = self:AdjustedFrom(from)
   self:DoMoveStone(l_from, to)
   if self:RemoveDice(self:DrawDistance(l_from, to)) == 0 then
      self:TogglePlayer()
   end
   print("Moved"..l_from..to)
   self:UpdateView()
end

----------------------------------------------------------------------------------

function Controller:DoMoveStone(from, to)
   self:PlaceStone(self:TakeStone(from), to)
end

----------------------------------------------------------------------------------

function Controller:TakeStone(from)
   if self:IsOutField(from) then
      local l_Field = self.mData.mOutField
      return l_Field:take_stone(self:CurrentPlayer())
   else
      local l_Field = self.mData.mFields:at(from)
      return l_Field and l_Field:take_stone()
   end
end

----------------------------------------------------------------------------------

function Controller:PlaceStone(l_Stone, to)
   if l_Stone then
      if self:IsFinishField(to) then
	 return
      end
      
      if ValueRange:new(1, 24):contains(to) then
	 if self.mData.mFields:at(to):has_single_opposite(l_Stone:Color()) then
	    self:DoMoveStone(to, -1)
	 end
	 self.mData.mFields:at(to):place_stone(l_Stone)
      elseif to == -1 then
	 self.mData.mOutField:place_stone(l_Stone)
      end
   end
end

----------------------------------------------------------------------------------

function Controller:IsOutField(num)
   return self:CurrentPlayer() == "black" and num == 25 or num == 0
end

----------------------------------------------------------------------------------

function Controller:IsFinishField(num)
   return self:CurrentPlayer() == "black" and num == 0 or num == 25
end

----------------------------------------------------------------------------------

function Controller:AdjustedFrom(num)
   return num == 0 and self:CurrentPlayer() == "black" and 25 or num
end

----------------------------------------------------------------------------------

function Controller:CurrentPlayer()       
   return self.mData.mCurrentPlayer
end

----------------------------------------------------------------------------------

function Controller:RemoveDice(dist)
   return self.mData.mDices:Remove(dist)
end

----------------------------------------------------------------------------------

function Controller:DrawDistance(from, to)
   return (to - from) * self:DrawDirection()
end

----------------------------------------------------------------------------------

function Controller:DrawDirection()
   return self:CurrentPlayer() == "black" and -1 or 1
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
       adapts = { Controller },
       before = { Check = "MoveStone" }}

----------------------------------------------------------------------------------

function RuleCheck:Check(from, to)
   print("Check", from, to)
   local l_from = self:AdjustedFrom(from)
   local l_Error =
      self:RightDrawDirection(l_from, to)
   or self:NoOutstandingBrokenStones(l_from)
   or self:PlayerMayDraw(l_from)
   or self:PlayerHasDice(self:DrawDistance(l_from, to))
   or self:TargetIsFree(to)
   or self:NoOutstandingDuties(to)
   if l_Error then
      print(l_Error)
      return false
   end
end

----------------------------------------------------------------------------------

function RuleCheck:RightDrawDirection(from, to)
   if (to - from) * self:DrawDirection() < 0 then
      return("Draws into wrong dircetion.")
   end
end

----------------------------------------------------------------------------------

function RuleCheck:NoOutstandingBrokenStones(from)
   if not self:IsOutField(from)
      and self.mData.mOutField:stone(self:CurrentPlayer()) ~= nil then
      return("Has to insert broken stone first.")
   end
end

----------------------------------------------------------------------------------

function RuleCheck:PlayerMayDraw(from)
   local l_Player = self:CurrentPlayer()
   if ValueRange:new(1,24):contains(from) then
      return self:MayDrawFromField(from, l_Player)
   elseif from == 0 or from == 25 then
      return self:MayDrawFromOutField(l_Player)
   else
      return("Illegal Field "..from.." to draw from")
   end
end

----------------------------------------------------------------------------------

function RuleCheck:MayDrawFromField(from, player)
   local l_Field = self.mData.mFields:at(from)
   local l_Stone = l_Field.mStones:top()
   if not l_Stone then
      return("Can't take stone from empty field.")
   elseif l_Stone:Color() ~=  player then
      return("Player "..player.." may not take opposite's stone.")
   end
end

----------------------------------------------------------------------------------

function RuleCheck:MayDrawFromOutField(player)
   local l_Stone = self.mData.mOutField:stone(player)
   if not l_Stone then
      return("No Stone to draw from beaten stones.")
   end
end

----------------------------------------------------------------------------------

function RuleCheck:PlayerHasDice(dist)
   if not self.mData.mDices:HasVal(dist) then
      return("Player doesn't have dice for drawing "..dist)
   end
end

----------------------------------------------------------------------------------


----------------------------------------------------------------------------------

function RuleCheck:TargetIsFree(to)
   local l_Field = self.mData.mFields:at(to)
   local l_Stone = l_Field and l_Field.mStones:top()
   local l_Free = not l_Stone
      or l_Stone:Color() == self:CurrentPlayer()
      or l_Field:has_single_opposite(self:CurrentPlayer())

   if not l_Free then
      return("Target is not free.")
   end
end

----------------------------------------------------------------------------------

function RuleCheck:NoOutstandingDuties(to)
   if self:IsFinishField(to)
      and not self:AllInHomeZone() then
      return("Needs to first move all stone into home zone.")
   end
end

----------------------------------------------------------------------------------

function RuleCheck:AllInHomeZone()
   local l_Color = self:CurrentPlayer()
   local l_Zone = self:PlayersHomeZone()
   for i in l_Zone:iterator() do
      if self.mData.mFields:at(i):stone(l_Color) then
	 return false
      end
   end
   return true
end

----------------------------------------------------------------------------------

function RuleCheck:PlayersHomeZone()
   if self:CurrentPlayer() == "black" then
      return ValueRange:new(1, 6)
   else
      return ValueRange:new(19, 24)
   end
end

----------------------------------------------------------------------------------

Class{"ValueRange", mLow = Number, mHigh = Number}

----------------------------------------------------------------------------------

function ValueRange:new(low, high)
   local New = ValueRange._super.new(self)
   New.mLow = low
   New.mHigh = high
   return New
end

----------------------------------------------------------------------------------

function ValueRange:contains(num)
   return self.mLow <= num
   and num <= self.mHigh
end

----------------------------------------------------------------------------------

function ValueRange:iterator()
   local l_beg = self.mLow
   local l_end = self.mHigh
   return
   function()
      if l_beg <= l_end then
	 local l_ret = l_beg
	 l_beg = l_beg + 1
	 return l_ret
      end
   end
end