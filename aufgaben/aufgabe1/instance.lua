require 'object'

-- instance behavior
function Instance(klass,...)
   local instance = {}   
      self, -- The 'Foo' in Foo:new(args) => Foo.new('Foo', args)
      unpack(arg), -- delegates constructor arguments
      klass -- closure variables
   )
end 


function build_instance(self, argv, klass)
   -- instantiate super class and add attributes

   local instance = klass._super.new(self, argv)
   -- instantiate attributes for current class
   instance._attributes = build_attributes(instance, klass._attributes) or {}
   --
   local instance_behavior = {
      __index = function(self, key)
                   return self._attributes[key]
                end
   }
   local class_metatable = {
      __index = function(self, key)
                   return self._class.classname[key]
                end
   }
   setmetatable(instance,             instance_behavior)
   setmetatable(instance._attributes, class_metatable)
   return instance
end

function build_attributes(instance, class_attributes)
   for attribute_name, attribute_class in pairs(class_attributes) do
      if is_superclass(instance[attribute_name], attribute_class) then
         instance[attribute_name] = attribute_class:new()
         or type_mismatch( attribute_class, instance[attribute_name]._class )
   else
      instance[attribute_name] = attribute_class:new()
   end
end
return instance._attributes
end
