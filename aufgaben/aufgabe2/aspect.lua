require 'class_aspect_shared'


function print_usage()
   print("Syntax:\
	 Aspect{'Name',\
		adapts = {klass, klass2},\
		before = {aspect_func = 'regex-pattern', 2nd_func = 'w%'}\
		after  = {aspect_func = 'regex-pattern', 2nd_func = 'w%'}}")
end

--================================================================================

function wrong_class_list_error()
   print_usage()
   error("Wrong class list supplied")
end

--================================================================================

function front(t)
   return table.remove(t, 1)
end

--================================================================================

----------------------------------------------------------------------------------

function Aspect(argv)
   local aspect = {}
   aspect._name = n_aspect:validated_decl_name(front(argv))
   aspect._adaptees = n_aspect:validated_adaptees(argv.adapts,klass)
   aspect._aspect_attributes =  n_aspect:validated_attributes(argv.attributes, aspect)
   aspect._before_pattern = n_aspect:validated_function_map(argv.before)
   aspect._after_pattern = n_aspect:validated_function_map(argv.after)
   setmetatable(aspect._before_pattern, { __index = n_pattern.find })
   setmetatable(aspect._after_pattern, { __index = n_pattern.find })

   n_aspect:publish(aspect._name, aspect)
   setmetatable(aspect, n_aspect_methods.mt)
   return aspect
end

----------------------------------------------------------------------------------
n_aspect = {}
setmetatable(n_aspect, {__index = n_class_aspect})
----------------------------------------------------------------------------------

function n_aspect:validated_adaptees(class_list)
   if type(class_list) ~= "table" then
      wrong_class_list_error()
   end
   for _, v in pairs(class_list) do
      if type(v) ~= "table" or not v._classname then
	 wrong_class_list_error()
      end
   end
   return class_list
end

----------------------------------------------------------------------------------

function n_aspect:check_attr(attrs, aspect)
   for name, decl_type in pairs(attrs) do
      if type(decl_type) ~= "table" then
	 wrong_type_decl_error(name, decl_type)
      else
	 self:redeclare_check(aspect, name, decl_type)
      end      
   end
end

----------------------------------------------------------------------------------

function n_aspect:is_assignable(aspect, name, type)
   return self:check_can_be_assigned(aspect._adaptees, name, type)
end

----------------------------------------------------------------------------------

function n_aspect:check_can_be_assigned(adaptees, name, declared)
   if adaptees == nil then 
      return 
   end

   for _, klass in pairs(adaptees) do
      local existing = klass[name]
      if existing and not existing:redeclarable_with(declared) then
	 return existing
      end
   end
end

----------------------------------------------------------------------------------

function n_aspect:make_attributes(attrs, aspect)
   return self:check_and_create_attributes(attrs, aspect)
end

----------------------------------------------------------------------------------

function n_aspect:validated_function_map(mapping)
   local _mapping = {}
   if mapping == nil then
      return _mapping
   end

   for k, v in pairs(mapping) do
      if type(k) ~= "string" or type(v) ~= "string" then
	 error("Wrong function mapping")
      end
      _mapping[v] = k
   end
   return _mapping
end

----------------------------------------------------------------------------------
n_aspect_methods = {}
n_aspect_methods.mt = {}

----------------------------------------------------------------------------------

function n_aspect_methods:delete()
   _G[self._classname] = nil
end

----------------------------------------------------------------------------------

function n_aspect_methods:enable()
   for _, klass in pairs(self._adaptees) do
      klass:_enable_aspect(self)
   end
end

----------------------------------------------------------------------------------

function n_aspect_methods:disable()
   for _, klass in pairs(self._adaptees) do
      klass:_disable_aspect(self)
   end
end


----------------------------------------------------------------------------------

Wrapper = {}
Wrapper._classname = "AspectWrapper"
Wrapper.mt = {}
function Wrapper.mt:__call(...)
   print("Called with ")
   print(unpack(...))
   local wd = self
   if wd.before ~= nil then
      local func = wd.aspect[wd.before]
      func(wd.aspect, unpack(...))
   end
   assert(wd.func ~= nil)
   wd.func(argv[1], ...)
   if wd.after ~= nil then
      local func = wd.aspect[wd.after]
      func(wd.aspect, unpack(arg))
   end
end

function Wrapper.mt:__index(key)
   return Wrapper[key]
end

function Wrapper:set_func(func)
   self.func = func
end

function Wrapper:_default_value()
   return Wrapper.mt.__call
end

----------------------------------------------------------------------------------

function Wrapper:new(aspect, before, after)
   local wd = {}
   wd.aspect = aspect
   wd.before = before
   wd.after = after
   function call_chain(inst, arg)
      print("Called with ")
      print(arg)
      if wd.before ~= nil then
	 local func = wd.aspect[wd.before]
	 func(wd.aspect, arg)
      end
      assert(wd.func ~= nil)
      wd.func(inst, arg)
      if wd.after ~= nil then
	 local func = wd.aspect[wd.after]
	 func(wd.aspect, arg)
      end
   end
   local wrapped = Function:new(call_chain)
   function wrapped:set_func(func)
      wd.func = func
   end
   wrapped._classname = "AspectWrapper"
   return wrapped
end

----------------------------------------------------------------------------------

function n_aspect_methods.mt:__index(key)
   local match_bef = self._before_pattern[key]
   local match_aft = self._after_pattern[key]
   if match_bef or match_aft then
      return Wrapper:new(self, match_bef, match_aft)
   else
      return self._aspect_attributes[key]
	 or n_aspect_methods[key]
   end
end

----------------------------------------------------------------------------------

function n_aspect_methods.mt:__newindex(key, value)
   if type(value) ~= "function" then
      error("You can only define functions")
   end
   self._aspect_attributes[key] = Function:new(value)
end

----------------------------------------------------------------------------------
n_pattern = {}
----------------------------------------------------------------------------------

function n_pattern:find(key)
   for pat, func in pairs(self) do
      if key == string.match(key, pat) then
	 return func
      end
   end
end
   
