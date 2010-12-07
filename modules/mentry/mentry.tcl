#==============================================================================
# Main Mentry package module.
#
# Copyright (c) 1999-2010  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require -exact mentry::common 3.4

package provide Mentry $::mentry::version
package provide mentry $::mentry::version

::mentry::useTile 0
::mentry::createBindings
