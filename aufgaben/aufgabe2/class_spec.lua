require 'lspec'
require 'class'
LSpec:setup()
----------------------------------------------------------------------------------
it("should not be possible to create a class called Object",
   function()
      success = pcall(Class,{'Object'})
      return success == false
   end)
----------------------------------------------------------------------------------
it("should not be possible to create a class called Class",
   function()
      success = pcall(Class,{'Class'})
      return success == false
   end)
----------------------------------------------------------------------------------
it("should not be possible to create a class called Instance",
   function()
      success = pcall(Class,{'Instance'})
      return success == false
   end)
----------------------------------------------------------------------------------
it("should not be possible to create a class called Boolean",
   function()
      success = pcall(Class,{'Boolean'})
      return success == false
   end)
----------------------------------------------------------------------------------
it("should not be possible to create a class called String",
   function()
      success = pcall(Class,{'String'})
      return success == false
   end)
----------------------------------------------------------------------------------
it("should not be possible to create a class called Number",
   function()
      success, message = pcall(Class,{'Number'})
      return success == false and string.find(message,"This class can't")
   end)
----------------------------------------------------------------------------------
it("should not",
   function()
      return false
   end)

LSpec:teardown()