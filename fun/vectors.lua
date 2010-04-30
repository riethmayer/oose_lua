Vector = {}
function _vector_addition(v1,v2)
   if compatible_vectors(v1,v2) then
      local result = Vector:new()
      for i,v in ipairs(v1) do
         result[i] = v1[i] + v2[i]
      end
      return result
   else
      return nil
   end
end

function _vector_multiplication(v1,v2)
   if compatible_vectors(v1,v2) then
      local result = Vector:new()
      for i,v in ipairs(v1) do
         result[i] = normalize(v1[i], v2[i])
      end
      return result
   else
      return nil
   end
end

_VectorBehavior = {
   -- component wise addition
   __add = function(v1,v2) return _vector_addition(v1,v2)  end,
   -- component wise normalization
   __mul = function(v1,v2) return _vector_multiplication(v1,v2) end
}

function Vector:new(...)
   local o = setmetatable({}, _VectorBehavior)
   for i,v in ipairs(arg) do
      o[i] = v
   end
   o._class = self
   return o
end

function compatible_vectors(v1,v2)
   result = is_vector(v1) and is_vector(v2) and (#v1 == #v2)
   return result
end

function is_vector(v)
   return v._class == Vector
end

function normalize(x,y)
   if(type(x) == "number" and type(y) == "number") then
      return math.sqrt(x^2 + y^2)
   else
      return nil
   end
end