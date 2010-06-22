--[[
Kilian Müller  210473
Jan Riethmayer    310326
Martin Nowak 302066
]]--

--================================================================================
super = {}
super_level = 0
super.trap = "Trap"
----------------------------------------------------------------------------------
function the_real_trap_maker(key)
   local _key = key

   return
   function (instance, ...)
      local i = super_level
      local _super_class = super._curr_self._class
      while i ~= 0 do
	 i = i - 1
	 _super_class = _super_class._super
      end
      local super_func = _super_class[_key]
      local ret = super_func(super._curr_self, ...)
      super_level = super_level - 1
      return ret
   end
end
----------------------------------------------------------------------------------
function set_current_super_self(inst)
   super._curr_self = inst
end
----------------------------------------------------------------------------------
function set_index()
   local mt = {}
   mt.__index = 
      function(_, key)
	 assert(_ == super)
	 super_level = super_level + 1
	 return the_real_trap_maker(key)
      end
   setmetatable(super, mt)
end
----------------------------------------------------------------------------------
set_index()
----------------------------------------------------------------------------------