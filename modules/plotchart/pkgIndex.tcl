if {![package vsatisfies [package provide Tcl] 8.3]} {
    # PRAGMA: returnok
    return
}
package ifneeded Plotchart 1.1 [list source [file join $dir plotchart.tcl]]
