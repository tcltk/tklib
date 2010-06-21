if {![package vsatisfies [package provide Tcl] 8.4]} {
    # PRAGMA: returnok
    return
}
package ifneeded Plotchart 1.9.0 [list source [file join $dir plotchart.tcl]]
package ifneeded xyplot    1.0.1 [list source [file join $dir xyplot.tcl]]
