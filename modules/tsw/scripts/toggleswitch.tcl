#==============================================================================
# Contains the implementation of the toggleswitch widget.
#
# Structure of the module:
#   - Namespace initialization
#   - Private procedure creating the default bindings
#   - Public procedure creating a new toggleswitch widget
#   - Private configuration procedures
#   - Private procedure implementing the toggleswitch widget command
#   - Private procedures used in bindings
#
# Copyright (c) 2025  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Namespace initialization
# ========================
#

namespace eval tsw {
    variable theme [ttk::style theme use]

    #
    # The array configSpecs is used to handle configuration options.  The names
    # of its elements are the configuration options for the Toggleswitch class.
    # The value of an array element is either an alias name or a list
    # containing the database name and class as well as an indicator specifying
    # the widget to which the option applies: f stands for the frame and w for
    # the toggleswitch widget itself.
    #
    #   Command-Line Name	{Database Name	Database Class	W}
    #   ----------------------------------------------------------
    #
    variable configSpecs
    array set configSpecs {
	-command		{command	Command		w}
	-cursor			{cursor		Cursor		f}
	-offvalue		{offValue	OffValue	w}
	-onvalue		{onValue	OnValue		w}
	-size			{size		Size		w}
	-takefocus		{takeFocus	TakeFocus	f}
	-variable		{variable	Variable	w}
    }

    #
    # Extend the elements of the array configSpecs
    #
    lappend configSpecs(-command)	""
    lappend configSpecs(-cursor)	""
    lappend configSpecs(-offvalue)	0
    lappend configSpecs(-onvalue)	1
    lappend configSpecs(-size)		2
    lappend configSpecs(-takefocus)	"ttk::takefocus"
    lappend configSpecs(-variable)	""

    variable configOpts [lsort [array names configSpecs]]

    #
    # Use a list to facilitate the handling of command options
    #
    variable cmdOpts [list attrib cget configure hasattrib identify instate \
		      state style switchstate toggle unsetattrib]

    #
    # Array variable used in binding scripts for the widget class TswScale
    #
    variable stateArr
    set stateArr(dragging) 0

    variable scaled4
    if {[llength [info procs ::tk::ScaleNum]] == 0} {
	#
	# Make sure that the variable ::scaleutil::scalingPct is set
	#
	scaleutil::scalingPercentage [tk windowingsystem]
	set scaled4 [scaleutil::scale 4 $::scaleutil::scalingPct]
    } else {						;# Tk 8.7b1/9 or later
	set scaled4 [tk::ScaleNum 4]
    }

    variable onAndroid [expr {[info exists ::tk::android] && $::tk::android}]

    #
    # Make the layouts
    #
    proc condMakeLayouts {} {
	variable theme
	set themeMod $theme
	set mod ""

	if {$theme eq "default"} {
	    set fg [ttk::style lookup . -foreground]
	    if {[mwutil::isColorLight $fg]} {
		set themeMod default-dark
		set mod "Dark"
	    }
	}

	variable elemInfoArr
	if {[info exists elemInfoArr($themeMod)]} {
	    if {$theme eq "aqua"} {
		updateElements_$theme
	    }

	    return ""
	}

	switch $themeMod {
	    default - default-dark - clam - droid - plastik - awarc -
	    awbreeze - awbreezedark - awlight - awdark - vista - aqua {
		createElements_$themeMod
	    }
	    winnative - xpnative {
		ttk::style theme settings vista { createElements_vista }
		foreach n {1 2 3} {
		    ttk::style element create Switch$n.trough from vista
		    ttk::style element create Switch$n.slider from vista
		}
	    }
	    default {
		set fg [ttk::style lookup . -foreground {} black]
		if {[mwutil::isColorLight $fg] ||
		    [string match -nocase *dark* $theme]} {
		    set createCmd createElements_default-dark
		    set mod "Dark"
		} else {
		    set createCmd createElements_default
		}

		ttk::style theme settings default { $createCmd }
		foreach n {1 2 3} {
		    ttk::style element create ${mod}Switch$n.trough from default
		    ttk::style element create ${mod}Switch$n.slider from default
		}
	    }
	}
	set elemInfoArr($themeMod) 1

	if {$theme eq "aqua"} {
	    foreach n {1 2 3} {
		ttk::style layout Toggleswitch$n [list \
		    Switch.padding -sticky nswe -children [list \
			Switch$n.trough -sticky {} -children [list \
			    Switch$n.slider -side left -sticky {} \
			]
		    ]
		]

		ttk::style configure Toggleswitch$n -padding 1.5p
	    }
	} else {
	    foreach n {1 2 3} {
		ttk::style layout Toggleswitch$n [list \
		    Switch.focus -sticky nswe -children [list \
			Switch.padding -sticky nswe -children [list \
			    ${mod}Switch$n.trough -sticky {} -children [list \
				${mod}Switch$n.slider -side left -sticky {}
			    ]
			]
		    ]
		]

		ttk::style configure Toggleswitch$n -padding 0.75p
		if {$theme eq "classic"} {
		    ttk::style configure Toggleswitch$n -focussolid 1
		}
	    }
	}
    }
    condMakeLayouts
}

#
# Private procedure creating the default bindings
# ===============================================
#

#------------------------------------------------------------------------------
# tsw::createBindings
#
# Creates the default bindings for the binding tags Toggleswitch, TswMain,
# ToggleswitchKeyNav, and TswScale.
#------------------------------------------------------------------------------
proc tsw::createBindings {} {
    bind Toggleswitch <KeyPress> continue
    bind Toggleswitch <FocusIn> {
	if {[focus -lastfor %W] eq "%W"} {
	    focus %W.scl
	}
    }
    bind Toggleswitch <Destroy>		{ tsw::onDestroy %W }
    bind Toggleswitch <<ThemeChanged>>	{ tsw::onThemeChanged %W }

    bindtags . [linsert [bindtags .] 1 TswMain]
    foreach event {<<ThemeChanged>> <<LightAqua>> <<DarkAqua>>} {
	bind TswMain $event { tsw::onThemeChanged %W }
    }

    #
    # Define the binding tag ToggleswitchKeyNav
    #
    mwutil::defineKeyNav Toggleswitch

    variable onAndroid
    if {!$onAndroid} {
	bind TswScale <Enter>	    { %W instate !disabled {%W state active} }
	bind TswScale <Leave>	    { %W state !active }
    }
    bind TswScale <B1-Leave>	    { # Preserves the "active" state. }
    bind TswScale <Button-1>	    { tsw::onButton1	%W %x %y }
    bind TswScale <B1-Motion>	    { tsw::onB1Motion	%W %x %y }
    bind TswScale <ButtonRelease-1> { tsw::onButtonRel1	%W }
    bind TswScale <space>	    { tsw::onSpace	%W }
}

#
# Public procedure creating a new toggleswitch widget
# ===================================================
#

#------------------------------------------------------------------------------
# tsw::toggleswitch
#
# Creates a new toggleswitch widget whose name is specified as the first
# command-line argument, and configures it according to the options and their
# values given on the command line.  Returns the name of the newly created
# widget.
#------------------------------------------------------------------------------
proc tsw::toggleswitch args {
    variable configSpecs
    variable configOpts

    if {[llength $args] == 0} {
	mwutil::wrongNumArgs "tsw::toggleswitch pathName ?options?"
    }

    #
    # Create a ttk::frame of the class Toggleswitch
    #
    set win [lindex $args 0]
    if {[catch {
	ttk::frame $win -class Toggleswitch -borderwidth 0 -relief flat \
			-height 0 -width 0 -padding 0
    } result] != 0} {
	return -code error $result
    }

    #
    # Create a namespace within the current one to hold the data of the widget
    #
    namespace eval ns$win {
	#
	# The following array holds various data for this widget
	#
	variable data
	set data(moveState) idle		;# other values: moving, moved

	#
	# The following array is used to hold arbitrary
	# attributes and their values for this widget
	#
	variable attribs
    }

    #
    # Initialize some further components of data
    #
    upvar ::tsw::ns${win}::data data
    foreach opt $configOpts {
	set data($opt) [lindex $configSpecs($opt) 3]
    }
    set data(varTraceCmd) [list tsw::varTrace $win]

    #
    # Create a ttk::scale child widget of a special style
    #
    set size [lindex $configSpecs(-size) end]
    set scl [ttk::scale $win.scl -class TswScale -style Toggleswitch$size \
	     -takefocus 0 -length 0 -from 0 -to 20]
    pack $scl -expand 1 -fill both
    bindtags $scl [linsert [bindtags $scl] 3 ToggleswitchKeyNav]

    #
    # Configure the widget according to the command-line
    # arguments and to the available database options
    #
    upvar #0 $win var
    if {![array exists var]} {
	set args [linsert $args 1 -variable $win]
    }
    if {[catch {
	mwutil::configureWidget $win configSpecs tsw::doConfig tsw::doCget \
	    [lrange $args 1 end] 1
    } result] != 0} {
	destroy $win
	return -code error $result
    }

    #
    # Move the original widget command into the current namespace
    # and build a new widget procedure in the global one
    #
    rename ::$win $win
    interp alias {} ::$win {} tsw::toggleswitchWidgetCmd $win

    return $win
}

#
# Private configuration procedures
# ================================
#

#------------------------------------------------------------------------------
# tsw::doConfig
#
# Applies the value val of the configuration option opt to the toggleswitch
# widget win.
#------------------------------------------------------------------------------
proc tsw::doConfig {win opt val} {
    variable configSpecs
    upvar ::tsw::ns${win}::data data

    #
    # Apply the value to the widget corresponding to the given option
    #
    switch [lindex $configSpecs($opt) 2] {
	f {
	    #
	    # Apply the value to the frame and save the
	    # properly formatted value of val in data($opt)
	    #
	    $win configure $opt $val
	    set data($opt) [$win cget $opt]

	    switch -- $opt {
		-cursor { $win.scl configure $opt $val }
	    }
	}

	w {
	    switch -- $opt {
		-command { set data($opt) $val }

		-offvalue -
		-onvalue {
		    if {[array exists $val]} {
			return -code error "value \"$val\" is array"
		    }

		    if {$data(-variable) ne ""} {
			#
			# Conditionally update the variable
			#
			set selected [$win.scl instate selected]
			if {($opt eq "-offvalue" && !$selected) ||
			    ($opt eq "-onvalue" && $selected)} {
			    upvar #0 $data(-variable) var
			    trace remove variable var {write unset} \
				$data(varTraceCmd)
			    set var $val
			    trace add variable var {write unset} \
				$data(varTraceCmd)
			}
		    }

		    set data($opt) $val
		}

		-size {
		    set val [mwutil::fullOpt "size" $val {1 2 3}]
		    $win.scl configure -style Toggleswitch$val

		    set data($opt) $val
		}

		-variable {
		    makeVariable $win $val
		    set data($opt) $val
		}
	    }
	}
    }
}

#------------------------------------------------------------------------------
# tsw::makeVariable
#
# Arranges for the global variable specified by varName to become the variable
# associated with the toggleswitch widget win.
#------------------------------------------------------------------------------
proc tsw::makeVariable {win varName} {
    upvar ::tsw::ns${win}::data data
    if {$varName eq ""} {
	#
	# If there is an old variable associated with the
	# widget then remove the trace set on this variable
	#
	if {$data(-variable) ne "" &&
	    [catch {upvar #0 $data(-variable) oldVar}] == 0} {
	    trace remove variable oldVar {write unset} $data(varTraceCmd)
	}
	return ""
    }

    #
    # The variable may be an array element but must not be an array
    #
    upvar #0 $varName var
    if {![regexp {^(.*)\((.*)\)$} $varName dummy name1 name2]} {
	if {[array exists var]} {
	    return -code error "variable \"$varName\" is array"
	}

	set name1 $varName
	set name2 ""
    }

    #
    # If there is an old variable associated with the
    # widget then remove the trace set on this variable
    #
    if {$data(-variable) ne "" &&
	[catch {upvar #0 $data(-variable) oldVar}] == 0} {
	trace remove variable oldVar {write unset} $data(varTraceCmd)
    }

    if {[info exists var]} {
	#
	# Invoke the trace procedure associated with the new variable
	#
	varTrace $win $name1 $name2 write
    } else {
	#
	# Set $varName according to the widget's switch state
	#
	set selected [$win.scl instate selected]
	set var [expr {$selected ? $data(-onvalue) : $data(-offvalue)}]
    }

    #
    # Set a trace on the new variable
    #
    trace add variable var {write unset} $data(varTraceCmd)
}

#------------------------------------------------------------------------------
# tsw::varTrace
#
# This procedure is executed whenever the global variable specified by varName
# and arrIndex is written or unset.  It makes sure that the widget's switch
# state is synchronized with the value of the variable, and that the variable
# is recreated if it was unset.
#------------------------------------------------------------------------------
proc tsw::varTrace {win varName arrIndex op} {
    if {$arrIndex ne ""} {
	set varName ${varName}($arrIndex)
    }
    upvar #0 $varName var

    set scl $win.scl
    upvar ::tsw::ns${win}::data data
    switch $op {
	write {
	    #
	    # Synchronize the widget's switch state with the variable's value
	    #
	    set stateSpec [$scl state !disabled]	;# needed for $scl set
	    if {$var eq $data(-onvalue)} {
		$scl state selected
		$scl set [$scl cget -to]
	    } else {
		$scl state !selected
		$scl set [$scl cget -from]
	    }
	    $scl state $stateSpec
	}

	unset {
	    #
	    # Recreate the variable $varName by setting it according to
	    # the widget's switch state, and set the trace on it again
	    #
	    set selected [$scl instate selected]
	    set var [expr {$selected ? $data(-onvalue) : $data(-offvalue)}]
	    trace add variable var {write unset} $data(varTraceCmd)
	}
    }
}

#------------------------------------------------------------------------------
# tsw::doCget
#
# Returns the value of the configuration option opt for the toggleswitch
# widget win.
#------------------------------------------------------------------------------
proc tsw::doCget {win opt} {
    upvar ::tsw::ns${win}::data data
    return $data($opt)
}

#
# Private procedure implementing the toggleswitch widget command
# ==============================================================
#

#------------------------------------------------------------------------------
# tsw::toggleswitchWidgetCmd
#
# Processes the Tcl command corresponding to a toggleswitch widget.
#------------------------------------------------------------------------------
proc tsw::toggleswitchWidgetCmd {win args} {
    set argCount [llength $args]
    if {$argCount == 0} {
        mwutil::wrongNumArgs "$win option ?arg arg ...?"
    }

    variable cmdOpts
    set cmd [mwutil::fullOpt "command" [lindex $args 0] $cmdOpts]
    set argList [lrange $args 1 end]
    set scl $win.scl

    switch $cmd {
	attrib {
	    return [mwutil::attribSubCmdEx "tsw" $win "widget" $argList]
	}

	cget {
	    if {$argCount != 2} {
		mwutil::wrongNumArgs "$win $cmd option"
	    }

	    #
	    # Return the value of the specified configuration option
	    #
	    variable configSpecs
	    set opt [mwutil::fullConfigOpt [lindex $args 1] configSpecs]
	    upvar ::tsw::ns${win}::data data
	    return $data($opt)
	}

	configure {
	    variable configSpecs
	    return [mwutil::configureSubCmd $win configSpecs \
		    tsw::doConfig tsw::doCget $argList]
	}

	hasattrib -
	unsetattrib {
	    if {$argCount != 2} {
		mwutil::wrongNumArgs "$win $cmd name"
	    }

	    return [mwutil::${cmd}SubCmdEx "tsw" $win "widget" [lindex $args 1]]
	}

	identify -
	state {
	    if {[catch {$scl $cmd {*}$argList} result] != 0} {
		return -code error [string map [list $scl $win] $result]
	    }

	    return $result
	}

	instate {
	    if {$argCount < 2 || $argCount > 3} {
		mwutil::wrongNumArgs "$win $cmd stateSpec ?script?"
	    }

	    set stateSpec [lindex $args 1]
	    if {$argCount == 2} {
		return [$scl instate $stateSpec]
	    } elseif {[$scl instate $stateSpec]} {
		set code [catch {uplevel 1 [lindex $args 2]} result]
		return -code $code $result
	    } else {
		return ""
	    }
	}

	style {
	    if {$argCount != 1} {
		mwutil::wrongNumArgs "$win $cmd"
	    }

	    return [$scl cget -style]
	}

	switchstate {
	    if {$argCount < 1 || $argCount > 2} {
		mwutil::wrongNumArgs "$win $cmd ?boolean?"
	    }

	    if {$argCount == 1} {
		#
		# Return the widget's current switch state
		#
		return [$scl instate selected]
	    } else {
		#
		# Update the widget's switch state
		#
		set oldSelState [$scl instate selected]
		set newSelState [expr {[lindex $args 1] ? 1 : 0}]
		$scl instate disabled {
		    return ""
		}
		if {$newSelState} {
		    $scl state selected
		    $scl set [$scl cget -to]
		} else {
		    $scl state !selected
		    $scl set [$scl cget -from]
		}

		upvar ::tsw::ns${win}::data data
		if {$data(-variable) ne ""} {
		    #
		    # Update the associated variable
		    #
		    upvar #0 $data(-variable) var
		    trace remove variable var {write unset} $data(varTraceCmd)
		    set var [expr {$newSelState ?
				   $data(-onvalue) : $data(-offvalue)}]
		    trace add variable var {write unset} $data(varTraceCmd)
		}

		if {$newSelState == $oldSelState || $data(-command) eq ""} {
		    return ""
		} else {
		    return [uplevel #0 $data(-command)]
		}
	    }
	}

	toggle {
	    if {$argCount != 1} {
		mwutil::wrongNumArgs "$win $cmd"
	    }

	    set flag [expr {![::$win switchstate]}]
	    return [::$win switchstate $flag]
	}
    }
}

#
# Private procedures used in bindings
# ===================================
#

#------------------------------------------------------------------------------
# tsw::onDestroy
#------------------------------------------------------------------------------
proc tsw::onDestroy win {
    upvar ::tsw::ns${win}::data data
    if {$data(-variable) ne "" &&
	[catch {upvar #0 $data(-variable) var}] == 0} {
	trace remove variable var {write unset} $data(varTraceCmd)
    }

    namespace delete ::tsw::ns$win
    catch {rename ::$win ""}
}

#------------------------------------------------------------------------------
# tsw::onThemeChanged
#------------------------------------------------------------------------------
proc tsw::onThemeChanged w {
    variable theme [ttk::style theme use]

    if {$w eq "."} {
	condMakeLayouts
    } else {
	set scl $w.scl
	set stateSpec [$scl state !disabled]		;# needed for $scl set
	$scl set [expr {[$scl instate selected] ?
			[$scl cget -to] : [$scl cget -from]}]
	$scl state $stateSpec
    }
}

#------------------------------------------------------------------------------
# tsw::onButton1
#------------------------------------------------------------------------------
proc tsw::onButton1 {w x y} {
    $w instate disabled {
	return ""
    }

    $w state pressed

    variable stateArr
    array set stateArr [list  dragging 0  startX $x  prevX $x \
			prevElem [$w identify element $x $y]]

    upvar ::tsw::ns[winfo parent $w]::data data
    set data(moveState) idle
}

#------------------------------------------------------------------------------
# tsw::onB1Motion
#------------------------------------------------------------------------------
proc tsw::onB1Motion {w x y} {
    if {[$w instate disabled] || [$w instate !pressed]} {
	return ""
    }

    variable theme
    variable stateArr

    if {$theme eq "aqua"} {
	upvar ::tsw::ns[winfo parent $w]::data data
	if {$data(moveState) eq "moving"} {
	    return ""
	}

	set curElem [$w identify element $x $y]
	if {[string match "*.slider" $stateArr(prevElem)] &&
	    [string match "*.trough" $curElem]} {
	    startToggling $w
	} elseif {$x < [winfo x $w]} {
	    startMovingLeft $w
	} elseif {$x >= [winfo x $w] + [winfo width $w]} {
	    startMovingRight $w
	}

	set stateArr(prevElem) $curElem
    } else {
	variable scaled4
	if {!$stateArr(dragging) && abs($x - $stateArr(startX)) > $scaled4} {
	    set stateArr(dragging) 1
	}
	if {!$stateArr(dragging)} {
	    return ""
	}

	lassign [$w coords] curX curY
	set newX [expr {$curX + $x - $stateArr(prevX)}]
	$w set [$w get $newX $curY]

	set stateArr(prevX) $x
    }
}

#------------------------------------------------------------------------------
# tsw::onButtonRel1
#------------------------------------------------------------------------------
proc tsw::onButtonRel1 w {
    if {[$w instate disabled] || [$w instate !pressed]} {
	return ""
    }

    variable stateArr
    set win [winfo parent $w]

    if {$stateArr(dragging)} {
	::$win switchstate [expr {[$w get] > [$w cget -to]/2}]
    } elseif {[$w instate hover]} {
	variable theme
	if {$theme eq "aqua"} {
	    upvar ::tsw::ns${win}::data data
	    if {$data(moveState) eq "idle"} {
		startToggling $w
	    }
	} else {
	    ::$win toggle
	}
    }

    $w state !pressed
    set stateArr(dragging) 0
}

#------------------------------------------------------------------------------
# tsw::onSpace
#------------------------------------------------------------------------------
proc tsw::onSpace w {
    if {[$w instate disabled] || [$w instate pressed]} {
	return ""
    }

    $w state pressed
    after 200 [list tsw::toggleSwitchState $w]
}

#------------------------------------------------------------------------------
# tsw::startToggling
#------------------------------------------------------------------------------
proc tsw::startToggling w {
    if {[$w get] == [$w cget -to]} {
	startMovingLeft $w
    } else {
	startMovingRight $w
    }
}

#------------------------------------------------------------------------------
# tsw::startMovingLeft
#------------------------------------------------------------------------------
proc tsw::startMovingLeft w {
    if {[$w get] == [$w cget -from]} {
	return ""
    }

    upvar ::tsw::ns[winfo parent $w]::data data
    set data(moveState) moving
    $w state !selected		;# will be undone before invoking switchstate
    moveLeft $w [$w cget -to]
}

#------------------------------------------------------------------------------
# tsw::moveLeft
#------------------------------------------------------------------------------
proc tsw::moveLeft {w val} {
    if {![winfo exists $w] || [winfo class $w] ne "TswScale"} {
	return ""
    }

    set val [expr {$val - 1}]
    $w set $val

    if {$val > [$w cget -from]} {
	after 10 [list tsw::moveLeft $w $val]
    } else {
	$w state selected	;# restores the original selected state flag
	set win [winfo parent $w]
	::$win switchstate 0

	upvar ::tsw::ns${win}::data data
	set data(moveState) moved
    }
}

#------------------------------------------------------------------------------
# tsw::startMovingRight
#------------------------------------------------------------------------------
proc tsw::startMovingRight w {
    if {[$w get] == [$w cget -to]} {
	return ""
    }

    upvar ::tsw::ns[winfo parent $w]::data data
    set data(moveState) moving
    $w state selected		;# will be undone before invoking switchstate
    moveRight $w [$w cget -from]
}

#------------------------------------------------------------------------------
# tsw::moveRight
#------------------------------------------------------------------------------
proc tsw::moveRight {w val} {
    if {![winfo exists $w] || [winfo class $w] ne "TswScale"} {
	return ""
    }

    set val [expr {$val + 1}]
    $w set $val

    if {$val < [$w cget -to]} {
	after 10 [list tsw::moveRight $w $val]
    } else {
	$w state !selected	;# restores the original !selected state flag
	set win [winfo parent $w]
	::$win switchstate 1

	upvar ::tsw::ns${win}::data data
	set data(moveState) moved
    }
}

#------------------------------------------------------------------------------
# tsw::toggleSwitchState
#------------------------------------------------------------------------------
proc tsw::toggleSwitchState w {
    if {![winfo exists $w] || [winfo class $w] ne "TswScale"} {
	return ""
    }

    ::[winfo parent $w] toggle
    $w state !pressed
}
