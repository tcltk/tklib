set rcsId {$Id: pielabel.tcl,v 1.1 1995/09/26 12:54:05 jfontain Exp $}

proc pieLabeller::pieLabeller {id pie args} {
    allowVirtualProceduresIn pieLabeller

    # set options default then parse switched options
    array set option {-font -adobe-helvetica-medium-r-*-120-*}
    array set option $args

    set pieLabeller($id,font) $option(-font)
    set pieLabeller($id,pie) $pie
}

proc pieLabeller::~pieLabeller {id} {
    virtualCallFrom pieLabeller

    global pie
    $pie($pieLabeller($id,pie),canvas) delete pieLabeller($id)
}

proc pieLabeller::create {id text} {
    global pie pieLabeller

    $pie($pieLabeller($id,pie),canvas) addtag pieLabeller($id) withtag [virtualCallFrom pieLabeller]
}
