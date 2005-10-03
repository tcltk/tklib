#==============================================================================
# Tablelist and Tablelist_tile package index file.
#
# Copyright (c) 2000-2005  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

if {[string compare $::tcl_platform(platform) "macintosh"] == 0} {
    #
    # We need to do this here instead of in tablelist.tcl, because of
    # a bug in [info script] in some Tcl releases for the Macintosh.
    #
    namespace eval tablelist {}
    set tablelist::library $dir
}

foreach package {Tablelist tablelist} {
    package ifneeded $package 4.2 "
	[list source [file join $dir tablelistPublic.tcl]]
	[list source [file join $dir tablelist.tcl]]
    "
}

foreach package {Tablelist_tile tablelist_tile} {
    package ifneeded $package 4.2 "
	[list source [file join $dir tablelistPublic.tcl]]
	[list source [file join $dir tablelist_tile.tcl]]
    "
}
