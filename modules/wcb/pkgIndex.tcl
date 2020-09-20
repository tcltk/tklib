#==============================================================================
# Wcb package index file.
#
# Copyright (c) 1999-2020  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Regular package:
#
package ifneeded wcb 3.7 [list source [file join $dir wcb.tcl]]

#
# Alias:
#
package ifneeded Wcb 3.7 { package require -exact wcb 3.7 }
