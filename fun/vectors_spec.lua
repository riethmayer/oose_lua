require('lspec')
require('vectors')

LSpec:setup()

-- describing basic type
it("should be a Vector", 
   function()
      v= Vector:new(1,2)
      return (v._class == Vector)
   end)
it("should not be classified as vector",
   function()
      return is_vector({}) == false
   end)
it("should be classified as vector without components",
   function()
      return is_vector(Vector:new())
   end)
it("should be classified as vector with components",
   function()
      return is_vector(Vector:new(1,2))
   end)
it("should assign components",
   function()
      v1 = Vector:new(1,2)
      return v1[1] == 1 and v1[2] == 2
   end)

-- describe add
it("should add components",
   function()
      v1 = Vector:new(2,5)
      result = v1 + v1
      return (4 == result[1]) and (10 == result[2])
   end)
it("should not add vectors with different length",
   function()
      v1 = Vector:new(3,4)
      v2 = Vector:new(4)
      result = v1 + v2
      return result == nil
   end)

-- describe validation for vector operations
it("should not validate invalid tables for addition",
   function()
      v1 = Vector:new(2,5)
      v2 = {}
      result = compatible_vectors(v1,v2)
      return result == false
   end)
it("should not validate vectors with different length",
   function()
      v1 = Vector:new(1,2,3)
      v2 = Vector:new(1,2)
      result = compatible_vectors(v1,v2)
      return result == false
   end)
it("should normalize values",
   function()
      return normalize(3,4) == 5
   end)
it("should return nil for nil component",
   function()
      return normalize(3,nil) == nil and normalize(nil,1) == nil
   end)

-- vector multiplication
it("should multiply simple vectors",
   function()
      v1 = Vector:new(3)
      v2 = Vector:new(4)
      result = v1 * v2
      return result[1] == 5
   end)
it("should multiply more elaborate vectors",
   function()
      v1 = Vector:new(3,4)
      v2 = Vector:new(4,3)
      result = v1 * v2
      return result[1] == 5 and result[2] == 5
   end)
it("should not multiply vectors with different length",
   function()
      v1 = Vector:new(3,4)
      v2 = Vector:new(4)
      result = v1 * v2
      return result == nil
   end)

LSpec:teardown()