set rcsId {$Id: boxlabel.tcl,v 1.1 1995/09/26 12:54:05 jfontain Exp $}

source pielabel.tcl

proc pieBoxLabeller::pieBoxLabeller {id pie} {
    pieLabeller::pieLabeller $id $pie
}

proc pieBoxLabeller::~pieBoxLabeller {id} {}

proc pieBoxLabeller::create {id text} {
    global pie pieLabeller

    set pieId $pieLabeller($id,pie)
    set canvas $pie($pieId,canvas)
    set box [$canvas bbox pieGraphics($pieId)]
    set number [llength [$canvas find withtag pieLabeller($id)]]

    if {($number%2)==0} {
        set x [lindex $box 0]
    } else {
        set x [expr ([lindex $box 2]-[lindex $box 0])/2]
    }
    set y [expr [lindex $box 3]+($number/2)*20]
    return [$canvas create text $x $y -text $text -font $pieLabeller($id,font) -anchor nw]
}
