set rcsId {$Id: boxlabel.tcl,v 1.30 1998/03/26 20:33:09 jfontain Exp $}

class pieBoxLabeller {

    proc pieBoxLabeller {this canvas args} pieLabeller {$canvas $args} switched {$args} {
        switched::complete $this
    }

    proc ~pieBoxLabeller {this} {
        catch {::delete $pieBoxLabeller::($this,array)}                                       ;# array may not have been created yet
    }

    proc options {this} {
        return [list\
            [list -font $pieLabeller::(default,font) $pieLabeller::(default,font)]\
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

    proc create {this slice args} {
        if {![info exists pieBoxLabeller::($this,array)]} {                                                 ;# create a labels array
            set box [$pieLabeller::($this,canvas) bbox pie($pieLabeller::($this,pie))]                   ;# position array below pie
            set pieBoxLabeller::($this,array) [new canvasLabelsArray\
                $pieLabeller::($this,canvas) [lindex $box 0] [expr {[lindex $box 3]+$switched::($this,-offset)}]\
                [expr {[lindex $box 2]-[lindex $box 0]}]\
                -justify $switched::($this,-justify) -xoffset $switched::($this,-xoffset) -font $switched::($this,-font)\
            ]
        }
        # this label font may be overriden in arguments
        set label [eval canvasLabelsArray::create $pieBoxLabeller::($this,array) $args]
        # refresh our tags
        $pieLabeller::($this,canvas) addtag pieLabeller($this) withtag canvasLabelsArray($pieBoxLabeller::($this,array))
        switched::configure $label -text [switched::cget $label -text]:                        ;# always append semi-column to label
        set pieBoxLabeller::($this,selected,$label) 0
        return $label
    }

    proc delete {this label} {
        canvasLabelsArray::delete $pieBoxLabeller::($this,array) $label
    }

    proc update {this label value} {
        regsub {:.*$} [switched::cget $label -text] ": $value" text
        switched::configure $label -text $text
    }

    proc selectState {this label {selected {}}} {
        if {[string length $selected]==0} {                                                   ;# return current state if no argument
            return $pieBoxLabeller::($this,selected,$label)
        }
        if {$selected} {
            switched::configure $label -borderwidth 2
        } else {
            switched::configure $label -borderwidth 1
        }
        set pieBoxLabeller::($this,selected,$label) $selected
    }

}
