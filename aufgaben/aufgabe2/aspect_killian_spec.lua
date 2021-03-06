-- Hier muss der Name eurer LOS Implementierung rein
require("class")
require("lspec")
LSpec:setup()

Class{'Fahrzeug', geschwindigkeit = Number}

function Fahrzeug:beschleunigen(diff)
	print('...beschleunigt von '..tostring(self.geschwindigkeit)..' auf '..tostring(self.geschwindigkeit+diff))
end

Class{'Motorrad', Fahrzeug}

function Motorrad:beschleunigen(diff)
	print('Das Motorrad...')
	super:beschleunigen(diff)
end

function Motorrad:hartAmGasZiehen()
	print('Der Gasgriff des Moppeds wird schnell geoeffnet')
end

function Motorrad:doWheely(speedDiff)
	self:hartAmGasZiehen()
	self:beschleunigen(speedDiff)
	print('Das Motorrad faehrt einen Wheely')
end

print('--- Wheely mit Super call')
ktm = Motorrad:new()
ktm.geschwindigkeit = 30
ktm:doWheely(10)
print()

Aspect{'WheelyAspect', adapts = {Motorrad}, attributes = {raederAmBoden = Number}, before = {prepareForWheely = 'doWheely', doNothing = 'unknownMethod'}, after = {holdWheely = 'doW%w*'}}

function WheelyAspect:prepareForWheely(speedDiff)
	print('Wheelyvorbereitung: Fu� auf die Bremse, zwei finger an die Kupplung')
	if (speedDiff < 10) then
		print('SpeedDiff zu klein, Wheely wird abgebrochen')
		return false
	else
		return true
	end
end

function WheelyAspect:holdWheely(speedDiff)
	self.raederAmBoden = 1
	print('Wheely wird gehalten, es ist noch '..tostring(self.raederAmBoden)..' Rad am Boden')
end

WheelyAspect:enable()

print('--- Wheely mit Aspect')
ktm.raederAmBoden = 2
ktm:doWheely(9)
print()
ktm:doWheely(10)



ktm.raederAmBoden = 2

it("Wrong Aspect declaration should throw an error",
	function()
	Aspect{'WrongAspect', iswrong}
end)


it("a disabled Aspect should behave as if he is not there",
	function()
	WhellyAspect:disable()
	ktm:doWheely(10)
	return self.raederAmBoden == nil
	end)

it("an attribute declared in an Aspect should have the same value if the Aspect is enabled again",
	function()
	WheelyAspect:enable()
	return self.raederAmBoden == 2
end)

it("the last declared Aspect should be active",
	function()
end)

it("Aspects should be inherited")
	function()
end)

it("an error should be thrown if an Aspect method gets called which is not declared")
	function()
end)

it("Aspect methods should overwrite object methods")
	function()
end)

it("If a before method returns false the original method should not be executed")
	function()
end)

it("should be possible to bind more the one Aspect to the same baseclass method")
	function()
end)

LSpec:teardown()



Class{'Fahrzeug', geschwindigkeit = Number}
----------------------------------------------------------------------------------
function Fahrzeug:beschleunigen(diff)
   local from = '...beschleunigt von '
   local to   = ' auf '
   local before_acceleration = tostring(self.geschwindigkeit)
   local after_acceleration = tostring(self.geschwindigkeit + diff)
   return from.. before_acceleration .. to .. after_acceleration
end
----------------------------------------------------------------------------------
Class{'Motorrad', Fahrzeug}
----------------------------------------------------------------------------------
function Motorrad:beschleunigen(diff)
   return ("Das Motorrad..." .. super:beschleunigen(diff))
end
----------------------------------------------------------------------------------
function Motorrad:hartAmGasZiehen()
   return "Der Gasgriff des Moppeds wird schnell geoeffnet"
end
----------------------------------------------------------------------------------
function Motorrad:doWheely(speedDiff)
   local whooo = "Das Motorrad faehrt einen Wheely"
   return self:hartAmGasZiehen() .. self:beschleunigen(speedDiff) .. whooo
end
----------------------------------------------------------------------------------
it("should call super",
   function()
      ktm = Motorrad:new()
      ktm.geschwindigkeit = 30
      return pcall(ktm:doWheely(10))
   end)
----------------------------------------------------------------------------------
Aspect{'WheelyAspect',
       adapts = {Motorrad},
       attributes = {raederAmBoden = Number},
       before = {
          prepareForWheely = 'doWheely',
          doNothing = 'unknownMethod'},
       after = {holdWheely = 'doW%w*'}
    }
----------------------------------------------------------------------------------
function WheelyAspect:prepareForWheely(speedDiff)
   print('Wheelyvorbereitung: Für auf die Bremse, zwei finger an die Kupplung')
   if (speedDiff < 10) then
      print('SpeedDiff zu klein, Wheely wird abgebrochen')
      return false
   else
      return true
   end
end
----------------------------------------------------------------------------------
function WheelyAspect:holdWheely(speedDiff)
   self.raederAmBoden = 1
   print('Wheely wird gehalten, es ist noch '..tostring(self.raederAmBoden)..' Rad am Boden')
end
----------------------------------------------------------------------------------
WheelyAspect:enable()
----------------------------------------------------------------------------------
function stop_wheelie()
   ktm.raederAmBoden = 2
end
stop_wheelie()
----------------------------------------------------------------------------------
it("should abort the wheelie if too slow",
   function()
      return ktm:doWheely(9) == false and stop_wheelie()
   end)
----------------------------------------------------------------------------------
it("should do a wheelie if fast enough",
   function()
      return ktm:doWheely(10) and stop_wheelie()
   end)
----------------------------------------------------------------------------------
it("Wrong Aspect declaration should throw an error",
   function()
      pcall(Aspect,{'WrongAspect', iswrong}) == false
   end)
----------------------------------------------------------------------------------
it("a disabled Aspect should behave as if he is not there",
   function()
      WhellyAspect:disable()
      ktm:doWheely(10)
      return ktm.raederAmBoden == nil
   end)
----------------------------------------------------------------------------------
it("an attribute declared in an Aspect should have the same value if the Aspect is enabled again",
   function()
      WheelyAspect:enable()
      return ktm.raederAmBoden == 2
   end)
----------------------------------------------------------------------------------
it("the last declared Aspect should be active",
   function()
   end)
----------------------------------------------------------------------------------
it("Aspects should be inherited")
function()
end)
----------------------------------------------------------------------------------
it("an error should be thrown if an Aspect method gets called which is not declared")
function()
end)
----------------------------------------------------------------------------------
it("Aspect methods should overwrite object methods")
function()
end)
----------------------------------------------------------------------------------
it("If a before method returns false the original method should not be executed")
function()
end)
----------------------------------------------------------------------------------
it("should be possible to bind more the one Aspect to the same baseclass method")
function()
end)