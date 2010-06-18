require("sm_loader")
require("Data")
--================================================================================

Class{"View", mData = BackGammonData}

----------------------------------------------------------------------------------

function View:plot()
   local iter = self.mData:field_iterator()
   local field = iter()
   while field do
      self:plotField(field)
      field = iter()
   end
end

----------------------------------------------------------------------------------

function View:plotField(field)
   local iter = field:stone_iterator()
   local stone = iter()
   while stone do
      print(stone:Symbol())
      stone = iter()
   end
end

----------------------------------------------------------------------------------

function View:set_data(data)
   self.mData = data
end
