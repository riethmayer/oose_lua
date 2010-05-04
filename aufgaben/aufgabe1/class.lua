-- a find method
function find(o,k)
   if(o._attributes[k]) then
      return o._attributes[k]
   else
      if(o._name[k]) then
         return o._name[k]
      else
         return delegate(o,k)
      end
   end
end
-- the class itself
function Class(arg)
   local klass = {}
   klass._name       = arg[1]
   klass._super      = to_class(arg[2])
   klass._attributes = {}
   -- cleanup used arguments
   arg[1], arg[2]  = nil, nil
   local meta = {
      __index = function(o,k)
                   return find(o,k)
                end,
      __tostring = function(o)
                      return o._name
                   end
   }
   
   -- add some functionality to our class
   setmetatable(klass, meta)
   -- publish class before assigning attributes, to enable recursive definitions
   _G[klass._name] = klass
   -- now assign attributes
   for k,v in pairs(arg) do
      if(is_valid_class(v) and is_valid_attribute(klass._attributes, k, v)) then
         klass._attributes[k] = v
      end
   end
   -- class functions
   -- hmm there should be some validations for attribute assignment then right?
   klass.new = function()
                  return klass
               end
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
   if klass == nil then
      return false
   end
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
-- delegate field to superclass
function delegate(object, key)
   if object then
      if rawget(object,_super) then
         return object._super[key]
      else
         return nil
      end
   else
      return nil
   end
end
