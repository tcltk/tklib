# $Id: slice.tcl,v 1.8 1995/06/21 09:46:34 jfontain Exp $

source $env(AGVHOME)/tools/utility.tk

proc moduloTwoPI {value} {
    # normalize value between 0 and 2*PI (not included)
    global twoPI

    if {$value>=0} {
        while {$value>=$twoPI} {
            set value [expr $value-$twoPI]
        }
    } else {
        while {$value<0} {
            set value [expr $value+$twoPI]
        }
    }
    return $value
}

proc moduloPI {value} {
    # normalize value between -PI and PI (not included)
    global PI twoPI

    set value [moduloTwoPI $value]
    return [expr $value>=$PI?$value-$twoPI:$value]
}

set slice(highlightLineWidth) 2

proc slice::slice {id canvas radiusX radiusY startRadian extentRadian {height 0} {topColor ""} {bottomColor ""}} {
    global slice PI twoPI

    set slice($id,canvas) $canvas
    set slice($id,start) 0
    set slice($id,radiusX) $radiusX
    set slice($id,radiusY) $radiusY
    # normalize extent by choosing a value slightly less than 2 PI for too large values, for slice size cannot be 2 PI
    set extentRadian [maximum 0 [minimum [expr $twoPI-0.0001] $extentRadian]]
    set slice($id,extent) $extentRadian
    set extentDegrees [expr $extentRadian*180/$PI]
    set slice($id,height) $height

    if {$height>0} {
        # 3D
        set slice($id,startBottomArcFill)\
            [$canvas create arc\
                -$radiusX -$radiusY $radiusX $radiusY -style chord -extent 0 -fill $bottomColor -outline $bottomColor\
            ]
        set slice($id,startPolygon) [$canvas create polygon 0 0 0 0 0 0 -fill $bottomColor]
        set slice($id,startBottomArc) [$canvas create arc -$radiusX -$radiusY $radiusX $radiusY -style arc -extent 0 -fill black]
        $canvas move $slice($id,startBottomArcFill) 0 $height
        $canvas move $slice($id,startBottomArc) 0 $height

        set slice($id,endBottomArcFill)\
            [$canvas create arc\
                -$radiusX -$radiusY $radiusX $radiusY -style chord -extent 0 -fill $bottomColor -outline $bottomColor\
            ]
        set slice($id,endPolygon) [$canvas create polygon 0 0 0 0 0 0 -fill $bottomColor]
        set slice($id,endBottomArc) [$canvas create arc -$radiusX -$radiusY $radiusX $radiusY -style arc -extent 0 -fill black]
        $canvas move $slice($id,endBottomArcFill) 0 $height
        $canvas move $slice($id,endBottomArc) 0 $height

        set slice($id,startLeftLine) [$canvas create line 0 0 0 0]
        set slice($id,startRightLine) [$canvas create line 0 0 0 0]
        set slice($id,endLeftLine) [$canvas create line 0 0 0 0]
        set slice($id,endRightLine) [$canvas create line 0 0 0 0]
    }

    set slice($id,topArc) [$canvas create arc -$radiusX -$radiusY $radiusX $radiusY -extent $extentDegrees -fill $topColor]
    slice::update $id [moduloPI $startRadian] $extentRadian
}

proc slice::~slice {id} {
    global slice

    $slice($id,canvas) delete $slice($id,topArc)
    if {$slice($id,height)>0} {
        $slice($id,canvas) delete $slice($id,startBottomArcFill) $slice($id,startBottomArc) $slice($id,startLeftLine)\
            $slice($id,startRightLine) $slice($id,endBottomArcFill) $slice($id,endBottomArc) $slice($id,startPolygon)\
            $slice($id,endLeftLine) $slice($id,endRightLine) $slice($id,endPolygon)
    }
}

proc slice::update {id radian extentRadian} {
    global slice PI twoPI

    set slice($id,start) [set startRadian [moduloPI $radian]]
    set startDegrees [expr $startRadian*180/$PI]
    # normalize extent by choosing a value slightly less than 2 PI for too large values, for slice size cannot be 2 PI
    set extentRadian [maximum 0 [minimum [expr $twoPI-0.0001] $extentRadian]]
    set slice($id,extent) $extentRadian
    set extentDegrees [expr $extentRadian*180/$PI]
    $slice($id,canvas) itemconfigure $slice($id,topArc) -start $startDegrees -extent $extentDegrees

    if {$slice($id,height)>0} {
        # if 3D
        slice::updateBottom $id
    }
}

proc slice::updateBottom {id} {
    global slice PI twoPI

    set startDegrees [expr [set startRadian $slice($id,start)]*180/$PI]
    set extentDegrees [expr [set extentRadian $slice($id,extent)]*180/$PI]

    set canvas $slice($id,canvas)
    set radiusX $slice($id,radiusX)
    set radiusY $slice($id,radiusY)
    set height $slice($id,height)

    # first make all bottom parts invisible
    $canvas itemconfigure $slice($id,startBottomArcFill) -extent 0
    $canvas itemconfigure $slice($id,startBottomArc) -extent 0
    $canvas coords $slice($id,startLeftLine) 0 0 0 0
    $canvas coords $slice($id,startRightLine) 0 0 0 0
    $canvas itemconfigure $slice($id,endBottomArcFill) -extent 0
    $canvas itemconfigure $slice($id,endBottomArc) -extent 0
    $canvas coords $slice($id,endLeftLine) 0 0 0 0
    $canvas coords $slice($id,endRightLine) 0 0 0 0
    $canvas coords $slice($id,startPolygon) 0 0 0 0 0 0 0 0
    $canvas coords $slice($id,endPolygon) 0 0 0 0 0 0 0 0

    set startX [expr $radiusX*cos($startRadian)]
    set startY [expr -$radiusY*sin($startRadian)]
    set endRadian [moduloPI [expr $startRadian+$extentRadian]]
    set endX [expr $radiusX*cos($endRadian)]
    set endY [expr -$radiusY*sin($endRadian)]

    set startBottom [expr $startY+$height]
    set endBottom [expr $endY+$height]

    if {(($startRadian>=0)&&($endRadian>=0))||(($startRadian<0)&&($endRadian<0))} {
        # start and end angles are on the same side of the 0 abscissa
        if {$extentRadian<=$PI} {
            # slice size is less than half pie
            if {$startRadian<0} {
                # slice is facing viewer, so bottom is visible
                $canvas itemconfigure $slice($id,startBottomArcFill) -start $startDegrees -extent $extentDegrees
                $canvas itemconfigure $slice($id,startBottomArc) -start $startDegrees -extent $extentDegrees
                # only one polygon is needed
                $canvas coords $slice($id,startPolygon) $startX $startY $endX $endY $endX $endBottom $startX $startBottom
                $canvas coords $slice($id,startLeftLine) $startX $startY $startX $startBottom
                $canvas coords $slice($id,startRightLine) $endX $endY $endX $endBottom
            }
            # else only top is visible
        } else {
            # slice size is more than half pie
            if {$startRadian<0} {
                # slice opening is facing viewer, so bottom is in 2 parts
                $canvas itemconfigure $slice($id,startBottomArcFill) -start 0 -extent $startDegrees
                $canvas itemconfigure $slice($id,startBottomArc) -start 0 -extent $startDegrees
                $canvas coords $slice($id,startPolygon) $startX $startY $radiusX 0 $radiusX $height $startX $startBottom
                $canvas coords $slice($id,startLeftLine) $startX $startY $startX $startBottom
                $canvas coords $slice($id,startRightLine) $radiusX 0 $radiusX $height

                set bottomArcExtent [expr ($endRadian+$PI)*180/$PI]
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
        if {$startRadian<0} {
            # slice start is facing viewer
            $canvas itemconfigure $slice($id,startBottomArcFill) -start 0 -extent $startDegrees
            $canvas itemconfigure $slice($id,startBottomArc) -start 0 -extent $startDegrees
            # only one polygon is needed
            $canvas coords $slice($id,startPolygon) $startX $startY $radiusX 0 $radiusX $height $startX $startBottom
            $canvas coords $slice($id,startLeftLine) $startX $startY $startX $startBottom
            $canvas coords $slice($id,startRightLine) $radiusX 0 $radiusX $height
        } else {
            # slice end is facing viewer
            set bottomArcExtent [expr ($endRadian+$PI)*180/$PI]
            $canvas itemconfigure $slice($id,endBottomArcFill) -start -180 -extent $bottomArcExtent
            $canvas itemconfigure $slice($id,endBottomArc) -start -180 -extent $bottomArcExtent
            # only one polygon is needed
            $canvas coords $slice($id,endPolygon) -$radiusX 0 $endX $endY $endX $endBottom -$radiusX $height
            $canvas coords $slice($id,startLeftLine) -$radiusX 0 -$radiusX $height
            $canvas coords $slice($id,startRightLine) $endX $endY $endX $endBottom
        }
    }
}

proc slice::position {id radian} {
    global slice

    slice::update $id $radian $slice($id,extent)
}

proc slice::rotate {id radian} {
    global slice

    if {$radian!=0} {
        slice::update $id [expr $slice($id,start)+$radian] $slice($id,extent)
    }
}

proc slice::size {id extentRadian} {
    global slice

    slice::update $id $slice($id,start) $extentRadian
}

proc slice::setupHighlighting {id enterCommand leaveCommand} {
    global slice

    set canvas $slice($id,canvas)

    # first tag all item susceptible to see pointer movement
    set sensitiveTag sensitive${id}
    $canvas addtag $sensitiveTag withtag $slice($id,topArc)

    # then tag all item susceptible to be highlighted
    set highlightTag highlight${id}
    $canvas addtag $highlightTag withtag $slice($id,topArc)

    if {$slice($id,height)>0} {
        # if 3D
        $canvas addtag $sensitiveTag withtag $slice($id,startBottomArcFill)
        $canvas addtag $sensitiveTag withtag $slice($id,startPolygon)
        $canvas addtag $sensitiveTag withtag $slice($id,endBottomArcFill)
        $canvas addtag $sensitiveTag withtag $slice($id,endPolygon)
        $canvas addtag $highlightTag withtag $slice($id,startBottomArc)
        $canvas addtag $highlightTag withtag $slice($id,endBottomArc)
        $canvas addtag $highlightTag withtag $slice($id,startLeftLine)
        $canvas addtag $highlightTag withtag $slice($id,startRightLine)
        $canvas addtag $highlightTag withtag $slice($id,endLeftLine)
        $canvas addtag $highlightTag withtag $slice($id,endRightLine)
    }
    $canvas bind $sensitiveTag <Enter> "$canvas itemconfigure $highlightTag -width $slice(highlightLineWidth); $enterCommand"
    $canvas bind $sensitiveTag <Leave> "$canvas itemconfigure $highlightTag -width 1; $leaveCommand"
}
