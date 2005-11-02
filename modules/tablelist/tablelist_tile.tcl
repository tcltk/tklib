#==============================================================================
# Main Tablelist_tile package module.
#
# Copyright (c) 2000-2005  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require Tcl  8.4
package require Tk   8.4
package require tile 0.6

package provide Tablelist_tile 4.2
package provide tablelist_tile 4.2

set tablelist::usingTile 1
trace variable tablelist::usingTile wu "tablelist::restoreUsingTile 1"

interp alias {} tk::frame {} ::frame
interp alias {} tk::label {} ::label
