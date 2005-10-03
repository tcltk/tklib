#==============================================================================
# Main Tablelist_tile package module.
#
# Copyright (c) 2000-2005  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require Tcl  8.4
package require Tk   8.4
package require tile 0.6

package provide Tablelist_tile $tablelist::version
package provide tablelist_tile $tablelist::version

set tablelist::usingTile 1
trace variable tablelist::usingTile wu "tablelist::restoreUsingTile 1"

#
# The following statements might no longer be needed for tile versions > 0.6:
#
interp alias {} tk::frame {} ::frame
interp alias {} tk::label {} ::label
