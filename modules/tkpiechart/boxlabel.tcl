set rcsId {$Id: boxlabel.tcl,v 1.15 1995/10/14 17:13:32 jfontain Exp $}

source pielabel.tcl
source labarray.tcl

proc pieBoxLabeller::pieBoxLabeller {this canvas args} {
    global pieBoxLabeller

    eval pieLabeller::pieLabeller $this $canvas $args

    # set options default then parse switched options
    array set option {-justify left}
    array set option $args
    set pieBoxLabeller($this,justify) $option(-justify)
}

proc pieBoxLabeller::~pieBoxLabeller {this} {
    global pieBoxLabeller

    # array may not have been created yet
    catch {delete canvasLabelsArray $pieBoxLabeller($this,array)}
}

proc pieBoxLabeller::create {this sliceId args} {
    global pieBoxLabeller pieLabeller

    if {![info exists pieBoxLabeller($this,array)]} {
        # create a labels array
        set options "-justify $pieBoxLabeller($this,justify)"
        # eventually use labeller font
        catch {lappend options -font $pieLabeller($this,font}
        # position array below pie
        set box [$pieLabeller($this,canvas) bbox pie($pieLabeller($this,pieId))]
        set pieBoxLabeller($this,array) [eval new canvasLabelsArray\
            $pieLabeller($this,canvas) [lindex $box 0] [expr [lindex $box 3]+$pieLabeller($this,offset)]\
            [expr [lindex $box 2]-[lindex $box 0]] $options\
        ]
    }
    # this label font may be overriden in arguments
    set labelId [eval canvasLabelsArray::create $pieBoxLabeller($this,array) $args]
    # refresh our tags
    $pieLabeller($this,canvas) addtag pieLabeller($this) withtag canvasLabelsArray($pieBoxLabeller($this,array))
    # always append semi-column to label
    canvasLabel::configure $labelId -text [canvasLabel::cget $labelId -text]:
    return $labelId
}

proc pieBoxLabeller::update {this labelId value} {
    regsub {:.*$} [canvasLabel::cget $labelId -text] ": $value" text
    canvasLabel::configure $labelId -text $text
}

# we are not concerned with slice rotation
proc pieBoxLabeller::rotate {this labelId} {}
