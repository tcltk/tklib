set rcsId {$Id: pie.tcl,v 1.66 1998/04/25 10:08:46 jfontain Exp $}

package provide tkpiechart 4.3

class pie {
    set pie::(colors) {#7FFFFF #7FFF7F #FF7F7F #FFFF7F #7F7FFF #FFBF00 #BFBFBF #FF7FFF #FFFFFF}
}

proc pie::pie {this canvas x y width height args} switched {$args} {            ;# note: all pie elements are tagged with pie($this)
    set pie::($this,canvas) $canvas

    set pie::($this,x) [winfo fpixels $canvas $x]
    set pie::($this,y) [winfo fpixels $canvas $y]
    set pie::($this,radiusX) [expr {[winfo fpixels $canvas $width]/2.0}]
    set pie::($this,radiusY) [expr {[winfo fpixels $canvas $height]/2.0}]

    set pie::($this,colorIndex) 0
    set pie::($this,slices) {}

    switched::complete $this
    complete $this                                                  ;# wait till all options have been set for initial configuration
}

proc pie::~pie {this} {
    catch {$pie::($this,canvas) delete $pie::($this,title)}                                                   ;# title may not exist
    delete $pie::($this,labeler)
    eval delete $pie::($this,slices) $pie::($this,backgroundSlice)
    catch {delete $pie::($this,selector)}
}

proc pie::options {this} {
    # force thickness option so that corresponding pie member is properly initialized
    return [list\
        [list -background {} {}]\
        [list -colors $pie::(colors) $pie::(colors)]\
        [list -labeler 0 0]\
        [list -selectable 0 0]\
        [list -thickness 0]\
        [list -title {} {}]\
        [list -titlefont {} {}]\
        [list -titleoffset 2 2]\
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

proc pie::complete {this} {
    set canvas $pie::($this,canvas)

    if {$switched::($this,-labeler)==0} {
        set pie::($this,labeler) [new pieBoxLabeler $canvas]                             ;# use default labeler if user defined none
    } else {
        set pie::($this,labeler) $switched::($this,-labeler)                                             ;# use user defined labeler
    }
    $canvas addtag pie($this) withtag pieLabeler($pie::($this,labeler))
    pieLabeler::link $pie::($this,labeler) $this                                                            ;# link labeler with pie

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
    set canvas $pie::($this,canvas)

    set start 90                                     ;# calculate start radian for new slice (slices grow clockwise from 12 o'clock)
    foreach slice $pie::($this,slices) {
        set start [expr {$start-$slice::($slice,extent)}]
    }
    set color [lindex $switched::($this,-colors) $pie::($this,colorIndex)]                                        ;# get a new color
    set pie::($this,colorIndex) [expr {($pie::($this,colorIndex)+1)%[llength $switched::($this,-colors)]}]  ;# circle through colors

    # make sure slice is positioned correctly in case pie was moved
    set coordinates [$canvas coords slice($pie::($this,backgroundSlice))]

    # darken slice top color by 40% to obtain bottom color, as it is done for Tk buttons shadow, for example
    set slice [new slice\
        $canvas [lindex $coordinates 0] [lindex $coordinates 1] $pie::($this,radiusX) $pie::($this,radiusY) $start 0\
        -height $pie::($this,thickness) -topcolor $color -bottomcolor [tkDarken $color 60]\
    ]
    $canvas addtag pie($this) withtag slice($slice)
    $canvas addtag pieGraphics($this) withtag slice($slice)
    lappend pie::($this,slices) $slice

    if {[string length $text]==0} {                                                           ;# generate label text if not provided
        set text "slice [llength $pie::($this,slices)]"
    }
    set labeler $pie::($this,labeler)
    set label [pieLabeler::new $labeler $slice -text $text -background $color]
    set pie::($this,sliceLabel,$slice) $label
    $canvas addtag pie($this) withtag pieLabeler($labeler)                     ;# update tags which canvas does not automatically do

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
}

proc pie::sizeSlice {this slice unitShare {valueToDisplay {}}} {
    set index [lsearch -exact $pie::($this,slices) $slice]
    if {$index<0} {
        error "invalid slice $slice for pie $this"
    }
    # cannot display slices that occupy more than whole pie and less than zero
    set newExtent [expr {[maximum [minimum $unitShare 1] 0]*360}]
    set growth [expr {$newExtent-$slice::($slice,extent)}]
    slice::update $slice [expr {$slice::($slice,start)-$growth}] $newExtent                                        ;# grow clockwise

    if {[string length $valueToDisplay]>0} {                  ;# update label after slice for it may need slice latest configuration
        pieLabeler::update $pie::($this,labeler) $pie::($this,sliceLabel,$slice) $valueToDisplay
    } else {
        pieLabeler::update $pie::($this,labeler) $pie::($this,sliceLabel,$slice) $unitShare
    }

    set value [expr {-1*$growth}]                                                               ;# finally move the following slices
    foreach slice [lrange $pie::($this,slices) [incr index] end] {
        slice::rotate $slice $value
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

class pie {                                                                                     ;# define various utility procedures
    proc maximum {a b} {return [expr {$a>$b?$a:$b}]}
    proc minimum {a b} {return [expr {$a<$b?$a:$b}]}
}
