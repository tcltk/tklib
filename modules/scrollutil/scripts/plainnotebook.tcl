#==============================================================================
# Contains the implementation of the plainnotebook widget.
#
# Structure of the module:
#   - Namespace initialization
#   - Private procedure creating the default bindings
#   - Public procedure creating a new plainnotebook widget
#   - Private configuration procedures
#   - Private procedures implementing the plainnotebook widget command
#   - Private procedures used in bindings
#   - Private utility procedures
#
# Copyright (c) 2021-2022  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require Tk 8.4

#
# Namespace initialization
# ========================
#

namespace eval scrollutil::pnb {
    #
    # The array configSpecs is used to handle configuration options.  The names
    # of its elements are the configuration options for the Plainnotebook
    # class.  The value of an array element is a list containing the database
    # name and class as well as an indicator specifying the widget to which the
    # option applies: f stands for the outer frame, n for the notebook child,
    # and w for the plainnotebook widget itself.
    #
    #	Command-Line Name	{Database Name	Database Class	W}
    #	----------------------------------------------------------
    #
    variable configSpecs
    array set configSpecs {
	-caller			{caller		Caller		w}
	-closabletabs		{closableTabs	ClosableTabs	w}
	-cursor			{cursor		Cursor		f}
	-forgetcommand		{forgetCommand	ForgetCommand	w}
	-height			{height		Height		n}
	-leavecommand		{leaveCommand	LeaveCommand	w}
	-movabletabs		{movableTabs	MovableTabs	w}
	-side			{side		Side		w}
	-takefocus		{takeFocus	TakeFocus	f}
	-title			{title		Title		w}
	-width			{width		Width		n}
    }

    #
    # Extend the elements of the array configSpecs
    #
    lappend configSpecs(-caller)	-1
    lappend configSpecs(-closabletabs)	0
    lappend configSpecs(-cursor)	""
    lappend configSpecs(-forgetcommand)	""
    lappend configSpecs(-height)	0
    lappend configSpecs(-leavecommand)	""
    lappend configSpecs(-movabletabs)	1
    lappend configSpecs(-side)		left
    lappend configSpecs(-takefocus)	"ttk::takefocus"
    lappend configSpecs(-title)		""
    lappend configSpecs(-width)		0

    variable configOpts [lsort [array names configSpecs]]

    #
    # Use a list to facilitate the handling of command options
    #
    variable cmdOpts [list add addbutton addlabel addseparator cget \
		      closablestate configure forget hide index insert \
		      insertbutton insertlabel insertseparator instate see \
		      select state style tab tabpath tabs titlepath]

    #
    # Array variable used in binding scripts for the tag PlainnotebookTab:
    #
    variable stateArr
    array set stateArr {
	closebtnPressed	0
	sourceIdx	""
	targetIdx	""
    }

    variable userDataSupported [expr {$::tk_version >= 8.5 &&
	[package vcompare $::tk_patchLevel "8.5a2"] >= 0}]

    #
    # Create the descend element
    #
    proc createDescendElement {} {
	::scrollutil::createDescendImages 

	set width [expr {[image width scrollutil_descendImg] +
			 [winfo pixels . 6p]}]
	ttk::style element create descend image [list scrollutil_descendImg \
	    disabled scrollutil_descendDisabledImg \
	] -width $width -sticky e
    }
    ttk::style theme settings default {
	if {[lsearch -exact [ttk::style element names] "descend"] < 0} {
	    createDescendElement 
	}
    }

    #
    # Create the Desc.Toolbutton layout
    #
    proc createDescToolbuttonLayout {} {
	set toolbtnLayout [ttk::style layout Toolbutton]

	set oldStr1 "Toolbutton.label -sticky nswe"
	set oldStr2 "Toolbutton.label -expand 1 -sticky nswe"

	set newStr "Toolbutton.label -side left -sticky {}\
		    Toolbutton.descend -side right -sticky {}"

	foreach oldStr [list $oldStr1 $oldStr2] {
	    if {[set first [string first $oldStr $toolbtnLayout]] >= 0} {
		set last [expr {$first + [string length $oldStr] - 1}]
		ttk::style layout Desc.Toolbutton \
		    [string replace $toolbtnLayout $first $last $newStr]
		return 1
	    }
	}

	return 0
    }
    createDescToolbuttonLayout 

    #
    # Create the closebtn element
    #
    proc createClosebtnElement {} {
	::scrollutil::createCloseImages 

	#
	# The "user*" states are not supported by
	# Tk versions earlier than 8.5.9 or 8.6b1.
	#
	variable user1 "user1" user2 "user2"
	if {[package vsatisfies $::tk_patchLevel 8-8.5.9] ||
	    [package vsatisfies $::tk_patchLevel 8.6-8.6b1]} {
	    set user1 "readonly"
	    set user2 "invalid"
	}

	set width  [expr {[image width scrollutil_closeImg] +
			  [winfo pixels . 3p]}]
	set sticky [expr {[tk windowingsystem] eq "aqua" ? "w" : "e"}]
	ttk::style element create closebtn image [list scrollutil_closeImg \
	    $user2	scrollutil_closePressedImg \
	    $user1	scrollutil_closeHoverImg \
	    disabled	scrollutil_closeDisabledImg \
	] -width $width -sticky $sticky
    }
    ttk::style theme settings default {
	if {[lsearch -exact [ttk::style element names] "closebtn"] < 0} {
	    createClosebtnElement 
	}
    }

    #
    # Create the ClosablePage.Toolbutton layout
    #
    proc createClosablePageToolbuttonLayout {} {
	set toolbtnLayout [ttk::style layout Toolbutton]

	set oldStr1 "Toolbutton.label -sticky nswe"
	set oldStr2 "Toolbutton.label -expand 1 -sticky nswe"

	if {[tk windowingsystem] eq "aqua"} {
	    set newStr "Toolbutton.closebtn -side left -sticky {}\
			Toolbutton.label -side left -sticky {}"
	} else {
	    set newStr "Toolbutton.label -side left -sticky {}\
			Toolbutton.closebtn -side right -sticky {}"
	}

	foreach oldStr [list $oldStr1 $oldStr2] {
	    if {[set first [string first $oldStr $toolbtnLayout]] >= 0} {
		set last [expr {$first + [string length $oldStr] - 1}]
		ttk::style layout ClosablePage.Toolbutton \
		    [string replace $toolbtnLayout $first $last $newStr]
		return 1
	    }
	}

	return 0
    }
    createClosablePageToolbuttonLayout 

    #
    # Configure some styles
    #
    proc configStyles {} {
	#
	# Configure the Plainnotebook.TNotebook style
	#
	ttk::style layout Plainnotebook.TNotebook.Tab null
	ttk::style configure Plainnotebook.TNotebook -mintabwidth 0 \
	    -padding 0 -tabmargins 0

	#
	# Configure the Desc.Toolbutton, Page.Toolbutton,
	# and ClosablePage.Toolbutton styles
	#
	foreach style {Desc.Toolbutton Page.Toolbutton
		       ClosablePage.Toolbutton} {
	    ttk::style configure $style -anchor w -padding 3p
	}
	switch [mwutil::currentTheme] {
	    alt -
	    classic -
	    default {
		set lst [linsert [ttk::style map Toolbutton -background] 0 \
			 selected #c3c3c3]
		ttk::style map Page.Toolbutton	       -background $lst
		ttk::style map ClosablePage.Toolbutton -background $lst
	    }

	    clam {
		set lst [linsert [ttk::style map Toolbutton -background] 2 \
			 selected #bab5ab]
		ttk::style map Page.Toolbutton	       -background $lst
		ttk::style map ClosablePage.Toolbutton -background $lst

		set lst [linsert [ttk::style map Toolbutton -lightcolor] 0 \
			 selected #bab5ab]
		ttk::style map Page.Toolbutton	       -lightcolor $lst
		ttk::style map ClosablePage.Toolbutton -lightcolor $lst

		set lst [linsert [ttk::style map Toolbutton -darkcolor] 0 \
			 selected #bab5ab]
		ttk::style map Page.Toolbutton	       -darkcolor $lst
		ttk::style map ClosablePage.Toolbutton -darkcolor $lst
	    }
	}
    }
    configStyles 

    #
    # Create a font for titles
    #
    proc createTitleFont {} {
	set size [font actual TkDefaultFont -size]
	if {$size == 0} {
	    set size 9
	}
	set factor [expr {$size * 6}]
	set size [expr {$factor / 5}]
	if {$factor % 5 > 2} {
	    incr size
	}

	variable titleFont \
	    [eval font create [font actual TkDefaultFont] -size $size]
    }
    createTitleFont 
}

#
# Private procedure creating the default bindings
# ===============================================
#

#------------------------------------------------------------------------------
# scrollutil::pnb::createBindings
#
# Creates the default bindings for the binding tags Plainnotebook,
# PlainnotebookMain, and PlainnotebookTab, and extends the default bindings for
# TNotebook.
#------------------------------------------------------------------------------
proc scrollutil::pnb::createBindings {} {
    bind Plainnotebook <KeyPress> continue
    bind Plainnotebook <FocusIn> {
	if {[focus -lastfor %W] eq "%W"} {
            focus %W.nb
        }
    }
    bind Plainnotebook <Map> { scrollutil::pnb::onPlainnotebookMap %W }
    bind Plainnotebook <Destroy> {
	namespace delete scrollutil::ns%W
	catch {rename %W ""}
    }
    bind Plainnotebook <<TkWorldChanged>> {
	if {"%d" eq "FontChanged"} {
	    scrollutil::pnb::onFontChanged %W
	}
    }
    bind Plainnotebook <<ThemeChanged>> { scrollutil::pnb::onThemeChanged %W }

    bindtags . [linsert [bindtags .] 1 PlainnotebookMain]
    bind PlainnotebookMain <<ThemeChanged>> {
	scrollutil::pnb::onThemeChanged %W
    }

    #
    # Add support for moving and closing the plainnotebook tabs with the mouse
    #
    bind PlainnotebookTab <Motion>    { scrollutil::pnb::onMotion   %W %x %y }
    bind PlainnotebookTab <Button-1>  { scrollutil::pnb::onButton1  %W %x %y }
    bind PlainnotebookTab <B1-Motion> { scrollutil::pnb::onB1Motion %W %X %Y }
    bind PlainnotebookTab <Leave>     { scrollutil::pnb::onLeave    %W }
    bind PlainnotebookTab <B1-Leave>  { scrollutil::pnb::onB1Leave  %W }
    bind PlainnotebookTab <ButtonRelease-1> {
	scrollutil::pnb::onButtonRel1 %W %x %y
    }
    bind PlainnotebookTab <Escape>    { scrollutil::pnb::onEscape   %W }

    #
    # Define the virtual event <<Button3>> and create a binding for it
    #
    event add <<Button3>> <Button-3>
    if {[tk windowingsystem] eq "aqua"} {
	event add <<Button3>> <Control-Button-1>
    }
    variable userDataSupported
    if {$userDataSupported} {
	bind PlainnotebookTab <<Button3>> {
	    scrollutil::pnb::onButton3 %W %X %Y
	}
    }

    #
    # Extend the default bindings for TNotebook
    #
    bind TNotebook <Up>   { ttk::notebook::CycleTab %W -1; break }
    bind TNotebook <Down> { ttk::notebook::CycleTab %W  1; break }
}

#
# Public procedure creating a new plainnotebook widget
# ====================================================
#

#------------------------------------------------------------------------------
# scrollutil::plainnotebook
#
# Creates a new plainnotebook widget whose name is specified as the first
# command-line argument, and configures it according to the options and their
# values given on the command line.  Returns the name of the newly created
# widget.
#------------------------------------------------------------------------------
proc scrollutil::plainnotebook args {
    variable usingTile
    if {!$usingTile} {
	return -code error "package scrollutil_tile is not loaded"
    }

    variable pnb::configSpecs
    variable pnb::configOpts

    if {[llength $args] == 0} {
	mwutil::wrongNumArgs "plainnotebook pathName ?options?"
    }

    #
    # Create a frame of the class Plainnotebook
    #
    set win [lindex $args 0]
    if {[catch {
	ttk::frame $win -class Plainnotebook -borderwidth 0 -relief flat \
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
    }

    #
    # Initialize some components of data
    #
    upvar ::scrollutil::ns${win}::data data
    foreach opt $configOpts {
	set data($opt) [lindex $configSpecs($opt) 3]
    }

    #
    # Create a frame with the ascend toolbutton,
    # the title label, and a separator as children
    #
    set frm [ttk::frame $win.frm -padding 0]
    pnb::configFrame $win.frm
    if {[lsearch -exact [image names] "scrollutil_ascendImg"] < 0} {
	createAscendImage 
    }
    set ascend [ttk::button $frm.ascend -style Toolbutton \
		-image scrollutil_ascendImg]
    set title [ttk::label $frm.title -font $pnb::titleFont]
    set sep [ttk::separator $frm.sep]

    #
    # Create a scrollableframe within a scrollarea,
    # which in turn is a child of the above frame
    #
    set sa [scrollarea $frm.sa -borderwidth 0 -relief flat]
    set charWidth [font measure TkDefaultFont -displayof $win "0"]
    set sf [scrollableframe $sa.sf -borderwidth 0 -contentheight 0 \
	    -contentwidth 0 -fitcontentheight 0 -fitcontentwidth 0 -height 0 \
	    -relief flat -takefocus 0 -xscrollincrement $charWidth \
	    -yscrollincrement 0 -width 0]
    $sa setwidget $sf

    grid $ascend -row 0 -column 0 -padx {1.5p 0} -pady 1.5p
    grid $title  -row 0 -column 1 -sticky w -padx 3p -pady 1.5p
    grid $sep -columnspan 2 -sticky we
    grid $sa  -columnspan 2 -sticky nswe
    grid rowconfigure    $frm 2 -weight 1
    grid columnconfigure $frm 1 -weight 1

    grid remove $ascend $title $sep

    #
    # Create a plain ttk::notebook widget
    #
    set nb [ttk::notebook $win.nb -style Plainnotebook.TNotebook]

    pack $frm -side left -fill y
    pack $nb  -side left -expand 1 -fill both

    set data(sf)	  $sf
    set data(cf)	  [$sf contentframe]
    set data(cfWidth)	   0
    set data(rbCount)	   0
    set data(auxCount)	   0
    set data(currentPage)  ""

    #
    # Configure the widget according to the command-line
    # arguments and to the available database options
    #
    if {[catch {
	mwutil::configureWidget $win configSpecs scrollutil::pnb::doConfig \
				scrollutil::pnb::doCget [lrange $args 1 end] 1
    } result] != 0} {
	destroy $win
	return -code error $result
    }

    #
    # Move the original widget command into the namespace pnb within the current
    # one and create an alias of the original name for a new widget procedure
    #
    rename ::$win pnb::$win
    interp alias {} ::$win {} scrollutil::pnb::plainnotebookWidgetCmd $win

    menu $win._m_e_n_u_ -tearoff 0

    if {$::tcl_platform(platform) ne "windows" || ($::tk_version >= 8.6 &&
	[package vcompare $::tk_patchLevel "8.6b2"] >= 0)} {
	createWheelEventBindings all
    }

    bind $data(cf) <Configure> { scrollutil::pnb::onCfConfigure %W %w }

    #
    # Deactivate the navigation between the tabs of the
    # plain ttk::notebook widget via the mouse wheel
    #
    bindMouseWheel $nb break

    return $win
}

#
# Private configuration procedures
# ================================
#

#------------------------------------------------------------------------------
# scrollutil::pnb::doConfig
#
# Applies the value val of the configuration option opt to the plainnotebook
# widget win.
#------------------------------------------------------------------------------
proc scrollutil::pnb::doConfig {win opt val} {
    variable configSpecs
    upvar ::scrollutil::ns${win}::data data

    #
    # Apply the value to the widget corresponding to the given option
    #
    switch [lindex $configSpecs($opt) 2] {
	f {
	    #
	    # Apply the value to the outer frame and save the
	    # properly formatted value of val in data($opt)
	    #
	    $win configure $opt $val
	    set data($opt) [$win cget $opt]

	    switch -- $opt {
		-cursor {
		    $win.frm configure $opt $val
		    $win.nb  configure $opt $val
		}
	    }
	}

	n {
	    #
	    # Apply the value to the notebook and save the
	    # properly formatted value of val in data($opt)
	    #
	    $win.nb configure $opt $val
	    set data($opt) [$win.nb cget $opt]
	}

	w {
	    switch -- $opt {
		-caller {
		    if {![string is integer -strict $val]} {
			return -code error "bad page index $val"
		    }
		    if {$val >= 0} {
			set pm [winfo parent $win]
			if {[winfo class $pm] ne "Pagesman"} {
			    return -code error \
				"parent \"$pm\" is not a pagesman widget"
			}
			if {$val >= [$pm size]} {
			    return -code error "page index $val out of bounds"
			}
			$win.frm.ascend configure -command \
			    [list $pm select $val]
		    }
		    set data($opt) $val

		    if {$val < 0} {
			grid remove $win.frm.ascend
		    } else {
			grid $win.frm.ascend
		    }
		    if {$val < 0 && $data(-title) eq ""} {
			grid remove $win.frm.sep
		    } else {
			grid $win.frm.sep
		    }
		}
		-closabletabs {
		    set data($opt) [expr {$val ? 1 : 0}]
		    set data(rbStyle) [expr {
			$val ? "ClosablePage.Toolbutton" : "Page.Toolbutton"}]
		    foreach w [winfo children $data(cf)] {
			if {[winfo class $w] eq "TRadiobutton"} {
			    $w configure -style $data(rbStyle)
			}
		    }
		}
		-forgetcommand -
		-leavecommand {
		    set data($opt) $val
		}
		-movabletabs {
		    set data($opt) [expr {$val ? 1 : 0}]
		}
		-side {
		    set side [mwutil::fullOpt "side" $val {left right}]
		    set data($opt) $side
		    pack forget $win.frm $win.nb
		    pack $win.frm -side $side -fill y
		    pack $win.nb  -side $side -expand 1 -fill both
		}
		-title {
		    set data($opt) $val
		    $win.frm.title configure -text $val

		    if {$val eq ""} {
			grid remove $win.frm.title
		    } else {
			grid $win.frm.title
		    }
		    if {$data(-caller) < 0 && $val eq ""} {
			grid remove $win.frm.sep
		    } else {
			grid $win.frm.sep
		    }
		}
	    }
	}
    }
}

#------------------------------------------------------------------------------
# scrollutil::pnb::doCget
#
# Returns the value of the configuration option opt for the plainnotebook
# widget win.
#------------------------------------------------------------------------------
proc scrollutil::pnb::doCget {win opt} {
    upvar ::scrollutil::ns${win}::data data
    return $data($opt)
}

#
# Private procedures implementing the plainnotebook widget command
# ================================================================
#

#------------------------------------------------------------------------------
# scrollutil::pnb::plainnotebookWidgetCmd
#
# Processes the Tcl command corresponding to a plainnotebook widget.
#------------------------------------------------------------------------------
proc scrollutil::pnb::plainnotebookWidgetCmd {win args} {
    set argCount [llength $args]
    if {$argCount == 0} {
	mwutil::wrongNumArgs "$win option ?arg arg ...?"
    }

    upvar ::scrollutil::ns${win}::data data
    set nb $win.nb

    variable cmdOpts
    set cmd [mwutil::fullOpt "command" [lindex $args 0] $cmdOpts]
    set argList [lrange $args 1 end]

    switch $cmd {
	add {
	    set widget [lindex $args 1]
	    set tabIdx [lsearch -exact [$nb tabs] $widget]
	    if {[set isNew [expr {$tabIdx < 0}]]} {
		set tabIdx [$nb index end]
	    }
	    if {[catch {eval [list $nb $cmd] $argList} result] != 0} {
		return -code error $result
	    }

	    if {$isNew} {
		set rb [ttk::radiobutton $data(cf).rb$data(rbCount) \
			-style $data(rbStyle) -takefocus 0 \
			-command [list $nb select $widget] -value $widget \
			-variable ::scrollutil::ns${win}::data(selectedPage)]
		incr data(rbCount)
		set tabPath $rb
		bindtags $rb [linsert [bindtags $rb] 1 PlainnotebookTab]
	    } else {
		set tabPath [widgetToTab $win $widget]
	    }

	    configTab $win $tabIdx $tabPath
	    return ""
	}

	addbutton {
	    if {$argCount < 3 || $argCount > 4} {
		mwutil::wrongNumArgs "$win $cmd pageIndex text ?image?"
	    }

	    set pm [winfo parent $win]
	    if {[winfo class $pm] ne "Pagesman"} {
		return -code error "\"$pm\" is not a pagesman widget"
	    }
	    foreach {pageIdx text img} $argList {}
	    if {![string is integer -strict $pageIdx] || $pageIdx < 0} {
		return -code error "bad page index $pageIdx"
	    }
	    if {$img ne "" && [lsearch -exact [image names] $img] < 0} {
		return -code error "image \"$img\" doesn't exist"
	    }

	    set name aux$data(auxCount)
	    $nb add [ttk::frame $nb.$name] -compound left -text $text \
		-image $img -state disabled

	    set aux [ttk::button $data(cf).$name -style Desc.Toolbutton \
		     -takefocus 0 -compound left -text $text -image $img \
		     -command [list $pm select $pageIdx]]
	    grid $aux -sticky we
	    incr data(auxCount)
	    bindtags $aux [linsert [bindtags $aux] 1 PlainnotebookTab]
	    return $aux
	}

	addlabel {
	    if {$argCount < 2 || $argCount > 3} {
		mwutil::wrongNumArgs "$win $cmd text ?image?"
	    }

	    foreach {text img} $argList {}
	    if {$img ne "" && [lsearch -exact [image names] $img] < 0} {
		return -code error "image \"$img\" doesn't exist"
	    }

	    set name aux$data(auxCount)
	    $nb add [ttk::frame $nb.$name] -compound left -text $text \
		-image $img -state disabled

	    variable titleFont
	    set aux [ttk::label $data(cf).$name -font $titleFont \
		     -takefocus 0 -compound left -text $text -image $img \
		     -padding 3p]
	    grid $aux -sticky we
	    incr data(auxCount)
	    bindtags $aux [linsert [bindtags $aux] 1 PlainnotebookTab]
	    return $aux
	}

	addseparator {
	    if {$argCount != 1} {
		mwutil::wrongNumArgs "$win $cmd"
	    }

	    set name aux$data(auxCount)
	    $nb add [ttk::frame $nb.$name] -state disabled

	    set aux [ttk::separator $data(cf).$name -takefocus 0]
	    grid $aux -sticky we
	    incr data(auxCount)
	    bindtags $aux [linsert [bindtags $aux] 1 PlainnotebookTab]
	    return $aux
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
	    return $data($opt)
	}

	closablestate {
	    if {$argCount < 2 || $argCount > 3} {
		mwutil::wrongNumArgs "$win $cmd tabId ?boolean?"
	    }

	    set tabId [lindex $args 1]
	    set tabIdx [$nb index $tabId]
	    if {$tabIdx < 0 || $tabIdx >= [$nb index end]} {
		return -code error "tab index $tabId out of bounds"
	    }

	    set widget [lindex [$nb tabs] $tabIdx]
	    set tabPath [widgetToTab $win $widget]
	    if {$argCount == 2} {
		return [expr {
		    [$tabPath cget -style] eq "ClosablePage.Toolbutton"}]
	    } else {
		set val [expr {[lindex $args 2] ? 1 : 0}]
		set tabClass [winfo class $tabPath]
		if {$tabClass eq "TRadiobutton"} {
		    $tabPath configure -style [expr {
			$val ? "ClosablePage.Toolbutton" : "Page.Toolbutton"}]
		    return ""
		} else {
		    return -code error \
			"unsupported tab widget class \"$tabClass\""
		}
	    }
	}

	configure {
	    variable configSpecs
	    return [mwutil::configureSubCmd $win configSpecs \
		    scrollutil::pnb::doConfig scrollutil::pnb::doCget $argList]
	}

	forget {
	    if {$argCount != 2} {
		mwutil::wrongNumArgs "$win $cmd tab"
	    }

	    if {[catch {$nb index [lindex $args 1]} tabIdx] == 0 &&
		$tabIdx >= 0 && $tabIdx < [$nb index end]} {
		set widget [lindex [$nb tabs] $tabIdx]
		set tabPath [widgetToTab $win $widget]
		if {[set forgetCmd $data(-forgetcommand)] ne "" &&
		    ![uplevel #0 $forgetCmd [list $win $widget]]} {
		    return 0
		}
	    }

	    if {[catch {eval [list $nb $cmd] $argList} result] != 0} {
		return -code error $result
	    }

	    destroy $tabPath
	    return 1
	}

	hide {
	    if {[catch {$nb index [lindex $args 1]} tabIdx] == 0 &&
		$tabIdx >= 0 && $tabIdx < [$nb index end]} {
		set widget [lindex [$nb tabs] $tabIdx]
		set tabPath [widgetToTab $win $widget]
	    }
	    if {[catch {eval [list $nb $cmd] $argList} result] != 0} {
		return -code error $result
	    }

	    grid remove $tabPath
	    return ""
	}

	index {
	    if {$argCount != 2} {
		mwutil::wrongNumArgs "$win $cmd tab"
	    }

	    set tabId [lindex $args 1]
	    if {[scan $tabId "@%d,%d%n" x y count] == 3 &&
		$count == [string length $tabId]} {
		set cf $data(cf)
		incr x [expr {[winfo rootx $win] - [winfo rootx $cf]}]
		incr y [expr {[winfo rooty $win] - [winfo rooty $cf]}]
		if {$x < 0 || $x >= [winfo width  $cf] ||
		    $y < 0 || $y >= [winfo height $cf]} {
		    return ""
		}

		set tabIdx 0
		foreach widget [$win.nb tabs] {
		    set tabPath [widgetToTab $win $widget]
		    set tabY [winfo y $tabPath]
		    if {$y >= $tabY && $y < $tabY + [winfo height $tabPath]} {
			return $tabIdx
		    }

		    incr tabIdx
		}

		return ""
	    } else {
		set code [catch {eval [list $nb $cmd $tabId]} result]
		return -code $code $result
	    }
	}

	insert {
	    set widget [lindex $args 2]
	    set isNew [expr {[lsearch -exact [$nb tabs] $widget] < 0}]
	    if {[catch {eval [list $nb $cmd] $argList} result] != 0} {
		return -code error $result
	    }

	    if {$isNew} {
		set rb [ttk::radiobutton $data(cf).rb$data(rbCount) \
			-style $data(rbStyle) -takefocus 0 \
			-command [list $nb select $widget] -value $widget \
			-variable ::scrollutil::ns${win}::data(selectedPage)]
		incr data(rbCount)
		set tabPath $rb
	    } else {
		set tabPath [widgetToTab $win $widget]
	    }

	    reorderTabs $win
	    configTab $win [$nb index $widget] $tabPath
	    return ""
	}

	insertbutton {
	    if {$argCount < 4 || $argCount > 5} {
		mwutil::wrongNumArgs "$win $cmd index pageIndex text ?image?"
	    }

	    set pos [lindex $args 1]
	    if {$pos ne "end"} {
		set tabIdx [$nb index $pos]
		if {$tabIdx < 0 || $tabIdx >= [$nb index end]} {
		    return -code error "tab index $pos out of bounds"
		}
	    }
	    set pm [winfo parent $win]
	    if {[winfo class $pm] ne "Pagesman"} {
		return -code error "\"$pm\" is not a pagesman widget"
	    }
	    foreach {pageIdx text img} [lrange $args 2 end] {}
	    if {![string is integer -strict $pageIdx] || $pageIdx < 0} {
		return -code error "bad page index $pageIdx"
	    }
	    if {$img ne "" && [lsearch -exact [image names] $img] < 0} {
		return -code error "image \"$img\" doesn't exist"
	    }

	    set name aux$data(auxCount)
	    $nb insert $pos [ttk::frame $nb.$name] -compound left -text $text \
		-image $img -state disabled

	    set aux [ttk::button $data(cf).$name -style Desc.Toolbutton \
		     -takefocus 0 -compound left -text $text -image $img \
		     -command [list $pm select $pageIdx]]
	    incr data(auxCount)
	    bindtags $aux [linsert [bindtags $aux] 1 PlainnotebookTab]
	    reorderTabs $win
	    return $aux
	}

	insertlabel {
	    if {$argCount < 3 || $argCount > 4} {
		mwutil::wrongNumArgs "$win $cmd index text ?image?"
	    }

	    set pos [lindex $args 1]
	    if {$pos ne "end"} {
		set tabIdx [$nb index $pos]
		if {$tabIdx < 0 || $tabIdx >= [$nb index end]} {
		    return -code error "tab index $pos out of bounds"
		}
	    }
	    foreach {text img} [lrange $args 2 end] {}
	    if {$img ne "" && [lsearch -exact [image names] $img] < 0} {
		return -code error "image \"$img\" doesn't exist"
	    }

	    set name aux$data(auxCount)
	    $nb insert $pos [ttk::frame $nb.$name] -compound left -text $text \
		-image $img -state disabled

	    variable titleFont
	    set aux [ttk::label $data(cf).$name -font $titleFont \
		     -takefocus 0 -compound left -text $text -image $img \
		     -padding 3p]
	    incr data(auxCount)
	    bindtags $aux [linsert [bindtags $aux] 1 PlainnotebookTab]
	    reorderTabs $win
	    return $aux
	}

	insertseparator {
	    if {$argCount != 2} {
		mwutil::wrongNumArgs "$win $cmd index"
	    }

	    set pos [lindex $args 1]
	    if {$pos ne "end"} {
		set tabIdx [$nb index $pos]
		if {$tabIdx < 0 || $tabIdx >= [$nb index end]} {
		    return -code error "tab index $pos out of bounds"
		}
	    }

	    set name aux$data(auxCount)
	    $nb insert $pos [ttk::frame $nb.$name] -state disabled

	    set aux [ttk::separator $data(cf).$name -takefocus 0]
	    incr data(auxCount)
	    bindtags $aux [linsert [bindtags $aux] 1 PlainnotebookTab]
	    reorderTabs $win
	    return $aux
	}

	instate {
	    if {$argCount < 2 || $argCount > 3} {
		mwutil::wrongNumArgs "$win $cmd stateSpec ?script?"
	    }

	    set stateSpec [lindex $args 1]
	    if {$argCount == 2} {
		return [$nb instate $stateSpec]
	    } elseif {[$nb instate $stateSpec]} {
		return -code [catch {uplevel 1 [lindex $args 2]}] ""
	    } else {
		return ""
	    }
	}

	see {
	    if {$argCount != 2} {
		mwutil::wrongNumArgs "$win $cmd tabId"
	    }

	    set tabId [lindex $args 1]
	    set tabIdx [$nb index $tabId]
	    if {$tabIdx < 0 || $tabIdx >= [$nb index end]} {
		return -code error "tab index $tabId out of bounds"
	    }

	    set widget [lindex [$nb tabs] $tabIdx]
	    set tabPath [widgetToTab $win $widget]
	    $data(sf) see $tabPath
	    return ""
	}

	select -
	tabs {
	    set code [catch {eval [list $nb $cmd] $argList} result]
	    return -code $code $result
	}

	state {
	    if {[catch {eval [list $nb $cmd] $argList} result] != 0} {
		return -code error $result
	    }

	    if {$argCount > 1} {
		set stateSpec [expr {
		    [$nb instate disabled] ? "disabled" : "!disabled"}]
		foreach w [list $win.frm.ascend $win.frm.title $win.frm.sep] {
		    $w state $stateSpec
		}
		foreach w [winfo children $data(cf)] {
		    $w state $stateSpec
		}
	    }
	    return $result
	}

	style {
	    if {$argCount != 1} {
		mwutil::wrongNumArgs "$win $cmd"
	    }

	    return "Plainnotebook.TNotebook"
	}

	tab {
	    if {[catch {$nb index [lindex $args 1]} tabIdx] == 0} {
		set widget [lindex [$nb tabs] $tabIdx]
		set tabPath [widgetToTab $win $widget]
		set class [winfo class $tabPath]
	    }
	    if {[catch {eval [list $nb $cmd] $argList} result] != 0} {
		return -code error $result
	    }

	    if {$argCount == 2} {
		set idx [expr {[lsearch -exact $result "-state"] + 1}]
		set state [lindex $result $idx]
		if {$state eq "disabled" && $class ne "TRadiobutton"} {
		    set state [expr {[$tabPath instate disabled] ?
				     "disabled" : "normal"}]
		    set result [lreplace $result $idx $idx $state]
		}
	    } elseif {$argCount == 3 &&
		      [string match "-sta*" [lindex $args 2]]} {
		set state [$nb tab $tabIdx -state]
		if {$state eq "disabled" && $class ne "TRadiobutton"} {
		    set result [expr {[$tabPath instate disabled] ?
				      "disabled" : "normal"}]
		}
	    } elseif {$argCount > 3} {
		if {$class ne "TRadiobutton"} {
		    foreach {opt val} [lrange $args 2 end] {
			if {[string match "-sta*" $opt]} {
			    set state [mwutil::fullOpt "state" $val \
				       {normal disabled hidden}]
			    if {$state ne "hidden"} {
				set state [expr {$state eq "disabled" ?
						 "disabled" : "!disabled"}]
				$tabPath state $state
			    }
			}
		    }
		}
		configTab $win $tabIdx $tabPath
	    }
	    return $result
	}

	tabpath {
	    if {$argCount != 2} {
		mwutil::wrongNumArgs "$win $cmd tabId"
	    }

	    set tabId [lindex $args 1]
	    set tabIdx [$nb index $tabId]
	    if {$tabIdx < 0 || $tabIdx >= [$nb index end]} {
		return -code error "tab index $tabId out of bounds"
	    }

	    set widget [lindex [$nb tabs] $tabIdx]
	    return [widgetToTab $win $widget]
	}

	titlepath {
	    if {$argCount != 1} {
		mwutil::wrongNumArgs "$win $cmd"
	    }

	    return $win.frm.title
	}
    }
}

#------------------------------------------------------------------------------
# scrollutil::pnb::configTab
#
# Configures the ttk::radiobutton, ttk::button, ttk::label, or ttk::separator
# associated with a given page of the plainnotebook widget win.
#------------------------------------------------------------------------------
proc scrollutil::pnb::configTab {win tabIdx tabPath} {
    set class [winfo class $tabPath]
    foreach {opt val} [$win.nb tab $tabIdx] {
	switch -- $opt {
	    -compound -
	    -image -
	    -text {
		if {$class ne "TSeparator"} {
		    $tabPath configure $opt $val
		}
	    }

	    -underline {
		if {$class eq "TRadiobutton"} {
		    $tabPath configure $opt $val
		}
	    }

	    -state {
		switch $val {
		    hidden { grid remove $tabPath }
		    normal {
			if {$class eq "TRadiobutton"} {
			    $tabPath configure $opt $val
			} else {
			    $win.nb tab $tabIdx -state disabled
			}
			grid $tabPath -sticky we
		    }
		    disabled {
			if {$class eq "TRadiobutton"} {
			    $tabPath configure $opt $val
			}
			grid $tabPath -sticky we
		    }
		}
	    }
	}
    }
}

#------------------------------------------------------------------------------
# scrollutil::pnb::reorderTabs
#
# Lays out the tabs of the plainnotebook widget win using grid, in the order of
# the notebook's pages.
#------------------------------------------------------------------------------
proc scrollutil::pnb::reorderTabs win {
    upvar ::scrollutil::ns${win}::data data
    eval grid forget [grid slaves $data(cf)]

    foreach widget [$win.nb tabs] {
	set tabPath [widgetToTab $win $widget]
	grid $tabPath -sticky we

	if {[$win.nb tab $widget -state] eq "hidden"} {
	    grid remove $tabPath
	}
    }
}

#
# Private procedures used in bindings
# ===================================
#

#------------------------------------------------------------------------------
# scrollutil::pnb::onPlainnotebookMap
#------------------------------------------------------------------------------
proc scrollutil::pnb::onPlainnotebookMap win {
    onNbTabChanged $win.nb 0
    bind $win.nb <<NotebookTabChanged>> { scrollutil::pnb::onNbTabChanged %W 1 }

    after 100 [list scrollutil::pnb::setYScrollIncr $win]
}

#------------------------------------------------------------------------------
# scrollutil::pnb::onNbTabChanged
#------------------------------------------------------------------------------
proc scrollutil::pnb::onNbTabChanged {nb seeTab} {
    set win [winfo parent $nb]
    upvar ::scrollutil::ns${win}::data data

    #
    # Invoke the command specified as the value
    # of the -leavecommand option if appropriate
    #
    set widget [$nb select]
    if {$widget ne "" && $widget ne $data(currentPage) &&
	[lsearch -exact [$nb tabs] $data(currentPage)] >= 0 &&
	[$nb tab $data(currentPage) -state] eq "normal" &&
	[set cmd $data(-leavecommand)] ne "" &&
	![uplevel #0 $cmd [list $win $data(currentPage)]]} {
	#
	# Restore the selection to $data(currentPage)
	#
	bind $nb <<NotebookTabChanged>> {}
	$nb select $data(currentPage)
	set data(selectedPage) $data(currentPage)
	$data(sf) see [widgetToTab $win $data(currentPage)]
	after 1 [list scrollutil::pnb::restoreTabChangedBinding $nb]
	return ""
    }

    set data(selectedPage) $widget
    if {$widget ne ""} {
	#
	# Re-manage the radiobutton corresponding to $widget
	# because it might have been unmanaged via grid remove
	#
	set rb [widgetToTab $win $widget]
	grid $rb -sticky we

	if {$seeTab} {
	    $data(sf) see $rb
	}
    }

    set data(currentPage) $widget
    event generate $win <<NotebookTabChanged>>
}

#------------------------------------------------------------------------------
# scrollutil::pnb::restoreTabChangedBinding
#------------------------------------------------------------------------------
proc scrollutil::pnb::restoreTabChangedBinding nb {
    if {![winfo exists $nb] || [winfo class $nb] ne "TNotebook"} {
	return ""
    }

    bind $nb <<NotebookTabChanged>> { scrollutil::pnb::onNbTabChanged %W 1 }
}

#------------------------------------------------------------------------------
# scrollutil::pnb::setYScrollIncr
#------------------------------------------------------------------------------
proc scrollutil::pnb::setYScrollIncr win {
    if {[destroyed $win]} {
	return ""
    }

    #
    # Set the scrollableframe's yscrollincrement
    #
    upvar ::scrollutil::ns${win}::data data
    set sf $data(sf)
    foreach w [grid slaves $data(cf)] {
	if {[winfo class $w] eq "TRadiobutton"} {
	    set rbHeight [winfo reqheight $w]
	    $sf configure -yscrollincrement $rbHeight
	    break
	}
    }
}

#------------------------------------------------------------------------------
# scrollutil::pnb::onFontChanged
#------------------------------------------------------------------------------
proc scrollutil::pnb::onFontChanged win {
    variable titleFont
    set configList {}
    foreach opt {-family -size -weight -slant -underline -overstrike} {
	set val1 [font actual TkDefaultFont $opt]
	set val2 [font actual $titleFont    $opt]
	switch -- $opt {
	    -family -
	    -weight -
	    -slant	{ set hasChanged [expr {$val1 ne $val2}] }

	    -underline -
	    -overstrike	{ set hasChanged [expr {$val1 != $val2}] }

	    -size {
		if {$val1 == 0} {
		    set val1 9
		}
		set factor [expr {$val1 * 6}]
		set val1 [expr {$factor / 5}]
		if {$factor % 5 > 2} {
		    incr val1
		}
		set hasChanged [expr {$val1 != $val2}]
	    }
	}

	if {$hasChanged} {
	    lappend configList $opt $val1
	}
    }

    if {[llength $configList] != 0} {
	eval font configure [list $titleFont] $configList
    }

    upvar ::scrollutil::ns${win}::data data
    set charWidth [font measure TkDefaultFont -displayof $win "0"]
    $data(sf) configure -xscrollincrement $charWidth
}

#------------------------------------------------------------------------------
# scrollutil::pnb::onThemeChanged
#------------------------------------------------------------------------------
proc scrollutil::pnb::onThemeChanged w {
    if {$w eq "."} {
	::scrollutil::getForegroundColors normalFg disabledFg
	scrollutil_descendImg	      configure -foreground $normalFg
	scrollutil_descendDisabledImg configure -foreground $disabledFg
	if {[lsearch -exact [image names] "scrollutil_ascendImg"] >= 0} {
	    scrollutil_ascendImg      configure -foreground $normalFg
	}

	createDescToolbuttonLayout 
	createClosablePageToolbuttonLayout
	configStyles 
    } else {
	configFrame $w.frm
	after 100 [list scrollutil::pnb::setYScrollIncr $w]
    }
}

#------------------------------------------------------------------------------
# scrollutil::pnb::onMotion
#------------------------------------------------------------------------------
proc scrollutil::pnb::onMotion {tabPath x y} {
    variable user1
    if {[$tabPath identify $x $y] eq "closebtn"} {
	$tabPath instate !disabled {
	    $tabPath state $user1
	}
    } else {
	$tabPath state !$user1
    }
}

#------------------------------------------------------------------------------
# scrollutil::pnb::onButton1
#------------------------------------------------------------------------------
proc scrollutil::pnb::onButton1 {tabPath x y} {
    set win [tabToPlainNb $tabPath]
    ::$win instate disabled {
	return ""
    }

    variable stateArr
    if {[$tabPath identify $x $y] eq "closebtn"} {
	$tabPath instate !disabled {
	    variable user2
	    $tabPath state $user2
	    set stateArr(closebtnPressed) 1
	}
	return -code break ""
    }

    if {[::$win cget -movabletabs]} {
	set stateArr(sourceIdx) [::$win index [tabToWidget $win $tabPath]]
	set stateArr(cursor) [::$win cget -cursor]
    }
}

#------------------------------------------------------------------------------
# scrollutil::pnb::onB1Motion
#------------------------------------------------------------------------------
proc scrollutil::pnb::onB1Motion {tabPath rootX rootY} {
    set cf  [winfo parent $tabPath]
    set sf  [winfo parent [winfo parent $cf]]
    set frm [winfo parent [winfo parent $sf]]
    set win [winfo parent $frm]

    set x [expr {$rootX - [winfo rootx $tabPath]}]
    set y [expr {$rootY - [winfo rooty $tabPath]}]
    variable stateArr
    variable user1
    variable user2
    if {[$tabPath identify $x $y] eq "closebtn" && $stateArr(closebtnPressed)} {
	$tabPath state $user2
	return -code break ""
    } else {
	$tabPath state [list !$user2 !$user1]
    }

    if {[set sourceIdx $stateArr(sourceIdx)] < 0} {
	return ""
    }

    set x [expr {$rootX - [winfo rootx $cf]}]
    set y [expr {$rootY - [winfo rooty $cf]}]
    $sf seerect $x $y $x $y

    set x [expr {$rootX - [winfo rootx $win]}]
    set y [expr {$rootY - [winfo rooty $win]}]
    set tabIdx [::$win index @$x,$y]

    if {$tabIdx < 0 || $tabIdx == $sourceIdx} {
	::$win configure -cursor $stateArr(cursor)
	set stateArr(targetIdx) ""
    } else {
	if {$tabIdx < $sourceIdx} {
	    ::$win configure -cursor sb_up_arrow
	} else {
	    ::$win configure -cursor sb_down_arrow
	}
	set stateArr(targetIdx) $tabIdx
    }
}

#------------------------------------------------------------------------------
# scrollutil::pnb::onLeave
#------------------------------------------------------------------------------
proc scrollutil::pnb::onLeave tabPath {
    variable user1
    $tabPath state !$user1
}

#------------------------------------------------------------------------------
# scrollutil::pnb::onB1Leave
#------------------------------------------------------------------------------
proc scrollutil::pnb::onB1Leave tabPath {
    variable user1
    variable user2
    $tabPath state [list !$user2 !$user1]
}

#------------------------------------------------------------------------------
# scrollutil::pnb::onButtonRel1
#------------------------------------------------------------------------------
proc scrollutil::pnb::onButtonRel1 {tabPath x y} {
    variable user1
    variable user2
    $tabPath state [list !$user2 !$user1]

    set win [tabToPlainNb $tabPath]

    variable stateArr
    variable userDataSupported
    if {[$tabPath identify $x $y] eq "closebtn" && $stateArr(closebtnPressed)} {
	set tabIdx [::$win index [tabToWidget $win $tabPath]]
	set widget [lindex [::$win tabs] $tabIdx]
	if {[::$win forget $tabIdx] && $userDataSupported} {
	    event generate $win <<NotebookTabClosed>> -data $widget
	}

	set stateArr(closebtnPressed) 0
	return -code break ""
    }

    set stateArr(closebtnPressed) 0

    if {$stateArr(targetIdx) >= 0} {
	#
	# Move the tab $sourceIdx of $win to the position $targetIdx
	#
	set sourceIdx $stateArr(sourceIdx)
	set targetIdx $stateArr(targetIdx)
	set widget [lindex [$win.nb tabs] $sourceIdx]
	::$win insert $targetIdx $widget
	::$win configure -cursor $stateArr(cursor)

	if {$userDataSupported} {
	    event generate $win <<NotebookTabMoved>> \
		  -data [list $widget $targetIdx]
	}

	set stateArr(targetIdx) ""
    }

    set stateArr(sourceIdx) ""
}

#------------------------------------------------------------------------------
# scrollutil::pnb::onEscape
#------------------------------------------------------------------------------
proc scrollutil::pnb::onEscape tabPath {
    set win [tabToPlainNb $tabPath]

    variable stateArr
    if {$stateArr(targetIdx) >= 0} {
	::$win configure -cursor $stateArr(cursor)

	set stateArr(targetIdx) ""
    }

    set stateArr(sourceIdx) ""
}

#------------------------------------------------------------------------------
# scrollutil::pnb::onButton3
#------------------------------------------------------------------------------
proc scrollutil::pnb::onButton3 {tabPath rootX rootY} {
    set win [tabToPlainNb $tabPath]
    ::$win instate disabled {
	return ""
    }

    set tabIdx [::$win index [tabToWidget $win $tabPath]]

    set menu $win._m_e_n_u_
    $menu delete 0 end

    event generate $win <<MenuItemsRequested>> -data [list $menu $tabIdx]

    after 100 [list scrollutil::pnb::postMenu $menu $rootX $rootY]
}

#------------------------------------------------------------------------------
# scrollutil::pnb::postMenu
#------------------------------------------------------------------------------
proc scrollutil::pnb::postMenu {menu rootX rootY} {
    #
    # This is an "after 100" callback; check
    # whether the menu exists and has items
    #
    if {![winfo exists $menu] || [winfo class $menu] ne "Menu" ||
	[$menu index end] eq "none"} {
	return ""
    }

    #
    # For awthemes:
    #
    catch {ttk::theme::[mwutil::currentTheme]::setMenuColors $menu}

    tk_popup $menu $rootX $rootY
}

#------------------------------------------------------------------------------
# scrollutil::pnb::onCfConfigure
#------------------------------------------------------------------------------
proc scrollutil::pnb::onCfConfigure {cf width} {
    set sf  [winfo parent [winfo parent $cf]]
    set frm [winfo parent [winfo parent $sf]]
    set win [winfo parent $frm]
    upvar ::scrollutil::ns${win}::data data

    if {$width != $data(cfWidth)} {
	$sf configure -width $width
	set data(cfWidth) $width
    }
}

#
# Private utility procedures
# ==========================
#

#------------------------------------------------------------------------------
# scrollutil::pnb::configFrame
#
# Sets the -borderwidth and -relief options of a given ttk::frame to theme-
# specific values.
#------------------------------------------------------------------------------
proc scrollutil::pnb::configFrame frm {
    switch [mwutil::currentTheme] {
	aqua		{ set bd 1; set rel sunken }

	vista -
	xpnative	{ set bd 1; set rel solid }

	awblack -
	awclearlooks -
	awdark -
	awlight -
	awwinxpblue -
	clam -
	winnative	{ set bd 2; set rel raised }

	default		{ set bd 1; set rel raised }
    }

    $frm configure -borderwidth $bd -relief $rel
}

#------------------------------------------------------------------------------
# scrollutil::pnb::widgetToTab
#
# Returns the path name of the ttk::radiobutton, ttk::button, ttk::label, or
# ttk::separator correspondig to a given page widget of the plainnotebook
# widget win.
#------------------------------------------------------------------------------
proc scrollutil::pnb::widgetToTab {win widget} {
    upvar ::scrollutil::ns${win}::data data
    set widgetName [winfo name $widget]
    foreach w [winfo children $data(cf)] {
	if {([winfo class $w] eq "TRadiobutton" &&
	     [$w cget -value] eq $widget) || [winfo name $w] eq $widgetName} {
	    return $w
	}
    }

    return ""
}

#------------------------------------------------------------------------------
# scrollutil::pnb::tabToWidget
#
# Returns the path name of the page widget correspondig to a given tab (a
# ttk::radiobutton, ttk::button, ttk::label, or ttk::separator) of the
# plainnotebook widget win.
#------------------------------------------------------------------------------
proc scrollutil::pnb::tabToWidget {win tabPath} {
    upvar ::scrollutil::ns${win}::data data
    if {[winfo class $tabPath] eq "TRadiobutton"} {
	return [$tabPath cget -value]
    } else {
	return $win.nb.[winfo name $tabPath]
    }
}

#------------------------------------------------------------------------------
# scrollutil::pnb::tabToPlainNb
#
# Returns the path name of the plainnotebokk widget correspondig to a given tab
# (a ttk::radiobutton, ttk::button, ttk::label, or ttk::separator).
#------------------------------------------------------------------------------
proc scrollutil::pnb::tabToPlainNb tabPath {
    set cf  [winfo parent $tabPath]
    set sf  [winfo parent [winfo parent $cf]]
    set frm [winfo parent [winfo parent $sf]]
    return  [winfo parent $frm]
}

#------------------------------------------------------------------------------
# scrollutil::pnb::destroyed
#
# Checks whether the plainnotebook widget win got destroyed by some custom
# script.
#------------------------------------------------------------------------------
proc scrollutil::pnb::destroyed win {
    #
    # A bit safer than using "winfo exists", because the widget might have
    # been destroyed and its name reused for a new non-plainnotebook widget:
    #
    return [expr {![array exists ::scrollutil::ns${win}::data] ||
	    [winfo class $win] ne "Plainnotebook"}]
}
