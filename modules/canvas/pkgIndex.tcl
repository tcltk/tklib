if {![package vsatisfies [package provide Tcl] 8.4]} {return}
package ifneeded canvas::sqmap 0.2 [list source [file join $dir canvas_sqmap.tcl]]
package ifneeded canvas::zoom  0.1 [list source [file join $dir canvas_zoom.tcl]]
if {![package vsatisfies [package provide Tcl] 8.5]} { return }
package ifneeded canvas::snap 1.0.1 [list source [file join $dir canvas_snap.tcl]]
