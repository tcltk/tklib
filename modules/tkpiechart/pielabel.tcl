set rcsId {$Id: pielabel.tcl,v 1.6 1995/10/01 16:45:12 jfontain Exp $}

source canlabel.tcl

proc pieLabeller::pieLabeller {id pieId args} {
    global pie
    allowVirtualProceduresIn pieLabeller

    # set options default then parse switched options
    array set option {-offset 5}
    array set option $args

    set pieLabeller($id,offset) [winfo fpixels $pie($pieId,canvas) $option(-offset)]
    catch {set pieLabeller($id,font) $option(-font)}
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
    if {[lsearch -exact $args -font]<0} {
        # eventually use main font if not overridden
        catch {lappend args -font $pieLabeller($id,font)}
    }
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

