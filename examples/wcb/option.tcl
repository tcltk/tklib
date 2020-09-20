#==============================================================================
# Contains some Tk option database settings.
#
# Copyright (c) 2010-2020  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
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
	#
	# Create the fonts TkDefaultFont and TkFixedFont if not yet present
	#
	catch {font create TkDefaultFont -family Helvetica -size 9}
	catch {font create TkFixedFont -family Courier -size 9}

	option add *Font		TkDefaultFont
	option add *selectBackground	#5294e2
	option add *selectForeground	white
    }
    classic {
	option add *background		#dedede
    }
}
