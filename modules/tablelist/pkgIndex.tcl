#==============================================================================
# Tablelist and Tablelist_tile package index file.
#
# Copyright (c) 2000-2005  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

namespace eval ::tablelist {}

proc ::tablelist::Load {dir} {
    if {[string compare $::tcl_platform(platform) "macintosh"] == 0} {
	#
	# We need to do this here instead of in tablelistPublic.tcl,
	# because of a bug in [info script] in some Tcl releases for
	# the Macintosh.
	#
	variable library $dir
    }

    uplevel #0 [list source [file join $dir tablelistPublic.tcl]]
    uplevel #0 [list source [file join $dir tablelist.tcl]]
    rename ::tablelist::Load {}
}

proc ::tablelist::LoadTile {dir} {
    if {[string compare $::tcl_platform(platform) "macintosh"] == 0} {
	#
	# We need to do this here instead of in tablelistPublic.tcl,
	# because of a bug in [info script] in some Tcl releases for
	# the Macintosh.
	#
	variable library $dir
    }

    uplevel #0 [list source [file join $dir tablelistPublic.tcl]]
    uplevel #0 [list source [file join $dir tablelist_tile.tcl]]
    rename ::tablelist::LoadTile {}
}

package ifneeded Tablelist      4.2 [list ::tablelist::Load     $dir]
package ifneeded tablelist      4.2 [list ::tablelist::Load     $dir]
package ifneeded Tablelist_tile 4.2 [list ::tablelist::LoadTile $dir]
package ifneeded tablelist_tile 4.2 [list ::tablelist::LoadTile $dir]
