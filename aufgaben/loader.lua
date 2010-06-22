require("CommonSource.basetypes")
require("CommonSource.object")
require("CommonSource.class_aspect_shared")
require("CommonSource.class")
require("CommonSource.aspect")
require("CommonSource.self_super_trap")
require("CommonSource.array")

function install_root_require()
   if (pcall(require, "lfs")) then
      local l_root = lfs.currentdir()
      root_require = 
	 function(module_name)
	    local l_old = lfs.currentdir()
	    lfs.chdir(l_root)
	    require(module_name)
	    lfs.chdir(l_old)
	 end
   else
      error("Need Lua File System module to work properly.")
   end
end

install_root_require()