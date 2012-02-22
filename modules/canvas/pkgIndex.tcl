if {![package vsatisfies [package provide Tcl] 8.4]} {return}
package ifneeded canvas::sqmap 0.3.1 [list source [file join $dir canvas_sqmap.tcl]]
package ifneeded canvas::zoom  0.2.1 [list source [file join $dir canvas_zoom.tcl]]
if {![package vsatisfies [package provide Tcl] 8.5]} { return }
package ifneeded canvas::snap         1.0.1 [list source [file join $dir canvas_snap.tcl]]
package ifneeded canvas::mvg          1     [list source [file join $dir canvas_mvg.tcl]]
package ifneeded canvas::tag          0.1   [list source [file join $dir canvas_tags.tcl]]
package ifneeded canvas::drag         0.1   [list source [file join $dir canvas_drag.tcl]]
package ifneeded canvas::highlight    0.1   [list source [file join $dir canvas_highlight.tcl]]
package ifneeded canvas::edit::points 0.1   [list source [file join $dir canvas_epoints.tcl]]
