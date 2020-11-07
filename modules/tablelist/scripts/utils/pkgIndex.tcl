#==============================================================================
# mwutil and scaleutil package index file.
#
# Copyright (c) 2020  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package ifneeded mwutil    2.17 [list source [file join $dir mwutil.tcl]]
package ifneeded scaleutil 1.1 "
    source [list [file join $dir scaleutil.tcl]]
    source [list [file join $dir scaleutilMisc.tcl]]
"
