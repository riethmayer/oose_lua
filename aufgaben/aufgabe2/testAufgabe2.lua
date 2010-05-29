-- Hier muss der Name eurer LOS Implementierung rein
require("class")
require("aspect")

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
	print('Wheelyvorbereitung: Fuﬂ auf die Bremse, zwei finger an die Kupplung')
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
