set rcsId {$Id: pie.tcl,v 1.34 1995/10/04 23:02:22 jfontain Exp $}

source slice.tcl
source boxlabel.tcl

proc pie::pie {id canvas x y width height args} {
    # note: all pie elements are tagged with pie($id)
    global pie

    # set options default then parse switched options
    array set option {-thickness 0 -background {} -colors {#7FFFFF #7FFF7F #FF7F7F #FFFF7F #7F7FFF #FFBF00 #BFBFBF #FF7FFF #FFFFFF}}
    array set option $args

    set pie($id,canvas) $canvas

    if {[info exists option(-labeller)]} {
        set pie($id,labeller) $option(-labeller)
    } else {
        # use default labeller
        set pie($id,labeller) [new pieBoxLabeller $canvas]
    }
    $canvas addtag pie($id) withtag pieLabeller($pie($id,labeller))
    # bind labeller with pie
    pieLabeller::bind $pie($id,labeller) $id

    set pie($id,radiusX) [expr [winfo fpixels $canvas $width]/2.0]
    set pie($id,radiusY) [expr [winfo fpixels $canvas $height]/2.0]
    set pie($id,thickness) [winfo fpixels $canvas $option(-thickness)]

    if {[string length $option(-background)]>0} {
        set bottomColor [tkDarken $option(-background) 60]
    } else {
        set bottomColor {}
    }
    set pie($id,backgroundSlice) [new slice\
        $canvas [winfo fpixels $canvas $x] [winfo fpixels $canvas $y] $pie($id,radiusX) $pie($id,radiusY) 90 360\
        -height $pie($id,thickness) -topcolor $option(-background) -bottomcolor $bottomColor\
    ]
    $canvas addtag pie($id) withtag slice($pie($id,backgroundSlice))
    $canvas addtag pieGraphics($id) withtag slice($pie($id,backgroundSlice))
    set pie($id,slices) {}
    set pie($id,colors) $option(-colors)
}

proc pie::~pie {id} {
    global pie

    delete pieLabeller $pie($id,labeller)
    foreach sliceId $pie($id,slices) {
        delete slice $sliceId
    }
    delete slice $pie($id,backgroundSlice)
}

proc pie::newSlice {id {text {}}} {
    global pie slice

    # calculate start radian for new slice (slices grow clockwise from 12 o'clock)
    set start 90
    foreach sliceId $pie($id,slices) {
        set start [expr $start-$slice($sliceId,extent)]
    }
    # get a new color
    set color [lindex $pie($id,colors) [expr [llength $pie($id,slices)]%[llength $pie($id,colors)]]]
    set numberOfSlices [llength $pie($id,slices)]

    # make sure slice is positioned correctly in case pie was moved
    set coordinates [$pie($id,canvas) coords slice($pie($id,backgroundSlice))]

    # darken slice top color by 40% to obtain bottom color, as it is done for Tk buttons shadow, for example
    set sliceId [new slice\
        $pie($id,canvas) [lindex $coordinates 0] [lindex $coordinates 1] $pie($id,radiusX) $pie($id,radiusY) $start 0\
        -height $pie($id,thickness) -topcolor $color -bottomcolor [tkDarken $color 60]\
    ]
    $pie($id,canvas) addtag pie($id) withtag slice($sliceId)
    $pie($id,canvas) addtag pieGraphics($id) withtag slice($sliceId)
    lappend pie($id,slices) $sliceId

    if {[string length $text]==0} {
        # generate label text if not provided
        set text "slice [expr [llength $pie($id,slices)]+1]"
    }
    set pie($id,sliceLabel,$sliceId) [pieLabeller::create $pie($id,labeller) -text $text -background $color]
    # update tags which canvas does not automatically do
    $pie($id,canvas) addtag pie($id) withtag pieLabeller($pie($id,labeller))

    return $sliceId
}

proc pie::sizeSlice {id sliceId unitShare {valueToDisplay {}}} {
    # share of whole pie between 0 and 1
    global pie slice

    if {[set index [lsearch $pie($id,slices) $sliceId]]<0} {
        error "could not find slice $sliceId in pie $id slices"
    }
    if {[string length $valueToDisplay]>0} {
        pieLabeller::update $pie($id,labeller) $pie($id,sliceLabel,$sliceId) $valueToDisplay
    } else {
        pieLabeller::update $pie($id,labeller) $pie($id,sliceLabel,$sliceId) $unitShare
    }
    # cannot display slices that occupy more than whole pie and less than zero
    set newExtent [expr [maximum [minimum $unitShare 1] 0]*360]
    set growth [expr $newExtent-$slice($sliceId,extent)]
    # grow clockwise
    slice::update $sliceId [expr $slice($sliceId,start)-$growth] $newExtent
    # finally move the following slices
    set value [expr -1*$growth]
    foreach sliceId [lrange $pie($id,slices) [incr index] end] {
        slice::rotate $sliceId $value
    }
}
