# plotannot.tcl --
#    Facilities for annotating charts
#
# Note:
#    This source file contains such functions as to draw a
#    balloon text in an xy-graph.
#    It is the companion of "plotchart.tcl"
#

#
# Static data
#
namespace eval ::Plotchart {
    # Index, three pairs of scale factors to determine xy-coordinates
    set BalloonDir(north-west) {0  0  1 -2 -2  1  0}
    set BalloonDir(north)      {1 -1  0  0 -3  1  0}
    set BalloonDir(north-east) {2 -1  0  2 -2  0  1}
    set BalloonDir(east)       {3  0 -1  3  0  0  1}
    set BalloonDir(south-east) {4  0 -1  2  2 -1  0}
    set BalloonDir(south)      {5  1  0  0  3 -1  0}
    set BalloonDir(south-west) {6  1  0 -2  2  0 -1}
    set BalloonDir(west)       {7  0  1 -3  0  0 -1}
}

# DefaultBalloon --
#    Set the default properties of balloon text
# Arguments:
#    w           Name of the canvas
# Result:
#    None
# Side effects:
#    Stores the default settings
#
proc ::Plotchart::DefaultBalloon { w } {
    variable settings

    foreach {option value} {font       fixed
                            margin     5
                            textcolour black
                            justify    left
                            arrowsize  5
                            background white
                            outline    black
                            rimwidth   1} {
        set settings($w,balloon$option) $value
    }
}

# ConfigBalloon --
#    Configure the properties of balloon text
# Arguments:
#    w           Name of the canvas
#    args        List of arguments
# Result:
#    None
# Side effects:
#    Stores the new settings for the next balloon text
#
proc ::Plotchart::ConfigBalloon { w args } {
    variable settings

    foreach {option value} $args {
        set option [string range $option 1 end]
        switch -- $option {
            "font" -
            "margin" -
            "textcolour" -
            "justify" -
            "arrowsize" -
            "background" -
            "outline" -
            "rimwidth" {
                set settings($w,balloon$option) $value
            }
            "textcolor" {
                set settings($w,balloontextcolour) $value
            }
        }
    }
}

# DrawBalloon --
#    Plot a balloon text in a chart
# Arguments:
#    w           Name of the canvas
#    x           X-coordinate of the point the arrow points to
#    y           Y-coordinate of the point the arrow points to
#    text        Text in the balloon
#    dir         Direction of the arrow (north, north-east, ...)
# Result:
#    None
# Side effects:
#    Text and polygon drawn in the chart
#
proc ::Plotchart::DrawBalloon { w x y text dir } {
    variable settings
    variable BalloonDir

    #
    # Create the item and then determine the coordinates
    # of the frame around the text
    #
    set item [$w create text 0 0 -text $text -tag BalloonText \
                 -font $settings($w,balloonfont) -fill $settings($w,balloontextcolour) \
                 -justify $settings($w,balloonjustify)]

    if { ![info exists BalloonDir($dir)] } {
        set dir south-east
    }

    foreach {xmin ymin xmax ymax} [$w bbox $item] {break}

    set xmin   [expr {$xmin-$settings($w,balloonmargin)}]
    set xmax   [expr {$xmax+$settings($w,balloonmargin)}]
    set ymin   [expr {$ymin-$settings($w,balloonmargin)}]
    set ymax   [expr {$ymax+$settings($w,balloonmargin)}]

    set xcentr [expr {($xmin+$xmax)/2}]
    set ycentr [expr {($ymin+$ymax)/2}]
    set coords [list $xmin   $ymin   \
                     $xcentr $ymin   \
                     $xmax   $ymin   \
                     $xmax   $ycentr \
                     $xmax   $ymax   \
                     $xcentr $ymax   \
                     $xmin   $ymax   \
                     $xmin   $ycentr ]

    set idx    [lindex $BalloonDir($dir) 0]
    set scales [lrange $BalloonDir($dir) 1 end]

    set factor $settings($w,balloonarrowsize)
    set extraCoords {}

    set xbase  [lindex $coords [expr {2*$idx}]]
    set ybase  [lindex $coords [expr {2*$idx+1}]]

    foreach {xscale yscale} $scales {
        set xnew [expr {$xbase+$xscale*$factor}]
        set ynew [expr {$ybase+$yscale*$factor}]
        lappend extraCoords $xnew $ynew
    }

    #
    # Insert the extra coordinates
    #
    set coords [eval lreplace [list $coords] [expr {2*$idx}] [expr {2*$idx+1}] \
                          $extraCoords]

    set xpoint [lindex $coords [expr {2*$idx+2}]]
    set ypoint [lindex $coords [expr {2*$idx+3}]]

    set poly [$w create polygon $coords -tag BalloonFrame \
                  -fill $settings($w,balloonbackground) \
                  -width $settings($w,balloonrimwidth)  \
                  -outline $settings($w,balloonoutline)]

    #
    # Position the two items
    #
    foreach {xtarget ytarget} [coordsToPixel $w $x $y] {break}
    set dx [expr {$xtarget-$xpoint}]
    set dy [expr {$ytarget-$ypoint}]
    $w move $item  $dx $dy
    $w move $poly  $dx $dy
    $w raise BalloonFrame
    $w raise BalloonText
}
