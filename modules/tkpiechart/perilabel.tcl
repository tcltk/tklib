set rcsId {$Id: perilabel.tcl,v 1.40 1998/06/04 21:59:01 jfontain Exp $}

class piePeripheralLabeler {

    variable PI 3.14159265358979323846

    proc piePeripheralLabeler {this canvas args} pieLabeler {$canvas $args} switched {$args} {
        switched::complete $this
    }

    proc ~piePeripheralLabeler {this} {
        catch {delete $piePeripheralLabeler::($this,array)}                                   ;# array may not have been created yet
        $pieLabeler::($this,canvas) delete pieLabeler($this)                                               ;# delete remaining items
    }

    proc options {this} {                        ;# bullet width, font and justify options are used when creating a new canvas label
        # justify option is used for both the labels array and the labels. force small font option for font metrics calculations
        return [list\
            [list -bulletwidth 20 20]\
            [list -font $pieLabeler::(default,font) $pieLabeler::(default,font)]\
            [list -justify left left]\
            [list -offset 5 5]\
            [list -smallfont {Helvetica -10}]\
            [list -xoffset 0 0]\
        ]
    }

    foreach option {-bulletwidth -font -justify -offset -xoffset} {                                    ;# no dynamic options allowed
        proc set$option {this value} "
            if {\$switched::(\$this,complete)} {
                error {option $option cannot be set dynamically}
            }
        "
    }

    proc set-smallfont {this value} {
        if {$switched::($this,complete)} {
            error {option -smallfont cannot be set dynamically}
        }
        ::set piePeripheralLabeler::($this,smallFontWidth) [font measure $value 0]
        ::set piePeripheralLabeler::($this,smallFontHeight) [font metrics $value -ascent]
    }

    proc new {this slice args} {                                       ;# variable arguments are for the created canvas label object
        ::set canvas $pieLabeler::($this,canvas)
        ::set text [$canvas create text 0 0 -font $switched::($this,-smallfont) -tags pieLabeler($this)]       ;# create value label
        if {![info exists piePeripheralLabeler::($this,array)]} {                                     ;# create a split labels array
            ::set piePeripheralLabeler::($this,array)\
                [::new canvasLabelsArray $canvas 0 0 -justify $switched::($this,-justify) -xoffset $switched::($this,-xoffset)]
            update $this                                                                                 ;# position array below pie
        }
        ::set label [eval ::new canvasLabel $pieLabeler::($this,canvas) 0 0 $args\
            [list\
                -style split -justify $switched::($this,-justify) -bulletwidth $switched::($this,-bulletwidth)\
                -font $switched::($this,-font)\
            ]\
        ]
        canvasLabelsArray::manage $piePeripheralLabeler::($this,array) $label
        $canvas addtag pieLabeler($this) withtag canvasLabelsArray($piePeripheralLabeler::($this,array))         ;# refresh our tags
        ::set piePeripheralLabeler::($this,textItem,$label) $text                       ;# value text item is the only one to update
        ::set piePeripheralLabeler::($this,slice,$label) $slice
        ::set piePeripheralLabeler::($this,selected,$label) 0
        return $label
    }

    proc anglePosition {degrees} {
        return [expr {(2*($degrees/90))+(($degrees%90)!=0)}]          ;# quadrant specific index with added value for exact quarters
    }

    ::set index 0                                                         ;# build angle position / value label anchor mapping array
    foreach anchor {w sw s se e ne n nw} {
        ::set piePeripheralLabeler::(anchor,[anglePosition [expr {$index*45}]]) $anchor
        incr index
    }
    unset index anchor

    proc set {this label value} {
        ::set text $piePeripheralLabeler::($this,textItem,$label)
        position $this $text $piePeripheralLabeler::($this,slice,$label)
        $pieLabeler::($this,canvas) itemconfigure $text -text $value
    }

    proc position {this text slice} {              ;# place the value text item next to the outter border of the corresponding slice
        variable PI

        slice::data $slice data                                                    ;# retrieve current slice position and dimensions
        # calculate text closest point coordinates in normal coordinates system (y increasing in north direction)
        ::set midAngle [expr {$data(start)+($data(extent)/2.0)}]
        ::set radians [expr {$midAngle*$PI/180}]
        ::set x [expr {($data(xRadius)+$switched::($this,-offset))*cos($radians)}]
        ::set y [expr {($data(yRadius)+$switched::($this,-offset))*sin($radians)}]
        ::set angle [expr {round($midAngle)%360}]
        if {$angle>180} {
            ::set y [expr {$y-$data(height)}]                                                           ;# account for pie thickness
        }

        ::set canvas $pieLabeler::($this,canvas)
        ::set coordinates [$canvas coords $text]                 ;# now transform coordinates according to canvas coordinates system
        $canvas move $text [expr {$data(xCenter)+$x-[lindex $coordinates 0]}] [expr {$data(yCenter)-$y-[lindex $coordinates 1]}]
        # finally set anchor according to which point of the text is closest to pie graphics
        $canvas itemconfigure $text -anchor $piePeripheralLabeler::(anchor,[anglePosition $angle])
    }

    proc delete {this label} {
        canvasLabelsArray::delete $piePeripheralLabeler::($this,array) $label
        $pieLabeler::($this,canvas) delete $piePeripheralLabeler::($this,textItem,$label)
        unset piePeripheralLabeler::($this,textItem,$label) piePeripheralLabeler::($this,slice,$label)\
            piePeripheralLabeler::($this,selected,$label)
        # finally reposition the remaining value text items next to their slices
        foreach label [canvasLabelsArray::labels $piePeripheralLabeler::($this,array)] {
            position $this $piePeripheralLabeler::($this,textItem,$label) $piePeripheralLabeler::($this,slice,$label)
        }
    }

    proc selectState {this label {selected {}}} {
        if {[string length $selected]==0} {                                                   ;# return current state if no argument
            return $piePeripheralLabeler::($this,selected,$label)
        }
        if {$selected} {
            switched::configure $label -borderwidth 2
        } else {
            switched::configure $label -borderwidth 1
        }
        ::set piePeripheralLabeler::($this,selected,$label) $selected
    }

    proc update {this} {
        ::set canvas $pieLabeler::($this,canvas)
        ::set box [$canvas bbox pieGraphics($pieLabeler::($this,pie))]
        ::set array $piePeripheralLabeler::($this,array)                         ;# first reposition labels array below pie graphics
        foreach {x y} [$canvas coords canvasLabelsArray($array)] {}
        $canvas move canvasLabelsArray($array) [expr {[lindex $box 0]-$x}]\
            [expr {[lindex $box 3]+$switched::($this,-offset)+$piePeripheralLabeler::($this,smallFontHeight)-$y}]
        switched::configure $array -width [switched::cget $pieLabeler::($this,pie) -width]                     ;# then fit pie width
        foreach label [canvasLabelsArray::labels $array] {                                   ;# finally reposition peripheral labels
            position $this $piePeripheralLabeler::($this,textItem,$label) $piePeripheralLabeler::($this,slice,$label)
        }
    }

    proc horizontalRoom {this} {
        # use 3 characters as a maximum numerical string length
        return [expr {2*((3*$piePeripheralLabeler::($this,smallFontWidth))+$switched::($this,-offset))}]
    }

    proc verticalRoom {this} {
        if {[catch {::set piePeripheralLabeler::($this,array)} array]} {
            return 0
        }
        ::set box [$pieLabeler::($this,canvas) bbox canvasLabelsArray($array)]
        return\
            [expr {[lindex $box 3]-[lindex $box 1]+(2*($switched::($this,-offset)+$piePeripheralLabeler::($this,smallFontHeight)))}]
    }

}
