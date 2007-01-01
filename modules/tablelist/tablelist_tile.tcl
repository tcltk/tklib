#==============================================================================
# Main Tablelist_tile package module.
#
# Copyright (c) 2000-2007  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require Tcl  8.4
package require Tk   8.4
if {$::tk_version < 8.5 || [regexp {^8\.5a[1-5]$} $::tk_patchLevel]} {
    package require tile 0.6
}
package require tablelist::common

package provide Tablelist_tile 4.6
package provide tablelist_tile 4.6

::tablelist::useTile 1

#
# Define some aliases
#
if {[info commands ::ttk::style] ne ""} {
    interp alias {} ::tablelist::getThemes {} ::ttk::themes
    interp alias {} ::tablelist::setTheme  {} ::ttk::setTheme

    interp alias {} ::tablelist::tileqt_currentThemeName \
		 {} ::ttk::theme::tileqt::currentThemeName
    interp alias {} ::tablelist::tileqt_currentThemeColour \
		 {} ::ttk::theme::tileqt::currentThemeColour
} else {
    interp alias {} ::tablelist::getThemes {} ::tile::availableThemes
    interp alias {} ::tablelist::setTheme  {} ::tile::setTheme

    interp alias {} ::tablelist::tileqt_currentThemeName \
		 {} ::tile::theme::tileqt::currentThemeName
    interp alias {} ::tablelist::tileqt_currentThemeColour \
		 {} ::tile::theme::tileqt::currentThemeColour
}

namespace eval ::tablelist {
    #
    # Commands related to tile themes:
    #
    namespace export	getThemes getCurrentTheme setTheme setThemeDefaults
}
