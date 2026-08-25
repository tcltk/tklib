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
# Copyright (c) 2025-2026  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
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
    # the widget to which the option applies: f stands for the frame, l for the
    # ttk::label child, and w for the toggleswitch widget itself.
    #
    #   Command-Line Name	{Database Name	Database Class	W}
    #   ----------------------------------------------------------
    #
    variable configSpecs
    array set configSpecs {
	-class			{""		""		f}
	-command		{command	Command		w}
	-cursor			{cursor		Cursor		f}
	-font			{font		Font		l}
	-foreground		{textColor	TextColor	l}
	-offvalue		{offValue	OffValue	w}
	-onvalue		{onValue	OnValue		w}
	-size			{size		Size		w}
	-style			{style		Style		w}
	-takefocus		{takeFocus	TakeFocus	f}
	-text			{text		Text		l}
	-textvariable		{textVariable	Variable	w}
	-underline		{underline	Underline	l}
	-variable		{variable	Variable	w}
	-width			{width		Width		l}
    }

    #
    # Extend the elements of the array configSpecs
    #
    lappend configSpecs(-class)		"Toggleswitch"
    lappend configSpecs(-command)	""
    lappend configSpecs(-cursor)	""
    lappend configSpecs(-font)		"TkDefaultFont"
    lappend configSpecs(-foreground)	""
    lappend configSpecs(-offvalue)	0
    lappend configSpecs(-onvalue)	1
    lappend configSpecs(-size)		"2"
    lappend configSpecs(-style)		"Toggleswitch2"
    lappend configSpecs(-takefocus)	"ttk::takefocus"
    lappend configSpecs(-text)		""
    lappend configSpecs(-textvariable)	""
    lappend configSpecs(-underline)	[expr {$::tk_version >= 9 ? "" : -1}]
    lappend configSpecs(-variable)	""
    lappend configSpecs(-width)		0

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
    set stateArr(dragging)  0
    set stateArr(moveState) idle		;# other values: moving, moved

    #
    # Create the ToggleswitchHull layout
    #
    proc createToggleswitchHullLayout {} {
	variable theme
	if {$theme eq "aqua"} {
	    ttk::style layout ToggleswitchHull {
		Switch.border -sticky nswe
	    }
	} else {
	    ttk::style layout ToggleswitchHull {
		Switch.focus -sticky nswe -children {
		    Switch.border -sticky nswe
		}
	    }
	}

	if {$theme eq "classic" &&
	    [ttk::style lookup ToggleswitchHull -focussolid] eq ""} {
	    ttk::style configure ToggleswitchHull -focussolid 1
	}
    }
    createToggleswitchHullLayout
}

#
# Private procedure creating the default bindings
# ===============================================
#

#------------------------------------------------------------------------------
# tsw::createBindings
#
# Creates the default bindings for the binding tags Toggleswitch, TswMain,
# TswScale, and TswLabel.
#------------------------------------------------------------------------------
proc tsw::createBindings {} {
    bind Toggleswitch <KeyPress> continue
    bind Toggleswitch <space>	     { tsw::onSpace %W }
    bind Toggleswitch <Destroy>	     { tsw::onDestroy %W }

    variable onAndroid [expr {[info exists ::tk::android] && $::tk::android}]
    if {!$onAndroid} {
	bind Toggleswitch <Enter>    { %W instate !disabled {%W state active} }
	bind Toggleswitch <Leave> {
	    if {"%d" ne "NotifyInferior"} { %W state !active }
	}
    }

    bindtags . [linsert [bindtags .] 1 TswMain]
    foreach event {<<ThemeChanged>> <<LightAppearance>> <<DarkAppearance>>
		   <<LightAqua>> <<DarkAqua>>} {
	bind TswMain $event { tsw::onThemeChanged %W }
    }

    bind TswScale <<ThemeChanged>>	{ tsw::onThemeChanged %W }

    foreach class {TswScale TswLabel} {
	bind $class <B1-Leave>		{ # Preserves the active state. }
	bind $class <Button-1>		{ tsw::onButton1    %W %x %y }
	bind $class <B1-Motion>		{ tsw::onB1Motion   %W %x %y }
	bind $class <ButtonRelease-1>	{ tsw::onButtonRel1 %W }
    }
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

    set argCount [llength $args]
    if {$argCount == 0 || $argCount % 2 == 0} {
	mwutil::wrongNumArgs "tsw::toggleswitch pathName ?options?"
    }

    #
    # Get the value of the last "-class" option if present
    #
    set className "Toggleswitch"
    for {set n [expr {$argCount - 2}]} {$n > 1} {incr n -2} {
	if {[lindex $args $n] eq "-class"} {
	    set className [lindex $args [expr {$n + 1}]]
	    break
	}
    }

    #
    # Create a ttk::frame of the class $className
    #
    set win [lindex $args 0]
    if {[catch {
	ttk::frame $win -class $className -style ToggleswitchHull \
			-borderwidth 0 -relief flat -height 0 -width 0 \
			-padding 0
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
    set data(-class) $className
    set data(varTraceCmd) [list tsw::varTrace $win]
    set data(textVarTraceCmd) [list tsw::textVarTrace $win]

    #
    # Create a ttk::scale child of a special style and a ttk::label child
    #
    condMakeElements
    set size [lindex $configSpecs(-size) end]
    set scl [ttk::scale $win.scl -class TswScale -style Toggleswitch$size \
	     -takefocus 0 -length 0 -from 0 -to 20]
    pack $scl -side right -fill both
    variable scaled4
    set r [expr {2 * $scaled4}]
    set pad [list 0 0 $r 0]
    set l [ttk::label $win.l -anchor w -class TswLabel -compound "" \
	   -background "" -cursor "" -font TkDefaultFont -foreground "" \
	   -image {} -justify left -padding $pad -relief flat -state normal \
	   -style TLabel -takefocus 0 -text "" -textvariable "" -underline \
	   [expr {$::tk_version >= 9 ? "" : -1}] -width 0 -wraplength 0]

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

    updateStyle $win
    updateGeometry $win

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
	    if {$opt eq "-class"} {
		if {[lindex [info level -2] 0] eq "mwutil::configureSubCmd"} {
		    return -code error "attempt to change read-only option"
		} else {
		    return ""
		}
	    }

	    #
	    # Apply the value to the frame and save the
	    # properly formatted value of val in data($opt)
	    #
	    $win configure $opt $val
	    set data($opt) [$win cget $opt]

	    switch -- $opt {
		-cursor {
		    $win.scl configure $opt $val
		    $win.l   configure $opt $val
		}
	    }
	}

	l {
	    #
	    # Apply the value to the label child and save the
	    # properly formatted value of val in data($opt)
	    #

	    $win.l configure $opt $val

	    switch -- $opt {
		-text {
		    if {$data(-textvariable) ne ""} {
			#
			# Update the text variable *before*
			# invoking "$win.l cget -text"
			#
			upvar #0 $data(-textvariable) var
			trace remove variable var {write unset} \
			    $data(textVarTraceCmd)
			set var $val
			trace add variable var {write unset} \
			    $data(textVarTraceCmd)
		    }
		}
	    }

	    set data($opt) [$win.l cget $opt]
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
		    set data($opt) $val
		}

		-style {
		    $win.scl configure -style $val
		    set data($opt) $val
		}

		-textvariable {
		    makeTextVariable $win $val
		    $win.l configure $opt $val
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
# tsw::doCget
#
# Returns the value of the configuration option opt for the toggleswitch
# widget win.
#------------------------------------------------------------------------------
proc tsw::doCget {win opt} {
    upvar ::tsw::ns${win}::data data
    return $data($opt)
}

#------------------------------------------------------------------------------
# tsw::updateGeometry
#
# Updates the pack parameters for the children of the toggleswitch widget win.
#------------------------------------------------------------------------------
proc tsw::updateGeometry win {
    set hullStyle [$win cget -style]
    set thickness [ttk::style lookup $hullStyle -focusthickness {} 1]
    set solid [ttk::style lookup $hullStyle -focussolid {} 0]
    set pad [expr {$solid ? [winfo pixels $win $thickness] : 1}]
    set l $win.l; set scl $win.scl

    if {[$l cget -text] eq ""} {
	pack forget $l
	pack configure $scl -expand 1 -padx $pad -pady $pad
    } else {
	pack $l -side left -expand 1 -fill both -padx [list $pad 0] -pady $pad
	pack configure $scl -expand 0 -padx [list 0 $pad] -pady $pad
    }
}

#------------------------------------------------------------------------------
# tsw::updateStyle
#
# Sets the "-style" option to "(*.)Toggleswitch{1|2|3}", depending on the size,
# if the option's previous value was of the same form.
#------------------------------------------------------------------------------
proc tsw::updateStyle win {
    upvar ::tsw::ns${win}::data data
    set size $data(-size)
    set style $data(-style)
    set idx [string last "." $style]
    set styleTail [expr {$idx < 0 ?
			 $style : [string range $style [incr idx] end]}]
    if {$styleTail eq "Toggleswitch1" || $styleTail eq "Toggleswitch2" ||
	$styleTail eq "Toggleswitch3"} {
	set style [string replace $style end end $size]

	$win.scl configure -style $style
	set data(-style) $style
    }
}

#------------------------------------------------------------------------------
# tsw::updateSize
#
# Sets the "-size" option to "1|2|3" if the style is "(*.)Toggleswitch{1|2|3}".
#------------------------------------------------------------------------------
proc tsw::updateSize win {
    upvar ::tsw::ns${win}::data data
    set style $data(-style)
    set idx [string last "." $style]
    set styleTail [expr {$idx < 0 ?
		   $style : [string range $style [incr idx] end]}]
    if {$styleTail eq "Toggleswitch1"} {
	set data(-size) 1
    } elseif {$styleTail eq "Toggleswitch2"} {
	set data(-size) 2
    } elseif {$styleTail eq "Toggleswitch3"} {
	set data(-size) 3
    }
}

#------------------------------------------------------------------------------
# tsw::makeTextVariable
#
# Arranges for the global variable specified by varName to become the text
# variable associated with the toggleswitch widget win.
#------------------------------------------------------------------------------
proc tsw::makeTextVariable {win varName} {
    upvar ::tsw::ns${win}::data data
    if {$varName eq ""} {
	#
	# If there is an old text variable associated with the
	# widget then remove the trace set on this variable
	#
	if {$data(-textvariable) ne "" &&
	    [catch {upvar #0 $data(-textvariable) oldVar}] == 0} {
	    trace remove variable oldVar {write unset} $data(textVarTraceCmd)
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
    # If there is an old text variable associated with the
    # widget then remove the trace set on this variable
    #
    if {$data(-textvariable) ne "" &&
	[catch {upvar #0 $data(-textvariable) oldVar}] == 0} {
	trace remove variable oldVar {write unset} $data(textVarTraceCmd)
    }

    if {[info exists var]} {
	#
	# Invoke the trace procedure associated with the new variable
	#
	varTrace $win $name1 $name2 write
    } else {
	#
	# Set $varName according to the widget's text
	#
	set var [$win.l cget -text]
    }

    #
    # Set a trace on the new variable
    #
    trace add variable var {write unset} $data(textVarTraceCmd)
}

#------------------------------------------------------------------------------
# tsw::textVarTrace
#
# This procedure is executed whenever the global variable specified by varName
# and arrIndex is written or unset.  It makes sure that the label's text is
# synchronized with the value of the variable, and that the variable is
# recreated if it was unset.
#------------------------------------------------------------------------------
proc tsw::textVarTrace {win varName arrIndex op} {
    if {$arrIndex ne ""} {
	set varName ${varName}($arrIndex)
    }
    upvar #0 $varName var

    upvar ::tsw::ns${win}::data data
    switch $op {
	write {
	    #
	    # Synchronize the label's text with the variable's value
	    #
	    $win.l configure -text $var
	    set data(-text) $var

	    updateGeometry $win
	}

	unset {
	    #
	    # Recreate the variable $varName by setting it according to
	    # the label's text, and set the trace on it again
	    #
	    set var [$win.l cget -text]
	    trace add variable var {write unset} $data(textVarTraceCmd)
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
	    $scl state $stateSpec			;# restores the state
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
	    set result [mwutil::configureSubCmd $win configSpecs \
			tsw::doConfig tsw::doCget $argList]

	    if {[llength $argList] > 1} {
		foreach {opt val} $argList {
		    if {$opt eq "-size"} {
			updateStyle $win
			return $result
		    }
		}
		foreach {opt val} $argList {
		    if {$opt eq "-style"} {
			updateSize $win
			break
		    }
		}

		updateGeometry $win
	    }

	    return $result
	}

	hasattrib -
	unsetattrib {
	    if {$argCount != 2} {
		mwutil::wrongNumArgs "$win $cmd name"
	    }

	    return [mwutil::${cmd}SubCmdEx "tsw" $win "widget" [lindex $args 1]]
	}

	identify {
	    if {[catch {$scl $cmd {*}$argList} result] != 0} {
		return -code error [string map [list $scl $win] $result]
	    }

	    set xIdx [expr {$argCount - 3}]
	    set x [lindex $argList $xIdx]
	    incr x -[winfo x $scl]
	    set argList [lreplace $argList $xIdx $xIdx $x]
	    return [$scl $cmd {*}$argList]
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

	state {
	    if {[catch {$scl $cmd {*}$argList} result] != 0} {
		return -code error [string map [list $scl $win] $result]
	    }

	    if {$argCount > 1} {
		$win.l state [lindex $args 1]
	    }

	    return $result
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
# tsw::onSpace
#------------------------------------------------------------------------------
proc tsw::onSpace win {
    if {[$win instate disabled] || [$win instate pressed]} {
	return ""
    }

    $win state pressed
    after 200 [list tsw::toggleSwitchState $win]
}

#------------------------------------------------------------------------------
# tsw::onDestroy
#------------------------------------------------------------------------------
proc tsw::onDestroy win {
    if {![namespace exists ::tsw::ns$win]} {
	return ""    ;# the widget was not created by the tsw::toggleswitch cmd
    }

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
	createToggleswitchHullLayout
	condUpdateElements
    } else {
	updateGeometry [winfo parent $w]

	set stateSpec [$w state !disabled]		;# needed for $w set
	$w set [expr {[$w instate selected] ? [$w cget -to] : [$w cget -from]}]
	$w state $stateSpec				;# restores the state
    }
}

#------------------------------------------------------------------------------
# tsw::onButton1
#------------------------------------------------------------------------------
proc tsw::onButton1 {w x y} {
    $w instate disabled {
	return ""
    }

    set win [winfo parent $w]
    ::$win state pressed

    variable stateArr
    incr x [winfo x $w]
    array set stateArr [list  dragging 0  moveState idle  startX $x  prevX $x \
			prevElem [::$win identify element $x $y]]
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

    set win [winfo parent $w]
    set scl $win.scl
    incr x [winfo x $w]

    if {$theme eq "aqua"} {
	if {$stateArr(moveState) eq "moving"} {
	    return ""
	}

	set curElem [::$win identify element $x $y]
	if {[string match "*.slider" $stateArr(prevElem)] &&
	    [string match "*.trough" $curElem]} {
	    startToggling $scl
	} elseif {$x < 0} {
	    startMovingLeft $scl
	} elseif {$x >= [winfo width $win]} {
	    startMovingRight $scl
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

	#
	# Guard against a bug in the ttk::scale widget's "get x y"
	# command (fixed in July 2025 for Tk 9.1a0, 9.0.3, and 8.6.17)
	#
	lassign [$scl coords [$scl cget -from]] fromX fromY
	lassign [$scl coords [$scl cget -to]] toX toY
	if {$fromX < $toX} {
	    lassign [$scl coords] curX curY
	    set newX [expr {$curX + $x - $stateArr(prevX)}]
	    $scl set [$scl get $newX $curY]
	}

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
    set scl $win.scl

    if {$stateArr(dragging)} {
	::$win switchstate [expr {[$scl get] > [$scl cget -to]/2}]
    } elseif {[$w instate hover]} {
	variable theme
	if {$theme eq "aqua"} {
	    if {$stateArr(moveState) eq "idle"} {
		startToggling $scl
	    }
	} else {
	    ::$win toggle
	}
    }

    ::$win state !pressed
    set stateArr(dragging) 0
}

#------------------------------------------------------------------------------
# tsw::toggleSwitchState
#------------------------------------------------------------------------------
proc tsw::toggleSwitchState win {
    if {![winfo exists $win] || [winfo class $win] ne "Toggleswitch"} {
	return ""
    }

    ::$win toggle
    $win state !pressed
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

    variable stateArr
    set stateArr(moveState) moving
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
	$w state selected	;# restores the original selected state
	set win [winfo parent $w]
	::$win switchstate 0

	variable stateArr
	set stateArr(moveState) moved
    }
}

#------------------------------------------------------------------------------
# tsw::startMovingRight
#------------------------------------------------------------------------------
proc tsw::startMovingRight w {
    if {[$w get] == [$w cget -to]} {
	return ""
    }

    variable stateArr
    set stateArr(moveState) moving
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
	$w state !selected	;# restores the original !selected state
	set win [winfo parent $w]
	::$win switchstate 1

	variable stateArr
	set stateArr(moveState) moved
    }
}
