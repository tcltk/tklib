#==============================================================================
# Main Tablelist package module.
#
# Copyright (c) 2000-2025  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require -exact tablelist::common 7.5

package provide tablelist $tablelist::version
package provide Tablelist $tablelist::version

tablelist::useTile 0
tablelist::createBindings
