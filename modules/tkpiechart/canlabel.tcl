set rcsId {$Id: canlabel.tcl,v 1.8 1995/10/09 18:37:24 jfontain Exp $}

proc canvasLabel::canvasLabel {id canvas x y args} {
    global canvasLabel

    set canvasLabel($id,canvas) $canvas
    # use a dimensionless line as an origin marker
    set canvasLabel($id,origin) [$canvas create line $x $y  $x $y -fill {} -tags canvasLabel($id)]
    set canvasLabel($id,rectangle) [$canvas create rectangle 0 0 0 0 -tags canvasLabel($id)]
    set canvasLabel($id,text) [$canvas create text 0 0 -tags canvasLabel($id)]
    # set anchor default
    set canvasLabel($id,anchor) center
    # style can be box or split
    set canvasLabel($id,style) box
    set canvasLabel($id,padding) 2

    eval canvasLabel::configure $id $args
    # initialize rectangle
    canvasLabel::update $id
}

proc canvasLabel::~canvasLabel {id} {
    global canvasLabel

    $canvasLabel($id,canvas) delete canvasLabel($id)
}

proc canvasLabel::configure {id args} {
    # emulate label widget behavior
    global canvasLabel

    set number [llength $args]
    for {set index 0} {$index<$number} {incr index} {
        set option [lindex $args $index]
        set value [lindex $args [incr index]]
        switch -- $option {
            -background {
                $canvasLabel($id,canvas) itemconfigure $canvasLabel($id,rectangle) -fill $value
            }
            -foreground {
                $canvasLabel($id,canvas) itemconfigure $canvasLabel($id,text) -fill $value
            }
            -borderwidth {
                $canvasLabel($id,canvas) itemconfigure $canvasLabel($id,rectangle) -width $value
            }
            -stipple {
                $canvasLabel($id,canvas) itemconfigure $canvasLabel($id,rectangle) $option $value
            }
            -anchor {
                set canvasLabel($id,anchor) $value
                canvasLabel::update $id
            }
            -font -
            -justify -
            -text -
            -width {
                $canvasLabel($id,canvas) itemconfigure $canvasLabel($id,text) $option $value
                canvasLabel::update $id
            }
            -bordercolor {
                $canvasLabel($id,canvas) itemconfigure $canvasLabel($id,rectangle) -outline $value
            }
            -style {
                set canvasLabel($id,style) $value
                canvasLabel::update $id
            }
        }
    }
}

proc canvasLabel::cget {id option} {
    global canvasLabel

    switch -- $option {
        -background {
            return [$canvasLabel($id,canvas) itemcget $canvasLabel($id,rectangle) -fill]
        }
        -foreground {
            return [$canvasLabel($id,canvas) itemcget $canvasLabel($id,text) -fill]
        }
        -borderwidth {
            return [$canvasLabel($id,canvas) itemcget $canvasLabel($id,rectangle) -width]
        }
        -stipple {
            return [$canvasLabel($id,canvas) itemcget $canvasLabel($id,rectangle) $option]
        }
        -anchor {
            return $canvasLabel($id,anchor)
        }
        -font -
        -justify -
        -text -
        -width {
            return [$canvasLabel($id,canvas) itemcget $canvasLabel($id,text) $option]
        }
        -bordercolor {
            return [$canvasLabel($id,canvas) itemcget $canvasLabel($id,rectangle) -outline]
        }
        -style {
            return canvasLabel($id,style) $value
        }
    }
}

proc canvasLabel::update {id} {
    global canvasLabel

    set canvas $canvasLabel($id,canvas)
    set rectangle $canvasLabel($id,rectangle)
    set text $canvasLabel($id,text)

    set coordinates [$canvas coords $canvasLabel($id,origin)]
    set x [lindex $coordinates 0]
    set y [lindex $coordinates 1]

    set border [$canvas itemcget $rectangle -width]
    set textBox [$canvas bbox $text]

    # position rectangle and text as if anchor was center (the default)
    if {[string compare $canvasLabel($id,style) split]==0} {
        set textHeight [expr [lindex $textBox 3]-[lindex $textBox 1]]
        set rectangleWidth [expr 2.0*($textHeight+$border)]
        set halfWidth [expr ($rectangleWidth+$canvasLabel($id,padding)+([lindex $textBox 2]-[lindex $textBox 0]))/2.0]
        set halfHeight [expr ($textHeight/2.0)+$border]
        $canvas coords $rectangle\
            [expr $x-$halfWidth] [expr $y-$halfHeight]\
            [expr $x-$halfWidth+$rectangleWidth] [expr $y+$halfHeight]
        $canvas coords $text [expr $x+(($rectangleWidth+$canvasLabel($id,padding))/2.0)] $y
    } else {
        set halfWidth [expr $border+$canvasLabel($id,padding)+(([lindex $textBox 2]-[lindex $textBox 0])/2.0)]
        set halfHeight [expr $border+$canvasLabel($id,padding)+(([lindex $textBox 3]-[lindex $textBox 1])/2.0)]
        $canvas coords $rectangle [expr $x-$halfWidth] [expr $y-$halfHeight] [expr $x+$halfWidth] [expr $y+$halfHeight]
        $canvas coords $text $x $y
    }
    # now move rectangle and text according to anchor
    set anchor $canvasLabel($id,anchor)
    set xDelta [expr ([string match *w $anchor]-[string match *e $anchor])*$halfWidth]
    set yDelta [expr ([string match n* $anchor]-[string match s* $anchor])*$halfHeight]
    $canvas move $rectangle $xDelta $yDelta
    $canvas move $text $xDelta $yDelta
}
