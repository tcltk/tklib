set rcsId {$Id: perilabel.tcl,v 1.26 1998/03/21 10:19:18 jfontain Exp $}

class piePeripheralLabeller {

    proc piePeripheralLabeller {this canvas args} pieLabeller {$canvas $args} switched {$args} {
        switched::complete $this
    }

    proc ~piePeripheralLabeller {this} {
        catch {delete $piePeripheralLabeller::($this,array)}                                  ;# array may not have been created yet
        $pieLabeller::($this,canvas) delete pieLabeller($this)                                             ;# delete remaining items
    }

    proc options {this} {
        return [list\
            [list -bulletwidth 20 20]\
            [list -font $pieLabeller::(default,font) $pieLabeller::(default,font)]\
            [list -justify left left]\
            [list -offset 5 5]\
            [list -smallfont {Helvetica 10} {Helvetica 10}]\
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
        set canvas $pieLabeller::($this,canvas)

        set item [$canvas create text 0 0 -tags pieLabeller($this)]                                            ;# create value label
        catch {$canvas itemconfigure $item -font $switched::($this,-smallfont)}                         ;# eventually use small font
        set box [$canvas bbox $item]
        set smallTextHeight [expr {[lindex $box 3]-[lindex $box 1]}]

        if {![info exists piePeripheralLabeller::($this,array)]} {                                    ;# create a split labels array
            set options "-style split -justify $switched::($this,-justify) -xoffset $switched::($this,-xoffset)"
            catch {lappend options -bulletwidth $switched::($this,-bulletwidth)}
            catch {lappend options -font $switched::($this,-font)}                                   ;# eventually use labeller font
            set box [$canvas bbox pie($pieLabeller::($this,pie))]                                        ;# position array below pie
            set piePeripheralLabeller::($this,array) [eval new canvasLabelsArray\
                $canvas [lindex $box 0] [expr {[lindex $box 3]+(2*$switched::($this,-offset))+$smallTextHeight}]\
                [expr {[lindex $box 2]-[lindex $box 0]}] $options\
            ]
        }

        # this label font may be overriden in arguments
        set labelId [eval canvasLabelsArray::create $piePeripheralLabeller::($this,array) $args]
        $canvas addtag pieLabeller($this) withtag canvasLabelsArray($piePeripheralLabeller::($this,array))       ;# refresh our tags

        set piePeripheralLabeller::($this,slice,$item) $slice                               ;# value label is the only one to update
        return $item
    }

    proc anglePosition {degrees} {
        return [expr {(2*($degrees/90))+(($degrees%90)!=0)}]          ;# quadrant specific index with added value for exact quarters
    }

    set index 0                                                           ;# build angle position / value label anchor mapping array
    foreach anchor {w sw s se e ne n nw} {
        set piePeripheralLabeller::(anchor,[anglePosition [expr {$index*45}]]) $anchor
        incr index
    }
    unset index anchor

    proc update {this item value} {
        rotate $this $item
        $pieLabeller::($this,canvas) itemconfigure $item -text $value
    }

    proc rotate {this item} {
        global PI

        set canvas $pieLabeller::($this,canvas)
        set slice $piePeripheralLabeller::($this,slice,$item)

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

        # now transform coordinates according to canvas coordinates system
        set coordinates [$pieLabeller::($this,canvas) coords $item]
        $pieLabeller::($this,canvas) move $item\
            [expr {$data(xCenter)+$x-[lindex $coordinates 0]}] [expr {$data(yCenter)-$y-[lindex $coordinates 1]}]

        # finally set anchor according to which point of the text is closest to pie graphics
        $canvas itemconfigure $item -anchor $piePeripheralLabeller::(anchor,[anglePosition $angle])
    }

}
