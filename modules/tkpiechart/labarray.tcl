set rcsId {$Id: labarray.tcl,v 1.1 1995/10/10 13:16:23 jfontain Exp $}

source canlabel.tcl

proc canvasLabelsArray::canvasLabelsArray {id canvas x y width args} {
    global canvasLabelsArray

    set canvasLabelsArray($id,canvas) $canvas
    set canvasLabelsArray($id,width) [winfo fpixels $canvas $width]
    # use a dimensionless line as an origin marker
    set canvasLabelsArray($id,origin) [$canvas create line $x $y $x $y -fill {} -tags canvasLabelsArray($id)]

    # set options default then parse switched options
    array set option {-justify left}
    array set option $args
    catch {set canvasLabelsArray($id,font) $option(-font)}
    set canvasLabelsArray($id,justify) $option(-justify)
}

proc canvasLabelsArray::~canvasLabelsArray {id} {
    global canvasLabelsArray

    foreach label $canvasLabelsArray($id,labelIds) {
        delete canvasLabel $label
    }
    $canvasLabelsArray($id,canvas) delete canvasLabelsArray($id)
}

proc canvasLabelsArray::create {id args} {
    global canvasLabelsArray

    if {[lsearch -exact $args -font]<0} {
        # eventually use array font
        catch {lappend args -font $canvasLabelsArray($id,font)}
    }
    set labelId [eval new canvasLabel $canvasLabelsArray($id,canvas) 0 0 $args]
    $canvasLabelsArray($id,canvas) addtag canvasLabelsArray($id) withtag canvasLabel($labelId)
    lappend canvasLabelsArray($id,labelIds) $labelId
    canvasLabelsArray::position $id $labelId
    return $labelId
}

proc canvasLabelsArray::position {id labelId} {
    global canvasLabelsArray

    set canvas $canvasLabelsArray($id,canvas)

    set coordinates [$canvas coords $canvasLabelsArray($id,origin)]
    set x [lindex $coordinates 0]
    set y [lindex $coordinates 1]

    set coordinates [$canvas bbox canvasLabel($labelId)]
    set labelHeight [expr [lindex $coordinates 3]-[lindex $coordinates 1]]

    set index [expr [llength $canvasLabelsArray($id,labelIds)]-1]

    # arrange labels in two columns
    switch $canvasLabelsArray($id,justify) {
        left {
            set x [expr $x+(($index%2)*($canvasLabelsArray($id,width)/2.0))]
            set anchor nw
        }
        right {
            set x [expr $x+((($index%2)+1)*($canvasLabelsArray($id,width)/2.0))]
            set anchor ne
        }
        default {
            # should be center
            set x [expr $x+((1.0+(2*($index%2)))*$canvasLabelsArray($id,width)/4)]
            set anchor n
        }
    }
    canvasLabel::configure $labelId -anchor $anchor
    $canvas move canvasLabel($labelId) $x [expr $y+(($index/2)*$labelHeight)]
}
