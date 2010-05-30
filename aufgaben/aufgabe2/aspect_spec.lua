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
	 a_flag = true
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

it_u("a Aspect should match calls if he is enabled",
   function()
      M = nil
      WhellyAspect = nil
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
	 a_flag = true
      end

      inst = M:new()
      WhellyAspect:enable()
      inst:set_flag()
      return c_flag == true and a_flag == true
   end)

----------------------------------------------------------------------------------

it("should be possible to chain aspect calls",
   function()
      M = nil
      WhellyAspect = nil
      Class{'M'}
      function M:call()
      end
      Aspect{'WhellyAspect',
	     adapts = {M},
	     attributes = {new_attr = Boolean},
	     before = {first = "call" , second = "first"}}
      local first = false
      local second = false
      function WhellyAspect:first()
	 first = true
      end
      function WhellyAspect:second()
	 second = true
      end
      o = M:new()
      WhellyAspect:enable()
      o:call()
      return first == true and second == true
   end)

----------------------------------------------------------------------------------

it("should raise an error on recursive calls",
   function()
      M = nil
      WhellyAspect = nil
      Class{'M'}
      Aspect{'WhellyAspect',
	     adapts = {M},
	     attributes = {new_attr = Boolean},
	     before = {call = "call"}}

      function WhellyAspect:call()
      end
      o = M:new()
      WhellyAspect:enable()
      local stat, err = pcall(function() return o:call() end)
      return stat == false
   end)

----------------------------------------------------------------------------------

it("shoud break call chain when before returns false",
   function()
      M = nil
      WhellyAspect = nil
      Class{'M'}
      local call = false
      function M:call()
	 call = true
      end
      Aspect{'WhellyAspect',
	     adapts = {M},
	     attributes = {new_attr = Boolean},
	     before = {first = "call"}}
      local first = false
      function WhellyAspect:first()
	 first = true
	 return false
      end
      o = M:new()
      WhellyAspect:enable()
      o:call()
      return first == true and call == false
   end)

----------------------------------------------------------------------------------

it("should be possible to bind more the one Aspect to the same baseclass method",
   function()
      M = nil
      One = nil
      Two = nil

      Class{'M'}
      local t = {false, false, false, false, false}
      Aspect{'One',
	     adapts = {M},
	     before = {one_b = "call"},
	     after = {one_a = "call"}}
      Aspect{'Two',
	     adapts = {M},
	     before = {two_b = "call"},
	     after = {two_a = "call"}}

      function One:one_b()
	 t[1] = true
      end
      function One:one_a()
	 t[2] = true
      end
      function M:call()
	 t[3] = true
      end
      function Two:two_b()
	 t[4] = true
      end
      function Two:two_a()
	 t[5] = true
      end

      One:enable()
      Two:enable()
      o = M:new()
      o:call()
      for i, v in ipairs(t) do
	 if v == false then
	    return false
	 end
      end
      return #t == 5
   end)

----------------------------------------------------------------------------------

it("should call multiple aspects in the right order",
   function()
      M = nil
      One = nil
      Two = nil

      Class{'M'}
      local t = {}
      Aspect{'One',
	     adapts = {M},
	     before = {be = "call"},
	     after = {af = "call"}}
      Aspect{'Two',
	     adapts = {M},
	     before = {be2 = "call"},
	     after = {af2 = "call"}}

      function Two:be2()
	 table.insert(t, 1)
      end
      function One:be()
	 table.insert(t, 2)
      end
      function M:call()
	 table.insert(t, 3)
      end
      function One:af()
	 table.insert(t, 4)
      end
      function Two:af2()
	 table.insert(t, 5)
      end

      One:enable()
      Two:enable()
      o = M:new()
      o:call()
      for i, v in ipairs(t) do
	 if i ~= v then
	    return false
	 end
      end
      return true
   end)


----------------------------------------------------------------------------------

it("should be possible to hook multiple function per aspect",
   function()
      -- we definetely need a sandbox but setfenv is somewhat difficult
      M = nil
      One = nil
      Two = nil

      Class{'M'}
      local t = {}
      Aspect{'One',
	     adapts = {M},
	     before = {be = "call", be2 = "call"},
	     after = {af = "call", af2 = "call"}}

      function One:be2()
	 table.insert(t, 1)
      end
      function One:be()
	 table.insert(t, 2)
      end
      function M:call()
	 table.insert(t, 3)
      end
      function One:af()
	 table.insert(t, 4)
      end
      function One:af2()
	 table.insert(t, 5)
      end

      One:enable()
      o = M:new()
      o:call()
      for i, v in ipairs(t) do
	 if i ~= v then
	    return false
	 end
      end
      return true
   end)

----------------------------------------------------------------------------------

it("should be possible have staggered aspect calls",
   function()
      M = nil
      One = nil
      Two = nil
      Three = nil

      Class{'M'}
      local t = {}

      Aspect{'One',
	     adapts = {M},
	     before = {one = "call"}}
      Aspect{'Two',
	     adapts = {M},
	     before = {b_one = "one"},
	     after = {a_one = "one"}}
      Aspect{'Three',
	     adapts = {M},
	     before = {b_call = "call"},
	     after = {a_call = "call"}}

  
      function Three:b_call()
	 table.insert(t, 1)
      end
      function Two:b_one()
	 table.insert(t, 2)
      end
      function One:one()
	 table.insert(t, 3)
      end
      function Two:a_one()
	 table.insert(t, 4)
      end
      function M:call()
	 table.insert(t, 5)
      end
      function Three:a_call()
	 table.insert(t, 6)
      end

      One:enable()
      Two:enable()
      Three:enable()

      o = M:new()
      o:call()
      for i, v in ipairs(t) do
	 if v == false then
	    return false
	 end
      end
      return #t == 6
   end)

----------------------------------------------------------------------------------

it("Aspects should raise an error on unknown class.",
   function()
      M = 5
      One = nil

      stat, err = pcall(Aspect,{"One", adapts = {M},
		    attributes = {val1 = Number}})
      return stat == false
   end)

----------------------------------------------------------------------------------

it("should raise an error on wrong attribute.",
   function()
      M = nil
      One = nil
      
      Class{"M"}
      stat, err = pcall(Aspect,{"One", adapts = {M},
		    attributes = {val1 = 5}})
      return stat == false
   end)

----------------------------------------------------------------------------------

it("shouldn't disturb super calls",
   function()
      M = nil
      N = nil
      One = nil
      Class{"M"}
      Class{"N", M}

      local super_flag = false
      function M:inherit()
	 super_flag = true
      end

      local child_flag = false
      function N:inherit()
	 child_flag = true
	 super:inherit()
      end

      Aspect{"One", adapts = {M, N}, before = {flag = "inherit"}}
      local aspect_flag = 0
      function One:flag()
	 aspect_flag = aspect_flag + 1
      end

      o = N:new()
      One:enable()
      o:inherit()
      return aspect_flag == 2 and child_flag == true and super_flag == true
   end)

----------------------------------------------------------------------------------
it_u("should allow super/self calls while aspect counts",
   function()
      M = nil N = nil O = nil
      Class{"M"}
      Class{"N", M}
      Class{"O", N}

      local m = 0
      local n = 0
      local o = 0

      function M:call()
	 m = m + 1
	 self:spr()
      end
      function M:spr()
	 m = m + 1
      end

      function N:call()
	 super:call()
	 n = n + 1
	 self:spr()
      end
      function N:spr()
	 n = n + 1
      end

      function O:call()
	 super:call()
	 o = o + 1
	 self:spr()
      end
      function O:spr()
	 o = o + 1
      end

      Aspect{"Counter",
	     adapts = {O},
	     before = {inc = "call"},
	     after = {dec = "spr"}}
      local count_up = 0
      local count_down = 0
      function Counter:inc()
	 count_up = count_up + 1
      end
      function Counter:dec()
	 count_down = count_down - 1
      end

      Counter:enable()
      inst = O:new()
      inst:call()

      return m == 1 and n == 1 and o == 4 
	 and count_up == 1 and count_down == -3
   end)

----------------------------------------------------------------------------------

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

LSpec:teardown()