# -*- tcl -*-
#
# scrollw.tcl -
#
#	Scrolled widget
#
# RCS: @(#) $Id: scrollw.tcl,v 1.13 2007/04/10 18:15:28 hobbs Exp $
#

# Creation and Options - widget::scrolledwindow $path ...
#  -scrollbar -default "both" ; vertical horizontal none
#  -auto      -default "both" ; vertical horizontal none
#  -sides     -default "se"   ;
#  -size      -default 0      ; scrollbar -width (not recommended to change)
#  -ipad      -default {0 0}  ; represents internal {x y} padding between
#			      ; scrollbar and given widget
#  All other options to frame
#
# Methods
#  $path getframe           => $frame
#  $path setwidget $widget  => $widget
#  All other methods to frame
#
# Bindings
#  NONE
#

if 0 {
    # Samples
    package require widget::scrolledwindow
    #set sw [widget::scrolledwindow .sw -scrollbar vertical]
    #set text [text .sw.text -wrap word]
    #$sw setwidget $text
    #pack $sw -fill both -expand 1

    set sw [widget::scrolledwindow .sw -borderwidth 1 -relief sunken]
    set text [text $sw.text -borderwidth 0 -height 4 -width 20]
    $sw setwidget $text
    pack $sw -fill both -expand 1 -padx 4 -pady 4

    set sw [widget::scrolledwindow .ssw -borderwidth 2 -relief solid]
    set text [text $sw.text -borderwidth 0 -height 4 -width 20]
    $sw setwidget $text
    pack $sw -fill both -expand 1 -padx 4 -pady 4
}

###

package require widget
package require tile

snit::widget widget::scrolledwindow {
    hulltype ttk::frame

    component hscroll
    component vscroll

    delegate option * to hull
    delegate method * to hull
    #delegate option -size to {hscroll vscroll} as -width

    option -scrollbar -default "both" \
	-configuremethod C-scrollbar -validatemethod isa
    option -auto      -default "both" \
	-configuremethod C-scrollbar -validatemethod isa
    option -sides     -default "se" \
	-configuremethod C-scrollbar -validatemethod isa
    option -size      -default 0 -configuremethod C-size -validatemethod isa
    option -ipad      -default 0 -configuremethod C-ipad -validatemethod isa

    typevariable scrollopts {none horizontal vertical both}
    variable realized 0    ; # set when first Configure'd
    variable hsb -array {
	packed 0 present 0 auto 0 cell 0 lastmin -1 lastmax -1 lock 0
    }
    variable vsb -array {
	packed 0 present 0 auto 0 cell 0 lastmin -1 lastmax -1 lock 0
    }
    variable pending {}    ; # pending after id for scrollbar mgmt

    constructor args {
	if {[tk windowingsystem] eq "x11"} {
	    install hscroll using ttk::scrollbar $win.hscroll \
		-orient horizontal -takefocus 0
	    install vscroll using ttk::scrollbar $win.vscroll \
		-orient vertical -takefocus 0
	} else {
	    install hscroll using scrollbar $win.hscroll \
		-orient horizontal -takefocus 0
	    install vscroll using scrollbar $win.vscroll \
		-orient vertical -takefocus 0
	    # in case the scrollbar has been overridden ...
	    catch {$hscroll configure -highlightthickness 0}
	    catch {$vscroll configure -highlightthickness 0}
	}

	set hsb(bar) $hscroll
	set vsb(bar) $vscroll
	bind $win <Configure> [mymethod _realize $win]

	grid columnconfigure $win 1 -weight 1
	grid rowconfigure    $win 1 -weight 1

	set pending [after idle [mymethod _setdata]]
	$self configurelist $args
    }

    destructor {
	after cancel $pending
    }

    # Do we need this ??
    method getframe {} { return $win }

    method isa {option value} {
	set cmd widget::isa
	switch -exact -- $option {
	    -scrollbar -
	    -auto {
		return [uplevel 1 [list $cmd list $scrollopts $option $value]]
	    }
	    -sides {
		return [uplevel 1 [list $cmd list {ne en nw wn se es sw ws} $option $value]]
	    }
	    -size {
		return [uplevel 1 [list $cmd integer {0 30} $option $value]]
	    }
	    -ipad {
		return [uplevel 1 [list $cmd listofint 2 $option $value]]
	    }
	}
    }

    variable setwidget {}
    method setwidget {widget} {
	if {$setwidget eq $widget} { return }
	if {[winfo exists $setwidget]} {
	    grid remove $setwidget
	    $setwidget configure -xscrollcommand "" -yscrollcommand ""
	    set setwidget {}
	}
	if {[winfo exists $widget]} {
	    set setwidget $widget
	    grid $widget -in $win -row 1 -column 1 -sticky news

	    $hscroll configure -command [list $widget xview]
	    $vscroll configure -command [list $widget yview]
	    $widget configure \
		-xscrollcommand [mymethod _set_scroll hsb] \
		-yscrollcommand [mymethod _set_scroll vsb]
	}
	return $widget
    }

    method C-size {option value} {
	set options($option) $value
	$vscroll configure -width $value
	$hscroll configure -width $value
    }

    method C-scrollbar {option value} {
	set options($option) $value
	after cancel $pending
	set pending [after idle [mymethod _setdata]]
    }

    method C-ipad {option value} {
	set options($option) $value
	# double value to ensure a single int value covers pad x and y
	foreach {padx pady} [concat $value $value] { break }
	grid configure $vscroll -padx [list $padx 0]
	grid configure $hscroll -pady [list $pady 0]
    }

    method _set_scroll {varname vmin vmax} {
	upvar 0 $varname sb
	if {$realized && $sb(present)} {
	    if {$sb(auto)} {
		if {!$sb(lock)} {
		    # One last check to avoid loops when not locked
		    if {$vmin == $sb(lastmin) && $vmax == $sb(lastmax)} {
			return
		    }
		    set sb(lastmin) $vmin
		    set sb(lastmax) $vmax
		}
		if {$sb(packed) && $vmin == 0 && $vmax == 1} {
		    if {!$sb(lock)} {
			set sb(packed) 0
			grid remove $sb(bar)
		    }
		} elseif {!$sb(packed) && ($vmin != 0 || $vmax != 1)} {
		    set sb(packed) 1
		    if {$varname eq "vsb"} {
			grid $sb(bar) -column $sb(cell) -row 1 -sticky ns
		    } else {
			grid $sb(bar) -column 1 -row $sb(cell) -sticky ew
		    }
		}
		set sb(lock) 1
		update idletasks
		set sb(lock) 0
	    }
	    $sb(bar) set $vmin $vmax
	}
    }

    method _setdata {} {
	set sb    [lsearch -exact $scrollopts $options(-scrollbar)]
	set auto  [lsearch -exact $scrollopts $options(-auto)]

	set hsb(present) [expr {($sb & 1) != 0}]
	set hsb(auto)	 [expr {($auto & 1) != 0}]
	set hsb(cell)	 [expr {[string match *n* $options(-sides)] ? 0 : 2}]

	set vsb(present) [expr {($sb & 2) != 0}]
	set vsb(auto)	 [expr {($auto & 2) != 0}]
	set vsb(cell)    [expr {[string match *w* $options(-sides)] ? 0 : 2}]

	foreach {vmin vmax} [$hscroll get] { break }
	set hsb(packed) [expr {$hsb(present) &&
			       (!$hsb(auto) || ($vmin != 0 || $vmax != 1))}]
	foreach {vmin vmax} [$vscroll get] { break }
	set vsb(packed) [expr {$vsb(present) &&
			       (!$vsb(auto) || ($vmin != 0 || $vmax != 1))}]

	if {$hsb(packed)} {
	    grid $hscroll -column 1 -row $hsb(cell) -sticky ew
	}
	if {$vsb(packed)} {
	    grid $vscroll -column $vsb(cell) -row 1 -sticky ns
	}
    }

    method _realize {w} {
	if {$w eq $win} {
	    bind $win <Configure> {}
	    set realized 1
	}
    }
}

package provide widget::scrolledwindow 1.1
