set rcsId {$Id: slice.tcl,v 1.38 1998/06/02 21:20:11 jfontain Exp $}


class slice {
    variable PI 3.14159265358979323846
}

proc slice::slice {this canvas x y xRadius yRadius args} switched {$args} {                      ;# all dimensions must be in pixels
    # note: all slice elements are tagged with slice($this)
    set slice::($this,canvas) $canvas
    set slice::($this,xRadius) $xRadius
    set slice::($this,yRadius) $yRadius
    switched::complete $this
    complete $this $x $y                                            ;# wait till all options have been set for initial configuration
    update $this
}

proc slice::~slice {this} {
    if {[string length $switched::($this,-deletecommand)]>0} {                              ;# always invoke command at global level
        uplevel $switched::($this,-deletecommand)
    }
    $slice::($this,canvas) delete slice($this)
}

proc slice::options {this} {
    return [list\
        [list -bottomcolor {} {}]\
        [list -deletecommand {} {}]\
        [list -height 0 0]\
        [list -scale {1 1} {1 1}]\
        [list -startandextent {0 0} {0 0}]\
        [list -topcolor {} {}]\
    ]
}

foreach option {-bottomcolor -height -topcolor} {                                        ;# no dynamic options allowed: see complete
    proc slice::set$option {this value} "
        if {\$switched::(\$this,complete)} {
            error {option $option cannot be set dynamically}
        }
    "
}

proc slice::set-deletecommand {this value} {}                                                    ;# data is stored at switched level

proc slice::set-scale {this value} {
    if {$switched::($this,complete)} {
        update $this                                                                       ;# requires initialization to be complete
    }
}

proc slice::set-startandextent {this value} {
    foreach {start extent} $value {}
    set slice::($this,start) [normalizedAngle $start]
    if {$extent<0} {
        set slice::($this,extent) 0                                                              ;# a negative extent is meaningless
    } elseif {$extent>=360} {                      ;# get as close as possible to 360, which would not work as it is equivalent to 0
        set slice::($this,extent) [expr {360-pow(10,-$::tcl_precision+3)}]
    } else {
        set slice::($this,extent) $extent
    }
    if {$switched::($this,complete)} {
        update $this                                                                       ;# requires initialization to be complete
    }
}

proc slice::normalizedAngle {value} {                                 ;# normalize value between -180 and 180 degrees (not included)
    while {$value>=180} {
        set value [expr {$value-360}]
    }
    while {$value<-180} {
        set value [expr {$value+360}]
    }
    return $value
}

proc slice::complete {this x y} {
    set canvas $slice::($this,canvas)
    set xRadius $slice::($this,xRadius)
    set yRadius $slice::($this,yRadius)
    set bottomColor $switched::($this,-bottomcolor)
    # use an empty image as an origin marker with only 2 coordinates
    set slice::($this,origin) [$canvas create image -$xRadius -$yRadius -tags slice($this)]
    if {$switched::($this,-height)>0} {                                                                                        ;# 3D
        set slice::($this,startBottomArcFill) [$canvas create arc\
            0 0 0 0 -style chord -extent 0 -fill $bottomColor -outline $bottomColor -tags slice($this)\
        ]
        set slice::($this,startPolygon) [$canvas create polygon 0 0 0 0 0 0 -fill $bottomColor -tags slice($this)]
        set slice::($this,startBottomArc) [$canvas create arc 0 0 0 0 -style arc -extent 0 -fill black -tags slice($this)]

        set slice::($this,endBottomArcFill) [$canvas create arc\
            0 0 0 0 -style chord -extent 0 -fill $bottomColor -outline $bottomColor -tags slice($this)\
        ]
        set slice::($this,endPolygon) [$canvas create polygon 0 0 0 0 0 0 -fill $bottomColor -tags slice($this)]
        set slice::($this,endBottomArc) [$canvas create arc 0 0 0 0 -style arc -extent 0 -fill black -tags slice($this)]

        set slice::($this,startLeftLine) [$canvas create line 0 0 0 0 -tags slice($this)]
        set slice::($this,startRightLine) [$canvas create line 0 0 0 0 -tags slice($this)]
        set slice::($this,endLeftLine) [$canvas create line 0 0 0 0 -tags slice($this)]
        set slice::($this,endRightLine) [$canvas create line 0 0 0 0 -tags slice($this)]
    }
    set slice::($this,topArc) [$canvas create arc\
        -$xRadius -$yRadius $xRadius $yRadius -fill $switched::($this,-topcolor) -tags slice($this)\
    ]
    # move slice so upper-left corner is at requested coordinates
    $canvas move slice($this) [expr {$x+$xRadius}] [expr {$y+$yRadius}]
}

proc slice::update {this} {
    set canvas $slice::($this,canvas)
    set coordinates [$canvas coords $slice::($this,origin)]            ;# first store slice position in case it was moved as a whole
    set xRadius $slice::($this,xRadius)
    set yRadius $slice::($this,yRadius)
    $canvas coords $slice::($this,origin) -$xRadius -$yRadius
    $canvas coords $slice::($this,topArc) -$xRadius -$yRadius $xRadius $yRadius
    $canvas itemconfigure $slice::($this,topArc) -start $slice::($this,start) -extent $slice::($this,extent)
    if {$switched::($this,-height)>0} {                                                                                        ;# 3D
        updateBottom $this
    }
    # now position slice at the correct coordinates
    $canvas move slice($this) [expr {[lindex $coordinates 0]+$xRadius}] [expr {[lindex $coordinates 1]+$yRadius}]
    eval $canvas scale slice($this) $coordinates $switched::($this,-scale)                                    ;# finally apply scale
}

proc slice::updateBottom {this} {
    variable PI

    set start $slice::($this,start)
    set extent $slice::($this,extent)

    set canvas $slice::($this,canvas)
    set xRadius $slice::($this,xRadius)
    set yRadius $slice::($this,yRadius)
    set height $switched::($this,-height)

    $canvas itemconfigure $slice::($this,startBottomArcFill) -extent 0                      ;# first make all bottom parts invisible
    $canvas coords $slice::($this,startBottomArcFill) -$xRadius -$yRadius $xRadius $yRadius
    $canvas move $slice::($this,startBottomArcFill) 0 $height
    $canvas itemconfigure $slice::($this,startBottomArc) -extent 0
    $canvas coords $slice::($this,startBottomArc) -$xRadius -$yRadius $xRadius $yRadius
    $canvas move $slice::($this,startBottomArc) 0 $height
    $canvas coords $slice::($this,startLeftLine) 0 0 0 0
    $canvas coords $slice::($this,startRightLine) 0 0 0 0
    $canvas itemconfigure $slice::($this,endBottomArcFill) -extent 0
    $canvas coords $slice::($this,endBottomArcFill) -$xRadius -$yRadius $xRadius $yRadius
    $canvas move $slice::($this,endBottomArcFill) 0 $height
    $canvas itemconfigure $slice::($this,endBottomArc) -extent 0
    $canvas coords $slice::($this,endBottomArc) -$xRadius -$yRadius $xRadius $yRadius
    $canvas move $slice::($this,endBottomArc) 0 $height
    $canvas coords $slice::($this,endLeftLine) 0 0 0 0
    $canvas coords $slice::($this,endRightLine) 0 0 0 0
    $canvas coords $slice::($this,startPolygon) 0 0 0 0 0 0 0 0
    $canvas coords $slice::($this,endPolygon) 0 0 0 0 0 0 0 0

    set startX [expr {$xRadius*cos($start*$PI/180)}]
    set startY [expr {-$yRadius*sin($start*$PI/180)}]
    set end [normalizedAngle [expr {$start+$extent}]]
    set endX [expr {$xRadius*cos($end*$PI/180)}]
    set endY [expr {-$yRadius*sin($end*$PI/180)}]

    set startBottom [expr {$startY+$height}]
    set endBottom [expr {$endY+$height}]

    if {(($start>=0)&&($end>=0))||(($start<0)&&($end<0))} {           ;# start and end angles are on the same side of the 0 abscissa
        if {$extent<=180} {                                                                      ;# slice size is less than half pie
            if {$start<0} {                                                          ;# slice is facing viewer, so bottom is visible
                $canvas itemconfigure $slice::($this,startBottomArcFill) -start $start -extent $extent
                $canvas itemconfigure $slice::($this,startBottomArc) -start $start -extent $extent
                # only one polygon is needed
                $canvas coords $slice::($this,startPolygon) $startX $startY $endX $endY $endX $endBottom $startX $startBottom
                $canvas coords $slice::($this,startLeftLine) $startX $startY $startX $startBottom
                $canvas coords $slice::($this,startRightLine) $endX $endY $endX $endBottom
            }                                                                                            ;# else only top is visible
        } else {                                                                                 ;# slice size is more than half pie
            if {$start<0} {                                               ;# slice opening is facing viewer, so bottom is in 2 parts
                $canvas itemconfigure $slice::($this,startBottomArcFill) -start 0 -extent $start
                $canvas itemconfigure $slice::($this,startBottomArc) -start 0 -extent $start
                $canvas coords $slice::($this,startPolygon) $startX $startY $xRadius 0 $xRadius $height $startX $startBottom
                $canvas coords $slice::($this,startLeftLine) $startX $startY $startX $startBottom
                $canvas coords $slice::($this,startRightLine) $xRadius 0 $xRadius $height

                set bottomArcExtent [expr {$end+180}]
                $canvas itemconfigure $slice::($this,endBottomArcFill) -start -180 -extent $bottomArcExtent
                $canvas itemconfigure $slice::($this,endBottomArc) -start -180 -extent $bottomArcExtent
                $canvas coords $slice::($this,endPolygon) -$xRadius 0 $endX $endY $endX $endBottom -$xRadius $height
                $canvas coords $slice::($this,endLeftLine) -$xRadius 0 -$xRadius $height
                $canvas coords $slice::($this,endRightLine) $endX $endY $endX $endBottom
            } else {                                                 ;# slice back is facing viewer, so bottom occupies half the pie
                $canvas itemconfigure $slice::($this,startBottomArcFill) -start 0 -extent -180
                $canvas itemconfigure $slice::($this,startBottomArc) -start 0 -extent -180
                # only one polygon is needed
                $canvas coords $slice::($this,startPolygon) -$xRadius 0 $xRadius 0 $xRadius $height -$xRadius $height
                $canvas coords $slice::($this,startLeftLine) -$xRadius 0 -$xRadius $height
                $canvas coords $slice::($this,startRightLine) $xRadius 0 $xRadius $height
            }
        }
    } else {                                                         ;# start and end angles are on opposite sides of the 0 abscissa
        if {$start<0} {                                                                              ;# slice start is facing viewer
            $canvas itemconfigure $slice::($this,startBottomArcFill) -start 0 -extent $start
            $canvas itemconfigure $slice::($this,startBottomArc) -start 0 -extent $start
            # only one polygon is needed
            $canvas coords $slice::($this,startPolygon) $startX $startY $xRadius 0 $xRadius $height $startX $startBottom
            $canvas coords $slice::($this,startLeftLine) $startX $startY $startX $startBottom
            $canvas coords $slice::($this,startRightLine) $xRadius 0 $xRadius $height
        } else {                                                                                       ;# slice end is facing viewer
            set bottomArcExtent [expr {$end+180}]
            $canvas itemconfigure $slice::($this,endBottomArcFill) -start -180 -extent $bottomArcExtent
            $canvas itemconfigure $slice::($this,endBottomArc) -start -180 -extent $bottomArcExtent
            # only one polygon is needed
            $canvas coords $slice::($this,endPolygon) -$xRadius 0 $endX $endY $endX $endBottom -$xRadius $height
            $canvas coords $slice::($this,startLeftLine) -$xRadius 0 -$xRadius $height
            $canvas coords $slice::($this,startRightLine) $endX $endY $endX $endBottom
        }
    }
}

proc slice::rotate {this angle} {
    if {$angle==0} return
    set slice::($this,start) [normalizedAngle [expr {$slice::($this,start)+$angle}]]
    update $this
}

proc slice::data {this arrayName} {                                               ;# return actual sizes and positions after scaling
    upvar $arrayName data

    set data(start) $slice::($this,start)
    set data(extent) $slice::($this,extent)
    foreach {x y} $switched::($this,-scale) {}
    set data(xRadius) [expr {$x*$slice::($this,xRadius)}]
    set data(yRadius) [expr {$y*$slice::($this,yRadius)}]
    set data(height) [expr {$y*$switched::($this,-height)}]
    foreach {x y} [$slice::($this,canvas) coords $slice::($this,origin)] {}
    set data(xCenter) [expr {$x+$data(xRadius)}]
    set data(yCenter) [expr {$y+$data(yRadius)}]
}
