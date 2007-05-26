#! /bin/sh
# -*- tcl -*- \
exec tclsh "$0" ${1+"$@"}

package require Tcl 8.3
package require Tk
source ../../modules/plotchart/plotchart.tcl
package require Plotchart

# testplot.tcl --
#    Test program for the Plotchart package
#

#
# Main code
# Note:
# The extremes and the canvas sizes are chosen so that the
# coordinate mapping is isometric!
#
#
canvas .c  -background white -width 400 -height 400
pack   .c -fill both -side top

set s [::Plotchart::createXYPlot .c {0.0 100.0 10.0} {0.0 100.0 20.0}]

$s vectorconfig series1 -colour "red"   -scale 40
$s vectorconfig series2 -colour "blue"  -scale 50 -type nautical -centred 1

#
# Cartesian
#
set data {1.0 0.0 0.0 1.0 0.5 0.5 -2.0 1.0}

set x 30.0
set y 20.0
foreach {u v} $data {
   $s vector series1 $x $y $u $v
}

#
# Nautical
#
set data {1.0 0.0 1.0 45.0 2.0 90.0}

set x 60.0
set y 40.0
foreach {length angle} $data {
   $s vector series2 $x $y $length $angle
}

