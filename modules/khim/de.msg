# de.msg --
#
#	German-language messages for KHIM
#
# Copyright (c) 2006 by Andreas Kupries.  All rights reserved.
#
# Refer to the file "license.terms" for the terms and conditions of
# use and redistribution of this file, and a DISCLAIMER OF ALL WARRANTEES.
#
# $Id: de.msg,v 1.1 2006/09/06 17:43:12 kennykb Exp $
# $Source: /home/rkeene/tmp/cvs2fossil/tcllib/tklib/modules/khim/de.msg,v $
#
#----------------------------------------------------------------------

namespace eval ::khim {

    ::msgcat::mcset de HELPTEXT {

	Kevin's Hacky Input Method (KHIM)

	KHIM ermoeglicht die Eingabe von internationalen Zeichen
	mittels einer Tastatur, welches diese nicht direkt
	unterstuetzt. Es ist unabhaengig von allen Eingabemethoden,
	welche vom Betriebssystem bereitgestellt werden (koennten),
	und fuer den Fall gedacht, wenn der Anwender keine Kontrolle
	ueber die Tastatur hat und dennoch Text in anderen Sprachen
	eingeben muss.

	Um KHIM zu benutzen, ist es notwendig, den KHIM Steuer-Dialog zu
	oeffnen (dies ist abhaengig von der Anwendung) und dann KHIM
	durch 'ticken' der 'Benutze KHIM'-Checkbox zu aktivieren. Es
	ist weiterhin notwendig, eine Taste als die Kombinier-Taste zu
	waehlen. Die gewaehlte Taste sollte im Normalgebrauch selten
	genutzt werden. Die Auswahl selbst besteht aus zwei Schritten.
	Zuerst muss der Knopf "Kombinier-Taste:" gedrueckt werden,
	dann die gewuenschte Taste.

	Allgemein gesprochen, wenn die benutzte Tastatur eine Taste
	"Compose" besitzt, dann sollte diese _nicht_ als die
	Kombinier-Taste fuer KHIM gewaehlt werden. Dies stellt sicher,
	das diese Taste weiterhin vom Betriebssystem genutzt werden
	kann, um dessen eventuelle Eingabemethoden zu aktivieren.

	Sobald KHIM aktiviert wurde, koennen in jedem Widget, welches
	fuer die Benutzung von KHIM konfiguriert wurde, internationale
	Zeichen eingegeben werden. Dies geschieht durch Druecken der
	gewaehlten Kombinier-Taste, gefolgt von zwei weiteren Zeichen,
	welche das gewuenschte Zeichen identifizieren. Der KHIM
	Steuer-Dialog stellt eine Liste der bekannten Zeichenfolgen
	zur Verfuegung. Zusaetzlich ist es moeglich einen Dialog zu
	oeffnen, welcher die Auswahl beliebiger Zeichen in einer Tabelle
	erlaubt. Dies geschieht durch zweimaliges Druecken der
	Kombinier-Taste. Navigation in der Tabelle geschieht mit der
	Maus oder den Kursor-Tasten. Das einzufuegende Zeichen kann
	mit Doppel-Klick gewaehlt werden, durch Druecken der
	Leer-Taste, oder durch Druecken der Enter- (oder Return-)Taste.

	Es ist auch moeglich, die Liste der direkt anwaehlbaeren Zeichen
	zu erweitern. Dies geschieht im KHIM Steuer-Dialog durch Eingabe
	der zwei Zeichen fuer den Kode im Eingabefeld
	"Eingabezeichenfolge", des gewuenschten Zeichens im Feld
	"Zeichen", gefolgt vom Druecken des Knopfes "Aendern".

	(Bezueglich der Herkunft des gewuenschten Zeichens: Es kann aus
	einer anderen Anwendung kopiert werden, oder man benutze den Knopf
	"Unicode..." (oder druecke die Kombinier-Taste zweimal), um es
	aus der Tabelle aller Zeichen auszuwaehlen.)

	Eine Zeichenfolge wird geloescht durch Auswahl der Folge in
	der Liste aller Zeichenfolgen, gefolgt von der
	Loesch/Entferne-Taste.
    }

    ::msgcat::mcset de {SELECT COMPOSE KEY} [string map [list \n\t \n] {
	Bitte druecken Sie
	die Taste, welche Sie
	als Kombinier-Taste
	verwenden wollen.
    }]

    ::msgcat::mcset de {Apply} {Anwenden}

    ::msgcat::mcset de {Cancel} {Abbrechen}

    ::msgcat::mcset de {Change} {Aendern}

    ::msgcat::mcset de {Character} {Zeichen}

    ::msgcat::mcset de {Compose Key} {Kombinier-Taste}

    ::msgcat::mcset de {Compose key:} {Kombinier-Taste:}

    ::msgcat::mcset de {Composed sequence must be two characters long} \
	{Die Eingabezeichenfolge muss aus zwei Zeichen bestehen}

    ::msgcat::mcset de {Delete} {Loeschen}

    ::msgcat::mcset de {Help...} {Hilfe...}

    ::msgcat::mcset de {Input key sequence} {Eingabezeichenfolge}

    ::msgcat::mcset de {Insert Character} {Zeichen einfuegen}

    ::msgcat::mcset de {Invalid sequence} {Ungueltige Zeichenfolge}

    ::msgcat::mcset de {Key sequences} {Zeichenfolgen}

    ::msgcat::mcset de {KHIM Controls} {KHIM Steuerung}

    ::msgcat::mcset de {OK} {OK}

    ::msgcat::mcset de {Select code page:} {Waehle Code-Seite:}

    ::msgcat::mcset de {Unicode...} {Unicode...}

    ::msgcat::mcset de {Use KHIM} {Benutze KHIM}

}

# Local Variables:
# mode: tcl
# End:
