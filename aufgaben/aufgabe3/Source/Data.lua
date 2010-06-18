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
   return self.mColor == "white" and "#" or
      self.mColor == "black" and "X"
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

function Field:stone_iterator()
   return self.mStones:iterator()
end

--================================================================================

Class{"Dices", mDice1 = Number, mDice2 = Number}

--================================================================================

Class{"BackGammonData", mFields = Array, mDices = Dices}

----------------------------------------------------------------------------------

function BackGammonData:new()
   local New = BackGammonData._super.new(self)
   New.mFields = Array:new(Field)
   for i = 1, 24 do
      New.mFields:push_back(Field:new())
   end
   New.mDices = Dices:new()
   return New
end

----------------------------------------------------------------------------------

function BackGammonData:field_iterator()
   return self.mFields:fwd_iterator()
end

