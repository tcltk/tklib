#==============================================================================
# Main Scrollutil package module.
#
# Copyright (c) 2019  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require -exact scrollutil::common 1.2

package provide scrollutil $::scrollutil::version
package provide Scrollutil $::scrollutil::version

::scrollutil::useTile 0
::scrollutil::sa::createBindings
::scrollutil::ss::createBindings
::scrollutil::sf::createBindings
