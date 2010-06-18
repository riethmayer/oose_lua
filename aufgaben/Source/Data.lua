require("loader")

Class{"Stone", mColor = String}

function Stone:Color()
   return mColor
end

Class{"Field", mNumStones = Number, mStones = 