-- Basic Object behavior which will be default behavior.
Object = {
   _super = nil,
   classname  = "Object",
   new    = function(_class)
               assert( nil ~= _class)
               local object = {_class = _class}
               local meta   = {
                  __index   = function(self,key) return _class.methods[key] end
               }
               setmetatable(object,meta)
               return object
            end,
   methods= { classname = function(self) return(self._class.classname) end }
}