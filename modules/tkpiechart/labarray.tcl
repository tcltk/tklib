set rcsId {$Id: labarray.tcl,v 1.7 1996/09/17 13:25:07 jfontain Exp $}

source canlabel.tcl

proc canvasLabelsArray::canvasLabelsArray {this canvas x y width args} {
    set canvasLabelsArray($this,canvas) $canvas
    set canvasLabelsArray($this,width) [winfo fpixels $canvas $width]
    # use a dimensionless line as an origin marker
    set canvasLabelsArray($this,origin) [$canvas create line $x $y $x $y -fill {} -tags canvasLabelsArray($this)]

    # set options default
    array set options {-justify left -style box -bulletwidth 20 -xoffset 0}
    # override with user options
    array set options $args
    # convert offset to pixel
    set canvasLabelsArray($this,xOffset) [winfo fpixels $canvas $options(-xoffset)]
    # remove invalid option for labels
    unset options(-xoffset)
    set canvasLabelsArray($this,labelOptions) [array get options]
}

proc canvasLabelsArray::~canvasLabelsArray {this} {
    foreach label $canvasLabelsArray($this,labelIds) {
        delete $label
    }
    # delete remaining items
    $canvasLabelsArray($this,canvas) delete canvasLabelsArray($this)
}

proc canvasLabelsArray::create {this args} {
    array set options $canvasLabelsArray($this,labelOptions)
    # override with user options
    array set options $args

    set labelId [eval new canvasLabel $canvasLabelsArray($this,canvas) 0 0 [array get options]]
    $canvasLabelsArray($this,canvas) addtag canvasLabelsArray($this) withtag canvasLabel($labelId)
    lappend canvasLabelsArray($this,labelIds) $labelId
    canvasLabelsArray::position $this $labelId $options(-justify)
    return $labelId
}

proc canvasLabelsArray::position {this labelId justification} {
    set canvas $canvasLabelsArray($this,canvas)

    set index [expr [llength $canvasLabelsArray($this,labelIds)]-1]

    set coordinates [$canvas coords $canvasLabelsArray($this,origin)]
    # offset horizontally, left column gets negative offset
    set x [expr [lindex $coordinates 0]+(($index%2?1:-1)*$canvasLabelsArray($this,xOffset))]
    set y [lindex $coordinates 1]

    set coordinates [$canvas bbox canvasLabel($labelId)]
    set labelHeight [expr [lindex $coordinates 3]-[lindex $coordinates 1]]

    # arrange labels in two columns
    switch $justification {
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
