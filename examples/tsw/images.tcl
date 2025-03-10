#==============================================================================
# Creates some images.
#
# Copyright (c) 2011-2025  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Create two images, to be displayed in tablelist cells with boolean values
#
set fmt $tablelist::svgfmt
image create photo checkedImg -format $fmt -data {
<svg width="12" height="12" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x=".5" y=".5" width="11" height="11" rx="1.5" fill="#fff" stroke="#808080"/>
 <path d="m3 6 2.5 2.5 3.5-5" fill="none" stroke="#000" stroke-linecap="round" stroke-linejoin="round"/>
</svg>}
image create photo uncheckedImg -format $fmt -data {
<svg width="12" height="12" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x=".5" y=".5" width="11" height="11" rx="1.5" fill="#fff" stroke="#808080"/>
</svg>}

#
# Create 16 images representing different colors
#
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
set dim  [expr {round(12 * $scaleutil::scalingPct / 100.0)}]
set dim1 [expr {$dim - 1}]
foreach value $colorValues {
    image create photo img$value -height $dim -width $dim
    img$value put gray50 -to 0 0 $dim 1				;# top edge
    img$value put gray50 -to 0 1 1 $dim1			;# left edge
    img$value put gray75 -to 0 $dim1 $dim $dim			;# bottom edge
    img$value put gray75 -to $dim1 1 $dim $dim1			;# right edge
    img$value put $value -to 1 1 $dim1 $dim1			;# interior
}
