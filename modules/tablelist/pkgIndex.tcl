#==============================================================================
# Tablelist and Tablelist_tile package index file.
#
# Copyright (c) 2000-2021  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Regular packages:
#
package ifneeded tablelist         6.15 \
	[list source [file join $dir tablelist.tcl]]
package ifneeded tablelist_tile    6.15 \
	[list source [file join $dir tablelist_tile.tcl]]

#
# Aliases:
#
package ifneeded Tablelist         6.15 \
	[list package require -exact tablelist	    6.15]
package ifneeded Tablelist_tile    6.15 \
	[list package require -exact tablelist_tile 6.15]

#
# Code common to all packages:
#
package ifneeded tablelist::common 6.15 \
	[list source [file join $dir tablelistCommon.tcl]]
