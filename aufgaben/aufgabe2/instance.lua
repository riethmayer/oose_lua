require 'object'

-- instance behavior
-- Instance is no class, it's a helper to create instances for a given class.
-- klass is the 'Foo' in Foo:new()
Instance = {}
function Instance:new(klass,params)
   -- allow object instantiation
   if klass == Object then
      local o = Object:new()
      return o
   end
   -- the object with it's class and 
   local object = {
      _class = klass,
      _super = validate_superclass(klass,params),
   }
   local class_method_lookup = {
      __index = function(self,key)
                   return object._class[key] 
                end 
   }
   setmetatable(object, class_method_lookup)
   return object
end

----------------------------------------------------------------------------------
function validate_superclass(klass,params)
   return Object
end

-- function build_instance(self, argv, klass)
--    -- instantiate super class and add attributes

--    local instance = klass._super.new(self, argv)
--    -- instantiate attributes for current class
--    instance._attributes = build_attributes(instance, klass._attributes) or {}
--    --
--    local before_filter = Logger
--    local after_filter = {}

--    local aspect_before_filter = {
--       __index = before_filter._attributes
--    }
--    local aspect_after_filter = {
--       Logger, Benchmark
--    }
   
--    local instance_behavior = {
--       __index = self._attributes
--    }
--    local class_metatable = {
--       __index = self._class.classname
--    }

--    setmetatable(instance, aspect_before_filter)
--    setmetatable(instance.aspect_before_filter, instance_behavior)
--    setmetatable(instance.instance_behavior, aspect_after_filter)
--    setmetatable(instance.aspect_after_filter, class_metatable)

-- --    setmetatable(instance,             instance_behavior)
-- --    setmetatable(instance._attributes, class_metatable)
--    return instance
-- end
-- ----------------------------------------------------------------------------------
-- -- function build_attributes(instance, class_attributes)
-- --    for attribute_name, attribute_class in pairs(class_attributes) do
-- --       if can_assign_type(instance, attribute_name, attribute_class) then
-- --          return true
-- --       else
         
-- --       if is_superclass(instance[attribute_name], attribute_class) then
         
-- --          instance[attribute_name] = attribute_class:new()
-- --          or type_mismatch( attribute_class, instance[attribute_name]._class )
-- --    else
-- --       instance[attribute_name] = attribute_class:new()
-- --    end
-- -- end
-- -- return instance._attributes
-- -- end

-- -- function assign_type_checked(instance, name, type)
-- --    if   instance[name]:is_super_of(type) then
-- --       return true
-- --    else

