#==============================================================================
# Main Tablelist package module.
#
# Copyright (c) 2000-2026  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require -exact tablelist::common 7.10

package provide tablelist $tablelist::version
package provide Tablelist $tablelist::version

tablelist::useTile 0
tablelist::createBindings
