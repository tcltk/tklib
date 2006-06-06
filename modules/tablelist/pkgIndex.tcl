#==============================================================================
# Tablelist and Tablelist_tile package index file.
#
# Copyright (c) 2000-2006  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package ifneeded Tablelist      4.4 "namespace eval ::tablelist {proc DIR {} {return [list $dir]}} ; [list source [file join $dir tablelist.tcl]]"
package ifneeded tablelist      4.4 "namespace eval ::tablelist {proc DIR {} {return [list $dir]}} ; [list source [file join $dir tablelist.tcl]]"
package ifneeded Tablelist_tile 4.4 "namespace eval ::tablelist {proc DIR {} {return [list $dir]}} ; [list source [file join $dir tablelist_tile.tcl]]"
package ifneeded tablelist_tile 4.4 "namespace eval ::tablelist {proc DIR {} {return [list $dir]}} ; [list source [file join $dir tablelist_tile.tcl]]"
