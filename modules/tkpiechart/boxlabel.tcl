set rcsId {$Id: boxlabel.tcl,v 1.2 1995/09/26 17:08:33 jfontain Exp $}

source pielabel.tcl

proc pieBoxLabeller::pieBoxLabeller {id pieId args} {
    eval pieLabeller::pieLabeller $id $pieId $args
}

proc pieBoxLabeller::~pieBoxLabeller {id} {}

proc pieBoxLabeller::create {id text} {
    global pie pieLabeller

    set pieId $pieLabeller($id,pie)
    set canvas $pie($pieId,canvas)
    set box [$canvas bbox pieGraphics($pieId)]
    set number [llength [$canvas find withtag pieLabeller($id)]]

    set x [expr (1+(2*($number%2)))*([lindex $box 2]-[lindex $box 0])/4]
    set y [expr [lindex $box 3]+$pieLabeller($id,offset)+(($number/2)*$pieLabeller($id,fontHeight))]
    return [$canvas create text $x $y -text $text -font $pieLabeller($id,font) -anchor n]
}
