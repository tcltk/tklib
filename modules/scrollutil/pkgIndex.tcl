#==============================================================================
# Scrollutil and Scrollutil_tile package index file.
#
# Copyright (c) 2019-2023  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Regular packages:
#
package ifneeded scrollutil         2.0 \
	[list source [file join $dir scrollutil.tcl]]
package ifneeded scrollutil_tile    2.0 \
	[list source [file join $dir scrollutil_tile.tcl]]

#
# Aliases:
#
package ifneeded Scrollutil         2.0 \
	[list package require -exact scrollutil      2.0]
package ifneeded Scrollutil_tile    2.0 \
	[list package require -exact scrollutil_tile 2.0]

#
# Code common to all packages:
#
package ifneeded scrollutil::common 2.0 \
	[list source [file join $dir scrollutilCommon.tcl]]
