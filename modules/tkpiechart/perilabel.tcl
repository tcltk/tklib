set rcsId {$Id: perilabel.tcl,v 1.4 1995/10/05 22:23:45 jfontain Exp $}

source pielabel.tcl

proc piePeripheralLabeller::piePeripheralLabeller {id canvas args} {
    eval pieLabeller::pieLabeller $id $canvas $args
}

proc piePeripheralLabeller::~piePeripheralLabeller {id} {}

proc piePeripheralLabeller::create {id sliceId args} {}

proc piePeripheralLabeller::update {id labelId value} {}
