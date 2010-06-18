require("classes")

-- extra points switch
-- 0: Kein Extrapunktetest
-- 1: Teste Fehlermeldung für rekursive Aspektmethodenbindung
extra = 0

-- err switch
-- 0: Kein Fehlertest
-- 1: Teste Fehlermeldung beim Aufruf einer unbekannten Supermethode
-- 2: Deklaration eines Aspektattributes, das in einer Basisklasse mit einem anderen Typen vorhanden ist
-- 3: Deklaration eines Aspektes mit einer unbekannten Basisklasse
-- 4: Aufruf einer nicht deklarierten before/after Methode
-- 5: Aufruf von nicht aktivierten Aspectfeatures
err = 0

if (extra ~= 0) then
	err = 0
end


-- file check print funtion 
function rintGrp(errorCode, extraPoints)
	print('## Grp 00 | Errorcode ' .. errorCode .. ' | Extra Tests = ' .. tostring(extraPoints) .. ' ##')
	print()
end

printGrp(err, extra)

-- prints if comments = true
function printc(msg)
	if comments then
		print('# ' .. msg)
	end
end

--- ###
print('1. Super-Aufrufe')
print()
--- ###

--- SuperClass
Class{'SuperClass'}

function SuperClass:simpleSuperCall(par1)
	print('SuperClass:simpleSuperCall mit '..par1)
end

function SuperClass:simpleSuperCallWithSelf(par1)
	print('SuperClass:simpleSuperCallWithSelf mit '..par1)
	print('Self: '..self:toString())
end;

function SuperClass:toString()
	return 'SuperClass'
end

function SuperClass:superCaller(par1)
	print('SuperCaller in SuperClass angekommen mit '..par1)
end

function SuperClass:superCallerWithSelf(par1)
	print('SuperCallerWithSelf in SuperClass mit Aurufer aus '..self:toString()..' '..par1)
end

--- SubClass1
Class{'SubClass1', SuperClass}

function SubClass1:simpleSuperCall(par1)
	print('SubClass1:simpleSuperCall mit '..par1)
	super:simpleSuperCall(par1)
end;

function SubClass1:simpleSuperCallWithSelf(par1)
	print('SubClass1:simpleSuperCallWithSelf mit '..par1)
	super:simpleSuperCallWithSelf(par1)
end;

function SubClass1:toString()
	return 'SubClass1'
end

print(' 1.1 Einfacher Superaufruf mit Parameter')
simpleSuperCaller = SubClass1:new()
simpleSuperCaller:simpleSuperCall('1.1')
print()

print(' 1.2 Test des Selfbezuges für einen einfachen Superaufruf mit Parameter')
simpleSuperCaller:simpleSuperCallWithSelf('1.2')
print()

--- SubClass2+3+4
Class{'SubClass2', SubClass1}

function SubClass2:superCallerWithSelf(par1)
	print('SuperCallerWithSelf in SubClass2 mit Aurufer aus '..self:toString()..' '..par1)
	super:superCallerWithSelf(par1);
end

function SubClass2:toString()
	return 'SubClass2'
end

function SubClass2:forkCall(par1)
	print('ForkCall in Subclass3, calling self:print() '..par1)
	print('self:toString(): '..self:toString())
end

Class{'SubClass3', SubClass2, subObj2 = SubClass2}

function SubClass3:superCaller(par1)
	print('SuperCaller aus SubClass3 mit '..par1)
	super:superCaller(par1);
end

function SubClass3:unknownSuperCall()
	print('UnknownSuperCall in SubClass3')
	print('UnknownSuperCall geht jetzt nicht mehr weiter...')
	super:unknownSuperCall()
	print('UnknownSuperCall zurueck in SubClass3')
end

function SubClass3:forkCall(par1)
	print('ForkCall in Subclass3, calling subObj2:forkCall(), erwarte self:toString() = SubClass2 '..par1)
	self.subObj2:forkCall(par1)
	print('ForkCall zurueck in Subclass3, calling super:forkCall(), erwarte self:toString() = SubClass4'..par1)
	super:forkCall(par1)
	print('ForkCall zurueck in Subclass3 '..par1)
end

Class{'SubClass4', SubClass3}

function SubClass4:superCaller(par1)
	print('SuperCaller in SubClass4 mit '..par1)
	super:superCaller(par1);
	print('SuperCaller endet in SubClass4 mit '..par1)
end

function SubClass4:toString()
	return 'SubClass4'
end

function SubClass4:superCallerWithSelf(par1)
	print('SuperCallerWithSelf in SubClass4 mit Aurufer aus '..self:toString()..' '..par1)
	super:superCallerWithSelf(par1);
	print('SuperCallerWithSelf endet in SubClass4 mit Aurufer aus '..self:toString()..' '..par1)
end

function SubClass4:unknownSuperCall()
	print('UnknownSuperCall in SubClass4')
	super:unknownSuperCall()
	print('UnknownSuperCall zurueck in SubClass4')
end

function SubClass4:forkCall(par1)
	print('ForkCall in SubClass4 '..par1)
	super:forkCall(par1)
	print('ForkCall zurueck in SubClass4 '..par1)
end

print(' 1.3 Geschachtelter Superaufruf mit Parameter')
nestedSuperCaller = SubClass4:new()
nestedSuperCaller:superCaller('1.3')
print()

print(' 1.4 Test des Selfbezuges für einen geschachtelten Superaufruf mit Parameter')
nestedSuperCaller:superCallerWithSelf('1.4')
print()

print(' 1.5 Test des verzweigten super calls mit Parameter')
forkCallObj = SubClass4:new()
subObject2 = SubClass2:new()
forkCallObj.subObj2 = subObject2
forkCallObj:forkCall('1.5')
print()

if (err == 1) then
	print(' e1 Erwarte Fehlermeldung: unbekannte Supermethode')
	nestedSuperCaller:unknownSuperCall()
end

--- ###
print()
print('2. Deklaration von Aspekten')
print()
--- ###

-- BasisKlasse1
Class{'BasisKlasse1', basisAtt1 = String, basisAtt2 = Number}

function BasisKlasse1:methode1()
	print('BasisKlasse1 methode1')
end

function BasisKlasse1:methode2()
	print('BasisKlasse1 methode2')
end

-- BasisKlasse2
Class{'BasisKlasse2'}

function BasisKlasse2:methode1()
	print('BasisKlasse2 methode1')
end

function BasisKlasse2:methode2()
	print('BasisKlasse2 methode2')
end

-- Aspect1
Aspect{'Aspect1', 
adapts = {BasisKlasse1}, 
attributes = {asp1Att1=Boolean}, 
before = {beforem1='methode1'}, 
after = {afterm1='methode1'}}

print(' 2.1 Aspekt ist global verfügbar: '..tostring(not(Aspect1 == nil)))
print()

-- Aspect2
Aspect{'Aspect2', 
adapts = {BasisKlasse1, BasisKlasse2}, 
attributes = {asp2Att1=Boolean, asp2Att2=Boolean}, 
before = {beforem1='methode1',beforem2='methode2'}, 
after = {afterm1='methode1', afterm2='methode2'}}

print(' 2.2 Es kann eine Liste von Basisklassen, Aspektattributen und Aspektmethoden angegeben werden: '..tostring(not(Aspect2 == nil)))
print()

function Aspect1:beforem1()
	print('Aspect1 beforem1')
	return true
end

function Aspect1:afterm1()
	print('Aspect1 afterm1')
end

function Aspect2:beforem1()
	print('Aspect2 beforem1')
	return true
end

function Aspect2:beforem2()
	print('Aspect2 beforem2')
	return true
end

function Aspect2:afterm1()
	print('Aspect2 afterm1')
end

function Aspect2:afterm2()
	print('Aspect2 afterm2')
end

print(' 2.3 Die Liste der before/after Aspektmethoden kann deklariert werden und der Aspekt aktiviert werden:')
Aspect2:enable()
print(' ...erfolgreich')
print()


print(' 2.4 Aspektattribute und Methoden des aktivitern Aspect2 sind in den Basisklassen1+2 verfügbar:')
basisObjekt1 = BasisKlasse1:new()
basisObjekt2 = BasisKlasse2:new()
print(tostring(not(basisObjekt1.asp2Att1))..' '..tostring(not(basisObjekt1.asp2Att2))..' '..tostring(not(basisObjekt2.asp2Att1))..' '..tostring(not(basisObjekt2.asp2Att2)))
basisObjekt1:beforem1()
basisObjekt1:afterm1()
basisObjekt1:beforem2()
basisObjekt1:afterm2()
basisObjekt2:beforem1()
basisObjekt2:afterm1()
basisObjekt2:beforem2()
basisObjekt2:afterm2()
print()

-- Aspect3
print(' 2.5 In der before/after Methodenliste können Basismethoden angegeben werden, die nicht in der Basisklasse vorkommen und die Aspektattributliste kann leer sein')
Aspect{'Aspect3', 
adapts = {BasisKlasse1}, 
attributes = {}, 
before = {beforeUnknownMethode='unknownMethode'}, 
after = {afterUnknownMethode='unknownMethode2'}}

function Aspect3:beforeUnknownMethode()
	print('Aspect3 beforeUnknownMethode')
	return true;
end

function Aspect3:afterUnknownMethode()
	print('Aspect3 afterUnknownMethode')
end

Aspect3:enable()
basisObjekt1 = BasisKlasse1:new()
basisObjekt1:beforeUnknownMethode()
basisObjekt1:afterUnknownMethode()
print()

-- Aspect4
print(' 2.6 Als Typen für Aspektattribute werden auch eigene Typen zugelassen:')
Aspect{'Aspect4', 
adapts = {BasisKlasse1}, 
attributes = {asp4Att1=SuperClass, asp4Att2=SubClass3},
before = {},
after = {}}

print(not(Aspect4 == nil))
print()

-- Basisklasse3
Class{'BasisKlasse3', att1 = String}

function BasisKlasse3:overwriteMe()
	print('BasisKlasse3 overwriteMe nicht überschrieben')
end

function BasisKlasse3:observedMethode()
	print('BasisKlasse3 observedMethode aufgerufen')
end

-- Aspect5
Aspect{'Aspect5', 
adapts = {BasisKlasse3}, 
attributes = {overwriteAtt1=Number}, 
before = {overwriteMe='observedMethode'}, 
after = {asp5afterm1='observedMethode'}}

function Aspect5:overwriteMe()
	print('Aspect5 overwriteMe ueberschrieben')
	return true
end

function Aspect5:asp5afterm1()
	print('Aspect5 asp5afterm2 nicht ueberschrieben')
end

print(' 2.7 Aspektmethode überschreibt gleichnamige Basismethode nur in aktiviertem Zustand, zuerst inaktiv:')
basisObjekt3 = BasisKlasse3:new()
basisObjekt3:overwriteMe()
print(' ... dann aktiviert:')
Aspect5:enable()
basisObjekt3:overwriteMe()
print(' ... und wieder deaktiviert:')
Aspect5:disable()
basisObjekt3:overwriteMe()
print()

-- Aspect6
Aspect{'Aspect6', 
adapts = {BasisKlasse3}, 
attributes = {overwriteAtt1=Number}, 
before = {asp6before1='observedMethode'}, 
after = {asp5afterm1='observedMethode'}}

function Aspect6:asp6before1()
	print('Aspect6 asp6before1')
end

function Aspect6:asp5afterm1()
	print('Aspect6 hat asp5afterm1 ueberschrieben')
end

Aspect6:enable()
basisObjekt3 = BasisKlasse3:new()
print(' 2.8 Bei Namensueberschneidungen von Aspektfeatures gilt das zuletzt deklarierte Attribut: '..tostring(not(basisObjekt3.overwriteAtt1)))
print(' ..und die zuletzt deklarierte Methode ist verfügbar:')
basisObjekt3:asp5afterm1()
print()

if (err == 2) then
	print(' e2 Deklaration eines Aspektattributes mit einem anderen Typen als das gleichname Attribut einer Basisklasse')
	Aspect{'AspectE2', 
	adapts = {BasisKlasse1, BasisKlasse2, BasisKlasse3}, 
	attributes = {att1=Number}, 
	before={}, after={}}
end

if (err == 3) then
	print(' e3 Deklaration eines Aspektes mit einer ungueltigen Basisklasse')
	Aspect{'AspectE4', 
	adapts = {BasisKlasse1, BasisKlasse2, UnknownBaseClass}, 
	attributes = {}, 
	before = {}, 
	after = {}}
end

if (err == 4) then
	print(' e4 Aufruf einer nicht explizit deklarierten Aspektmethode')
	Aspect{'AspectE5', 
	adapts = {BasisKlasse3}, 
	attributes = {}, 
	before = {doNotDeclareMe='overwriteMe'}, 
	after = {doNotDeclareMe='overwriteMe'}}
	
	AspectE5:enable()
	errorObject = BasisKlasse3:new()
	errorObject:doNotDeclareMe()
end

--- ###
print()
print('3. Effekte von Aspekten')
print()
--- ###

Class{'EffectSuperClass'}

function EffectSuperClass:methode1(par1)
	return par1;
end

function EffectSuperClass:methode2(par1)
	return par1;
end

function EffectSuperClass:monitorMethode1(par1)
	print('EffectClass1 monitorMethode1 '..par1)
end

Aspect{'Aspect7',
adapts = {EffectSuperClass},
attributes = {},
before = {methode1='monitorMethode1'},
after = {afterMethode1='monitorMethode1'}}

function Aspect7:methode1(par1)
	return not(par1)
end

function Aspect7:afterMethode1(par1)
	return not(par1)
end

Aspect7:enable()

Class{'EffectSubClass1', EffectSuperClass}

function EffectSubClass1:simpleSuperMethode(par1)
	print('EffectSubClass1 simpleSuperMethode '..par1)
end

Class{'EffectSubClass2', EffectSubClass1}

function EffectSubClass2:simpleSuperMethode(par1)
	print('EffectSubClass2 simpleSuperMethode '..par1)
end

effectSuperObjekt = EffectSuperClass:new()
effectSubObjekt = EffectSubClass2:new()

print(' 3.1 Featuresuchreihenfolge korrekt: ')
print('  Aspekt vor Klasse: '..tostring(effectSuperObjekt:methode1(false))..' '..tostring(effectSuperObjekt:methode2(true)))
print('  Aspekt der Oberklasse vor Oberklasse: '..tostring(effectSubObjekt:methode1(false))..' '..tostring(effectSubObjekt:methode2(true)))
print()

Aspect{'Aspect8',
adapts = {EffectSubClass2},
attributes = {},
before = {},
after = {afterSuperAspectMethode='simpleSuperMethode'}}

function Aspect8:afterSuperAspectMethode(par1)
	print('Aspect8 afterSuperAspectMethode '..par1)
	super:simpleSuperMethode(' Super call')
end

Aspect8:enable()

print(' 3.2 Einfacher superCall aus Aspektmethoden: ')
effectSubObjekt:simpleSuperMethode('Adapted function')
print()

Class{'EffectClass', text=String, count=Number, flag=Boolean}

function EffectClass:setText(newText)
	self.text = newText
end

function EffectClass:countUp()
	self.count = self.count + 1
end

function EffectClass:setFlag(isFlagged)
	self.flag = isFlagged
end

function EffectClass:getText()
	return self.text
end

function EffectClass:getCount()
	return self.count
end

function EffectClass:isFlagged()
	return self.flag
end

Aspect{'Aspect9',
adapts = {EffectClass},
attributes = {calls9=Number},
before = {beforeSetText='setText'},
after = {afterSetText='setText'}}

function Aspect9:beforeSetText(newText)
	self.calls9 = self.calls9+1
	print('Aspect9 setText called with '..newText..' calls '..tostring(self.calls9))
	return true
end

function Aspect9:afterSetText(newText)
	self.calls9 = self.calls9+1
	print('Aspect9 setText call finished with '..newText..' calls '..tostring(self.calls9))
end

Aspect9:enable()

print(' 3.3 Before/After Methoden werden ausgefuehrt: ')
effectObjekt = EffectClass:new()
effectObjekt.text = 'oldText'
effectObjekt:setText('newText')
print()

Aspect{'Aspect10',
adapts = {EffectClass},
attributes = {calls10=Number},
before = {beforeSet='set%a+'},
after = {afterGet='get%w*'}}

function Aspect10:beforeSet()
	self.calls10 = self.calls10+1
	print('Aspect10 beforeSet calls '..tostring(self.calls10))
	return true
end

function Aspect10:afterGet()
	self.calls10 = self.calls10+1
	print('Aspect10 afterGet calls '..tostring(self.calls10))
end

Aspect9:disable()
Aspect10:enable()

print(' 3.4 Namensmuster in before/after Methoden werden erkannt, je 2 Aspektmethodenaufrufe:')
effectObjekt:setText('hello')
effectObjekt:countUp()
effectObjekt:setFlag(true)
effectObjekt:getText()
effectObjekt:getCount()
effectObjekt:isFlagged()
print()

Class{'ReturnClass'}

function ReturnClass:adaptedMethode1(par1)
	print('ReturnClass adaptedMethode1 called '..tostring(par1))
end

function ReturnClass:adaptedMethode2(par1)
	print('ReturnClass adaptedMethode2 called '..tostring(par1))
end

Aspect{'ReturnAspect',
adapts = {ReturnClass},
attributes = {},
before = {continue='adaptedMethode1', stop='adaptedMethode2'},
after = {}}

function ReturnAspect:continue()
	return true
end

function ReturnAspect:stop()
	return false
end

ReturnAspect:enable()
returnObject = ReturnClass:new()

print(' 3.5 Rueckgabe einer before Methode entscheidet ueber den Aufruf der adaptierten Methode')
returnObject:adaptedMethode1('3.5')
returnObject:adaptedMethode2('3.5 sollte nicht aufgerufen werden')
print()

Class{'MultiBindClass'}

function MultiBindClass:methode(par1)
	print('MultiBindClass MultiBindMethode '..par1)
end

Aspect{'MultiBindAspect',
adapts = {MultiBindClass},
attributes = {},
before = {multiAspectMethode1='methode', multiAspectMethode2='methode', multiAspectMethode3='methode'},
after = {multiAspectMethode1='methode', multiAspectMethode2='methode', multiAspectMethode3='methode'}}

function MultiBindAspect:multiAspectMethode1(par1)
	print('MultiBindAspect multiAspectMethode1 '..par1)
	return true
end

function MultiBindAspect:multiAspectMethode2(par1)
	print('MultiBindAspect multiAspectMethode2 '..par1)
	return true
end

function MultiBindAspect:multiAspectMethode3(par1)
	print('MultiBindAspect multiAspectMethode3 '..par1)
	return true
end

MultiBindAspect:enable()
multiBindObject = MultiBindClass:new()

print(' 3.6 Eine mehrfach gebundene Basismethode wird aufgerufen:')
multiBindObject:methode('3.6')
print()

Class{'OrderClass'}

function OrderClass:methode1()
	print('OrderClass methode1')
end

Aspect{'FirstAspect',
adapts = {OrderClass},
attributes = {},
before = {firstAspectBefore='methode1'},
after = {firstAspectAfter='methode1'}}

function FirstAspect:firstAspectBefore()
	print('first before')
	return true
end

function FirstAspect:firstAspectAfter()
	print('first after')
end

Aspect{'SecondAspect',
adapts = {OrderClass},
attributes = {},
before = {secondAspectBefore='methode1'},
after = {secondAspectAfter='methode1'}}

function SecondAspect:secondAspectBefore()
	print('second before')
	return true
end

function SecondAspect:secondAspectAfter()
	print('second after')
end

Aspect{'ThirdAspect',
adapts = {OrderClass},
attributes = {},
before = {thirdAspectBefore='methode1'},
after = {thirdAspectAfter='methode1'}}

function ThirdAspect:thirdAspectBefore()
	print('third before')
	return true
end

function ThirdAspect:thirdAspectAfter()
	print('third after')
end

FirstAspect:enable()
SecondAspect:enable()
ThirdAspect:enable()

orderObject = OrderClass:new()

print(' 3.7 + 3.8 Reihnfolge der before/after Methoden: before(third>second>first), after(first>second>third)')
orderObject:methode1()
print()

--- ###
print()
print('4. Aktivieren von Aspekten')
print()
--- ###

Class{'EnableTestClass'}

function  EnableTestClass:methode1(par1)
	print('EnableTestClass methode1 '..par1)
end

Aspect{'EnableAspect',
adapts = {EnableTestClass},
attributes = {enableAtt=String},
before = {aspectMethode1='methode1'},
after = {aspectMethode2='methode1'}}

function EnableAspect:aspectMethode1(par1)
	print('EnableAspect aspectMethode1 '..par1)
	return true
end

function EnableAspect:aspectMethode2(par1)
	print('EnableAspect aspectMethode2 '..par1)
end

enableObject = EnableTestClass:new()

print(' 4.1 Ein Aspekt ist initial deaktiviert, es folgt nur der Basismethodenprint:')
enableObject:methode1('4.1')
print()

print(' 4.2 Ein Aspekt verfuegt ueber eine enable() und disable() methode:')
EnableAspect:enable()
EnableAspect:disable()
EnableAspect:enable()
enableObject:methode1('4.2')
print()

print(' 4.3 Aspektattribute behalten ihre Werte im deaktivierten Zustand')
enableObject.enableAtt = 'enabled'
print(' aktiviert: '..enableObject.enableAtt)
EnableAspect:disable()
EnableAspect:enable()
print(' deaktiviert und wieder aktiviert: '..enableObject.enableAtt)
print()

if (err == 5) then
 	local testNo = os.time()%2 
 	if (testNo < 1) then
		print(' e5 Aspektattribute sind nur im aktivierten Zustand sichtbar:')
		enableObject.enableAtt = 'enabled'
		print(' aktiviert: '..enableObject.enableAtt)
		EnableAspect:disable()
		print(' deaktiviert: '..enableObject.enableAtt) 
	else
		print(' e5 Aspektmethoden sind nur im aktivierten Zustand sichtbar:')
		print(' aktiviert:')
		enableObject:aspectMethode1('enabled') 
		EnableAspect:disable()
		print(' deaktiviert:')
		enableObject:aspectMethode1('enabled')  
	end
end

if (extra > 0) then
	--- ###
	print()
	print('5. Extras')
	print()
	--- ###
	
	Class{'ExtraClass'}
	
	function ExtraClass:methode(par1)
		print(' ExtraClass methode '..par1)
	end
	
	if (extra == 1) then	
		print(' 5.1 Ein Aspekt mit rekursiven after/before methoden wird definiert')
		Aspect{'RekursiveAspect1',
		adapts = {ExtraClass},
		attributes = {},
		before = {before1 = 'after1'},
		after = {after1 = 'before1'}}
		
		RekursiveAspect1:enable()
		
		print(' 5.1 Ein Aspekt mit rekursiver before methode')
		Aspect{'RekursiveAspect2',
		adapts = {ExtraClass},
		attributes = {},
		before = {before1 = 'before1'},
		after = {}}
		
		RekursiveAspect2:enable()
		
		print(' 5.1 Test fehlgeschlagen, es wurde eine Fehlermeldung erwartet')
	end
	
	if (extra == 2) then	
		print(' 5.2 Es wird eine Klasse mit einem Attribut vom eigenen Typ deklariert (keine Fehlermeldung erwartet)')
		Class{'ExtraClass2', att1 = String, att2 = Number, att3 = ExtraClass2, att4 = Boolean}
		print(' 5.2 Es wird eine Aspekt mit einem Attribut von einem unbekannten Typ deklariert (Fehlermeldung erwartet)')
		Aspect{'ExtraAspect', 
		adapts = {ExtraClass3},
		attributes = {att1 = String, att2 = Number, att3 = UnknownTyp, att4 = Boolean},
		before = {},
		after = {}}
		
	end
end

	