#==============================================================================
# Main Scrollutil package module.
#
# Copyright (c) 2019-2024  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require Tk 8.4-
package require -exact scrollutil::common 2.2

package provide scrollutil $::scrollutil::version
package provide Scrollutil $::scrollutil::version

::scrollutil::useTile 0

::scrollutil::sa::createBindings
::scrollutil::ss::createBindings
::scrollutil::sf::createBindings
::scrollutil::pm::createBindings
::scrollutil::createBindings
