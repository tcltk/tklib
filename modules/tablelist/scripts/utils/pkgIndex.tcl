#==============================================================================
# mwutil, scaleutil, scaleutilmisc, themepatch, and wsb package index file.
#
# Copyright (c) 2020-2026  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package ifneeded mwutil     2.25 [list source [file join $dir mwutil.tcl]]
package ifneeded scaleutil  1.17 [list source [file join $dir scaleutil.tcl]]
package ifneeded scaleutilmisc 1.8 \
	[list source [file join $dir scaleutilMisc.tcl]]
package ifneeded themepatch 1.10 [list source [file join $dir themepatch.tcl]]

if {$::tk_version < 9 || [package vcompare [package require Tk] "9.1a1"] < 0} {
    package ifneeded wsb 1.2 [list source [file join $dir wsb.tcl]]
} else {
    package ifneeded wsb 1.2 {
	# No-op, because Tk 9.1a1+ has built-in Wide.TSpinbox layout support
	package provide wsb 1.2
    }
}
