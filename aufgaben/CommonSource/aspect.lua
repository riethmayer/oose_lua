--[[
Kilian Müller  210473
Jan Riethmayer    310326
Martin Nowak 302066
]]--

--================================================================================
----------------------------------------------------------------------------------
n_aspect = {}
setmetatable(n_aspect, {__index = n_class_aspect})
----------------------------------------------------------------------------------

function n_aspect:print_usage()
   print("Syntax:\
	 Aspect{'Name',\
		adapts = {klass, klass2},\
		before = {aspect_func = 'regex-pattern', 2nd_func = 'w%'}\
		after  = {aspect_func = 'regex-pattern', 2nd_func = 'w%'}}")
end

--================================================================================

function wrong_class_list_error(obj)
   obj:print_usage()
   error("Wrong class list supplied")
end

--================================================================================

function front(t)
   return table.remove(t, 1)
end

--================================================================================

----------------------------------------------------------------------------------

function Aspect(argv)
   n_aspect:validate_arguments(argv)
   local aspect = {}
   aspect._name = n_aspect:validated_decl_name(front(argv))
   aspect._adaptees = n_aspect:validated_adaptees(argv.adapts,klass)
   aspect._aspect_attributes =  n_aspect:validated_attributes(
      argv.attributes, aspect)

   aspect._before_pattern = n_aspect:validated_function_map(argv.before)
   aspect._after_pattern = n_aspect:validated_function_map(argv.after)
   setmetatable(aspect._before_pattern, n_pattern.mt)
   setmetatable(aspect._after_pattern, n_pattern.mt)

   n_aspect:publish(aspect._name, aspect)
   setmetatable(aspect, n_aspect_methods.mt)
   return aspect
end

----------------------------------------------------------------------------------

function n_aspect:validate_arguments(argv)
   local allowed_keys = {"1","attributes", "before", "after", "adapts"}
   setmetatable(allowed_keys, {__index = n_string_array_methods})
   for k, v in pairs(argv) do
      if not (type(k) == "string" and allowed_keys:contains(k)
	or type(k) == "number" and k == 1) then
	 self:print_usage()
	 error("Wrong aspect keyword "..k)
      end
   end
end
      
----------------------------------------------------------------------------------

function n_aspect:validated_adaptees(class_list)
   if type(class_list) ~= "table" then
      self:wrong_class_list_error()
   end

   for _, v in pairs(class_list) do
      if type(v) ~= "table" or not v._classname then
	 self:wrong_class_list_error()
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

   for asp_func, pattern in pairs(mapping) do
      if type(asp_func) ~= "string" or type(pattern) ~= "string" then
	 error("Wrong function mapping")
      end
      _mapping[asp_func] = pattern
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
Class{"NamedFunc", mFunc = Function, mName = String}
----------------------------------------------------------------------------------
function NamedFunc:new(Func, FuncName)
   local New = NamedFunc._super.new(self)
   New.mFunc = Func
   New.mName = FuncName
   return New
end
----------------------------------------------------------------------------------
n_wrapper = {}
----------------------------------------------------------------------------------

local function append_var(ta, elem)
   table.insert(ta, elem)
   return unpack(ta)
end

function n_wrapper.new(klass, before, middle, after)
   local wd = {}
   wd.before = before
   wd.middle = middle
   wd.after = after

   function call_order(...)
      while wd.before[1] ~= nil do
	 local func = front(wd.before)
	 local ret = func(append_var({...}, func.mName))
	 assert(ret == nil or type(ret) == "boolean")
	 if ret == false then
	    return
	 end
      end
      assert(wd.middle ~= nil)
      wd.middle(...)
      while wd.after[1] ~= nil do
	 local func = front(wd.after)
	 func(append_var({...}, func.mName))
      end
   end

   local wrapped = Function:new(call_order)
   return wrapped
end

----------------------------------------------------------------------------------

function n_wrapper.build_functions(klass, func_names, key)
   local funcs = {}
   for i, v in ipairs(func_names) do
      local l_func = klass[v]
      funcs[i] = Function:new(l_func._default_value(), key)
   end
   return funcs
end

----------------------------------------------------------------------------------

function n_aspect_methods:wrap_func(klass, func, key)
   local match_bef = self._before_pattern:build_rev(key)
   local match_aft = self._after_pattern:build_fow(key)

   if match_bef[1] ~= nil or match_aft[1] ~= nil then
      local bef_funcs = n_wrapper.build_functions(klass, match_bef, key)
      local aft_funcs = n_wrapper.build_functions(klass, match_aft, key)
      return n_wrapper.new(klass, bef_funcs, func, aft_funcs)
   else
      return func
   end
end

----------------------------------------------------------------------------------

function n_aspect_methods.mt:__index(key)
   return self._aspect_attributes[key]
      or n_aspect_methods[key]
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
n_pattern.mt = {__index = n_pattern}
----------------------------------------------------------------------------------

function n_pattern:build_fow(key)
   local chain = {}
   for func, pat in pairs(self) do
      if key == string.match(key, pat) then
	 table.insert(chain, func)
      end
   end
   return chain
end

----------------------------------------------------------------------------------

function n_pattern:build_rev(key)
   local chain = {}
   for func, pat in pairs(self) do
      if key == string.match(key, pat) then
	 table.insert(chain, 1, func)
      end
   end
   return chain
end

