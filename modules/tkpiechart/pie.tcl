set rcsId {$Id: pie.tcl,v 1.15 1995/09/22 21:15:28 jfontain Exp $}

source slice.tcl
source boxlabel.tcl

proc pie::pie {id canvas width height {thickness 0} {topColor {}} {bottomColor {}} {sliceColors {}}} {
    # note: all pie elements are tagged with pie($id)
    global pie PI

    set pie($id,radiusX) [expr [winfo fpixels $canvas $width]/2.0]
    set pie($id,radiusY) [expr [winfo fpixels $canvas $height]/2.0]
    set pie($id,thickness) [winfo fpixels $canvas $thickness]

    set pie($id,canvas) $canvas
    set pie($id,backgroundSlice)\
        [new slice $canvas $pie($id,radiusX) $pie($id,radiusY) [expr $PI/2] 7 $pie($id,thickness) $topColor $bottomColor]
    $canvas addtag pie($id) withtag slice($pie($id,backgroundSlice))
    set pie($id,slices) {}

    if {[llength $sliceColors]==0} {
        set pie($id,colors) {#7FFFFF #7FFF7F #FF7F7F #FFFF7F #7F7FFF #FFBF00 #BFBFBF #FF7FFF #FFFFFF}
    } else {
        set pie($id,colors) $sliceColors
    }
    set pie($id,labeller) [new pieBoxLabeller $id]
}

proc pie::~pie {id} {
    global pie

    delete pieBoxLabeller $pie($id,labeller)
    foreach sliceId $pie($id,slices) {
        delete slice $sliceId
    }
    delete slice $pie($id,backgroundSlice)
}

proc pie::newSlice {id {text {}}} {
    global pie slice halfPI

    if {[string length $text]==0} {
        # generate label text if not provided
        set text "slice [expr [llength $pie($id,slices)]+1]"
    }

    # calculate start radian for new slice (slices grow clockwise from 12 o'clock)
    set startRadian $halfPI
    foreach sliceId $pie($id,slices) {
        set startRadian [expr $startRadian-$slice($sliceId,extent)]
    }
    # get a new color
    set color [lindex $pie($id,colors) [expr [llength $pie($id,slices)]%[llength $pie($id,colors)]]]
    set numberOfSlices [llength $pie($id,slices)]
    # darken slice top color by 40% to obtain bottom color, as it is done for Tk buttons shadow, for example
    set sliceId [new slice\
        $pie($id,canvas) $pie($id,radiusX) $pie($id,radiusY) $startRadian 0 $pie($id,thickness) $color [tkDarken $color 60]\
    ]
    $pie($id,canvas) addtag pie($id) withtag slice($sliceId)
    lappend pie($id,slices) $sliceId
    return $sliceId
}

proc pie::sizeSlice {id sliceId perCent} {
    # in per cent of whole pie
    global pie slice twoPI

    if {[set index [lsearch $pie($id,slices) $sliceId]]<0} {
        error "could not find slice $sliceId in pie $id slices"
    }
    # cannot display slices that occupy more than 100%
    set perCent [minimum $perCent 100]
    set newExtent [expr $perCent*$twoPI/100]
    set growth [expr $newExtent-$slice($sliceId,extent)]
    # grow clockwise
    slice::update $sliceId [expr $slice($sliceId,start)-$growth] $newExtent
    # finally move the following slices
    set radian [expr -1*$growth]
    while {[set sliceId [lindex $pie($id,slices) [incr index]]]>=0} {
        slice::rotate $sliceId $radian
    }
}
