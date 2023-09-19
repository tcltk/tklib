if {![package vsatisfies [package provide Tcl] 8.5-]} {return}
package ifneeded ntext 1.0b6 [list source [file join $dir ntext.tcl]]
