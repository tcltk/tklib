set rcsId {$Id: boxlabel.tcl,v 1.6 1995/10/05 20:41:03 jfontain Exp $}

source pielabel.tcl

proc pieBoxLabeller::pieBoxLabeller {id canvas args} {
    eval pieLabeller::pieLabeller $id $canvas $args
}

proc pieBoxLabeller::~pieBoxLabeller {id} {}

proc pieBoxLabeller::position {id labelId} {
    global pie pieLabeller

    set pieId $pieLabeller($id,pieId)
    set canvas $pie($pieId,canvas)
    set graphicsBox [$canvas bbox pieGraphics($pieId)]
    set labelBox [$canvas bbox canvasLabel($labelId)]
    set index [expr [llength $pieLabeller($id,labels)]-1]

    # arrange labels in two columns
    set x [expr [lindex $graphicsBox 0]+(1.0+(2*($index%2)))*([lindex $graphicsBox 2]-[lindex $graphicsBox 0])/4]
    set y [expr [lindex $graphicsBox 3]+$pieLabeller($id,offset)+(($index/2)*([lindex $labelBox 3]-[lindex $labelBox 1]))]

    canvasLabel::configure $labelId -anchor n
    $canvas move canvasLabel($labelId) $x $y
}

