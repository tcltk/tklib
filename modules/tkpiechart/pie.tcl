set rcsId {$Id: pie.tcl,v 1.52 1998/02/22 20:13:45 jfontain Exp $}

package provide tkpiechart 3.0


class pie {}

proc pie::pie {this canvas x y width height args} {                             ;# note: all pie elements are tagged with pie($this)
    array set option {\
        -thickness 0 -background {} -title {} -titlefont {} -titleoffset 2\
        -colors {#7FFFFF #7FFF7F #FF7F7F #FFFF7F #7F7FFF #FFBF00 #BFBFBF #FF7FFF #FFFFFF}\
    }                                                                             ;# set options default then parse switched options
    array set option $args

    set pie::($this,canvas) $canvas

    if {[info exists option(-labeller)]} {
        set pie::($this,labellerId) $option(-labeller)
    } else {                                                                                                 ;# use default labeller
        set pie::($this,labellerId) [new pieBoxLabeller $canvas]
    }
    $canvas addtag pie($this) withtag pieLabeller($pie::($this,labellerId))
    pieLabeller::bind $pie::($this,labellerId) $this                                                       ;# bind labeller with pie

    set pie::($this,radiusX) [expr {[winfo fpixels $canvas $width]/2.0}]
    set pie::($this,radiusY) [expr {[winfo fpixels $canvas $height]/2.0}]
    set pie::($this,thickness) [winfo fpixels $canvas $option(-thickness)]

    if {[string length $option(-background)]>0} {
        set bottomColor [tkDarken $option(-background) 60]
    } else {
        set bottomColor {}
    }
    set pie::($this,backgroundSliceId) [new slice\
        $canvas [winfo fpixels $canvas $x] [winfo fpixels $canvas $y] $pie::($this,radiusX) $pie::($this,radiusY) 90 360\
        -height $pie::($this,thickness) -topcolor $option(-background) -bottomcolor $bottomColor\
    ]
    $canvas addtag pie($this) withtag slice($pie::($this,backgroundSliceId))
    $canvas addtag pieGraphics($this) withtag slice($pie::($this,backgroundSliceId))
    set pie::($this,sliceIds) {}
    set pie::($this,colors) $option(-colors)

    pie::createTitle $this $option(-title) $option(-titlefont) [winfo fpixels $canvas $option(-titleoffset)]
}

proc pie::~pie {this} {
    catch {$pie::($this,canvas) delete $pie::($this,title)}                                                   ;# title may not exist
    delete $pie::($this,labellerId)
    foreach sliceId $pie::($this,sliceIds) {
        delete $sliceId
    }
    delete $pie::($this,backgroundSliceId)
}

proc pie::newSlice {this {text {}}} {
    set start 90                                     ;# calculate start radian for new slice (slices grow clockwise from 12 o'clock)
    foreach sliceId $pie::($this,sliceIds) {
        set start [expr {$start-$slice::($sliceId,extent)}]
    }
    # get a new color
    set color [lindex $pie::($this,colors) [expr {[llength $pie::($this,sliceIds)]%[llength $pie::($this,colors)]}]]
    set numberOfSlices [llength $pie::($this,sliceIds)]

    # make sure slice is positioned correctly in case pie was moved
    set coordinates [$pie::($this,canvas) coords slice($pie::($this,backgroundSliceId))]

    # darken slice top color by 40% to obtain bottom color, as it is done for Tk buttons shadow, for example
    set sliceId [new slice\
        $pie::($this,canvas) [lindex $coordinates 0] [lindex $coordinates 1] $pie::($this,radiusX) $pie::($this,radiusY) $start 0\
        -height $pie::($this,thickness) -topcolor $color -bottomcolor [tkDarken $color 60]\
    ]
    $pie::($this,canvas) addtag pie($this) withtag slice($sliceId)
    $pie::($this,canvas) addtag pieGraphics($this) withtag slice($sliceId)
    lappend pie::($this,sliceIds) $sliceId

    if {[string length $text]==0} {                                                           ;# generate label text if not provided
        set text "slice [llength $pie::($this,sliceIds)]"
    }
    set pie::($this,sliceLabel,$sliceId) [pieLabeller::create $pie::($this,labellerId) $sliceId -text $text -background $color]
    # update tags which canvas does not automatically do
    $pie::($this,canvas) addtag pie($this) withtag pieLabeller($pie::($this,labellerId))

    return $sliceId
}

proc pie::sizeSlice {this sliceId unitShare {valueToDisplay {}}} {
    if {[set index [lsearch $pie::($this,sliceIds) $sliceId]]<0} {
        error "could not find slice $sliceId in pie $this slices"
    }
    # cannot display slices that occupy more than whole pie and less than zero
    set newExtent [expr {[maximum [minimum $unitShare 1] 0]*360}]
    set growth [expr {$newExtent-$slice::($sliceId,extent)}]
    slice::update $sliceId [expr {$slice::($sliceId,start)-$growth}] $newExtent                                    ;# grow clockwise

    if {[string length $valueToDisplay]>0} {                  ;# update label after slice for it may need slice latest configuration
        pieLabeller::update $pie::($this,labellerId) $pie::($this,sliceLabel,$sliceId) $valueToDisplay
    } else {
        pieLabeller::update $pie::($this,labellerId) $pie::($this,sliceLabel,$sliceId) $unitShare
    }

    set value [expr {-1*$growth}]                                                               ;# finally move the following slices
    foreach sliceId [lrange $pie::($this,sliceIds) [incr index] end] {
        slice::rotate $sliceId $value
        pieLabeller::rotate $pie::($this,labellerId) $pie::($this,sliceLabel,$sliceId)
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
