set rcsId {$Id: canlabel.tcl,v 1.1 1995/09/28 15:53:54 jfontain Exp $}

proc canvasLabel::canvasLabel {id canvas x y args} {
    global canvasLabel

    set canvasLabel($id,canvas) $canvas
    # use a dimensionless line as an origin marker
    set canvasLabel($id,origin) [$canvas create line $x $y  $x $y -fill {} -tags canvasLabel($id)]
    set canvasLabel($id,rectangle) [$canvas create rectangle 0 0 0 0 -tags canvasLabel($id)]
    set canvasLabel($id,text) [$canvas create text 0 0 -tags canvasLabel($id)]
    set canvasLabel($id,anchor) center
    eval canvasLabel::configure $id $args
    canvasLabel::sizeRectangle $id
}

proc canvasLabel::~canvasLabel {id} {
    global canvasLabel

    canvasLabel($id,canvas) delete canvasLabel($id)
}

proc canvasLabel::configure {id args} {
    # emulate label widget behavior
    global canvasLabel

    set canvas $canvasLabel($id,canvas)
    set rectangle $canvasLabel($id,rectangle)
    set text $canvasLabel($id,text)

    set number [llength $args]
    for {set index 0} {$index<$number} {incr index} {
        set switch [lindex $args $index]
        set option [lindex $args [incr index]]
        switch -- $switch {
            -background {
                $canvas itemconfigure $rectangle -fill $option
            }
            -foreground {
                $canvas itemconfigure $text -fill $option
            }
            -borderwidth {
                $canvas itemconfigure $rectangle -width $option
            }
            -bitmap {
                $canvas itemconfigure $rectangle -stipple $option
            }
            -anchor {
                set canvasLabel($id,anchor) $option
                canvasLabel::sizeRectangle $id
            }
            -font -
            -justify -
            -text -
            -width {
                $canvas itemconfigure $text $switch $option
                canvasLabel::sizeRectangle $id
            }
            -bordercolor {
                $canvas itemconfigure $rectangle -outline $option
            }
        }
    }
}

proc canvasLabel::cget {id} {
    global canvasLabel

    return [$canvasLabel($id,canvas) itemcget $canvasLabel($id,text) -text]
}

proc canvasLabel::sizeRectangle {id} {
    global canvasLabel

    set padding 2
    set canvas $canvasLabel($id,canvas)
    set rectangle $canvasLabel($id,rectangle)
    set text $canvasLabel($id,text)

    set coordinates [$canvas coords $canvasLabel($id,origin)]
    set x [lindex $coordinates 0]
    set y [lindex $coordinates 0]

    set border [$canvas itemcget $rectangle -width]
    set halfBorder [expr $border/2.0]
    set box [$canvas bbox $text]

    set halfWidth [expr ([lindex $box 2]-[lindex $box 0])/2.0]
    set halfHeight [expr ([lindex $box 3]-[lindex $box 1])/2.0]

    # first position rectangle and text as if anchor was center (the default)
    $canvas coords $rectangle\
        [expr $x-$halfWidth-$padding-$halfBorder] [expr $y-$halfHeight-$padding-$halfBorder]\
        [expr $x+$halfWidth+$padding+$halfBorder] [expr $y+$halfHeight+$padding+$halfBorder]
    $canvas coords $text $x $y

    # now move rectangle and text according to anchor
    set halfWidth [expr $border+$padding+$halfWidth]
    set halfHeight [expr $border+$padding+$halfHeight]
    switch $canvasLabel($id,anchor) {
        nw {
            $canvas move $rectangle $halfWidth $halfHeight
            $canvas move $text $halfWidth $halfHeight
        }
        n {
            $canvas move $rectangle 0 $halfHeight
            $canvas move $text 0 $halfHeight
        }
        ne {
            $canvas move $rectangle -$halfWidth $halfHeight
            $canvas move $text -$halfWidth $halfHeight
        }
        e {
            $canvas move $rectangle -$halfWidth 0
            $canvas move $text -$halfWidth 0
        }
        se {
            $canvas move $rectangle -$halfWidth -$halfHeight
            $canvas move $text -$halfWidth -$halfHeight
        }
        s {
            $canvas move $rectangle 0 -$halfHeight
            $canvas move $text 0 -$halfHeight
        }
        sw {
            $canvas move $rectangle $halfWidth -$halfHeight
            $canvas move $text $halfWidth -$halfHeight
        }
        w {
            $canvas move $rectangle $halfWidth 0
            $canvas move $text $halfWidth 0
        }
    }
}
