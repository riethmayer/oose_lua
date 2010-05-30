-- Shared functions of classes and aspects
-- functions defined in each module are print_usage, make_attributes, check_attr
----------------------------------------------------------------------------------

n_class_aspect = {}
----------------------------------------------------------------------------------

function n_class_aspect:validated_decl_name(decl_name)
   if not decl_name or type(decl_name) ~= "string" then
      print("declared"..decl_name)
      self:print_usage()
   end
   if _G[decl_name] then
      error("Declared name: "..decl_name.." exists already. Delete first")
   end
   return decl_name
end

----------------------------------------------------------------------------------

function n_class_aspect:validated_attributes(argv, obj)
   if argv == nil then
      return {}
   end

   self:check_attr(argv, obj)
   attributes = self:make_attributes(argv, obj)
   return attributes
end

----------------------------------------------------------------------------------

function n_class_aspect:redeclare_check(klass, name, decl_type)
   local incompat_ex = self:is_assignable(klass, name, decl_type)
   if incompat_ex ~= nil then
      wrong_type_assign_error(name, incompat_ex, decl_type)
   end
end

----------------------------------------------------------------------------------

function n_class_aspect:check_and_create_attributes(argv, obj, ex_attr)
   local attr = ex_attr or {}
   for name, decl_type in pairs(argv) do
      attr[name] = Attribute:new(decl_type)
   end
   assert(#argv == #attr)
   argv = nil
   return attr
end

----------------------------------------------------------------------------------

function n_class_aspect:publish(name, class_aspect)
   _G[name] = class_aspect
end
