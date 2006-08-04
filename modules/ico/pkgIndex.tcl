# pkgIndex.tcl --
#
# Copyright (c) 2003 ActiveState Corporation.
# All rights reserved.
#
# RCS: @(#) $Id: pkgIndex.tcl,v 1.4 2006/08/04 16:37:13 hobbs Exp $

package ifneeded ico 0.3 [list source [file join $dir ico0.tcl]]
package ifneeded ico 1.0 [list source [file join $dir ico.tcl]]
