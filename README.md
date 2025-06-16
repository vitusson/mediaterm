Mit dem Bash-Skript MediaTerm lassen sich Filme aus den Mediatheken der öffentlich-rechtlichen Fernsehsender ressourcenschonend im Linux-Terminal suchen, abspielen, herunterladen und als Bookmarks speichern. Für das Abspielen der Filme wird standardmäßig der Medienplayer mpv eingesetzt, der aus den Paketquellen der gängigen Linux-Distributionen installiert werden kann. Vorausgesetzt werden außerdem wget, ffmpeg und xz bzw. xz-utils; zusätzlich empfohlen wird yt-dlp.

Bei der ersten Suchanfrage mit MediaTerm erfolgt (nach Bestätigung durch den Benutzer) automatisch ein Download der Filmliste (Filmliste-akt.xz) von MediathekView, die im – ebenfalls automatisch vom Skript angelegten – Verzeichnis $HOME/MediaTerm entpackt und aufbereitet wird. Später lässt sich die Filmliste jederzeit unter Verwendung der Option "-u" aktualisieren.

Ein Überblick über alle Funktionen von MediaTerm einschließlich Anwendungsbeispielen wird mit mediaterm -h aufgerufen.

Lizenz: MediaTerm wird als freie Software unter der Lizenz GNU GENERAL PUBLIC LICENSE, GPLv3 (inoffizielle deutsche Übersetzung) zur Verfügung gestellt.


Neu in Version 14.0 (2024-02-08):
• Themenfilter: Ein Unterstrich unmittelbar vor einem Suchbegriff bewirkt, dass dieser nur im Feld "Thema" (= Fernsehserie) gesucht wird. Beispiele:
    mediaterm _tatort
findet alle Tatortfolgen.
    mediaterm _"science talk" schlaf
findet alle Folgen von "Science Talk", in deren Titel oder Beschreibung "schlaf" vorkommt.
    mediaterm Oderbruch _~Oderbruch
findet alle Filme mit "Oderbruch", schließt jedoch die Folgen der gleichnamigen Serie vom Suchergebnis aus.
• Die neue Option -e entfernt Dubletten aus den Suchergebnissen. Haben zwei oder mehr Filme identische Film-URLs, wird jeweils nur der erste Treffer angezeigt. Die Filmlisten bestehen derzeit zu gut 20% aus derartigen Dubletten; insbesondere sind viele Sendungen sowohl unter der ARD als auch unter einer Landesrundfunkanstalt gelistet.
• Die Optionen -q und -Q wurden ersatzlos gestrichen, um den Code des Skripts schlank zu halten. Die Möglichkeit der Auswahl verschiedener Filmqualitäten auf der internen Kommandozeile bleibt davon selbstverständlich unberührt.
• Das Kommando a zum Einschalten der Blätterfunktion auf der internen Kommandozeile zeigt, wenn ohne Sprungnummer angegeben, die letzten 5 bzw. 10 Treffer der Suchergebnisse an, statt wie bisher an den Anfang zu springen. Mit der Minustaste kann dann bequem zurückgeblättert werden. Zum Anfang der Trefferliste gelangt man mit a1.

Neu in Version 13.0 (2023-05-08):
• Die neue Option -k gibt die Ergebnisliste einer Filmsuche in kompakter Form aus – ohne Filmbeschreibungen und Film-URLs. Auf diese Weise haben mehr Filmtitel im Terminal Platz. Die Filmbeschreibung zu einem Film lässt sich mit dem Kommando f<Filmnr.> anzeigen.
• Die optionale Auswahl zusätzlicher Filmqualitäten mittels yt-dlp und Kommando y<Filmnr.> bzw. dy<Filmnr.> listet jetzt auch gesonderte Audioformate auf. Für das Abspielen oder den Download des Films lassen sich mit der Eingabe <Video-Nr.>+<Audio-Nr.> gegebenenfalls Video- und Audioformate kombinieren.
• Es gibt nur noch ein Kommando a<Filmnr.>, um sich eine begrenzte Zahl von Suchergebnissen anzeigen zu lassen und mit "+" und "-" vor- und zurückzublättern (A<Filmnr.> entfällt). Es werden im Allgemeinen fünf Ergebnisse angezeigt, bei Verwendung der Optionen -k (Kompaktanzeige) und -l (Livestreams) hingegen zehn.
• Der Download der Filmliste bevorzugt nun IPV4-Adressen, da er sich mit IPV6 als fehleranfällig erwies.

Neu in Version 12.0 (2022-04-01):
• Die neuen Kommandos y<Filmnr.> und dy<Filmnr.> erlauben für viele Filme das Abspielen bzw. Speichern weiterer, nicht in der MediathekView-Filmliste enthaltener Filmqualitäten. Voraussetzung ist die Installation des Programms yt-dlp. MediaTerm kann selbstverständlich unter Verzicht auf die neue Funktion wie bisher auch ohne yt-dlp genutzt werden, das deshalb als optionale Abhängigkeit betrachtet wird.
• Mediaterm verwendet jetzt für die Wiedergabe der niedrigen und hohen Filmqualitäten aller Livestreams das unter Version 11.0 beschriebene Verfahren, das bislang nur für Livestreams mit getrennten Video- und Audio-URLs eingesetzt wurde.

Neu in Version 11.1 (2021-10-21):
• Für die neuerdings in die Filmliste aufgenommen Livestreams der WDR-Lokalzeit musste die Auswahl und Zusammensetzung der Film-URLs angepasst werden.
• Außerdem wird jetzt in der Auflistung der Livestreams die inzwischen verfügbare hohe Qualität für DW und WDR korrekt angezeigt.

Neu in Version 11.0 (2021-05-11):
• Die MDR-Livestreams funktionieren wieder.
• In den Livestream-M3U8-Playlists mancher Sender sind Ton- und Videospuren getrennt. Dies ist seit gut einem Jahr der Fall bei den ZDF-Livestreams, einschließlich 3Sat und Phoenix. Die Livestreams dieser Sender werden jetzt endlich in allen drei Qualitäten (niedrig, mittel, hoch) mit Ton wiedergegeben. Hierfür nutzt MediaTerm eine Option des Medienplayers mpv. Verwendet man einen anderen Medienplayer, wird diesem zum Abspielen eines ZDF-Livestreams – unabhängig von der gewählten Filmqualität – die Original-M3U8-Playlist übergeben.
Auch beim Aufzeichnen (Kommando "d...") der ZDF-Livestreams wird grundsätzlich die Original-M3U8 von FFmpeg verarbeitet. Hingegen werden die Livestreams der anderen Sender in der vom Nutzer gewählten Qualität aufgezeichnet.
Da somit MediaTerm (hoffentlich) jeweils eine "intelligente" Auswahl der Livestream-URL(s) vornimmt, wurde das Kommando "o" zum Erzwingen der Original-M3U8 entfernt.
• Beim Linkcheck der Bookmarks per Kommando "c" konnte sich das genutzte Programm Wget in seltenen Fällen scheinbar "aufhängen", was jetzt durch eine bessere Einstellung des Timeouts unterbunden wird.
• Vor dem Download der Filmliste (Option "-u") wird die Bestätigung durch den Nutzer nur noch dann abgefragt, wenn (noch) keine lokale Filmliste gespeichert ist – insbesondere also beim ersten Aufruf von mediaterm.

Neu in Version 10.1 (2021-02-01):
• Der erhöhte Arbeitsspeicherbedarf bei der Aufbereitung der heruntergeladenen, zuletzt stetig angewachsenen MediathekView-Filmlisten konnte erheblich reduziert werden.
• Zwei bisher für Livestreams (Option -l) nur unvollkommen funktionierende Kommandos wurden entsprechend angepasst: Die Anzeige aller zu einem Film/Stream gehörenden URLs (Kommando i) sowie die Teilansicht der Trefferliste mit je fünf bzw. zehn Filmen (Kommando a bzw. A) und Blätterfunktion (Kommandos + und -).

Neu in Version 10.0.1 (2020-08-31):
Dieses Minimal-Update bringt keine funktionalen Neuerungen.
• Meine (also des Entwicklers) E-Mail-Adresse im Kopfkommentar des Skripts wurde aktualisiert.
• Eine redundante if-Anweisung im Code wurde entfernt.

Neu in Version 10.0 (2020-06-25):
• Mit zwei neuen Optionen -q und -Q lassen sich in den Suchergebnissen die URLs für die jeweils niedrigste bzw. höchste verfügbare Filmqualität ausgeben (statt durchgehend die mittlere Standardqualität). Dies kann sinnvoll sein, wenn die URLs der bevorzugten Filmqualität im Rahmen eines eigenen Skriptes verwendet werden sollen – aber auch, wenn die Möglichkeit gewünscht wird, Filme direkt per Anklicken im (entsprechend konfigurierten) Terminal abzuspielen. Die Filmsuche unter Verwendung der Optionen -q und -Q kann allerdings bei großen Treffermengen deutlich langsamer als die Standardsuche sein, da die URLs für die alternativen Filmauflösungen nicht als Ganzes in der Filmliste enthalten sind, sondern vom Skript erst zusammengesetzt werden müssen.
• Die kompakte Hilfe für die Filmsuche auf der internen Eingabezeile wurde entfernt. Stattdessen erfolgt mit dem Kommando H jetzt ein Sprung in den Abschnitt SUCHOPTIONEN des neu gegliederten allgemeinen Hilfetextes.
• Die im Rahmen der Benutzerführung ausgegebenen Meldungen und Hinweise wurden überarbeitet.
• Suchanfragen müssen nicht mehr mindestens 3 Zeichen lang sein.
• Unter den bisherigen MediaTerm-Versionen konnte ein abgebrochener Download der gepackten Filmliste Filmliste-akt.xz ein Problem darstellen, da bei einem erneuten Download die Liste unter dem Namen "Filmliste-akt.xz.1" gespeichert und vom Skript nicht entpackt wurde. Jetzt wird beim Download eine bereits vorhandene (unvollständige) Datei überschrieben.
• Für das Abspielen und den Download von Livestreams in niedriger Qualität wird nun wieder bevorzugt eine Auflösung ≤ 640x360 (statt ≤ 512x288) gewählt.
• Außerdem zahlreiche Änderungen und Straffungen vorwiegend programmtechnischer Natur.

Neu in Version 9.1 (2020-02-06):
• Das Problem einer unvollständigen Aktualisierung der Filmliste (Option -u) unter Linux-Systemen, die "mawk" nutzen, ist behoben. Die auf den Download folgende Aufbereitung der Filmliste kann jetzt allerdings einige Sekunden länger dauern.
• Das Abspielen der Livestreams wurde so angepasst, dass auch der Sender SR wieder funktioniert.
• Das Kommando "o" kann jetzt nicht nur für das Abspielen, sondern in der Form do<Filmnr.> auch für den Download von Livestreams verwendet werden. Damit wird von FFmpeg die Original-M3U8 verarbeitet (nur so lassen sich derzeit die Livestreams der ZDF-Sender mit Ton abspielen bzw. aufzeichnen).
• Für das Abspielen und den Download von Livestreams in niedriger Qualität wird nun bevorzugt eine Auflösung ≤ 512x288 gewählt (statt ≤ 640x360).
• Vor dem Download wird jetzt auch eine mittlere Filmqualität korrekt angezeigt/bestätigt.

Neu in Version 9.0 (2020-01-07):
• Die Filmsuche erstreckt sich nicht mehr über alle Felder der Filmliste, sondern schließt URLs und andere i.A. für die Suche unerhebliche Felder aus.
• Die M3U8-Wiedergabelisten der Livestreams wurden bisher direkt an den Medienplayer bzw. an FFmpeg weitergereicht. Ab dieser Version werden Livestreams standardmäßig in einer mittleren Auflösung abgespielt und gespeichert, wobei das Skript jeweils einen passenden Substream aus der Wiedergabeliste herauspickt. Eine höhere oder niedrigere Qualität kann – wie von anderen Filmen gewohnt – per einem der Filmnummer vorangestellten "h" bzw. "n" ausgewählt werden (nicht in hoher Auflösung verfügbar sind derzeit die Livestreams von 3sat, Deutscher Welle und SR). Soll stattdessen wie in den bisherigen Versionen die Original-M3U8-Datei an den Player übergeben werden, geht das mit einem der Filmnummer vorangestellten "o" (dies empfielt sich bei allen ZDF-Sendern, da sonst der Ton fehlt).
• Per export-Befehl in der Shell lassen sich jetzt bei Bedarf der genutzte Medienplayer (bzw. dessen Optionen) sowie der Zielordner für den Filmdownload abweichend von den Vorgaben des Skripts auswählen, z. B.
    export MT_PLAYER="vlc --play-and-exit"
    export MT_DLDIR="$HOME/Videos"
Mit folgender Definition der Variablen MT_PLAYER werden z.B. Livestreams bei vorangestelltem Kommando "o" in mittlerer statt bester Qualität abgespielt:
    export MT_PLAYER="mpv --hls-bitrate=3000000"
Als dauerhafte Einstellung können die export-Befehle in die versteckte Datei .bashrc im Homeverzeichnis eingefügt werden.
• Die Anzeige eines Bookmarks als detailliertes Suchergebnis (jetzt Kommando s<Bookmarknr.>, bisher a<Bookmarknr.>) war unvollständig, wenn unmittelbar vorher eine Suche nach Livestreams (Option -l) durchgeführt worden war. Behoben!
• Die beim Aufbereiten der aktualisierten Filmliste (Option -u) unter neueren gawk-Versionen auftretenden, für das Funktionieren unerheblichen Warnmeldungen werden nun unterdrückt.

Neu in Version 8.0 (2019-10-18):
Die AKTUALISIERUNG DER FILMLISTE (Option -u) wurde grundlegend überarbeitet:
• Wurde bisher die Filmliste von einem zufällig ausgewählten Verteiler-Server heruntergeladen, so erfolgt der Download jetzt über den zentralen Load-Server von MediathekView. Die automatische Weiterleitung an einen passenden Verteiler trägt zur gleichmäßigen Verteilung der Serverlast bei; erfolglose Download-Versuche von vorübergehend vom Netz genommenen Verteilern werden ggf. verhindert.
• Um Mehrfach-Downloads bereits gespeicherter Filmlisten nach Möglichkeit auszuschließen, erfolgt vor dem Download eine Aktualitätsprüfung. Ab Erstellungszeit der lokalen Liste kann frühestens 30 Minuten nach der übernächsten vollen Stunde wieder aktualisiert werden. (Beispiel: Wurde die lokale Liste um 10:15 Uhr erstellt, ist ein neuer Download am selben Tag nicht vor 12:30 Uhr möglich; Erstellungsdatum und -uhrzeit der lokalen Filmliste lassen sich per Option -v anzeigen).
• Beim Download der Filmliste wird der User-Agent "MediaTerm" an den Server übertragen.
• Der unerwünschte Effekt einer leeren Filmliste nach einem gescheiterten Verbindungsaufbau zum MediathekView-Server wurde behoben; eine bereits lokal gespeicherte Filmliste bleibt in dem Fall erhalten.
Weitere Änderungen:
• Die Wiedergabe eines Livestreams (Option -l) in geringerer Auflösung (Kommando m<Filmnr.>) funktioniert nun auch, wenn die m3u8-Playlist des Senders auf relative URLs verweist.
• Die Option -p zur Wahl eines anderen Medienplayers als dem standardmäßig verwendeten mpv wurde entfernt. Wer die Filme mit einem alternativen Player abspielen möchte, kann im Abschnitt "Vorbelegte Variablen" des Skripts (ziemlich am Anfang, direkt nach dem Copyright-Block) die Variable "player" einfach entsprechend anpassen.

Neu in Version 7.6.1 (2019-10-01):
• Fehlerhafte Film-Sortierung nach Sendezeit (Optionen -s und -t) in Systemen mit aktueller gawk-Implementierung wurde behoben. Eventuell auftretende Warnmeldungen beim Download der Filmliste (Option -u), die ebenfalls von gawk erzeugt werden, konnten leider nicht behoben werden, sind aber für die Funktionsfähigkeit unerheblich (hier unter gawk-Version 5.0.1).
• Anpassung der Linkcheck-Funktion für Bookmarks an neue Wget-Versionen.

Neu in Version 7.6 (2019-08-21):
• Lästige Warnmeldungen des Browsers, die gelegentlich beim Aufruf von Sendungs-Internetseiten (Kommando w<Filmnr.>) auftraten und die Rückkehr zur MediaTerm-Eingabezeile verhinderten, werden nun unterdrückt.
• Bei Aktualisierung der Filmliste (Option -u) wird die URL der herunterzuladenden Datei jetzt vor dem Download angezeigt – und somit auch der genutzte Verteiler (1 bis 6).
• Die störende Anzeige von Escape-Sequenzen für Zeilenumbrüche in einigen Film-Beschreibungen wurde behoben. Die Zeilenumbrüche werden allerdings von MediaTerm u.a. aus Platzgründen nicht umgesetzt, sondern durch ein Leerzeichen ersetzt.
• Code für die Korrektur inzwischen nicht mehr auftretender Fehler in der Filmliste wurde entfernt (Konvertierung fehlerhafter SR-URLs [siehe Version 7.5-sr] und Ergänzung einer fehlenden Klammer [siehe Version 7.4]).

Neu in Version 7.5-sr (2019-08-14):
Die vom Skript genutzte Filmliste von MediathekView enthält für zahlreiche Filme des Senders "SR" fehlerhafte URLs. Diese werden in der MediaTerm-Ergebnisliste zwar in der falschen Form angezeigt, beim Abspielen oder Download der zugehörigen Filme jetzt jedoch automatisch in eine gültige URL konvertiert. Diese Behelfs-Version des Skripts wird nur so lange als Download zur Verfügung gestellt, wie die Fehler in der Filmliste bestehen.

Neu in Version 7.5 (2019-06-14):
• Die Optionen -s und -t zur Sortierung der Filmtreffer nach Sendedatum liefern jetzt – innerhalb des jeweiligen Datums – auch eine Feinsortierung nach Uhrzeit.
• Libav wird von MediaTerm nicht mehr unterstützt. Die Installation von FFmpeg ist Voraussetzung für den Download von Filmen im m3u8-Format.

Neu in Version 7.4.1 (2019-05-16):
Ein Fehler im Text der Suchhilfe (= Kommando H) wurde korrigiert.

Neu in Version 7.4 (2019-04-29):
• Seit Version 7.2 nicht mehr funktionierende Option -B wurde repariert.
• Fehlende schließende Klammer in einem Filmeintrag machte Probleme bei Aufbereitung der Filmliste und wird jetzt automatisch ergänzt.

Neu in Version 7.3 (2019-04-15):
Die teilweise vom Format hh:mm:ss abweichenden Angaben der Filmlänge bei Nutzung der Optionen -L und -K wurden korrigiert.

Neu in Version 7.2 (2018-11-08):
• Die Umstellung des Video-Downloads von cURL auf Wget (in Version 7.1) war fehlerhaft und wurde korrigiert.
• Nachdem sich gezeigt hatte, dass die in Version 7.0 eingeführten Optionen -K und -L nur mit der awk-Implementierung gawk funktionierten, klappt die Filterung nach Filmlänge jetzt auch unter Linux-Systemen, die mawk nutzen.
• Der vollständige Such- und Kommandoverlauf einer MediaTerm-Sitzung kann nun in der internen Eingabezeile mit den Pfeiltasten durchgeblättert werden. Hierzu wird im Verzeichnis $HOME/MediaTerm ggf. eine History-Datei angelegt, die bei Beenden des Skripts automatisch wieder gelöscht wird.

Neu in Version 7.1 (2018-10-01):
Diese Version bringt nur kleinere Änderungen, die für die praktische Nutzung keine nennenswerten Auswirkungen haben dürften.
• Sämtliche Download-Vorgänge wurden (wieder) von cURL auf Wget umgestellt.
• Die Aufbereitung der entpackten Filmliste wurde gestrafft, sodass das Skript keine Interimsdateien mehr anlegen und löschen muss.
• Geringfügige Änderungen der Hilfetexte, insbesondere enthält der less-Prompt jetzt einen Hinweis, dass die Hilfe mit Taste q beendet werden kann.

Neu in Version 7.0 (2018-09-03):
• Die beiden neuen Optionen -K (kürzer/gleich) und -L (länger/gleich) erlauben eine Filterung nach der Filmlänge.
• Aus Gründen der besseren Merkbarkeit wurden die beiden Optionen für die Eingrenzung des Zeitraums von bisher -d und -e zu -A ("ab") und -B ("bis") umbenannt.
• Per Option -p können, falls gewünscht, die Videos mit einem anderen als dem voreingestellten Medienplayer mpv abgespielt werden. (Soll dauerhaft ein alternativer Player verwendet werden, empfiehlt es sich, den Aufruf von MediaTerm mit der neuen Option als Alias einzurichten.)
• Mehrere in Anführungszeichen eingeschlossene Suchbegriffe werden jetzt auch aus MediaTerms interner Eingabezeile korrekt als Phrase (exakte Wortfolge) gesucht – bisher hatte dies nur bei der Suche aus der Terminal-Kommandozeile funktioniert.
• Die Versionsanzeige (Option -v) gibt nun u.a. auch Auskunft über die Anzahl der Filme in der aktuell genutzten Filmliste.

Neu in Version 6.5 (2018-03-18):Bei der Aufbereitung der Filmliste wurden in Einzelfällen falsche Zeilenumbrüche gesetzt, was in der Trefferanzeige zu auseinandergerissenen oder inkorrekt formatierten Film-Datensätzen führte. Dieser durch einen unvollständigen Trenner verursachte Fehler wurde behoben.
Bisher konnten Livestreams standardmäßig nur in der besten Qualität abgespielt werden. Jetzt lässt sich bei Bedarf ein Livestream per vorangestelltem m (m<Filmnr.>) auch in geringerer Auflösung abspielen (genauer: in der größten Auflösung kleiner/gleich 1024 px, je nach Verfügbarkeit). Diese Option hat nur eine Auswirkung für Streams, deren höchste verfügbare Auflösung größer als 1024 px ist.
Version 6.5.1 (2018-05-02): Fehler in der Extraktion der URLs für Livestreams in geringerer Auflösung behoben.

Neu in Version 6.4 (2018-01-19): Da unter manchen Linux-Installationen die auf "grep" fußende Suche extrem langsam sein konnte (wegen der grep-Option "--ignore-case"), wurde die Suchfunktion nun auf "sed" umgestellt. Außerdem neu: Die Nutzerin/Der Nutzer erhält im Bookmark-Modus bei der Eingabe von Befehlen mit nicht existierenden Bookmark-Nummern konsequent einen entsprechenden Hinweis. Beim Update der MediathekView-Filmliste werden nur die Verteiler 1, 3, 5 und 6 berücksichtigt, da es – zumindest mit dem im Skript verwendeten Download-Befehl – mit den Verteilern 2 und 4 permanent scheiterte. -- Version 6.4.1 (2018-01-22): Typo korrigiert, der das Abspielen in höherer/niedrigerer Auflösung verhinderte.

Neu in Version 6.3 (2017-08-12): Nun werden auch Filme mit M3U8-URLs als MP4-Videos heruntergeladen. Als neue Abhängigkeit muss hierfür entweder ffmpeg oder libav-tools installiert sein. Außerdem wurden unschöne Fehlfunktionen/Falschausgaben behoben, die bei den Kommandos w1, d1, i1 etc. nach Start von MediaTerm ohne Suchanfrage auftraten. -- Version 6.3.1 (2017-08-22): Beim Filmdownload werden ggf. Schrägstriche (/) im aus dem Filmtitel generierten Dateinamen durch Bindestriche (-) ersetzt, da sonst ein nicht existierendes Downloadverzeichnis suggeriert wird und der Download fehlschlägt. -- Version 6.3.2 (2017-08-25): Formatierung des Hilfetextes zwecks besserer Lesbarkeit wiederhergestellt.

Neu in Version 6.2 (2017-08-09): Bei jedem Filmdownload kann der Benutzer nun Speicherort und Dateinamen frei wählen – oder stattdessen die vorgeschlagene Speicherung im aktuellen Arbeitsverzeichnis ($PWD) unter dem Filmtitel (+ Dateiendung) akzeptieren. -- Wer sich ungerne durch lange, unübersichtliche Trefferlisten scrollt hat jetzt die Alternative, sich wahlweise nur 5 oder 10 Treffer auf einmal anzeigen zu lassen (Kommandos "a" bzw. "A") und in den Suchergebnissen zu "blättern" (Kommandos "+" und "-"). -- Die Option "-v" zeigt nun zusätzlich zur MediaTerm-Version auch Erstellungsdatum und -uhrzeit der genutzten Filmliste an (dies funktioniert erst nach einer ersten Aktualisierung der Filmliste per Option "-u").

Neu in Version 6.1 (2017-07-12): Bei der Bestätigung einer Filmauswahl auf der internen Kommandozeile werden neben dem Titel jetzt auch Sender und Thema angezeigt. Wird eine Suche mit der Option "-o" (Farbdarstellung deaktiviert) oder "-w" (worterhaltende Zeilenumbrüche deaktiviert) ausgeführt, so bleibt diese auch für nachfolgende Suchen aus der internen Kommandozeile wirksam. Fehlermeldung, falls bei Option "-n" kein Suchstring eingegeben wurde. Existiert das Ziel eines Bookmarklinks nicht mehr, so zeigt Kommando "a<Bookmarknr.>" eine entsprechende Meldung an, statt MediaTerm zu beenden.

Neu in Version 6.0 (2017-06-01): Vollständige mawk-Kompatibilität; eine Installation von gawk ist nicht mehr erforderlich. Aufwertung der internen Kommandozeile, aus der nun auch Recherchen ausgeführt werden können. Filmlisten-Feld "Thema" wird jetzt von der Suche ausgewertet und in den Einträgen der Trefferliste angezeigt. Begrenzung der Recherche auf einen gewünschten Zeitraum (Optionen "-d" und "-e"). Ausgabe der Trefferliste sortiert nach Sendedatum (Optionen "-s" und "-t"; die Option zur Unterscheidung zw. Groß- und Kleinschreibung wurde von bisher "-s" auf "-g" gelegt). Gezielter Ausschluss von Suchbegriffen mit der Tilde (~) als neuem Operator. Download von Filmen auch in niedriger und hoher Qualität. Linkübersicht zur Sendung: Das Kommando "i<Nr.>" listet alle zur Treffernr. gehörigen Links auf, d.h. die URLs der verfügbaren Video-Qualitäten und der Internetseite zur Sendung. Direkter Wechsel zwischen den Modi "Suche/Treffer" und "Bookmarks". Kommando zum Löschen von Bookmarks. Neues Kommandokürzel "z", um die letzte Ergebnisliste bzw. die Bookmarks neu zu laden (hilfreich, wenn nach mehreren Filmaufrufen die Treffer bzw. die Bookmarks im Terminal nach oben gerutscht sind). – Außerdem zahlreiche kleinere Verbesserungen und Korrekturen.

Neu in Version 5.5 (2017-05-07): Leider zeigte sich schnell, dass MediaTerm mit der awk-Implementierung mawk an mehr Stellen, als zunächst vermutet, zu Fehlern führt. Deshalb wurde awk explizit durch gawk ersetzt!

Neu in Version 5.4 (2017-05-06): War awk nur in der Implementierung mawk (statt gawk) installiert, funktionierte die Filmauswahl auf der internen Kommandozeile nicht. Dieser Bug konnte (hoffentlich) behoben werden, indem der fragliche awk-Befehl durch einen Befehl ersetzt wurde, der mit reinen Bash-Mitteln auskommt.

Neu in Version 5.3 (2017-05-05): Für die interne Kommandozeile der Bookmarks (Option "-b") gibt es mit dem neuen Kommando "c" jetzt einen Linkchecker, um die Gültigkeit aller (also gerade auch älterer) Bookmark-Links zu prüfen. Da diese Funktion mit curl umgesetzt wurde, wurden auch alle anderen Download-Funktionen des Skripts von wget auf curl umgestellt, um die Abhängigkeiten möglichst gering zu halten. Version 5.3.1 (2017-05-06): Wegen eventueller Unverträglichkeit mit individuellen Konfigurationen (?) readline-Funktionalität aus read-Befehl für die interne Kommandozeile entfernt und die eingelesene Variable "$lfdnr" konsequent in den if-Bedingungen gequotet. Außerdem das Ausbleiben der Fehlermeldung bei Eingabe ungültiger Kommandos behoben.

Neu in Version 5.2 (2017-04-29): Eine exakte Wortsuche wurde eingerichtet: Ein dem Suchstring vorangstelltes Pluszeichen ("+") beschränkt die Suche auf das Einzelwort; Teilwörter bleiben unberücksichtigt. So findet +mut "Mut" bzw. "mut", nicht jedoch "Mutlangen", "Armut" oder "schmutzig". Außerdem gibt es ein neues Kommando ("w"), um zu Filmen die zugehörige Webseite im Standardbrowser zu öffnen. – Vier Versionen in vier Tagen: Jetzt funktioniert das Skript erst einmal zu meiner Zufriedenheit, und ich will mich wieder analogen Interessen zuwenden ... :-)

Neu in Version 5.1 (2017-04-27): Hinter den Filmtiteln in der Trefferliste findet sich jetzt jeweils eine Kennzeichnung zur eventuellen zusätzlichen Verfügbarkeit in niedriger (n) oder hoher (h) Auflösung. Version 5.1.1 (2017-04-28): In Zeile 127 war mein persönlicher Home-Pfad hineingerutscht -> korrigiert!

Neu in Version 5.0 (2017-04-26): Die Kommandounterstützung zum direkten Abspielen und Herunterladen der Filme wird jetzt nach jeder Recherche automatisch angeboten; die bisherige Option "-p" entfällt. Die interne Kommandozeile lässt sich bei Bedarf jedoch mit der Option "-n" ausblenden. Hinzugekommen sind Kommandos, um die Filme in einer – sofern verfügbar – niedrigeren oder höheren Auflösung abzuspielen. Die Trefferliste führt jetzt zu jedem Film auch den Sender auf (der sich in früheren Versionen nur aus der URL des Streams erschließen ließ). Die Nutzung von youtube-dl durch mpv wurde (außer für Livestreams) deaktiviert, was die Ladezeit der Videos verkürzt. Die Darstellung der Trefferliste ist nun lesbarer, da Zeilenumbrüche nicht mehr innerhalb von Wörtern erfolgen. ACHTUNG: Nach dem "Upgrade" auf diese Version muss die MediathekView-Filmliste – wegen einer neuen Formatierung durch das Skript – neu heruntergeladen werden; dies wird beim ersten Start automatisch angeboten.

Neu in Version 4.0 (2017-04-10): Anders als in den Vorgängerversionen greift die Filmsuche jetzt auf eine entpackte und mit eingefügten Zeilenumbrüchen aufbereitete Filmliste zu. Dies beschleunigt die Recherche deutlich.
