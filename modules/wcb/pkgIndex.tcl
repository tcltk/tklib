#==============================================================================
# Wcb package index file.
#
# Copyright (c) 1999-2014  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Regular package:
#
package ifneeded wcb 3.5 [list source [file join $dir wcb.tcl]]

#
# Alias:
#
package ifneeded Wcb 3.5 { package require -exact wcb 3.5 }
