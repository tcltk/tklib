set rcsId {$Id: boxlabel.tcl,v 1.12 1995/10/08 21:38:42 jfontain Exp $}

source pielabel.tcl

proc pieBoxLabeller::pieBoxLabeller {id canvas args} {
    global pieBoxLabeller

    eval pieLabeller::pieLabeller $id $canvas $args

    # set options default then parse switched options
    array set option {-justify left}
    array set option $args
    set pieBoxLabeller($id,justify) $option(-justify)
}

proc pieBoxLabeller::~pieBoxLabeller {id} {
    global pieBoxLabeller

    foreach label $pieBoxLabeller($id,labelIds) {
        delete canvasLabel $label
    }
}

proc pieBoxLabeller::create {id sliceId args} {
    global pieBoxLabeller pieLabeller

    # eventually use labeller font
    catch {lappend args -font $pieLabeller($id,font)}
    set labelId [eval new canvasLabel $pieLabeller($id,canvas) 0 0 $args]
    # always append semi-column to label
    canvasLabel::configure $labelId -text [canvasLabel::cget $labelId -text]:
    $pieLabeller($id,canvas) addtag pieLabeller($id) withtag canvasLabel($labelId)
    lappend pieBoxLabeller($id,labelIds) $labelId
    pieBoxLabeller::position $id $labelId
    return $labelId
}

proc pieBoxLabeller::position {id labelId} {
    global pieBoxLabeller pieLabeller

    set canvas $pieLabeller($id,canvas)

    set labelBox [$canvas bbox canvasLabel($labelId)]
    set labelHeight [expr [lindex $labelBox 3]-[lindex $labelBox 1]]

    set index [expr [llength $pieBoxLabeller($id,labelIds)]-1]

    set graphicsBox [$canvas bbox pieGraphics($pieLabeller($id,pieId))]
    set left [lindex $graphicsBox 0]
    set bottom [lindex $graphicsBox 3]
    set width [expr [lindex $graphicsBox 2]-$left]

    # arrange labels in two columns
    set y [expr $bottom+$pieLabeller($id,offset)+(($index/2)*$labelHeight)]
    switch $pieBoxLabeller($id,justify) {
        left {
            set x [expr $left+(($index%2)*($width/2.0))]
            canvasLabel::configure $labelId -anchor nw
        }
        right {
            set x [expr $left+((($index%2)+1)*($width/2.0))]
            canvasLabel::configure $labelId -anchor ne
        }
        default {
            # should be center
            set x [expr $left+((1.0+(2*($index%2)))*$width/4)]
            canvasLabel::configure $labelId -anchor n
        }
    }
    $canvas move canvasLabel($labelId) $x $y
}

proc pieBoxLabeller::update {id labelId value} {
    regsub {:.*$} [canvasLabel::cget $labelId -text] ": $value" text
    canvasLabel::configure $labelId -text $text
}

proc pieBoxLabeller::rotate {id labelId} {}
