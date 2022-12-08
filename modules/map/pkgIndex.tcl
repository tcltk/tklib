if {![package vsatisfies [package provide Tcl] 8.6]} { return }
#
package ifneeded map::box::display       0.1   [list source [file join $dir box-display.tcl]]
package ifneeded map::box::entry         0.1   [list source [file join $dir box-entry.tcl]]
package ifneeded map::box::map-display   0.1   [list source [file join $dir box-map-display.tcl]]
package ifneeded map::box::store::fs     0.1   [list source [file join $dir box-store-fs.tcl]]
package ifneeded map::box::store::memory 0.1   [list source [file join $dir box-store-mem.tcl]]
package ifneeded map::box::table-display 0.1   [list source [file join $dir box-table-display.tcl]]
package ifneeded map::display            0.1   [list source [file join $dir display.tcl]]
package ifneeded map::mark               0.1   [list source [file join $dir mark.tcl]]
package ifneeded map::provider::osm      0.1   [list source [file join $dir provider-osm.tcl]]
#
return
