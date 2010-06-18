require("sm_loader")
require 'lspec'

LSpec:setup("BaseType Tests")
----------------------------------------------------------------------------------
TEST("should have Object as superclass",
   function()
      return Boolean._super == Object and Number._super == Object and 
         String._super == Object
   end)
----------------------------------------------------------------------------------
TEST("should have classnames",
   function()
      return Boolean.classname == "Boolean" and Number.classname == "Number" and
         String.classname == "String"
   end)
----------------------------------------------------------------------------------
TEST("should be instantiatable",
   function()
      local b = Boolean:new()
      local s = String:new()
      local n = Number:new()
      return b == false and s == "" and n == 0
   end)
----------------------------------------------------------------------------------
LSpec:teardown()