set rcsId {$Id: boxlabel.tcl,v 1.41.1.1 2000/03/05 20:55:56 jfontain Exp $}

class pieBoxLabeler {

    proc pieBoxLabeler {this canvas args} pieLabeler {$canvas $args} switched {$args} {
        ::set pieBoxLabeler::($this,array) [::new canvasLabelsArray $canvas]
        switched::complete $this
    }

    proc ~pieBoxLabeler {this} {
        ::delete $pieBoxLabeler::($this,array)
    }

    proc options {this} {                                      ;# font and justify options are used when creating a new canvas label
        # justify option is used for both the labels array and the labels
        return [list\
            [list -font $pieLabeler::(default,font) $pieLabeler::(default,font)]\
            [list -justify left left]\
            [list -offset 5 5]\
            [list -xoffset 0 0]\
        ]
    }

    foreach option {-font -justify -offset -xoffset} {                                                 ;# no dynamic options allowed
        proc set$option {this value} "
            if {\$switched::(\$this,complete)} {
                error {option $option cannot be set dynamically}
            }
        "
    }

    proc new {this slice args} {                                       ;# variable arguments are for the created canvas label object
        ::set label [eval ::new canvasLabel $pieLabeler::($this,canvas)\
            $args [list -justify $switched::($this,-justify) -font $switched::($this,-font)]\
        ]
        canvasLabelsArray::manage $pieBoxLabeler::($this,array) $label
        # refresh our tags
        $pieLabeler::($this,canvas) addtag pieLabeler($this) withtag canvasLabelsArray($pieBoxLabeler::($this,array))
        switched::configure $label -text [switched::cget $label -text]:                        ;# always append semi-column to label
        ::set pieBoxLabeler::($this,selected,$label) 0
        return $label
    }

    proc delete {this label} {
        canvasLabelsArray::delete $pieBoxLabeler::($this,array) $label
        unset pieBoxLabeler::($this,selected,$label)
    }

    proc set {this label value} {
        regsub {:[^:]*$} [switched::cget $label -text] ": $value" text                  ;# update string part after last semi-column
        switched::configure $label -text $text
    }

    proc label {this label args} {
        ::set text [switched::cget $label -text]
        if {[llength $args]==0} {
            regexp {^(.*):} $text dummy text
            return $text
        } else {
            regsub {^.*:} $text [lindex $args 0]: text                                 ;# update string part before last semi-column
            switched::configure $label -text $text
        }
    }

    proc selectState {this label {selected {}}} {
        if {[string length $selected]==0} {                                                   ;# return current state if no argument
            return $pieBoxLabeler::($this,selected,$label)
        }
        switched::configure $label -select $selected
        ::set pieBoxLabeler::($this,selected,$label) $selected
    }

    proc update {this left top right bottom} {                                   ;# whole pie coordinates, includings labeler labels
        ::set canvas $pieLabeler::($this,canvas)
        ::set array $pieBoxLabeler::($this,array)                                ;# first reposition labels array below pie graphics
        foreach {x y} [$canvas coords canvasLabelsArray($array)] {}
        $canvas move canvasLabelsArray($array) [expr {$left-$x}] [expr {$bottom-[canvasLabelsArray::height $array]-$y}]
        switched::configure $array -width [expr {$right-$left}]                                                ;# then fit pie width
    }

    proc room {this arrayName} {
        upvar $arrayName data

        ::set data(left) 0                                                                            ;# no room taken around slices
        ::set data(right) 0
        ::set data(top) 0
        ::set box [$pieLabeler::($this,canvas) bbox canvasLabelsArray($pieBoxLabeler::($this,array))]
        if {[llength $box]==0} {                                                                                    ;# no labels yet
            ::set data(bottom) 0
        } else {                                                                        ;# room taken by all labels including offset
            ::set data(bottom) [expr {[lindex $box 3]-[lindex $box 1]+$switched::($this,-offset)}]
        }
    }
}
