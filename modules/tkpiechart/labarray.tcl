set rcsId {$Id: labarray.tcl,v 1.12 1998/03/21 10:18:18 jfontain Exp $}

class canvasLabelsArray {}

proc canvasLabelsArray::canvasLabelsArray {this canvas x y width args} {
    set canvasLabelsArray::($this,canvas) $canvas
    set canvasLabelsArray::($this,width) [winfo fpixels $canvas $width]
    # use a dimensionless line as an origin marker
    set canvasLabelsArray::($this,origin) [$canvas create line $x $y $x $y -fill {} -tags canvasLabelsArray($this)]

    array set options {-justify left -style box -bulletwidth 20 -xoffset 0}                                   ;# set options default
    array set options $args                                                                            ;# override with user options
    set canvasLabelsArray::($this,xOffset) [winfo fpixels $canvas $options(-xoffset)]                     ;# convert offset to pixel
    unset options(-xoffset)                                                                      ;# remove invalid option for labels
    set canvasLabelsArray::($this,labelOptions) [array get options]
}

proc canvasLabelsArray::~canvasLabelsArray {this} {
    foreach label $canvasLabelsArray::($this,labels) {
        delete $label
    }
    $canvasLabelsArray::($this,canvas) delete canvasLabelsArray($this)                                     ;# delete remaining items
}

proc canvasLabelsArray::create {this args} {
    array set options $canvasLabelsArray::($this,labelOptions)
    array set options $args                                                                            ;# override with user options

    set label [eval new canvasLabel $canvasLabelsArray::($this,canvas) 0 0 [array get options]]
    $canvasLabelsArray::($this,canvas) addtag canvasLabelsArray($this) withtag canvasLabel($label)
    lappend canvasLabelsArray::($this,labels) $label
    canvasLabelsArray::position $this $label $options(-justify)
    return $label
}

proc canvasLabelsArray::position {this label justification} {
    set canvas $canvasLabelsArray::($this,canvas)

    set index [expr {[llength $canvasLabelsArray::($this,labels)]-1}]

    set coordinates [$canvas coords $canvasLabelsArray::($this,origin)]
    # offset horizontally, left column gets negative offset
    set x [expr {[lindex $coordinates 0]+(($index%2?1:-1)*$canvasLabelsArray::($this,xOffset))}]
    set y [lindex $coordinates 1]

    set coordinates [$canvas bbox canvasLabel($label)]
    set labelHeight [expr {[lindex $coordinates 3]-[lindex $coordinates 1]}]

    switch $justification {                                                                         ;# arrange labels in two columns
        left {
            set x [expr {$x+(($index%2)*($canvasLabelsArray::($this,width)/2.0))}]
            set anchor nw
        }
        right {
            set x [expr {$x+((($index%2)+1)*($canvasLabelsArray::($this,width)/2.0))}]
            set anchor ne
        }
        default {                                                                                                ;# should be center
            set x [expr {$x+((1.0+(2*($index%2)))*$canvasLabelsArray::($this,width)/4)}]
            set anchor n
        }
    }
    switched::configure $label -anchor $anchor
    $canvas move canvasLabel($label) $x [expr {$y+(($index/2)*$labelHeight)}]
}
