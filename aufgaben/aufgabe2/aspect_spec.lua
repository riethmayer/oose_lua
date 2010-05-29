require 'aspect'
require 'class'
require 'lspec'

LSpec:setup()

----------------------------------------------------------------------------------

it("Wrong Aspect declaration should throw an error",
   function()
      code, err = pcall(Aspect, {'WrongAspect', iswrong})
      return code == false
   end)

----------------------------------------------------------------------------------

function same_type_aspect(Type)
   Class{'A', attr = Type}
   Aspect{'One', 
	  adapts = {A},
	  attributes = { attr = Type}}
   o = A:new()
   One = nil
   A = nil
   return o.attr == Type._default_value()
end


----------------------------------------------------------------------------------

it_u("Should be okay to overwrite an attribute with same type",
   function()
      local Types = {Boolean, String, Number}
      for _,v in pairs(Types) do
	 if not same_type_aspect(v) then
	    return false
	 end
      end
      return true
   end
)

----------------------------------------------------------------------------------

it("Should throw an error on overwriting class attributes",
   function()
      Class{'A', attr = Boolean}
      res, err = pcall(Aspect, {'One', 
	     adapts = {A},
	     attributes = { attr = Number}})
      One = nil
      A = nil
      return res == false
   end)

----------------------------------------------------------------------------------

it("a Aspect should behave as if he is not there",
   function()
      Class{'M'}
      local c_flag = false
      local a_flag = false

      function M:set_flag()
	 c_flag = true
      end

      Aspect{'WhellyAspect',
	     adapts = {M},
	     before = {flag = 'set_flag'}}
      function WhellyAspect:flag()
	 before = true
	 print("before call")
      end

      inst = M:new()
      inst:set_flag()
      return c_flag == true and a_flag == false
   end)

----------------------------------------------------------------------------------

it("a Aspect should be able to alter behaviour",
   function()
      M = nil
      WhellyAspect = nil
      Class{'M'}
      Aspect{'WhellyAspect',
	     adapts = {M},
	     attributes = {new_attr = Boolean}}

      WhellyAspect:enable()
      inst = M:new()
      return inst.new_attr == false
   end)

----------------------------------------------------------------------------------

it("An value of an aspect attribute should be the same on reenabling",
   function()
      M = nil
      WhellyAspect = nil
      Class{'M'}
      Aspect{'WhellyAspect',
	     adapts = {M},
	     attributes = {new_attr = Boolean}}

      inst = M:new()
      WhellyAspect:enable()
      inst.new_attr = true
      WhellyAspect:disable()
      WhellyAspect:enable()
      return inst.new_attr == true
   end)

----------------------------------------------------------------------------------

it("an attribute declared in an Aspect should have the same value if the Aspect is enabled again",
   function()
      WheelyAspect:enable()
      return self.raederAmBoden == 2
   end)

it("the last declared Aspect should be active",
   function()
      return false
   end)

it("Aspects should be inherited",
   function()
      return false
   end)

it("an error should be thrown if an Aspect method gets called which is not declared",
   function()
      return false
   end)

it("Aspect methods should overwrite object methods",
   function()
      return false
   end)

it("If a before method returns false the original method should not be executed",
   function()
      return false
   end)

it("should be possible to bind more the one Aspect to the same baseclass method",
   function()
      return false
   end)

LSpec:teardown()