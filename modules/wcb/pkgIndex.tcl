#==============================================================================
# Wcb package index file.
#
# Copyright (c) 1999-2023  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Regular package:
#
package ifneeded wcb 4.0 [list source [file join $dir wcb.tcl]]

#
# Alias:
#
package ifneeded Wcb 4.0 { package require -exact wcb 4.0 }
