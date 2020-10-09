#==============================================================================
# Creates some images.
#
# Copyright (c) 2011-2020  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Create two images, to be displayed in tablelist cells with boolean values
#
set pct $tablelist::scalingpct
image create photo checkedImg   -file [file join $dir checked$pct.gif]
image create photo uncheckedImg -file [file join $dir unchecked$pct.gif]

#
# Create 16 images representing different colors
#
# Declare the variables as global because this
# file might be sourced from within a procedure
#
global colorNames colorValues colors
set colorNames {
    "red" "green" "blue" "magenta"
    "yellow" "cyan" "light gray" "white"
    "dark red" "dark green" "dark blue" "dark magenta"
    "dark yellow" "dark cyan" "dark gray" "black"
}
set colorValues {
    #FF0000 #00FF00 #0000FF #FF00FF
    #FFFF00 #00FFFF #C0C0C0 #FFFFFF
    #800000 #008000 #000080 #800080
    #808000 #008080 #808080 #000000
}
foreach name $colorNames value $colorValues {
    set colors($name) $value
}
array set arr {100 13  125 16  150 20  175 23  200 26}
set len $arr($pct)
set len1 [expr {$len - 1}]
foreach value $colorValues {
    image create photo img$value -height $len -width $len
    img$value put gray50 -to 0 0 $len 1				;# top edge
    img$value put gray50 -to 0 1 1 $len1			;# left edge
    img$value put gray75 -to 0 $len1 $len $len			;# bottom edge
    img$value put gray75 -to $len1 1 $len $len1			;# right edge
    img$value put $value -to 1 1 $len1 $len1			;# interior
}
