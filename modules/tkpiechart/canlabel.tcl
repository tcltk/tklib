set rcsId {$Id: canlabel.tcl,v 1.22 1998/06/07 10:08:13 jfontain Exp $}

class canvasLabel {

    proc canvasLabel {this canvas args} switched {$args} {
        set canvasLabel::($this,canvas) $canvas
        # use an empty image as an origin marker with only 2 coordinates
        set canvasLabel::($this,origin) [$canvas create image 0 0 -tags canvasLabel($this)]
        set canvasLabel::($this,rectangle) [$canvas create rectangle 0 0 0 0 -tags canvasLabel($this)]
        set canvasLabel::($this,text) [$canvas create text 0 0 -tags canvasLabel($this)]

        switched::complete $this
    }

    proc ~canvasLabel {this} {
        $canvasLabel::($this,canvas) delete canvasLabel($this)
    }

    proc options {this} {
        # force font for proper initialization
        return [list\
            [list -anchor center center]\
            [list -background {} {}]\
            [list -bordercolor black black]\
            [list -borderwidth 1 1]\
            [list -bulletwidth 20 20]\
            [list -font {Helvetica -12}]\
            [list -foreground black black]\
            [list -justify left left]\
            [list -padding 2 2]\
            [list -scale {1 1} {1 1}]\
            [list -stipple {} {}]\
            [list -style box box]\
            [list -text {} {}]\
            [list -width 0 0]\
        ]
    }

    proc set-background {this value} {
        $canvasLabel::($this,canvas) itemconfigure $canvasLabel::($this,rectangle) -fill $value
    }
    proc set-bordercolor {this value} {
        $canvasLabel::($this,canvas) itemconfigure $canvasLabel::($this,rectangle) -outline $value
    }
    proc set-borderwidth {this value} {
        $canvasLabel::($this,canvas) itemconfigure $canvasLabel::($this,rectangle) -width $value
        update $this
    }
    proc set-foreground {this value} {
        $canvasLabel::($this,canvas) itemconfigure $canvasLabel::($this,text) -fill $value
    }
    proc set-scale {this value} {                                   ;# value is a list of ratios of the horizontal and vertical axis
        update $this                                                           ;# refresh display which takes new scale into account
    }
    proc set-stipple {this value} {
        $canvasLabel::($this,canvas) itemconfigure $canvasLabel::($this,rectangle) -stipple $value
    }
    proc set-style {this value} {
        if {![regexp {^box|split$} $value]} {
            error "bad style value \"$value\": must be box or split"
        }
        update $this
    }
    foreach option {-anchor -bulletwidth -padding} {
        proc set$option {this value} {update $this}
    }
    foreach option {-font -justify -text -width} {
        proc set$option {this value} "
            \$canvasLabel::(\$this,canvas) itemconfigure \$canvasLabel::(\$this,text) $option \$value
            update \$this
        "
    }

    proc update {this} {
        set canvas $canvasLabel::($this,canvas)
        set rectangle $canvasLabel::($this,rectangle)
        set text $canvasLabel::($this,text)

        foreach {x y} [$canvas coords $canvasLabel::($this,origin)] {}

        set border [$canvas itemcget $rectangle -width]
        set textBox [$canvas bbox $text]
        set padding [winfo fpixels $canvas $switched::($this,-padding)]

        # position rectangle and text as if anchor was center (the default)
        if {[string compare $switched::($this,-style) split]==0} {                                                    ;# split style
            set textHeight [expr {[lindex $textBox 3]-[lindex $textBox 1]}]
            set rectangleWidth [winfo fpixels $canvas $switched::($this,-bulletwidth)]
            set halfWidth [expr {($rectangleWidth+$padding+([lindex $textBox 2]-[lindex $textBox 0]))/2.0}]
            set halfHeight [expr {($textHeight/2.0)+$border}]
            $canvas coords $rectangle\
                [expr {$x-$halfWidth}] [expr {$y-$halfHeight}] [expr {$x-$halfWidth+$rectangleWidth}] [expr {$y+$halfHeight}]
            $canvas coords $text [expr {$x+(($rectangleWidth+$padding)/2.0)}] $y
        } else {                                                                                                        ;# box style
            set width [expr {$switched::($this,-width)==0?[lindex $textBox 2]-[lindex $textBox 0]:$switched::($this,-width)}]
            set halfWidth [expr {$border+$padding+($width/2.0)}]
            set halfHeight [expr {$border+$padding+(([lindex $textBox 3]-[lindex $textBox 1])/2.0)}]
            $canvas coords $rectangle [expr {$x-$halfWidth}] [expr {$y-$halfHeight}] [expr {$x+$halfWidth}] [expr {$y+$halfHeight}]
            $canvas coords $text $x $y
        }
        set anchor $switched::($this,-anchor)                                     ;# now move rectangle and text according to anchor
        set xDelta [expr {([string match *w $anchor]-[string match *e $anchor])*$halfWidth}]
        set yDelta [expr {([string match n* $anchor]-[string match s* $anchor])*$halfHeight}]
        $canvas move $rectangle $xDelta $yDelta
        $canvas move $text $xDelta $yDelta
        eval $canvas scale canvasLabel($this) $x $y $switched::($this,-scale)                                 ;# finally apply scale
    }

}
