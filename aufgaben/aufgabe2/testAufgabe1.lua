-- Hier muss der Name eurer LOS Implementierung rein
require("BaseClass")

Class{'Fahrzeug', marke = String, baujahr = Number}

function Fahrzeug:tostring()
  return 'Ich bin ein '..self.marke
end

function Fahrzeug:print()
  print(self:tostring())
end

function Fahrzeug:printBaujahr()
  print('Dieses Fahrzeug der Marke '..self.marke..' ist von '..tostring(self.baujahr))
end

function settable(table, key, value)
  print(key)
end

f = Fahrzeug:new()
f.marke = 'Opel'
f.baujahr = 1993
f:print()

-- Motorrad = {}  -- Vorankuendigung der Klasse bei einem Attribut eigenen Typs
Class{"Motorrad", Fahrzeug, ersatzFahrzeug = Motorrad}

function Motorrad:tostring()
  local s = 'Ich bin ein Motorrad der Marke '..self.marke
  if self.ersatzFahrzeug then
    s = s..'. Mein Ersatzfahrzeug ist von der Marke '..self.ersatzFahrzeug.marke..'.'
  end
  return s
end

ka = Motorrad:new()
ka.marke = 'Kawasaki'
ka.baujahr = 1999
ka:printBaujahr()

kt = Motorrad:new()
kt.marke = 'KTM'
kt.baujahr = 2000
kt:print()
ka.ersatzFahrzeug = kt
ka:print()

-- Hier sollte eine Fehlermeldung folgen
-- Class{"FehlerKlasse", falschesAttribut = unbekannterTyp}
