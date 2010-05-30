
if pcall(require, "lfs") then

   local it = lfs.dir(".")
   local path
   repeat
      path = it()
   until patch == nil or path == "Source"
   if path == nil then
      error("unexpected working dir "..lfs.currentdir())
   end

   lfs.chdir("Source")
   require("aspect")
   require("class")
   lfs.chdir("..")
else
   dofile("../Source/aspect.lua")
   dofile("../Source/class.lua")
end