set rcsId {$Id: perilabel.tcl,v 1.33 1998/03/28 08:59:39 jfontain Exp $}

class piePeripheralLabeler {

    proc piePeripheralLabeler {this canvas args} pieLabeler {$canvas $args} switched {$args} {
        switched::complete $this
    }

    proc ~piePeripheralLabeler {this} {
        catch {delete $piePeripheralLabeler::($this,array)}                                   ;# array may not have been created yet
        $pieLabeler::($this,canvas) delete pieLabeler($this)                                               ;# delete remaining items
    }

    proc options {this} {
        return [list\
            [list -bulletwidth 20 20]\
            [list -font $pieLabeler::(default,font) $pieLabeler::(default,font)]\
            [list -justify left left]\
            [list -offset 5 5]\
            [list -smallfont {Helvetica -10} {Helvetica -10}]\
            [list -xoffset 0 0]\
        ]
    }

    foreach option {-bulletwidth -font -justify -offset -smallfont -xoffset} {                         ;# no dynamic options allowed
        proc set$option {this value} "
            if {\$switched::(\$this,complete)} {
                error {option $option cannot be set dynamically}
            }
        "
    }

    proc create {this slice args} {
        set canvas $pieLabeler::($this,canvas)

        set text [$canvas create text 0 0 -tags pieLabeler($this)]                                             ;# create value label
        catch {$canvas itemconfigure $text -font $switched::($this,-smallfont)}                         ;# eventually use small font
        set box [$canvas bbox $text]
        set smallTextHeight [expr {[lindex $box 3]-[lindex $box 1]}]

        if {![info exists piePeripheralLabeler::($this,array)]} {                                     ;# create a split labels array
            set options "-style split -justify $switched::($this,-justify) -xoffset $switched::($this,-xoffset)"
            catch {lappend options -bulletwidth $switched::($this,-bulletwidth)}
            catch {lappend options -font $switched::($this,-font)}                                    ;# eventually use labeler font
            set box [$canvas bbox pie($pieLabeler::($this,pie))]                                         ;# position array below pie
            set piePeripheralLabeler::($this,array) [eval new canvasLabelsArray\
                $canvas [lindex $box 0] [expr {[lindex $box 3]+(2*$switched::($this,-offset))+$smallTextHeight}]\
                [expr {[lindex $box 2]-[lindex $box 0]}] $options\
            ]
        }

        # this label font may be overriden in arguments
        set label [eval canvasLabelsArray::create $piePeripheralLabeler::($this,array) $args]
        $canvas addtag pieLabeler($this) withtag canvasLabelsArray($piePeripheralLabeler::($this,array))         ;# refresh our tags

        set piePeripheralLabeler::($this,textItem,$label) $text                         ;# value text item is the only one to update
        set piePeripheralLabeler::($this,slice,$label) $slice
        set piePeripheralLabeler::($this,selected,$label) 0

        return $label
    }

    proc anglePosition {degrees} {
        return [expr {(2*($degrees/90))+(($degrees%90)!=0)}]          ;# quadrant specific index with added value for exact quarters
    }

    set index 0                                                           ;# build angle position / value label anchor mapping array
    foreach anchor {w sw s se e ne n nw} {
        set piePeripheralLabeler::(anchor,[anglePosition [expr {$index*45}]]) $anchor
        incr index
    }
    unset index anchor

    proc update {this label value} {
        set text $piePeripheralLabeler::($this,textItem,$label)
        position $this $text $piePeripheralLabeler::($this,slice,$label)
        $pieLabeler::($this,canvas) itemconfigure $text -text $value
    }

    proc position {this text slice} {              ;# place the value text item next to the outter border of the corresponding slice
        global PI

        slice::data $slice data
        # calculate text closest point coordinates in normal coordinates system (y increasing in north direction)
        set midAngle [expr {$data(start)+($data(extent)/2.0)}]
        set radians [expr {$midAngle*$PI/180}]
        set x [expr {($data(xRadius)+$switched::($this,-offset))*cos($radians)}]
        set y [expr {($data(yRadius)+$switched::($this,-offset))*sin($radians)}]
        set angle [expr {round($midAngle)%360}]
        if {$angle>180} {
            set y [expr {$y-$data(height)}]                                                             ;# account for pie thickness
        }

        set canvas $pieLabeler::($this,canvas)
        set coordinates [$canvas coords $text]                   ;# now transform coordinates according to canvas coordinates system
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
        set piePeripheralLabeler::($this,selected,$label) $selected
    }

}
