set rcsId {$Id: relirect.tcl,v 1.1 2000/12/24 16:27:56 jfontain Exp $}


class canvasReliefRectangle {

    proc canvasReliefRectangle {this canvas args} switched {$args} {
        set ($this,topLeft) [$canvas create line 0 0 0 0 0 0 -tags canvasReliefRectangle($this)]
        set ($this,bottomRight) [$canvas create line 0 0 0 0 0 0 -tags canvasReliefRectangle($this)]
        set ($this,canvas) $canvas
        switched::complete $this
    }

    proc ~canvasReliefRectangle {this} {
        $($this,canvas) delete canvasReliefRectangle($this)
    }

    proc options {this} {                                                      ;# force relief initialization for color calculations
        return [list\
            [list -coordinates {0 0 0 0} {0 0 0 0}]\
            [list -relief flat]\
        ]
    }

    proc set-coordinates {this value} {
        foreach {left top right bottom} $value {}
        $($this,canvas) coords $($this,topLeft) $left $bottom $left $top $right $top
        $($this,canvas) coords $($this,bottomRight) $right $top $right $bottom $left $bottom
    }

    proc set-relief {this value} {
        switch $value {
            flat {
                $($this,canvas) itemconfigure canvasReliefRectangle($this) -fill #D9D9D9
            }
            raised {
                $($this,canvas) itemconfigure $($this,topLeft) -fill white
                $($this,canvas) itemconfigure $($this,bottomRight) -fill #828282
            }
            sunken {
                $($this,canvas) itemconfigure $($this,topLeft) -fill #828282
                $($this,canvas) itemconfigure $($this,bottomRight) -fill white
            }
            default {
                error "bad relief value \"$value\": must be flat, raised or sunken"
            }
        }
    }

}
