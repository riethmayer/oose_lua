require 'aspect'
require 'class'
require 'lspec'

LSpec:setup()

it("Wrong Aspect declaration should throw an error",
   function()
      code, err = pcall(Aspect, {'WrongAspect', iswrong})
      return code == false
   end)


----------------------------------------------------------------------------------

it("Should be okay to overwrite an attribute with same type",
   function()
      Class{'A', attr = Boolean}
      res, err = pcall(Aspect, {'One', 
	     adapts = {A},
	     attributes = { attr = Boolean}}
		    )
      One = nil
      A = nil
      return  res == true
   end)

----------------------------------------------------------------------------------

it("Should throw an error on overwriting class attributes",
   function()
      Class{'A', attr = Boolean}
      res, err = pcall(Aspect, {'One', 
	     adapts = {A},
	     attributes = { attr = Number}}
		    )
      One = nil
      A = nil
      return  res == false
   end)

----------------------------------------------------------------------------------

it("a disabled Aspect should behave as if he is not there",
   function()
      Class{'M'}
      function M:DoSome()
      end
      Aspect{'WhellyAspect',
	     adapts = {M},
	     before = {print = 'DoSome'}}
      local before = false
      function WhellyAspect:print()
	 before = true
	 print("before call")
      end

      inst = M:new()
      inst:DoSome()
      condition1 = before == false
      WhellyAspect:enable()
      inst:DoSome()
      condition2 = before == true
      return condition1 and condition2
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