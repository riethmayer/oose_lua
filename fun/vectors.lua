Vector = {}
_VectorBehavior = {
   __add = function(v1,v2)
              --valid_for_add(v1,v2)
              local result = Vector:new()
              for i,v in ipairs(v1) do
                 result[i] = v1[i] + v2[i]
              end
              return result
           end
}

function valid_for_add(v1,v2)
   result = is_vector(v1) and is_vector(v2) and (#v1 == #v2)
   return result
end

function is_vector(v)
   return v._class == Vector
end

function unless(val)
   return (val ~= true)
end

function Vector:new(...)
   local o = setmetatable({}, _VectorBehavior)
   for i,v in ipairs(arg) do
      o[i] = v
   end
   o._class = self
   return o
end
