set rcsId {$Id: perilabel.tcl,v 1.15 1995/10/14 17:13:32 jfontain Exp $}

source pielabel.tcl
source labarray.tcl

proc piePeripheralLabeller::piePeripheralLabeller {this canvas args} {
    global piePeripheralLabeller pieLabeller

    eval pieLabeller::pieLabeller $this $canvas $args

    # eventually use labeller font as small font
    catch {set piePeripheralLabeller($this,smallFont) $pieLabeller($this,font)}

    # set options default then parse switched options
    array set option {-justify left}
    array set option $args
    # small font can be overidden as an option
    catch {set piePeripheralLabeller($this,smallFont) $option(-smallfont)}
    set piePeripheralLabeller($this,justify) $option(-justify)
}

proc piePeripheralLabeller::~piePeripheralLabeller {this} {
    global piePeripheralLabeller pieLabeller

    # array may not have been created yet
    catch {delete canvasLabelsArray $piePeripheralLabeller($this,array)}
    # delete remaining items
    $pieLabeller($this,canvas) delete pieLabeller($this)
}

proc piePeripheralLabeller::create {this sliceId args} {
    global piePeripheralLabeller pieLabeller

    set canvas $pieLabeller($this,canvas)

    # create value label
    set valueId [$canvas create text 0 0 -tags pieLabeller($this)]
    # eventually use small font
    catch {$canvas itemconfigure $valueId -font $piePeripheralLabeller($this,smallFont)}
    set box [$canvas bbox $valueId]
    set smallTextHeight [expr [lindex $box 3]-[lindex $box 1]]

    if {![info exists piePeripheralLabeller($this,array)]} {
        # create a split labels array
        set options "-style split -justify $piePeripheralLabeller($this,justify)"
        # eventually use labeller font
        catch {lappend options -font $pieLabeller($this,font}
        # position array below pie
        set box [$canvas bbox pie($pieLabeller($this,pieId))]
        set piePeripheralLabeller($this,array) [eval new canvasLabelsArray\
            $canvas [lindex $box 0] [expr [lindex $box 3]+(2*$pieLabeller($this,offset))+$smallTextHeight]\
            [expr [lindex $box 2]-[lindex $box 0]] $options\
        ]
    }

    # this label font may be overriden in arguments
    set labelId [eval canvasLabelsArray::create $piePeripheralLabeller($this,array) $args]
    # refresh our tags
    $canvas addtag pieLabeller($this) withtag canvasLabelsArray($piePeripheralLabeller($this,array))

    # value label is the only one to update
    set piePeripheralLabeller($this,sliceId,$valueId) $sliceId
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

proc piePeripheralLabeller::update {this valueId value} {
    global pieLabeller

    piePeripheralLabeller::rotate $this $valueId
    $pieLabeller($this,canvas) itemconfigure $valueId -text $value
}

proc piePeripheralLabeller::rotate {this valueId} {
    global piePeripheralLabeller pieLabeller PI

    set canvas $pieLabeller($this,canvas)
    set sliceId $piePeripheralLabeller($this,sliceId,$valueId)

    slice::data $sliceId data

    # calculate text closest point coordinates in normal coordinates system (y increasing in north direction)
    set midAngle [expr $data(start)+($data(extent)/2.0)]
    set radians [expr $midAngle*$PI/180]
    set x [expr ($data(xRadius)+$pieLabeller($this,offset))*cos($radians)]
    set y [expr ($data(yRadius)+$pieLabeller($this,offset))*sin($radians)]
    set angle [expr round($midAngle)%360]
    if {$angle>180} {
        # account for pie thickness
        set y [expr $y-$data(height)]
    }

    # now transform coordinates according to canvas coordinates system
    set coordinates [$pieLabeller($this,canvas) coords $valueId]
    $pieLabeller($this,canvas) move $valueId\
        [expr $data(xCenter)+$x-[lindex $coordinates 0]] [expr $data(yCenter)-$y-[lindex $coordinates 1]]

    # finally set anchor according to which point of the text is closest to pie graphics
    $canvas itemconfigure $valueId -anchor $piePeripheralLabeller(anchor,[piePeripheralLabeller::anglePosition $angle])
}
