-- Basic Object behavior which will be default behavior.
Object = {
   _super = nil,
   classname  = "Object",
   methods= { 
      classname = function(self) return(self._class.classname) end,
      initialize= function(self) --
   }
}

function Object:new()
   assert( nil ~= self)
   local object = {_class = self}
   local meta   = {
      __index   = function(self,key) return self.methods[key] end
   }
   setmetatable(object,meta)
   return object
end
