# as_style.tcl --
#
#	This file implements package as::style.
#
# Copyright (c) 2003 ActiveState Corporation, a division of Sophos
#

package provide style::as 1.1

namespace eval style::as {
    if { [tk windowingsystem] == "x11" } {
	set highlightbg "#316AC5" ; # SystemHighlight
	set highlightfg "white"   ; # SystemHighlightText
	set bg          "white"   ; # SystemWindow
	set fg          "black"   ; # SystemWindowText

	## Fonts
	##
	set size	-12
	set family	Helvetica
	set fsize	-12
	set ffamily	Courier


	font create ASfont      -size $size -family $family
	font create ASfontBold  -size $size -family $family -weight bold
	font create ASfontFixed -size $fsize -family $ffamily
	for {set i -2} {$i <= 4} {incr i} {
	    set isize  [expr {$size + ($i * (($size > 0) ? 1 : -1))}]
	    set ifsize [expr {$fsize + ($i * (($fsize > 0) ? 1 : -1))}]
	    font create ASfont$i      -size $isize -family $family
	    font create ASfontBold$i  -size $isize -family $family -weight bold
	    font create ASfontFixed$i -size $ifsize -family $ffamily
	}

	option add *Text.font		ASfontFixed widgetDefault
	option add *Button.font		ASfont widgetDefault
	option add *Canvas.font		ASfont widgetDefault
	option add *Checkbutton.font	ASfont widgetDefault
	option add *Entry.font		ASfont widgetDefault
	option add *Label.font		ASfont widgetDefault
	option add *Labelframe.font	ASfont widgetDefault
	option add *Listbox.font	ASfont widgetDefault
	option add *Menu.font		ASfont widgetDefault
	option add *Menubutton.font	ASfont widgetDefault
	option add *Message.font	ASfont widgetDefault
	option add *Radiobutton.font	ASfont widgetDefault
	option add *Spinbox.font	ASfont widgetDefault

	option add *Table.font		ASfont widgetDefault
	option add *TreeCtrl*font	ASfont widgetDefault
	## Misc
	##
	option add *ScrolledWindow.ipad		0 widgetDefault

	## Listbox
	##
	option add *Listbox.background		$bg widgetDefault
	option add *Listbox.foreground		$fg widgetDefault
	option add *Listbox.selectBorderWidth	0 widgetDefault
	option add *Listbox.selectForeground	$highlightfg widgetDefault
	option add *Listbox.selectBackground	$highlightbg widgetDefault
	option add *Listbox.activeStyle		dotbox widgetDefault

	## Button
	##
	option add *Button.padX			1 widgetDefault
	option add *Button.padY			2 widgetDefault

	## Entry
	##
	option add *Entry.background		$bg widgetDefault
	option add *Entry.foreground		$fg widgetDefault
	option add *Entry.selectBorderWidth	0 widgetDefault
	option add *Entry.selectForeground	$highlightfg widgetDefault
	option add *Entry.selectBackground	$highlightbg widgetDefault

	## Spinbox
	##
	option add *Spinbox.background		$bg widgetDefault
	option add *Spinbox.foreground		$fg widgetDefault
	option add *Spinbox.selectBorderWidth	0 widgetDefault
	option add *Spinbox.selectForeground	$highlightfg widgetDefault
	option add *Spinbox.selectBackground	$highlightbg widgetDefault

	## Text
	##
	option add *Text.background		$bg widgetDefault
	option add *Text.foreground		$fg widgetDefault
	option add *Text.selectBorderWidth	0 widgetDefault
	option add *Text.selectForeground	$highlightfg widgetDefault
	option add *Text.selectBackground	$highlightbg widgetDefault

	## Menu
	##
	option add *Menu.activeBackground	$highlightbg widgetDefault
	option add *Menu.activeForeground	$highlightfg widgetDefault
	option add *Menu.activeBorderWidth	0 widgetDefault
	option add *Menu.highlightThickness	0 widgetDefault
	option add *Menu.borderWidth		1 widgetDefault

	## Menubutton
	##
	option add *Menubutton.activeBackground	$highlightbg widgetDefault
	option add *Menubutton.activeForeground	$highlightfg widgetDefault
	option add *Menubutton.activeBorderWidth	0 widgetDefault
	option add *Menubutton.highlightThickness	0 widgetDefault
	option add *Menubutton.borderWidth		0 widgetDefault
	option add *Menubutton*padX			4 widgetDefault
	option add *Menubutton*padY			2 widgetDefault

	## Scrollbar
	##
	option add *Scrollbar.width		12 widgetDefault
	option add *Scrollbar.troughColor	#bdb6ad widgetDefault
	option add *Scrollbar.borderWidth		1 widgetDefault
	option add *Scrollbar.highlightThickness	0 widgetDefault

	## PanedWindow
	##
	option add *Panedwindow.borderWidth		0 widgetDefault
	option add *Panedwindow.sashwidth		3 widgetDefault
	option add *Panedwindow.showhandle		0 widgetDefault
	option add *Panedwindow.sashpad		0 widgetDefault
	option add *Panedwindow.sashrelief		flat widgetDefault
	option add *Panedwindow.relief		flat widgetDefault
    }
}; # end of namespace style::as
