set rcsId {$Id: pielabel.tcl,v 1.16 1995/10/10 21:08:42 jfontain Exp $}

proc pieLabeller::pieLabeller {id canvas args} {
    allowVirtualProceduresIn pieLabeller

    # set options default then parse switched options
    array set option {-offset 5}
    array set option $args

    # convert offset to pixel
    set pieLabeller($id,offset) [winfo fpixels $canvas $option(-offset)]
    catch {set pieLabeller($id,font) $option(-font)}
    set pieLabeller($id,canvas) $canvas
}

proc pieLabeller::~pieLabeller {id} {
    virtualCallFrom pieLabeller
}

proc pieLabeller::bind {id pieId} {
    global pieLabeller

    set pieLabeller($id,pieId) $pieId
}

proc pieLabeller::create {id sliceId args} {
    # as this function is generic, it accepts only a few options, such as: -text, -background
    return [virtualCallFrom pieLabeller]
}

proc pieLabeller::update {id label value} {
    virtualCallFrom pieLabeller
}

proc pieLabeller::rotate {id label} {
    virtualCallFrom pieLabeller
}

