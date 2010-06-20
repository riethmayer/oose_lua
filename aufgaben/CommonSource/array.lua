--================================================================================

----------------------------------------------------------------------------------

Class{"Stack"}

----------------------------------------------------------------------------------

function Stack:new(type)
   local new_inst = Stack._super.new(self)
   rawset(new_inst, "_m_type", Attribute:new(type))
   rawset(new_inst, "_array_data", {})
   return new_inst
end

----------------------------------------------------------------------------------

function Stack:size()
   return #self._array_data
end

----------------------------------------------------------------------------------

function Stack:push(elem)
   if not self._array_data then
      error("Array not initialized")
   end
   if self._m_type:can_accept(elem) then
      table.insert(self._array_data, elem)
   else
      error("Wrong Type to push, expected"..self._class._classname)
   end
end

----------------------------------------------------------------------------------

function Stack:pop()
   return table.remove(self._array_data)
end

----------------------------------------------------------------------------------

function Stack:top()
   return self._array_data[self:size()]
end

----------------------------------------------------------------------------------
-- optional parameters, you can use stack_inst:iterator()
function Stack:iterator(start_idx, stride)
   local l_idx = start_idx or self:size()
   local l_stride = stride or -1
   local l_stack = self
   return 
   function()
      local val = l_stack._array_data[l_idx]
      l_idx = l_idx + l_stride
      return val
   end
end

--================================================================================

----------------------------------------------------------------------------------

Class{"Array", Stack}

----------------------------------------------------------------------------------

function Array:push_back(elem)
   self:push(elem)
end

----------------------------------------------------------------------------------

function Array:pop_back(elem)
   return self:pop(elem)
end

----------------------------------------------------------------------------------

function Array:back(elem)
   return self:top(elem)
end

----------------------------------------------------------------------------------

function Array:at(index)
   if self:size() >= index then
      return self._array_data[index]
   end
end

----------------------------------------------------------------------------------

function Array:clear(index)
   repeat
   until not self:pop_back()     
end

----------------------------------------------------------------------------------

function Array:fwd_iterator()
   return self:iterator(1, 1)
end

----------------------------------------------------------------------------------

function Array:rev_iterator()
   return self:iterator(self:size(), -1)
end

----------------------------------------------------------------------------------

function Array:_remove(idx)
   table.remove(self._array_data, idx)
end

----------------------------------------------------------------------------------

function Array:remove_val(val, all)
   for i = 1, self:size() do
      if self:at(i) == val then
	 self:_remove(i)
	 if not all then break end
      end
   end
end