#==============================================================================
# Tsw package index file.
#   
# Copyright (c) 2025  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Regular package:
# 
package ifneeded tsw 1.2 [list source [file join $dir tsw.tcl]]

#
# Alias:
#   
package ifneeded Tsw 1.2 { package require -exact tsw 1.2 }
