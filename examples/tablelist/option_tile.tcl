#==============================================================================
# Contains some Tk option database settings.
#
# Copyright (c) 2004-2005  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Get the current windowing system ("x11", "win32", or
# "aqua") and add some entries to the Tk option database
#
if {[tk windowingsystem] eq "x11"} {
    option add *Font			"Helvetica -12"
    option add *selectBackground	#447bcd
    option add *selectForeground	white

    tile::setTheme alt
}
option add *Tablelist.activeStyle	frame
option add *Tablelist.background	gray98
option add *Tablelist.stripeBackground	#e0e8f0
option add *Tablelist.setGrid		yes
option add *Tablelist.movableColumns	yes
option add *Tablelist.labelCommand	tablelist::sortByColumn
