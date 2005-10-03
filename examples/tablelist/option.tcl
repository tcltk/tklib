#==============================================================================
# Contains some Tk option database settings.
#
# Copyright (c) 2004-2005  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Get the current windowing system ("x11", "win32", "classic", or "aqua")
#
if {[catch {tk windowingsystem} winSys] != 0} {
    switch $::tcl_platform(platform) {
	unix      { set winSys x11 }
	windows   { set winSys win32 }
	macintosh { set winSys classic }
    }
}

#
# Add some entries to the Tk option database
#
switch $winSys {
    x11 {
	option add *Font		"Helvetica -12"
	option add *selectBackground	#447bcd
	option add *selectForeground	white
    }
    classic {
	option add *background		#dedede
    }
}
option add *Tablelist.activeStyle	frame
option add *Tablelist.background	gray98
option add *Tablelist.stripeBackground	#e0e8f0
option add *Tablelist.setGrid		yes
option add *Tablelist.movableColumns	yes
option add *Tablelist.labelCommand	tablelist::sortByColumn
