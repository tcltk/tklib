set rcsId {$Id: perilabel.tcl,v 1.1 1995/10/04 22:40:48 jfontain Exp $}

source pielabel.tcl

proc peripheralBoxLabeller::peripheralBoxLabeller {id canvas args} {
    eval pieLabeller::pieLabeller $id $canvas $args
}

proc peripheralBoxLabeller::~peripheralBoxLabeller {id} {}

proc peripheralBoxLabeller::position {id label} {}
