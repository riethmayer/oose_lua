require("sm_loader")
root_require("aufgabe3.Source.Backgammon")

bgGame = Backgammon:new()
bgGame:start(false)			-- startet ein Backgammonspiel ohne Benutzerinteraktion, dabei wird das Spielfeld einmalig angezeigt
MoveChecker:enable()		-- aktiviert den MoveChecker: Eingabesyntax und Spielzuege werden jetzt geprueft
MoveLogger:enable()			-- aktiviert den MoveLogger: Der Spielverlauf wird geloggt
bgGame:print()
bgGame:setDice(3,5)			-- setzt die Würfelwerte auf 3 und 5
bgGame:moveStone("24 21")	-- Ein schwarzer Stein wird erfolgreich von Point 24 auf Point 21 verschoben
bgGame:moveStone("24 20")	-- es sollte ein Fehlermeldung erscheinen, da keine 4 gewuerfelt wurde
bgGame:moveStone("8 3")		-- Ein schwarzer Stein wird erfolgreich von Point 8 auf Point 3 verschoben
bgGame:print()				-- das aktuelle Spielbrett wird angezeigt, weiss ist jetzt am Zug
bgGame:setDice(2, 2)		-- setzt die Würfelwerte auf 2 und 2
bgGame:moveStone("1 3")		-- Ein weisser Stein wird erfolgreich von Point 1 auf Point 3 verschoben und schlaegt dabei einen Schwarzen
bgGame:moveStone("1 3")		-- Ein weisser Stein wird erfolgreich von Point 1 auf Point 3 verschoben
bgGame:print()				-- das aktuelle Spielbrett wird angezeigt, schwarz ist jetzt am Zug und er hat einen geschlagenen Stein
bgGame:setDice(2,3)			-- setzt die Würfelwerte auf 2 und 3
bgGame:moveStone("24 22")	-- Trotz der gewuerfelten zwei ist das ein ungueltiger Spielzug, da zuerst der geschlagene Stein ins Spiel gebracht werden muss
bgGame:moveStone("0 23")	-- Der geschlagene Stein wird ins Spiel gebracht
bgGame:moveStone("24, 21")	-- Hier sollte der Syntaxcheck einen Fehler melden
bgGame:print()
MoveChecker:disable()		-- Die Steine können jetzt unabhängig von gueltigen Zuegen bewegt werden
MoveLogger:disable()		-- Die naechsten zuege sollen nicht geloggt werden
bgGame:moveStone("24 1")	-- Das sollte ohne den MoveChecker ohne Fehlermeldung funktionieren
bgGame:print()
bgGame:moveStone("23 1")
bgGame:moveStone("21 1")
for k = 1, 5 do
	bgGame:moveStone("13 2")
end
for k = 1, 2 do
	bgGame:moveStone("8 4")
end
MoveChecker:enable()		-- Die Steine duerfen jetzt nur noch regelkonform bewegt werden, schwarz ist noch am zug und hat Wuerfelwert 3 zur Verfuegung
MoveLogger:enable()			-- Die naechsten zuege sollen wieder geloggt werden
bgGame:moveStone("1 0")		-- Schwarz würfelt den ersten Stein heraus, weiss ist am Zug
bgGame:print()
print()
bgGame:start(true)			-- Hier startet ein neues Spiel mit der Benutzerinteraktion über die Konsole


