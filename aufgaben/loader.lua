
if pcall(require, "lfs") then

   lfs.chdir("..")
   print(lfs.currentdir())
   local it = lfs.dir(".")
   repeat
      local path = it()
      print(path)
   until patch == nil or path == "Source"
   if path == nil then
      error("unexpected working dir "..lfs.currentdir())
   end

   lfs.chdir("Source")
   require("aspect")
   require("class")
   lfs.chdir("../Tests")
else
   dofile("../Source/aspect.lua")
   dofile("../Source/class.lua")
end