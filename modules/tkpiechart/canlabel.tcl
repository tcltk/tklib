set rcsId {$Id: canlabel.tcl,v 1.11 1995/10/14 17:13:32 jfontain Exp $}

proc canvasLabel::canvasLabel {this canvas x y args} {
    global canvasLabel

    set canvasLabel($this,canvas) $canvas
    # use a dimensionless line as an origin marker
    set canvasLabel($this,origin) [$canvas create line $x $y $x $y -fill {} -tags canvasLabel($this)]
    set canvasLabel($this,rectangle) [$canvas create rectangle 0 0 0 0 -tags canvasLabel($this)]
    set canvasLabel($this,text) [$canvas create text 0 0 -tags canvasLabel($this)]
    # set anchor default
    set canvasLabel($this,anchor) center
    # style can be box or split
    set canvasLabel($this,style) box
    set canvasLabel($this,padding) 2

    eval canvasLabel::configure $this $args
    # initialize rectangle
    canvasLabel::update $this
}

proc canvasLabel::~canvasLabel {this} {
    global canvasLabel

    $canvasLabel($this,canvas) delete canvasLabel($this)
}

proc canvasLabel::configure {this args} {
    # emulate label widget behavior
    global canvasLabel

    set number [llength $args]
    for {set index 0} {$index<$number} {incr index} {
        set option [lindex $args $index]
        set value [lindex $args [incr index]]
        switch -- $option {
            -background {
                $canvasLabel($this,canvas) itemconfigure $canvasLabel($this,rectangle) -fill $value
            }
            -foreground {
                $canvasLabel($this,canvas) itemconfigure $canvasLabel($this,text) -fill $value
            }
            -borderwidth {
                $canvasLabel($this,canvas) itemconfigure $canvasLabel($this,rectangle) -width $value
                canvasLabel::update $this
            }
            -stipple {
                $canvasLabel($this,canvas) itemconfigure $canvasLabel($this,rectangle) $option $value
            }
            -anchor {
                set canvasLabel($this,anchor) $value
                canvasLabel::update $this
            }
            -font -
            -justify -
            -text -
            -width {
                $canvasLabel($this,canvas) itemconfigure $canvasLabel($this,text) $option $value
                canvasLabel::update $this
            }
            -bordercolor {
                $canvasLabel($this,canvas) itemconfigure $canvasLabel($this,rectangle) -outline $value
            }
            -style {
                set canvasLabel($this,style) $value
                canvasLabel::update $this
            }
        }
    }
}

proc canvasLabel::cget {this option} {
    global canvasLabel

    switch -- $option {
        -background {
            return [$canvasLabel($this,canvas) itemcget $canvasLabel($this,rectangle) -fill]
        }
        -foreground {
            return [$canvasLabel($this,canvas) itemcget $canvasLabel($this,text) -fill]
        }
        -borderwidth {
            return [$canvasLabel($this,canvas) itemcget $canvasLabel($this,rectangle) -width]
        }
        -stipple {
            return [$canvasLabel($this,canvas) itemcget $canvasLabel($this,rectangle) $option]
        }
        -anchor {
            return $canvasLabel($this,anchor)
        }
        -font -
        -justify -
        -text -
        -width {
            return [$canvasLabel($this,canvas) itemcget $canvasLabel($this,text) $option]
        }
        -bordercolor {
            return [$canvasLabel($this,canvas) itemcget $canvasLabel($this,rectangle) -outline]
        }
        -style {
            return canvasLabel($this,style) $value
        }
    }
}

proc canvasLabel::update {this} {
    global canvasLabel

    set canvas $canvasLabel($this,canvas)
    set rectangle $canvasLabel($this,rectangle)
    set text $canvasLabel($this,text)

    set coordinates [$canvas coords $canvasLabel($this,origin)]
    set x [lindex $coordinates 0]
    set y [lindex $coordinates 1]

    set border [$canvas itemcget $rectangle -width]
    set textBox [$canvas bbox $text]

    # position rectangle and text as if anchor was center (the default)
    if {[string compare $canvasLabel($this,style) split]==0} {
        set textHeight [expr [lindex $textBox 3]-[lindex $textBox 1]]
        set rectangleWidth [expr 2.0*($textHeight+$border)]
        set halfWidth [expr ($rectangleWidth+$canvasLabel($this,padding)+([lindex $textBox 2]-[lindex $textBox 0]))/2.0]
        set halfHeight [expr ($textHeight/2.0)+$border]
        $canvas coords $rectangle\
            [expr $x-$halfWidth] [expr $y-$halfHeight] [expr $x-$halfWidth+$rectangleWidth] [expr $y+$halfHeight]
        $canvas coords $text [expr $x+(($rectangleWidth+$canvasLabel($this,padding))/2.0)] $y
    } else {
        set halfWidth [expr $border+$canvasLabel($this,padding)+(([lindex $textBox 2]-[lindex $textBox 0])/2.0)]
        set halfHeight [expr $border+$canvasLabel($this,padding)+(([lindex $textBox 3]-[lindex $textBox 1])/2.0)]
        $canvas coords $rectangle [expr $x-$halfWidth] [expr $y-$halfHeight] [expr $x+$halfWidth] [expr $y+$halfHeight]
        $canvas coords $text $x $y
    }
    # now move rectangle and text according to anchor
    set anchor $canvasLabel($this,anchor)
    set xDelta [expr ([string match *w $anchor]-[string match *e $anchor])*$halfWidth]
    set yDelta [expr ([string match n* $anchor]-[string match s* $anchor])*$halfHeight]
    $canvas move $rectangle $xDelta $yDelta
    $canvas move $text $xDelta $yDelta
}
