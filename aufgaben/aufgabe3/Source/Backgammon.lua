require("sm_loader")
root_require("aufgabe3.Source.Controller")
root_require("aufgabe3.Source.Dispatcher")
root_require("aufgabe3.Source.FrontEnd")
root_require("aufgabe3.Source.Data")
root_require("aufgabe3.Source.View")

--================================================================================

----------------------------------------------------------------------------------

Class{"Backgammon"}

function Backgammon:new()
   local l_data = Data:new()
   local l_view = View:new(l_data)
   local l_cont = Controller:new(l_data, l_view)
   local l_disp = Dispatcher:new(l_cont)
   return FrontEnd:new(l_disp)
end
