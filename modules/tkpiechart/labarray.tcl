set rcsId {$Id: labarray.tcl,v 1.15 1998/03/28 20:36:12 jfontain Exp $}

class canvasLabelsArray {

    proc canvasLabelsArray {this canvas x y width args} switched {$args} {
        set canvasLabelsArray::($this,canvas) $canvas
        set canvasLabelsArray::($this,width) [winfo fpixels $canvas $width]
        # use a dimensionless line as an origin marker
        set canvasLabelsArray::($this,origin) [$canvas create line $x $y $x $y -fill {} -tags canvasLabelsArray($this)]

#       array set options {-justify left -style box -bulletwidth 20 -xoffset 0}                               ;# set options default
#       array set options $args                                                                        ;# override with user options
#       set canvasLabelsArray::($this,xOffset) [winfo fpixels $canvas $options(-xoffset)]                 ;# convert offset to pixel
#       unset options(-xoffset)                                                                  ;# remove invalid option for labels
#       set canvasLabelsArray::($this,labelOptions) [array get options]
        set canvasLabelsArray::($this,labels) {}
        switched::complete $this
    }

    proc ~canvasLabelsArray {this} {
        eval ::delete $canvasLabelsArray::($this,labels)
        $canvasLabelsArray::($this,canvas) delete canvasLabelsArray($this)                                 ;# delete remaining items
    }

    proc options {this} {
        return [list\
            [list -justify left left]\
            [list -xoffset 0 0]\
        ]
    }

    foreach option {-justify -xoffset} {
        proc set$option {this value} "
            if {\$switched::(\$this,complete)} {
                error {option $option cannot be set dynamically}
            }
        "
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

        set coordinates [$canvas coords $canvasLabelsArray::($this,origin)]
        # offset horizontally, left column gets negative offset
        set x [expr {[lindex $coordinates 0]+(($index%2?1:-1)*$switched::($this,-xoffset))}]
        set y [lindex $coordinates 1]
        set coordinates [$canvas bbox canvasLabel($label)]
        set y [expr {$y+(($index/2)*([lindex $coordinates 3]-[lindex $coordinates 1]))}]           ;# take label height into account

        switch $switched::($this,-justify) {                                                        ;# arrange labels in two columns
            left {
                set x [expr {$x+(($index%2)*($canvasLabelsArray::($this,width)/2.0))}]
                set anchor nw
            }
            right {
                set x [expr {$x+((($index%2)+1)*($canvasLabelsArray::($this,width)/2.0))}]
                set anchor ne
            }
            default {                                                                                            ;# should be center
                set x [expr {$x+((1.0+(2*($index%2)))*$canvasLabelsArray::($this,width)/4)}]
                set anchor n
            }
        }
        switched::configure $label -anchor $anchor
        set coordinates [$canvas coords canvasLabel($label)]                           ;# do an absolute positioning using label tag
        $canvas move canvasLabel($label) [expr {$x-[lindex $coordinates 0]}] [expr {$y-[lindex $coordinates 1]}]
    }

    proc labels {this} {
        return $canvasLabelsArray::($this,labels)
    }

}
