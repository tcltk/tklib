set rcsId {$Id: boxlabel.tcl,v 1.8 1995/10/05 21:06:56 jfontain Exp $}

source pielabel.tcl

proc pieBoxLabeller::pieBoxLabeller {id canvas args} {
    eval pieLabeller::pieLabeller $id $canvas $args
}

proc pieBoxLabeller::~pieBoxLabeller {id} {}

proc pieBoxLabeller::position {id labelId} {
    global pieLabeller

    set canvas $pieLabeller($id,canvas)
    set graphicsBox [$canvas bbox pieGraphics($pieLabeller($id,pieId))]
    set labelBox [$canvas bbox canvasLabel($labelId)]
    set index [expr [llength $pieLabeller($id,labelIds)]-1]

    # arrange labels in two columns
    set x [expr [lindex $graphicsBox 0]+(1.0+(2*($index%2)))*([lindex $graphicsBox 2]-[lindex $graphicsBox 0])/4]
    set y [expr [lindex $graphicsBox 3]+$pieLabeller($id,offset)+(($index/2)*([lindex $labelBox 3]-[lindex $labelBox 1]))]

    canvasLabel::configure $labelId -anchor n
    $canvas move canvasLabel($labelId) $x $y
}

