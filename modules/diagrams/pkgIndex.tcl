if {![package vsatisfies [package provide Tcl] 8.3]} {
    # PRAGMA: returnok
    return
}
package ifneeded Diagrams 0.3 [list source [file join $dir draw_diagram.tcl]]
