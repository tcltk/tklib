set rcsId {$Id: pielabel.tcl,v 1.4 1995/09/28 20:36:09 jfontain Exp $}

source canlabel.tcl

proc pieLabeller::pieLabeller {id pieId args} {
    global pie
    allowVirtualProceduresIn pieLabeller

    # set options default then parse switched options
    array set option {-offset 5}
    array set option $args

    set pieLabeller($id,offset) $option(-offset)
    set pieLabeller($id,pie) $pieId
}

proc pieLabeller::~pieLabeller {id} {
    virtualCallFrom pieLabeller

    foreach label $pieLabeller($id,labels) {
        delete canvasLabel $label
    }
}

proc pieLabeller::create {id args} {
    global pie pieLabeller

    set canvas $pie($pieLabeller($id,pie),canvas)
    set label [eval new canvasLabel $canvas 0 0 $args]
    # always append semi-column to label
    canvasLabel::configure $label -text [canvasLabel::cget $label -text]:
    $canvas addtag pieLabeller($id) withtag canvasLabel($label)
    lappend pieLabeller($id,labels) $label
    pieLabeller::position $id $label
    return $label
}

proc pieLabeller::position {id label} {
    virtualCallFrom pieLabeller
}

proc pieLabeller::setValue {id label value} {
    regsub {:.*$} [canvasLabel::cget $label -text] ": $value" text
    canvasLabel::configure $label -text $text
}

