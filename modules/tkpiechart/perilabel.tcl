set rcsId {$Id: perilabel.tcl,v 1.13 1995/10/11 21:00:16 jfontain Exp $}

source pielabel.tcl
source labarray.tcl

proc piePeripheralLabeller::piePeripheralLabeller {id canvas args} {
    global piePeripheralLabeller pieLabeller

    eval pieLabeller::pieLabeller $id $canvas $args

    # eventually use labeller font as small font
    catch {set piePeripheralLabeller($id,smallFont) $pieLabeller($id,font)}

    # set options default then parse switched options
    array set option {-justify left}
    array set option $args
    # small font can be overidden as an option
    catch {set piePeripheralLabeller($id,smallFont) $option(-smallfont)}
    set piePeripheralLabeller($id,justify) $option(-justify)
}

proc piePeripheralLabeller::~piePeripheralLabeller {id} {
    global pieLabeller

    # array may not have been created yet
    catch {delete canvasLabelsArray $piePeripheralLabeller($id,array)}
    # delete remaining items
    $pieLabeller($id,canvas) delete pieLabeller($id)
}

proc piePeripheralLabeller::create {id sliceId args} {
    global piePeripheralLabeller pieLabeller

    set canvas $pieLabeller($id,canvas)

    # create value label
    set valueId [$canvas create text 0 0 -tags pieLabeller($id)]
    # eventually use small font
    catch {$canvas itemconfigure $valueId -font $piePeripheralLabeller($id,smallFont)}
    set box [$canvas bbox $valueId]
    set smallTextHeight [expr [lindex $box 3]-[lindex $box 1]]

    if {![info exists piePeripheralLabeller($id,array)]} {
        # create a split labels array
        set options "-style split -justify $piePeripheralLabeller($id,justify)"
        # eventually use labeller font
        catch {lappend options -font $pieLabeller($id,font}
        # position array below pie
        set box [$canvas bbox pie($pieLabeller($id,pieId))]
        set piePeripheralLabeller($id,array) [eval new canvasLabelsArray\
            $canvas [lindex $box 0] [expr [lindex $box 3]+(2*$pieLabeller($id,offset))+$smallTextHeight]\
            [expr [lindex $box 2]-[lindex $box 0]] $options\
        ]
    }

    # this label font may be overriden in arguments
    set labelId [eval canvasLabelsArray::create $piePeripheralLabeller($id,array) $args]
    # refresh our tags
    $canvas addtag pieLabeller($id) withtag canvasLabelsArray($piePeripheralLabeller($id,array))

    # value label is the only one to update
    set piePeripheralLabeller($id,sliceId,$valueId) $sliceId
    return $valueId
}

proc piePeripheralLabeller::anglePosition {degrees} {
    # quadrant specific index with added value for exact quarters
    return [expr (2*($degrees/90))+(($degrees%90)!=0)]
}

# build angle position / value label anchor mapping array
set index 0
foreach anchor {w sw s se e ne n nw} {
    set piePeripheralLabeller(anchor,[piePeripheralLabeller::anglePosition [expr $index*45]]) $anchor
    incr index
}
unset index anchor

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
    set midAngle [expr $data(start)+($data(extent)/2.0)]
    set radians [expr $midAngle*$PI/180]
    set x [expr ($data(xRadius)+$pieLabeller($id,offset))*cos($radians)]
    set y [expr ($data(yRadius)+$pieLabeller($id,offset))*sin($radians)]
    set angle [expr round($midAngle)%360]
    if {$angle>180} {
        # account for pie thickness
        set y [expr $y-$data(height)]
    }

    # now transform coordinates according to canvas coordinates system
    set coordinates [$pieLabeller($id,canvas) coords $valueId]
    $pieLabeller($id,canvas) move $valueId\
        [expr $data(xCenter)+$x-[lindex $coordinates 0]] [expr $data(yCenter)-$y-[lindex $coordinates 1]]

    # finally set anchor according to which point of the text is closest to pie graphics
    $canvas itemconfigure $valueId -anchor $piePeripheralLabeller(anchor,[piePeripheralLabeller::anglePosition $angle])
}
