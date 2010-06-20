require("sm_loader")
require("Source.Controller")
require("Source.Dispatcher")
require("Source.FrontEnd")
require("Source.Data")
require("Source.View")

--================================================================================

----------------------------------------------------------------------------------

Class{"Backgammon"}

function Backgammon:new()
   local l_data = Data:new()
   local l_view = View:new(l_data)
   local l_cont = Controller:new(l_data, l_view)
   local l_disp = Dispatcher:new(l_cont)
   l_data:Init()
   return FrontEnd:new(l_disp)
end
