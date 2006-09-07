# Tcl package index file, version 1.0

if {![package vsatisfies [package provide Tcl] 8.4]} {return}

namespace eval ::widget {}
proc ::widget::pkgindex {dir} {
    set allpkgs [list]
    # Keep alphabetical for sanity
    foreach {pkg ver file} {
	widget			3.0	widget.tcl
	widget::dialog		1.2	dialog.tcl
	widget::menuentry	1.0	mentry.tcl
	widget::panelframe	1.0	panelframe.tcl
	widget::ruler		1.0	ruler.tcl
	widget::screenruler	1.1	ruler.tcl
	widget::scrolledwindow	1.1	scrollw.tcl
	widget::statusbar	1.1	statusbar.tcl
	widget::superframe	1.0	superframe.tcl
	widget::toolbar		1.0	toolbar.tcl
    } {
	lappend allpkgs [list package require $pkg $ver]
	package ifneeded $pkg $ver [list source [file join $dir $file]]
    }
    lappend allpkgs {package provide widget::all 1.1}
    package ifneeded widget::all 1.1 [join $allpkgs \n]
}
::widget::pkgindex $dir
