if {![package vsatisfies [package provide Tcl] 8.5-]} {return}
package ifneeded ntext 1.0b4 [list source [file join $dir ntext.tcl]]
