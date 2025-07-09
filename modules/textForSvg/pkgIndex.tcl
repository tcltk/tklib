if {![package vsatisfies [package provide Tcl] 8.6-]} {return}
package ifneeded textForSvg 1.0b1 [list source [file join $dir textForSvg.tcl]]
