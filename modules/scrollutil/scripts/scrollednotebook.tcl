#==============================================================================
# Contains the implementation of the scrollednotebook widget.
#
# Structure of the module:
#   - Namespace initialization
#   - Private procedure creating the default bindings
#   - Public procedures
#   - Private configuration procedures
#   - Private procedures implementing the scrollednotebook widget command
#   - Private callback procedure
#   - Private procedures used in bindings
#   - Private utility procedures
#
# Copyright (c) 2021  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require Tk 8.4

#
# Namespace initialization
# ========================
#

namespace eval scrollutil::snb {
    #
    # The array configSpecs is used to handle configuration options.  The names
    # of its elements are the configuration options for the Scrollednotebook
    # class.  The value of an array element is either an alias name or a list
    # containing the database name and class as well as an indicator specifying
    # the widget to which the option applies: f stands for the outer frame and
    # n for the notebook widget.
    #
    #	Command-Line Name	{Database Name	Database Class	W}
    #	----------------------------------------------------------
    #
    variable configSpecs
    array set configSpecs {
	-cursor			{cursor		Cursor		f}
	-height			{height		Height		f}
	-padding		{padding	Padding		n}
	-style			{style		Style		n}
	-takefocus		{takeFocus	TakeFocus	f}
	-width			{width		Width		f}
    }

    #
    # Extend the elements of the array configSpecs
    #
    lappend configSpecs(-cursor)	""
    lappend configSpecs(-height)	0
    lappend configSpecs(-padding)	""
    lappend configSpecs(-style)		"TNotebook"
    lappend configSpecs(-takefocus)	"ttk::takefocus"
    lappend configSpecs(-width)		10c

    variable configOpts [lsort [array names configSpecs]]

    #
    # Use a list to facilitate the handling of command options
    #
    variable cmdOpts [list add cget configure forget hide identify index \
		      insert instate see select state style tab tabs]
    if {$::tk_version < 8.7 ||
	[package vcompare $::tk_patchLevel "8.7a4"] < 0} {
	set idx [lsearch -exact $cmdOpts "style"]
	set cmdOpts [lreplace $cmdOpts $idx $idx]
	unset idx
    }

    #
    # Array variable used in binding scripts for the class TNotebook:
    #
    variable state
    set state(closeIdx)  ""
    set state(sourceIdx) ""
    set state(targetIdx) ""

    variable userDataSupported [expr {$::tk_version >= 8.5 &&
	     [package vcompare $::tk_patchLevel "8.5a2"] >= 0}]

    #
    # Create the closetab element
    #
    proc createClosetabElement {} {
	switch $::scrollutil::scalingpct {
	    100 {
		set closetabData "
#define close100_width 16
#define close100_height 15
static unsigned char close100_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x0c, 0x60, 0x06,
   0xc0, 0x03, 0x80, 0x01, 0xc0, 0x03, 0x60, 0x06, 0x30, 0x0c, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }

	    125 {
		set closetabData "
#define close125_width 20
#define close125_height 19
static unsigned char close125_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x60, 0x60, 0x00, 0xc0, 0x30, 0x00, 0x80, 0x19, 0x00,
   0x00, 0x0f, 0x00, 0x00, 0x06, 0x00, 0x00, 0x0f, 0x00, 0x80, 0x19, 0x00,
   0xc0, 0x30, 0x00, 0x60, 0x60, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }

	    150 {
		set closetabData "
#define close150_width 24
#define close150_height 23
static unsigned char close150_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x00, 0x03, 0x80, 0x81, 0x01,
   0x00, 0xc3, 0x00, 0x00, 0x66, 0x00, 0x00, 0x3c, 0x00, 0x00, 0x18, 0x00,
   0x00, 0x3c, 0x00, 0x00, 0x66, 0x00, 0x00, 0xc3, 0x00, 0x80, 0x81, 0x01,
   0xc0, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }

	    175 {
		set closetabData "
#define close175_width 28
#define close175_height 28
static unsigned char close175_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x18, 0x00, 0x80, 0x03, 0x1c, 0x00,
   0x00, 0x07, 0x0e, 0x00, 0x00, 0x0e, 0x07, 0x00, 0x00, 0x9c, 0x03, 0x00,
   0x00, 0xf8, 0x01, 0x00, 0x00, 0xf0, 0x00, 0x00, 0x00, 0xf0, 0x00, 0x00,
   0x00, 0xf8, 0x01, 0x00, 0x00, 0x9c, 0x03, 0x00, 0x00, 0x0e, 0x07, 0x00,
   0x00, 0x07, 0x0e, 0x00, 0x80, 0x03, 0x1c, 0x00, 0x80, 0x01, 0x18, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00};
"
	    }

	    200 {
		set closetabData "
#define close200_2_width 32
#define close200_2_height 32
static unsigned char close200_2_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0xc0, 0x00,
   0x00, 0x07, 0xe0, 0x00, 0x00, 0x0e, 0x70, 0x00, 0x00, 0x1c, 0x38, 0x00,
   0x00, 0x38, 0x1c, 0x00, 0x00, 0x70, 0x0e, 0x00, 0x00, 0xe0, 0x07, 0x00,
   0x00, 0xc0, 0x03, 0x00, 0x00, 0xc0, 0x03, 0x00, 0x00, 0xe0, 0x07, 0x00,
   0x00, 0x70, 0x0e, 0x00, 0x00, 0x38, 0x1c, 0x00, 0x00, 0x1c, 0x38, 0x00,
   0x00, 0x0e, 0x70, 0x00, 0x00, 0x07, 0xe0, 0x00, 0x00, 0x03, 0xc0, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }
	}

	if {[set normalFg [ttk::style lookup . -foreground]] eq ""} {
	    set normalFg black
	}

	array set arr [ttk::style map . -foreground]
	if {[info exists arr(disabled)]} {
	    set disabledFg $arr(disabled)
	} else {
	    set disabledFg $normalFg
	}

	image create bitmap scrollutil_closetabImg \
	    -data $closetabData -foreground $normalFg
	image create bitmap scrollutil_closetabDisabledImg \
	    -data $closetabData -foreground $disabledFg
	image create bitmap scrollutil_closetabHoverImg \
	    -data $closetabData -foreground #ffffff -background #ff6666
	image create bitmap scrollutil_closetabPressedImg \
	    -data $closetabData -foreground #ffffff -background #e60000

	#
	# Instead of the state "alternate" below it would be
	# more natural to use "hover", but the latter was not
	# supported by Tk versions earler than 8.6b1 or 8.5.9.
	#
	set width  [expr {[image width scrollutil_closetabImg] + 4}]
	set sticky [expr {[tk windowingsystem] eq "aqua" ? "w" : "e"}]
	ttk::style element create closetab image [list scrollutil_closetabImg \
		{active pressed}	     scrollutil_closetabPressedImg \
		{active alternate !disabled} scrollutil_closetabHoverImg \
		disabled		     scrollutil_closetabDisabledImg] \
	    -width $width -sticky $sticky
    }
    createClosetabElement 
}

#
# Private procedure creating the default bindings
# ===============================================
#

#------------------------------------------------------------------------------
# scrollutil::snb::createBindings
#
# Creates the default bindings for the binding tags Scrollednotebook and
# ScrollutilMain, and extends the default bindings for TNotebook.
#------------------------------------------------------------------------------
proc scrollutil::snb::createBindings {} {
    bind Scrollednotebook <KeyPress> continue
    bind Scrollednotebook <FocusIn> {
	if {[focus -lastfor %W] eq "%W"} {
            focus [%W.sf contentframe].nb
        }
    }
    bind Scrollednotebook <Map> {
	after 100 [list scrollutil::snb::onScrollednotebookMap %W]
    }
    bind Scrollednotebook <Destroy> {
	namespace delete scrollutil::ns%W
	catch {rename %W ""}
    }
    bind Scrollednotebook <<ThemeChanged>> {
	scrollutil::snb::onThemeChanged %W
    }

    bindtags . [linsert [bindtags .] 1 ScrollutilMain]
    bind ScrollutilMain <<ThemeChanged>> { scrollutil::snb::onThemeChanged %W }

    #
    # Add support for moving and closing the ttk::notebook tabs with the mouse
    #
    bind TNotebook <Motion>	     { scrollutil::snb::onMotion      %W %x %y }
    bind TNotebook <Button-1>	     { scrollutil::snb::onButton1     %W %x %y }
    bind TNotebook <B1-Motion>	     { scrollutil::snb::onB1Motion    %W %x %y }
    bind TNotebook <ButtonRelease-1> { scrollutil::snb::onBtnRelease1 %W %x %y }
    bind TNotebook <Escape>	     { scrollutil::snb::onEscape %W }

    #
    # Define the virtual event <<Button3>> and create a binding for it
    #
    event add <<Button3>> <Button-3>
    if {[tk windowingsystem] eq "aqua"} {
	event add <<Button3>> <Control-Button-1>
    }
    variable userDataSupported
    if {$userDataSupported} {
	bind TNotebook <<Button3>> { scrollutil::snb::onButton3 %W %x %y %X %Y }
    }

    #
    # Implement the navigation between the ttk::notebook tabs via the mouse
    # wheel (TIP 591).  Use our own bindMouseWheel procedure rather than
    # ttk::bindMouseWheel, which was not present in tile before Dec. 2008.
    #
    bindMouseWheel TNotebook \
	{%W instate disabled continue; ttk::notebook::CycleTab %W}
}

#
# Public procedures
# =================
#

#------------------------------------------------------------------------------
# scrollutil::scrollednotebook
#
# Creates a new scrollednotebook widget whose name is specified as the first
# command-line argument, and configures it according to the options and their
# values given on the command line.  Returns the name of the newly created
# widget.
#------------------------------------------------------------------------------
proc scrollutil::scrollednotebook args {
    variable usingTile
    if {!$usingTile} {
	return -code error "package scrollutil_tile is not loaded"
    }

    variable snb::configSpecs
    variable snb::configOpts

    if {[llength $args] == 0} {
	mwutil::wrongNumArgs "scrollednotebook pathName ?options?"
    }

    #
    # Create a frame of the class Scrollednotebook
    #
    set win [lindex $args 0]
    if {[catch {
	ttk::frame $win -class Scrollednotebook -borderwidth 0 -relief flat \
			-height 0 -width 0 -padding 0
    } result] != 0} {
	return -code error $result
    }

    #
    # Create a namespace within the current one to hold the data of the widget
    #
    namespace eval ns$win {
	#
	# The folowing array holds various data for this widget
	#
	variable data

	#
	# The folowing array holds the horizontal paddings of the panes
	#
	variable xPadArr
    }

    #
    # Initialize some components of data
    #
    upvar ::scrollutil::ns${win}::data data
    foreach opt $configOpts {
	set data($opt) [lindex $configSpecs($opt) 3]
    }

    #
    # Create a scrollableframe and a ttk::notebook in its content frame
    #
    set sf [scrollableframe $win.sf -borderwidth 0 -contentheight 0 \
	    -contentwidth 0 -relief flat -takefocus 0 -xscrollincrement 1 \
	    -yscrollcommand "" -yscrollincrement 1]
    pack $sf -expand 1 -fill both
    set cf [$sf contentframe]
    set nb [ttk::notebook $cf.nb -class TNotebook -height 0 -width 0]
    pack $nb -expand 1 -fill both

    set data(sf) $sf
    set data(nb) $nb

    #
    # Configure the widget according to the command-line
    # arguments and to the available database options
    #
    if {[catch {
	mwutil::configureWidget $win configSpecs scrollutil::snb::doConfig \
				scrollutil::snb::doCget [lrange $args 1 end] 1
    } result] != 0} {
	destroy $win
	return -code error $result
    }

    #
    # Move the original widget command into the namespace snb within the current
    # one and create an alias of the original name for a new widget procedure
    #
    rename ::$win snb::$win
    interp alias {} ::$win {} scrollutil::snb::scrollednotebookWidgetCmd $win

    menu $win._m_e_n_u_ -tearoff no

    #
    # Extend the library procedure ::ttk::notebook::ActivateTab
    #
    if {[llength [info commands ActivateTab]] == 0} {
	rename ::ttk::notebook::ActivateTab ActivateTab

	proc ::ttk::notebook::ActivateTab {nb tabIdx} {
	    if {[set snb [::scrollutil::snb::containingSnb $nb]] eq ""} {
		::scrollutil::ActivateTab $nb $tabIdx
	    } else {
		upvar ::scrollutil::ns${snb}::data data
		set data(tabIdx) $tabIdx
		if {![info exists data(activateId)]} {
		    set data(activateId) \
			[after 100 [list scrollutil::snb::activateTab $snb]]
		}
	    }
	}
    }

    return $win
}

#------------------------------------------------------------------------------
# scrollutil::addclosetab
#
# Adds the closetab element to the tabs of a given ttk::notebook style.
#------------------------------------------------------------------------------
proc scrollutil::addclosetab nbStyle {
    set tabStyle $nbStyle.Tab
    set tabLayout [ttk::style layout $tabStyle]
    if {[string first "Notebook.closetab" $tabLayout] >= 0} {  ;# nothing to do
	return 1
    }

    if {[tk windowingsystem] eq "aqua"} {
	set newStr "Notebook.closetab -side left -sticky {}\
		    Notebook.label -side right -sticky {}"
    } else {
	set newStr "Notebook.label -side left -sticky {}\
		    Notebook.closetab -side right -sticky {}"
    }

    set oldStr "Notebook.label -side top -sticky {}"		;# most themes
    if {[set first [string first $oldStr $tabLayout]] >= 0} {
	set last [expr {$first + [string length $oldStr] - 1}]
	ttk::style layout $tabStyle \
	    [string replace $tabLayout $first $last $newStr]
	return 1
    }

    set oldStr "Notebook.label -sticky nswe"	;# "classic" and "aqua" themes
    if {[set first [string first $oldStr $tabLayout]] >= 0} {
	set last [expr {$first + [string length $oldStr] - 1}]
	ttk::style layout $tabStyle \
	    [string replace $tabLayout $first $last $newStr]
	return 1
    }

    return 0
}

#------------------------------------------------------------------------------
# scrollutil::removeclosetab
#
# Removes the closetab element from the tabs of a given ttk::notebook style.
#------------------------------------------------------------------------------
proc scrollutil::removeclosetab nbStyle {
    set tabStyle $nbStyle.Tab
    set tabLayout [ttk::style layout $tabStyle]
    if {[string first "Notebook.closetab" $tabLayout] < 0} {   ;# nothing to do
	return 1
    }

    set curTheme [mwutil::currentTheme]
    if {$curTheme eq "aqua" || $curTheme eq "classic"} {
	set newStr "Notebook.label -sticky nswe"
    } else {
	set newStr "Notebook.label -side top -sticky {}"
    }

    set oldStr "Notebook.label -side left -sticky {}\
		Notebook.closetab -side right -sticky {}"	;# on x11/win32
    if {[set first [string first $oldStr $tabLayout]] >= 0} {
	set last [expr {$first + [string length $oldStr] - 1}]
	ttk::style layout $tabStyle \
	    [string replace $tabLayout $first $last $newStr]
	return 1
    }

    set oldStr "Notebook.closetab -side left -sticky {}\
		Notebook.label -side right -sticky {}"		;# on aqua
    if {[set first [string first $oldStr $tabLayout]] >= 0} {
	set last [expr {$first + [string length $oldStr] - 1}]
	ttk::style layout $tabStyle \
	    [string replace $tabLayout $first $last $newStr]
	return 1
    }

    return 0
}

#
# Private configuration procedures
# ================================
#

#------------------------------------------------------------------------------
# scrollutil::snb::doConfig
#
# Applies the value val of the configuration option opt to the scrollednotebook
# widget win.
#------------------------------------------------------------------------------
proc scrollutil::snb::doConfig {win opt val} {
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
		    $data(sf) configure $opt $val
		    $data(nb) configure $opt $val
		}
		-height {
		    if {$data($opt) == 0} {
			$data(sf) configure -fitcontentheight 1 \
			    $opt [winfo reqheight $data(nb)]
		    } else {
			$data(sf) configure -fitcontentheight 0 $opt $val
		    }
		}
		-width {
		    if {$data($opt) == 0} {
			$data(sf) configure -fitcontentwidth 1 \
			    $opt [winfo reqwidth $data(nb)]
		    } else {
			$data(sf) configure -fitcontentwidth 0 $opt $val
		    }
		}
	    }
	}

	n {
	    #
	    # Apply the value to the notebook and save the
	    # properly formatted value of val in data($opt)
	    #
	    $data(nb) configure $opt $val
	    set data($opt) [$data(nb) cget $opt]

	    switch -- $opt {
		-style {
		    if {$val eq ""} {
			set val TNotebook
		    }
		    set tabPos [ttk::style lookup $val -tabposition]
		    if {$tabPos eq ""} {
			set tabPos nw
		    }
		    set tabSide [string index $tabPos 0]
		    if {$tabSide ne "n" && $tabSide ne "s"} {
			return -code error "only horizontal tab layout is\
					    supported"
		    }
		}
	    }
	}
    }
}

#------------------------------------------------------------------------------
# scrollutil::snb::doCget
#
# Returns the value of the configuration option opt for the scrollednotebook
# widget win.
#------------------------------------------------------------------------------
proc scrollutil::snb::doCget {win opt} {
    upvar ::scrollutil::ns${win}::data data
    return $data($opt)
}

#
# Private procedures implementing the scrollednotebook widget command
# ===================================================================
#

#------------------------------------------------------------------------------
# scrollutil::snb::scrollednotebookWidgetCmd
#
# Processes the Tcl command corresponding to a scrollednotebook widget.
#------------------------------------------------------------------------------
proc scrollutil::snb::scrollednotebookWidgetCmd {win args} {
    set argCount [llength $args]
    if {$argCount == 0} {
	mwutil::wrongNumArgs "$win option ?arg arg ...?"
    }

    upvar ::scrollutil::ns${win}::data data

    variable cmdOpts
    set cmd [mwutil::fullOpt "option" [lindex $args 0] $cmdOpts]
    switch $cmd {
	add {
	    set widget [lindex $args 1]
	    set isNew [expr {[lsearch -exact [$data(nb) tabs] $widget] < 0}]
	    eval [list $data(nb) $cmd] [lrange $args 1 end]
	    if {$isNew} {
		saveXPad $win $widget
		updateNbWidthDelayed $win
	    }
	    return ""
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

	configure {
	    variable configSpecs
	    return [mwutil::configureSubCmd $win configSpecs \
		    scrollutil::snb::doConfig scrollutil::snb::doCget \
		    [lrange $args 1 end]]
	}

	forget {
	    if {[catch {$data(nb) index [lindex $args 1]} tabIdx] == 0 &&
		$tabIdx < [$data(nb) index end]} {
		set widget [lindex [$data(nb) tabs] $tabIdx]
	    }
	    eval [list $data(nb) $cmd] [lrange $args 1 end]
	    forgetXPad $win $widget
	    updateNbWidthDelayed $win
	    return ""
	}

	hide -
	identify -
	index -
	instate -
	state -
	style -
	tabs { return [eval [list $data(nb) $cmd] [lrange $args 1 end]] }

	insert {
	    set widget [lindex $args 2]
	    set isNew [expr {[lsearch -exact [$data(nb) tabs] $widget] < 0}]
	    eval [list $data(nb) $cmd] [lrange $args 1 end]
	    if {$isNew} {
		saveXPad $win $widget
		updateNbWidthDelayed $win
	    } elseif {[::$win index $widget] == [::$win index current]} {
		::$win see $widget
	    }
	    return ""
	}

	see {
	    after idle [list scrollutil::snb::seeSubCmd \
			$win [lrange $args 1 end]]
	    return ""
	}

	select {
	    set result [eval [list $data(nb) $cmd] [lrange $args 1 end]]
	    if {$argCount > 1} {
		::$win see [lindex $args 1]
	    }
	    return $result
	}

	tab {
	    set result [eval [list $data(nb) $cmd] [lrange $args 1 end]]
	    if {$argCount > 3 && [lsearch -exact $args "-padding"] >= 2} {
		if {[set tabIdx [$data(nb) index [lindex $args 1]]] >= 0} {
		    set widget [lindex [$data(nb) tabs] $tabIdx]
		    saveXPad $win $widget
		    updateNbWidthDelayed $win
		}
	    }
	    return $result
	}
    }
}

#------------------------------------------------------------------------------
# scrollutil::snb::seeSubCmd
#
# Processes the scrollednotebook see subcommmand.
#------------------------------------------------------------------------------
proc scrollutil::snb::seeSubCmd {win argList} {
    if {[llength $argList] != 1} {
	mwutil::wrongNumArgs "$win see tabId"
    }

    if {[destroyed $win]} {
	return ""
    }

    upvar ::scrollutil::ns${win}::data data
    set nb $data(nb)
    if {[set height [winfo height $nb]] < 10 ||
	[set tabIdx [$nb index [lindex $argList 0]]] < 0 ||
	[$nb tab $tabIdx -state] eq "hidden"} {
	return ""
    }

    if {$tabIdx == [firstNonHiddenTab $nb]} {
	$data(sf) xview moveto 0
	return ""
    } elseif {$tabIdx == [lastNonHiddenTab $nb]} {
	$data(sf) xview moveto 1
	return ""
    }

    #
    # Get the greatest/least y within the tabs
    #
    set x [expr {[winfo width $nb] / 2}]
    if {[set style [$nb cget -style]] eq ""} {
	set style TNotebook
    }
    if {[set tabPos [ttk::style lookup $style -tabposition]] eq ""} {
	set tabPos nw
    }
    set tabSide [string index $tabPos 0]
    if {$tabSide eq "n"} {
	set y $height
	while {$y >= 0 && [$nb index @$x,$y] < 0} {
	    incr y -20
	}
	incr y 20
	while {[$nb index @$x,$y] < 0} {
	    incr y -1
	}
	incr y -9
    } else {
	set y 0
	while {$y < $height && [$nb index @$x,$y] < 0} {
	    incr y 20
	}
	incr y -20
	while {[$nb index @$x,$y] < 0} {
	    incr y
	}
	incr y 9
    }

    #
    # Bring the tab $tab of $nb into view
    #
    set x1 0
    while {[set idx [$nb index @$x1,$y]] < 0 || $idx < $tabIdx} {
	incr x1 100
    }
    incr x1 -100
    while {[$nb index @$x1,$y] < $tabIdx} {
	incr x1
    }
    set x2 $x1
    while {[$nb index @$x2,$y] == $tabIdx} {
	incr x2
    }
    $data(sf) seerect $x1 0 $x2 0

    return ""
}

#
# Private callback procedure
# ==========================
#

#------------------------------------------------------------------------------
# scrollutil::snb::adjustXPad
#
# This procedure is the value of the -xscrollcommand option of the
# scrollableframe contained in the scrollednotebook widget win.  It adjusts the
# horizontal padding of the current pane according to the xview values of the
# scrollableframe widget.
#------------------------------------------------------------------------------
proc scrollutil::snb::adjustXPad {win first last} {
    upvar ::scrollutil::ns${win}::data data

    if {[set tabIdx [$data(nb) index current]] < 0} {
	return ""
    }

    set cfWidth [winfo width [$data(sf) contentframe]]
    foreach {left right} [origXPad $win $tabIdx] {}
    incr left  [expr {int($cfWidth * $first + 0.5)}]
    incr right [expr {$cfWidth - int($cfWidth * $last + 0.5)}]

    foreach {l top r bottom} \
	    [normalizePadding $win [$data(nb) tab $tabIdx -padding]] {}

    $data(nb) tab $tabIdx -padding [list $left $top $right $bottom]
}

#
# Private procedures used in bindings
# ===================================
#

#------------------------------------------------------------------------------
# scrollutil::snb::onScrollednotebookMap
#------------------------------------------------------------------------------
proc scrollutil::snb::onScrollednotebookMap win {
    if {[destroyed $win]} {
	return ""
    }

    upvar ::scrollutil::ns${win}::data data

    if {$data(-height) == 0} {
	$data(sf) configure -height [winfo reqheight $data(nb)]
    }
    if {$data(-width) == 0} {
	$data(sf) configure -width [winfo reqwidth $data(nb)]
    }
    $data(sf) configure -xscrollcommand [list scrollutil::snb::adjustXPad $win]

    $data(nb) configure -width [maxPaneWidth $win]
    onNbTabChanged $data(nb)   ;# adjusts the current pane's horizontal padding

    bind $data(nb) <<NotebookTabChanged>> { scrollutil::snb::onNbTabChanged %W }
    bind $data(nb) <Configure>		  { scrollutil::snb::onNbConfigure %W }
    bind $data(sf) <Configure>		  { scrollutil::snb::onSfConfigure %W }
}

#------------------------------------------------------------------------------
# scrollutil::snb::onThemeChanged
#------------------------------------------------------------------------------
proc scrollutil::snb::onThemeChanged w {
    if {$w eq "."} {
	if {[set normalFg [ttk::style lookup . -foreground]] eq ""} {
	    set normalFg black
	}

	array set arr [ttk::style map . -foreground]
	if {[info exists arr(disabled)]} {
	    set disabledFg $arr(disabled)
	} else {
	    set disabledFg $normalFg
	}

	scrollutil_closetabImg         configure -foreground $normalFg
	scrollutil_closetabDisabledImg configure -foreground $disabledFg
    } else {
	updateNbWidthDelayed $w
    }
}

#------------------------------------------------------------------------------
# scrollutil::snb::onNbTabChanged
#------------------------------------------------------------------------------
proc scrollutil::snb::onNbTabChanged {nb {genEvent 1}} {
    set snb [containingSnb $nb]
    foreach {first last} [$snb.sf xview] {}
    adjustXPad $snb $first $last

    if {$genEvent} {
	event generate $snb <<NotebookTabChanged>>
    }
}

#------------------------------------------------------------------------------
# scrollutil::snb::onNbConfigure
#------------------------------------------------------------------------------
proc scrollutil::snb::onNbConfigure nb {
    set snb [containingSnb $nb]
    ::$snb see current
}

#------------------------------------------------------------------------------
# scrollutil::snb::onSfConfigure
#------------------------------------------------------------------------------
proc scrollutil::snb::onSfConfigure sf {
    set snb [winfo parent $sf]
    ::$snb see current
}

#------------------------------------------------------------------------------
# scrollutil::snb::onMotion
#------------------------------------------------------------------------------
proc scrollutil::snb::onMotion {nb x y} {
    if {[$nb identify element $x $y] eq "closetab"} {
	$nb state alternate
    } else {
	$nb state !alternate
    }
}

#------------------------------------------------------------------------------
# scrollutil::snb::onButton1
#------------------------------------------------------------------------------
proc scrollutil::snb::onButton1 {nb x y} {
    if {[$nb instate disabled] || [set tabIdx [$nb index @$x,$y]] < 0} {
	return ""
    }

    variable state
    if {[$nb identify element $x $y] eq "closetab"} {
	if {[$nb tab $tabIdx -state] ne "disabled"} {
	    $nb state pressed
	    set state(closeIdx) $tabIdx
	}
	return ""
    }

    ::ttk::notebook::ActivateTab $nb $tabIdx

    set state(sourceIdx) $tabIdx
    set state(cursor) [$nb cget -cursor]
    set state(focus) [focus -displayof $nb]
    focus $nb

    if {[set style [$nb cget -style]] eq ""} {
	set style TNotebook
    }
    set tabSide [string index [ttk::style lookup $style -tabposition] 0]
    switch -- $tabSide {
	n {
	    set state(orient) h
	    while {[$nb index @$x,$y] >= 0} { incr y }
	    set state(y) [incr y -10]
	}
	s {
	    set state(orient) h
	    while {[$nb index @$x,$y] >= 0} { incr y -1 }
	    set state(y) [incr y 10]
	}
	w {
	    set state(orient) v
	    while {[$nb index @$x,$y] >= 0} { incr x }
	    set state(x) [incr x -10]
	}
	e {
	    set state(orient) v
	    while {[$nb index @$x,$y] >= 0} { incr x -1 }
	    set state(x) [incr x 10]
	}
	default {
	    set state(orient) h
	    while {[$nb index @$x,$y] >= 0} { incr y }
	    set state(y) [incr y -10]
	}
    }
}

#------------------------------------------------------------------------------
# scrollutil::snb::onB1Motion
#------------------------------------------------------------------------------
proc scrollutil::snb::onB1Motion {nb x y} {
    variable state
    set tabIdx [$nb index @$x,$y]

    if {[$nb identify element $x $y] eq "closetab" &&
	$tabIdx == $state(closeIdx)} {
	$nb state pressed
    } else {
	$nb state !pressed
	$nb state !alternate
    }

    if {[set sourceIdx $state(sourceIdx)] < 0} {
	return ""
    }

    if {$state(orient) eq "h"} {
	set y $state(y)
    } else {
	set x $state(x)
    }

    if {[set snb [containingSnb $nb]] ne ""} {
	$snb.sf seerect $x $y $x $y
    }

    if {$tabIdx < 0 || $tabIdx == $sourceIdx} {
	$nb configure -cursor $state(cursor)
	set state(targetIdx) ""
    } else {
	if {$state(orient) eq "h"} {
	    if {$tabIdx < $sourceIdx} {
		$nb configure -cursor sb_left_arrow
	    } else {
		$nb configure -cursor sb_right_arrow
	    }
	} else {
	    if {$tabIdx < $sourceIdx} {
		$nb configure -cursor sb_up_arrow
	    } else {
		$nb configure -cursor sb_down_arrow
	    }
	}
	set state(targetIdx) $tabIdx
    }
}

#------------------------------------------------------------------------------
# scrollutil::snb::onBtnRelease1
#------------------------------------------------------------------------------
proc scrollutil::snb::onBtnRelease1 {nb x y} {
    variable state
    $nb state !pressed

    variable userDataSupported
    set snb [containingSnb $nb]
    set w [expr {$snb eq "" ? $nb : $snb}]

    if {[$nb identify element $x $y] eq "closetab" &&
	[set tabIdx [$nb index @$x,$y]] == $state(closeIdx)} {
	set widget [lindex [$nb tabs] $tabIdx]
	$nb forget $tabIdx

	if {$userDataSupported} {
	    event generate $w <<NotebookTabClosed>> -data $widget
	}

	set state(closeIdx) ""
	return ""
    }

    set state(closeIdx) ""

    if {$state(targetIdx) >= 0} {
	#
	# Move the tab $sourceIdx of $nb to the position $targetIdx
	#
	set sourceIdx $state(sourceIdx)
	set targetIdx $state(targetIdx)
	set widget [lindex [$nb tabs] $sourceIdx]
	$nb insert $targetIdx $widget
	$nb configure -cursor $state(cursor)
	focus $state(focus)

	if {$snb ne ""} {
	    ::$snb see $targetIdx
	}

	if {$userDataSupported} {
	    event generate $w <<NotebookTabMoved>> \
		  -data [list $widget $targetIdx]
	}

	set state(targetIdx) ""
    }

    set state(sourceIdx) ""
}

#------------------------------------------------------------------------------
# scrollutil::snb::onEscape
#------------------------------------------------------------------------------
proc scrollutil::snb::onEscape nb {
    variable state
    if {$state(targetIdx) >= 0} {
	$nb configure -cursor $state(cursor)
	focus $state(focus)

	set state(targetIdx) ""
    }

    set state(sourceIdx) ""
}

#------------------------------------------------------------------------------
# scrollutil::snb::onButton3
#------------------------------------------------------------------------------
proc scrollutil::snb::onButton3 {nb x y rootX rootY} {
    if {[$nb instate disabled] || [set tabIdx [$nb index @$x,$y]] < 0} {
	return ""
    }

    if {[set snb [containingSnb $nb]] eq ""} {
	for {set n 0} {1} {incr n} {
	    set menu $nb._m_e_n_u_${n}_
	    if {[winfo exists $menu]} {
		if {[winfo class $menu] eq "Menu"} {
		    break
		}
	    } else {
		menu $menu -tearoff no
		break
	    }
	}
    } else {
	set menu $snb._m_e_n_u_
    }
    $menu delete 0 end

    set w [expr {$snb eq "" ? $nb : $snb}]
    event generate $w <<MenuItemsRequested>> -data [list $menu $tabIdx]

    after 100 [list scrollutil::snb::postMenu $menu $rootX $rootY]
}

#------------------------------------------------------------------------------
# scrollutil::snb::postMenu
#------------------------------------------------------------------------------
proc scrollutil::snb::postMenu {menu rootX rootY} {
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
# scrollutil::snb::bindMouseWheel
#------------------------------------------------------------------------------
proc scrollutil::snb::bindMouseWheel {bindTag cmd} {
    set winSys [tk windowingsystem]
    if {$::tk_version >= 8.7 &&
	[package vcompare $::tk_patchLevel "8.7a4"] >= 0} {
	#
	# Uniform mouse wheel support
	#
	bind $bindTag <MouseWheel>	  "$cmd %D -120.0"
	bind $bindTag <Option-MouseWheel> "$cmd %D -12.0"
    } elseif {$winSys eq "aqua"} {
	bind $bindTag <MouseWheel>	  "$cmd \[expr {-%D}\]"
	bind $bindTag <Option-MouseWheel> "$cmd \[expr {-10 * %D}\]"
    } else {
	bind $bindTag <MouseWheel> \
	    "$cmd \[expr {%D >= 0 ? -%D / 120 : (-%D + 119) / 120}\]"

	if {$winSys eq "x11"} {
	    bind $bindTag <Button-4>	  "$cmd -1"
	    bind $bindTag <Button-5>	  "$cmd +1"

	    if {$::tk_patchLevel eq "8.7a3"} {
		bind $bindTag <Button-6>  "$cmd -1"
		bind $bindTag <Button-7>  "$cmd +1"
	    }
	}
    }
}

#
# Private utility procedures
# ==========================
#

#------------------------------------------------------------------------------
# scrollutil::snb::containingSnb
#
# Returns the scrollednotebook containing a given ttk::notebook widget.
#------------------------------------------------------------------------------
proc scrollutil::snb::containingSnb nb {
    set par [winfo parent $nb]
    while {[winfo exists $par]} {
	if {[winfo class $par] eq "Scrollednotebook" &&
	    $nb eq "[$par.sf contentframe].nb"} {
	    return $par
	} else {
	    set par [winfo parent $par]
	}
    }

    return ""
}

#------------------------------------------------------------------------------
# scrollutil::snb::firstNonHiddenTab
#
# Returns the the index of the first nonhidden tab of a given ttk::notebook
# widget.
#------------------------------------------------------------------------------
proc scrollutil::snb::firstNonHiddenTab nb {
    set tabCount [$nb index end]
    for {set tabIdx 0} {$tabIdx < $tabCount} {incr tabIdx} {
	if {[$nb tab $tabIdx -state] ne "hidden"} {
	    return $tabIdx
	}
    }

    return ""
}

#------------------------------------------------------------------------------
# scrollutil::snb::lastNonHiddenTab
#
# Returns the the index of the last nonhidden tab of a given ttk::notebook
# widget.
#------------------------------------------------------------------------------
proc scrollutil::snb::lastNonHiddenTab nb {
    set lastTabIdx [expr {[$nb index end] - 1}]
    for {set tabIdx $lastTabIdx} {$tabIdx > 0} {incr tabIdx -1} {
	if {[$nb tab $tabIdx -state] ne "hidden"} {
	    return $tabIdx
	}
    }

    return ""
}

#------------------------------------------------------------------------------
# scrollutil::snb::activateTab
#
# Activates the tab data(tabIdx) of the scrollednotebook widget win.
#------------------------------------------------------------------------------
proc scrollutil::snb::activateTab win {
    if {[destroyed $win]} {
	return ""
    }

    upvar ::scrollutil::ns${win}::data data
    unset data(activateId)

    set tabIdx $data(tabIdx)
    ::scrollutil::ActivateTab $data(nb) $tabIdx
    ::$win see $tabIdx
}

#------------------------------------------------------------------------------
# scrollutil::snb::normalizePadding
#
# Returns the 4-elements list of pixels corresponding to a given padding
# specification.
#------------------------------------------------------------------------------
proc scrollutil::snb::normalizePadding {w padding} {
    switch [llength $padding] {
	0 {
	    return [list 0 0 0 0]
	}
	1 {
	    foreach l $padding {}
	    set l [winfo pixels $w $l]
	    return [list $l $l $l $l]
	}
	2 {
	    foreach {l t} $padding {}
	    set l [winfo pixels $w $l]
	    set t [winfo pixels $w $t]
	    return [list $l $t $l $t]
	}
	3 {
	    foreach {l t r} $padding {}
	    set l [winfo pixels $w $l]
	    set t [winfo pixels $w $t]
	    set r [winfo pixels $w $r]
	    return [list $l $t $r $t]
	}
	4 {
	    foreach {l t r b} $padding {}
	    set l [winfo pixels $w $l]
	    set t [winfo pixels $w $t]
	    set r [winfo pixels $w $r]
	    set b [winfo pixels $w $b]
	    return [list $l $t $r $b]
	}
	default {
	    return -code error "wrong # elements in padding spec \"$padding\""
	}
    }
}

#------------------------------------------------------------------------------
# scrollutil::snb::saveXPad
#
# Saves the horizontal padding of the pane identified by a given widget of the
# scrollednotebook widget win.
#------------------------------------------------------------------------------
proc scrollutil::snb::saveXPad {win widget} {
    upvar ::scrollutil::ns${win}::data data \
	  ::scrollutil::ns${win}::xPadArr xPadArr

    set padding [normalizePadding $win [$data(nb) tab $widget -padding]]
    foreach {l t r b} $padding {}
    set xPadArr($widget) [list $l $r]
}

#------------------------------------------------------------------------------
# scrollutil::snb::forgetXPad
#
# Forgets the horizontal padding of the pane identified by a given widget of
# the scrollednotebook widget win.
#------------------------------------------------------------------------------
proc scrollutil::snb::forgetXPad {win widget} {
    upvar ::scrollutil::ns${win}::xPadArr xPadArr
    unset xPadArr($widget)
}

#------------------------------------------------------------------------------
# scrollutil::snb::origXPad
#
# Returns the saved horizontal padding of the pane identified by a given tab
# index of the scrollednotebook widget win.
#------------------------------------------------------------------------------
proc scrollutil::snb::origXPad {win tabIdx} {
    upvar ::scrollutil::ns${win}::data data \
	  ::scrollutil::ns${win}::xPadArr xPadArr

    set widget [lindex [$data(nb) tabs] $tabIdx]
    return $xPadArr($widget)
}

#------------------------------------------------------------------------------
# scrollutil::snb::maxPaneWidth
#
# Returns the max. pane width (including the saved paddings) of the
# scrollednotebook widget win.
#------------------------------------------------------------------------------
proc scrollutil::snb::maxPaneWidth win {
    upvar ::scrollutil::ns${win}::data data
    set maxWidth 0
    set tabIdx 0
    foreach widget [$data(nb) tabs] {
	set width [winfo reqwidth $widget]
	foreach {l r} [origXPad $win $tabIdx] {}
	incr width [expr {$l + $r}]
	if {$width > $maxWidth} {
	    set maxWidth $width
	}

	incr tabIdx
    }

    return $maxWidth
}

#------------------------------------------------------------------------------
# scrollutil::snb::updateNbWidthDelayed
#
# Arranges for the -width option of the notebook component of the
# scrollednotebook widget win to be updated 100 ms later.
#------------------------------------------------------------------------------
proc scrollutil::snb::updateNbWidthDelayed win {
    upvar ::scrollutil::ns${win}::data data
    if {[info exists data(afterId)]} {
        return ""
    }

    set data(afterId) [after 100 [list scrollutil::snb::updateNbWidth $win]]
}

#------------------------------------------------------------------------------
# scrollutil::snb::updateNbWidth
#
# Updates the -width option of the notebook component of the scrollednotebook
# widget win.
#------------------------------------------------------------------------------
proc scrollutil::snb::updateNbWidth win {
    if {[destroyed $win]} {
	return ""
    }

    upvar ::scrollutil::ns${win}::data data
    unset data(afterId)

    $data(nb) configure -width [maxPaneWidth $win]
    onNbTabChanged $data(nb) 0 ;# adjusts the current pane's horizontal padding
}

#------------------------------------------------------------------------------
# scrollutil::snb::destroyed
#
# Checks whether the scrollednotebook widget win got destroyed by some custom
# script.
#------------------------------------------------------------------------------
proc scrollutil::snb::destroyed win {
    #
    # A bit safer than using "winfo exists", because the widget might have
    # been destroyed and its name reused for a new non-scrollednotebook widget:
    #
    return [expr {![array exists ::scrollutil::ns${win}::data] ||
	    [winfo class $win] ne "Scrollednotebook"}]
}
