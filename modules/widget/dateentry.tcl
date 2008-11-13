# -*- tcl -*-
#
# dateentry.tcl -
#
#       dateentry widget
#
# This widget provides an entry with a visual calendar for
# choosing a date. It is mostly a gathering compoments.
#
# The basics for the entry were taken from the "MenuEntry widget"
# of the widget package in the tklib.
# The visual calendar is taken from http://wiki.tcl.tk/1816.
#
# So many thanks to Richard Suchenwirth for visual calendar
# and to Jeff Hobbs for the widget package in tklib.
#
# See the example at the bottom.
#
# RCS: @(#) $Id: dateentry.tcl,v 1.2 2008/11/13 01:42:40 hobbs Exp $
#

# Creation and Options - widget::dateentry $path ...
# -command        -default {}
# -dateformat     -default "%m/%d/%Y"
# -font           -default {Helvetica 9}
# -titlefont      -default {Helvetica 12}
# -background     -default white
# -textvariable   -default {}  -configuremethod C-textvariable
# -startday       -default "monday" -configuremethod C-startofweek
# -highlightcolor -default "orange" -configuremethod C-highlightcolor
#
# Methods
#  $widget post   - display calendar dropdown
#  $widget unpost - remove calendar dropdown
#  All other methods to entry
#
# Bindings
#  NONE
#

###

package require widget
if {![package vsatisfies [package provide Tk] 8.5]} { package require tile }

namespace eval ::widget {
    # http://www.famfamfam.com/lab/icons/mini/
    # ?Mini? is a set of 144 GIF icons available for free use for any purpose.
    variable dateentry_gifdata {
	R0lGODlhEAAQAMQAANnq+K7T5HiUsMHb+v/vlOXs9IyzzHWs1/T5/1ZtjUlVa+z1/+3
	x9uTx/6a2ysng+FFhe0NLXIDG/fD4/ykxQz5FVf/41vr8/6TI3MvM0XHG/vbHQPn8//
	b8/4PL/f///yH5BAAAAAAALAAAAAAQABAAAAWV4Cdam2h+5AkExCYYsCC0iSAGTisAP
	JC7kNvicPBIjkeiIyHCMDzQaFRTYH4wBY6W0+kgvpNC8GNgXLhd8CQ8Lp8f3od8sSgo
	RIasHPGY0AcNdiIHBV0PfHQNgAURIgKFfBMPCw2KAIyOkH0LA509FY4TXn6UDT0MoB8
	JDwwFDK+wrxkUjgm2EBAKChERFRUUYyfCwyEAOw==
    }
    # http://www.famfamfam.com/lab/icons/silk/
    # ?Silk? is a smooth, free icon set,
    variable dateentry_gifdata {
	R0lGODlhEAAQAPZ8AP99O/9/PWmrYmytZW6uaHOxbP+EQv+LR/+QTf+UUv+VVP+WVP+
	YV/+ZWP+aWv+dXP+eXf+fX/+nVP+rWv+gYP+hYf+iYv+jZP+kZP+kZf+wYf+zaP+4bf
	+5cf+7df+9eUJ3u1KEw1SGxFWGxlaHx12KxVyKxl+MxlmKyFuKyV+NyF6Oy1+Py2OSz
	mSTzmiW0WqX0W6Z02+b1HKe1nSg13Wh13qj2nqk2X2l3H6o3ZHBjJvHlqXNoa/Sq4Cp
	3YOr3IKq34mu2Yyw24mw3pG03Za434Ss4Ieu4Yiv4oyx44+14Yyy5I+05ZC15pO355S
	355W445294Zq75p++5pa66Zi66Zq865u9652+656/7KG/55/A7aTB5KTB56vG5abD6a
	HB7qLB76rG6a7J6rLL6rfO6rrQ67zQ68PdwNfp1dji8Nvk8d7n8t7n8+Lq9Obt9urw9
	+vx9+3y+O7z+e/z+fD0+vH2+vL2+vT3+/n8+f7+/v7//v///wAAAAAAAAAAACH5BAEA
	AH0ALAAAAAAQABAAAAfMgH2Cg4SFg2FbWFZUTk1LSEY+ODaCYHiXmJmXNIJZeBkXFBA
	NCwgHBgF4MoJXeBgfHh0cGxoTEgB4MIJVnxcWFREPDgwKCXgugk94X3zNzs1ecSyCTH
	difD0FaT0DPXxcbCiCSXZjzQJpO3kFfFFqI4JHdWTnaTp8AnxFaiKCQHRl+KARwKMHA
	W9E1KgQlIOOGT569uyB2EyIGhOCbsw500XLFClQlAz5EUTNCUE15MB546bNGjUwY5YQ
	NCPGixYrUpAIwbMnCENACQUCADs=
    }
}

proc ::widget::createdateentryLayout {} {
    variable dateentry
    if {[info exists dateentry]} { return }
    set dateentry 1
    variable dateentry_pngdata
    variable dateentry_gifdata
    set img ::widget::img_dateentry
    image create photo $img -format GIF -data $dateentry_gifdata
    namespace eval ::ttk [list set dateimg $img] ; # namespace resolved
    namespace eval ::ttk {
	# Create -padding for space on left and right of icon
	set pad [expr {[image width $dateimg] + 6}]
	style theme settings "default" {
	    style layout dateentry {
		Entry.field -children {
		    dateentry.icon -side left
		    Entry.padding -children {
			Entry.textarea
		    }
		}
	    }
	    # center icon in padded cell
	    style element create dateentry.icon image $dateimg \
		-sticky "" -padding [list $pad 0 0 0]
	}
	if 0 {
	    # Some mappings would be required per-theme to adapt to theme
	    # changes
	    foreach theme [style theme names] {
		style theme settings $theme {
		    # Could have disabled, pressed, ... state images
		    #style map dateentry -image [list disabled $img]
		}
	    }
	}
    }
}

snit::widgetadaptor widget::dateentry {
    delegate option * to hull
    delegate method * to hull

    option -command -default {}
    option -dateformat -default "%m/%d/%Y"
    option -font -default {Helvetica 9}
    option -titlefont {Helvetica 12}
    option -background -default white
    option -textvariable -default {} -configuremethod C-textvariable
    option -startday -default "monday" -configuremethod C-startofweek
    option -highlightcolor -default "orange" -configuremethod C-highlightcolor

    component canvas

    variable calendar
    variable waitVar
    variable formattedDate
    variable rawDate
    variable startOnMonday 1

    constructor args {
	::widget::createdateentryLayout

	installhull using ttk::entry -style dateentry

	bindtags $win [linsert [bindtags $win] 1 TDateEntry]

	$self configurelist $args

	# Calendar dropdown - will be created on first use
	set calendar $win.__calendar

	set now [clock seconds]
	set x [clock format $now -format "%d/%m%/%Y"]
	set rawDate [clock scan "$x 00:00:00" -format "%d/%m%/%Y %H:%M:%S"]
	set formattedDate [clock format $rawDate -format $options(-dateformat)]

	$hull configure -state normal
	$hull delete 0 end
	$hull insert end $formattedDate
	$hull configure -state readonly
    }

    method MakeCalendar {args} {
	destroy $calendar
	toplevel $calendar -takefocus 0 -class Calendar
	wm withdraw $calendar

	if {[tk windowingsystem] ne "aqua"} {
	    wm overrideredirect $calendar 1
	} else {
	    tk::unsupported::MacWindowStyle style $calendar \
		help {noActivates hideOnSuspend}
	}
	wm transient	    $calendar [winfo toplevel $win]
	wm group	    $calendar [winfo parent $win]
	wm resizable	    $calendar 0 0

	bind $calendar <Escape> [list $win unpost]

	set f [frame $calendar.fcal -background #666666 \
		   -borderwidth 1 -relief flat]
	set canvas $f.cal

	__Xdate__::chooser $canvas -command [mymethod DateChosen] \
	    -textvariable [myvar formattedDate] \
	    -clockformat $options(-dateformat) \
	    -highlight $options(-highlightcolor) \
	    -font $options(-font) \
	    -titlefont $options(-titlefont) \
	    -mon $startOnMonday

	pack $canvas -expand 1 -fill both
	pack $f -expand 1 -fill both

	#bind $canvas <FocusOut> "puts out"
	#bind $canvas <FocusIn> "puts in"
    }

    method post { args } {
	# XXX should we reset date on each display?
	if {![winfo exists $calendar]} { $self MakeCalendar }
	set waitVar 0

	foreach {x y} [$self PostPosition] { break }
	wm geometry $calendar "+$x+$y"
	wm deiconify $calendar
	raise $calendar

	if {[tk windowingsystem] ne "aqua"} {
	    tkwait visibility $calendar
	}

	ttk::globalGrab $calendar
	focus -force $canvas
	return

	tkwait variable [myvar waitVar]

	$self unpost
    }

    method unpost { args } {
	ttk::releaseGrab $calendar
	wm withdraw $calendar
    }

    method PostPosition {} {
	# PostPosition --
	#	Returns the x and y coordinates where the menu
	#	should be posted, based on the dateentry and menu size
	#	and -direction option.
	#
	# TODO: adjust menu width to be at least as wide as the button
	#	for -direction above, below.
	#
	set x [winfo rootx $win]
	set y [winfo rooty $win]
	set dir "below" ; #[$win cget -direction]

	set bw [winfo width $win]
	set bh [winfo height $win]
	set mw [winfo reqwidth $calendar]
	set mh [winfo reqheight $calendar]
	set sw [expr {[winfo screenwidth  $calendar] - $bw - $mw}]
	set sh [expr {[winfo screenheight $calendar] - $bh - $mh}]

	switch -- $dir {
	    above { if {$y >= $mh} { incr y -$mh } { incr y  $bh } }
	    below { if {$y <= $sh} { incr y  $bh } { incr y -$mh } }
	    left  { if {$x >= $mw} { incr x -$mw } { incr x  $bw } }
	    right { if {$x <= $sw} { incr x  $bw } { incr x -$mw } }
	}

	return [list $x $y]
    }

    method DateChosen { args } {
	upvar $options(-textvariable) date

	set waitVar 1
	set date $formattedDate
	set rawDate [clock scan $formattedDate -format $options(-dateformat)]
	if { $options(-command) ne "" } {
	    uplevel \#0 $options(-command) $formattedDate $rawDate
	}
	$self unpost

	$hull configure -state normal
	$hull delete 0 end
	$hull insert end $formattedDate
	$hull configure -state readonly
    }

    method C-textvariable { key value args } {
	set options($key) $value
    }

    method C-highlightcolor { key value args } {
	set options($key) $value
    }

    method C-startofweek { key value args } {
	switch -nocase -- $value {
	    "sunday" {
		set startOnMonday 0
	    }
	    "monday" {
		set startOnMonday 1
	    }
	    default {
		error "Invalid day for start of week. Must be either Monday or Sunday"
	    }
	}
	set options($key) $value
    }
}

# Bindings for menu portion.
#
# This is a variant of the ttk menubutton.tcl bindings.
# See menubutton.tcl for detailed behavior info.
#

bind TDateEntry <Enter>     { %W state active }
bind TDateEntry <Leave>     { %W state !active }
bind TDateEntry <<Invoke>>  { %W post }
bind TDateEntry <Control-space> { %W post }
bind TDateEntry <Escape>        { %W unpost }

bind TDateEntry <ButtonPress-1> { %W state pressed ; %W post }
bind TDateEntry <ButtonRelease-1> { %W state !pressed }

namespace eval __Xdate__ {

    proc chooser {w args} {
	variable $w
	variable defaults
	array set $w [array get defaults]
	upvar 0 $w a

	set now [clock scan today]
	set x [clock format $now -format "%d/%m%/%Y"]
	set now [clock scan "$x 00:00:00" -format "%d/%m%/%Y %H:%M:%S"]

	set a(year) [clock format $now -format "%Y"]
	scan [clock format $now -format "%m"] %d a(month)
	scan [clock format $now -format "%d"] %d a(day)

	array set a $args

	set tmp [set $a(-textvariable)]
	if {($a(-textvariable) ne {}) && ($tmp ne {}) } {
	    set date [clock scan $tmp -format $a(-clockformat)]

	    set a(selday)   [clock format $date -format %d]
	    set a(selmonth) [clock format $date -format %m]
	    set a(selyear)  [clock format $date -format %Y]
	}

	# The -mon switch gives the position of Monday (1 or 0)
	array set a $args
	set a(canvas) [canvas $w -highlightthickness 0 -borderwidth 0 \
			   -background $a(-bg) -width 210 -height 200]
	$w bind day <1> {
	    set item [%W find withtag current]
	    set __Xdate__::%W(day) [%W itemcget $item -text]
	    __Xdate__::display %W
	    __Xdate__::HandleCallback %W
	}

	set csep 3
	cbutton $w [expr {60 - $csep}]	10 << {__Xdate__::adjust %W  0 -1}
	cbutton $w 80  10 <  {__Xdate__::adjust %W -1  0}

	cbutton $w 120 10 >  {__Xdate__::adjust %W  1  0}
	cbutton $w [expr {140 + $csep}] 10 >> {__Xdate__::adjust %W  0	1}
	display $w
	set w
    }
    proc adjust {w dmonth dyear} {
	variable $w
	upvar 0 $w a

	incr a(year)  $dyear
	incr a(month) $dmonth

	if {$a(month) > 12} {
	    set a(month) 1
	    incr a(year)
	}

	if {$a(month) < 1}  {
	    set a(month) 12
	    incr a(year) -1
	}
	set maxday [numberofdays $a(month) $a(year)]
	if {$maxday < $a(day)} {set a(day) $maxday}
	display $w
    }
    proc display {w} {
	variable $w
	upvar 0 $w a

	set c $a(canvas)
	foreach tag {title otherday day} {
	    $c delete $tag
	}
	set x0 40; set x $x0; set y 50
	set dx 25; set dy 20
	set xmax [expr {$x0+$dx*6}]

	$c create rect 0 [expr {$y -10}]  [expr {$xmax + $dx -2}] [expr {$y + 10}] \
	    -fill #777777 -outline #777777
	set maxh [$c cget -height]
	$c create rect 0 [expr {$y -10}]  25 $maxh \
	    -fill #777777 -outline #777777

	set a(date) [clock scan $a(month)/$a(day)/$a(year)]
	set title [formatMY $w [monthname $w $a(month)] $a(year)]
	$c create text [expr {($xmax+$dx)/2}] 30 -text $title -fill blue \
	    -font $a(-titlefont) -tag title
	set weekdays $a(weekdays,$a(-language))
	if {!$a(-mon)} { lcycle weekdays }
	foreach i $weekdays {
	    $c create text $x $y -text $i -fill white \
		-font $a(-font) -tag title
	    incr x $dx
	}
	set first $a(month)/1/$a(year)
	set weekday [clock format [clock scan $first] -format %w]
	if {!$a(-mon)} {
	    set weekday [expr {($weekday+6)%7}]
	}
	set x [expr {$x0+$weekday*$dx}]
	set x1 $x; set offset 0
	incr y $dy
	while {$weekday} {
	    set t [clock scan "$first [incr offset] days ago"]
	    scan [clock format $t -format "%d"] %d day
	    $c create text [incr x1 -$dx] $y -text $day \
		-fill grey -font $a(-font) -tag otherday
	    incr weekday -1
	}
	set dmax [numberofdays $a(month) $a(year)]

	for {set d 1} {$d<=$dmax} {incr d} {
	    if {($a(-showpast) == 0)
		&& ($d < $a(selday))
		&& ($a(month) <= $a(selmonth)) && ($a(year) <= $a(selyear)) } {
		set id [$c create text $x $y -text $d -fill grey -tag otherday -font $a(-font)]
	    } else {
		set id [$c create text $x $y -text $d -tag day -font $a(-font)]
	    }
	    if {$d==$a(selday) && ($a(month) == $a(selmonth))} {
		$c create rect [$c bbox $id] \
		    -fill $a(-highlight) -outline $a(-highlight) -tag day
	    }
	    $c raise $id
	    if {[incr x $dx]>$xmax} {
		set x $x0
		set _date [clock scan $a(month)/$d/$a(year)]
		set week [clock format $_date -format %V]
		$c create text [expr {$x0 -25}] $y -text $week -fill white \
		    -font $a(-font) -tag week
		incr y $dy
	    }
	}
	set _date [clock scan $a(month)/$d/$a(year)]
	set week [clock format $_date -format %V]
	$c create text [expr {$x0 -25}] $y -text $week -fill white \
	    -font $a(-font) -tag week
	if {$x != $x0} {
	    for {set d 1} {$x<=$xmax} {incr d; incr x $dx} {
		$c create text $x $y -text $d \
		    -fill grey -font $a(-font) -tag otherday
	    }
	}

	set now [clock seconds]
	set today "Today is [clock format $now -format $a(-clockformat)]"
	$c create text 114 190 -text $today -fill black \
	    -tag week -font $a(-font)

	if { $a(-textvariable) ne {} } {
	    set $a(-textvariable) [clock format $a(date) -format $a(-clockformat)]
	}
    }

    proc HandleCallback {w} {
	variable $w
	upvar 0 $w a
	upvar 0 $a(-textvariable) date
	if { $a(-textvariable) ne {} } {
	    set date [clock format $a(date) -format $a(-clockformat)]
	    set $a(-textvariable) $date
	    set tmp [set $a(-textvariable)]
	}

	if { $a(-command) ne {} } {
	    uplevel \#0 $a(-command)
	}
    }

    proc formatMY {w month year} {
	variable $w
	upvar 0 $w a

	if ![info exists a(format,$a(-language))] {
	    set format "%m %y" ;# default
	} else {set format $a(format,$a(-language))}
	foreach {from to} [list %m $month %y $year] {
	    regsub $from $format $to format
	}
	subst $format
    }
    proc monthname {w month {language default}} {
	variable $w
	upvar 0 $w a

	if {$language=="default"} {set language $a(-language)}
	if {[info exists a(mn,$language)]} {
	    set res [lindex $a(mn,$language) $month]
	} else {set res $month}
    }

    variable defaults
    array set defaults {
	-font {Helvetica 9}
	-titlefont {Helvetica 12}
	-bg white
	-highlight orange
	-mon 1
	-langauge en
	-textvariable {}
	-command {}
	-clockformat "%m/%d/%Y"
	-showpast 1

	-language en
	mn,crk {
	    . Kis\u01E3p\u012Bsim Mikisiwip\u012Bsim Niskip\u012Bsim Ay\u012Bkip\u012Bsim
	    S\u0101kipak\u0101wip\u012Bsim
	    P\u0101sk\u0101wihowip\u012Bsim Paskowip\u012Bsim Ohpahowip\u012Bsim
	    N\u014Dcihitowip\u012Bsim Pin\u0101skowip\u012Bsim Ihkopiwip\u012Bsim
	    Paw\u0101cakinas\u012Bsip\u012Bsim
	}
	weekdays,crk {P\u01E3 N\u01E3s Nis N\u01E3 Niy Nik Ay}

	mn,crx-nak {
	    . {Sacho Ooza'} {Chuzsul Ooza'} {Chuzcho Ooza'} {Shin Ooza'} {Dugoos Ooza'} {Dang Ooza'}\
		{Talo Ooza'} {Gesul Ooza'} {Bit Ooza'} {Lhoh Ooza'} {Banghan Nuts'ukih} {Sacho Din'ai}
	}
	weekdays,crx-nak {Ji Jh WN WT WD Ts Sa}

	mn,crx-lhe {
	    . {'Elhdzichonun} {Yussulnun} {Datsannadulhnun} {Dulats'eknun} {Dugoosnun} {Daingnun}\
		{Gesnun} {Nadlehcho} {Nadlehyaz} {Lhewhnandelnun} {Benats'ukuihnun} {'Elhdziyaznun}
	}
	weekdays,crx-lhe {Ji Jh WN WT WD Ts Sa}

	mn,de {
	    . Januar Februar März April Mai Juni Juli August
	    September Oktober November Dezember
	}
	weekdays,de {So Mo Di Mi Do Fr Sa}

	mn,en {
	    . January February March April May June July August
	    September October November December
	}
	weekdays,en {Su Mo Tu We Th Fr Sa}

	mn,es {
	    . Enero Febrero Marzo Abril Mayo Junio Julio Agosto
	    Septiembre Octubre Noviembre Diciembre
	}
	weekdays,es {Do Lu Ma Mi Ju Vi Sa}

	mn,fr {
	    . Janvier Février Mars Avril Mai Juin Juillet Août
	    Septembre Octobre Novembre Décembre
	}
	weekdays,fr {Di Lu Ma Me Je Ve Sa}

	mn,gr {
	    . Îýý???Ïýý?Ïýý??Ïýý ???Ïýý?Ïýý?Ïýý??Ïýý Îýý?ÏýýÏýý??Ïýý ÎýýÏýýÏýý????Ïýý Îýý?Îýý?Ïýý Îýý?Ïýý???Ïýý Îýý?Ïýý???Ïýý ÎýýÏýý??ÏýýÏýýÏýý?Ïýý
	    ??ÏýýÏýýÎýý??Ïýý??Ïýý Îýý?ÏýýÏýý??Ïýý??Ïýý Îýý?Îýý??Ïýý??Ïýý Îýý??Îýý??Ïýý??Ïýý
	}
	weekdays,gr {ÎýýÏýýÏýý Îýý?Ïýý TÏýý? ??Ïýý Î ?? Î ?Ïýý ???}

	mn,he {
	    . ×ýý× ×ýý×ýý? ?×ýý?×ýý×ýý? ×ýý?? ×ýý??×ýý×ýý ×ýý×ýý×ýý ×ýý×ýý× ×ýý ×ýý×ýý×ýý×ýý ×ýý×ýý×ýý×ýý?×ýý ??×ýý×ýý×ýý? ×ýý×ýý?×ýý×ýý×ýý? × ×ýý×ýý×ýý×ýý? ×ýý?×ýý×ýý?
	}
	weekdays,he {?×ýý?×ýý×ýý ?× ×ýý ?×ýý×ýý?×ýý ?×ýý×ýý?×ýý ×ýý×ýý×ýý?×ýý ?×ýý?×ýý ?×ýý?}
	mn,it {
	    . Gennaio Febraio Marte Aprile Maggio Giugno Luglio Agosto
	    Settembre Ottobre Novembre Dicembre
	}
	weekdays,it {Do Lu Ma Me Gi Ve Sa}

	format,ja {%y\u5e74 %m\u6708}
	weekdays,ja {\u65e5 \u6708 \u706b \u6c34 \u6728 \u91d1 \u571f}

	mn,nl {
	    . januari februari maart april mei juni juli augustus
	    september oktober november december
	}
	weekdays,nl {Zo Ma Di Wo Do Vr Za}

	mn,ru {
	    . \u042F\u043D\u0432\u0430\u0440\u044C
	    \u0424\u0435\u0432\u0440\u0430\u043B\u044C \u041C\u0430\u0440\u0442
	    \u0410\u043F\u0440\u0435\u043B\u044C \u041C\u0430\u0439
	    \u0418\u044E\u043D\u044C \u0418\u044E\u043B\u044C
	    \u0410\u0432\u0433\u0443\u0441\u0442
	    \u0421\u0435\u043D\u0442\u044F\u0431\u0440\u044C
	    \u041E\u043A\u0442\u044F\u0431\u0440\u044C \u041D\u043E\u044F\u0431\u0440\u044C
	    \u0414\u0435\u043A\u0430\u0431\u0440\u044C
	}
	weekdays,ru {
	    \u432\u43e\u441 \u43f\u43e\u43d \u432\u442\u43e \u441\u440\u435
	    \u447\u435\u442 \u43f\u44f\u442 \u441\u443\u431
	}

	mn,sv {
	    . januari februari mars april maj juni juli augusti
	    september oktober november december
	}
	weekdays,sv {s\u00F6n m\u00E5n tis ons tor fre l\u00F6r}

	mn,pt {
	    . Janeiro Fevereiro Mar\u00E7o Abril Maio Junho
	    Julho Agosto Setembro Outubro Novembro Dezembro
	}
	weekdays,pt {Dom Seg Ter Qua Qui Sex Sab}

	format,zh {%y\u5e74 %m\u6708}
	mn,zh {
	    . \u4e00 \u4e8c \u4e09 \u56db \u4e94 \u516d \u4e03
	    \u516b \u4e5d \u5341 \u5341\u4e00 \u5341\u4e8c
	}
	weekdays,zh {\u65e5 \u4e00 \u4e8c \u4e09 \u56db \u4e94 \u516d}
	mn,fi {
	    . Tammikuu Helmikuu Maaliskuu Huhtikuu Toukokuu Kesäkuu
	    Heinäkuu Elokuu Syyskuu Lokakuu Marraskuu Joulukuu
	}
	weekdays,fi {Ma Ti Ke To Pe La Su}
	mn,tr {
	    . ocak \u015fubat mart nisan may\u0131s haziran temmuz a\u011fustos eyl\u00FCl ekim kas\u0131m aral\u0131k
	}
	weekdays,tr {pa'tesi sa \u00e7a pe cu cu'tesi pa}
    }
    proc numberofdays {month year} {
	if {$month==12} {set month 0; incr year}
	clock format [clock scan "[incr month]/1/$year	1 day ago"] \
	    -format %d
    }

    proc lcycle _list {
	upvar $_list list
	set list [concat [lrange $list 1 end] [list [lindex $list 0]]]
    }
    proc cbutton {w x y text command} {
	set txt [$w create text $x $y -text " $text "]
	set btn [$w create rect [$w bbox $txt] -fill grey -outline grey]
	$w raise $txt
	foreach i [list $txt $btn] {$w bind $i <1> $command}
    }
} ;# end namespace __Xdate__

package provide widget::dateentry 0.9

##############
# TEST CODE ##
##############

if { [info script] eq $argv0 } {

    proc getDate { args } {
	puts [info level 0]
	puts "DATE $::DATE"

	update
    }

    proc dateTrace { args } {
	puts [info level 0]
    }

    # Samples
    # package require widget::dateentry
    set ::DATE ""
    set start [widget::dateentry .s -textvariable ::DATE \
		   -dateformat "%d.%m.%Y %H:%M" \
		   -command [list getDate .s]]
    set end [widget::dateentry .e \
		 -command [list getDate .e] \
		 -highlightcolor dimgrey \
		 -font {Courier 10} \
		 -titlefont {Utopia 10} \
		 -startday sunday]
    grid [label .sl -text "Start:"] $start  -padx 4 -pady 4
    grid [label .el -text "End:"  ] $end    -padx 4 -pady 4

    trace add variable ::DATE write dateTrace
    set ::DATE 1

    puts [$end get]
}
