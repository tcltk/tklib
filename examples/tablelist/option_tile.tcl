#==============================================================================
# Contains some Tk option database settings.
#
# Copyright (c) 2004-2006  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Get the current windowing system ("x11", "win32", or
# "aqua") and add some entries to the Tk option database
#
if {[tk windowingsystem] eq "x11"} {
    tile::setTheme alt
    option add *Font			"Helvetica -12"
}
tablelist::setThemeDefaults
if {$tile::currentTheme ne "aqua"} {
    option add *selectBackground  $tablelist::themeDefaults(-selectbackground)
    option add *selectForeground  $tablelist::themeDefaults(-selectforeground)
    option add *selectBorderWidth $tablelist::themeDefaults(-selectborderwidth)
}
option add *Tablelist.activeStyle	frame
option add *Tablelist.background	gray98
option add *Tablelist.stripeBackground	#e0e8f0
option add *Tablelist.setFocus		yes
option add *Tablelist.setGrid		yes
option add *Tablelist.movableColumns	yes
option add *Tablelist.labelCommand	tablelist::sortByColumn
option add *Tablelist.labelCommand2	tablelist::addToSortColumns
