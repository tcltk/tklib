set rcsId {$Id: perilabel.tcl,v 1.3 1995/10/05 20:24:11 jfontain Exp $}

source pielabel.tcl

proc piePeripheralLabeller::piePeripheralLabeller {id canvas args} {
    eval pieLabeller::pieLabeller $id $canvas $args
}

proc piePeripheralLabeller::~piePeripheralLabeller {id} {}

proc piePeripheralLabeller::position {id labelId} {}
