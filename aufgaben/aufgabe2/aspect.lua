----------------------------------------------------------------------------------
function Aspect(params)
   local aspect_name = params[1]
   validate_presence_of_attributes(params)
   local aspect = {
      __index = nil
   }
   
   publish(aspect_name,aspect)
end
----------------------------------------------------------------------------------
function validates_presence_of_attributes(params)
-- todo
end
----------------------------------------------------------------------------------
function Aspect.attach_aspect_hooks_to(adaptees, aspekt)
   for _,klass in ipairs(adaptees) do
      klass.add_aspect_hooks(aspekt)
   end
end
----------------------------------------------------------------------------------
function Aspect.attach_aspect_hooks_to(adaptees, aspekt)
   for _,klass in ipairs(adaptees) do
      klass.remove_aspect_hooks(aspekt)
   end
end
----------------------------------------------------------------------------------
function publish_aspect(name,aspect)
   _G[aspect.name] = aspect 
end