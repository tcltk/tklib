set rcsId {$Id: boxlabel.tcl,v 1.22 1997/06/05 20:25:51 jfontain Exp $}

package provide tkpiechart 3.0

class pieBoxLabeller {}

proc pieBoxLabeller::pieBoxLabeller {this canvas args} pieLabeller {$canvas $args} {
    array set option {-justify left}                                              ;# set options default then parse switched options
    array set option $args
    set pieBoxLabeller::($this,justify) $option(-justify)
}

proc pieBoxLabeller::~pieBoxLabeller {this} {
    catch {delete $pieBoxLabeller::($this,array)}                                             ;# array may not have been created yet
}

proc pieBoxLabeller::create {this sliceId args} {
    if {![info exists pieBoxLabeller::($this,array)]} {                                                     ;# create a labels array
        set options "-justify $pieBoxLabeller::($this,justify) -xoffset $pieLabeller::($this,xOffset)"
        catch {lappend options -font $pieLabeller::($this,font)}                                     ;# eventually use labeller font
        set box [$pieLabeller::($this,canvas) bbox pie($pieLabeller::($this,pieId))]                     ;# position array below pie
        set pieBoxLabeller::($this,array) [eval new canvasLabelsArray\
            $pieLabeller::($this,canvas) [lindex $box 0] [expr {[lindex $box 3]+$pieLabeller::($this,offset)}]\
            [expr {[lindex $box 2]-[lindex $box 0]}] $options\
        ]
    }
    # this label font may be overriden in arguments
    set labelId [eval canvasLabelsArray::create $pieBoxLabeller::($this,array) $args]
    # refresh our tags
    $pieLabeller::($this,canvas) addtag pieLabeller($this) withtag canvasLabelsArray($pieBoxLabeller::($this,array))
    canvasLabel::configure $labelId -text [canvasLabel::cget $labelId -text]:                  ;# always append semi-column to label
    return $labelId
}

proc pieBoxLabeller::update {this labelId value} {
    regsub {:.*$} [canvasLabel::cget $labelId -text] ": $value" text
    canvasLabel::configure $labelId -text $text
}

proc pieBoxLabeller::rotate {this labelId} {}                                            ;# we are not concerned with slice rotation
