set rcsId {$Id: slice.tcl,v 1.23 1995/10/11 20:59:17 jfontain Exp $}

source util.tcl

proc normalizedAngle {value} {
    # normalize value between -180 and 180 degrees (not included)
    while {$value>=180} {
        set value [expr $value-360]
    }
    while {$value<-180} {
        set value [expr $value+360]
    }
    return $value
}

proc slice::slice {id canvas x y radiusX radiusY start extent args} {
    # all dimensions must be in pixels
    # note: all slice elements are tagged with slice($id)
    global slice

    # set options default then parse switched options
    array set option {-height 0 -topcolor {} -bottomcolor {}}
    array set option $args

    set slice($id,canvas) $canvas
    set slice($id,start) 0
    set slice($id,radiusX) $radiusX
    set slice($id,radiusY) $radiusY
    set slice($id,height) $option(-height)
    # extent member is set in update{}

    # use a dimensionless line as an origin marker
    set slice($id,origin) [$canvas create line -$radiusX -$radiusY -$radiusX -$radiusY -fill {} -tags slice($id)]

    if {$option(-height)>0} {
        # 3D
        set slice($id,startBottomArcFill) [$canvas create arc\
            0 0 0 0 -style chord -extent 0 -fill $option(-bottomcolor) -outline $option(-bottomcolor) -tags slice($id)\
        ]
        set slice($id,startPolygon) [$canvas create polygon 0 0 0 0 0 0 -fill $option(-bottomcolor) -tags slice($id)]
        set slice($id,startBottomArc) [$canvas create arc 0 0 0 0 -style arc -extent 0 -fill black -tags slice($id)]

        set slice($id,endBottomArcFill) [$canvas create arc\
            0 0 0 0 -style chord -extent 0 -fill $option(-bottomcolor) -outline $option(-bottomcolor) -tags slice($id)\
        ]
        set slice($id,endPolygon) [$canvas create polygon 0 0 0 0 0 0 -fill $option(-bottomcolor) -tags slice($id)]
        set slice($id,endBottomArc) [$canvas create arc 0 0 0 0 -style arc -extent 0 -fill black -tags slice($id)]

        set slice($id,startLeftLine) [$canvas create line 0 0 0 0 -tags slice($id)]
        set slice($id,startRightLine) [$canvas create line 0 0 0 0 -tags slice($id)]
        set slice($id,endLeftLine) [$canvas create line 0 0 0 0 -tags slice($id)]
        set slice($id,endRightLine) [$canvas create line 0 0 0 0 -tags slice($id)]
    }

    set slice($id,topArc)\
        [$canvas create arc -$radiusX -$radiusY $radiusX $radiusY -extent $extent -fill $option(-topcolor) -tags slice($id)]

    # move slice so upper-left corner is at requested coordinates
    $canvas move slice($id) [expr $x+$radiusX] [expr $y+$radiusY]

    slice::update $id $start $extent
}

proc slice::~slice {id} {
    global slice

    $slice($id,canvas) delete slice($id)
}

proc slice::update {id start extent} {
    global slice

    set canvas $slice($id,canvas)

    # first store slice position in case it was moved as a whole
    set coordinates [$canvas coords slice($id)]

    set radiusX $slice($id,radiusX)
    set radiusY $slice($id,radiusY)
    $canvas coords $slice($id,origin) -$radiusX -$radiusY $radiusX $radiusY
    $canvas coords $slice($id,topArc) -$radiusX -$radiusY $radiusX $radiusY

    # normalize extent by choosing a value slightly less than 360 degrees for too large values, for slice size cannot be 360
    set extent [maximum 0 $extent]
    if {$extent>=360} {
        set extent 359.9999999999999
    }
    $canvas itemconfigure $slice($id,topArc)\
        -start [set slice($id,start) [normalizedAngle $start]] -extent [set slice($id,extent) $extent]

    if {$slice($id,height)>0} {
        # if 3D
        slice::updateBottom $id
    }

    # now position slice at the correct coordinates
    $canvas move slice($id) [expr [lindex $coordinates 0]+$radiusX] [expr [lindex $coordinates 1]+$radiusY]
}

proc slice::updateBottom {id} {
    global slice PI

    set start $slice($id,start)
    set extent $slice($id,extent)

    set canvas $slice($id,canvas)
    set radiusX $slice($id,radiusX)
    set radiusY $slice($id,radiusY)
    set height $slice($id,height)

    # first make all bottom parts invisible
    $canvas itemconfigure $slice($id,startBottomArcFill) -extent 0
    $canvas coords $slice($id,startBottomArcFill) -$radiusX -$radiusY $radiusX $radiusY
    $canvas move $slice($id,startBottomArcFill) 0 $height
    $canvas itemconfigure $slice($id,startBottomArc) -extent 0
    $canvas coords $slice($id,startBottomArc) -$radiusX -$radiusY $radiusX $radiusY
    $canvas move $slice($id,startBottomArc) 0 $height
    $canvas coords $slice($id,startLeftLine) 0 0 0 0
    $canvas coords $slice($id,startRightLine) 0 0 0 0
    $canvas itemconfigure $slice($id,endBottomArcFill) -extent 0
    $canvas coords $slice($id,endBottomArcFill) -$radiusX -$radiusY $radiusX $radiusY
    $canvas move $slice($id,endBottomArcFill) 0 $height
    $canvas itemconfigure $slice($id,endBottomArc) -extent 0
    $canvas coords $slice($id,endBottomArc) -$radiusX -$radiusY $radiusX $radiusY
    $canvas move $slice($id,endBottomArc) 0 $height
    $canvas coords $slice($id,endLeftLine) 0 0 0 0
    $canvas coords $slice($id,endRightLine) 0 0 0 0
    $canvas coords $slice($id,startPolygon) 0 0 0 0 0 0 0 0
    $canvas coords $slice($id,endPolygon) 0 0 0 0 0 0 0 0

    set startX [expr $radiusX*cos($start*$PI/180)]
    set startY [expr -$radiusY*sin($start*$PI/180)]
    set end [normalizedAngle [expr $start+$extent]]
    set endX [expr $radiusX*cos($end*$PI/180)]
    set endY [expr -$radiusY*sin($end*$PI/180)]

    set startBottom [expr $startY+$height]
    set endBottom [expr $endY+$height]

    if {(($start>=0)&&($end>=0))||(($start<0)&&($end<0))} {
        # start and end angles are on the same side of the 0 abscissa
        if {$extent<=180} {
            # slice size is less than half pie
            if {$start<0} {
                # slice is facing viewer, so bottom is visible
                $canvas itemconfigure $slice($id,startBottomArcFill) -start $start -extent $extent
                $canvas itemconfigure $slice($id,startBottomArc) -start $start -extent $extent
                # only one polygon is needed
                $canvas coords $slice($id,startPolygon) $startX $startY $endX $endY $endX $endBottom $startX $startBottom
                $canvas coords $slice($id,startLeftLine) $startX $startY $startX $startBottom
                $canvas coords $slice($id,startRightLine) $endX $endY $endX $endBottom
            }
            # else only top is visible
        } else {
            # slice size is more than half pie
            if {$start<0} {
                # slice opening is facing viewer, so bottom is in 2 parts
                $canvas itemconfigure $slice($id,startBottomArcFill) -start 0 -extent $start
                $canvas itemconfigure $slice($id,startBottomArc) -start 0 -extent $start
                $canvas coords $slice($id,startPolygon) $startX $startY $radiusX 0 $radiusX $height $startX $startBottom
                $canvas coords $slice($id,startLeftLine) $startX $startY $startX $startBottom
                $canvas coords $slice($id,startRightLine) $radiusX 0 $radiusX $height

                set bottomArcExtent [expr $end+180]
                $canvas itemconfigure $slice($id,endBottomArcFill) -start -180 -extent $bottomArcExtent
                $canvas itemconfigure $slice($id,endBottomArc) -start -180 -extent $bottomArcExtent
                $canvas coords $slice($id,endPolygon) -$radiusX 0 $endX $endY $endX $endBottom -$radiusX $height
                $canvas coords $slice($id,endLeftLine) -$radiusX 0 -$radiusX $height
                $canvas coords $slice($id,endRightLine) $endX $endY $endX $endBottom
            } else {
                # slice back is facing viewer, so bottom occupies half the pie
                $canvas itemconfigure $slice($id,startBottomArcFill) -start 0 -extent -180
                $canvas itemconfigure $slice($id,startBottomArc) -start 0 -extent -180
                # only one polygon is needed
                $canvas coords $slice($id,startPolygon) -$radiusX 0 $radiusX 0 $radiusX $height -$radiusX $height
                $canvas coords $slice($id,startLeftLine) -$radiusX 0 -$radiusX $height
                $canvas coords $slice($id,startRightLine) $radiusX 0 $radiusX $height
            }
        }
    } else {
        # start and end angles are on opposite sides of the 0 abscissa
        if {$start<0} {
            # slice start is facing viewer
            $canvas itemconfigure $slice($id,startBottomArcFill) -start 0 -extent $start
            $canvas itemconfigure $slice($id,startBottomArc) -start 0 -extent $start
            # only one polygon is needed
            $canvas coords $slice($id,startPolygon) $startX $startY $radiusX 0 $radiusX $height $startX $startBottom
            $canvas coords $slice($id,startLeftLine) $startX $startY $startX $startBottom
            $canvas coords $slice($id,startRightLine) $radiusX 0 $radiusX $height
        } else {
            # slice end is facing viewer
            set bottomArcExtent [expr $end+180]
            $canvas itemconfigure $slice($id,endBottomArcFill) -start -180 -extent $bottomArcExtent
            $canvas itemconfigure $slice($id,endBottomArc) -start -180 -extent $bottomArcExtent
            # only one polygon is needed
            $canvas coords $slice($id,endPolygon) -$radiusX 0 $endX $endY $endX $endBottom -$radiusX $height
            $canvas coords $slice($id,startLeftLine) -$radiusX 0 -$radiusX $height
            $canvas coords $slice($id,startRightLine) $endX $endY $endX $endBottom
        }
    }
}

proc slice::position {id start} {
    global slice

    slice::update $id $start $slice($id,extent)
}

proc slice::rotate {id angle} {
    global slice

    if {$angle!=0} {
        slice::update $id [expr $slice($id,start)+$angle] $slice($id,extent)
    }
}

proc slice::size {id extent} {
    global slice

    slice::update $id $slice($id,start) $extent
}

proc slice::data {id arrayName} {
    global slice
    upvar $arrayName data

    set data(start) $slice($id,start)
    set data(extent) $slice($id,extent)
    set data(xRadius) $slice($id,radiusX)
    set data(yRadius) $slice($id,radiusY)
    set coordinates [$slice($id,canvas) coords $slice($id,origin)]
    set data(xCenter) [expr [lindex $coordinates 0]+$data(xRadius)]
    set data(yCenter) [expr [lindex $coordinates 1]+$data(yRadius)]
    set data(height) $slice($id,height)
}
