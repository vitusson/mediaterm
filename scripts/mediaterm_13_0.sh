#!/bin/bash

# Mit dem Bash-Skript MediaTerm lassen sich Filme aus den Mediatheken
# der öffentlich-rechtlichen Fernsehsender ressourcenschonend im
# Linux-Terminal suchen, abspielen, herunterladen und als Bookmarks
# speichern. MediaTerm greift dabei auf die Filmliste des Programms
# MediathekView (https://mediathekview.de/) zurück.

# https://mediaterm.martikel.bplaced.net

#################################################################
#
#  Copyright (c) 2017-2023 Martin O'Connor (maroc@mailbox.org)
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see http://www.gnu.org/licenses/.
#
################################################################

#### Vorbelegte Variablen

dir=$HOME/MediaTerm   #Verzeichnis, in dem Filmliste und Bookmarks gespeichert werden
MT_PLAYER="${MT_PLAYER:-mpv --really-quiet}"   #Player mpv mit Optionen
MT_PLAYER_ex="$MT_PLAYER"
MT_DLDIR="${MT_DLDIR:-$(pwd)}"   #Zielverzeichnis für den Download von Videos

datum1=01.01.0000   #fiktive untere Zeitgrenze bei Nichtnutzung der Option -A
datum2=31.12.9999   #fiktive obere Zeitgrenze bei Nichtnutzung der Option -B
longer=0   #fiktive untere Grenze für Filmdauer bei Nichtnutzung der Option -L
shorter=86399   #fiktive obere Grenze für Filmdauer bei Nichtnutzung der Option -K

#### Bei Beenden oder irregulärem Abbruch des Skripts wird die History-Datei gelöscht
trap "rm -f $dir/mt_history" EXIT

#### OPTIONEN
while getopts "A:B:bghHkK:lL:noqQstuvw" opt; do
    case $opt in
        b)  bopt=1
            ;;
        A)  Aopt=1
            datum1=$(echo "$OPTARG" | awk -F "." 'NF==3{print $3"."$2"."$1}; NF==2{print $2"."$1.".01"}; NF==1{print $1".01.01"}')   #Datum wird invertiert: tt.mm.jjjj -> jjjj.mm.tt
            ;;
        B)  Bopt=1
            datum2=$(echo "$OPTARG" | awk -F "." 'NF==3{print $3"."$2"."$1}; NF==2{print $2"."$1".31"}; NF==1{print $1"12.31"}')   #Datum wird invertiert: tt.mm.jjjj -> jjjj.mm.tt
            ;;
        g)  gopt=1
            ;;
        h)  hopt=1
            ;;
        k)  kopt=1
            ;;
        K)  Kopt=1
            shorter="$(($OPTARG*60))" #Umrechnung der Minuten in Sekunden
            ;;
        L)  Lopt=1
            longer="$(($OPTARG*60))" #Umrechnung der Minuten in Sekunden
            ;;
        l)  lopt=1
            ;;
        n)  nopt=1
            ;;
        o)  oopt=1
            ;;
        q)  qopt=1
            ;;
        Q)  Qopt=1
            ;;
        s)  sopt=1
            ;;
        t)  topt=1
            ;;
        u)  uopt=1
            ;;
        v)  if [ ! -f $dir/filmliste ]; then
                flstand="[Datei \"filmliste\" nicht gefunden]"
            else
                flstand=$(head -n +1 $dir/filmliste | cut -d"\"" -f6 | tr -d '\n'; echo " ($(($(cat $dir/filmliste | wc -l) - 1)) Filme)")
            fi
            echo "MediaTerm 13.0, 2023-05-08"
            echo "Filmliste vom $flstand"
            exit
            ;;
        w)  wopt=1
            ;;
        H)  Hopt=1   #undokumentierte interne Option, um Ausführung von Suchen auf der internen Kommandozeile zu markieren
            ;;
        \?) echo "mediaterm -h gibt weitere Informationen."
            exit 1
            ;;
    esac
done

#Variable für Anzeige der Suchanfrage in der History und unterhalb der Trefferliste
if [ ! -z $Hopt ]; then
    suchanfrage=$(for i in "${@:2}"; do echo -n " $i"; done)   #"versteckte" Option -H soll nicht angezeigt werden
else
    suchanfrage=$(for i in "${@}"; do phrase=$(echo "$i" | grep ' '); if [ ! -z "$phrase" ]; then echo -n " \"$i\""; else echo -n " $i"; fi; done)
fi
suchanfrage=$(echo "$suchanfrage" | sed "s/^[ \t]*//")

# Einfügen der Suchanfrage in den Such- und Kommandoverlauf
history -r $dir/mt_history
[ -z $Hopt ] && history -s -- "$suchanfrage"

shift $(($OPTIND -1))

#---------------------------------------------------------------
# Hilfe
#---------------------------------------------------------------
fett=$(tput bold)
normal=$(tput sgr0)
unterstr=$(tput smul)

if [ ! -z $hopt ]; then

# Zeige den folgenden Textblock an

    fmt -s -w $(tput cols) << ende-hilfetext | less -ir -Ps"Zum Beenden der Hilfe Taste q drücken"

Mit MediaTerm können im Terminal Filme aus den Mediatheken der öffentlich-rechtlichen Fernsehsender gesucht, mit dem Mediaplayer mpv abgespielt sowie heruntergeladen werden.

${fett}VORAUSSETZUNGEN FUER DAS FUNKTIONIEREN DES SKRIPTS:${normal}
      ffmpeg, mpv, wget und xz bzw. xz-utils müssen installiert sein. Empfohlen wird außerdem eine aktuelle Version von yt-dlp.

${fett}AUFRUF:${normal}
      mediaterm [-a|-A DATUM|-B DATUM|-g|-k|-K MINUTEN|-L MINUTEN|-n|-o|-q|-Q|-s|-t|-w] [+]Suchstring1 [[+|~]Suchstring2 ...]
      mediaterm -l[n|o|w]
      mediaterm -b
      mediaterm -u
      mediaterm -v
      mediaterm -h

${fett}INTERNE EINGABEZEILE:${normal}
      "mediaterm" ohne Optionen oder Argumente ausgeführt - aber auch jede erfolgreiche Suche aus dem Terminal - öffnet die interne Eingabezeile von MediaTerm. Auf ihr werden Suchanfragen nach obigem Muster OHNE einleitende Angabe des Befehls "mediaterm" ausgeführt. Das Abspielen, Anzeigen und Herunterladen der gefundenen Filme wird mit vorgegebenen Kommandos gesteuert. Eine Übersicht aller Kommando-Kürzel lässt sich per Eingabe von "k" in der internen Eingabe anzeigen.

${fett}ALLGEMEINE OPTIONEN:${normal}
      ${fett}-b${normal}   Anzeige, Abspielen und Löschen der Bookmarks.
      ${fett}-h${normal}   Zeigt diese Hilfe an.
      ${fett}-k${normal}   Gibt die Ergebnisliste in kompakter Form ohne Filmbeschreibungen und Film-URLs aus.
      ${fett}-n${normal}   Gibt die Ergebnisliste ohne interne Kommandozeile aus.
      ${fett}-o${normal}   Gibt die Ergebnisliste ohne Farben aus.
      ${fett}-u${normal}   Aktualisiert die Filmliste.
      ${fett}-v${normal}   Zeigt die MediaTerm-Version, das Erstellungsdatum der Filmliste und die Anzahl der Filme.
      ${fett}-w${normal}   Deaktiviert die worterhaltenden Zeilenumbrüche in der Ergebnisliste.

${fett}SUCHOPTIONEN (auch auf der internen Eingabezeile nutzbar):${normal}
   Mit Ausnahme der Option -l muss auf die folgenden Optionen mindestens ein Suchstring folgen.
      ${fett}-A DATUM${normal}   Sucht nur Sendungen neuer als DATUM (und vom DATUM); DATUM muss im Format [[TT.]MM.]JJJJ eingegeben werden.
      ${fett}-B DATUM${normal}   Sucht nur Sendungen älter als DATUM (und vom DATUM); DATUM muss im Format [[TT.]MM.]JJJJ eingegeben werden.
      ${fett}-g${normal}   Unterscheidet bei der Suche zwischen Groß- und Kleinbuchstaben.
      ${fett}-K MINUTEN${normal}   Sucht nur Filme, deren Dauer kürzer/gleich MINUTEN (ganze Zahl) ist.
      ${fett}-L MINUTEN${normal}   Sucht nur Filme, deren Dauer länger/gleich MINUTEN (ganze Zahl) ist.
      ${fett}-l${normal}   Listet alle Livestreams auf.
      ${fett}-q${normal}   Gibt in der Ergebnisliste die URLs für die jeweils niedrigste verfügbare Filmqualität aus (statt durchgehend die mittlere Standardqualität).
      ${fett}-Q${normal}   Gibt in der Ergebnisliste die URLs für die jeweils höchste verfügbare Filmqualität aus (statt durchgehend die mittlere Standardqualität).
      ${fett}-s${normal}   Sortiert Suchtreffer absteigend nach Sendedatum (neueste zuoberst).
      ${fett}-t${normal}   Sortiert Suchtreffer aufsteigend nach Sendedatum (neueste zuunterst).

${fett}SUCH-OPERATOREN:${normal}
       ${fett}+${normal}   Ein "+" unmittelbar vor einem Suchstring bewirkt, dass dieser als Einzelwort gesucht wird und NICHT als Zeichenfolge auch innerhalb von Wörtern.
       ${fett}~${normal}   Eine Tilde (~) unmittelbar vor einem Suchstring schließt diesen für die Suche gezielt aus. Dieser Operator kann nicht mit dem ersten Suchstring verwendet werden.
       ${fett}" "${normal} Zwei oder mehr in Anführungszeichen gesetzte Wörter (z.B. "Thomas Mann") werden als exakte Wortfolge (Phrase) gesucht, d.h. die Wörter müssen in dieser Reihenfolge direkt aufeinander folgen.

${fett}ANWENDUNGSBEISPIELE:${normal}
   ${unterstr}mediaterm alpen klimawandel${normal}
      ... listet alle Filme auf, in deren Titel, Thema oder Beschreibung die Zeichenfolgen "alpen" und "klimawandel" vorkommen (unabhängig von Groß-/Kleinschreibung). Die gefundenen Filme können per Eingabe der jeweiligen Treffernummer gestreamt, heruntergeladen oder als Bookmark gespeichert werden.

   ${unterstr}mediaterm -now alpen klimawandel${normal}
      ... liefert die gleiche Trefferliste in roher Form, d.h. ohne Kommandoeingabe (-n), ohne Farbe (-o) und ohne worterhaltende Zeilenumbrüche (-w). Dies ist beispielsweise sinnvoll, wenn die Liste weiterverarbeitet oder in eine Datei umgeleitet werden soll.

   ${unterstr}mediaterm +gier${normal}
      ... sucht nur nach Treffern, in denen "gier" bzw. "Gier" als ganzes Wort vorkommt; beispielsweise bleiben "gierig", "Magier" oder "Passagiere" unberücksichtigt.

   ${unterstr}mediaterm -A 15.05.2015 -B 2016 alpen klimawandel${normal}
      ... beschränkt die Suche auf Sendungen aus dem Zeitraum 15.05.2015-31.12.2016.

   ${unterstr}mediaterm -L 45 -K 120 alpen klimawandel${normal}
      ... beschränkt die Suche auf Filme, die länger oder gleich 45 Minuten sowie kürzer oder gleich 2 Stunden dauern.

   ${unterstr}mediaterm python ~monty${normal}
      ... vermindert die Ergebnismenge der Suche nach "python" um alle Treffer, in denen die Zeichenfolge "monty" vorkommt.

${fett}ANPASSUNG:${normal}
   Mit der Variablen ${fett}MT_PLAYER${normal} lässt sich ein alternativer Medienplayer (Standard = mpv) wählen, z.B.
      export MT_PLAYER="vlc --play-and-exit"

   Mit der Variablen ${fett}MT_DLDIR${normal} lässt sich der Zielordner für Filmdownloads (Standard = aktuelles Arbeitsverz. \$(pwd)) ändern, z.B.
      export MT_DLDIR="\$HOME/Videos"

   Als dauerhafte Einstellung können die export-Befehle in die versteckte Datei ~/.bashrc eingefügt werden.

ende-hilfetext

# Falls Hilfe aus Kommandozeile/Terminal aufgerufen, "exit"
    [ -z $Hopt ] && exit
fi

#---------------------------------------------------------------

#### FUNKTIONEN hits, icli, bmcomm, bmcli, urlqual, dots

### Definition der FUNKTION hits: Formatierung und Ausgabe der Suchergebnisse
function hits {
# Meldung bei leerer Treffermenge
if [ ! "$out"  ]; then
    if [ ! -z $oopt ]; then
        printf "\033[1mZu der Suche wurden keine Filme gefunden.\033[0m\n"
    else
        printf "\033[0;31mZu der Suche wurden keine Filme gefunden.\033[0m\n"
    fi
    #Bei leerer Treffermenge Anwendung nur beenden, wenn Suchanfrage auf der Kommandozeile (Terminal) ausgeführt wurde
    [[ -z $Hopt && "$suchanfrage" != " Bookmark $input" ]] && exit
# Ausgabe der Ergebnisliste bei nichtleerer Treffermenge
else
    # Kompakte Ausgabe der Ergebnisliste Livestreams
    if [ ! -z $lopt ]; then
        echo "$out" | \
        awk -F "\",\"" '{print "("NR") " "\033[0;32m"$4"\033[0m"" ("$1")  [n/h]"}; {print "\033[0;34m"$10"\033[0m","\n"}' | \
        ( if [ ! -z $a ]; then awk -v x1=$x1 -v x2=$x2 'NR==x1,NR==x2'; else tee; fi) | #10 Treffer ab Nr. in Variable x1 \
        ( if [ ! -z $oopt ]; then sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"; else tee; fi ) |   #Entfernt Farbformatierungen bei Option -o \
        tr -d '\\' |   #Entfernt Escape-Backslashes aus Ausgabe \
        ( if [ -z $wopt ]; then fmt -s -w $(tput cols); else tee; fi )   #Worterhaltende Zeilenumbrüche (außer bei Option -w)

    # Ausgabe der übrigen Ergebnislisten
    elif [ ! -z "$out" ]; then
        if [[ ! -z $kopt || ( -z $qopt && -z $Qopt) ]]; then
            echo "$out" | \
            ( if [ ! -z $kopt ]; then awk -F "\",\"" '{ORS=" "}; {print "("NR")", "\033[0;32m"$4"\033[0m"" ("$1": "$3")"}; {if($14!=""){printf "[n"} else{printf "[-"}}; {if($16!=""){print "/h]"} else{print "/-]"}}; {print "\n"  "\33[1m""Datum:""\033[0m",$5  ",",  $6,"Uhr","*",  "\33[1m""Dauer:""\033[0m",  $7,"\n"} {printf "\n"}';  #Kompaktanzeige bei Option -k \
            else awk -F "\",\"" '{ORS=" "}; {print "("NR")", "\033[0;32m"$4"\033[0m"" ("$1": "$3")"}; {if($14!=""){printf "[n"} else{printf "[-"}}; {if($16!=""){print "/h]"} else{print "/-]"}}; {print "\n"  "\33[1m""Datum:""\033[0m",$5  ",",  $6,"Uhr","*",  "\33[1m""Dauer:""\033[0m",  $7,"\n" $9,  "\n" "\033[0;34m"$10"\033[0m"} {printf "\n\n"}'; fi ) |  #Detailanzeige ohne Option -k \
            ( if [ ! -z $a ]; then awk -v x1=$x1 -v x2=$x2 'NR==x1,NR==x2'; else tee; fi) | #nur 5/10 Treffer ab Nr. in Variable x1 \
            ( if [ ! -z $oopt ]; then sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"; else tee; fi ) |   #Entfernt Farbformatierungen bei Option -o \
            tr -d '\\' |   #Entfernt Escape-Backslashes aus Ausgabe \
            ( if [ -z $wopt ]; then fmt -s -w $(tput cols); else tee; fi )   #Worterhaltende Zeilenumbrüche (außer bei Option -w)

        # Ausgabe der URLs für die niedrigste/höchste Filmqualität bei Option -q bzw. -Q
        else
            let i=1
            j=$(echo "$out" | wc -l)
            [ ! -z $a ] && i=$a && j=$a2  #ausgewertete Zeilen bei Blätter-Funktion
            auf=16
            [ -z $qopt ] || auf=14
            echo "$out" | awk -v mn=$i -v mx=$j 'NR==mn,NR==mx' | while read -r line; do
                echo "$line" | awk -F "\",\"" -v i=$i -v q=$auf -v urllength="$(echo "$line" | awk -F "\",\"" -v q=$auf '{print $q}' | cut -d\| -f1)" -v suffix="$(echo "$line" | awk -F "\",\"" -v q=$auf '{print $q}' | cut -d\| -f2)" '{ORS=" "}{print "("i")", "\033[0;32m"$4"\033[0m"" ("$1": "$3")"}; {if($14!=""){printf "[n"} else{printf "[-"}}; {if($16!=""){print "/h]"} else{print "/-]"}}; {print "\n" "\33[1m""Datum:""\033[0m",$5  ",",  $6,"Uhr","*",  "\33[1m""Dauer:""\033[0m",  $7,"\n" $9} {printf "\n"} {if($q!=""){print "\033[0;34m"substr($10,1,urllength)suffix"\033[0m"} else {print "\033[0;34m"$10"\033[0m"} printf "\n\n"}' | \
                ( if [ ! -z $oopt ]; then sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"; else tee; fi ) |   #Entfernt Farbformatierungen bei Option -o \
                tr -d '\\' |   #Entfernt Escape-Backslashes aus Ausgabe \
                ( if [[ -z $wopt ]]; then fmt -s -w $(tput cols); else tee; fi )   #Worterhaltende Zeilenumbrüche (außer bei Option -w)
                (( i++ ))
            done
        fi
    fi
fi

# Anzeige der Suchanfrage unter der Trefferliste (außer bei Option -n)
if [ -z $nopt ]; then
    if [ -z $a ]; then
       echo "[Suchanfrage: $suchanfrage]"
    else
       echo "[Suchanfrage: $suchanfrage] (Treffer: $trefferzahl, Blättern mit +/-)"
    fi
fi

# Bei Option -n nach Ausgabe der Trefferliste exit
[ -z $nopt ] || exit 0

icli
}

### Definition der FUNKTION icli: Interne Kommandozeile
function icli {
trefferzahl=$(echo "$out" | wc -l)   #Anzahl der Treffer (= Zeilen von $out)
[ -z "$out" ] && trefferzahl=0

# Zeilen pro Treffer für Blätterfunktion
let tz=5
[[ ! -z $lopt || ! -z $kopt ]] && let tz=3

printf '%.0s-' $(seq $(tput cols)); printf '\n'   #gestrichelte Trennlinie
if [ ! "$out" ]; then
    printf "\033[1mNach Fernsehsendungen suchen ...\033[0m\n\033[1mH\033[0m zeigt die Hilfe zur Suche; \033[1mq\033[0m beendet mediaterm; \033[1mk\033[0m listet zusätzliche Kommando-Optionen auf.\n"
else
    printf "\033[1mZum Abspielen Nummer des gewünschten Films eingeben (... oder neue Suche starten)\033[0m \n\033[1mq\033[0m beendet mediaterm. \033[1mk\033[0m zeigt zusätzliche Kommando-Optionen.\n" | ( if [ -z $wopt ]; then fmt -s -w $(tput cols); else tee; fi )
fi

while true; do

    noq=0
    # Benutzereingabe der Treffernummer bzw. eines Kommandos
    read -er -p "> " input

    # Einfügen der Benutzereingabe in den Such- und Kommandoverlauf
    history -s -- "$input"

    # Auflistung zusätzlicher Kommando-Optionen bei Kommando k
    if [ "$input" = k ]; then
        printf " \033[1mh\033[0m voranstellen, um Film in hoher Qualität abzuspielen (z.B. h6),\n \033[1mn\033[0m voranstellen, um Film in niedriger Qualität abzuspielen (z.B. n9)\n  (zur Verfügbarkeit niedriger/hoher Qualität siehe Kennzeichnung [n/h] hinter Filmtitel),\n \033[1mb\033[0m voranstellen, um Bookmark zu speichern (z.B. b4),\n \033[1md\033[0m voranstellen, um Film in Standardqualität zu speichern (z.B. d17),\n \033[1mdh\033[0m voranstellen, um Film in hoher Qualität zu speichern (z.B. dh1),\n \033[1mdn\033[0m voranstellen, um Film in niedriger Qualität zu speichern (z.B. dn2),\n \033[1mw\033[0m voranstellen, um Internetseite zur Sendung im Browser zu öffnen (z.B. w35),\n \033[1mi\033[0m voranstellen, um alle zum Film gehörenden Links anzuzeigen (z.B. i2),\n \033[1mf\033[0m voranstellen, um Filmbeschreibung anzuzeigen (z.B. f12),\n \033[1ma\033[0m voranstellen, um nur 5 Treffer (bzw. 10 Treffer bei Option -l oder -k) ab Filmnr. anzuzeigen (z.B. a12)\n   (\033[1ma\033[0m ohne Nummer entspricht a1),\n \033[1m   +\033[0m (oder \033[1mv\033[0m) blättert vorwärts (in Teilansicht mit 5 bzw. 10 Treffern),\n \033[1m   -\033[0m (oder \033[1mr\033[0m) blättert rückwärts (in Teilansicht mit 5 bzw. 10 Treffern),\n \033[1my\033[0m voranstellen, um aus ALLEN vom Sender angebotenen Qualitäten auszuwählen (Abspielen) (z.B. y8),\n \033[1mdy\033[0m voranstellen, um aus ALLEN vom Sender angebotenen Qualitäten auszuwählen (Speichern) (z.B. dy8),\n \033[1mz\033[0m liest die Trefferliste neu ein,\n \033[1mB\033[0m wechselt in den Modus \"Bookmarks\" (Ansicht, Abspielen, Löschen),\n \033[1mH\033[0m zeigt die Hilfe zur Filmsuche.\n"

    elif [[ $input =~ ^(q|quit|exit)$ ]]; then
        exit   #Beenden des Programms bei Eingabe von "q", "quit" oder "exit"

    elif [ "$input" = B ]; then
        if [ ! -f $dir/bookmarks ]; then
            echo "Die Datei $dir/bookmarks existiert nicht."
        else
            bmcli   #Wechsel zur Kommandozeile Bookmarks
        fi

    elif [ "$input" = H ]; then
        exec "$0" -h | less -ir -pSUCHOPTIONEN -Ps"Zum Beenden der Hilfe Taste q drücken"

    #Anzeige von 5 bzw. 10 Treffern ab Zeile
    elif [[ $input =~ ^a[0-9]*$ ]]; then
        a=${input:1}
        clear && printf '\e[3J'
        if [[ -z $lopt && -z $kopt ]]; then
            im=5
        else
            im=10
        fi
        a=$(( a < trefferzahl ? a : trefferzahl-im+1 ))
        a=$(( a > 0 ? a : 1 ))
        let x1=(a-1)*tz+1
        let x2=(im*tz)+x1-1
        let a2=a+im-1
        pl=im
        hits

    elif [[ "$input" = v || "$input" = "+" || "$input" = r || "$input" = "-" ]]; then   #Blättern in Treffern
        if [ "$a" = "" ]; then
            echo "Blättern ist in der Gesamtansicht der Trefferliste nicht möglich. Bitte zuerst mit Kommando a oder A zu einem Eintrag springen." | ( if [ -z $wopt ]; then fmt -s -w $(tput cols); else tee; fi )
        else
            clear && printf '\e[3J'
            case $input in
                v|\+) let a=$(( a+pl <= trefferzahl ? a+pl : a )) ;;
                r|\-) let a=$(( a-pl > 0 ? a-pl : 1 )) ;;
            esac
            let x1=(a-1)*tz+1
            let x2=x1+pl*tz-1
            let a2=a+pl-1
            hits
        fi

    elif [ "$input" = z ]; then
        a=""
        if [ ! -z "$out" ]; then
            hits
        else
            echo "Es liegt keine Suchanfrage vor."
        fi

    elif [[ $input =~ ^(d[hny]?|[bfhinwy])?[0-9]+$ ]]; then

        filmnr=${input//[!0-9]/} # Variable $filmnr = Kommando ohne führenden Buchstaben
        if [[ $filmnr -gt $trefferzahl || $filmnr -eq 0 ]]; then
            echo "Kein Film mit dieser Nummer!"
        else
            # Bestätigung des ausgewählten Films
            if [[ ! "$input" = f* ]]; then
                echo "$out" | awk -F "\",\"" 'NR=='$filmnr'{print "Ausgewählt:", $4, "("$1":",$3")"}' | tr -d '\\'
            else
                printf '%s'"\033[1m$(echo "$out" | awk -F "\",\"" 'NR=='$filmnr'{print $4, "("$1":",$3")"}' | tr -d '\\')\033[0m"
            fi

            #(Standard-)Auflösungen für Livestreams
            bitrate="3000000"

            # ANSI-Escapesequenzen für URL-Farbe blau in Variablen,
            # wenn Option -o nicht gewählt
            [[ -z $oopt ]] && bluein="\\033[0;34m" && blueout="\\033[0m"

            filmurl=$(echo "$out" | \
                awk -F "\",\"" 'NR=='$filmnr'{print $10}')

            # Auswahl/Zusammensetzung der URL bei niedriger/hoher Auflösung
            if [[ $input =~ ^d?[nh][0-9]+$ ]]; then
                case $input in
                    dn*|n*) qual="niedriger" ;;
                    dh*|h*) qual="hoher" ;;
                esac
                if [ ! -z $lopt ]; then
                    case $input in
                        dn*|n*) bitrate="1700000" ;;
                        dh*|h*) bitrate="6000000" ;;
                    esac
                else
                    case $input in
                       dn*|n*) def=14 ;;
                       dh*|h*) def=16 ;;
                    esac
                    urlqual $def
                fi
            fi

            weburl=$(echo "$out" | awk -F "\",\"" 'NR=='$filmnr'{print $11}')

            # Auflistung aller URLs (Kommando "i")
            if [[ "$input" = i* ]]; then
                echo "    [n] = Niedrige Qualität, [s] = Standardqualität, [h] = Hohe Qualität, [w] = Internetseite" |    #Legende der Abkürzungen \
                ( if [ -z $wopt ]; then fmt -s -w $(tput cols); else tee; fi )   #Worterhaltende Zeilenumbrüche (außer bei Option -w)
                urlqual 14
                if [[ "$filmurl" = "" ]]; then
                    echo "[n] nicht verfügbar"
                else
                    echo -e "[n] $bluein$filmurl$blueout"
                fi
                stanurl=$(echo "$out" | awk -F "\",\"" 'NR=='$filmnr'{print $10}')
                echo -e "[s] $bluein$stanurl$blueout"
                urlqual 16
                if [[ "$filmurl" = "" ]]; then
                    echo "[h] nicht verfügbar"
                else
                    echo -e "[h] $bluein$filmurl$blueout"
                fi
                echo -e "[w] $bluein$weburl$blueout"
            fi

            # Anzeige der Filmbeschreibung (Kommando "f")
            if [[ "$input" = f* ]]; then
                echo; echo "$out" | awk -F "\",\"" 'NR=='$filmnr'{print $9}' | \
                tr -d '\\' |   #Entfernt Escape-Backslashes aus Ausgabe \
                ( if [ -z $wopt ]; then fmt -s -w $(tput cols); else tee; fi )   #Worterhaltende Zeilenumbrüche (außer bei Option -w)
            fi

            # Anzeige der Internetseite zur Sendung im Standardbrowser (Kommando "w")
            if [[ "$input" = w* ]]; then
                echo -e "URL: $bluein$weburl$blueout"
                read -p "Soll die Internetseite zu dieser Sendung im Browser geöffnet werden? (J/n)" antwort
                [[ "${antwort,,}" = j || "$antwort" = "" ]] && xdg-open $weburl >/dev/null 2>&1 &
            fi

            # Anzeige aller Videoqualitäten (Kommando "y")
            if [[ $input =~ ^d?y[0-9]+$ ]]; then
                noq=1
                command -v yt-dlp >/dev/null
                if [ $? -eq 0 ]; then
                    echo
                    warn=0
                    tabs -2
                    yt-dlp --no-colors --compat-options youtube-dl -F $weburl 2>/dev/null | awk '/resolution/{print "\t  "$0}'
                    yt-dlp --no-colors --compat-options youtube-dl -F $weburl 2>/dev/null | tail -n +5 | awk 'BEGIN{i=1} !/^\[/ && !/resolution/{print i++")\t"$0}' | grep . || warn=1
                    if [ $warn -eq 0 ]; then
                        read -p "Nummer des gewünschten Formats eingeben – ggf. auch in der Form <Video-Nr.>+<Audio-Nr.> möglich (0 für Abbrechen): " nr
                        if [[ ! "$nr" = 0 ]]; then
                            nr1="$(echo "$nr" | cut -d+ -f1)"
                            nr2="$(echo "$nr" | cut -d+ -f2)"
                            yt="$(yt-dlp --no-colors --compat-options youtube-dl -F $weburl 2>/dev/null | tail -n +5 | awk '!/^\[/ && !/resolution/{print $0}' | awk -v var=$nr1 'NR==var{print $1}')+$(yt-dlp --no-colors --compat-options youtube-dl -F $weburl 2>/dev/null | tail -n +5 | awk '!/^\[/ && !/resolution/{print $0}' | awk -v var=$nr2 'NR==var{print $1}')"
                            noq=0
                            [[ $input =~ ^y[0-9]+$ && "$MT_PLAYER" != mpv* ]] && printf '\n\033[1mDiese Funktion setzt die Nutzung des Players mpv voraus!\033[0m\n' && noq=1
                            [[ "$MT_PLAYER" = mpv* ]] && MT_PLAYER_ex="$MT_PLAYER --player-operation-mode=pseudo-gui --ytdl-format=$yt"
                            filmurl=$weburl
                        else
                            warn=0
                            echo
                            echo "Nächste Nummerneingabe bezieht sich wieder auf Trefferliste der Filmsuche (neu einlesen mit z)"
                        fi
                    else
                        printf '\033[1mFür diesen Film konnten keine Videoqualitäten ermittelt werden.\033[0m\n'
                    fi
                else
                    printf '\033[1mDiese Funktion setzt eine Installation von yt-dlp voraus!\033[0m\n'
                fi
            fi

            # Speichern als Bookmark
            [[ "$input" = b* ]] && echo "$out" | \
                awk -F "\",\"" 'NR=='$filmnr'{print $4,"* "$10}' | tr -d '\\' >> $dir/bookmarks && printf "\033[1mFilm ($filmnr) wurde als Bookmark gespeichert.\033[0m\nWechsel zur Bookmarkübersicht mit Kommando \033[1mB\033[0m.\n"

            # Download des Videos (Kommando "d...")
            if [[ $input =~ ^d[hny]?[0-9]+$ && $noq -eq 0 ]]; then
                if [ "$filmurl" = "" ]; then
                    echo "Film nicht in $qual Auflösung verfügbar."
                else
                    ext="${filmurl##*.}"   #Dateiendung der Film-URL
                    echo -e "\033[1mFalls gewünscht, bitte Speicherort und Dateiname anpassen.\033[0m"
                    if [[ "$ext" = m3u8* ]]; then
                        xx="mp4"
                    else
                        xx=$ext
                    fi
                    [[ $input =~ ^dy[0-9]+$ ]] && xx=$(yt-dlp --no-colors --compat-options youtube-dl -F $weburl 2>/dev/null | awk '!/^\[/ && !/resolution/{print $0}' | awk -v var=$nr 'NR==var{print $2}')
                    read -ep "Speichern unter: " -i "$MT_DLDIR/$(echo "$out" | awk -F "\",\"" -v ext=$xx 'NR=='$filmnr'{print $4"."ext}' | tr -d '\\' | tr ' ' '_' | tr '/' '-' )" downloadziel
                    if [[ $input =~ ^dy[0-9]+$ ]]; then
                        yt-dlp --no-colors --compat-options youtube-dl -o $downloadziel -f "$yt" $filmurl
                    else
                        if [[ "$ext" = m3u8* ]]; then
                            ffmpeg -i $filmurl -c copy -bsf:a aac_adtstoasc "$downloadziel"
                        else
                            wget -nc -O $downloadziel $filmurl
                        fi
                    fi
                    echo -e "\033[1mTrefferliste kann mit Kommando z neu eingelesen werden.\033[0m"
                fi
            fi

            # Abspielen des Videos
            if [[ $input =~ ^[nhy]?[0-9]+$ && $noq -eq 0 ]]; then
                if [ "$filmurl" = "" ]; then
                    echo "Film nicht in $qual Auflösung verfügbar."
                else
                    [ ! -z $lopt ] && [[ ! $input =~ ^y[0-9]+$ ]] && [[ "$MT_PLAYER" = mpv* ]] && MT_PLAYER_ex="$MT_PLAYER --hls-bitrate=$bitrate"
                    $MT_PLAYER_ex "$filmurl" >/dev/null 2>&1
                    [ $? -ne 0 ] && echo "Diese URL konnte vom Player nicht abgespielt werden."
                    [ $yt ] && [[ "$MT_PLAYER" = mpv* ]] && echo && echo "Nächste Nummerneingabe bezieht sich wieder auf Trefferliste der Filmsuche (neu einlesen mit z)"
                    unset yt
                fi
            fi
        fi

    else
        # Ausführen der Suche von der internen Kommandozeile
        [ -z $oopt ] || o="-o"
        [ -z $wopt ] || w="-w"
        history -w $dir/mt_history
        H="-H"
        ninput=$(echo "x@$input" | cut -d@ -f2 | awk -F\" '{OFS="\"";for(i=2;i<NF;i+=2)gsub(/ /,"\\s",$i);print}' | sed 's/"//g')  #Leerzeichen in Phrasen werden durch \\s ersetzt
        exec "$0" $H $o $w $ninput
    fi
done
}

### Defintion der FUNKTION bmcomm: Übersicht der Bookmark-Kommandos anzeigen
function bmcomm {
printf '%.0s-' $(seq $(tput cols)); printf '\n'   #gestrichelte Trennlinie
printf "\033[1mZum Abspielen Nummer des gewünschten Eintrags eingeben.\033[0m\n\033[1mq\033[0m beendet MediaTerm. \033[1mk\033[0m listet zusätzliche Kommando-Optionen auf.\n"
}

### Definition der FUNKTION bmcli: Kommandozeile Bookmarks
function bmcli {
sed -i '/^\s*$/d' $dir/bookmarks   #entfernt eventuelle Leerzeilen aus der BM-Datei
cat -b $dir/bookmarks | awk 'ORS="\n"{$1=$1;print}' | sed G   #Aufbereitete Ausgabe der Bookmarks (mit Zeilennummerierung und Leerzeilen zw. Einträgen)
bmcomm
filmmax=$(cat $dir/bookmarks | wc -l)   #Anzahl der Bookmarks

while [ 1 ]; do
    read -ep ">> " input
    history -s -- "$input"
    if ! [[ $input =~ ^([c,k,q,z,S]|exit|quit|[sl]?[0-9]+)$ ]]; then
    echo "$input ist keine korrekte Eingabe."

    elif [ "$input" = k ]; then
        printf " \033[1ms\033[0m voranstellen (z.B. s5), um Bookmark als Suchergebnis anzuzeigen\n (= detaillierte Anzeige und zusätzliche Abspieloptionen; Trefferliste einer evtl. vorher durchgeführten Suche danach nicht mehr verfügbar),\n \033[1mc\033[0m überprüft Gültigkeit aller Bookmarklinks,\n \033[1ml\033[0m voranstellen (z.B. l3), um Bookmark zu löschen,\n \033[1mz\033[0m liest Bookmarks neu ein,\n \033[1mS\033[0m wechselt in den Modus \"Suche/Treffer\".\n" | ( if [ -z $wopt ]; then fmt -s -w $(tput cols); else tee; fi )

    elif [[ $input =~ ^(q|quit|exit)$ ]]; then
        exit   #Beenden des Programs bei Kommando "q"

    # Linkchecker (Kommando "c")
    elif [ "$input" = c ]; then
        tabs 4
        for i in $(seq 1 $filmmax); do
            echo -e -n "$i\t"; wget -nv --server-response --spider --timeout=6 --tries=1 $(cat -b $dir/bookmarks | awk '{$1=$1;print}' | grep "^${i} " | cut -d "*" -f2) 2>&1 | grep 'HTTP/'
            if [ $? -ne 0 ]; then echo "Download des Headers gescheitert"; fi
        done
        echo
        printf "\033[1mz\033[0m lädt Bookmarks neu.\n"
        bmcomm

    # Löschen eines Bookmarks
    elif [[ "$input" = l* ]]; then
        if [[ ${input:1} -gt $filmmax || ${input:1} -eq 0 ]]; then
            echo "Kein Bookmark mit dieser Nummer!"
        else
            read -p "Soll Bookmark ${input:1} gelöscht werden (J/n)" antwort
            if [[ "${antwort,,}" = j || -z $antwort ]]; then
                sed -i '/^\s*$/d' $dir/bookmarks   #entfernt eventuelle Leerzeilen aus der BM-Datei
                sed -i "${input:1}d" $dir/bookmarks
                echo
                cat -b $dir/bookmarks | awk '{$1=$1;print}' | sed G
                echo -e "\033[1mBookmark wurde gelöscht.\033[0m"
                filmmax=$(cat $dir/bookmarks | wc -l)
                bmcomm
            else
                echo "Es wurde kein Bookmark gelöscht."
            fi
        fi

    # Wechsel in den Modus "Suchen/Treffer" (Kommando "S")
    elif [ "$input" = S ]; then
        [ "$out" ] && hits || icli

    # Anzeigen von Bookmarks und Kommandoübersicht (Kommando "z")
    elif [ "$input" = z ]; then
        bmcli

    # Detaillierte Anzeige und Abspieloptionen
    elif [[ "$input" = s* ]]; then
        if [[ ${input:1} -gt $filmmax || ${input:1} -eq 0 ]]; then
            echo "Kein Bookmark mit dieser Nummer!"
        else
            bmurl=$(cat -b $dir/bookmarks | awk '{$1=$1;print}' | grep "^${input:1} " | cut -d "*" -f2)
            out=$(grep $bmurl $dir/filmliste)
            a=""   #Variable für Blättern zurücksetzen
            suchanfrage="Bookmark ${input:1}"
            echo
            lopt=""
            hits
        fi

    # Abspielen der Bookmarks
    else
        if [[ $input -gt $filmmax || $input -eq 0 ]]; then
            echo "Kein Bookmark mit dieser Nummer!"
        else
            $MT_PLAYER $(cat -b $dir/bookmarks | awk '{$1=$1;print}' | grep "^${input} " | cut -d "*" -f2) >/dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo "Diese URL konnte vom Player nicht abgespielt werden."
            fi
        fi
    fi
done
exit
}

### Definition der FUNKTION urlqual: setzt URLs niedriger und hoher Qualität zusammen
# Parameter bestimmen sich nach Feldnummer von $out (14 niedrige, 16 hohe Qualität)
urlqual () {
filmurl=$(echo "$out" | \
    nl -s "\", \""  |   # Zeilennummerierung \
    awk -v url="$(echo "$out" | awk -F "\",\"" -v fn=$filmnr 'NR==fn{print $10}')" -v urlstammlaenge="$(echo "$out" | awk -F "\",\"" -v var="$1" -v fn=$filmnr 'NR==fn{print $var}' | cut -d"|" -f1)" -v urlsuffix="$(echo "$out" | awk -F "\",\"" -v var="$1" -v fn=$filmnr 'NR==fn{print $var}' | cut -d"|" -f2)" -F "\",\"" -v fn=$filmnr 'NR==fn{print substr(url,1,urlstammlaenge)urlsuffix}')
}

### Definition der FUNKTION dots: Einfache Fortschrittsanzeige
dots () {
        while ps |grep $! &>/dev/null
        do
            echo -n "."
            sleep 0.5
        done
}
# <<<<< ENDE FUNKTIONEN <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#### Aufrufen, Abspielen und Löschen der Bookmarks (Option -b)
if [ ! -z $bopt ]; then
    [ ! -f $dir/bookmarks ] && echo "Die Datei $dir/bookmarks existiert nicht." && exit 1
    bmcli
fi

#### Herunterladen der Filmliste (falls nicht vorhanden oder bei Option -u)
if ! [[ -f $dir/filmliste && -z $uopt ]]; then
    antwort="j"
    if [ ! -f $dir/filmliste ]; then
        read -p "Soll die aktuelle Filmliste heruntergeladen und im Verzeichnis $dir (wird ggf. vom Programm angelegt) gespeichert werden? (J/n)" antwort
        echo
    fi

    # Fall: Lokale Filmliste vorhanden oder Download-Frage bejaht
    if [[ "${antwort,,}" = j || -z $antwort ]]; then
        mkdir -p $dir
        cd $dir

        # Prüfung der lokalen Filmliste auf Aktualität
        if [[ -f $dir/filmliste ]]; then
            listdate=$(awk -F "\",\"" 'NR=='1'{print $2}' $dir/filmliste | cut -d"\"" -f4 | awk -F "," '{ n=split($1,b,".");$1=b[3]"-"b[2]"-"b[1];print }')   #Erstellungsdatum aus lokaler Filmliste
            nlistdate=$(date -d "${listdate}" +%Y%m%d%H30)   #Normierung des Datums (Abrundung zur vollen Stunde + 30 Minuten)
        else
            nlistdate=0
        fi
        if [ $(($nlistdate + 200)) -gt $(TZ=Europe/Berlin date +%Y%m%d%H%M) ]; then
            printf "\033[1mDie gespeicherte Filmliste vom $(head -n +1 $dir/filmliste | cut -d"\"" -f6 | tr -d '\n') Uhr, ist aktuell -- kein Download\033[0m \n"   #kein Download bis zur übernächsten vollen Stunde + 30 Minuten
            exit
        fi

        echo "Die Filmliste wird heruntergeladen"
        wget --prefer-family=IPv4 -N -nv --show-progress --user-agent=MediaTerm https://liste.mediathekview.de/Filmliste-akt.xz   # Herunterladen der komprimierten Filmliste
        # Prüfung des Exitstatus von Wget
        if [ $? -ne 0 ]; then
            echo "Die Filmliste konnte nicht heruntergeladen werden"
        else
            echo "Die heruntergeladene Filmliste wird entpackt und aufbereitet"
            xz -d --stdout Filmliste-akt.xz | awk -v RS=",\"X\":" 1 > Filmliste-akt &  #Entpacken der Filmliste und Einfügen von Zeilenumbrüchen
            dots
            rm Filmliste-akt.xz
            sed -i 's-","?-","\\?-g' Filmliste-akt 2>/dev/null &  #mawk macht Probleme, wenn Thema mit ? beginnt
            dots
            sed -i 's-\\"-"-g' Filmliste-akt 2>/dev/null &  #gawk gibt Warnung aus bei \" in Thema
            dots
            awk -F "\"" '!/\[""/ { sender = $2; } { print sender"\",\""$0; }' Filmliste-akt | awk -F "\",\"" -v OFS="\",\"" '!($3==""){ thema = $3; } {sub($3,thema,$3); print}' > filmliste & #allen Zeilen Sender voranstellen und in alle Zeilen Thema einfügen
            dots
            echo
            rm Filmliste-akt
            # Entfernung von Zeilenumbruch-Escape-Sequenzen in Filmliste (d.h. in Film-Beschreibungen)
            sed -i 's/\(\(\\r\)*\(\\n\)\)\+/\ /g' filmliste
            echo "Die Filmliste wurde aktualisiert"
            exec "$0" -v | sed 's/Filmliste vom/Stand:/g' | sed -n '2p'
        fi

    # Fall: Download-Frage verneint
    else
        [ -f $dir/filmliste ] || printf "\033[1mOhne Filmliste funktioniert MediaTerm nicht.\033[0m\n" && exit
    fi

    # Bei Option -u wird Programm nach Download beendet
    [ -z $uopt ] || exit 0
fi

#### Bei fehlendem Suchstring wird die interne Kommando(Such-)zeile ohne Trefferliste geöffnet (Ausnahme: Option -l, Livestreams) bzw. bei bestimmten Optionen eine Meldung ausgegeben
if [[ -z $1 && -z $lopt ]]; then
    if ! [[ -z $nopt && -z $Aopt && -z $Bopt && -z $gopt && -z $kopt && -z $Kopt && -z $Lopt && -z $qopt && -z $Qopt && -z $sopt && -z $topt ]]; then
        echo "Es wurde kein Suchbegriff eingegeben!"
        [ -z $Hopt ] && exit 1
    fi
    icli
fi

#### Suche (rohes Suchergebnis)
echo
# Falls Option -l, Änderung des Suchstrings zu "Livestream"
if [ ! -z $lopt ]; then
    out=$(grep -w "\"Livestream\"" $dir/filmliste)
else
    # Variable, um Suche in URLs auszuschließen
    nourls=$(printf '.*'; printf '\\",\\".*%.0s' {1..12})

    # Wenn Option -g NICHT gewählt, keine Unterscheidung zwischen Gross- und Kleinschreibung
    [ -z $gopt ] && C="I"   #sed-Option I (ignore case) in Variable C

    # Suchergebnis für ersten Suchstring
    if [[ $1 = \+* ]]; then
        out=$(tail -n +2 $dir/filmliste | sed -n "/\b${1:1}\b$nourls/$C p")   #Exakte Wortsuche
    else
        out=$(tail -n +2 $dir/filmliste | sed -n "/$1$nourls/$C p")
    fi
fi

# Filtern mit weiteren Suchstrings
for i in "${@:2}"; do
    if [[ $i = \+* ]]; then
        out=$(echo "$out" | sed -n "/\b${i:1}\b$nourls/$C p")   #Exakte Wortsuche
    elif [[ $i = \~\+* ]]; then
        out=$(echo "$out" | sed -n "/\b${i:2}\b$nourls/$C !p")  #Ausschluss eines exakten Wortes
    elif [[ $i = \~* ]]; then
        out=$(echo "$out" | sed -n "/${i:1}$nourls/$C !p")   #Ausschluss eines Strings
    else
        out=$(echo "$out" | sed -n "/$i$nourls/$C p")   #Normale Stringsuche
    fi
done

if [[ "$out" ]]; then
    # Filtern nach Zeitraum (Optionen -A, -B)
    if ! [[ "$datum1" = "01.01.0000" && "$datum2" = "31.12.9999" ]]; then
        out=$(echo "$out" | awk -F"\",\"" 'OFS="\",\""{ n=split($5,b,".");$5=b[3]"."b[2]"."b[1];print }' |   #Datumsfelder ($5) werden zwecks Vergleich invertiert \
        awk -F "\",\"" -v t1="$datum1" -v t2="$datum2" '{if (($5 <= t2)&&($5 >= t1)) {print} }' |   #Vergleich der Datumsfelder mit Optionsargumenten; Filtern mit if-Anweisung \
        awk -F"\",\"" 'OFS="\",\""{ n=split($5,b,".");$5=b[3]"."b[2]"."b[1];print}')   #Zurücksetzen der Datumsfelder ($5) in ihr ursprüngliches Format
    fi

    # Filtern nach Filmlänge (Optionen -K, -L)
    if ! [[ -z $Kopt && -z $Lopt ]]; then
        out=$(echo "$out" | awk -F"\",\"" 'OFS="\",\""{n=split($7,b,":"); $7=(b[1]*3600 + b[2]*60 + b[3]);print }' |   #Filmlänge ($7) wird in Sekunden konvertiert \
        awk -F "\",\"" -v d1="$longer" -v d2="$shorter" '{if (($7 >= d1)&&($7 <= d2)) {print} }' |   #Vergleich der Filmlänge mit Optionsargument; Filtern mit if-Anweisung \
        awk -F"\",\"" 'OFS="\",\""{hms="date -u -d @"$7 " +%T";hms | getline $7;close(hms);print}')   #Zurücksetzen der Felder "Dauer" ($7) in ihr ursprüngliches Format
    fi
fi

#### Sortieren nach Sendezeit (Optionen -s, -t)
# Sortierung aufsteigend
[ ! -z $topt ] && out=$(echo "$out" | awk -F "\",\"" '{print $5"*"$6"-"$0}' | sort -t"." -n -k3,3 -k2,2 -k1,1 | cut -d "-" -f 2-)
# Sortierung absteigend
[ ! -z $sopt ] && out=$(echo "$out" | awk -F "\",\"" '{print $5"*"$6"-"$0}' | sort -t"." -r -n -k3,3 -k2,2 -k1,1 | cut -d "-" -f 2-)

#### Formatierung und Ausgabe des Suchergebnisses
hits