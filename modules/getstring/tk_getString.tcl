# tk_getString.tcl --
#
#       A dialog which prompts for a string input
#
# Copyright (c) 2005    Aaron Faupell <afaupell@users.sourceforge.net>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# RCS: @(#) $Id: tk_getString.tcl,v 1.1 2005/03/17 19:39:45 afaupell Exp $

package require Tk
package provide tk_getString 0.1

namespace eval ::dialogs {
    namespace export tk_getString
}

if {[tk windowingsystem] == "win32"} {
    option add *TkSDialog*Button.width -10 widgetDefault
    option add *TkSDialog*Button.padX 1m widgetDefault
} else {
    option add *TkSDialog.borderWidth 1 widgetDefault
    option add *TkSDialog*Button.width 5 widgetDefault
}
option add *TkSDialog*Entry.width 20 widgetDefault

proc ::dialogs::getStringEnable {w} {
    if {![winfo exists $w.entry]} {return}
    if {[$w.entry get] != ""} {
        $w.ok configure -state normal
    } else {
        $w.ok configure -state disabled
    }
}

proc ::dialogs::tk_getString {w var title text args} {
    set allowempty 0
    set entryoptions {}
    foreach {opt arg} $args {
        if {$opt == "-allowempty" && [string is boolean -strict $arg] && $arg} {
            set allowempty 1
        } elseif {[string match -inv* $opt] || [string match -valid* $opt]} {
            lappend entryoptions $opt $arg
        }
    }

    variable ::tk::Priv
    upvar $var result
    catch {destroy $w}
    set focus [focus]
    set grab [grab current .]

    toplevel $w -relief raised -class TkSDialog
    wm title $w $title
    wm iconname $w $title
    wm protocol $w WM_DELETE_WINDOW {set ::tk::Priv(button) 0}
    wm transient $w [winfo toplevel [winfo parent $w]]

    eval [list entry $w.entry] $entryoptions
    button $w.ok -text OK -default active -command {set ::tk::Priv(button) 1}
    button $w.cancel -text Cancel -command {set ::tk::Priv(button) 0}
    label $w.label -text $text

    grid $w.label -columnspan 2 -sticky ew -padx 3 -pady 3
    grid $w.entry -columnspan 2 -sticky ew -padx 3 -pady 3
    grid $w.ok $w.cancel -padx 3 -pady 3
    grid rowconfigure $w 2 -weight 1
    grid columnconfigure $w {0 1} -uniform 1 -weight 1

    bind $w <Return> [list $w.ok invoke]
    bind $w <Escape> [list $w.cancel invoke]
    bind $w <Destroy> {set ::tk::Priv(button) 0}
    if {!$allowempty} {
        bind $w.entry <KeyPress> [list after idle [list ::dialogs::getStringEnable $w]]
        $w.ok configure -state disabled 
    }

    wm withdraw $w
    update idletasks
    focus $w.entry
    if {[winfo parent $w] == "."} {
        set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 - [winfo vrootx $w]}]
        set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 - [winfo vrooty $w]}]
    } else {
        set t [winfo toplevel [winfo parent $w]]
        set x [expr {[winfo width $t]/2 - [winfo reqwidth $w]/2 - [winfo vrootx $w]}]
        set y [expr {[winfo height $t]/2 - [winfo reqheight $w]/2 - [winfo vrooty $w]}]
    }
    wm geom $w +$x+$y
    wm deiconify $w
    grab $w

    tkwait variable ::tk::Priv(button)
    set result [$w.entry get]
    bind $w <Destroy> {}
    grab release $w
    destroy $w
    focus -force $focus
    if {$grab != ""} {grab $grab}
    update idletasks
    return $::tk::Priv(button)
}
