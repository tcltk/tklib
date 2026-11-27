#==============================================================================
# Scrollutil and Scrollutil_tile package index file.
#
# Copyright (c) 2019-2026  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Regular packages:
#
package ifneeded scrollutil         2.12 \
	[list source [file join $dir scrollutil.tcl]]
package ifneeded scrollutil_tile    2.12 \
	[list source [file join $dir scrollutil_tile.tcl]]

#
# Aliases:
#
package ifneeded Scrollutil         2.12 \
	[list package require -exact scrollutil      2.12]
package ifneeded Scrollutil_tile    2.12 \
	[list package require -exact scrollutil_tile 2.12]

#
# Code common to all packages:
#
package ifneeded scrollutil::common 2.12 \
	[list source [file join $dir scrollutilCommon.tcl]]
