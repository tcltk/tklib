set rcsId {$Id: boxlabel.tcl,v 1.4 1995/10/04 22:23:42 jfontain Exp $}

source pielabel.tcl

proc pieBoxLabeller::pieBoxLabeller {id canvas args} {
    eval pieLabeller::pieLabeller $id $canvas $args
}

proc pieBoxLabeller::~pieBoxLabeller {id} {}

proc pieBoxLabeller::position {id label} {
    global pie pieLabeller

    set pieId $pieLabeller($id,pie)
    set canvas $pie($pieId,canvas)
    set graphicsBox [$canvas bbox pieGraphics($pieId)]
    set labelBox [$canvas bbox canvasLabel($label)]
    set index [expr [llength $pieLabeller($id,labels)]-1]

    # arrange labels in two columns
    set x [expr [lindex $graphicsBox 0]+(1.0+(2*($index%2)))*([lindex $graphicsBox 2]-[lindex $graphicsBox 0])/4]
    set y [expr [lindex $graphicsBox 3]+$pieLabeller($id,offset)+(($index/2)*([lindex $labelBox 3]-[lindex $labelBox 1]))]

    canvasLabel::configure $label -anchor n
    $canvas move canvasLabel($label) $x $y
}

