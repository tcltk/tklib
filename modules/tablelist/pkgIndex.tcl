#==============================================================================
# Tablelist and Tablelist_tile package index file.
#
# Copyright (c) 2000-2025  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Regular packages:
#
package ifneeded tablelist         7.5 \
	[list source [file join $dir tablelist.tcl]]
package ifneeded tablelist_tile    7.5 \
	[list source [file join $dir tablelist_tile.tcl]]

#
# Aliases:
#
package ifneeded Tablelist         7.5 \
	[list package require -exact tablelist	    7.5]
package ifneeded Tablelist_tile    7.5 \
	[list package require -exact tablelist_tile 7.5]

#
# Code common to all packages:
#
package ifneeded tablelist::common 7.5 \
	[list source [file join $dir tablelistCommon.tcl]]
