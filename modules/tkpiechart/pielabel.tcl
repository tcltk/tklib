set rcsId {$Id: pielabel.tcl,v 1.12 1995/10/05 21:09:58 jfontain Exp $}

source canlabel.tcl

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

    foreach label $pieLabeller($id,labelIds) {
        delete canvasLabel $label
    }
}

proc pieLabeller::bind {id pieId} {
    global pieLabeller

    set pieLabeller($id,pieId) $pieId
}

proc pieLabeller::create {id sliceId args} {
    global pieLabeller

    if {[lsearch -exact $args -font]<0} {
        # eventually use main font if not overridden
        catch {lappend args -font $pieLabeller($id,font)}
    }
    set labelId [eval new canvasLabel $pieLabeller($id,canvas) 0 0 $args]
    # always append semi-column to label
    canvasLabel::configure $labelId -text [canvasLabel::cget $labelId -text]:
    $pieLabeller($id,canvas) addtag pieLabeller($id) withtag canvasLabel($labelId)
    lappend pieLabeller($id,labelIds) $labelId
    # save related slice
    set pieLabeller($id,sliceId,$labelId) $sliceId
    pieLabeller::position $id $labelId
    return $labelId
}

proc pieLabeller::position {id labelId} {
    virtualCallFrom pieLabeller
}

proc pieLabeller::update {id label value} {
    regsub {:.*$} [canvasLabel::cget $label -text] ": $value" text
    canvasLabel::configure $label -text $text
}

