# $Id: slice.tcl,v 1.1 1994/07/25 09:59:46 jfontain Exp $

source ../tools/utility.tcl

set PI 3.14159265358979323846
set twoPI 6.2831853071795864769
set halfPI 1.57079632679489661923

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

proc slice::slice {\
    id canvas centerX centerY radiusX radiusY startRadian extentRadian {height 0} {topColor ""} {bottomColor ""}\
} {
    global slice PI twoPI

    set slice($id,canvas) $canvas
    set slice($id,centerX) $centerX
    set slice($id,centerY) $centerY
    set slice($id,start) 0
    set slice($id,radiusX) $radiusX
    set slice($id,radiusY) $radiusY
    # normalize extent by choosing a value slightly less than 2 PI for too large values, for slice size cannot be 2 PI
    set extentRadian [maximum 0 [minimum [expr $twoPI-0.0001] $extentRadian]]
    set slice($id,extent) $extentRadian
    set extentDegrees [expr $extentRadian*180/$PI]
    set slice($id,height) $height

    set arcLeft [expr $centerX-$radiusX]
    set arcTop [expr $centerY-$radiusY]
    set arcRight [expr $centerX+$radiusX]
    set arcBottom [expr $centerY+$radiusY]

    if {$height>0} {
        # 3D
        set slice($id,startBottomArcFill)\
            [$canvas create arc\
                $arcLeft $arcTop $arcRight $arcBottom -style chord -extent 0 -fill $bottomColor -outline $bottomColor\
            ]
        set slice($id,startPolygon) [$canvas create polygon 0 0 0 0 0 0 -fill $bottomColor]
        set slice($id,startBottomArc) [$canvas create arc $arcLeft $arcTop $arcRight $arcBottom -style arc -extent 0 -fill black]
        $canvas move $slice($id,startBottomArcFill) 0 $height
        $canvas move $slice($id,startBottomArc) 0 $height

        set slice($id,endBottomArcFill)\
            [$canvas create arc\
                $arcLeft $arcTop $arcRight $arcBottom -style chord -extent 0 -fill $bottomColor -outline $bottomColor\
            ]
        set slice($id,endPolygon) [$canvas create polygon 0 0 0 0 0 0 -fill $bottomColor]
        set slice($id,endBottomArc) [$canvas create arc $arcLeft $arcTop $arcRight $arcBottom -style arc -extent 0 -fill black]
        $canvas move $slice($id,endBottomArcFill) 0 $height
        $canvas move $slice($id,endBottomArc) 0 $height

        set slice($id,startLeftLine) [$canvas create line 0 0 0 0]
        set slice($id,startRightLine) [$canvas create line 0 0 0 0]
        set slice($id,endLeftLine) [$canvas create line 0 0 0 0]
        set slice($id,endRightLine) [$canvas create line 0 0 0 0]
    }

    set slice($id,topArc) [$canvas create arc $arcLeft $arcTop $arcRight $arcBottom -extent $extentDegrees -fill $topColor]
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

    set radiusX $slice($id,radiusX)
    set radiusY $slice($id,radiusY)
    set centerX $slice($id,centerX)
    set centerY $slice($id,centerY)
    set height $slice($id,height)

    # first make all bottom parts invisible
    $slice($id,canvas) itemconfigure $slice($id,startBottomArcFill) -extent 0
    $slice($id,canvas) itemconfigure $slice($id,startBottomArc) -extent 0
    $slice($id,canvas) coords $slice($id,startLeftLine) 0 0 0 0
    $slice($id,canvas) coords $slice($id,startRightLine) 0 0 0 0
    $slice($id,canvas) itemconfigure $slice($id,endBottomArcFill) -extent 0
    $slice($id,canvas) itemconfigure $slice($id,endBottomArc) -extent 0
    $slice($id,canvas) coords $slice($id,endLeftLine) 0 0 0 0
    $slice($id,canvas) coords $slice($id,endRightLine) 0 0 0 0
    $slice($id,canvas) coords $slice($id,startPolygon) 0 0 0 0 0 0 0 0
    $slice($id,canvas) coords $slice($id,endPolygon) 0 0 0 0 0 0 0 0

    set startX [expr $centerX+($radiusX*cos($startRadian))]
    set startY [expr $centerY-($radiusY*sin($startRadian))]
    set endRadian [moduloPI [expr $startRadian+$extentRadian]]
    set endX [expr $centerX+($radiusX*cos($endRadian))]
    set endY [expr $centerY-($radiusY*sin($endRadian))]

    set left [expr $centerX-$radiusX]
    set right [expr $centerX+$radiusX]

    set bottom [expr $centerY+$height]
    set startBottom [expr $startY+$height]
    set endBottom [expr $endY+$height]

    if {(($startRadian>=0)&&($endRadian>=0))||(($startRadian<0)&&($endRadian<0))} {
        # start and end angles are on the same side of the 0 abscissa
        if {$extentRadian<=$PI} {
            # slice size is less than half pie
            if {$startRadian<0} {
                # slice is facing viewer, so bottom is visible
                $slice($id,canvas) itemconfigure $slice($id,startBottomArcFill) -start $startDegrees -extent $extentDegrees
                $slice($id,canvas) itemconfigure $slice($id,startBottomArc) -start $startDegrees -extent $extentDegrees
                # only one polygon is needed
                $slice($id,canvas) coords $slice($id,startPolygon) $startX $startY $endX $endY $endX $endBottom $startX $startBottom
                $slice($id,canvas) coords $slice($id,startLeftLine) $startX $startY $startX $startBottom
                $slice($id,canvas) coords $slice($id,startRightLine) $endX $endY $endX $endBottom
            }
            # else only top is visible
        } else {
            # slice size is more than half pie
            if {$startRadian<0} {
                # slice opening is facing viewer, so bottom is in 2 parts
                $slice($id,canvas) itemconfigure $slice($id,startBottomArcFill) -start 0 -extent $startDegrees
                $slice($id,canvas) itemconfigure $slice($id,startBottomArc) -start 0 -extent $startDegrees
                $slice($id,canvas) coords $slice($id,startPolygon)\
                    $startX $startY $right $centerY $right $bottom $startX $startBottom
                $slice($id,canvas) coords $slice($id,startLeftLine) $startX $startY $startX $startBottom
                $slice($id,canvas) coords $slice($id,startRightLine) $right $centerY $right $bottom

                set bottomArcExtent [expr ($endRadian+$PI)*180/$PI]
                $slice($id,canvas) itemconfigure $slice($id,endBottomArcFill) -start -180 -extent $bottomArcExtent
                $slice($id,canvas) itemconfigure $slice($id,endBottomArc) -start -180 -extent $bottomArcExtent
                $slice($id,canvas) coords $slice($id,endPolygon) $left $centerY $endX $endY $endX $endBottom $left $bottom
                $slice($id,canvas) coords $slice($id,endLeftLine) $left $centerY $left $bottom
                $slice($id,canvas) coords $slice($id,endRightLine) $endX $endY $endX $endBottom
            } else {
                # slice back is facing viewer, so bottom occupies half the pie
                $slice($id,canvas) itemconfigure $slice($id,startBottomArcFill) -start 0 -extent -180
                $slice($id,canvas) itemconfigure $slice($id,startBottomArc) -start 0 -extent -180
                # only one polygon is needed
                $slice($id,canvas) coords $slice($id,startPolygon) $left $centerY $right $centerY $right $bottom $left $bottom
                $slice($id,canvas) coords $slice($id,startLeftLine) $left $centerY $left $bottom
                $slice($id,canvas) coords $slice($id,startRightLine) $right $centerY $right $bottom
            }
        }
    } else {
        # start and end angles are on opposite sides of the 0 abscissa
        if {$startRadian<0} {
            # slice start is facing viewer
            $slice($id,canvas) itemconfigure $slice($id,startBottomArcFill) -start 0 -extent $startDegrees
            $slice($id,canvas) itemconfigure $slice($id,startBottomArc) -start 0 -extent $startDegrees
            # only one polygon is needed
            $slice($id,canvas) coords $slice($id,startPolygon) $startX $startY $right $centerY $right $bottom $startX $startBottom
            $slice($id,canvas) coords $slice($id,startLeftLine) $startX $startY $startX $startBottom
            $slice($id,canvas) coords $slice($id,startRightLine) $right $centerY $right $bottom
        } else {
            # slice end is facing viewer
            set bottomArcExtent [expr ($endRadian+$PI)*180/$PI]
            $slice($id,canvas) itemconfigure $slice($id,endBottomArcFill) -start -180 -extent $bottomArcExtent
            $slice($id,canvas) itemconfigure $slice($id,endBottomArc) -start -180 -extent $bottomArcExtent
            # only one polygon is needed
            $slice($id,canvas) coords $slice($id,endPolygon) $left $centerY $endX $endY $endX $endBottom $left $bottom
            $slice($id,canvas) coords $slice($id,startLeftLine) $left $centerY $left $bottom
            $slice($id,canvas) coords $slice($id,startRightLine) $endX $endY $endX $endBottom
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
                                                                                                                          