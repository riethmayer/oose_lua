if pcall(require, "lfs") then
   local old_wd = lfs.currentdir()
   repeat
      local it = lfs.dir(".")
      local path
      repeat
	 path = it()
      until path == nil or path == "loader.lua"
      if path ~= nil then
	 require("loader")
	 lfs.chdir(old_wd)
	 return
      end
      local current_dir = lfs.currentdir()
   until not lfs.chdir("..") or lfs.currentdir() == current_dir
else
   dofile("../Source/aspect.lua")
   dofile("../Source/class.lua")
end