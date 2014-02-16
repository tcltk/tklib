#==============================================================================
# Mentry and Mentry_tile package index file.
#
# Copyright (c) 1999-2014  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Regular packages:
#
package ifneeded mentry         3.7 \
	[list source [file join $dir mentry.tcl]]
package ifneeded mentry_tile    3.7 \
	[list source [file join $dir mentry_tile.tcl]]

#
# Aliases:
#
package ifneeded Mentry         3.7 \
	[list package require -exact mentry      3.7]
package ifneeded Mentry_tile    3.7 \
	[list package require -exact mentry_tile 3.7]

#
# Code common to all packages:
#
package ifneeded mentry::common 3.7 \
	"namespace eval ::mentry { proc DIR {} {return [list $dir]} } ;\
	 source [list [file join $dir mentryPublic.tcl]]"
