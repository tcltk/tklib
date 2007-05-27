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
canvas .c2 -background white -width 400 -height 200
pack   .c .c2 -fill both -side top

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

set s2 [::Plotchart::createXYPlot .c2 {0.0 100.0 10.0} {0.0 100.0 20.0}]

$s2 dotconfig series1 -colour "red" -scalebyvalue 1 -scale 2.5
$s2 dotconfig series2 -colour "magenta" -classes {0 blue 1 green 2 yellow 3 red} \
    -scalebyvalue 0 -outline 0
$s2 dotconfig series3 -colour "magenta" -classes {0 blue 1 green 2 yellow 3 red} \
    -scalebyvalue 1 -scale 2.5

set y1 20
set y2 50
set y3 80
set x  10
foreach value {-1.0 0.5 1.5 2.5 3.5 4.5} {
    $s2 dot series1 $x $y1 $value
    $s2 dot series2 $x $y2 $value
    $s2 dot series3 $x $y3 $value
    set x [expr {$x + 10}]
}
