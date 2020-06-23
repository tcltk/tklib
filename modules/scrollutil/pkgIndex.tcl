#==============================================================================
# Scrollutil and Scrollutil_tile package index file.
#
# Copyright (c) 2019-2020  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Regular packages:
#
package ifneeded scrollutil         1.6 \
	[list source [file join $dir scrollutil.tcl]]
package ifneeded scrollutil_tile    1.6 \
	[list source [file join $dir scrollutil_tile.tcl]]

#
# Aliases:
#
package ifneeded Scrollutil         1.6 \
	[list package require -exact scrollutil      1.6]
package ifneeded Scrollutil_tile    1.6 \
	[list package require -exact scrollutil_tile 1.6]

#
# Code common to all packages:
#
package ifneeded scrollutil::common 1.6 \
	[list source [file join $dir scrollutilCommon.tcl]]
