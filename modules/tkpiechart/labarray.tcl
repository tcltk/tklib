set rcsId {$Id: labarray.tcl,v 1.20.1.1 2000/04/06 19:26:04 jfontain Exp $}

class canvasLabelsArray {

    proc canvasLabelsArray {this canvas args} switched {$args} {
        set canvasLabelsArray::($this,canvas) $canvas
        # use an empty image as an origin marker with only 2 coordinates
        set canvasLabelsArray::($this,origin) [$canvas create image 0 0 -tags canvasLabelsArray($this)]
        set canvasLabelsArray::($this,labels) {}
        switched::complete $this
    }

    proc ~canvasLabelsArray {this} {
        eval ::delete $canvasLabelsArray::($this,labels)
        $canvasLabelsArray::($this,canvas) delete canvasLabelsArray($this)                                 ;# delete remaining items
    }

    proc options {this} {
        # force width initialization for internals initialization
        return [list\
            [list -justify left left]\
            [list -width 100]\
        ]
    }

    proc set-justify {this value} {
        if {$switched::($this,complete)} {
            error {option -justify cannot be set dynamically}
        }
    }

    proc set-width {this value} {
        set canvasLabelsArray::($this,width) [winfo fpixels $canvasLabelsArray::($this,canvas) $value]
        update $this
    }

    proc update {this} {
        set index 0
        foreach label $canvasLabelsArray::($this,labels) {
            position $this $label $index
            incr index
        }
    }

    proc manage {this label} {                                                                              ;# must be a canvasLabel
        $canvasLabelsArray::($this,canvas) addtag canvasLabelsArray($this) withtag canvasLabel($label)
        set index [llength $canvasLabelsArray::($this,labels)]
        lappend canvasLabelsArray::($this,labels) $label
        position $this $label $index
    }

    proc delete {this label} {
        set index [lsearch -exact $canvasLabelsArray::($this,labels) $label]
        if {$index<0} {
            error "invalid label $label for canvas labels array $this"
        }
        set canvasLabelsArray::($this,labels) [lreplace $canvasLabelsArray::($this,labels) $index $index]
        ::delete $label
        foreach label [lrange $canvasLabelsArray::($this,labels) $index end] {
            position $this $label $index
            incr index
        }
    }

    proc position {this label index} {
        set canvas $canvasLabelsArray::($this,canvas)
        foreach {x y} [$canvas coords $canvasLabelsArray::($this,origin)] {}
        set column [expr {$index%2}]
        switch $switched::($this,-justify) {                                                        ;# arrange labels in two columns
            left {
                set x [expr {$x+($column*($canvasLabelsArray::($this,width)/2.0))}]
                set anchor nw
            }
            right {
                set x [expr {$x+(($column+1)*($canvasLabelsArray::($this,width)/2.0))}]
                set anchor ne
            }
            default {                                                                                            ;# should be center
                set x [expr {$x+((1.0+(2*$column))*$canvasLabelsArray::($this,width)/4)}]
                set anchor n
            }
        }
        set y [expr {$y+[columnHeight $this $column [expr {$index/2}]]}]
        switched::configure $label -anchor $anchor
        foreach {xDelta yDelta} [$canvas coords canvasLabel($label)] {}                ;# do an absolute positioning using label tag
        $canvas move canvasLabel($label) [expr {$x-$xDelta}] [expr {$y-$yDelta}]
    }

    proc labels {this} {
        return $canvasLabelsArray::($this,labels)
    }

    proc columnHeight {this column {rows 2147483647}} {                                              ;# column must be either 0 or 1
        set canvas $canvasLabelsArray::($this,canvas)
        set length [llength $canvasLabelsArray::($this,labels)]
        set height 0
        for {set index $column; set row 0} {($index<$length)&&($row<$rows)} {incr index 2; incr row} {
            set coordinates [$canvas bbox canvasLabel([lindex $canvasLabelsArray($this,labels) $index])]
            incr height [expr {[lindex $coordinates 3]-[lindex $coordinates 1]}]
        }
        return $height
    }

    proc height {this} {
        return [maximum [columnHeight $this 0] [columnHeight $this 1]]
    }

    proc maximum {a b} {return [expr {$a>$b?$a:$b}]}

}
