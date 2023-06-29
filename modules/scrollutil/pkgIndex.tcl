#==============================================================================
# Scrollutil and Scrollutil_tile package index file.
#
# Copyright (c) 2019-2023  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Regular packages:
#
package ifneeded scrollutil         1.19 \
	[list source [file join $dir scrollutil.tcl]]
package ifneeded scrollutil_tile    1.19 \
	[list source [file join $dir scrollutil_tile.tcl]]

#
# Aliases:
#
package ifneeded Scrollutil         1.19 \
	[list package require -exact scrollutil      1.19]
package ifneeded Scrollutil_tile    1.19 \
	[list package require -exact scrollutil_tile 1.19]

#
# Code common to all packages:
#
package ifneeded scrollutil::common 1.19 \
	[list source [file join $dir scrollutilCommon.tcl]]
