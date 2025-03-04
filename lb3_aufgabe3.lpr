{  Sourcecodeinformation:
Name:       Markus Wirtz
Aufgabe:    3
}

{ Schreiben Sie ein Pascal-Programm, welches eine Adressverwaltung in einer
  Datei realisiert. Neben dem Hauptprogramm sind folgende Prozeduren zu entwerfen:
  - Eingabe von Adressen - Fertig
  - Suchen einer Adresse aufgrund des Nachnamens - Fertig
  - Ausgabe einer Adressliste in alphabetischer Reihenfolge - Fertig
  - Ändern einer Adresse - Fertig
}

program lb3_aufgabe3;           // Start des Programmabschnitts

uses Crt, SysUtils, Classes;    // Für TStringList und StringReplace

type                            // Definition der Datenstruktur für Adressdaten
    TAdresse = record
      vorname:string;
      nachname:string;
      strasse_nr:string;
      plz:string;
      ort:string;
		end;


VAR                             // Allgemeine Variablendeklaration
    Datei: Textfile;
    Adresse: TAdresse;
    Zeile, VerarbeiteteZeile, nachname, auswahl: string;

const
  Pfad = 'lb3_aufgabe3_adressen.txt';  // Fester Pfad für Datei im selben Verzeichnis

procedure NeueAdresseSpeichern(Adresse:TAdresse);   // Prozedur zum Speichern der Daten
begin
  Assign(Datei, Pfad);    // Standard-Dateioperation für Öffnen
  try
    Append(Datei);            // Versucht, an die Datei anzuhängen;
	except
    on E: EInOutError do
      Rewrite(Datei);         // Datei neu erstellen und zum schreiben öffnen, wenn Anhängen fehlschlägt
	end;

  with Adresse do            // Einfaches ansprechen der Felder des Records "Adresse" mit "with"
    writeln(Datei, vorname, ';', nachname, ';', strasse_nr, ';', plz, ';', ort);
  CloseFile(Datei);          // Schließen der Datei
  readln();
end;


procedure DatenEingebenZumSpeichern;     // Benutzer Dateneingabe
begin
  writeln('Bitte geben Sie nun eine neue Adresse ein!');
  writeln('-----------------------------------------');
  write('Vorname: ');
  readln(Adresse.vorname);
  write('Nachname: ');
  readln(Adresse.nachname);
  write('Strasse Nr: ');
  readln(Adresse.strasse_nr);
  write('PLZ: ');
  readln(Adresse.plz);
  write('Ort: ');
  readln(Adresse.ort);

  NeueAdresseSpeichern(Adresse);        // Aufruf der Speicherprocedur

  writeln('>>> Vielen Dank.');

end;


procedure NachnameSuchen(GesuchterNachname: string);
var                                     // Prodcedurspezifische Deklarationen
    Teile: array of string;
    Gefunden: Boolean;
begin
  Assign(Datei, Pfad);              // Standard-Dateioperation für Öffnen
  Reset(Datei);                         // Datei zum Lesen öffnen
  Gefunden := False;

  while not EOF(Datei) do               // Prüfe auf EOF
  begin
    ReadLn(Datei, Zeile);
    Teile := Zeile.Split(';');          // Zeile an Semikolons aufteilen

    // Vermutung: Der Nachname befindet sich an der zweiten Stelle
    if Length(Teile) > 1 then // Sicherstellen, dass die Zeile genug Teile hat
      nachname := Teile[1]; // Index 1, da Arrays bei 0 beginnen

    if AnsiCompareText(nachname, GesuchterNachname) = 0 then    // Vergleich ohne Berücksichtigung der Groß- und Kleinschreibung
    begin
      VerarbeiteteZeile := StringReplace(Zeile, ';', ',', [rfReplaceAll]);  // Ersetze ';' in ',' für bessere Lesbarkeit in der Konsole.
      WriteLn('Eintrag gefunden: ', VerarbeiteteZeile);
      Gefunden := True;
      Break; // Schleife beenden, nachdem der Eintrag gefunden wurde
    end;
  end;

  if not Gefunden then  // Wenn kein Eintrag gefunden
    WriteLn('Kein Eintrag fuer den Nachnamen "', GesuchterNachname, '" gefunden.');
  CloseFile(Datei); // Schließen der Datei
  readln();

end;


procedure DatenEingebenZumSuchen;       // Benutzer Dateneingabe
var
    GesuchterNachname: string;
begin
  writeln('Suchen Sie im Adressbuch auf Basis eines "Nachnamens"');
  writeln('-----------------------------------------------------');
  write('Geben Sie einen Nachname ein: ');
  readln(GesuchterNachname);
  writeln();
  NachnameSuchen(GesuchterNachname);    // Aufruf der Procedur zur Suche
end;


procedure AdresseListeAusgebenSortiert;
var
    ZeilenListe: TStringList;
begin
  Assign(Datei, Pfad);
  Reset(Datei); // Datei zum Lesen öffnen

  ZeilenListe := TStringList.Create;

  try
     while not EOF(Datei) do      // Wiederholen, bis Ende der Datei erreicht ist
    begin
      ReadLn(Datei, Zeile);       // Eine Zeile aus der Datei lesen
      Zeile := StringReplace(Zeile, ';', ',', [rfReplaceAll]); // Ersetze ';' in ',' für bessere Lesbarkeit in der Konsole.
      ZeilenListe.Add(Zeile);     // Zeile zur Liste hinzufügen
    end;
    ZeilenListe.Sort;             // Liste alphabetisch sortieren

                                  // Sortierte Liste ausgeben
    for Zeile in ZeilenListe do
      WriteLn(Zeile);
  finally
    ZeilenListe.Free;             // Speicher wieder freigeben
  end;

  CloseFile(Datei);               // Schließen der Datei
  readln();
end;


procedure AdresseBearbeiten(GesuchterNachname: string);
var
    ZeilenListe, Teile: TStringList;
    i: Integer;
    Gefunden: Boolean;
    NeueAdresse: TAdresse;

begin
  Assign(Datei, Pfad);
  Reset(Datei); // Datei zum Lesen öffnen

  ZeilenListe := TStringList.Create;
  Teile := TStringList.Create;

  try
    while not EOF(Datei) do
    begin
      ReadLn(Datei, Zeile);
      ZeilenListe.Add(Zeile); // Füge jede Zeile zur Liste hinzu
    end;

    Gefunden := False;

    // Durchsuche alle Zeilen
    for i := 0 to ZeilenListe.Count - 1 do
    begin
      Teile.Clear;
      Teile.Delimiter := ';'; // Definiere das Trennzeichen
      Teile.DelimitedText := ZeilenListe[i]; // Teile die Zeile in Bestandteile

      if AnsiCompareText(Teile[1], GesuchterNachname) = 0 then // Vergleiche Nachnamen
      begin
        Gefunden := True;

        // Hier könnte man die Details der gefundenen Adresse anzeigen und um neue Eingaben bitten
        writeln('Eintrag gefunden: ', Teile.DelimitedText);
        writeln('Geben Sie die neuen Daten ein.');

        // Neue Daten vom Benutzer einlesen (als Beispiel)
        write('Vorname: ');
        readln(NeueAdresse.vorname);
        write('Nachname: ');
        readln(NeueAdresse.nachname);
        write('Strasse Nr: ');
        readln(NeueAdresse.strasse_nr);
        write('PLZ: ');
        readln(NeueAdresse.plz);
        write('Ort: ');
        readln(NeueAdresse.ort);

        // Aktualisiere die Zeile mit den neuen Daten
        ZeilenListe[i] := Format('%s;%s;%s;%s;%s', [NeueAdresse.vorname, NeueAdresse.nachname, NeueAdresse.strasse_nr, NeueAdresse.plz, NeueAdresse.ort]);
        Break; // Beende die Schleife nach der Bearbeitung
      end;
    end;

    if not Gefunden then
    begin
      writeln('Kein Eintrag mit dem Nachnamen "', GesuchterNachname, '" gefunden.');
    end
    else
    begin
      // Schreibe die aktualisierte Liste zurück in die Datei
      Rewrite(Datei); // Öffne die Datei zum Überschreiben
      for Zeile in ZeilenListe do
        writeln(Datei, Zeile);
    end;
  finally
    ZeilenListe.Free;
    Teile.Free;
    CloseFile(Datei); // Schließe die Datei
    readln();
  end;
end;

procedure DatenEingebenZumAendern;       // Benutzer Dateneingabe
var
    GesuchterNachname: string;
begin
  writeln('Bearbeiten Sie einen Adressbucheintrag auf Basis des "Nachnamens"');
  writeln('-----------------------------------------------------------------');
  write('Geben Sie einen Nachname ein: ');
  readln(GesuchterNachname);
  writeln();
  AdresseBearbeiten(GesuchterNachname);    // Aufruf der Procedur zur Bearbeitung
end;


begin                        // Hauptprogramm

  repeat
    ClrScr;
    writeln('Willkommen im Adressbuch. Treffen Sie Ihre Auswahl!');
    writeln('---------------------------------------------------');
    writeln('1)  Adresse anlegen');
    writeln('2)  Adresse suchen');
    writeln('3)  Adressen sortiert ausgeben');
    writeln('4)  Adresse bearbeiten');
    writeln('5)  Programm beenden');
    writeln();
    write('Ihre Auswahl: ');
    readln(auswahl);

    case auswahl of
      '1': DatenEingebenZumSpeichern;
      '2': DatenEingebenZumSuchen;
      '3': AdresseListeAusgebenSortiert;
      '4': DatenEingebenZumAendern;
      '5': begin
             writeln('Programm wird beendet...');
             Break; // Beendet die Schleife und damit das Programm
           end;
    else
      writeln('Ungueltige Eingabe, bitte erneut versuchen.');
      readln; // Pause, damit der Nutzer die Nachricht lesen kann
    end;
  until auswahl = '5'; // Wiederhole, bis der Nutzer '5' für Beenden wählt

end.


