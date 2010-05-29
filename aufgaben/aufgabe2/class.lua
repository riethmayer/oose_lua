require 'class_aspect_shared'
require 'instance'
require 'self_super_trap'

--  Usage: Class{'<classname>' [, <superclass>] [, <variable> = <type>]+ }
--    * classname (mandatory):
--      - must not be Object
--      - if classname already exists it will be overwritten
--    * superclass (optional):
--      - must be a valid class, which has been created with Class
--      - defaults to Object
--    * instance variables (optional)
--      instance variables are key value pairs, with a variable name and a type
--      the variable name may be defined in a superclass. If this is the case
--      the type for the defined variable must be compatible with the superclass's
--      variable type.
--
--      1. Example:
--        Class{'Foo', foo = Foo }
--        Class{'Bar', Foo, foo = Bar } should be fine. As Bar derives from Foo.
--
--      2. Example:
--        Class{'Foo' }
--        Class{'Bar', foo = Foo }
--        Class{'Baz', Bar, foo = Bar } must return an error, as Foo and Bar have
--        nothing in common.
----------------------------------------------------------------------------------

function call_chain(...)
   local functions = arg
   return
   function(...)
      for _, func in ipairs(arg) do
	 func(...)
      end
   end
end

----------------------------------------------------------------------------------

function class_hook(global_table, key)
   assert(_G == global_table)
   if key == "Class" then
      recording_global_forward_decls = true
      return class_impl
   end
   if recording_global_forward_decls then
      return key
   end
end

----------------------------------------------------------------------------------

function verify_restricted_new(global_table, key, value)
   assert(_G == global_table)
   local reserved_names =
      {"Class", "Object", "Function", "ClassRef", "Instance",
       "Boolean", "String", "Number"}
   for _, v in pairs(reserved_names) do
      assert(key ~= v)
   end
   rawset(_G, key, value)
end

----------------------------------------------------------------------------------

recording_global_forward_decls = false

----------------------------------------------------------------------------------

function set_global_indexhook()
   old_meta = getmetatable(_G)
   new_meta = old_meta or {}
   local prev_index_func = new_meta.__index
   if prev_index_func then
      new_meta.__index = call_chain(class_hook, prev_index_func)
   else
      new_meta.__index = class_hook
   end
   local prev_newindex_func = new_meta.__newindex
   if prev_newindex_func then
      new_meta.__newindex = call_chain(verify_restricted_new, prev_newindex_func)
   else
      new_meta.__newindex = verify_restricted_new
   end
   setmetatable(_G, new_meta)
end

----------------------------------------------------------------------------------

set_global_indexhook()

--================================================================================

function print_usage()
   print("Syntax:\
	 Class{'Name',\
	       attribute_name = Type,\
	       attr1 = Boolean,\
	       attr2 = String,\
	       attr3 = Number,\
	       attr4 = OtherClass}")
end

--================================================================================

function wrong_type_decl_error(name, decl_type)
   local message = "Member "..(name or "unknown").." declared with incomaptible\
     type: "..type(decl_type)..", only classes allowed."
   error(message)
end

--================================================================================

function wrong_type_assign_error(ex_type, decl_type)
   local message = "Member "..(name or "unknown").." declared with incomaptible\
     tpye: "..type(decl_type)..". Exisiting of type "..ex_type.classname.."."
   error(message)
end

--================================================================================

function wrong_super_class_error(super_class)
   local message = "Wrong super class of type "..type(super_class).." / "
     ..(super_class and super_class.classname or "").."."
   error(message)
end

--================================================================================

function front(t)
   return table.remove(t, 1)
end

--================================================================================

----------------------------------------------------------------------------------

function class_impl(argv)
   recording_global_forward_decls = false

   local klass = {}
   klass._classname = n_class:validated_decl_name(front(argv))
   klass._super = n_class:validated_superclass(front(argv), klass) or Object
   klass._class_attributes = n_class:validated_attributes(argv,klass)
   klass._aspects = {}
   setmetatable(klass._aspects, n_aspect_array_methods.mt)

  -- n_class:delegate_to_class_methods(klass)

   n_class:publish(klass._classname, klass)
   setmetatable(klass, n_class_methods.mt)
   return klass
end

----------------------------------------------------------------------------------
n_class = {}
setmetatable(n_class, {__index = n_class_aspect})
----------------------------------------------------------------------------------

function n_class:validated_superclass(super_class, klass)
   if super_class and (type(super_class) ~= "table"
		    or not super_class._classname
		    or super_class:has_ancestor(klass)) then
      wrong_super_class_error(super_class)
   end
   return super_class
end

-- Point of customisation

----------------------------------------------------------------------------------

function n_class:check_attr(argv, klass)
   for name, decl_type in pairs(argv) do
      if type(decl_type) ~= "table" and decl_type ~= klass._classname then
	 wrong_type_decl_error(name, decl_type)
      else
	 self:redeclare_check(klass, name, decl_type)
      end
   end
end

----------------------------------------------------------------------------------

function n_class:is_assignable(klass, name, type)
   return self:check_can_be_assigned(klass._super[name], type)
end


----------------------------------------------------------------------------------

function n_class:check_can_be_assigned(existing, declared)
   if existing and not existing:redeclarable_with(declared) then
      return existing
   end
end

----------------------------------------------------------------------------------

function n_class:make_attributes(argv, klass)
   local attr = self:get_forward_decls(argv, klass)
   return self:check_and_create_attributes(argv, klass, attr)
end

----------------------------------------------------------------------------------

function n_class:get_forward_decls(argv, klass)
   local attr = {}
   for name, decl_type in pairs(argv) do
      if decl_type == klass._classname then
	 argv[name] = nil
	 attr[name] = ClassRef:new(klass)
      end
   end
   return attr
end

----------------------------------------------------------------------------------
n_class_methods = {}
n_class_methods.mt = {}
----------------------------------------------------------------------------------

function n_class_methods:_enable_aspect(aspect) 
   self._aspects:append(aspect)
end

----------------------------------------------------------------------------------

function n_class_methods:_disable_aspect(aspect)
   self._aspects:remove(aspect)
end

----------------------------------------------------------------------------------

function n_class_methods:delete()
   _G[self._classname] = nil
end

----------------------------------------------------------------------------------

function n_class_methods.mt:__index(key)
   local wrapper = self._aspects:pattern_wrapper(key)
   
   func_attr = self._class_attributes[key]
      or self._super and self._super[key]
      or n_class_methods[key]

   assert(not wrapper or func_attr)
   if wrapper then
      assert(func_attr._classname == "Function")
      wrapper:set_func(func_attr)
      return wrapper
   else
      return func_attr
	 or self._aspects[key]
   end
end

----------------------------------------------------------------------------------

function n_class_methods.mt:__newindex(key, value)
   if type(value) ~= "function" then
      error("You can only define functions")
   end
   self._class_attributes[key] = Function:new(value)
end

----------------------------------------------------------------------------------
n_aspect_array_methods = {}
n_aspect_array_methods.mt = {}
----------------------------------------------------------------------------------

function  n_aspect_array_methods:append(aspect)
   local pos = self:find_aspect_pos(aspect)
   assert(pos == nil)
   table.insert(self, aspect)
end


----------------------------------------------------------------------------------

function  n_aspect_array_methods:remove(aspect)
   local pos = self:find_aspect_pos(aspect)
   assert(pos ~= nil)
   table.remove(self, pos)
end

----------------------------------------------------------------------------------

function  n_aspect_array_methods:find_aspect_pos(aspect)
   for i,v in ipairs(self) do
      if v == aspect then
	 return i
      end
   end
end

----------------------------------------------------------------------------------

function n_aspect_array_methods:find_key(key)
   local found_key = nil
   for i,v in ipairs(self) do
      local has_key = v[key]
      if has_key ~= nil then
	 found_key = has_key
      end
   end
   return found_key
end

----------------------------------------------------------------------------------

function n_aspect_array_methods:pattern_wrapper(key)
   local ret = self:find_key(key)
   if ret and ret._classname == "AspectWrapper" then
      return ret
   end
end

----------------------------------------------------------------------------------

function n_aspect_array_methods.mt:__index(key)
   return n_aspect_array_methods[key]
      or self:find_key(key)
end

----------------------------------------------------------------------------------

function n_aspect_array_methods.mt:__newindex(key, value)
   error("Don't insert aspects directly, but call append")
end