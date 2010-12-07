#==============================================================================
# Wcb package index file.
#
# Copyright (c) 1999-2010  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Regular package:
#
package ifneeded wcb 3.3 \
	"namespace eval ::wcb { proc DIR {} {return [list $dir]} } ;\
	 source [list [file join $dir wcb.tcl]]"

#
# Alias:
#
package ifneeded Wcb 3.3 { package require -exact wcb 3.3 }
