set rcsId {$Id: labarray.tcl,v 1.3 1995/10/14 17:13:32 jfontain Exp $}

source canlabel.tcl

proc canvasLabelsArray::canvasLabelsArray {this canvas x y width args} {
    global canvasLabelsArray

    set canvasLabelsArray($this,canvas) $canvas
    set canvasLabelsArray($this,width) [winfo fpixels $canvas $width]
    # use a dimensionless line as an origin marker
    set canvasLabelsArray($this,origin) [$canvas create line $x $y $x $y -fill {} -tags canvasLabelsArray($this)]

    # set options default then parse switched options
    array set option {-justify left -style box}
    array set option $args
    catch {set canvasLabelsArray($this,font) $option(-font)}
    set canvasLabelsArray($this,justify) $option(-justify)
    set canvasLabelsArray($this,style) $option(-style)
}

proc canvasLabelsArray::~canvasLabelsArray {this} {
    global canvasLabelsArray

    foreach label $canvasLabelsArray($this,labelIds) {
        delete canvasLabel $label
    }
    # delete remaining items
    $canvasLabelsArray($this,canvas) delete canvasLabelsArray($this)
}

proc canvasLabelsArray::create {this args} {
    global canvasLabelsArray

    if {[lsearch -exact $args -font]<0} {
        # eventually use array main font
        catch {lappend args -font $canvasLabelsArray($this,font)}
    }
    if {[lsearch -exact $args -style]<0} {
        # use array main style if not overridden
        lappend args -style $canvasLabelsArray($this,style)
    }
    set labelId [eval new canvasLabel $canvasLabelsArray($this,canvas) 0 0 $args]
    $canvasLabelsArray($this,canvas) addtag canvasLabelsArray($this) withtag canvasLabel($labelId)
    lappend canvasLabelsArray($this,labelIds) $labelId
    canvasLabelsArray::position $this $labelId
    return $labelId
}

proc canvasLabelsArray::position {this labelId} {
    global canvasLabelsArray

    set canvas $canvasLabelsArray($this,canvas)

    set coordinates [$canvas coords $canvasLabelsArray($this,origin)]
    set x [lindex $coordinates 0]
    set y [lindex $coordinates 1]

    set coordinates [$canvas bbox canvasLabel($labelId)]
    set labelHeight [expr [lindex $coordinates 3]-[lindex $coordinates 1]]

    set index [expr [llength $canvasLabelsArray($this,labelIds)]-1]

    # arrange labels in two columns
    switch $canvasLabelsArray($this,justify) {
        left {
            set x [expr $x+(($index%2)*($canvasLabelsArray($this,width)/2.0))]
            set anchor nw
        }
        right {
            set x [expr $x+((($index%2)+1)*($canvasLabelsArray($this,width)/2.0))]
            set anchor ne
        }
        default {
            # should be center
            set x [expr $x+((1.0+(2*($index%2)))*$canvasLabelsArray($this,width)/4)]
            set anchor n
        }
    }
    canvasLabel::configure $labelId -anchor $anchor
    $canvas move canvasLabel($labelId) $x [expr $y+(($index/2)*$labelHeight)]
}
