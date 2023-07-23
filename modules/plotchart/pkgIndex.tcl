if {![package vsatisfies [package provide Tcl] 8.5 9]} {
    # PRAGMA: returnok
    return
}
package ifneeded Plotchart 2.6.0 [list source [file join $dir plotchart.tcl]]
package ifneeded xyplot    1.0.1 [list source [file join $dir xyplot.tcl]]
package ifneeded plotanim    0.2 [list source [file join $dir plotanim.tcl]]
