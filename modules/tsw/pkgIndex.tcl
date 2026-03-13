#==============================================================================
# Tsw package index file.
#   
# Copyright (c) 2025-2026  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Regular package:
# 
package ifneeded tsw 1.4.1 [list source [file join $dir tsw.tcl]]

#
# Alias:
#   
package ifneeded Tsw 1.4.1 { package require -exact tsw 1.4.1 }
