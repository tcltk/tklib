set rcsId {$Id: slice.tcl,v 1.24 1995/10/14 17:13:32 jfontain Exp $}

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

proc slice::slice {this canvas x y radiusX radiusY start extent args} {
    # all dimensions must be in pixels
    # note: all slice elements are tagged with slice($this)
    global slice

    # set options default then parse switched options
    array set option {-height 0 -topcolor {} -bottomcolor {}}
    array set option $args

    set slice($this,canvas) $canvas
    set slice($this,start) 0
    set slice($this,radiusX) $radiusX
    set slice($this,radiusY) $radiusY
    set slice($this,height) $option(-height)
    # extent member is set in update{}

    # use a dimensionless line as an origin marker
    set slice($this,origin) [$canvas create line -$radiusX -$radiusY -$radiusX -$radiusY -fill {} -tags slice($this)]

    if {$option(-height)>0} {
        # 3D
        set slice($this,startBottomArcFill) [$canvas create arc\
            0 0 0 0 -style chord -extent 0 -fill $option(-bottomcolor) -outline $option(-bottomcolor) -tags slice($this)\
        ]
        set slice($this,startPolygon) [$canvas create polygon 0 0 0 0 0 0 -fill $option(-bottomcolor) -tags slice($this)]
        set slice($this,startBottomArc) [$canvas create arc 0 0 0 0 -style arc -extent 0 -fill black -tags slice($this)]

        set slice($this,endBottomArcFill) [$canvas create arc\
            0 0 0 0 -style chord -extent 0 -fill $option(-bottomcolor) -outline $option(-bottomcolor) -tags slice($this)\
        ]
        set slice($this,endPolygon) [$canvas create polygon 0 0 0 0 0 0 -fill $option(-bottomcolor) -tags slice($this)]
        set slice($this,endBottomArc) [$canvas create arc 0 0 0 0 -style arc -extent 0 -fill black -tags slice($this)]

        set slice($this,startLeftLine) [$canvas create line 0 0 0 0 -tags slice($this)]
        set slice($this,startRightLine) [$canvas create line 0 0 0 0 -tags slice($this)]
        set slice($this,endLeftLine) [$canvas create line 0 0 0 0 -tags slice($this)]
        set slice($this,endRightLine) [$canvas create line 0 0 0 0 -tags slice($this)]
    }

    set slice($this,topArc)\
        [$canvas create arc -$radiusX -$radiusY $radiusX $radiusY -extent $extent -fill $option(-topcolor) -tags slice($this)]

    # move slice so upper-left corner is at requested coordinates
    $canvas move slice($this) [expr $x+$radiusX] [expr $y+$radiusY]

    slice::update $this $start $extent
}

proc slice::~slice {this} {
    global slice

    $slice($this,canvas) delete slice($this)
}

proc slice::update {this start extent} {
    global slice

    set canvas $slice($this,canvas)

    # first store slice position in case it was moved as a whole
    set coordinates [$canvas coords slice($this)]

    set radiusX $slice($this,radiusX)
    set radiusY $slice($this,radiusY)
    $canvas coords $slice($this,origin) -$radiusX -$radiusY $radiusX $radiusY
    $canvas coords $slice($this,topArc) -$radiusX -$radiusY $radiusX $radiusY

    # normalize extent by choosing a value slightly less than 360 degrees for too large values, for slice size cannot be 360
    set extent [maximum 0 $extent]
    if {$extent>=360} {
        set extent 359.9999999999999
    }
    $canvas itemconfigure $slice($this,topArc)\
        -start [set slice($this,start) [normalizedAngle $start]] -extent [set slice($this,extent) $extent]

    if {$slice($this,height)>0} {
        # if 3D
        slice::updateBottom $this
    }

    # now position slice at the correct coordinates
    $canvas move slice($this) [expr [lindex $coordinates 0]+$radiusX] [expr [lindex $coordinates 1]+$radiusY]
}

proc slice::updateBottom {this} {
    global slice PI

    set start $slice($this,start)
    set extent $slice($this,extent)

    set canvas $slice($this,canvas)
    set radiusX $slice($this,radiusX)
    set radiusY $slice($this,radiusY)
    set height $slice($this,height)

    # first make all bottom parts invisible
    $canvas itemconfigure $slice($this,startBottomArcFill) -extent 0
    $canvas coords $slice($this,startBottomArcFill) -$radiusX -$radiusY $radiusX $radiusY
    $canvas move $slice($this,startBottomArcFill) 0 $height
    $canvas itemconfigure $slice($this,startBottomArc) -extent 0
    $canvas coords $slice($this,startBottomArc) -$radiusX -$radiusY $radiusX $radiusY
    $canvas move $slice($this,startBottomArc) 0 $height
    $canvas coords $slice($this,startLeftLine) 0 0 0 0
    $canvas coords $slice($this,startRightLine) 0 0 0 0
    $canvas itemconfigure $slice($this,endBottomArcFill) -extent 0
    $canvas coords $slice($this,endBottomArcFill) -$radiusX -$radiusY $radiusX $radiusY
    $canvas move $slice($this,endBottomArcFill) 0 $height
    $canvas itemconfigure $slice($this,endBottomArc) -extent 0
    $canvas coords $slice($this,endBottomArc) -$radiusX -$radiusY $radiusX $radiusY
    $canvas move $slice($this,endBottomArc) 0 $height
    $canvas coords $slice($this,endLeftLine) 0 0 0 0
    $canvas coords $slice($this,endRightLine) 0 0 0 0
    $canvas coords $slice($this,startPolygon) 0 0 0 0 0 0 0 0
    $canvas coords $slice($this,endPolygon) 0 0 0 0 0 0 0 0

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
                $canvas itemconfigure $slice($this,startBottomArcFill) -start $start -extent $extent
                $canvas itemconfigure $slice($this,startBottomArc) -start $start -extent $extent
                # only one polygon is needed
                $canvas coords $slice($this,startPolygon) $startX $startY $endX $endY $endX $endBottom $startX $startBottom
                $canvas coords $slice($this,startLeftLine) $startX $startY $startX $startBottom
                $canvas coords $slice($this,startRightLine) $endX $endY $endX $endBottom
            }
            # else only top is visible
        } else {
            # slice size is more than half pie
            if {$start<0} {
                # slice opening is facing viewer, so bottom is in 2 parts
                $canvas itemconfigure $slice($this,startBottomArcFill) -start 0 -extent $start
                $canvas itemconfigure $slice($this,startBottomArc) -start 0 -extent $start
                $canvas coords $slice($this,startPolygon) $startX $startY $radiusX 0 $radiusX $height $startX $startBottom
                $canvas coords $slice($this,startLeftLine) $startX $startY $startX $startBottom
                $canvas coords $slice($this,startRightLine) $radiusX 0 $radiusX $height

                set bottomArcExtent [expr $end+180]
                $canvas itemconfigure $slice($this,endBottomArcFill) -start -180 -extent $bottomArcExtent
                $canvas itemconfigure $slice($this,endBottomArc) -start -180 -extent $bottomArcExtent
                $canvas coords $slice($this,endPolygon) -$radiusX 0 $endX $endY $endX $endBottom -$radiusX $height
                $canvas coords $slice($this,endLeftLine) -$radiusX 0 -$radiusX $height
                $canvas coords $slice($this,endRightLine) $endX $endY $endX $endBottom
            } else {
                # slice back is facing viewer, so bottom occupies half the pie
                $canvas itemconfigure $slice($this,startBottomArcFill) -start 0 -extent -180
                $canvas itemconfigure $slice($this,startBottomArc) -start 0 -extent -180
                # only one polygon is needed
                $canvas coords $slice($this,startPolygon) -$radiusX 0 $radiusX 0 $radiusX $height -$radiusX $height
                $canvas coords $slice($this,startLeftLine) -$radiusX 0 -$radiusX $height
                $canvas coords $slice($this,startRightLine) $radiusX 0 $radiusX $height
            }
        }
    } else {
        # start and end angles are on opposite sides of the 0 abscissa
        if {$start<0} {
            # slice start is facing viewer
            $canvas itemconfigure $slice($this,startBottomArcFill) -start 0 -extent $start
            $canvas itemconfigure $slice($this,startBottomArc) -start 0 -extent $start
            # only one polygon is needed
            $canvas coords $slice($this,startPolygon) $startX $startY $radiusX 0 $radiusX $height $startX $startBottom
            $canvas coords $slice($this,startLeftLine) $startX $startY $startX $startBottom
            $canvas coords $slice($this,startRightLine) $radiusX 0 $radiusX $height
        } else {
            # slice end is facing viewer
            set bottomArcExtent [expr $end+180]
            $canvas itemconfigure $slice($this,endBottomArcFill) -start -180 -extent $bottomArcExtent
            $canvas itemconfigure $slice($this,endBottomArc) -start -180 -extent $bottomArcExtent
            # only one polygon is needed
            $canvas coords $slice($this,endPolygon) -$radiusX 0 $endX $endY $endX $endBottom -$radiusX $height
            $canvas coords $slice($this,startLeftLine) -$radiusX 0 -$radiusX $height
            $canvas coords $slice($this,startRightLine) $endX $endY $endX $endBottom
        }
    }
}

proc slice::position {this start} {
    global slice

    slice::update $this $start $slice($this,extent)
}

proc slice::rotate {this angle} {
    global slice

    if {$angle!=0} {
        slice::update $this [expr $slice($this,start)+$angle] $slice($this,extent)
    }
}

proc slice::size {this extent} {
    global slice

    slice::update $this $slice($this,start) $extent
}

proc slice::data {this arrayName} {
    global slice
    upvar $arrayName data

    set data(start) $slice($this,start)
    set data(extent) $slice($this,extent)
    set data(xRadius) $slice($this,radiusX)
    set data(yRadius) $slice($this,radiusY)
    set coordinates [$slice($this,canvas) coords $slice($this,origin)]
    set data(xCenter) [expr [lindex $coordinates 0]+$data(xRadius)]
    set data(yCenter) [expr [lindex $coordinates 1]+$data(yRadius)]
    set data(height) $slice($this,height)
}
