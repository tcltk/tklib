#==============================================================================
# mwutil, scaleutil, scaleutilmisc, themepatch, and wsb package index file.
#
# Copyright (c) 2020-2025  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package ifneeded mwutil     2.25 [list source [file join $dir mwutil.tcl]]
package ifneeded scaleutil  1.15 [list source [file join $dir scaleutil.tcl]]
package ifneeded themepatch 1.10 [list source [file join $dir themepatch.tcl]]
package ifneeded wsb	    1.1  [format {
    if {$tcl_version < 9 ||
	[package vcompare [package require Tk] "9.1a1"] < 0} {
	source [file join %s wsb.tcl]
    } else {
	# No-op, because Tk 9.1a1+ has built-in Wide.TSpinbox layout support
	package provide wsb 1.1
    }
} $dir]
package ifneeded scaleutilmisc 1.8 \
	[list source [file join $dir scaleutilMisc.tcl]]
