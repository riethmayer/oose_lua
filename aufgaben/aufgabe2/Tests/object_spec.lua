require("loader")

Class{'A'}
function A:print()
   print("A")
end
Class{'B', A}
function B:print()
   print("B")
   super:print()
end
Class{'C', B}
function C:print()
   print("C")
   super:print()
end
o = C:new()
o:print()