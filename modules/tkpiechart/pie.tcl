# $Id: pie.tcl,v 1.1 1994/07/25 09:59:46 jfontain Exp $

source ../tools/slice.tcl

set pie(lights,red) "#FF7F7F"
set pie(lights,green) "#7FFF7F"
set pie(lights,blue) "#7F7FFF"
set pie(lights,cyan) "#7FFFFF"
set pie(lights,magenta) "#FF7FFF"
set pie(lights,yellow) "#FFFF7F"
set pie(lights,white) "#FFFFFF"
set pie(lights,gray) "#BFBFBF"
set pie(lights,orange) "#FFBF00"
set pie(darks,red) "#BF0000"
set pie(darks,green) "#00BF00"
set pie(darks,blue) "#0000BF"
set pie(darks,cyan) "#00BFBF"
set pie(darks,magenta) "#BF00BF"
set pie(darks,yellow) "#BFBF00"
set pie(darks,white) "#BFBFBF"
set pie(darks,gray) "#7F7F7F"
set pie(darks,orange) "#BF7F00"
set pie(colors) "cyan green red yellow blue orange gray magenta white"
set pie(separatorHeight) 5

proc pie::pie {id parentWidget radiusX radiusY {height 0} {topColor ""} {bottomColor ""}} {
    global pie PI

    set pie($id,frame) [frame [objectWidgetName pie $id $parentWidget] -bd 0]
    set pie($id,canvas) [canvas $pie($id,frame).canvas -width [expr (2*$radiusX)+1] -height [expr (2*$radiusY)+$height+1]]
    pack $pie($id,canvas)
    pack [frame $pie($id,frame).separator -height $pie(separatorHeight)]
    # arrange slice labels in rows of 2 entries
    pack [frame $pie($id,frame).entriesFrame] -fill x
    pack [frame $pie($id,frame).entriesFrame.leftFrame] -side left -fill both -expand 1
    pack [frame $pie($id,frame).entriesFrame.rightFrame] -side right -fill both -expand 1
    set pie($id,radiusX) $radiusX
    set pie($id,radiusY) $radiusY
    set pie($id,height) $height
    set pie($id,backgroundSlice)\
        [new slice $pie($id,canvas) $radiusX $radiusY $radiusX $radiusY [expr $PI/2] 7 $height $topColor $bottomColor]
    set pie($id,slices) ""
}

proc pie::~pie {id} {
    global pie

    foreach sliceId $pie($id,slices) {
        delete slice $sliceId
    }
    destroy $pie($id,frame)
}

proc pie::newSlice {id {text ""}} {
    global pie slice halfPI

    # calculate start radian for new slice (slices grow clockwise from 12 o'clock)
    set startRadian $halfPI
    foreach sliceId $pie($id,slices) {
        set startRadian [expr $startRadian-$slice($sliceId,extent)]
    }
    # get a new color
    set color [lindex $pie(colors) [expr [llength $pie($id,slices)]%[llength $pie(colors)]]]
    if {$text==""} {
        # generate label text if not provided
        set text "slice [llength $pie($id,slices)]"
    }
    # arrange slice labels in rows of 2 entries
    set numberOfSlices [llength $pie($id,slices)]
    # put even numbered entries of the left side, odd ones on the right side, in order to fill entries row by row
    set side [expr ($numberOfSlices%2)==0?"left":"right"]
    set rowFrame [frame [objectWidgetName row [expr $numberOfSlices/2] $pie($id,frame).entriesFrame.${side}Frame]]
    pack $rowFrame -fill x -padx 15

    set sliceId [new slice\
        $pie($id,canvas) $pie($id,radiusX) $pie($id,radiusY) $pie($id,radiusX) $pie($id,radiusY) $startRadian 0\
        $pie($id,height) $pie(lights,$color) $pie(darks,$color)\
    ]
    global normalFont boldFont
    set pie($id,$sliceId,label) [\
        label [objectWidgetName text $sliceId $rowFrame]\
            -background $pie(lights,$color) -relief raised -bd 1 -text $text -font $normalFont -padx 2\
    ]
    pack $pie($id,$sliceId,label) -side left
    pack [set pie($id,$sliceId,valueLabel) [label [objectWidgetName value $sliceId $rowFrame] -text 0 -font $boldFont]] -side right

    lappend pie($id,slices) $sliceId
    return $sliceId
}

proc pie::sizeSlice {id sliceId perCent} {
    # in per cent of whole pie
    global pie

    if {[set index [lsearch $pie($id,slices) $sliceId]]<0} {
        error "could not find slice $sliceId in pie $id slices"
    }
    $pie($id,$sliceId,valueLabel) configure -text $perCent
    global slice twoPI
    set newExtent [expr $perCent*$twoPI/100]
