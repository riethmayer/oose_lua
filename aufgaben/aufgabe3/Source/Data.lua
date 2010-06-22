require("sm_loader")

--================================================================================

Class{"Stone", mColor = String}

----------------------------------------------------------------------------------

function Stone:new(Color)
   local New = Stone._super.new(self)
   New.mColor = Color
   return New
end

----------------------------------------------------------------------------------

function Stone:Color()
   return self.mColor
end

----------------------------------------------------------------------------------

function Stone:Symbol()
   return self.mColor == "white" and "W" or
      self.mColor == "black" and "B"
end

--================================================================================

Class{"Field", mStones = Array}

----------------------------------------------------------------------------------

function Field:new()
   local New = Field._super.new(self)
   New.mStones = Array:new(Stone)
   return New
end

----------------------------------------------------------------------------------

function Field:stone_iterator(UpOrDown)
   if UpOrDown then
      return self.mStones:iterator(1, 1)
   else
      return self.mStones:iterator()
   end
end

----------------------------------------------------------------------------------

function Field:stone(color)
   for stone, idx in self:stone_iterator() do
      if stone:Color() == color then
	 return stone, idx
      end
   end
end

----------------------------------------------------------------------------------

function Field:take_stone()
   return self.mStones:pop()
end

----------------------------------------------------------------------------------

function Field:place_stone(l_Stone)
   self.mStones:push(l_Stone)
end

----------------------------------------------------------------------------------

function Field:has_single_opposite(color)
   local l_top = self.mStones:top()
   local l_ret = self.mStones:size() == 1
     and l_top and l_top:Color() ~= color
  return l_ret
end

--================================================================================

Class{"OutField", Field}

----------------------------------------------------------------------------------

function OutField:take_stone(color)
   local l_Stone, l_idx = self:stone(color)
   if l_Stone then 
      self.mStones:_remove(l_idx)
      return l_Stone
   end
end

--================================================================================

Class{"Dices", mDices = Array}

----------------------------------------------------------------------------------

function Dices:new()
   local New = Dices._super.new(self)
   New.mDices = Array:new(Number)
   New:Randomize()
   return New
end

----------------------------------------------------------------------------------

function Dices:Randomize()
   self:Set(math.random(6), math.random(6))
end

----------------------------------------------------------------------------------

function Dices:Set(f, s)
   self.mDices:clear()
   self.mDices:push_back(f)
   self.mDices:push_back(s)
end

----------------------------------------------------------------------------------

function Dices:Remove(val)
   self.mDices:remove_val(val)
   return self.mDices:size()
end

----------------------------------------------------------------------------------

function Dices:HasVal(val)
   local l_Ret = self.mDices:val_iterator(val)() ~= nil
   return l_Ret
end
      
--================================================================================

Class{"Data", mFields = Array, mOutField = OutField, mCurrentPlayer = String, mDices = Dices}

----------------------------------------------------------------------------------

function Data:new()
   local New = Data._super.new(self)
   New.mFields = Array:new(Field)
   for i = 1, 24 do
      New.mFields:push_back(Field:new())
   end
   New.mOutField = OutField:new()
   New.mCurrentPlayer = "black"
   New.mDices = Dices:new()
   return New
end

----------------------------------------------------------------------------------
-- par example
function Data:Init()
   local l_w = "white"
   local l_b = "black"
   self:Place(1, 2, l_w)
   self:Place(6, 5, l_b)
   self:Place(8, 3, l_b)
   self:Place(12, 5, l_w)
   self:Place(13, 5, l_b)
   self:Place(17, 3, l_w)
   self:Place(19, 5, l_w)
   self:Place(24, 2, l_b)
end

----------------------------------------------------------------------------------

function Data:Place(where, count, color)
   local l_Field = self.mFields:at(where)
   for i = 1, count do
      l_Field:place_stone(Stone:new(color))
   end
end
      
----------------------------------------------------------------------------------

function Data:field_iterator()
   return self.mFields:fwd_iterator()
end

