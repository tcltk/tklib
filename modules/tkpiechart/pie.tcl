# $Id: pie.tcl,v 1.6 1995/01/27 15:54:42 jfontain Exp $

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

proc pie::pie {id parentWidget width height {thickness 0} {topColor ""} {bottomColor ""} {highlight auto}} {
    # slice / label highlighting can be automatic when slices of identical colors exist (auto), or on or off (boolean) no matter
    # the number of slices
    global pie PI

    set pie($id,radiusX) [set radiusX [expr [winfo fpixels $parentWidget $width]/2.0]]
    set pie($id,radiusY) [set radiusY [expr [winfo fpixels $parentWidget $height]/2.0]]
    set pie($id,thickness) [set thickness [winfo fpixels $parentWidget $thickness]]

    set pie($id,frame) [frame [objectWidgetName pie $id $parentWidget] -bd 0]

    set canvas [canvas $pie($id,frame).canvas]
    set pie($id,canvas) $canvas
    pack $canvas

    pack [frame $pie($id,frame).separator -height $pie(separatorHeight)]
    # arrange slice labels in rows of 2 entries
    pack [frame $pie($id,frame).entriesFrame] -fill x
    pack [frame $pie($id,frame).entriesFrame.leftFrame] -side left -fill both -expand 1
    pack [frame $pie($id,frame).entriesFrame.rightFrame] -side right -fill both -expand 1
    set pie($id,automaticHighlight) [expr [string compare [string tolower $highlight] auto]==0]
    if {$pie($id,automaticHighlight)} {
        # no need to highlight first slices
        set pie($id,highlight) 0
    } else {
        set pie($id,highlight) [boolean $highlight]
    }
    set pie($id,backgroundSlice) [new slice $canvas $radiusX $radiusY [expr $PI/2] 7 $thickness $topColor $bottomColor]
    set pie($id,slices) ""

    showWholeCanvas $canvas
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
    set numberOfSlices [llength $pie($id,slices)]
    if {$text==""} {
        # generate label text if not provided
        set text "slice [expr $numberOfSlices+1]"
    }
    # arrange slice labels in rows of 2 entries
    # put even numbered entries of the left side, odd ones on the right side, in order to fill entries row by row
    set side [expr ($numberOfSlices%2)==0?"left":"right"]
    set rowFrame [frame [objectWidgetName row [expr $numberOfSlices/2] $pie($id,frame).entriesFrame.${side}Frame] -bd 2]
    pack $rowFrame -fill x -padx 15

    set sliceId [new slice\
        $pie($id,canvas) $pie($id,radiusX) $pie($id,radiusY) $startRadian 0 $pie($id,thickness)\
        $pie(lights,$color) $pie(darks,$color)\
    ]
    set pie($id,$sliceId,rowFrame) $rowFrame

    global normalFont boldFont
    set pie($id,$sliceId,label) [\
        label [objectWidgetName text $sliceId $rowFrame]\
            -background $pie(lights,$color) -foreground black -relief raised -text $text -font $normalFont -bd 1 -padx 2\
    ]
    pack $pie($id,$sliceId,label) -side left
    pack [frame [objectWidgetName spacer $sliceId $rowFrame]] -side left -fill both -expand 1

    set pie($id,$sliceId,valueLabel) [label [objectWidgetName value $sliceId $rowFrame] -text 0 -font $boldFont -bd 1]
    pack $pie($id,$sliceId,valueLabel) -side right
    lappend pie($id,slices) $sliceId

    if {$pie($id,highlight)} {
        # highlight by changing row frame background color, unhighlight by reversing to original background
        slice::setupHighlighting $sliceId "$rowFrame configure -background black"\
            "$rowFrame configure -background [$rowFrame cget -background]"
    } else {
        if {$pie($id,automaticHighlight)&&([llength $pie($id,slices)]>[llength $pie(colors)])} {
            # if automatic highlight and number of colors exhausted, highlight from now on
            set pie($id,highlight) 1
            # setup highlighting on current slices
            foreach currentId $pie($id,slices) {
                set rowFrame $pie($id,$currentId,rowFrame)
                slice::setupHighlighting $currentId "$rowFrame configure -background black"\
                     "$rowFrame configure -background [$rowFrame cget -background]"
            }
        }
    }

    return $sliceId
}

proc pie::sizeSlice {id sliceId perCent} {
    # in per cent of whole pie
    global pie

    if {[set index [lsearch $pie($id,slices) $sliceId]]<0} {
        error "could not find slice $sliceId in pie $id slices"
    }
    $pie($id,$sliceId,valueLabel) configure -text $perCent
    # cannot display slices that occupy more than 100%
    set perCent [minimum $perCent 100]
    global slice twoPI
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
