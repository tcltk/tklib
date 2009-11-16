# plotbind.tcl --
#     Facilities for interaction with the plot, via event bindings
#
# Note:
#     This source contains private functions only.
#     It accompanies "plotchart.tcl"
#

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

