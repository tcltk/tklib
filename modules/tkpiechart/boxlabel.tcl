set rcsId {$Id: boxlabel.tcl,v 1.10 1995/10/06 10:54:41 jfontain Exp $}

source pielabel.tcl

proc pieBoxLabeller::pieBoxLabeller {id canvas args} {
    eval pieLabeller::pieLabeller $id $canvas $args
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
    set graphicsBox [$canvas bbox pieGraphics($pieLabeller($id,pieId))]
    set labelBox [$canvas bbox canvasLabel($labelId)]
    set index [expr [llength $pieBoxLabeller($id,labelIds)]-1]

    # arrange labels in two columns
    set x [expr [lindex $graphicsBox 0]+(1.0+(2*($index%2)))*([lindex $graphicsBox 2]-[lindex $graphicsBox 0])/4]
    set y [expr [lindex $graphicsBox 3]+$pieLabeller($id,offset)+(($index/2)*([lindex $labelBox 3]-[lindex $labelBox 1]))]

    canvasLabel::configure $labelId -anchor n
    $canvas move canvasLabel($labelId) $x $y
}

proc pieBoxLabeller::update {id labelId value} {
    regsub {:.*$} [canvasLabel::cget $labelId -text] ": $value" text
    canvasLabel::configure $labelId -text $text
}
