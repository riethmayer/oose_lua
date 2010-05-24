String = ""
Boolean = true
Number = 0
Function = function() end
NullClass = {}

--===============================================================================

function InitValueByType(value)
  if type(value) == "table" then return nil end
  if type(value) == "string" then return String end
  if type(value) == "boolean" then return Boolean end
  if type(value) == "number" then return Number end
end


--===============================================================================

-------------------------------------------------------------------------------

function TypeName(value)
  if type(value) ~= "table" then
    return type(value)
  end
  if value._classname then
    return value._classname
  end
  return "table"
end


-------------------------------------------------------------------------------

function Type(value)
  return TypeInfo:new(value)
end


--===============================================================================

-------------------------------------------------------------------------------

TypeInfo = {}


-------------------------------------------------------------------------------

function TypeInfo:new(value)
  local New = {}
  setmetatable(New, { __index = TypeInfo })
  New.TypeName = TypeName(value)
  return New
end


-------------------------------------------------------------------------------

function TypeInfo:IsNotConvertibleTo(op2)
  return not self:IsConvertibleTo(op2)
end


-------------------------------------------------------------------------------

function TypeInfo:IsConvertibleTo(op2)
  if not self.TypeName then
    return false
  end
    
  local NextSuper = self.TypeName
  while (NextSuper) do
    if NextSuper == op2.TypeName then
      return true
    end
    NextSuper = _G[NextSuper]._super and _G[NextSuper]._super._classname
  end
end
  
  
