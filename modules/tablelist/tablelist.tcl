#==============================================================================
# Main Tablelist package module.
#
# Copyright (c) 2000-2006  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require Tcl 8
package require Tk  8

package provide Tablelist 4.3.1
package provide tablelist 4.3.1

set tablelist::usingTile 0
trace variable tablelist::usingTile wu "tablelist::restoreUsingTile 0"

interp alias {} tk::frame {} ::frame
interp alias {} tk::label {} ::label
