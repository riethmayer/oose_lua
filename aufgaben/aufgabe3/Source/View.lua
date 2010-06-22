require("sm_loader")
root_require("aufgabe3.Source.Data")

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
----------------------------------------------------------------------------------

local function Invert(t)
   local l_inv = {}
   for i, line in pairs(t) do
      local l_ins = #t + 1 - i
      table.insert(l_inv, l_ins, line)
   end
   return l_inv
end

----------------------------------------------------------------------------------

local function Join(...)
   local l_joint = {}
   local l_args = {...}
   for _, v in pairs(l_args) do
      for _, line in pairs(v) do
	 table.insert(l_joint, line)
      end
   end
   return l_joint
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

function View:StoneIters(left, right)
   local l_low = left < right and left or right
   local l_high = left < right and right or left
   local l_Iters = {}
   local KBottomUp = true
   for i = l_low, l_high do
      l_Iters[i] = self.mData.mFields:at(i):stone_iterator(KBottomUp)
   end
   return l_Iters
end

----------------------------------------------------------------------------------

function View:Beaten()
   local l_line = "Geschlagene Steine:"
   local KUp = true
   for stone in self.mData.mOutField:stone_iterator(KUp) do
      l_line = l_line.." "..stone:Symbol()
   end
   return l_line
end

----------------------------------------------------------------------------------

function View:Info()
   local l_Table = {}
   l_Table[1] = self.mData.mCurrentPlayer.." ist am Zug und hat nutzbare Würfelwerte:"
   for val in self.mData.mDices.mDices:fwd_iterator() do
      table.insert(l_Table, val)
   end
   local l_TimeString = " , Spielzeit"..self.mData:TimeDiff().." s."
   table.insert(l_Table, l_TimeString)
   return table.concat(l_Table, " ")
end

----------------------------------------------------------------------------------

function View:plot()
   local KUpper = true
   local l_UpperBar = {UpperIndices()}
   local l_UpperHalf = self:PlotHalf(KUpper)
   local l_LowerHalf = self:PlotHalf(not KUpper)
   local l_LowerBar = {LowerIndices()}
   local l_FreeLine = {""}
   local l_Beaten = {self:Beaten()}
   local l_Info = {self:Info()}

   local l_lines = Join(l_UpperBar, l_UpperHalf, l_FreeLine,
	l_LowerHalf, l_LowerBar, l_Beaten, l_Info)

   for _, v in pairs(l_lines) do
      print(v)
   end
end

----------------------------------------------------------------------------------

function View:PlotHalf(Upper)
   local l_lines  = {}
   local l_Left = Upper and 13 or 12
   local l_Right = Upper and 24 or 1
   local l_Middle = Upper and 18 or 7
   local l_StoneIters = self:StoneIters(l_Left, l_Right)
   local l_Stride = Upper and 1 or -1

   while true do
      local l_SymbolTable = {}

      for j = l_Left, l_Middle, l_Stride do
	 local l_Stone = l_StoneIters[j]()
	 local l_Symbol = l_Stone and l_Stone:Symbol() or " "
	 table.insert(l_SymbolTable, l_Symbol.." ")
      end
      table.insert(l_SymbolTable, "|")
      for j = l_Middle + l_Stride, l_Right, l_Stride do
	 local l_Stone = l_StoneIters[j]()
	 local l_Symbol = l_Stone and l_Stone:Symbol() or " "
	 table.insert(l_SymbolTable, l_Symbol.." ")
      end
      local l_line = table.concat(l_SymbolTable, " ")
      
      if not l_line:find("%u") then 
	 break
      end
      table.insert(l_lines, l_line)
   end

   return Upper and l_lines or Invert(l_lines)
end
