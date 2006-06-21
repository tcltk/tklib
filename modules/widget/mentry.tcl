# -*- tcl -*-
#
# mentry.tcl -
#
#	MenuEntry widget
#

# Creation and Options - widget::menuentry $path ...
#  -menu -default "" ; menu to associate with entry
#  -image -default "default"
#  All other options to entry
#
# Methods
#  All other methods to entry
#
# Bindings
#  NONE
#

if 0 {
    # Samples
    package require widget::menuentry
    set me [widget::menuentry .me]
    set menu [menu .me.menu -tearoff 0]
    $menu add radiobutton -label "Name" -variable foo -value name
    $menu add radiobutton -label "Abstract" -variable foo -value abstract
    $menu add separator
    $menu add radiobutton -label "Name and Abstract" \
	-variable foo -value [list name abstract]
    $me configure -menu $menu
    pack $me -fill x -expand 1 -padx 4 -pady 4
}

###

package require widget
package require tile

namespace eval ::widget {
    # PNG version has partial alpha transparency for better look
    variable menuentry_pngdata {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/I
	NwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAJG
	SURBVDjLjdJLSNRBHMDx78yqLZaKS75DPdgDDaFDbdJmde5QlhCJGxgpRJfq
	EEKnIsJLB7skQYQKZaSmdLaopPCgEvSCShCMzR5a7oq7/3l12RVtjfzBMA/4
	fWZ+MyOccwBM3g8HEbIdfCEhfAFnLVapOa28Uevpjrqz/WOsERJgsu9Uq5CZ
	QzgqrJfo9BajNd5irEYn4p3OUiFExtCLmw2tawFi4l5zUMjMIau9u7K+qxeo
	AcoAA0wDb2OPwmfA16LiiaOHLj1edRLpkO3WmIis7+oBDgJbgQ2AH6gC6jY1
	9N62RkcctKeVIJAhp9QgUA3kJXdONZVcq9JxPSgQoXRAyIDRth8oAXQyKdWn
	oCKrTD9CBv4GMqx1WGNZkeRWJKbG2hiD1Cb9FbTnzWFdY/LCdLKlgNQ84gyN
	KqHm0gDjqVHnxDHgA/B9RQkpaB6YklkZl62np9KBhOqwjpKFgeY2YAz4BESB
	WHI8Hhs6PVVSvc3v98ye4fP7T676B845nt040ip98qpWJmI9PWiU6bfWgXGN
	2YHcKwU7tsuc4kpUPMbU0+f8+vKt+Pitl7PLAMDI9cNBoB0hQwICzjqUp6MZ
	vsy8yvp95BRuQUjJ75mPvH4wYo1NlJ64Mza7DPwrhi8cCOeXl/aUB4P4c/NJ
	xKLMvpngycCrzxVFG2v/CwAMnguF80oLe8p27cQh+fnpPV/fTc95S6piXQDA
	w7a9YbWkezZXFbAwMx/xPFXb1D3+Y90AQF/L7kAsri9mZ4lrTd0TcYA/Kakr
	+x2JSPUAAAAASUVORK5CYII=
    }
    variable menuentry_gifdata {
	R0lGODlhEAAQAMQAAAAAAIBIKOjQoNjAiMCQUODQoODImODAkLiASLiAUKhg
	OMigWLiISKhgMMiYULhwQMiYWMCISJhYMLB4QMCYULh4QMigYMCIUMCIWMiY
	YMioYNCoaKBYMNCweNi4gAAAACH5BAEAAB8AIf/8SUNDUkdCRzEwMTIAAALM
	YXBwbAIAAABtbnRyUkdCIFhZWiAH1gAGABQAAAAAAABhY3NwQVBQTAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAA9tYAAQAAAADTLWFwcGwAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAxyWFlaAAAB
	FAAAABRnWFlaAAABKAAAABRiWFlaAAABPAAAABR3dHB0AAABUAAAABRjaGFk
	AAABZAAAACxyVFJDAAABkAAAAA5nVFJDAAABoAAAAA5iVFJDAAABsAAAAA52
	Y2d0AAABwAAAADBu/2RpbgAAAfAAAAA4ZGVzYwAAAigAAAB0Y3BydAAAApwA
	AAAtWFlaIAAAAAAAAHRLAAA+HQAAA8xYWVogAAAAAAAAWnMAAKymAAAXJlhZ
	WiAAAAAAAAAoGAAAFVcAALgzWFlaIAAAAAAAAPNRAAEAAAABFsxzZjMyAAAA
	AAABDEIAAAXe///zJgAAB5MAAP2Q///7ov///aMAAAPcAADAbmN1cnYAAAAA
	AAAAAQI5AABjdXJ2AAAAAAAAAAECOQAAY3VydgAAAAAAAAABAjkAAHZjZ3QA
	AAAAAAAAAQABAAAAAAAAAAEAAAABAAAAAAAAAAEAAAABAAAAAAAAAAEAANxu
	ZGluAAAAAAAAADAAAKFIAABXCgAAS4UAAJrhAAAnrgAAE7YAAFANAABUOQAC
	OOQAAjjkAAI45GRlc2MAAAAAAAAAGkNhbGlicmF0ZWQgUkdCIENvbG9yc3Bh
	Y2UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAdGV4dAAAAABD
	b3B5cmlnaHQgQXBwbGUgQ29tcHV0ZXIsIEluYy4sIDIwMDUAAAAAACwAAAAA
	EAAQAAAFWeAnLpZmLY6ortqyUsSqtvJHxOvi1l/ErBae6qcKCj9EkVGIWEGO
	n8oLV0NMZIRIjbB51C7Jz6VjGDRliLQV4REIPAroBzMoHDIBeaLTITTkHxwI
	f4AfEiohADs=
    }
}

proc ::widget::createMenuEntryLayout {} {
    variable MENUENTRY
    if {[info exists MENUENTRY]} { return }
    set MENUENTRY 1
    variable menuentry_pngdata
    variable menuentry_gifdata
    if {[package provide img::png] != ""} {
	image create photo ::widget::img_menuentry \
	    -format PNG -data $menuentry_pngdata
    } else {
	image create photo ::widget::img_menuentry \
	    -format GIF -data $menuentry_gifdata
    }
    foreach theme [style theme names] {
	set pad [style theme settings $theme { style default TEntry -padding }]

	switch -- [llength $pad] {
	    0 { set pad [list 4 0 0 0] }
	    1 { set pad [list [expr {$pad+4}] $pad $pad $pad] }
	    2 {
		foreach {padx pady} $pad break
		set pad [list [expr {$padx+4}] $pady $padx $pady]
	    }
	    4 { lset pad 0 [expr {[lindex $pad 0]+4}] }
	}

	style theme settings $theme {
	    style layout MenuEntry {
		Entry.field -children {
		    MenuEntry.icon -side left
		    Entry.padding -children {
			Entry.textarea
		    }
		}
	    }

	    style configure MenuEntry -padding $pad
	    style element create MenuEntry.icon image ::widget::img_menuentry \
		-padding {8 0 0 0} -sticky {}

	    #style map MenuEntry -image [list disabled ::widget::img_menuentry]
	}
    }
}

snit::widgetadaptor widget::menuentry {
    delegate option * to hull
    delegate method * to hull

    option -image -default "default" -configuremethod C-image
    option -menu -default "" -configuremethod C-menu

    constructor args {
	::widget::createMenuEntryLayout

	installhull using ttk::entry -style MenuEntry

	bindtags $win [linsert [bindtags $win] 1 TMenuEntry]

	$self configurelist $args
    }

    method C-menu {option value} {
	if {$value ne "" && ![winfo exists $value]} {
	    return -code error "invalid widget \"$value\""
	}
	set options($option) $value
    }

    method C-image {option value} {
	set options($option) $value
	if {$value eq "default"} {
	}
    }
}

# Bindings for menu portion.
#
# This is a variant of the ttk menubutton.tcl bindings.
# See menubutton.tcl for detailed behavior info.
#

namespace eval ttk {
    bind TMenuEntry <Enter>	{ %W state active }
    bind TMenuEntry <Leave>	{ %W state !active }
    bind TMenuEntry <<Invoke>> 	{ ttk::menuentry::Popdown %W %x %y }
    bind TMenuEntry <Key-space>	{ ttk::menuentry::Popdown %W 10 10 }

    if {[tk windowingsystem] eq "x11"} {
	bind TMenuEntry <ButtonPress-1>   { ttk::menuentry::Pulldown %W %x %y }
	bind TMenuEntry <ButtonRelease-1> { ttk::menuentry::TransferGrab %W }
	bind TMenuEntry <B1-Leave>  	  { ttk::menuentry::TransferGrab %W }
    } else {
    	bind TMenuEntry <ButtonPress-1>  \
	    { %W state pressed ; ttk::menuentry::Popdown %W %x %y }
	bind TMenuEntry <ButtonRelease-1> { %W state !pressed }
    }

    namespace eval menuentry {
	variable State

	array set State {
	    pulldown	0
	    oldcursor	{}
	}
    }
}

# PostPosition --
#	Returns the x and y coordinates where the menu 
#	should be posted, based on the menuentry and menu size
#	and -direction option.
#
# TODO: adjust menu width to be at least as wide as the button
#	for -direction above, below.
#
proc ttk::menuentry::PostPosition {mb menu} {
    set x [winfo rootx $mb]
    set y [winfo rooty $mb]
    set dir "below" ; #[$mb cget -direction]

    set bw [winfo width $mb]
    set bh [winfo height $mb]
    set mw [winfo reqwidth $menu]
    set mh [winfo reqheight $menu]
    set sw [expr {[winfo screenwidth  $menu] - $bw - $mw}]
    set sh [expr {[winfo screenheight $menu] - $bh - $mh}]

    switch -- $dir {
	above { if {$y >= $mh} { incr y -$mh } { incr y  $bh } }
	below { if {$y <= $sh} { incr y  $bh } { incr y -$mh } }
	left  { if {$x >= $mw} { incr x -$mw } { incr x  $bw } }
	right { if {$x <= $sw} { incr x  $bw } { incr x -$mw } }
	flush { 
	    # post menu atop menuentry.
	    # If there's a menu entry whose label matches the
	    # menuentry -text, assume this is an optionmenu
	    # and place that entry over the menuentry.
	    set index [FindMenuEntry $menu [$mb cget -text]]
	    if {$index ne ""} {
		incr y -[$menu yposition $index]
	    }
	}
    }

    return [list $x $y]
}

# Popdown --
#	Post the menu and set a grab on the menu.
#
proc ttk::menuentry::Popdown {me x y} {
    if {[$me instate disabled] || [set menu [$me cget -menu]] eq ""
	|| [$me identify $x $y] ne "MenuEntry.icon"} {
	return
    }
    foreach {x y} [PostPosition $me $menu] { break }
    tk_popup $menu $x $y
}

# Pulldown (X11 only) --
#	Called when Button1 is pressed on a menuentry.
#	Posts the menu; a subsequent ButtonRelease 
#	or Leave event will set a grab on the menu.
#
proc ttk::menuentry::Pulldown {mb x y} {
    variable State
    if {[$mb instate disabled] || [set menu [$mb cget -menu]] eq ""
	|| [$mb identify $x $y] ne "MenuEntry.icon"} {
	return
    }
    foreach {x y} [PostPosition $mb $menu] { break }
    set State(pulldown) 1
    set State(oldcursor) [$mb cget -cursor]

    $mb state pressed
    $mb configure -cursor [$menu cget -cursor]
    $menu post $x $y
    tk_menuSetFocus $menu
}

# TransferGrab (X11 only) --
#	Switch from pulldown mode (menuentry has an implicit grab)
#	to popdown mode (menu has an explicit grab).
#
proc ttk::menuentry::TransferGrab {mb} {
    variable State
    if {$State(pulldown)} {
	$mb configure -cursor $State(oldcursor)
	$mb state {!pressed !active}
	set State(pulldown) 0
	grab -global [$mb cget -menu]
    }
}

# FindMenuEntry --
#	Hack to support tk_optionMenus.
#	Returns the index of the menu entry with a matching -label,
#	-1 if not found.
#
proc ttk::menuentry::FindMenuEntry {menu s} {
    set last [$menu index last]
    if {$last eq "none"} {
	return ""
    }
    for {set i 0} {$i <= $last} {incr i} {
	if {![catch {$menu entrycget $i -label} label]
	    && ($label eq $s)} {
	    return $i
	}
    }
    return ""
}

package provide widget::menuentry 1.0
