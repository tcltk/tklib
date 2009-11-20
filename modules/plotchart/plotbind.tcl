# plotbind.tcl --
#     Facilities for interaction with the plot, via event bindings
#
# Note:
#     This source contains private functions only.
#     It accompanies "plotchart.tcl"
#

# BindPlot --
#     Bind an event to the entire plot area
#
# Arguments:
#     w               Widget
#     event           Type of event
#     cmd             Command to execute
#
# Result:
#     None
#
proc ::Plotchart::BindPlot {w event cmd} {
    variable scaling

    if { $scaling($w,eventobj) == "" } {

        set pxmin $scaling($w,pxmin)
        set pxmax $scaling($w,pxmax)
        set pymin $scaling($w,pymin)
        set pymax $scaling($w,pymax)

        set scaling($w,eventobj) [$w create rectangle $pxmin $pymin $pxmax $pymax -fill {} -outline {}]
    }
    $w lower $scaling($w,eventobj)

    $w bind $scaling($w,eventobj) $event [list ::Plotchart::BindCmd %x %y $w $cmd]

}

# BindLast --
#     Bind an event to the last data point of a data series
#
# Arguments:
#     w               Widget
#     series          Data series in question
#     event           Type of event
#     cmd             Command to execute
#
# Result:
#     None
#
proc ::Plotchart::BindLast {w series event cmd} {
    variable data_series

    foreach {x y} [coordsToPixel $w $data_series($w,$series,x) $data_series($w,$series,y)] {break}

    set pxmin [expr {$x-5}]
    set pxmax [expr {$x+5}]
    set pymin [expr {$y-5}]
    set pymax [expr {$y+5}]

    set object [$w create rectangle $pxmin $pymin $pxmax $pymax -fill {} -outline {}]

    $w bind $object $event \
        [list ::Plotchart::BindCmd $x $y $w $cmd]



    console show
    puts "Bindings: $object -- [$w bind $object]"
}

# BindCmd --
#     Call the command that is bound to the event
#
# Arguments:
#     xcoord          X coordinate of event
#     ycoord          Y coordinate of event
#     w               Canvas widget
#     cmd             Command to execute
#
# Result:
#     None
#
proc ::Plotchart::BindCmd {xcoord ycoord w cmd} {
    variable scaling

    foreach {x y} [pixelToCoords $w $xcoord $ycoord] {break}

    eval [lindex $cmd 0] $x $y [lrange $cmd 1 end]

}

if {0} {

-- this represents an old idea. Keeping it around for the moment --

# BindVar --
#     Bind a variable to a mouse event
#
# Arguments:
#     w               Widget
#     event           Type of event
#     varname         Name of a global variable
#     text            Text containing %x and %y to set the variable to
#
# Result:
#     None
#
# Note:
#     This procedure makes it easy to build a label widget showing
#     the current position of the mouse in the plot's coordinate
#     system for instance.
#
proc ::Plotchart::BindVar {w event varname text} {

    BindCmd $w $event [list ::Plotchart::SetText $w "%x %y" $varname \
        [string map {% @} $text]]

}

# BindCmd --
#     Bind a command to a mouse event
#
# Arguments:
#     w               Widget
#     event           Type of event
#     cmd             Command to be run
#
# Result:
#     None
#
# Note:
#     This procedure makes it easy to define interactive plots
#     But it defines bindings for the whole canvas window, not the
#     individual items. -- TODO --
#
proc ::Plotchart::BindCmd {w event cmd} {
    switch -- $event {
        "mouse"  { set b "<Motion>" }
        "button" { set b "<ButtonPress-1>" }
        default  { return -code error "Unknown event type $event" }
    }

    bind $w $b $cmd
}

# SetText --
#     Substitute the coordinates in the given text
#
# Arguments:
#     w               Widget
#     coords          Current coordinates
#     varname         Name of a global variable
#     text            Text containing %x and %y to set the variable to
#
# Result:
#     None
#
# Side effects:
#     The text is assigned to the variable after making the
#     various substitutions
#
proc ::Plotchart::SetText {w coords varname text} {
    upvar #0 $varname V

    foreach {x y} [pixelToCoords $w [lindex $coords 0] [lindex $coords 1]] {break}

    set V [string map [list @x $x @y $y] $text]
}

--- end of old code ---
}
