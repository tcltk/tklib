#! /bin/sh
# -*- tcl -*- \
exec tclsh "$0" ${1+"$@"}

package require Tcl 8.3
package require Tk
source ../../modules/plotchart/plotchart.tcl
package require Plotchart


# plotdemo8.tcl --
#     Demonstration of a boxplot
#
pack [canvas .c] -fill both

set p [::Plotchart::createBoxplot .c {0 40 5} {A B C D E F}]

$p plot A {0 1 2 5 7 1 4 5 0.6 5 5.5}
$p plot C {2 2 3 6 1.5 3}

$p plot E {2 3 3 4 7 8 9 9 10 10 11 11 11 14 15 17 17 20 24 29}
