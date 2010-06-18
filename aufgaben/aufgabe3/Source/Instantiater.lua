require("sm_loader")
require("View")
require("Data")

--================================================================================

----------------------------------------------------------------------------------
-- par example
function InitBackGammon(bg)
   bg.mFields:at(1).mStones:push(Stone:new("white"))
   bg.mFields:at(1).mStones:push(Stone:new("white"))
   bg.mFields:at(1).mStones:push(Stone:new("white"))
   bg.mFields:at(1).mStones:push(Stone:new("white"))
   bg.mFields:at(1).mStones:push(Stone:new("white"))
   bg.mFields:at(5).mStones:push(Stone:new("black"))
   bg.mFields:at(5).mStones:push(Stone:new("black"))
end

----------------------------------------------------------------------------------

v = View:new()
data = BackGammonData:new()
InitBackGammon(data)
v:set_data(data)

v:plot()
