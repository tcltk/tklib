#==============================================================================
# Tablelist and Tablelist_tile package index file.
#
# Copyright (c) 2000-2022  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Regular packages:
#
package ifneeded tablelist         6.19 \
	[list source [file join $dir tablelist.tcl]]
package ifneeded tablelist_tile    6.19 \
	[list source [file join $dir tablelist_tile.tcl]]

#
# Aliases:
#
package ifneeded Tablelist         6.19 \
	[list package require -exact tablelist	    6.19]
package ifneeded Tablelist_tile    6.19 \
	[list package require -exact tablelist_tile 6.19]

#
# Code common to all packages:
#
package ifneeded tablelist::common 6.19 \
	[list source [file join $dir tablelistCommon.tcl]]
