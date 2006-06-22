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
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAFo9M/3AAAABGdBTUEAAYag
	MeiWXwAAAxFJREFUGJVlkH9o1HUYx1+f785rroliUpsFi4KQojAtRjOv3PxF
	E5dy9GPdjin5j/2xipixSiGj2F9BMTYp/KPYzfC2m3BsDDSWNE9j3aVlbZSa
	X8WbHc21731///j0z91Y64E37z+e53m/n+cNwPkvX05x7thLqZyqtZAd2FcA
	IKdqBwDIJtoLOVXrzKnaQco1NjYmh9+MtP2Z+VySTcTqs4n9/kI3p2p7c6r2
	1pmPm98HUIAsMOe5wXsAocJU5pqqqjRt3c4nmWt/iGwiVi8D2aJE+rJADTBS
	TLVPbO4YrAVQpFx2Ton0XQfWAh7QqP89v6XsKQDOfvpi3tHtHtf2klUrV1x+
	6PkdyvToCFs/OCUUgIuhpienVjUfHZlbZzz3zlBF5tjxuO/b9Mc3rBEA2YF4
	Sojwbt+2Zx3d2NVwcPDCgkXuxL48DZ81AtuBq8VU2zOu5Z1qPJS+AKD4ltUD
	tAAhoK56z9ffgkiXFRTX9pKACViAC9wjfbl6YUD6JIA8YJcwYWvmZHkg5Bh2
	r3Wi9V1Xt1sDN4jWNTx9Y13zCyTvGPdF+zK3xejoqF5ZWVlVLBaZnJz8qXHl
	9PpHtu1EPf8dV76/dDcA3d3dZmdnp1GW7Y9tlCdfr7+1kGR2oO2AEKEPZeDn
	A9cb8j0/KQMJUkYlyl58al3HPhzpGP6CJSV+TMRTSOqUzT2twBZgFeADQYn/
	Aibmk7Ehz/WvNx1K71ksEFJEaLdj6I+FoQlYXoqrvOwD1cAmR7NbK5bfdXnp
	BYpj2bOB60eBK6W87UVwSnzDc/yoo1uz/xfQjF1+IN6YH4xFgDTwG3AHmAOm
	gdPF4f2n71//6NFw0V4z3PHsq//JAGB8fFw6joNt21iWhWmaGIaBrs3LJ4yz
	4sHIJlbc+wBCUfjn5u9c/OZM4Af22leO/3BbASgUCrUzMzO6ruuEw2FM00RV
	VfPmrfzD246kxaWT6fgvqSFmr07hOZKax2uVimXi1/74hmqx+Jyurq4a0zR/
	tixrY29vr7r034H2p1YXLe/tqrD46LWvchbAv3ejiD1SNMCQAAAAAElFTkSu
	QmCC
    }
    variable menuentry_gifdata {
	R0lGODlhEAAQAPcAAAQEBGRsaW5saW51dHh1dHh+foF+fotGLIuIiJWRkpWb
	nJ5ZLJ6bnJ6kpqhZN6hiN6hiQahsN6iuprJsN7JsQbJ1QbKusbK3sbt+S7uI
	S7uIVbu3u7vBu8WIVcWRS8WRVcWbVcWbX8+kVc+kX8+udM/d7ti3ftjBiOLB
	iOLBkuLKkuLKnOLUpgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAP///yH5BAEAAP8ALAAAAAAQABAAQAiEAP8JHEGQIAiB
	CAWC+JAwIYYKCUc0bJih4YYNHDZcYGDg34cUK1SEODBQYkMPDCNOTFjxZEuB
	HUysQIFhIoIEBBo6wPAgokmFBxsSXPnPw8t/P1ceDUFUYM2EHzxM/EACYsKM
	FyQ0UIAAwwkWLExASNiggQUFBRBqMGHiQ8+EA1YuQBgQADs=
    }
}

proc ::widget::createMenuEntryLayout {} {
    variable MENUENTRY
    if {[info exists MENUENTRY]} { return }
    set MENUENTRY 1
    variable menuentry_pngdata
    variable menuentry_gifdata
    set img ::widget::img_menuentry
    if {[package provide img::png] != ""} {
	image create photo $img -format PNG -data $menuentry_pngdata
    } else {
	image create photo $img -format GIF -data $menuentry_gifdata
    }
    # Create -padding for space on left and right of icon
    set pad [expr {[image width $img] + 4}]
    foreach theme [style theme names] {
	# Do this per-theme so that we adapt to theme changes
	style theme settings $theme {
	    style layout MenuEntry {
		Entry.field -children {
		    MenuEntry.icon -side left
		    Entry.padding -children {
			Entry.textarea
		    }
		}
	    }
	    # center icon in padded cell
	    style element create MenuEntry.icon image $img -sticky "" \
		-padding [list $pad 0 0 0]

	    # Could have disabled, pressed, ... state images
	    #style map MenuEntry -image [list disabled $img]
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
    bind TMenuEntry <Control-space> { ttk::menuentry::Popdown %W 10 10 }

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
