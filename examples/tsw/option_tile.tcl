#==============================================================================
# Contains some Tk option database settings.
#
# Copyright (c) 2004-2025  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Add some entries to the Tk option database
#
set currentTheme [tablelist::getCurrentTheme]
if {$tablelist::themeDefaults(-stripebackground) eq "" &&
    $currentTheme ne "black" && $currentTheme ne "breeze-dark" &&
    $currentTheme ne "sun-valley-dark"} {
    option add *Tablelist.background		white
    option add *Tablelist.stripeBackground	#f0f0f0
}
if {[tk windowingsystem] eq "x11"} {
    option add *Font		  TkDefaultFont
    option add *selectBackground  $tablelist::themeDefaults(-selectbackground)
    option add *selectForeground  $tablelist::themeDefaults(-selectforeground)
}
option add *selectBorderWidth	  $tablelist::themeDefaults(-selectborderwidth)
option add *Tablelist.movableColumns		yes
option add *Tablelist.labelCommand		tablelist::sortByColumn
option add *Tablelist.labelCommand2		tablelist::addToSortColumns
