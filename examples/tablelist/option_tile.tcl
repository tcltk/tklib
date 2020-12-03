#==============================================================================
# Contains some Tk option database settings.
#
# Copyright (c) 2004-2020  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Add some entries to the Tk option database
#
set currentTheme [tablelist::getCurrentTheme]
set isAwTheme \
    [llength [info commands ::ttk::theme::${currentTheme}::setTextColors]]
if {$currentTheme ne "aqua" && $currentTheme ne "black" && !$isAwTheme} {
    option add *Tablelist.background		white
    option add *Tablelist.stripeBackground	#f0f0f0
}
tablelist::setThemeDefaults
if {[tk windowingsystem] eq "x11"} {
    option add *Font		  TkDefaultFont
    option add *selectBackground  $tablelist::themeDefaults(-selectbackground)
    option add *selectForeground  $tablelist::themeDefaults(-selectforeground)
}
option add *selectBorderWidth	  $tablelist::themeDefaults(-selectborderwidth)
option add *Tablelist.setGrid			yes
option add *Tablelist.movableColumns		yes
option add *Tablelist.labelCommand		tablelist::sortByColumn
option add *Tablelist.labelCommand2		tablelist::addToSortColumns
if {$isAwTheme && ![regexp {^(aw)?(arc|breeze)$} $currentTheme]} {
    option add *ScrollArea.borderWidth		2
} else {
    option add *ScrollArea.borderWidth		1
}
option add *ScrollArea.relief			sunken
option add *ScrollArea.Tablelist.borderWidth	0
option add *ScrollArea.Text.borderWidth		0
option add *ScrollArea.Text.highlightThickness	0
