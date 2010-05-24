require 'LuaTypes'

--===============================================================================

ClassProxy = {}
ClassProxy.ForwardDeclarations = {}

-------------------------------------------------------------------------------

function ClassProxy.Indirection(table, key)
  if key == "Class" then
    ClassProxy.InConstruction = true
    return ClassProxy:Wrapper()
  end
  if ClassProxy.InConstruction then
    ClassProxy.ForwardDeclarations[key] = true
    return key
  end
end


-------------------------------------------------------------------------------

function ClassProxy:Wrapper()
  local function Wrap(argv)
    ConstructionHelper:MakeNewClass(argv, self.ForwardDeclarations)
    self.InConstruction = false
    self.ForwardDeclarations = {}
  end
  return Wrap
end


--===============================================================================

function SetClassProxyHook()
  local GlobalMT = getmetatable(_G) or {}

  GlobalMT.__index = 
    (GlobalMT.__index and CallChain(
      ClassProxy.Indirection, GlobalMT.__index))
    or
    (ClassProxy.Indirection)
  
  setmetatable(_G, GlobalMT)
end

-------------------------------------------------------------------------------
SetClassProxyHook()

--===============================================================================
  
function CallChain(FirstFunc, SecondFunc)
  local 
  function Chain(...)
    return FirstFunc(...) or SecondFunc(...)
  end
  return Chain
end


--===============================================================================

ConstructionHelper = {}
-------------------------------------------------------------------------------

function ConstructionHelper:MakeNewClass(argv, ForwardDeclarations)
	self.NewClass = {}
	self.argv = argv
	self.ForwardDeclarations = ForwardDeclarations

	ConstructionHelper:GetClassName()
  ConstructionHelper:GetSuperClass()
	ConstructionHelper:GetAttributesFromSuper()
	ConstructionHelper:CheckForUndefinedClasses()
	ConstructionHelper:CopyAttributesFromArgv()
	ConstructionHelper:DelegateClassToSuper()
	ConstructionHelper:DelegateObjectToClass()
  self.NewClass.new = ConstructionHelper.new
  
	_G[self.NewClass._classname] = self.NewClass
	self.NewClass = nil
	self.argv = nil
	self.ForwardDeclarations = nil
end


-------------------------------------------------------------------------------

function ConstructionHelper:GetClassName()
	self.NewClass._classname = self.argv[1]
	table.remove(self.argv, 1)
end


-------------------------------------------------------------------------------

function ConstructionHelper:GetSuperClass()
	self.NewClass._super = self.argv[1] or NullClass
	

	if Type(self.NewClass._super):IsConvertibleTo(
      Type(_G[self.NewClass._classname])) then
	  error("Cyclic inheritance")
	end
	table.remove(self.argv, 1)
end


-------------------------------------------------------------------------------

function ConstructionHelper:GetAttributesFromSuper()
  self.NewClass.attributes = self.NewClass._super.attributes or {}
end


-------------------------------------------------------------------------------

function ConstructionHelper:CheckForUndefinedClasses()
  for key, value in pairs(self.argv) do
    if self.ForwardDeclarations[value] then
      if value == self.NewClass._classname then
        self.argv[key] = self.NewClass
      else
        error("Only Defined Types allowed")
      end
    end
  end
end

        
-------------------------------------------------------------------------------

function ConstructionHelper:CopyAttributesFromArgv()
  for key, value in pairs(self.argv) do
    self:CheckOverwritingAttribute(key, value)  
    self.NewClass.attributes[key] = value
  end
end


-------------------------------------------------------------------------------

function ConstructionHelper:CheckOverwritingAttribute(key, value)
  local ExisitingValue = self.NewClass.attributes[key]
  if ExisitingValue and
    Type(value):IsNotConvertibleTo(Type(ExisitingValue)) then
    error("redeclaring element with incompatible type. Element: "..key)
  end
end


-------------------------------------------------------------------------------

function ConstructionHelper:DelegateClassToSuper()
	local meta = 
  { __index = self.NewClass._super }
	setmetatable(self.NewClass, meta)
end


-------------------------------------------------------------------------------

function ConstructionHelper:DelegateObjectToClass()
    local meta = {}
    meta.__index = 
        function (self, key)
          return self.attributes[key] or
            self._class[key]
        end
    meta.__newindex =
        function (self, key, value)
          if not Type(value):IsConvertibleTo(
                  Type(self._class.attributes[key])) then
            ValueName = TypeName(value)
            KeyTypeName = TypeName(self._class.attributes[key])
            error("Invalid assignement of "..ValueName
              .." to "..key.." of type "..KeyTypeName)
          end
          rawset(self.attributes, key, value)
        end
    self.NewClass.objectMetaTable = meta
end

-------------------------------------------------------------------------------

function ConstructionHelper:new()
  local NewObj = {}
  NewObj.attributes = {}
  for key, value in pairs(self.attributes) do
    NewObj.attributes[key] = InitValueByType(value)
  end
  NewObj._class = self
  setmetatable(NewObj, self.objectMetaTable)
  return NewObj
end
