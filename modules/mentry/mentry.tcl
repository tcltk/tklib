#==============================================================================
# Main Mentry package module.
#
# Copyright (c) 1999-2012  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require -exact mentry::common 3.6

package provide Mentry $::mentry::version
package provide mentry $::mentry::version

::mentry::useTile 0
::mentry::createBindings
