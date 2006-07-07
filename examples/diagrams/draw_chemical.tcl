    # draw_diagram.tcl
    #    A toy derived from "PIC" by B. Kernighan to draw diagrams
    #
    # TODO:
    #    - Make each item as "self-supporting" as possible (include
    #      the coordinates of the anchor points)
    #    - Creation routines should put it in a known place and then
    #      use a generic routine to move them to the right position
    #    - Routines to:
    #      - Set the various options
    #      - Re-initialise a page
    #      - Collect the height and width of text (for objects that
    #        have several text strings possibly in different fonts)

    namespace eval ::Diagrams {
        variable state
        variable anchors
        variable dirinfo
        variable torad [expr {3.1415926/180.0}]

        namespace export box arrow currentpos getpos direction \
                         drawin saveps line position plaintext

        array set state {
            attach         "northwest"
            canvas         ""
            colour         "black"
            default_dir    "east"
            dir            "init"
            font           "Helvetica 12"
            justify        center
            default_width  "fitting"
            default_height 20
            xdir           1
            ydir           0
            xshift         0
            yshift         0
            xcurr          10
            ycurr          10
            xgap           10
            ygap           10
            scale          {1.0}
            xprev          10
            yprev          10
            lastitem       {}
            usegap         1
        }
        set anchors(X) {south xns north xns west x1 east x2
                        S     xns N     xns W    x1 E    x2
                        southeast x2 northeast x2
                        SE        x2 NE        x2
                        southwest x1 northwest x1
                        SW        x1 NW        x1
                        centre xns   center xns C xns}
        set anchors(Y) {south y2  north y1 west yew east yew
                        S     y2  N     y1 W    yew E    yew
                        southeast y2 northeast y1
                        SE        y2 NE        y1
                        southwest y2 northwest y1
                        SW        y2 NW        y1
                        centre yew   center yew C yew}

        # Name of direction, xdir, ydir, default attachment
        set dirinfo(south)      {south  0  1 north}
        set dirinfo(north)      {north  0 -1 south}
        set dirinfo(west)       {west  -1  0 east}
        set dirinfo(east)       {east   1  0 west}
        set dirinfo(southwest)  {southwest  -1  1 north}
        set dirinfo(northwest)  {northwest  -1 -1 south}
        set dirinfo(southeast)  {southeast   1  1 north}
        set dirinfo(northeast)  {northeast   1 -1 south}
        set dirinfo(down)       $dirinfo(south)
        set dirinfo(up)         $dirinfo(north)
        set dirinfo(left)       $dirinfo(west)
        set dirinfo(right)      $dirinfo(east)
        set dirinfo(SE)         $dirinfo(southeast)
        set dirinfo(NE)         $dirinfo(northeast)
        set dirinfo(SW)         $dirinfo(southwest)
        set dirinfo(NW)         $dirinfo(northwest)
    }

    # drawin --
    #    Set the canvas widget in which to draw
    # Arguments:
    #    widget    Name of the canvas widget to use
    # Result:
    #    None
    #
    proc ::Diagrams::drawin {widget} {
        variable state
        set state(canvas) $widget
    }

    # saveps --
    #    Save the drawing in a PostScript file
    # Arguments:
    #    filename   Name of the file to write
    # Result:
    #    None
    #
    proc ::Diagrams::saveps {filename} {
        variable state
        update
        $state(canvas) postscript -file $filename
    }

    # direction --
    #    Set the direction for moving the current position
    # Arguments:
    #    newdir    Direction (down, left, up, right)
    # Result:
    #    None
    #
    proc ::Diagrams::direction {newdir} {
        variable state
        variable dirinfo

        if { [info exists dirinfo($newdir)] } {
            foreach s {dir xdir ydir attach} v $dirinfo($newdir) {
                set state($s) $v
            }
        } else {
            return
        }
        if { $state(lastitem) != {} } {
            currentpos [getpos $state(dir) $state(lastitem)]
        }
    }

    # currentpos
    #    Set the current position explicitly
    # Arguments:
    #    pos       Position "object" (optional)
    # Result:
    #    Current position as an "object"
    # Side effect:
    #    Current position set
    #
    proc ::Diagrams::currentpos { {pos {}} } {
        variable state

        if { [lindex $pos 0] == "POSITION" } {
            set state(xprev) $state(xcurr)
            set state(yprev) $state(ycurr)
            set state(xcurr) [lindex $pos 1]
            set state(ycurr) [lindex $pos 2]
        }

        return [list POSITION $state(xcurr) $state(ycurr)]
    }

    # CoordName
    #    Return the name of the variable for a particular "anchor" point
    # Arguments:
    #    coord     Which coordinate to return
    #    anchor    Which anchor point
    # Result:
    #    Name of the variable
    #
    proc ::Diagrams::CoordName {coord anchor} {
        variable anchors

        if { $anchor == "init" } {
            direction "east"
            set anchor "east"
        }

        set idx [lsearch $anchors($coord) $anchor]
        if { $idx >= 0 } {
            return [lindex $anchors($coord) [incr idx]]
        } else {
            return -code error "Unknown anchor: $anchor"
        }
    }

    # getpos
    #    Get the position of a particular "anchor" point of an object
    # Arguments:
    #    anchor    Which point to return
    #    obj       Drawable "object"
    # Result:
    #    Position of the requested point
    #
    proc ::Diagrams::getpos {anchor obj} {
        variable state

        if { [lindex $obj 0] == "BOX" } {
            foreach {x1 y1 x2 y2} [lrange $obj 1 end] {break}
            set yew [expr {($y1+$y2)/2}]
            set xns [expr {($x1+$x2)/2}]
        }
        if { [lindex $obj 0] == "ARROW" ||
             [lindex $obj 0] == "LINE" } {
            foreach {x1 y1 x2 y2} [lrange $obj 1 end] {break}
            set yew [expr {($y1+$y2)/2}]
            set xns [expr {($x1+$x2)/2}]
        }

        set xp [set [CoordName X $anchor]]
        set yp [set [CoordName Y $anchor]]

        return [list POSITION $xp $yp]
    }

    # computepos
    #    Compute the new position
    # Arguments:
    #    None
    # Result:
    #    X- and Y-coordinates
    #
    proc ::Diagrams::computepos {} {
        variable state

        set xcoord [expr {$state(xcurr)+$state(xgap)*$state(xdir)*$state(usegap)}]
        set ycoord [expr {$state(ycurr)+$state(ygap)*$state(ydir)*$state(usegap)}]

        return [list "POSITION" $xcoord $ycoord]
    }

    # position
    #    Create a position "object"
    # Arguments:
    #    xcoord    X-coordinate
    #    ycoord    Y-coordinate
    # Result:
    #    List representing the object
    #
    proc ::Diagrams::position {xcoord ycoord} {

        return [list "POSITION" $xcoord $ycoord]
    }

    # box --
    #    Draw a box from the current position
    # Arguments:
    #    text      Text to be fitted in the box
    #    width     (Optional) width in pixels or "fitting"
    #    height    (Optional) height in pixels
    # Result:
    #    ID of the box
    # Side effect:
    #    Box drawn with text inside, current position set
    #
    proc ::Diagrams::box {text {width {}} {height {}}} {
        variable state

        if { $width == {} } {
            set width $state(default_width)
        }

        if { $height == {} } {
            set height $state(default_height)
        }

        set items [$state(canvas) create text 0 0 -text $text \
                      -font    $state(font) \
                      -justify $state(justify)]

        if { $width == "fitting" } {
            foreach {x1 y1 x2 y2} [$state(canvas) bbox $items] {break}

            set width  [expr {$x2-$x1+10}]
            set height [expr {$y2-$y1+10}]
        }

        #
        # Construct the box
        #
        set x1 0
        set x2 $width
        set y1 0
        set y2 $height

        $state(canvas) move $items [expr {$width/2}] [expr {$height/2}]

        lappend items [$state(canvas) create rectangle $x1 $y1 $x2 $y2]

        set item2 [list BOX $x1 $y1 $x2 $y2]

        #
        # Compute the coordinates of the box (positioned correctly)
        #
        foreach {dummy xcurr ycurr}     [computepos] {break}
        foreach {dummy xanchor yanchor} [getpos $state(attach) $item2] {break}

        set xt [expr {$xcurr-$xanchor}]
        set yt [expr {$ycurr-$yanchor}]

        foreach i $items {
            $state(canvas) move $i $xt $yt
        }

        set x1 [expr {$x1+$xt}]
        set x2 [expr {$x2+$xt}]
        set y1 [expr {$y1+$yt}]
        set y2 [expr {$y2+$yt}]

        set item [list BOX $x1 $y1 $x2 $y2]

        currentpos [getpos $state(dir) $item]

        set state(lastitem) $item
        set state(usegap)   1
        puts $item
        return $item
    }

    # plaintext --
    #    Draw plain text from the current position
    # Arguments:
    #    text      Text to be fitted in the box
    #    width     (Optional) width in pixels or "fitting"
    #    height    (Optional) height in pixels
    # Result:
    #    ID of the box
    # Side effect:
    #    Text drawn, current position set
    # NOTE:
    #    Quicky
    #
    proc ::Diagrams::plaintext {text {width {}} {height {}}} {
        variable state

        if { $width == {} } {
            set width $state(default_width)
        }

        if { $height == {} } {
            set height $state(default_height)
        }

        set items [$state(canvas) create text 0 0 -text $text \
                      -font    $state(font) \
                      -justify $state(justify)]

        if { $width == "fitting" } {
            foreach {x1 y1 x2 y2} [$state(canvas) bbox $items] {break}

            set width  [expr {$x2-$x1}]
            set height [expr {$y2-$y1}]
        }

        #
        # Construct the box
        #
        set x1 0
        set x2 $width
        set y1 0
        set y2 $height

        $state(canvas) move $items [expr {$width/2}] [expr {$height/2}]

        set item2 [list BOX $x1 $y1 $x2 $y2]

        #
        # Compute the coordinates of the box (positioned correctly)
        #
        set state(usegap) 0
        foreach {dummy xcurr ycurr}     [computepos] {break}
        set state(usegap) 1
        foreach {dummy xanchor yanchor} [getpos $state(attach) $item2] {break}

        set xt [expr {$xcurr-$xanchor}]
        set yt [expr {$ycurr-$yanchor}]

        foreach i $items {
            $state(canvas) move $i $xt $yt
        }

        set x1 [expr {$x1+$xt}]
        set x2 [expr {$x2+$xt}]
        set y1 [expr {$y1+$yt}]
        set y2 [expr {$y2+$yt}]

        set item [list BOX $x1 $y1 $x2 $y2]

        currentpos [getpos $state(dir) $item]

        set state(lastitem) $item
        set state(usegap)   1
        puts $item
        return $item
    }

    # arrow --
    #    Draw an arrow from the current position to the next
    # Arguments:
    #    text      (Optional) text to written above the arrow
    #    length    (Optional) length in pixels
    # Result:
    #    ID of the arrow
    # Side effect:
    #    Arrow drawn
    #
    proc ::Diagrams::arrow { {text {}} {length {}}} {
        variable state

        if { $length != {} } {
            set factor  [expr {hypot($state(xdir),$state(ydir))}]
            set dxarrow [expr {$length*$state(xdir)/$factor}]
            set dyarrow [expr {$length*$state(ydir)/$factor}]
        } else {
            set dxarrow [expr {$state(xdir)*$state(xgap)}]
            set dyarrow [expr {$state(ydir)*$state(ygap)}]
        }

        set x1      $state(xcurr)
        set y1      $state(ycurr)
        set x2      [expr {$state(xcurr)+$dxarrow}]
        set y2      [expr {$state(ycurr)+$dyarrow}]

        set item [$state(canvas) create line $x1 $y1 $x2 $y2 \
                     -fill    $state(colour) \
                     -arrow   last]

        set xt [expr {5+($x1+$x2)/2}]
        set yt [expr {($y1+$y2)/2}]

        set item [$state(canvas) create text $xt $yt -text $text \
                     -font    $state(font) \
                     -justify $state(justify)]

        set item [list ARROW $x1 $y1 $x2 $y2]

        #
        # Ignore the direction of motion - we need the end point
        #
        currentpos [position $x2 $y2]

        set state(lastitem) $item
        set state(usegap)   0
        return $item
    }

    # line --
    #    Draw a line specified via positions or via line segments
    # Arguments:
    #    args        All arguments (either position or length-angle pairs)
    # Result:
    #    ID of the line
    # Side effect:
    #    Line drawn
    #
    proc ::Diagrams::line {args} {
        variable state
        variable torad

        #
        # Get the current position if the first arguments
        # are line segments (this guarantees that x, y are
        # defined)
        #
        if { [lindex [lindex $args 0] 0] != "POSITION" } {
            set args [linsert $args 0 [currentpos]]
        }

        set xycoords {}
        set x1       {}
        set x2       {}
        set y1       {}
        set y2       {}

        set idx 0
        set number [llength $args]
        while { $idx < $number } {
            set arg [lindex $args $idx]

            if { [lindex $arg 0] != "POSITION" } {
                incr idx
                set length $arg
                set angle  [lindex $args $idx]

                set x      [expr {$x+$length*cos($torad*$angle)}]
                set y      [expr {$y-$length*sin($torad*$angle)}]
            } else {
                foreach {dummy x y} [currentpos] {break}
            }

            lappend xycoords $x $y

            if { $x1 == {} || $x1 > $x } { set x1 $x }
            if { $x2 == {} || $x2 < $x } { set x2 $x }
            if { $y1 == {} || $y1 > $y } { set y1 $y }
            if { $y2 == {} || $y2 < $y } { set y2 $y }

            incr idx
        }

        set item [$state(canvas) create line $xycoords \
                     -fill  $state(colour)] ;# -dash?

        set item [list LINE $x1 $y1 $x2 $y2]

        currentpos [getpos $state(dir) $item]

        set state(lastitem) $item
        set state(usegap)   1
        puts $item
        return $item
    }

    #
    # A small demonstration ...
    #

    pack [canvas .c -width 400 -height 130 -bg white]

    namespace import ::Diagrams::*

    #console show
    drawin .c

    proc ring {} {
       set side 20
       line $side 60 $side 0 $side -60 $side -120 $side 180 $side 120
    }
    proc benzene {} {
       set item [ring]

       foreach {dummy x1 y1 x2 y2} $item {break}

       $::Diagrams::state(canvas) create oval \
          [expr {($x1+$x2)/2-12}] [expr {($y1+$y2)/2+12}] \
          [expr {($x1+$x2)/2+12}] [expr {($y1+$y2)/2-12}]

       return $item
    }

    proc bond { {angle 0} {item {}} } {
       set side 20

       set anchor E
       switch -- $angle {
       "0"   { direction E  ; set anchor E  }
       "60"  { direction NE ; set anchor NE }
       "90"  { direction N  ; set anchor N  }
       "120" { direction NW ; set anchor NW }
       "180" { direction W  ; set anchor W  }
       "240" { direction SW ; set anchor SW }
       "-90" -
       "270" { direction S  ; set anchor S  }
       "-60" -
       "300" { direction SE ; set anchor SE }
       }

       if { $item != {} } {
          currentpos [getpos $anchor $item]
       }

       line $side $angle
    }

    #
    # Very primitive chemical formula
    # -- order of direction/currentpos important!
    #
    direction east
    currentpos [position 40 60]
    benzene; bond;

    set Catom [plaintext C]

    bond 90 $Catom
    direction north
    plaintext C
    direction east
    plaintext OOH

    bond -90 $Catom
    direction south
    plaintext H

    bond 0 $Catom
    direction east
    benzene
    bond; direction east
    plaintext NH2  ;# UNICODE \u2082 is subscript 2, but that is not
                    # supported in PostScript

    saveps chemical.eps
