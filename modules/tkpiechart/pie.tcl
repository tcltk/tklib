set rcsId {$Id: pie.tcl,v 1.26 1995/09/29 11:47:43 jfontain Exp $}

source slice.tcl
source boxlabel.tcl

proc pie::pie {id canvas x y width height args} {
    # note: all pie elements are tagged with pie($id)
    global pie PI

    # set options default then parse switched options
    array set option {\
        -thickness 0 -topcolor {} -bottomcolor {}\
        -slicecolors {#7FFFFF #7FFF7F #FF7F7F #FFFF7F #7F7FFF #FFBF00 #BFBFBF #FF7FFF #FFFFFF}\
    }
    # other options: -labelsoffset, -font
    array set option $args

    set pie($id,radiusX) [expr [winfo fpixels $canvas $width]/2.0]
    set pie($id,radiusY) [expr [winfo fpixels $canvas $height]/2.0]
    set pie($id,thickness) [winfo fpixels $canvas $option(-thickness)]

    set pie($id,canvas) $canvas
    set pie($id,backgroundSlice) [new slice\
        $canvas $x $y $pie($id,radiusX) $pie($id,radiusY) [expr $PI/2] 7\
        -height $pie($id,thickness) -topcolor $option(-topcolor) -bottomcolor $option(-bottomcolor)\
    ]
    $canvas addtag pie($id) withtag slice($pie($id,backgroundSlice))
    $canvas addtag pieGraphics($id) withtag slice($pie($id,backgroundSlice))
    set pie($id,slices) {}
    set pie($id,colors) $option(-slicecolors)

    set options {}
    catch {lappend options -font $option(-font)}
    catch {lappend options -offset $option(-labelsoffset)}
    set pie($id,labeller) [eval new pieBoxLabeller $id $options]
    $canvas addtag pie($id) withtag pieLabeller($pie($id,labeller))
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
    global pie slice halfPI

    # calculate start radian for new slice (slices grow clockwise from 12 o'clock)
    set startRadian $halfPI
    foreach sliceId $pie($id,slices) {
        set startRadian [expr $startRadian-$slice($sliceId,extent)]
    }
    # get a new color
    set color [lindex $pie($id,colors) [expr [llength $pie($id,slices)]%[llength $pie($id,colors)]]]
    set numberOfSlices [llength $pie($id,slices)]

    # make sure slice is positioned correctly in case pie was moved
    set coordinates [$pie($id,canvas) coords slice($pie($id,backgroundSlice))]

    # darken slice top color by 40% to obtain bottom color, as it is done for Tk buttons shadow, for example
    set sliceId [new slice\
        $pie($id,canvas) [lindex $coordinates 0] [lindex $coordinates 1] $pie($id,radiusX) $pie($id,radiusY) $startRadian 0\
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

proc pie::sizeSlice {id sliceId perCent} {
    # in per cent of whole pie
    global pie slice twoPI

    if {[set index [lsearch $pie($id,slices) $sliceId]]<0} {
        error "could not find slice $sliceId in pie $id slices"
    }
    pieLabeller::setValue $pie($id,labeller) $pie($id,sliceLabel,$sliceId) $perCent
    # cannot display slices that occupy more than 100%
    set perCent [minimum $perCent 100]
    set newExtent [expr $perCent*$twoPI/100]
    set growth [expr $newExtent-$slice($sliceId,extent)]
    # grow clockwise
    slice::update $sliceId [expr $slice($sliceId,start)-$growth] $newExtent
    # finally move the following slices
    set radian [expr -1*$growth]
    foreach sliceId [lrange $pie($id,slices) [incr index] end] {
        slice::rotate $sliceId $radian
    }
}
