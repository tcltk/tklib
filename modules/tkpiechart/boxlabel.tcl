set rcsId {$Id: boxlabel.tcl,v 1.14 1995/10/10 19:48:36 jfontain Exp $}

source pielabel.tcl
source labarray.tcl

proc pieBoxLabeller::pieBoxLabeller {id canvas args} {
    global pieBoxLabeller

    eval pieLabeller::pieLabeller $id $canvas $args

    # set options default then parse switched options
    array set option {-justify left}
    array set option $args
    set pieBoxLabeller($id,justify) $option(-justify)
}

proc pieBoxLabeller::~pieBoxLabeller {id} {
    global pieBoxLabeller

    # array may not have been created yet
    catch {delete canvasLabelsArray $pieBoxLabeller($id,array)}
}

proc pieBoxLabeller::create {id sliceId args} {
    global pieBoxLabeller pieLabeller

    if {![info exists pieBoxLabeller($id,array)]} {
        # create a labels array
        set options "-justify $pieBoxLabeller($id,justify)"
        # eventually use labeller font
        catch {lappend options -font $pieLabeller($id,font}
        # position array below pie
        set box [$pieLabeller($id,canvas) bbox pie($pieLabeller($id,pieId))]
        set pieBoxLabeller($id,array) [eval new canvasLabelsArray\
            $pieLabeller($id,canvas) [lindex $box 0] [expr [lindex $box 3]+$pieLabeller($id,offset)]\
            [expr [lindex $box 2]-[lindex $box 0]] $options\
        ]
    }
    # this label font may be overriden in arguments
    set labelId [eval canvasLabelsArray::create $pieBoxLabeller($id,array) $args]
    # refresh our tags
    $pieLabeller($id,canvas) addtag pieLabeller($id) withtag canvasLabelsArray($pieBoxLabeller($id,array))
    # always append semi-column to label
    canvasLabel::configure $labelId -text [canvasLabel::cget $labelId -text]:
    return $labelId
}

proc pieBoxLabeller::update {id labelId value} {
    regsub {:.*$} [canvasLabel::cget $labelId -text] ": $value" text
    canvasLabel::configure $labelId -text $text
}

# we are not concerned with slice rotation
proc pieBoxLabeller::rotate {id labelId} {}
