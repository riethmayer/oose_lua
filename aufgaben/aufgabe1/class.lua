function Class(arg)
   local klass       = {}
   klass._name       = arg[1]
   klass._super      = to_class(arg[2])
   klass._attributes = {}
   -- cleanup used arguments
   arg[1], arg[2]  = nil, nil
   for k,v in pairs(arg) do
      if(is_valid_class(v) and is_valid_attribute(klass._attributes, k, v)) then
         klass._attributes[k] = v
      end
   end
   local mt = {
      __index = function(o,k)
                   if(o._attributes[k]) then
                      return o._attributes[k]
                   else
                      return o._name[k]
                   end
                end,
      __tostring = function(o)
                      return o._name
                   end
   }
   setmetatable(klass, mt)
   klass.new = function()
                  return klass
               end
   _G[klass._name] = klass
end
-- receives a string, returns a class or nil, if undefined.
function to_class(klass)
   if(is_valid_class(klass)) then 
      return _G[klass]                       
   else
      -- TODO how to return an error? This doesn't work.
      if(type(klass) ~= "nil") then 
         error("unsupported Class definition")
      else
         return nil
      end
   end
end
-- lookup in global namespace
function is_valid_class(klass)
   klass = tostring(klass)
   if(type(_G[klass]) == "table") then 
      return true
   else
      return false
   end
end
-- returns false if _attributes contains a defined attribute with mismatching class
function is_valid_attribute(attributes, name, klass)
   if(attributes[name] and attributes[name] ~= klass) then
      return false
   else
      return true
   end
end