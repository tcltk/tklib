# Tcl package index file, version 1.0

if {![package vsatisfies [package provide Tcl] 8.4]} {return}

package ifneeded widget::all 1.0 {
    package require widget
    package require widget::scrolledwindow
    package require widget::dialog
    package require widget::superframe
    package require widget::panelframe
    package require widget::ruler ; # includes screenruler
    package provide widget::all 1.0
}

package ifneeded widget 3.0 [list source [file join $dir widget.tcl]]

package ifneeded widget::scrolledwindow 1.0 \
    [list source [file join $dir scrollw.tcl]]

package ifneeded widget::dialog 1.2 \
    [list source [file join $dir dialog.tcl]]

package ifneeded widget::superframe 1.0 \
    [list source [file join $dir superframe.tcl]]

package ifneeded widget::panelframe 1.0 \
    [list source [file join $dir panelframe.tcl]]

package ifneeded widget::screenruler 1.1 \
    [list source [file join $dir ruler.tcl]]
package ifneeded widget::ruler 1.0 \
    [list source [file join $dir ruler.tcl]]
