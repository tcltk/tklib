set rcsId {$Id: canlabel.tcl,v 1.25 1999/03/30 20:11:01 jfontain Exp $}

class canvasLabel {

    proc canvasLabel {this canvas args} switched {$args} {
        set canvasLabel::($this,canvas) $canvas
        # use an empty image as an origin marker with only 2 coordinates
        set canvasLabel::($this,origin) [$canvas create image 0 0 -tags canvasLabel($this)]
        set canvasLabel::($this,rectangle) [$canvas create rectangle 0 0 0 0 -tags canvasLabel($this)]
        # select rectangle is on top for default box style
        set canvasLabel::($this,selectRectangle) [$canvas create rectangle 0 0 0 0 -tags canvasLabel($this)]
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
            [list -bulletwidth 10 10]\
            [list -font {Helvetica -12}]\
            [list -foreground black black]\
            [list -justify left left]\
            [list -padding 2 2]\
            [list -scale {1 1} {1 1}]\
            [list -select 0 0]\
            [list -selectcolor white white]\
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
        if {[string compare $switched::($this,-style) box]==0} {
            $canvasLabel::($this,canvas) itemconfigure $canvasLabel::($this,selectRectangle) -outline $value
        }
    }
    proc set-borderwidth {this value} {
        $canvasLabel::($this,canvas) itemconfigure $canvasLabel::($this,selectRectangle) -width $value
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
        switch $value {
            box {
                $canvasLabel::($this,canvas) raise $canvasLabel::($this,selectRectangle) $canvasLabel::($this,rectangle)
            }
            split {
                $canvasLabel::($this,canvas) lower $canvasLabel::($this,selectRectangle) $canvasLabel::($this,rectangle)
            }
            default {
                error "bad style value \"$value\": must be box or split"
            }
        }
        update $this
    }
    foreach option {-anchor -bulletwidth -padding -select -selectcolor} {
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
        set selectRectangle $canvasLabel::($this,selectRectangle)
        set text $canvasLabel::($this,text)

        foreach {x y} [$canvas coords $canvasLabel::($this,origin)] {}

        set border [$canvas itemcget $rectangle -width]
        set textBox [$canvas bbox $text]
        set padding [winfo fpixels $canvas $switched::($this,-padding)]
        set bulletWidth [winfo fpixels $canvas $switched::($this,-bulletwidth)]

        $canvas itemconfigure $selectRectangle -fill {} -outline {}
        set split [expr {[string compare $switched::($this,-style) split]==0}]

        # position rectangle and text as if anchor was center (the default)
        if {$split} {                                                                                                 ;# split style
            set halfWidth [expr {($bulletWidth+$border+$padding+([lindex $textBox 2]-[lindex $textBox 0]))/2.0}]
            set halfHeight [expr {(([lindex $textBox 3]-[lindex $textBox 1])/2.0)+$border}]
        } else {                                                                                                        ;# box style
            set width [expr {$switched::($this,-width)==0?[lindex $textBox 2]-[lindex $textBox 0]:$switched::($this,-width)}]
            set halfWidth [expr {$bulletWidth+$border+$padding+($width/2.0)}]
            set halfHeight [expr {(([lindex $textBox 3]-[lindex $textBox 1])/2.0)+$border+$padding}]
        }
        set left [expr {$x-$halfWidth}]
        set top [expr {$y-$halfHeight}]
        set right [expr {$x+$halfWidth}]
        set bottom [expr {$y+$halfHeight}]
        $canvas coords $text [expr {$x+(($bulletWidth+$border+$padding)/2.0)}] $y
        if {$split} {
            $canvas coords $selectRectangle $left $top $right $bottom
            $canvas coords $rectangle $left $top [expr {$left+$bulletWidth}] $bottom
            if {$switched::($this,-select)} {
                $canvas itemconfigure $selectRectangle\
                    -fill $switched::($this,-selectcolor) -outline $switched::($this,-selectcolor)
            }
        } else {
            $canvas coords $selectRectangle $left $top [expr {$left+$bulletWidth}] $bottom
            $canvas coords $rectangle $left $top $right $bottom
            $canvas itemconfigure $selectRectangle -outline $switched::($this,-bordercolor)
            if {$switched::($this,-select)} {
                $canvas itemconfigure $selectRectangle -fill $switched::($this,-selectcolor)
            }
        }

        set anchor $switched::($this,-anchor)                                     ;# now move rectangle and text according to anchor
        set xDelta [expr {([string match *w $anchor]-[string match *e $anchor])*$halfWidth}]
        set yDelta [expr {([string match n* $anchor]-[string match s* $anchor])*$halfHeight}]
        $canvas move $rectangle $xDelta $yDelta
        $canvas move $selectRectangle $xDelta $yDelta
        $canvas move $text $xDelta $yDelta
        eval $canvas scale canvasLabel($this) $x $y $switched::($this,-scale)                                 ;# finally apply scale
    }

}
