set rcsId {$Id: perilabel.tcl,v 1.6 1995/10/06 15:58:17 jfontain Exp $}

source pielabel.tcl

proc piePeripheralLabeller::piePeripheralLabeller {id canvas args} {
    global piePeripheralLabeller

    eval pieLabeller::pieLabeller $id $canvas $args
    set piePeripheralLabeller($id,number) 0
}

proc piePeripheralLabeller::~piePeripheralLabeller {id} {
    global pieLabeller

    $pieLabeller($id,canvas) delete pieLabeller($id)
}

proc piePeripheralLabeller::create {id sliceId args} {
    global piePeripheralLabeller pieLabeller

    set canvas $pieLabeller($id,canvas)

    # filter text options
    if {[set index [lsearch -exact $args -text]]>=0} {
        set options [lrange $args $index [expr $index+1]]
    } else {
        set options {}
    }
    # eventually use labeller font
    catch {lappend options -font $pieLabeller($id,font)}
    lappend options -anchor w
    set textId [eval $canvas create text 0 0 $options]
    $canvas addtag pieLabeller($id) withtag $textId

    set box [$canvas bbox $textId]
    set textHeight [expr [lindex $box 3]-[lindex $box 1]]

    # arrange labels in two columns below graphics
    set box [$canvas bbox pieGraphics($pieLabeller($id,pieId))]
    # add some vertical padding so that rectangles do not touch
    set yPadding 2
    set x [expr [lindex $box 0]+(($piePeripheralLabeller($id,number)%2)*([lindex $box 2]-[lindex $box 0])/2.0)]
    set y [expr [lindex $box 3]+$pieLabeller($id,offset)+(($piePeripheralLabeller($id,number)/2)*($textHeight+$yPadding))]

    # take into account value labels around pie graphics
    set y [expr $y+$pieLabeller($id,offset)+$textHeight]

    # filter rectangle options
    if {[set index [lsearch -exact $args -background]]>=0} {
        set options "-fill [lindex $args [expr $index+1]]"
    } else {
        set options {}
    }
    $canvas addtag pieLabeller($id) withtag [\
        eval $canvas create rectangle $x $y [expr $x+(1.5*$textHeight)] [expr $y+$textHeight] $options\
    ]
    # place text next to colored rectangle
    $canvas move $textId [expr $x+(2*$textHeight)] [expr $y+($textHeight/2.0)]

    # create value label
    $canvas addtag pieLabeller($id) withtag [set valueId [$canvas create text 0 0]]
    # eventually use labeller font
    if {[info exists pieLabeller($id,font)]} {
        $canvas itemconfigure -font $pieLabeller($id,font)
    }

    incr piePeripheralLabeller($id,number)
    # value label is the only one to update
    return $valueId
}

proc piePeripheralLabeller::update {id sliceId value} {}
