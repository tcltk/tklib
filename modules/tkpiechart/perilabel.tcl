set rcsId {$Id: perilabel.tcl,v 1.2 1995/10/04 23:00:10 jfontain Exp $}

source pielabel.tcl

proc piePeripheralLabeller::piePeripheralLabeller {id canvas args} {
    eval pieLabeller::pieLabeller $id $canvas $args
}

proc piePeripheralLabeller::~piePeripheralLabeller {id} {}

proc piePeripheralLabeller::position {id label} {}
