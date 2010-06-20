require("sm_loader")
require("Source.Data")

--================================================================================

----------------------------------------------------------------------------------

local function UpperIndices()
   local l_upper = {}
   for i = 13, 18 do
      table.insert(l_upper, i)
   end
   table.insert(l_upper, "|")
   for i = 19, 24 do
      table.insert(l_upper, i)
   end
   return table.concat(l_upper, " ")
end

----------------------------------------------------------------------------------
-- small helper to make a 6 to a "06"
local function double(i) 
   if #tostring(i) == 1 then
      return "0"..i
   else
      return i
   end
end

----------------------------------------------------------------------------------

local function LowerIndices()
   local l_lower = {}
   for i = 12, 7, -1 do
      table.insert(l_lower, double(i))
   end
   table.insert(l_lower, "|")
   for i = 6, 1, -1 do
      table.insert(l_lower, double(i))
   end
   return table.concat(l_lower, " ")
end
      
--================================================================================

Class{"View", mData = Data}

----------------------------------------------------------------------------------

function View:new(rData)
   local New = View._super.new(self)
   New.mData = rData
   return New
end

----------------------------------------------------------------------------------

function View:StoneIters()
   local l_Iters = {}
   local l_FieldIter = self.mData:field_iterator()
   local KBottomUp = true
   for i = 1, 24 do
      l_Iters[i] = l_FieldIter():stone_iterator(KBottomUp)
   end
   return l_Iters
end

----------------------------------------------------------------------------------

function View:plot()
   local l_lines = {}
   l_lines[1] = UpperIndices()
   l_lines[13] = LowerIndices()
   local l_StoneIters = self:StoneIters()
   for i = 2, 6 do
      local l_SymbolTable = {}

      for j = 13, 18 do
	 local l_Stone = l_StoneIters[j]()
	 local l_Symbol = l_Stone and l_Stone:Symbol() or " "
	 table.insert(l_SymbolTable, l_Symbol.." ")
      end
      table.insert(l_SymbolTable, "|")
      for j = 19, 24 do
	 local l_Stone = l_StoneIters[j]()
	 local l_Symbol = l_Stone and l_Stone:Symbol() or " "
	 table.insert(l_SymbolTable, l_Symbol.." ")
      end
      l_lines[i] = table.concat(l_SymbolTable, " ")
   end

   l_lines[7] = ""

   for i = 12, 8, -1 do
      local l_SymbolTable = {}

      for j = 12, 7,  -1 do
	 local l_Stone = l_StoneIters[j]()
	 local l_Symbol = l_Stone and l_Stone:Symbol() or " "
	 table.insert(l_SymbolTable, l_Symbol.." ")
      end
      table.insert(l_SymbolTable, "|")
      for j = 6, 1,  -1 do
	 local l_Stone = l_StoneIters[j]()
	 local l_Symbol = l_Stone and l_Stone:Symbol() or " "
	 table.insert(l_SymbolTable, l_Symbol.." ")
      end
      l_lines[i] = table.concat(l_SymbolTable, " ")
   end

   l_lines[14] = "Geschlagene Steine:"
   local KUp = true
   for stone in self.mData.mOutField:stone_iterator(KUp) do
      l_lines[14] = l_lines[14].." "..stone:Symbol()
   end

   local l_DrawString = "ist am Zug und hat nutzbar Würfelwerte:"
   local l_Player = self.mData.mCurrentPlayer
   local l_Time = " , Spielzeit 0 s."
   local l_AsTable = {l_Player, l_DrawString}
   for i in self.mData.mDices.mDices:fwd_iterator() do
      table.insert(l_AsTable, i)
   end
   table.insert(l_AsTable, l_Time)
   l_lines[15] = table.concat( l_AsTable, " ")

   for _, v in ipairs(l_lines) do
      print(v)
   end
end
