set rcsId {$Id: canlabel.tcl,v 1.15 1996/12/22 12:42:04 jfontain Exp $}

proc canvasLabel::canvasLabel {this canvas x y args} {
    set canvasLabel($this,canvas) $canvas
    # use a dimensionless line as an origin marker
    set canvasLabel($this,origin) [$canvas create line $x $y $x $y -fill {} -tags canvasLabel($this)]
    set canvasLabel($this,rectangle) [$canvas create rectangle 0 0 0 0 -tags canvasLabel($this)]
    set canvasLabel($this,text) [$canvas create text 0 0 -tags canvasLabel($this)]

    # anchor defaults to center, style can be box by default or split
    array set options {-anchor center -style box -padding 2 -bulletwidth 20}
    # override with user options
    array set options $args
    eval canvasLabel::configure $this [array get options]
}

proc canvasLabel::~canvasLabel {this} {
    $canvasLabel($this,canvas) delete canvasLabel($this)
}

proc canvasLabel::configure {this args} {
    # emulate label widget behavior

    set update 0
    array set value $args
    foreach option [array names value] {
        switch -- $option {
            -background {
                $canvasLabel($this,canvas) itemconfigure $canvasLabel($this,rectangle) -fill $value($option)
            }
            -foreground {
                $canvasLabel($this,canvas) itemconfigure $canvasLabel($this,text) -fill $value($option)
            }
            -borderwidth {
                $canvasLabel($this,canvas) itemconfigure $canvasLabel($this,rectangle) -width $value($option)
                set update 1
            }
            -stipple {
                $canvasLabel($this,canvas) itemconfigure $canvasLabel($this,rectangle) $option $value($option)
            }
            -anchor {
                set canvasLabel($this,anchor) $value($option)
                set update 1
            }
            -font -
            -justify -
            -text -
            -width {
                $canvasLabel($this,canvas) itemconfigure $canvasLabel($this,text) $option $value($option)
                set update 1
            }
            -bordercolor {
                $canvasLabel($this,canvas) itemconfigure $canvasLabel($this,rectangle) -outline $value($option)
            }
            -style {
                set canvasLabel($this,style) $value($option)
                set update 1
            }
            -padding {
                # convert to pixels
                set canvasLabel($this,padding) [winfo fpixels $canvasLabel($this,canvas) $value($option)]
                set update 1
            }
            -bulletwidth {
                set canvasLabel($this,bulletWidth) [winfo fpixels $canvasLabel($this,canvas) $value($option)]
                set update 1
            }
        }
    }
    if {$update} {
        canvasLabel::update $this
    }
}

proc canvasLabel::cget {this option} {
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
            return $canvasLabel($this,style)
        }
        -padding {
            return $canvasLabel($this,padding)
        }
        -bulletwidth {
            return $canvasLabel($this,bulletWidth)
        }
    }
}

proc canvasLabel::update {this} {
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
        set textHeight [expr {[lindex $textBox 3]-[lindex $textBox 1]}]
        set rectangleWidth $canvasLabel($this,bulletWidth)
        set halfWidth [expr {($rectangleWidth+$canvasLabel($this,padding)+([lindex $textBox 2]-[lindex $textBox 0]))/2.0}]
        set halfHeight [expr {($textHeight/2.0)+$border}]
        $canvas coords $rectangle\
            [expr {$x-$halfWidth}] [expr {$y-$halfHeight}] [expr {$x-$halfWidth+$rectangleWidth}] [expr {$y+$halfHeight}]
        $canvas coords $text [expr {$x+(($rectangleWidth+$canvasLabel($this,padding))/2.0)}] $y
    } else {
        set halfWidth [expr {$border+$canvasLabel($this,padding)+(([lindex $textBox 2]-[lindex $textBox 0])/2.0)}]
        set halfHeight [expr {$border+$canvasLabel($this,padding)+(([lindex $textBox 3]-[lindex $textBox 1])/2.0)}]
        $canvas coords $rectangle [expr {$x-$halfWidth}] [expr {$y-$halfHeight}] [expr {$x+$halfWidth}] [expr {$y+$halfHeight}]
        $canvas coords $text $x $y
    }
    # now move rectangle and text according to anchor
    set anchor $canvasLabel($this,anchor)
    set xDelta [expr {([string match *w $anchor]-[string match *e $anchor])*$halfWidth}]
    set yDelta [expr {([string match n* $anchor]-[string match s* $anchor])*$halfHeight}]
    $canvas move $rectangle $xDelta $yDelta
    $canvas move $text $xDelta $yDelta
}
