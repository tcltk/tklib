set rcsId {$Id: perilabel.tcl,v 1.8 1995/10/08 18:17:39 jfontain Exp $}

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
        $canvas itemconfigure $valueId -font $pieLabeller($id,font)
    }

    # value label is the only one to update
    set piePeripheralLabeller($id,sliceId,$valueId) $sliceId

    incr piePeripheralLabeller($id,number)
    return $valueId
}

proc piePeripheralLabeller::update {id valueId value} {
    global pieLabeller

    piePeripheralLabeller::rotate $id $valueId
    $pieLabeller($id,canvas) itemconfigure $valueId -text $value
}

proc piePeripheralLabeller::rotate {id valueId} {
    global piePeripheralLabeller pieLabeller PI

    set canvas $pieLabeller($id,canvas)
    set sliceId $piePeripheralLabeller($id,sliceId,$valueId)

    slice::data $sliceId data

    # calculate text closest point coordinates in normal coordinates system (y increasing in north direction)
    set radians [expr $data(midAngle)*$PI/180]
    set x [expr ($data(xRadius)+$pieLabeller($id,offset))*cos($radians)]
    set y [expr ($data(yRadius)+$pieLabeller($id,offset))*sin($radians)]
    set angle [expr round($data(midAngle))%360]
    if {$angle>180} {
        # account for pie thickness
        set y [expr $y-$data(height)]
    }

    # now transform coordinates according to canvas coordinates system
    set coordinates [$pieLabeller($id,canvas) coords $valueId]
    $pieLabeller($id,canvas) move $valueId\
        [expr $data(xCenter)+$x-[lindex $coordinates 0]] [expr $data(yCenter)-$y-[lindex $coordinates 1]]

    # finally determine which point of the text is closest to pie graphics
    if {$angle<=0} {
        set anchor w
    } elseif {$angle<90} {
        set anchor sw
    } elseif {$angle==90} {
        set anchor s
    } elseif {$angle<180} {
        set anchor se
    } elseif {$angle==180} {
        set anchor e
    } elseif {$angle<270} {
        set anchor ne
    } elseif {$angle==270} {
        set anchor n
    } else {
        set anchor nw
    }
    $canvas itemconfigure $valueId -anchor $anchor
}
