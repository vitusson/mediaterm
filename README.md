Mit dem Bash-Skript MediaTerm lassen sich Filme aus den Mediatheken der öffentlich-rechtlichen Fernsehsender ressourcenschonend im Linux-Terminal suchen, abspielen, herunterladen und als Bookmarks speichern. Für das Abspielen der Filme wird standardmäßig der Medienplayer mpv eingesetzt, der aus den Paketquellen der gängigen Linux-Distributionen installiert werden kann. Vorausgesetzt werden außerdem wget, ffmpeg und xz bzw. xz-utils; zusätzlich empfohlen wird yt-dlp.

Bei der ersten Suchanfrage mit MediaTerm erfolgt (nach Bestätigung durch den Benutzer) automatisch ein Download der Filmliste (Filmliste-akt.xz) von MediathekView, die im – ebenfalls automatisch vom Skript angelegten – Verzeichnis $HOME/MediaTerm entpackt und aufbereitet wird. Später lässt sich die Filmliste jederzeit unter Verwendung der Option "-u" aktualisieren.

Ein Überblick über alle Funktionen von MediaTerm einschließlich Anwendungsbeispielen wird mit mediaterm -h aufgerufen.

Lizenz: MediaTerm wird als freie Software unter der Lizenz GNU GENERAL PUBLIC LICENSE, GPLv3 (inoffizielle deutsche Übersetzung) zur Verfügung gestellt.
