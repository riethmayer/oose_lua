if not __loaded then
   require("sm_loader")
end

Class{"Stone", mColor = String}
function Stone:new(Color)
   local New = Stone._super.new(self)
   New.mColor = Color
   return New
end
function Stone:Color()
   return self.mColor
end
function Stone:Symbol()
   return self.mColor == "white" and "#" or
      self.mColor == "black" and "X"
end
Class{"Field", mStones = Array}
function Field:new()
   local New = Field._super.new(self)
   New.mStones = Array:new(Stone)
   return New
end

Class{"Dices", mDice1 = Number, mDice2 = Number}
Class{"BackGammonData", mFields = Array, mDices = Dices}
function BackGammonData:new()
   local New = BackGammonData._super.new(self)
   New.mFields = Array:new(Field)
   for i = 1, 24 do
      New.mFields:push_back(Field:new())
   end
   New.mDices = Dices:new()
   return New
end

function InitBackGammon(bg)
   local Field = bg.mFields:size()
   bg.mFields:at(1).mStones:push(Stone:new("white"))
   bg.mFields:at(1).mStones:push(Stone:new("white"))
   bg.mFields:at(1).mStones:push(Stone:new("white"))
   bg.mFields:at(1).mStones:push(Stone:new("white"))
   bg.mFields:at(1).mStones:push(Stone:new("white"))
   bg.mFields:at(5).mStones:push(Stone:new("black"))
   bg.mFields:at(5).mStones:push(Stone:new("black"))
end

---[[[

Class{"View", m_data = BackGammonData}
function View:plot()
   local iter = self.m_data.mFields:fwd_iterator()
   local field = iter()
   while field do
      self:plotField(field)
      field = iter()
   end
end
function View:plotField(field)
   local iter = field.mStones:iterator()
   local stone = iter()
   while stone do
      print(stone:Symbol())
      stone = iter()
   end
end

---]]]
v = View:new()
bgd = BackGammonData:new()
InitBackGammon(bgd)
v.m_data = bgd
v:plot()
