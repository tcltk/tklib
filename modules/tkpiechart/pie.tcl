set rcsId {$Id: pie.tcl,v 1.82 1998/11/14 20:35:29 jfontain Exp $}

package provide tkpiechart 5.2.1

class pie {
    set pie::(colors) {#7FFFFF #7FFF7F #FF7F7F #FFFF7F #7F7FFF #FFBF00 #BFBFBF #FF7FFF #FFFFFF}
}

proc pie::pie {this canvas x y args} switched {$args} {                         ;# note: all pie elements are tagged with pie($this)
    set pie::($this,canvas) $canvas
    set pie::($this,colorIndex) 0
    set pie::($this,slices) {}
    # use an empty image as an origin marker with only 2 coordinates
    set pie::($this,origin) [$canvas create image $x $y -tags pie($this)]
    switched::complete $this
    complete $this                                                  ;# wait till all options have been set for initial configuration
}

proc pie::~pie {this} {
    if {[info exists pie::($this,title)]} {                                                                   ;# title may not exist
        $pie::($this,canvas) delete $pie::($this,title)
    }
    delete $pie::($this,labeler)
    eval delete $pie::($this,slices) $pie::($this,backgroundSlice)
    if {[info exists pie::($this,selector)]} {                                                             ;# selector may not exist
        delete $pie::($this,selector)
    }
    $pie::($this,canvas) delete $pie::($this,origin)
}

proc pie::options {this} {
    # force height, thickness title font and width options so that corresponding members are properly initialized
    return [list\
        [list -background {} {}]\
        [list -colors $pie::(colors) $pie::(colors)]\
        [list -height 200]\
        [list -labeler 0 0]\
        [list -selectable 0 0]\
        [list -thickness 0]\
        [list -title {} {}]\
        [list -titlefont {Helvetica -12 bold} {Helvetica -12 bold}]\
        [list -titleoffset 2 2]\
        [list -width 200]\
    ]
}

# no dynamic options allowed: see complete
foreach option {-background -colors -labeler -selectable -title -titlefont -titleoffset} {
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

# size is first converted to pixels, then 1 pixel is subtracted since slice size is half the pie size and pie center takes 1 pixel
proc pie::set-height {this value} {                                                ;# height is slices height not counting thickness
    set pie::($this,height) [expr {[winfo fpixels $pie::($this,canvas) $value]-1}]
    if {$switched::($this,complete)} {
        update $this
    } else {
        set pie::($this,initialHeight) $pie::($this,height)           ;# keep track of initial value for latter scaling calculations
    }
}
proc pie::set-width {this value} {
    set pie::($this,width) [expr {[winfo fpixels $pie::($this,canvas) $value]-1}]
    if {$switched::($this,complete)} {
        update $this
    } else {
        set pie::($this,initialWidth) $pie::($this,width)             ;# keep track of initial value for latter scaling calculations
    }
}

proc pie::complete {this} {                                                                              ;# no user slices exist yet
    set canvas $pie::($this,canvas)

    if {$switched::($this,-labeler)==0} {
        set pie::($this,labeler) [new pieBoxLabeler $canvas]                             ;# use default labeler if user defined none
    } else {
        set pie::($this,labeler) $switched::($this,-labeler)                                             ;# use user defined labeler
    }
    $canvas addtag pie($this) withtag pieLabeler($pie::($this,labeler))

    if {[string length $switched::($this,-background)]==0} {
        set bottomColor {}
    } else {
        set bottomColor [tkDarken $switched::($this,-background) 60]
    }
    set slice [new slice\
        $canvas [expr {$pie::($this,initialWidth)/2}] [expr {$pie::($this,initialHeight)/2}]\
        -startandextent {90 360} -height $pie::($this,thickness) -topcolor $switched::($this,-background) -bottomcolor $bottomColor\
    ]
    $canvas addtag pie($this) withtag slice($slice)
    $canvas addtag pieSlices($this) withtag slice($slice)
    set pie::($this,backgroundSlice) $slice
    if {[string length $switched::($this,-title)]==0} {
        set pie::($this,titleRoom) 0
    } else {
        set pie::($this,title) [$canvas create text 0 0\
            -anchor n -text $switched::($this,-title) -font $switched::($this,-titlefont) -tags pie($this)\
        ]
        set pie::($this,titleRoom) [expr {\
            [font metrics $switched::($this,-titlefont) -ascent]+[winfo fpixels $canvas $switched::($this,-titleoffset)]\
        }]
    }
    update $this
}

proc pie::newSlice {this {text {}}} {
    set canvas $pie::($this,canvas)

    set start 90                                     ;# calculate start radian for new slice (slices grow clockwise from 12 o'clock)
    foreach slice $pie::($this,slices) {
        set start [expr {$start-$slice::($slice,extent)}]
    }
    set color [lindex $switched::($this,-colors) $pie::($this,colorIndex)]                                        ;# get a new color
    set pie::($this,colorIndex) [expr {($pie::($this,colorIndex)+1)%[llength $switched::($this,-colors)]}]  ;# circle through colors

    # darken slice top color by 40% to obtain bottom color, as it is done for Tk buttons shadow, for example
    set slice [new slice\
        $canvas [expr {$pie::($this,initialWidth)/2}] [expr {$pie::($this,initialHeight)/2}] -startandextent "$start 0"\
        -height $pie::($this,thickness) -topcolor $color -bottomcolor [tkDarken $color 60]\
    ]
    eval $canvas move slice($slice) [$canvas coords pieSlices($this)]  ;# place slice at other slices position in case pie was moved
    $canvas addtag pie($this) withtag slice($slice)
    $canvas addtag pieSlices($this) withtag slice($slice)
    lappend pie::($this,slices) $slice

    if {[string length $text]==0} {                                                           ;# generate label text if not provided
        set text "slice [llength $pie::($this,slices)]"
    }
    set labeler $pie::($this,labeler)
    set label [pieLabeler::new $labeler $slice -text $text -background $color]
    set pie::($this,sliceLabel,$slice) $label
    $canvas addtag pie($this) withtag pieLabeler($labeler)                     ;# update tags which canvas does not automatically do

    update $this

    if {$switched::($this,-selectable)} {                                             ;# toggle select state at every button release
        if {![info exists pie::($this,selector)]} {                                                  ;# create selector if necessary
            set pie::($this,selector) [new objectSelector -selectcommand "pie::setLabelsState $this"]
        }
        set selector $pie::($this,selector)
        selector::add $selector $label
        $canvas bind canvasLabel($label) <ButtonRelease-1> "selector::select $selector $label"
        $canvas bind slice($slice) <ButtonRelease-1> "selector::select $selector $label"
        $canvas bind canvasLabel($label) <Control-ButtonRelease-1> "selector::toggle $selector $label"
        $canvas bind slice($slice) <Control-ButtonRelease-1> "selector::toggle $selector $label"
        $canvas bind canvasLabel($label) <Shift-ButtonRelease-1> "selector::extend $selector $label"
        $canvas bind slice($slice) <Shift-ButtonRelease-1> "selector::extend $selector $label"
    }

    return $slice
}

proc pie::deleteSlice {this slice} {
    set index [lsearch -exact $pie::($this,slices) $slice]
    if {$index<0} {
        error "invalid slice $slice for pie $this"
    }
    set pie::($this,slices) [lreplace $pie::($this,slices) $index $index]
    set extent $slice::($slice,extent)
    delete $slice
    foreach following [lrange $pie::($this,slices) $index end] {                     ;# rotate the following slices counterclockwise
        slice::rotate $following $extent
    }
    # finally delete label last so that other labels may eventually be repositionned according to remaining slices placement
    pieLabeler::delete $pie::($this,labeler) $pie::($this,sliceLabel,$slice)
    if {$switched::($this,-selectable)} {
        selector::remove $pie::($this,selector) $pie::($this,sliceLabel,$slice)
    }
    unset pie::($this,sliceLabel,$slice)
    update $this
}

proc pie::sizeSlice {this slice unitShare {valueToDisplay {}}} {
    set index [lsearch -exact $pie::($this,slices) $slice]
    if {$index<0} {
        error "invalid slice $slice for pie $this"
    }
    # cannot display slices that occupy more than whole pie and less than zero
    set newExtent [expr {[maximum [minimum $unitShare 1] 0]*360}]
    set growth [expr {$newExtent-$slice::($slice,extent)}]
    switched::configure $slice -startandextent "[expr {$slice::($slice,start)-$growth}] $newExtent"                ;# grow clockwise

    if {[string length $valueToDisplay]>0} {                  ;# update label after slice for it may need slice latest configuration
        pieLabeler::set $pie::($this,labeler) $pie::($this,sliceLabel,$slice) $valueToDisplay
    } else {
        pieLabeler::set $pie::($this,labeler) $pie::($this,sliceLabel,$slice) $unitShare
    }

    set value [expr {-1*$growth}]                                                               ;# finally move the following slices
    foreach slice [lrange $pie::($this,slices) [incr index] end] {
        slice::rotate $slice $value
    }
}

proc pie::selectedSlices {this} {                                                      ;# return a list of currently selected slices
    set list {}
    foreach slice $pie::($this,slices) {
        if {[pieLabeler::selectState $pie::($this,labeler) $pie::($this,sliceLabel,$slice)]} {
            lappend list $slice
        }
    }
    return $list
}

proc pie::setLabelsState {this labels selected} {
    set labeler $pie::($this,labeler)
    foreach label $labels {
        pieLabeler::selectState $labeler $label $selected
    }
}

proc pie::currentSlice {this} {                           ;# return current slice (slice or its label under the mouse cursor) if any
    set tags [$pie::($this,canvas) gettags current]
    if {[scan $tags slice(%u) slice]>0} {
        return $slice                                                                                         ;# found current slice
    }
    if {[scan $tags canvasLabel(%u) label]>0} {
        foreach slice $pie::($this,slices) {
            if {$pie::($this,sliceLabel,$slice)==$label} {
                return $slice                                                                  ;# slice is current through its label
            }
        }
    }
    return 0                                                                                                     ;# no current slice
}

proc pie::update {this} {                         ;# place and scale slices along and with labels array in its current configuration
    set canvas $pie::($this,canvas)
    pieLabeler::room $pie::($this,labeler) room                                                     ;# take labels room into account
    foreach {x y} [$canvas coords $pie::($this,origin)] {}                                       ;# retrieve current pie coordinates
    foreach {xSlices ySlices} [$canvas coords pieSlices($this)] {}                  ;# move slices in order to leave room for labels
    $canvas move pieSlices($this) [expr {$x+$room(left)-$xSlices}] [expr {$y+$room(top)+$pie::($this,titleRoom)-$ySlices}]
    set scale [list\
        [expr {($pie::($this,width)-$room(left)-$room(right))/$pie::($this,initialWidth)}]\
        [expr {\
            ($pie::($this,height)-$room(top)-$room(bottom)-$pie::($this,titleRoom))/\
            ($pie::($this,initialHeight)+$pie::($this,thickness))\
        }]\
    ]
    switched::configure $pie::($this,backgroundSlice) -scale $scale                             ;# update scale of background slice,
    foreach slice $pie::($this,slices) {
        switched::configure $slice -scale $scale                                                                 ;# and other slices
    }
    if {$pie::($this,titleRoom)>0} {                                                                                 ;# title exists
        $canvas coords $pie::($this,title) [expr {$x+($pie::($this,width)/2)}] $y               ;# place text above pie and centered
    }
    # finally update labels now that pie graphics are in position
    pieLabeler::update $pie::($this,labeler) $x $y [expr {$x+$pie::($this,width)}] [expr {$y+$pie::($this,height)}]
}

class pie {                                                                                     ;# define various utility procedures
    proc maximum {a b} {return [expr {$a>$b?$a:$b}]}
    proc minimum {a b} {return [expr {$a<$b?$a:$b}]}
}
