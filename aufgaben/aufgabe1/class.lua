-- Basic Object behavior which will be default behavior.
Object = {
   _super = nil,
   classname  = "Object",
   new    = function(_class)
               assert( nil ~= _class)
               local object = {_class = _class}
               local meta   = {
                  __index   = function(self,key) return _class.methods[key] end
               }
               setmetatable(object,meta)
               return object
            end,
   methods= { classname = function(self) return(self._class.classname) end }
}

function Class(argv)
   -- check for a class name
   if((not argv[1]) or (type(argv[1]) ~= "string")) then
      error("Undefined class name. Usage: Class{'ClassName'}")
   else
      classname = argv[1]
   end
   
   -- check for a super class
   -- TODO validate argv[2] as a real class
   local _super = argv[2] or Object
   
   -- define the class
   local klass = {
      _super = _super;
      classname  = classname;
      new    = function(self, ...)
                  local obj = _super.new(self);
                  setmetatable(obj, {__index = function(self, key)
                                                  return self._class[key]
                                               end
                                  });
                  return obj
               end,
      methods = {},
      attributes = setattributes(_super, argv)
   }
   -- delegation for class table access
   setmetatable(klass,{
                   __index = function(self,key)
                                return self.classname[key] or self._super[key]
                             end
                })
   -- if instance method unavailable, check super class methods
   -- this way it's cleaner to define methods within one container.
   setmetatable(klass.methods,{
                   __index = function(self,key) return klass._super.methods[key] end
                })
   _G[klass.classname] = klass
   return klass
end

function setattributes(_super,argv)
   argv[1] = nil -- name is the 1st parameter
   argv[2] = nil -- superclass is the 2nd parameter
   -- other parameters are tables which define some classes
   local result = _super.attributes or {} -- a list with defined params
   for param,klassname in pairs(argv) do
      if class_exists(klassname) and not_yet_defined(result,param, klassname) then
         result[param] = klassname
      end
   end
   return result
end

function class_exists(klassname)
   return type(klassname) == "table"
end

function not_yet_defined(given, param, klassname)
   if(given and given.param and given.param == klassname) then
      return false
   else
      return true
   end
end