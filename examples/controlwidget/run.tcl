#! /bin/sh
# -*- tcl -*- \
exec tclsh "$0" ${1+"$@"}

package require Tk

# run.tcl --
#     Auxiliary script to run the examples
#
set dir ../../modules/controlwidget
source $dir/pkgIndex.tcl

source [lindex $argv 0]
