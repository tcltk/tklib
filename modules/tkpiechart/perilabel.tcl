set rcsId {$Id: perilabel.tcl,v 1.23 1997/06/05 20:25:51 jfontain Exp $}

package provide tkpiechart 3.0

class piePeripheralLabeller {}

proc piePeripheralLabeller::piePeripheralLabeller {this canvas args} pieLabeller {$canvas $args} {
    catch {set piePeripheralLabeller::($this,smallFont) $pieLabeller::($this,font)}    ;# eventually use labeller font as small font
    array set option {-justify left}                                              ;# set options default then parse switched options
    array set option $args
    catch {set piePeripheralLabeller::($this,smallFont) $option(-smallfont)}             ;# small font can be overidden as an option
    catch {set piePeripheralLabeller::($this,bulletWidth) $option(-bulletwidth)}
    set piePeripheralLabeller::($this,justify) $option(-justify)
}

proc piePeripheralLabeller::~piePeripheralLabeller {this} {
    catch {delete $piePeripheralLabeller::($this,array)}                                      ;# array may not have been created yet
    $pieLabeller::($this,canvas) delete pieLabeller($this)                                                 ;# delete remaining items
}

proc piePeripheralLabeller::create {this sliceId args} {
    set canvas $pieLabeller::($this,canvas)

    set valueId [$canvas create text 0 0 -tags pieLabeller($this)]                                             ;# create value label
    catch {$canvas itemconfigure $valueId -font $piePeripheralLabeller::($this,smallFont)}              ;# eventually use small font
    set box [$canvas bbox $valueId]
    set smallTextHeight [expr {[lindex $box 3]-[lindex $box 1]}]

    if {![info exists piePeripheralLabeller::($this,array)]} {                                        ;# create a split labels array
        set options "-style split -justify $piePeripheralLabeller::($this,justify) -xoffset $pieLabeller::($this,xOffset)"
        catch {lappend options -bulletwidth $piePeripheralLabeller::($this,bulletWidth)}
        catch {lappend options -font $pieLabeller::($this,font)}                                     ;# eventually use labeller font
        set box [$canvas bbox pie($pieLabeller::($this,pieId))]                                          ;# position array below pie
        set piePeripheralLabeller::($this,array) [eval new canvasLabelsArray\
            $canvas [lindex $box 0] [expr {[lindex $box 3]+(2*$pieLabeller::($this,offset))+$smallTextHeight}]\
            [expr {[lindex $box 2]-[lindex $box 0]}] $options\
        ]
    }

    # this label font may be overriden in arguments
    set labelId [eval canvasLabelsArray::create $piePeripheralLabeller::($this,array) $args]
    $canvas addtag pieLabeller($this) withtag canvasLabelsArray($piePeripheralLabeller::($this,array))           ;# refresh our tags

    set piePeripheralLabeller::($this,sliceId,$valueId) $sliceId                            ;# value label is the only one to update
    return $valueId
}

proc piePeripheralLabeller::anglePosition {degrees} {
    return [expr {(2*($degrees/90))+(($degrees%90)!=0)}]              ;# quadrant specific index with added value for exact quarters
}

set index 0                                                               ;# build angle position / value label anchor mapping array
foreach anchor {w sw s se e ne n nw} {
    set piePeripheralLabeller::(anchor,[piePeripheralLabeller::anglePosition [expr {$index*45}]]) $anchor
    incr index
}
unset index anchor

proc piePeripheralLabeller::update {this valueId value} {
    piePeripheralLabeller::rotate $this $valueId
    $pieLabeller::($this,canvas) itemconfigure $valueId -text $value
}

proc piePeripheralLabeller::rotate {this valueId} {
    global PI

    set canvas $pieLabeller::($this,canvas)
    set sliceId $piePeripheralLabeller::($this,sliceId,$valueId)

    slice::data $sliceId data

    # calculate text closest point coordinates in normal coordinates system (y increasing in north direction)
    set midAngle [expr {$data(start)+($data(extent)/2.0)}]
    set radians [expr {$midAngle*$PI/180}]
    set x [expr {($data(xRadius)+$pieLabeller::($this,offset))*cos($radians)}]
    set y [expr {($data(yRadius)+$pieLabeller::($this,offset))*sin($radians)}]
    set angle [expr {round($midAngle)%360}]
    if {$angle>180} {
        set y [expr {$y-$data(height)}]                                                                 ;# account for pie thickness
    }

    # now transform coordinates according to canvas coordinates system
    set coordinates [$pieLabeller::($this,canvas) coords $valueId]
    $pieLabeller::($this,canvas) move $valueId\
        [expr {$data(xCenter)+$x-[lindex $coordinates 0]}] [expr {$data(yCenter)-$y-[lindex $coordinates 1]}]

    # finally set anchor according to which point of the text is closest to pie graphics
    $canvas itemconfigure $valueId -anchor $piePeripheralLabeller::(anchor,[piePeripheralLabeller::anglePosition $angle])
}
