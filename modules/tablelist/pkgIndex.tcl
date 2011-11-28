#==============================================================================
# Tablelist and Tablelist_tile package index file.
#
# Copyright (c) 2000-2011  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Regular packages:
#
package ifneeded tablelist         5.5 \
	[list source [file join $dir tablelist.tcl]]
package ifneeded tablelist_tile    5.5 \
	[list source [file join $dir tablelist_tile.tcl]]

#
# Aliases:
#
package ifneeded Tablelist         5.5 \
	[list package require -exact tablelist	    5.5]
package ifneeded Tablelist_tile    5.5 \
	[list package require -exact tablelist_tile 5.5]

#
# Code common to all packages:
#
package ifneeded tablelist::common 5.5 \
        "namespace eval ::tablelist { proc DIR {} {return [list $dir]} } ;\
	 source [list [file join $dir tablelistPublic.tcl]]"
