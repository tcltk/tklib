set rcsId {$Id: pielabel.tcl,v 1.2 1995/09/26 17:07:35 jfontain Exp $}

proc pieLabeller::pieLabeller {id pieId args} {
    global pie
    allowVirtualProceduresIn pieLabeller

    # set options default then parse switched options
    array set option {-font -adobe-helvetica-medium-r-*-120-* -offset 5}
    array set option $args

    set pieLabeller($id,font) $option(-font)
    set pieLabeller($id,offset) $option(-offset)

    set canvas $pie($pieId,canvas)
    set temporary [$canvas create text 0 0 -font $pieLabeller($id,font)]
    set box [$canvas bbox $temporary]
    $canvas delete $temporary
    set pieLabeller($id,fontHeight) [expr [lindex $box 3]-[lindex $box 1]]
    set pieLabeller($id,pie) $pieId
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
