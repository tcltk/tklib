set rcsId {$Id: pie.tcl,v 1.53 1998/03/15 13:38:41 jfontain Exp $}

package provide tkpiechart 4.0

class pie {
    set pie::(colors) {#7FFFFF #7FFF7F #FF7F7F #FFFF7F #7F7FFF #FFBF00 #BFBFBF #FF7FFF #FFFFFF}
}

proc pie::pie {this canvas x y width height args} switched {$args} {            ;# note: all pie elements are tagged with pie($this)
    set pie::($this,canvas) $canvas

    set pie::($this,x) [winfo fpixels $canvas $x]
    set pie::($this,y) [winfo fpixels $canvas $y]
    set pie::($this,radiusX) [expr {[winfo fpixels $canvas $width]/2.0}]
    set pie::($this,radiusY) [expr {[winfo fpixels $canvas $height]/2.0}]

    set pie::($this,slices) {}

    switched::complete $this
    complete $this                                                  ;# wait till all options have been set for initial configuration
}

proc pie::~pie {this} {
    catch {$pie::($this,canvas) delete $pie::($this,title)}                                                   ;# title may not exist
    delete $pie::($this,labeller)
    eval delete $pie::($this,slices) $pie::($this,backgroundSlice)
}

proc pie::options {this} {
    # force thickness option so that corresponding pie member is properly initialized
    return [list\
        [list -background {} {}]\
        [list -colors $pie::(colors) $pie::(colors)]\
        [list -labeller 0 0]\
        [list -thickness 0]\
        [list -title {} {}]\
        [list -titlefont {} {}]\
        [list -titleoffset 2 2]\
    ]
}

foreach option {-background -colors -labeller -title -titlefont -titleoffset} {          ;# no dynamic options allowed: see complete
    proc pie::set$option {this value} "
        if {\$switched::(\$this,complete)} {
            error {option $option cannot be set dynamically}
        }
    "
}

proc pie::set-thickness {this value} {
    if {$switched::($this,complete)} {
        error {option -thickness cannot be set dynamically}
    }
    set pie::($this,thickness) [winfo fpixels $pie::($this,canvas) $value]                                      ;# convert to pixels
}

proc pie::complete {this} {
    set canvas $pie::($this,canvas)

    if {$switched::($this,-labeller)==0} {
        set pie::($this,labeller) [new pieBoxLabeller $canvas]                           ;# use default labeler if user defined none
    } else {
        set pie::($this,labeller) $switched::($this,-labeller)                                           ;# use user defined labeler
    }
    $canvas addtag pie($this) withtag pieLabeller($pie::($this,labeller))
    pieLabeller::bind $pie::($this,labeller) $this                                                         ;# bind labeller with pie

    if {[string length $switched::($this,-background)]==0} {
        set bottomColor {}
    } else {
        set bottomColor [tkDarken $switched::($this,-background) 60]
    }
    set slice [new slice\
        $canvas $pie::($this,x) $pie::($this,y) $pie::($this,radiusX) $pie::($this,radiusY) 90 360\
        -height $pie::($this,thickness) -topcolor $switched::($this,-background) -bottomcolor $bottomColor\
    ]
    $canvas addtag pie($this) withtag slice($slice)
    $canvas addtag pieGraphics($this) withtag slice($slice)
    set pie::($this,backgroundSlice) $slice
}

proc pie::newSlice {this {text {}}} {
    set start 90                                     ;# calculate start radian for new slice (slices grow clockwise from 12 o'clock)
    foreach slice $pie::($this,slices) {
        set start [expr {$start-$slice::($slice,extent)}]
    }
    # get a new color
    set color [lindex $switched::($this,-colors) [expr {[llength $pie::($this,slices)]%[llength $switched::($this,-colors)]}]]

    # make sure slice is positioned correctly in case pie was moved
    set coordinates [$pie::($this,canvas) coords slice($pie::($this,backgroundSlice))]

    # darken slice top color by 40% to obtain bottom color, as it is done for Tk buttons shadow, for example
    set slice [new slice\
        $pie::($this,canvas) [lindex $coordinates 0] [lindex $coordinates 1] $pie::($this,radiusX) $pie::($this,radiusY) $start 0\
        -height $pie::($this,thickness) -topcolor $color -bottomcolor [tkDarken $color 60]\
    ]
    $pie::($this,canvas) addtag pie($this) withtag slice($slice)
    $pie::($this,canvas) addtag pieGraphics($this) withtag slice($slice)
    lappend pie::($this,slices) $slice

    if {[string length $text]==0} {                                                           ;# generate label text if not provided
        set text "slice [llength $pie::($this,slices)]"
    }
    set pie::($this,sliceLabel,$slice) [pieLabeller::create $pie::($this,labeller) $slice -text $text -background $color]
    # update tags which canvas does not automatically do
    $pie::($this,canvas) addtag pie($this) withtag pieLabeller($pie::($this,labeller))

    return $slice
}

proc pie::sizeSlice {this slice unitShare {valueToDisplay {}}} {
    if {[set index [lsearch $pie::($this,slices) $slice]]<0} {
        error "could not find slice $slice in pie $this slices"
    }
    # cannot display slices that occupy more than whole pie and less than zero
    set newExtent [expr {[maximum [minimum $unitShare 1] 0]*360}]
    set growth [expr {$newExtent-$slice::($slice,extent)}]
    slice::update $slice [expr {$slice::($slice,start)-$growth}] $newExtent                                        ;# grow clockwise

    if {[string length $valueToDisplay]>0} {                  ;# update label after slice for it may need slice latest configuration
        pieLabeller::update $pie::($this,labeller) $pie::($this,sliceLabel,$slice) $valueToDisplay
    } else {
        pieLabeller::update $pie::($this,labeller) $pie::($this,sliceLabel,$slice) $unitShare
    }

    set value [expr {-1*$growth}]                                                               ;# finally move the following slices
    foreach slice [lrange $pie::($this,slices) [incr index] end] {
        slice::rotate $slice $value
        pieLabeller::rotate $pie::($this,labeller) $pie::($this,sliceLabel,$slice)
    }
}

proc pie::createTitle {this string font offset} {
    if {[string length $string]==0} {
        return
    }
    set canvas $pie::($this,canvas)                                                                      ;# place text on top of pie
    set box [$canvas bbox pie($this)]
    set pie::($this,title) [\
        $canvas create text [expr {[lindex $box 0]+([lindex $box 2]-[lindex $box 0])/2}] [expr {[lindex $box 1]-$offset}]\
            -anchor s -tags pie($this) -text $string\
    ]
    if {[string length $font]>0} {
        $canvas itemconfigure $pie::($this,title) -font $font
    }
}
