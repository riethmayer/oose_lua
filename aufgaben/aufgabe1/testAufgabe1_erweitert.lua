require("class")

-- err switch
-- 0: Kein Fehlertest
-- 1: Teste type checking für String, Number und Boolean
-- 2: Teste unbekanntest Attribut
-- 3: Teste unbekannte Methode
-- 4: Fehlerhafte Attributsdeklaration (geerbt oder doppelter Name)
-- 5: Fehlerhafte Attributsdeklaration (unbekannter Typ)
-- 6: Teste Fehlermeldung fuer unbekannte Oberklasse
-- 7: Teste type checking für eigenen Typen
err = 0

-- true: Classentable wird angekündigt
explicitDecl = false

-- true: ablaufkommentare
comments = false

-- file check print funtion
function printGrp(errorCode, expDecl)
	print('## Grp 00 | Errorcode ' .. errorCode .. ' | expl. Klassendeklaration = ' .. tostring(expDecl) .. ' ##')
	print()
end

printGrp(err, explicitDecl)

-- prints if comments = true
function printc(msg)
	if comments then
		print('# ' .. msg)
	end
end

-- Testklassenbaum
printc('--Klassenuebersicht--')
printc('MySuper')
printc('Attribute: name')
printc('Methoden: tostring(), print(), init(), setAttributes()')
printc('')
printc('MyClass extends MySuper')
printc('Attribute: MySuper.name')
printc('Methoden: MySuper.print(), tostring()')
printc('')
printc('MySub extends MyClass')
printc('Attribute: MySuper.name')
printc('Methoden: MyClass.tostring(), MyClass.hello(), init()')
printc('')
printc('MyOther')
printc('Attribute: mc, mc2, ms, mo')
printc('Methoden: init(), print()')
printc('--------------------')
print()
print()

----- MySuper -----
print('1 Einfache Klassendeklaration')

Class{'MySuper',
  name = String,
  text = String,
  id = Number,
  isFlagged = Boolean,
}
print()
print(' 1.1 Klasse MySuper erstellt')

printc('MySuper methoden hinzufuegen: alltostring(), tostring(), print(), printAll(), init(), setAttributes()')
function MySuper:tostring()
  return 'MySuper '..self.name
end

function MySuper:attstostring()
	return 'MySuper '..self.text ..' '..self.id..' '..tostring(self.isFlagged)
end

function MySuper:print(msg)
  print(msg..' MySuper:print in '..self:tostring())
end

function MySuper:printAtts(msg)
print(msg..' MySuper:print in '..self:attstostring())
end

function MySuper:init(name)
  self.name = name
end

function MySuper:setAttributes(text, id, isFlagged)
	self.text = text
	self.id = id
	self.isFlagged = isFlagged
end

printc('MySuper methoden hinzugefuegt')

----- MySuper Tests -----
print()
s = MySuper:new()
print(' 1.2 s = MySuper.new() ausgefuehrt')

print()
printc('s.init(s1), s:print(): erwarte 1.3 MySuper:print in MySuper s1')
s:init('s1')
s:print(' 1.3')

print()
printc('s.name = s2, s:print(): erwarte 1.4 MySuper:print in MySuper s2')
s.name = 's2'
s:print(' 1.4')

print()
printc('s:printAll(): erwartet 1.5 MySuper:print in MySuper 0 false')
s:printAtts(' 1.5')

print()
printc('s.text = text, s.id = 123, s.isFlagged = true, s:printAll(): erwartet 1.6 MySuper:print in MySuper text 123 true (korrekte Attributwertzuweisung)')
s.text = 'text'
s.id = 123
s.isFlagged = true
s:printAtts(' 1.6')

----- MySuper Errors -----
print()
if err == 1 then
  local testNo = os.time()%3
  if (testNo < 1) then
  	print(' 1.e1 Erwarte Fehler type mismatch string = number:')
  	s.name = 5
  else if (testNo < 2) then
  	print(' 1.e1 Erwarte Fehler type mismatch number = string:')
  	s.id = 'neueID'
  else
  	print(' 1.e1 Erwarte Fehler type mismatch boolean = string:')
  	s.isFlagged = 'ja'
  end
  end
end

if err == 2 then
  print(' 1.e2 Erwarte Fehler: no such field (.irgendwas):')
  s.irgendwas = 42
end
if err == 3 then
  print(' 1.e3 Erwarte Fehler no such method (.dosomething()):')
  s:dosomething()
end

print()
print()

----- MyClass -----
print('2 Vererbung')

print()
Class{'MyClass', MySuper}

print(' 2.1 Klasse MyClass mit Superklasse MySuper erstellt')

printc('MyClass methoden hinzufuegen: tostring()')
function MyClass:tostring()
  return 'MyClass '..self.name
end

function MyClass:setname(name)
  self.name = name
end

----- MyClass Tests -----
print()
print(' 2.2 mc = MyClass:new() und mc.setname(m1)')
mc = MyClass:new()
mc:setname('m1')

print()
printc('mc:print(): erwarte 2.3 MySuper:print in MyClass m1 (Geerbte print methode, geerbtes name attribut)')
mc:print(' 2.3')

print()
printc('mc.name = m2, mc:print(): erwarte 2.4 MySuper:print in MyClass m2 (Wertzuweisung an geerbtes Attribut)')
mc.name = 'm2'
mc:print(' 2.4')

----- MySub -----
print()
printc('erstelle MySub mit _super MyClass')
Class{'MySub', MyClass}

printc('MySub methoden hinzufuegen: init')
function MySub:init(name)
  self.name = name
end

----- MySub Tests -----
printc('b = MySub.new() und b.setname(m2)')
b = MySub:new()
b:setname('m2')

print()
printc('b.print(): erwarte 2.5 MySuper:print in MyClass sub1 (print geerbt aus MySuper, tostring() geerbt aus MyClass, eigener name Wert)')
b:print(' 2.5')

print()
printc('MySub methoden hinzufuegen: tostring() (ueberschreibt die geerbte MyClass.tostring())')
function MySub:tostring()
  return ' MySub '..self.name
end

printc('b:print(): erwarte 2.6 MySuper:print in  MySub sub1 (Nutzung der ueberschriebenen tostring() statt der geerbten)')
b:print(' 2.6')
print()

----- MySub Errors -----
if err == 4 then
	print(' 2.e4 MyNamesOK , gleiche Attributdeklaration mit gleichem Typ, erwarte keinen Fehler')
	Class{'MyNamesOK', MySuper, name = String}
	print(' 2.e4 MyNamesDBL , gleiche Attributdeklaration mit unterschiedlichem Typ, erwarte Fehler')
	Class{'MyNamesDBL', MySuper, name = Number}
end

if err == 5 then
	print(' 2.e5 Erwarte Fehler unknown type in attribute declaration')
	Class{'MyTest', att = unknownType}
end

if err == 6 then
	print(' 2.e6 Erwarte Fehler unknown super class')
	Class{'FalscheKlasse', FalscheOberklasse, att1 = String, att2 = Boolean}
end

print()
print()

----- MyOther -----
print('3 Referenzen')

print()
if explicitDecl then
  print(' 3.1 Klassentable muss mit MyOther{} vorangekuendigt werden')
  MyOther = {}
else
  print(' 3.1 Klassentable muss NICHT vorangekuendigt werden')
end

Class{'MyOther',
  mc = MyClass,
  mc2 = MyClass,
  ms = MySuper,
  mo = MyOther,
}

print()
print(' 3.2 Klasse MyOther erstellt mit Attributen mc = MyClass, mc2 = MyClass, ms = MySuper, mo = MyOther')

print()
printc('MyOther methoden hinzufuegen: init(), print()')
function MyOther:init(msg)
  print(msg..' init MyOther')
end

function MyOther:print(msg)
  print(msg..' MyOther:print')
  if self.mc then self.mc:print(' ' .. msg) end
  if self.mo then
    if self.mo == self then
      print(' '..msg..' mo = self')
    else
      self.mo:print(' '..msg)
    end
  end
end

----- MyOther Tests -----
printc('mo = MyOther.new()')
mo = MyOther:new()
mco = MyClass:new()
mco.name = 'mco1'
mo.mc2 = mco
printc('Zuweisung mo.mc2 = mco erfolgt (Typ mc ist gleich Typ mco) erwarte 3.3 MySuper:print in MyClass mco1')
mo.mc2:print(' 3.3')

print()
mo.ms = mc
print(' 3.4 Zuweisung mo.ms = mc erfolgt (Typ mc ist subtyp von Typ ms)')

print()
printc('mo:print(): erwarte 3.5 MyOther:print (mc == mo == nil)')
mo:print(' 3.5')

print()
printc('mo.mc = mc')
mo.mc = mc
printc('mo:print(): erwarte 3.6 MyOther:print + 3.6 MySuper:print in MyClass m2 (von mc)')
mo:print(' 3.6')

print()
printc('mo.mc = nil')
mo.mc = nil
printc('mo:print(): erwarte 3.7 MyOther:print (mc == mo == nil)')
mo:print(' 3.7')

print()
printc('mo.mo = mo')
mo.mo = mo
printc('mo:print(): erwarte 3.8 MyOther:print + mo = self (von mo)')
mo:print(' 3.8')

----- MyOther Errors -----
print()
if err == 7 then
  testNo = os.time()%3
  if (testNo < 1) then
  	print(' 3.e7 Erwarte Fehler type mismatch MyOther = string:')
  	mo.mo = 'hallo'
  else if (testNo < 2) then
    print(' 3.e7 Erwarte Fehler type mismatch MyOther = MyClass')
    mo.mo = mc
  else
    print(' 3.e7 Erwarte Fehler type mismatch MyClass = MySuper')
    ms = MySuper:new()
    mo.mc = ms
  end
  end
end
