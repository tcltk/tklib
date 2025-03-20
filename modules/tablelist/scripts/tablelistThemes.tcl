#==============================================================================
# Contains procedures that populate the array themeDefaults with theme-specific
# default values of some tablelist configuration options.
#
# Structure of the module:
#   - Public procedure related to tile themes
#   - Private procedures related to tile themes
#   - Private procedures related to global KDE configuration options
#
# Copyright (c) 2005-2025  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Public procedure related to tile themes
# =======================================
#

#------------------------------------------------------------------------------
# tablelist::setThemeDefaults
#
# Populates the array themeDefaults with theme-specific default values of some
# tablelist configuration options and updates the array configSpecs.
#------------------------------------------------------------------------------
proc tablelist::setThemeDefaults {} {
    #
    # For several themes, some of the following most frequent
    # values will be overridden by theme-specific ones:
    #
    variable themeDefaults
    array set themeDefaults [list \
	-background		white \
	-foreground		black \
	-font			TkDefaultFont \
	-labelforeground	black \
	-labelactiveFg		black \
	-labelpressedFg		black \
	-labelfont		TkDefaultFont \
	-arrowcolor		black \
    ]

    set currentTheme [::mwutil::currentTheme]
    set isAwTheme \
	[llength [info commands ::ttk::theme::${currentTheme}::setTextColors]]
    if {$isAwTheme} {
	awTheme $currentTheme
    } elseif {[catch {${currentTheme}Theme}] != 0} {
	#
	# Fall back to the "default" theme (which is the root of all
	# themes) and then override the options set by the current one
	#
	defaultTheme
	array set themeDefaults [styleConfig .]

	if {[set bg [styleConfig . -background]] ne ""} {
	    array set themeDefaults [list \
		-labelbackground	$bg \
		-labeldeactivatedBg	$bg \
		-labeldisabledBg	$bg \
		-labelactiveBg		$bg \
		-labelpressedBg		$bg \
	    ]
	}

	if {[set fg [styleConfig . -foreground]] ne ""} {
	    array set themeDefaults [list \
		-labelforeground	$fg \
		-labelactiveFg		$fg \
		-labelpressedFg		$fg \
		-arrowcolor		$fg \
	    ]
	}

	array set arr [style map . -background]
	if {[info exists arr(active)]} {
	    set activeBg $arr(active)
	    array set themeDefaults [list \
		-labelactiveBg		$activeBg \
		-labelpressedBg		$activeBg \
	    ]
	} elseif {[set highlightBg [styleConfig . -highlightcolor]] ne ""} {
	    array set themeDefaults [list \
		-labelactiveBg		$highlightBg \
		-labelpressedBg		$highlightBg \
	    ]
	}
	if {[info exists arr(pressed)]} {
	    set themeDefaults(-labelpressedBg) $arr(pressed)
	}

	unset arr
	array set arr [style map . -foreground]
	if {[info exists arr(disabled)]} {
	    set disabledFg $arr(disabled)
	    array set themeDefaults [list \
		-disabledforeground	$disabledFg \
		-labeldisabledFg	$disabledFg \
	    ]
	}
    }

    if {$themeDefaults(-arrowcolor) eq ""} {
	set themeDefaults(-arrowdisabledcolor) ""
    } else {
	set themeDefaults(-arrowdisabledcolor) $themeDefaults(-labeldisabledFg)
    }

    set themeDefaults(-targetcolor) $themeDefaults(-foreground)

    variable configSpecs
    foreach opt {-background -foreground -disabledforeground -stripebackground
		 -selectbackground -selectforeground -selectborderwidth -font
		 -labelforeground -labelfont -labelborderwidth -labelpady
		 -arrowcolor -arrowdisabledcolor -arrowstyle -treestyle
		 -targetcolor} {
	if {[llength $configSpecs($opt)] < 4} {
	    lappend configSpecs($opt) $themeDefaults($opt)
	} else {
	    lset configSpecs($opt) 3 $themeDefaults($opt)
	}
    }
}

#
# Private procedures related to tile themes
# =========================================
#

#------------------------------------------------------------------------------
# tablelist::awTheme
#------------------------------------------------------------------------------
proc tablelist::awTheme theme {
    set bg		[styleConfig . -background]
    set fg		[styleConfig . -foreground]
    set disabledFg	[lindex [style map . -foreground] 1]
    set labelBg		[styleConfig Heading -background]
    set labelactiveBg	[styleConfig Heading -lightcolor]

    scan $bg "#%2x%2x%2x" r g b
    incr r -15; incr g -15; incr b -15
    set stripeBg [format "#%2x%2x%2x" $r $g $b]

    variable svgSupported
    variable scalingpct
    set pct [expr {$svgSupported ? "" : $scalingpct}]
    switch $theme {
	awarc - arc			{ set treeStyle classic$pct }
	awblack - black			{ set treeStyle white$pct }
	awbreeze - breeze		{ set treeStyle bicolor$pct }
	awbreezedark			{ set treeStyle white$pct }
	awclearlooks - clearlooks	{ set treeStyle plain$pct }
	awdark				{ set treeStyle white$pct }
	awlight				{ set treeStyle bicolor$pct }
	awtemplate			{ set treeStyle white$pct }
	awwinxpblue - winxpblue		{ set treeStyle bicolor$pct }
	default				{ set treeStyle bicolor$pct }
    }

    variable themeDefaults
    array set themeDefaults [list \
	-background		$bg \
	-foreground		$fg \
	-disabledforeground	$disabledFg \
	-stripebackground	$stripeBg \
	-selectbackground	[styleConfig . -selectbackground] \
	-selectforeground	[styleConfig . -selectforeground] \
	-selectborderwidth	[styleConfig . -selectborderwidth] \
	-labelbackground	$labelBg \
	-labeldeactivatedBg	$labelBg \
	-labeldisabledBg	$labelBg \
	-labelactiveBg		$labelactiveBg \
	-labelpressedBg		$labelactiveBg \
	-labelforeground	$fg \
	-labeldisabledFg	$disabledFg \
	-labelactiveFg		$fg \
	-labelpressedFg		$fg \
	-labelborderwidth	1 \
	-labelpady		1 \
	-arrowcolor		$fg \
	-arrowstyle		[defaultX11ArrowStyle] \
	-treestyle		$treeStyle \
    ]
}

#------------------------------------------------------------------------------
# tablelist::altTheme
#------------------------------------------------------------------------------
proc tablelist::altTheme {} {
    variable themeDefaults
    array set themeDefaults [list \
	-disabledforeground	#a3a3a3 \
	-stripebackground	#f0f0f0 \
	-selectbackground	#4a6984 \
	-selectforeground	#ffffff \
	-selectborderwidth	0 \
	-labelbackground	#d9d9d9 \
	-labeldeactivatedBg	#d9d9d9 \
	-labeldisabledBg	#d9d9d9 \
	-labelactiveBg		#ececec \
	-labelpressedBg		#ececec \
	-labeldisabledFg	#a3a3a3 \
	-labelborderwidth	2 \
	-labelpady		1 \
	-arrowstyle		[defaultX11ArrowStyle] \
	-treestyle		gtk \
    ]
}

#------------------------------------------------------------------------------
# tablelist::aquaTheme
#------------------------------------------------------------------------------
proc tablelist::aquaTheme {} {
    variable newAquaSupport
    if {$newAquaSupport} {
	set darkMode   [tk::unsupported::MacWindowStyle isdark .]
	set disabledFg [expr {$darkMode ? "#646464" : "#b1b1b1"}]
    } else {
	set disabledFg #b1b1b1
    }

    ##nagelfar ignore
    scan $::tcl_platform(osVersion) "%d" majorOSVersion
    if {$majorOSVersion >= 14} {			;# OS X 10.10 or later
	if {$newAquaSupport} {
	    if {$darkMode} {
		set labelBg		#323232
		set labeldeactivatedBg	#323232
		set labeldisabledBg	""
		set labelpressedBg	#323232
		if {$majorOSVersion >= 20} {		;# macOS 11.0 or higher
		    set arrowColor	#a4a0a1
		} else {
		    set arrowColor	#808080
		}
	    } else {
		set labelBg		#eeeeee
		set labeldeactivatedBg	#f6f6f6
		set labeldisabledBg	""
		set labelpressedBg	#eeeeee
		if {$majorOSVersion >= 20} {		;# macOS 11.0 or higher
		    set arrowColor	#878787
		} else {
		    set arrowColor	#404040
		}
	    }
	} else {
	    set labelBg			#f6f6f6
	    set labeldeactivatedBg	#ffffff
	    set labeldisabledBg		#ffffff
	    set labelpressedBg		#e9e9e9
	    set arrowColor		#404040
	}
    } elseif {$majorOSVersion >= 11} {			;# OS X 10.7 or later
	set labelBg		#f3f3f3
	set labeldeactivatedBg	#f3f3f3
	set labeldisabledBg	#f3f3f3
	set labelpressedBg	#d5d5d5
	set arrowColor		#777777
    } else {
	set labelBg		#efefef
	set labeldeactivatedBg	#efefef
	set labeldisabledBg	#efefef
	set labelpressedBg	#dddddd
	set arrowColor		#777777
    }

    switch [mwutil::normalizeColor systemMenuActive] {
	#3571cd - #7eadd9 {				;# Blue Cocoa/Carbon
	    if {$majorOSVersion >= 14} {		;# OS X 10.10 or later
		if {$newAquaSupport} {
		    if {$darkMode} {
			set stripeBg			#282828
			set labelselectedBg		#323232
			set labelselectedpressedBg	#323232
		    } else {
			set stripeBg			#f5f5f5
			set labelselectedBg		#eeeeee
			set labelselectedpressedBg	#eeeeee
		    }
		} else {
		    set stripeBg		#f5f5f5
		    set labelselectedBg		#f6f6f6
		    set labelselectedpressedBg	#e9e9e9
		}
	    } elseif {$majorOSVersion >= 11} {		;# OS X 10.7 or later
		set stripeBg			#f3f6fa
		set labelselectedBg		#91c5f3
		set labelselectedpressedBg	#5092e3
	    } else {
		set stripeBg			#edf3fe
		set labelselectedBg		#80b8ef
		set labelselectedpressedBg	#69aaeb
	    }
	}

	#5f6b7a - #9babbd {				;# Graphite Cocoa/Carbon
	    if {$majorOSVersion >= 14} {		;# OS X 10.10 or later
		if {$newAquaSupport} {
		    if {$darkMode} {
			set stripeBg			#282828
			set labelselectedBg		#323232
			set labelselectedpressedBg	#323232
		    } else {
			set stripeBg			#f5f5f5
			set labelselectedBg		#eeeeee
			set labelselectedpressedBg	#eeeeee
		    }
		} else {
		    set stripeBg		#f5f5f5
		    set labelselectedBg		#f6f6f6
		    set labelselectedpressedBg	#e9e9e9
		}
	    } elseif {$majorOSVersion >= 11} {		;# OS X 10.7 or later
		set stripeBg			#f6f7f9
		set labelselectedBg		#abb6c2
		set labelselectedpressedBg	#76829a
	    } else {
		set stripeBg			#f0f0f0
		set labelselectedBg		#c0c7ce
		set labelselectedpressedBg	#afb7c0
	    }
	}
    }

    #
    # Get the default value of the -selectbackground option
    #
    if {$majorOSVersion >= 18} {			;# OS X 10.14 or later
	if {$newAquaSupport} {
	    variable channel
	    if {[info exists channel]} {	;# see proc condOpenPipeline
		set input [gets $channel]

		puts $channel "exit"
		flush $channel
		close $channel
		unset channel

		lassign $input r g b
		set rgb [format "#%02x%02x%02x" \
			 [expr {$r >> 8}] [expr {$g >> 8}] [expr {$b >> 8}]]
	    } else {
		set rgb [mwutil::normalizeColor \
			 systemSelectedTextBackgroundColor]
	    }

	    if {[catch {winfo rgb . systemSelectedContentBackgroundColor}]
		== 0} {
		set selectBg systemSelectedContentBackgroundColor
	    } elseif {$darkMode} {
		switch $rgb {
		    #3f638b		{ set selectBg #0059d1	;# blue }
		    #705771 - #705670	{ set selectBg #803482	;# purple }
		    #89576e - #88566e	{ set selectBg #c93379	;# pink }
		    #8b5759 - #8b5758	{ set selectBg #d13539	;# red }
		    #896647 - #886547	{ set selectBg #c96003	;# orange }
		    #8b7a3f - #8a754a	{ set selectBg #d19e00	;# yellow }
		    #5c7654 - #5c7653	{ set selectBg #43932a	;# green }
		    #ffffff		{ set selectBg #696969	;# graphite }
		    default	{ set selectBg systemHighlightAlternate }
		}
	    } else {
		switch $rgb {
		    #b3d7ff		{ set selectBg #0064e1	;# blue }
		    #dfc5e0 - #dfc5df	{ set selectBg #7d2a7e	;# purple }
		    #fdcbe2 - #fccae2	{ set selectBg #d93b86	;# pink }
		    #f6c4c5 - #f5c3c5	{ set selectBg #c4262b	;# red }
		    #fddabb - #fcd9bb	{ set selectBg #d96b0a	;# orange }
		    #ffeebe - #fee9be	{ set selectBg #e1ac15	;# yellow }
		    #d0eac8 - #d0eac7	{ set selectBg #4da033	;# green }
		    #e0e0e0		{ set selectBg #808080	;# graphite }
		    default	{ set selectBg systemHighlightAlternate }
		}
	    }
	} else {
	    switch [mwutil::normalizeColor systemHighlight] {
		#b2d7ff	{ set selectBg #0064e1	;# blue }
		#f7d4ff	{ set selectBg #7d2a7e	;# purple }
		#ffbfd2	{ set selectBg #d93b86	;# pink }
		#ffbbb8	{ set selectBg #c4262b	;# red }
		#ffdfb3	{ set selectBg #d96b0a	;# orange }
		#ffefb0	{ set selectBg #e1ac15	;# yellow }
		#c0f6ad	{ set selectBg #4da033	;# green }
		#d8d8dc	{ set selectBg #808080	;# graphite }
		default	{ set selectBg systemHighlightAlternate }
	    }
	}
    } else {
	set selectBg systemHighlightAlternate
    }

    variable themeDefaults
    if {$newAquaSupport} {
	array set themeDefaults [list \
	    -background			systemTextBackgroundColor \
	    -foreground			systemTextColor \
	    -labelforeground		systemLabelColor \
	    -labelactiveFg		systemLabelColor \
	    -labelpressedFg		systemLabelColor \
	    -labelselectedFg		systemLabelColor \
	    -labelselectedpressedFg	systemLabelColor \
	]
    } else {
	array set themeDefaults [list \
	    -background			systemWindowBody \
	    -foreground			systemModelessDialogActiveText \
	    -labelforeground		systemModelessDialogActiveText \
	    -labelactiveFg		systemModelessDialogActiveText \
	    -labelpressedFg		systemModelessDialogActiveText \
	    -labelselectedFg		systemModelessDialogActiveText \
	    -labelselectedpressedFg	systemModelessDialogActiveText \
	]
    }
    array set themeDefaults [list \
	-disabledforeground	$disabledFg \
	-stripebackground	$stripeBg \
	-selectbackground	$selectBg \
	-selectforeground	white \
	-selectborderwidth	0 \
	-labelbackground	$labelBg \
	-labeldeactivatedBg	$labeldeactivatedBg \
	-labeldisabledBg	$labeldisabledBg \
	-labelactiveBg		$labelBg \
	-labelpressedBg		$labelpressedBg \
	-labelselectedBg	$labelselectedBg \
	-labelselectedpressedBg	$labelselectedpressedBg \
	-labeldisabledFg	$disabledFg \
	-labelfont		TkHeadingFont \
	-labelborderwidth	1 \
	-labelpady		1 \
	-arrowcolor		$arrowColor \
    ]

    variable pngSupported
    if {$majorOSVersion >= 14} {			;# OS X 10.10 or later
	set themeDefaults(-arrowstyle) flatAngle7x4
    } elseif {$pngSupported} {
	set themeDefaults(-arrowstyle) photo7x7
    } else {
	set themeDefaults(-arrowstyle) flat7x7
    }

     if {$majorOSVersion >= 20} {			;# macOS 11.0 or higher
	set themeDefaults(-treestyle) aqua11
    } else {
	set themeDefaults(-treestyle) aqua
    }
}

#------------------------------------------------------------------------------
# tablelist::AquativoTheme
#------------------------------------------------------------------------------
proc tablelist::AquativoTheme {} {
    variable themeDefaults
    array set themeDefaults [list \
	-disabledforeground	black \
	-stripebackground	#edf3fe \
	-selectbackground	#000000 \
	-selectforeground	#ffffff \
	-selectborderwidth	0 \
	-labelbackground	#fafafa \
	-labeldeactivatedBg	#fafafa \
	-labeldisabledBg	#fafafa \
	-labelactiveBg		#fafafa \
	-labelpressedBg		#fafafa \
	-labeldisabledFg	black \
	-labelborderwidth	2 \
	-labelpady		1 \
	-arrowcolor		#777777 \
	-arrowstyle		flat7x7 \
	-treestyle		aqua \
    ]
}

#------------------------------------------------------------------------------
# tablelist::aquativoTheme
#------------------------------------------------------------------------------
proc tablelist::aquativoTheme {} {
    variable themeDefaults
    array set themeDefaults [list \
	-disabledforeground	#565248 \
	-stripebackground	#edf3fe \
	-selectbackground	#000000 \
	-selectforeground	#ffffff \
	-selectborderwidth	0 \
	-labelbackground	#fafafa \
	-labeldeactivatedBg	#fafafa \
	-labeldisabledBg	#e3e1dd\
	-labelactiveBg		#c1d2ee \
	-labelpressedBg		#bab5ab \
	-labeldisabledFg	#565248 \
	-labelborderwidth	2 \
	-labelpady		1 \
	-arrowcolor		#777777 \
	-arrowstyle		flat7x7 \
	-treestyle		aqua \
    ]
}

#------------------------------------------------------------------------------
# tablelist::ArcTheme
#------------------------------------------------------------------------------
proc tablelist::ArcTheme {} {
    variable themeDefaults
    variable svgSupported
    variable scalingpct
    set pct [expr {$svgSupported ? "" : $scalingpct}]
    array set themeDefaults [list \
	-foreground		#5c616c \
	-disabledforeground	#a9acb2 \
	-stripebackground	"" \
	-selectbackground	#5294e2 \
	-selectforeground	#ffffff \
	-selectborderwidth	0 \
	-labelbackground	#f5f6f7 \
	-labeldeactivatedBg	#f5f6f7 \
	-labeldisabledBg	#fbfcfc \
	-labelactiveBg		#f5f6f7 \
	-labelpressedBg		#f5f6f7 \
	-labelforeground	#5c616c \
	-labeldisabledFg	#a9acb2 \
	-labelactiveFg		#5c616c \
	-labelpressedFg		#5c616c \
	-labelborderwidth	0 \
	-labelpady		0 \
	-arrowcolor		#5c616c \
	-arrowstyle		flatAngle10x6 \
	-treestyle		classic$pct \
    ]
}

#------------------------------------------------------------------------------
# tablelist::blackTheme
#------------------------------------------------------------------------------
proc tablelist::blackTheme {} {
    variable themeDefaults
    variable svgSupported
    variable scalingpct
    set pct [expr {$svgSupported ? "" : $scalingpct}]
    array set themeDefaults [list \
	-background		#000000 \
	-foreground		#ffffff \
	-disabledforeground	#a9a9a9 \
	-stripebackground	"" \
	-selectbackground	#4a6984 \
	-selectforeground	#ffffff \
	-selectborderwidth	0 \
	-labelbackground	#424242 \
	-labeldeactivatedBg	#424242 \
	-labeldisabledBg	#424242 \
	-labelactiveBg		#626262 \
	-labelpressedBg		#626262 \
	-labelforeground	#ffffff \
	-labeldisabledFg	#a9a9a9 \
	-labelactiveFg		#ffffff \
	-labelpressedFg		#ffffff \
	-labelborderwidth	2 \
	-labelpady		[scaleutil::scale 3 $scalingpct] \
	-arrowcolor		#ffffff \
	-arrowstyle		[defaultX11ArrowStyle] \
	-treestyle		white$pct \
    ]
}

#------------------------------------------------------------------------------
# tablelist::blueTheme
#------------------------------------------------------------------------------
proc tablelist::blueTheme {} {
    variable themeDefaults
    array set themeDefaults [list \
	-background		#e6f3ff \
	-disabledforeground	#666666 \
	-stripebackground	"" \
	-selectbackground	#ffff33 \
	-selectforeground	#000000 \
	-selectborderwidth	1 \
	-labelbackground	#6699cc \
	-labeldeactivatedBg	#6699cc \
	-labeldisabledBg	#6699cc \
	-labelactiveBg		#6699cc \
	-labelpressedBg		#6699cc \
	-labeldisabledFg	#666666 \
	-labelborderwidth	1 \
	-labelpady		1 \
	-arrowcolor		#2d2d66 \
	-arrowstyle		flat9x5 \
	-treestyle		gtk \
    ]
}

#------------------------------------------------------------------------------
# tablelist::BreezeTheme, tablelist::breezeTheme
#------------------------------------------------------------------------------
proc tablelist::BreezeTheme {} {
    variable themeDefaults
    variable svgSupported
    variable scalingpct
    set pct [expr {$svgSupported ? "" : $scalingpct}]
    array set themeDefaults [list \
	-background		#eff0f1 \
	-foreground		#31363b \
	-disabledforeground	#bbcbbe \
	-stripebackground	"" \
	-selectbackground	#3daee9 \
	-selectforeground	#ffffff \
	-selectborderwidth	0 \
	-labelbackground	#eff0f1 \
	-labeldeactivatedBg	#eff0f1 \
	-labeldisabledBg	#eff0f1 \
	-labelactiveBg		#94d0eb \
	-labelpressedBg		#94d0eb \
	-labelforeground	#31363b \
	-labeldisabledFg	#bbcbbe \
	-labelactiveFg		#31363b \
	-labelpressedFg		#31363b \
	-labelborderwidth	0 \
	-labelpady		1 \
	-arrowcolor		#31363b \
	-arrowstyle		flatAngle11x6 \
	-treestyle		bicolor$pct \
    ]
}
proc tablelist::breezeTheme {} {
    BreezeTheme
}

#------------------------------------------------------------------------------
# tablelist::breeze-darkTheme
#------------------------------------------------------------------------------
proc tablelist::breeze-darkTheme {} {
    variable themeDefaults
    variable svgSupported
    variable scalingpct
    set pct [expr {$svgSupported ? "" : $scalingpct}]
    array set themeDefaults [list \
	-background		#31363b \
	-foreground		#eff0f1 \
	-disabledforeground	#7f8c8d \
	-stripebackground	"" \
	-selectbackground	#3daee9 \
	-selectforeground	#ffffff \
	-selectborderwidth	0 \
	-labelbackground	#31363b \
	-labeldeactivatedBg	#31363b \
	-labeldisabledBg	#31363b \
	-labelactiveBg		#94d0eb \
	-labelpressedBg		#94d0eb \
	-labelforeground	#eff0f1 \
	-labeldisabledFg	#bbcbbe \
	-labelactiveFg		#eff0f1 \
	-labelpressedFg		#eff0f1 \
	-labelborderwidth	0 \
	-labelpady		1 \
	-arrowcolor		#eff0f1 \
	-arrowstyle		flatAngle11x6 \
	-treestyle		white$pct \
    ]
}

#------------------------------------------------------------------------------
# tablelist::clamTheme
#------------------------------------------------------------------------------
proc tablelist::clamTheme {} {
    if {[styleConfig Heading -padding] == 1} {	;# set by themepatch::patch
	set labelPadY 1
    } else {
	variable scalingpct
	set labelPadY [scaleutil::scale 3 $scalingpct]
    }

    variable themeDefaults
    array set themeDefaults [list \
	-disabledforeground	#999999 \
	-stripebackground	#eeebe7 \
	-selectbackground	#4a6984 \
	-selectforeground	#ffffff \
	-selectborderwidth	0 \
	-labelbackground	#dcdad5 \
	-labeldeactivatedBg	#dcdad5 \
	-labeldisabledBg	#dcdad5 \
	-labelactiveBg		#eeebe7 \
	-labelpressedBg		#eeebe7 \
	-labeldisabledFg	#999999 \
	-labelborderwidth	2 \
	-labelpady		$labelPadY \
	-arrowstyle		[defaultX11ArrowStyle] \
	-treestyle		gtk \
    ]
}

#------------------------------------------------------------------------------
# tablelist::classicTheme
#------------------------------------------------------------------------------
proc tablelist::classicTheme {} {
    variable themeDefaults
    array set themeDefaults [list \
	-disabledforeground	#a3a3a3 \
	-stripebackground	#f0f0f0 \
	-selectbackground	#c3c3c3 \
	-selectforeground	#000000 \
	-labelbackground	#d9d9d9 \
	-labeldeactivatedBg	#d9d9d9 \
	-labeldisabledBg	#d9d9d9 \
	-labelactiveBg		#ececec \
	-labelpressedBg		#ececec \
	-labeldisabledFg	#a3a3a3 \
	-labelborderwidth	2 \
	-labelpady		1 \
	-arrowcolor		"" \
	-arrowstyle		sunken10x9 \
	-treestyle		gtk \
    ]

    set val [styleConfig . -selectborderwidth]
    set themeDefaults(-selectborderwidth) [expr {$val eq "" ? 0 : $val}]

    if {[info exists ::tile::version] &&
	[string compare $::tile::version "0.8"] < 0} {
	set themeDefaults(-font)	TkClassicDefaultFont
	set themeDefaults(-labelfont)	TkClassicDefaultFont
    }
}

#------------------------------------------------------------------------------
# tablelist::clearlooksTheme
#------------------------------------------------------------------------------
proc tablelist::clearlooksTheme {} {
    variable themeDefaults
    array set themeDefaults [list \
	-disabledforeground	#b5b3ac \
	-stripebackground	"" \
	-selectbackground	#71869e \
	-selectforeground	#ffffff \
	-selectborderwidth	0 \
	-labelbackground	#efeae6 \
	-labeldeactivatedBg	#efeae6 \
	-labeldisabledBg	#eee9e4 \
	-labelactiveBg		#f4f2ee \
	-labelpressedBg		#d4cfca \
	-labeldisabledFg	#b5b3ac \
	-labelborderwidth	0 \
	-labelpady		1 \
	-arrowstyle		flatAngle9x6 \
	-treestyle		gtk \
    ]
}

#------------------------------------------------------------------------------
# tablelist::defaultTheme
#------------------------------------------------------------------------------
proc tablelist::defaultTheme {} {
    variable themeDefaults
    array set themeDefaults [list \
	-disabledforeground	#a3a3a3 \
	-stripebackground	#e8e8e8 \
	-selectbackground	#4a6984 \
	-selectforeground	#ffffff \
	-labelbackground	#d9d9d9 \
	-labeldeactivatedBg	#d9d9d9 \
	-labeldisabledBg	#d9d9d9 \
	-labelactiveBg		#ececec \
	-labelpressedBg		#ececec \
	-labeldisabledFg	#a3a3a3 \
	-labelborderwidth	1 \
	-labelpady		1 \
	-arrowstyle		[defaultX11ArrowStyle] \
	-treestyle		gtk \
    ]

    set val [styleConfig . -selectborderwidth]
    set themeDefaults(-selectborderwidth) [expr {$val eq "" ? 0 : $val}]
}

#------------------------------------------------------------------------------
# tablelist::keramikTheme
#------------------------------------------------------------------------------
proc tablelist::keramikTheme {} {
    variable themeDefaults
    array set themeDefaults [list \
	-disabledforeground	#aaaaaa \
	-stripebackground	"" \
	-selectbackground	#0a5f89 \
	-selectforeground	#ffffff \
	-selectborderwidth	0 \
	-labelbackground	#e2e4e7 \
	-labeldeactivatedBg	#e2e4e7 \
	-labeldisabledBg	#e2e4e7 \
	-labelactiveBg		#e2e4e7 \
	-labelpressedBg		#c6c8cc \
	-labeldisabledFg	#aaaaaa \
	-labelborderwidth	0 \
	-labelpady		1 \
	-arrowstyle		flat8x5 \
	-treestyle		winnative \
    ]
}

#------------------------------------------------------------------------------
# tablelist::keramik_altTheme
#------------------------------------------------------------------------------
proc tablelist::keramik_altTheme {} {
    variable themeDefaults
    array set themeDefaults [list \
	-disabledforeground	#aaaaaa \
	-stripebackground	"" \
	-selectbackground	#0a5f89 \
	-selectforeground	#ffffff \
	-selectborderwidth	0 \
	-labelbackground	#e2e4e7 \
	-labeldeactivatedBg	#e2e4e7 \
	-labeldisabledBg	#e2e4e7 \
	-labelactiveBg		#e2e4e7 \
	-labelpressedBg		#c6c8cc \
	-labeldisabledFg	#aaaaaa \
	-labelborderwidth	0 \
	-labelpady		1 \
	-arrowstyle		flat8x5 \
	-treestyle		winnative \
    ]
}

#------------------------------------------------------------------------------
# tablelist::krocTheme
#------------------------------------------------------------------------------
proc tablelist::krocTheme {} {
    variable themeDefaults
    array set themeDefaults [list \
	-disabledforeground	#b2b2b2 \
	-stripebackground	"" \
	-selectbackground	#000000 \
	-selectforeground	#ffffff \
	-selectborderwidth	1 \
	-labelbackground	#fcb64f \
	-labeldeactivatedBg	#fcb64f \
	-labeldisabledBg	#fcb64f \
	-labelactiveBg		#694418 \
	-labelpressedBg		#694418 \
	-labeldisabledFg	#b2b2b2 \
	-labelactiveFg		#ffe7cb \
	-labelpressedFg		#ffe7cb \
	-labelborderwidth	2 \
	-labelpady		1 \
	-arrowstyle		[defaultX11ArrowStyle] \
	-treestyle		gtk \
    ]
}

#------------------------------------------------------------------------------
# tablelist::plastikTheme
#------------------------------------------------------------------------------
proc tablelist::plastikTheme {} {
    variable themeDefaults
    array set themeDefaults [list \
	-disabledforeground	#aaaaaa \
	-stripebackground	"" \
	-selectbackground	#657a9e \
	-selectforeground	#ffffff \
	-selectborderwidth	0 \
	-labelbackground	#dcdde3 \
	-labeldeactivatedBg	#dcdde3 \
	-labeldisabledBg	#dcdde3 \
	-labelactiveBg		#dcdde3 \
	-labelpressedBg		#b9bcc0 \
	-labeldisabledFg	#aaaaaa \
	-labelborderwidth	0 \
	-labelpady		1 \
	-arrowstyle		flat7x4 \
	-treestyle		plastik \
    ]
}

#------------------------------------------------------------------------------
# tablelist::srivTheme
#------------------------------------------------------------------------------
proc tablelist::srivTheme {} {
    variable themeDefaults
    array set themeDefaults [list \
	-background		#e6f3ff \
	-disabledforeground	#666666 \
	-stripebackground	"" \
	-selectbackground	#ffff33 \
	-selectforeground	#000000 \
	-selectborderwidth	1 \
	-labelbackground	#a0a0a0 \
	-labeldeactivatedBg	#a0a0a0 \
	-labeldisabledBg	#a0a0a0 \
	-labelactiveBg		#a0a0a0 \
	-labelpressedBg		#a0a0a0 \
	-labeldisabledFg	#666666 \
	-labelborderwidth	1 \
	-labelpady		1 \
	-arrowstyle		[defaultX11ArrowStyle] \
	-treestyle		gtk \
    ]
}

#------------------------------------------------------------------------------
# tablelist::srivlgTheme
#------------------------------------------------------------------------------
proc tablelist::srivlgTheme {} {
    variable themeDefaults
    array set themeDefaults [list \
	-background		#e6f3ff \
	-disabledforeground	#666666 \
	-stripebackground	"" \
	-selectbackground	#ffff33 \
	-selectforeground	#000000 \
	-selectborderwidth	1 \
	-labelbackground	#6699cc \
	-labeldeactivatedBg	#6699cc \
	-labeldisabledBg	#6699cc \
	-labelactiveBg		#6699cc \
	-labelpressedBg		#6699cc \
	-labeldisabledFg	#666666 \
	-labelborderwidth	1 \
	-labelpady		1 \
	-arrowstyle		[defaultX11ArrowStyle] \
	-treestyle		gtk \
    ]
}

#------------------------------------------------------------------------------
# tablelist::stepTheme
#------------------------------------------------------------------------------
proc tablelist::stepTheme {} {
    variable themeDefaults
    array set themeDefaults [list \
	-disabledforeground	#808080 \
	-stripebackground	"" \
	-selectbackground	#fdcd00 \
	-selectforeground	#ffffff \
	-selectborderwidth	0 \
	-labelbackground	#a0a0a0 \
	-labeldeactivatedBg	#a0a0a0 \
	-labeldisabledBg	#a0a0a0 \
	-labelactiveBg		#aeb2c3 \
	-labelpressedBg		#aeb2c3 \
	-labeldisabledFg	#808080 \
	-labelborderwidth	2 \
	-labelpady		1 \
	-arrowstyle		[defaultX11ArrowStyle] \
	-treestyle		gtk \
    ]
}

#------------------------------------------------------------------------------
# tablelist::sun-valley-lightTheme
#------------------------------------------------------------------------------
proc tablelist::sun-valley-lightTheme {} {
    variable themeDefaults
    variable svgSupported
    variable scalingpct
    set pct [expr {$svgSupported ? "" : $scalingpct}]
    array set themeDefaults [list \
	-background		#fafafa \
	-foreground		#1c1c1c \
	-disabledforeground	#a0a0a0 \
	-stripebackground	"" \
	-selectbackground	#2f60d8 \
	-selectforeground	#ffffff \
	-selectborderwidth	0 \
	-labelbackground	#fdfdfd \
	-labeldeactivatedBg	#fdfdfd \
	-labeldisabledBg	#fdfdfd \
	-labelactiveBg		#f9f9f9 \
	-labelpressedBg		#fafafa \
	-labelforeground	#1c1c1c \
	-labeldisabledFg	#a0a0a0 \
	-labelactiveFg		#1c1c1c \
	-labelpressedFg		#1c1c1c \
	-labelborderwidth	0 \
	-labelpady		1 \
	-arrowcolor		#1c1c1c \
	-arrowstyle		[defaultX11ArrowStyle] \
	-treestyle		bicolor$pct \
    ]
}

#------------------------------------------------------------------------------
# tablelist::sun-valley-darkTheme
#------------------------------------------------------------------------------
proc tablelist::sun-valley-darkTheme {} {
    variable themeDefaults
    variable svgSupported
    variable scalingpct
    set pct [expr {$svgSupported ? "" : $scalingpct}]
    array set themeDefaults [list \
	-background		#1c1c1c \
	-foreground		#fafafa \
	-disabledforeground	#595959 \
	-stripebackground	"" \
	-selectbackground	#2f60d8 \
	-selectforeground	#ffffff \
	-selectborderwidth	0 \
	-labelbackground	#2a2a2a \
	-labeldeactivatedBg	#2a2a2a \
	-labeldisabledBg	#2a2a2a \
	-labelactiveBg		#2f2f2f \
	-labelpressedBg		#232323 \
	-labelforeground	#fafafa \
	-labeldisabledFg	#595959 \
	-labelactiveFg		#fafafa \
	-labelpressedFg		#fafafa \
	-labelborderwidth	0 \
	-labelpady		1 \
	-arrowcolor		#fafafa \
	-arrowstyle		[defaultX11ArrowStyle] \
	-treestyle		white$pct \
    ]
}

#------------------------------------------------------------------------------
# tablelist::tileqtTheme
#
# Tested with the following Qt styles:
#
#   Acqua              KDE Classic                Motif Plus     RISC OS
#   B3/KDE             KDE_XP                     MS Windows 9x  SGI
#   Baghira            Keramik                    Oxygen         System-Series
#   CDE                Light Style, 2nd revision  Phase          System++
#   Cleanlooks         Light Style, 3rd revision  Plastik        ThinKeramik
#   GTK+ Style         Lipstik                    Plastique
#   HighColor Classic  Marble                     Platinum
#   HighContrast       Motif                      QtCurve
#
# Supported KDE 1/2/3 color schemes:
#
#   Aqua Blue                     Ice (FreddyK)     Point Reyes Green
#   Aqua Graphite                 KDE 1             Pumpkin
#   Atlas Green                   KDE 2             Redmond 2000
#   BeOS                          Keramik           Redmond 95
#   Blue Slate                    Keramik Emerald   Redmond XP
#   CDE                           Keramik White     Solaris
#   Dark Blue                     Lipstik Noble     Storm
#   Desert Red                    Lipstik Standard  SuSE, old & new
#   Digital CDE                   Lipstik White     SUSE-kdm
#   EveX                          Media Peach       System
#   High Contrast Black Text      Next              Thin Keramik, old & new
#   High Contrast Yellow on Blue  Pale Gray         Thin Keramik II
#   High Contrast White Text      Plastik
#
# Supported KDE 4 color schemes:
#
#   Honeycomb       Oxygen (= Standard)  Steel       Zion (Reversed)
#   Norway          Oxygen Cold          Wonton Soup
#   Obsidian Coast  Oxygen-Molecule 3.0  Zion
#------------------------------------------------------------------------------
proc tablelist::tileqtTheme {} {
    set bg		[tileqt_currentThemeColour -background]
    set fg		[tileqt_currentThemeColour -foreground]
    set tableBg		[tileqt_currentThemeColour -base]
    set tableFg		[tileqt_currentThemeColour -text]
    set tableDisFg	[tileqt_currentThemeColour -disabled -text]
    set selectBg	[tileqt_currentThemeColour -highlight]
    set selectFg	[tileqt_currentThemeColour -highlightedText]
    set labelBg		[tileqt_currentThemeColour -button]
    set labelFg		[tileqt_currentThemeColour -buttonText]
    set labelDisFg	[tileqt_currentThemeColour -disabled -buttonText]
    set style		[string tolower [tileqt_currentThemeName]]
    set pressedBg	$labelBg

    #
    # For most Qt styles the label colors depend on the color scheme:
    #
    switch "$bg $labelBg" {
	"#fafafa #6188d7" {	;# color scheme "Aqua Blue"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #ffffff }
		"platinum"			      { set pressedBg #d0d0d0 }
		"baghira"	{ set labelBg #f5f5f5;  set pressedBg #9ec2fa }
		"highcolor"	{ set labelBg #628ada;  set pressedBg #6188d7 }
		"keramik"	{ set labelBg #8fabe4;  set pressedBg #7390cc }
		"phase"		{ set labelBg #6188d7;  set pressedBg #d0d0d0 }
		"plastik"	{ set labelBg #666bd6;  set pressedBg #5c7ec2 }
		"qtcurve"	{ set labelBg #f4f4f4;  set pressedBg #d0d0d0 }
		"thinkeramik"	{ set labelBg #f4f4f4;  set pressedBg #dedede }
	    }
	}

	"#ffffff #89919b" {	;# color scheme "Aqua Graphite"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #ffffff }
		"platinum"			      { set pressedBg #d4d4d4 }
		"baghira"	{ set labelBg #f5f5f5;  set pressedBg #c3c7cd }
		"highcolor"	{ set labelBg #8b949e;  set pressedBg #89919b }
		"keramik"	{ set labelBg #acb1b8;  set pressedBg #91979e }
		"phase"		{ set labelBg #89919b;  set pressedBg #d4d4d4 }
		"plastik"	{ set labelBg #8c949d;  set pressedBg #7f868e }
		"qtcurve"	{ set labelBg #f6f6f6;  set pressedBg #d4d4d4 }
		"thinkeramik"	{ set labelBg #f4f4f4;  set pressedBg #e2e2e2 }
	    }
	}

	"#afb49f #afb49f" {	;# color scheme "Atlas Green"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #c1c6af }
		"platinum"			      { set pressedBg #929684 }
		"baghira"	{ set labelBg #e5e8dc;  set pressedBg #dadcd0 }
		"highcolor"	{ set labelBg #b2b6a1;  set pressedBg #afb49f }
		"keramik"	{ set labelBg #c7cabb;  set pressedBg #adb1a1 }
		"phase"		{ set labelBg #a7b49f;  set pressedBg #929684 }
		"plastik"	{ set labelBg #acb19c;  set pressedBg #959987 }
		"qtcurve"	{ set labelBg #adb19e;  set pressedBg #939881 }
		"thinkeramik"	{ set labelBg #c1c4b6;  set pressedBg #a5a999 }
	    }
	}

	"#d9d9d9 #d9d9d9" {	;# color scheme "BeOS"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #eeeeee }
		"platinum"			      { set pressedBg #b4b4b4 }
		"baghira"	{ set labelBg #f2f2f2;  set pressedBg #e9e9e9 }
		"highcolor"	{ set labelBg #dcdcdc;  set pressedBg #d9d9d9 }
		"keramik"	{ set labelBg #e5e5e5;  set pressedBg #cdcdcd }
		"phase"		{ set labelBg #dadada;  set pressedBg #b4b4b4 }
		"plastik"	{ set labelBg #d6d6d6;  set pressedBg #b6b6b6 }
		"qtcurve"	{ set labelBg #d6d6d6;  set pressedBg #b5b5b5 }
		"thinkeramik"	{ set labelBg #dddddd;  set pressedBg #c5c5c5 }
	    }
	}

	"#9db9c8 #9db9c8" {	;# color scheme "Blue Slate"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #adcbdc }
		"platinum"			      { set pressedBg #8299a6 }
		"baghira"	{ set labelBg #ddeff6;  set pressedBg #d0e1ea }
		"highcolor"	{ set labelBg #9fbbcb;  set pressedBg #9db9c8 }
		"keramik"	{ set labelBg #baced9;  set pressedBg #a0b5c1 }
		"phase"		{ set labelBg #9db9c9;  set pressedBg #8299a6 }
		"plastik"	{ set labelBg #99b6c5;  set pressedBg #869fab }
		"qtcurve"	{ set labelBg #9bb7c6;  set pressedBg #7c9cad }
		"thinkeramik"	{ set labelBg #b5c8d2;  set pressedBg #98adb8 }
	    }
	}

	"#999999 #999999" {	;# color scheme "CDE"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #a8a8a8 }
		"platinum"			      { set pressedBg #7f7f7f }
		"baghira"	{ set labelBg #d5d5d5;  set pressedBg #cccccc }
		"highcolor"	{ set labelBg #9b9b9b;  set pressedBg #999999 }
		"keramik"	{ set labelBg #b7b7b7;  set pressedBg #9d9d9d }
		"phase"		{ set labelBg #999999;  set pressedBg #7f7f7f }
		"plastik"	{ set labelBg #979797;  set pressedBg #808080 }
		"qtcurve"	{ set labelBg #979797;  set pressedBg #7f7f7f }
		"thinkeramik"	{ set labelBg #b3b3b3;  set pressedBg #959595 }
	    }
	}

	"#426794 #426794" {	;# color scheme "Dark Blue"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #4871a2 }
		"platinum"			      { set pressedBg #37567b }
		"baghira"	{ set labelBg #8aafdc;  set pressedBg #82a3cc }
		"highcolor"	{ set labelBg #436895;  set pressedBg #426794 }
		"keramik"	{ set labelBg #7994b4;  set pressedBg #5b7799 }
		"phase"		{ set labelBg #426795;  set pressedBg #37567b }
		"plastik"	{ set labelBg #406592;  set pressedBg #36547a }
		"qtcurve"	{ set labelBg #416692;  set pressedBg #3c5676 }
		"thinkeramik"	{ set labelBg #7991af;  set pressedBg #546f91 }
	    }
	}

	"#d6cdbb #d6cdbb" {	;# color scheme "Desert Red"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #ebe1ce }
		"platinum"			      { set pressedBg #b2ab9c }
		"baghira"	{ set labelBg #f7f4ec;  set pressedBg #edeae0 }
		"highcolor"	{ set labelBg #d9d0be;  set pressedBg #d6cdbb }
		"keramik"	{ set labelBg #e3dcd0;  set pressedBg #cbc5b7 }
		"phase"		{ set labelBg #d6cdbb;  set pressedBg #b2ab9c }
		"plastik"	{ set labelBg #d3cbb8;  set pressedBg #bab3a3 }
		"qtcurve"	{ set labelBg #d4cbb8;  set pressedBg #b8ac94 }
		"thinkeramik"	{ set labelBg #dbd5ca;  set pressedBg #c2bbae }
	    }
	}

	"#4b7b82 #4b7b82" {	;# color scheme "Digital CDE"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #52878f }
		"platinum"			      { set pressedBg #3e666c }
		"baghira"	{ set labelBg #97c3c9;  set pressedBg #8eb6bc }
		"highcolor"	{ set labelBg #4b7d84;  set pressedBg #4b7b82 }
		"keramik"	{ set labelBg #80a2a7;  set pressedBg #62868c }
		"phase"		{ set labelBg #4b7b82;  set pressedBg #3e666c }
		"plastik"	{ set labelBg #49787f;  set pressedBg #3d666c }
		"qtcurve"	{ set labelBg #4a7980;  set pressedBg #416468 }
		"thinkeramik"	{ set labelBg #7f97a3;  set pressedBg #5a7e83 }
	    }
	}

	"#e6dedc #e4e4e4" {	;# color scheme "EveX"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #fdf4f2 }
		"platinum"			      { set pressedBg #bfb8b7 }
		"baghira"	{ set labelBg #f6f5f5;  set pressedBg #ededed }
		"highcolor"	{ set labelBg #e7e7e7;  set pressedBg #e4e4e4 }
		"keramik"	{ set labelBg #ededed;  set pressedBg #d6d6d6 }
		"phase"		{ set labelBg #e7e0dd;  set pressedBg #bfb8b7 }
		"plastik"	{ set labelBg #e2e2e2;  set pressedBg #c0bfbf }
		"qtcurve"	{ set labelBg #e4dcd9;  set pressedBg #c5b7b4 }
		"thinkeramik"	{ set labelBg #e6e1df;  set pressedBg #c7c9c7 }
	    }
	}

	"#ffffff #ffffff" {	;# color scheme "High Contrast Black Text"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #ffffff }
		"platinum"			      { set pressedBg #d4d4d4 }
		"baghira"	{ set labelBg #f5f5f5;  set pressedBg #f2f2f2 }
		"highcolor"	{ set labelBg #f5f5f5;  set pressedBg #ffffff }
		"keramik"	{ set labelBg #fbfbfb;  set pressedBg #e8e8e8 }
		"phase"		{ set labelBg #f7f7f7;  set pressedBg #d4d4d4 }
		"plastik"	{ set labelBg #f8f8f8;  set pressedBg #d8d8d8 }
		"qtcurve"	{ set labelBg #f6f6f6;  set pressedBg #d6d6d6 }
		"thinkeramik"	{ set labelBg #f4f4f4;  set pressedBg #e2e2e2 }
	    }
	}

	"#0000ff #0000ff" {	;# color scheme "High Contrast Yellow on Blue"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #1919ff }
		"platinum"			      { set pressedBg #0000d4 }
		"baghira"	{ set labelBg #4848ff;  set pressedBg #4646ff }
		"highcolor"	{ set labelBg #0e0ef5;  set pressedBg #0000ff }
		"keramik"	{ set labelBg #4949fb;  set pressedBg #2929e8 }
		"phase"		{ set labelBg #0909f7;  set pressedBg #0000d4 }
		"plastik"	{ set labelBg #0505f8;  set pressedBg #0000d8 }
		"qtcurve"	{ set labelBg #0909f2;  set pressedBg #0f0fc5 }
		"thinkeramik"	{ set labelBg #5151f4;  set pressedBg #2222e2 }
	    }
	}

	"#000000 #000000" {	;# color scheme "High Contrast White Text"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #000000 }
		"platinum"			      { set pressedBg #000000 }
		"baghira"	{ set labelBg #818181;  set pressedBg #7f7f7f }
		"highcolor"	{ set labelBg #000000;  set pressedBg #000000 }
		"keramik"	{ set labelBg #494949;  set pressedBg #292929 }
		"phase"		{ set labelBg #000000;  set pressedBg #000000 }
		"plastik"	{ set labelBg #000000;  set pressedBg #000000 }
		"qtcurve"	{ set labelBg #000000;  set pressedBg #000000 }
		"thinkeramik"	{ set labelBg #4d4d4d;  set pressedBg #222222 }
	    }
	}

	"#f6f6ff #e4eeff" {	;# color scheme "Ice (FreddyK)"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #ffffff }
		"platinum"			      { set pressedBg #cdcdd4 }
		"baghira"	{ set labelBg #f6f6f6;  set pressedBg #f2f4f6 }
		"highcolor"	{ set labelBg #e8edf5;  set pressedBg #e4eeff }
		"keramik"	{ set labelBg #edf3fb;  set pressedBg #d6dde8 }
		"phase"		{ set labelBg #f3f3f7;  set pressedBg #cdcdd4 }
		"plastik"	{ set labelBg #e3eaf8;  set pressedBg #c0c9d8 }
		"qtcurve"	{ set labelBg #ebebfc;  set pressedBg #b3b3f0 }
		"thinkeramik"	{ set labelBg #f1f1f4;  set pressedBg #dbdbe2 }
	    }
	}

	"#c0c0c0 #c0c0c0" {	;# color schemes "KDE 1" and "Storm"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #d3d3d3 }
		"platinum"			      { set pressedBg #a0a0a0 }
		"baghira"	{ set labelBg #e9e9e9;  set pressedBg #dedede }
		"highcolor"	{ set labelBg #c2c2c2;  set pressedBg #c0c0c0 }
		"keramik"	{ set labelBg #d3d3d3;  set pressedBg #bababa }
		"phase"		{ set labelBg #c1c1c1;  set pressedBg #a0a0a0 }
		"plastik"	{ set labelBg #bebebe;  set pressedBg #a2a2a2 }
		"qtcurve"	{ set labelBg #bebebe;  set pressedBg #a0a0a0 }
		"thinkeramik"	{ set labelBg #cccccc;  set pressedBg #b2b2b2 }
	    }
	}

	"#dcdcdc #e4e4e4" {	;# color scheme "KDE 2"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #d3d3d3 }
		"platinum"			      { set pressedBg #b7b7b7 }
		"baghira"	{ set labelBg #f3f3f3;  set pressedBg #ededed }
		"highcolor"	{ set labelBg #e7e7e7;  set pressedBg #e4e4e4 }
		"keramik"	{ set labelBg #ededed;  set pressedBg #d6d6d6 }
		"phase"		{ set labelBg #dddddd;  set pressedBg #b7b7b7 }
		"plastik"	{ set labelBg #e2e2e2;  set pressedBg #c0c0c0 }
		"qtcurve"	{ set labelBg #d9d9d9;  set pressedBg #b8b8b8 }
		"thinkeramik"	{ set labelBg #dfdfdf;  set pressedBg #c7c7c7 }
	    }
	}

	"#eae9e8 #e6f0f9" {	;# color scheme "Keramik"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #ffffff }
		"platinum"			      { set pressedBg #c3c2c1 }
		"baghira"	{ set labelBg #f4f4f4;  set pressedBg #f1f3f5 }
		"highcolor"	{ set labelBg #eaeef2;  set pressedBg #e6f0f9 }
		"keramik"	{ set labelBg #eef4f8;  set pressedBg #d7dfe5 }
		"phase"		{ set labelBg #ebeae9;  set pressedBg #c3c2c1 }
		"plastik"	{ set labelBg #e3ecf3;  set pressedBg #c0c9d2 }
		"qtcurve"	{ set labelBg #e8e6e6;  set pressedBg #c5c3c1 }
		"thinkeramik"	{ set labelBg #e8e8e7;  set pressedBg #d2d1d0 }
	    }
	}

	"#eeeee6 #eeeade" {	;# color scheme "Keramik Emerald"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #fffffc }
		"platinum"			      { set pressedBg #c6c6bf }
		"baghira"	{ set labelBg #f6f6f6;  set pressedBg #f3f2ee }
		"highcolor"	{ set labelBg #eeeae1;  set pressedBg #eeeade }
		"keramik"	{ set labelBg #f3f1e8;  set pressedBg #dddad1 }
		"phase"		{ set labelBg #efefef;  set pressedBg #c6c6bf }
		"plastik"	{ set labelBg #ebe7dc;  set pressedBg #c9c6bc }
		"qtcurve"	{ set labelBg #ecece3;  set pressedBg #cdcdbb }
		"thinkeramik"	{ set labelBg #ebebe5;  set pressedBg #d5d5cf }
	    }
	}

	"#e9e9e9 #f6f6f6" {	;# color scheme "Keramik White"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #ffffff }
		"platinum"			      { set pressedBg #c2c2c2 }
		"baghira"	{ set labelBg #f4f4f4;  set pressedBg #f1f1f1 }
		"highcolor"	{ set labelBg #f1f1f1;  set pressedBg #f6f6f6 }
		"keramik"	{ set labelBg #f7f7f7;  set pressedBg #e3e3e3 }
		"phase"		{ set labelBg #eaeaea;  set pressedBg #c2c2c2 }
		"plastik"	{ set labelBg #f1f1f1;  set pressedBg #cfcfcf }
		"qtcurve"	{ set labelBg #e6e6e6;  set pressedBg #c3c3c3 }
		"thinkeramik"	{ set labelBg #e8e8e8;  set pressedBg #d1d1d1 }
	    }
	}

	"#ebe9e9 #f6f4f4" {	;# color scheme "Lipstik Noble"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #ffffff }
		"platinum"			      { set pressedBg #c3c1c1 }
		"baghira"	{ set labelBg #f4f4f4;  set pressedBg #f1f1f1 }
		"highcolor"	{ set labelBg #f1f0f0;  set pressedBg #f6f4f4 }
		"keramik"	{ set labelBg #f7f6f6;  set pressedBg #e3e1e1 }
		"phase"		{ set labelBg #f5f4f4;  set pressedBg #c3c1c1 }
		"plastik"	{ set labelBg #f2f2f2;  set pressedBg #d3d2d2 }
		"qtcurve"	{ set labelBg #e9e6e6;  set pressedBg #c5c1c1 }
		"thinkeramik"	{ set labelBg #e9e8e8;  set pressedBg #d3d1d1 }
	    }
	}

	"#eeeee6 #eeeade" {	;# color scheme "Lipstik Standard"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #fffffc }
		"platinum"			      { set pressedBg #c6c6bf }
		"baghira"	{ set labelBg #f6f6f6;  set pressedBg #f3f2ee }
		"highcolor"	{ set labelBg #eeeae1;  set pressedBg #eeeade }
		"keramik"	{ set labelBg #f3f1e8;  set pressedBg #dddad1 }
		"phase"		{ set labelBg #eeeade;  set pressedBg #c6c6bf }
		"plastik"	{ set labelBg #ebe7dc;  set pressedBg #ccc9c0 }
		"qtcurve"	{ set labelBg #ecece3;  set pressedBg #ccccba }
		"thinkeramik"	{ set labelBg #ebebe5;  set pressedBg #d5d5cf }
	    }
	}

	"#eeeff2 #f7faff" {	;# color scheme "Lipstik White"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #ffffff }
		"platinum"			      { set pressedBg #c6c7c9 }
		"baghira"	{ set labelBg #f5f5f5;  set pressedBg #f2f2f3 }
		"highcolor"	{ set labelBg #f1f2f5;  set pressedBg #f1faff }
		"keramik"	{ set labelBg #f8f9fb;  set pressedBg #e3e5e8 }
		"phase"		{ set labelBg #f4f5f7;  set pressedBg #c6c7c9 }
		"plastik"	{ set labelBg #f3f4f7;  set pressedBg #d0d3d8 }
		"qtcurve"	{ set labelBg #ebecf0;  set pressedBg #c4c7ce }
		"thinkeramik"	{ set labelBg #ebecee;  set pressedBg #d5d6d8 }
	    }
	}

	"#f4ddb2 #f4ddb2" {	;# color scheme "Media Peach"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #ffebc7 }
		"platinum"			      { set pressedBg #cbb894 }
		"baghira"	{ set labelBg #fcfced;  set pressedBg #faf6df }
		"highcolor"	{ set labelBg #f0dbb6;  set pressedBg #f4ddb2 }
		"keramik"	{ set labelBg #f6e8c9;  set pressedBg #e1d0b0 }
		"phase"		{ set labelBg #f4ddb2;  set pressedBg #cbb894 }
		"plastik"	{ set labelBg #ffdbaf;  set pressedBg #d5c19c }
		"qtcurve"	{ set labelBg #f2dbaf;  set pressedBg #e0bd7f }
		"thinkeramik"	{ set labelBg #efe0c3;  set pressedBg #d9c8a7 }
	    }
	}

	"#a8a8a8 #a8a8a8" {	;# color scheme "Next"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #b8b8b8 }
		"platinum"			      { set pressedBg #8c8c8c }
		"baghira"	{ set labelBg #dedede;  set pressedBg #d3d3d3 }
		"highcolor"	{ set labelBg #aaaaaa;  set pressedBg #a8a8a8 }
		"keramik"	{ set labelBg #c2c2c2;  set pressedBg #a8a8a8 }
		"phase"		{ set labelBg #a9a9a9;  set pressedBg #8c8c8c }
		"plastik"	{ set labelBg #a5a5a5;  set pressedBg #898989 }
		"qtcurve"	{ set labelBg #a6a6a6;  set pressedBg #8d8d8d }
		"thinkeramik"	{ set labelBg #bdbdbd;  set pressedBg #a0a0a0 }
	    }
	}

	"#d6d6d6 #d6d6d6" {	;# color scheme "Pale Gray"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #ebebeb }
		"platinum"			      { set pressedBg #b2b2b2 }
		"baghira"	{ set labelBg #f2f2f2;  set pressedBg #e8e8e8 }
		"highcolor"	{ set labelBg #d9d9d9;  set pressedBg #d6d6d6 }
		"keramik"	{ set labelBg #e3e3e3;  set pressedBg #cbcbcb }
		"phase"		{ set labelBg #d6d6d6;  set pressedBg #b2b2b2 }
		"plastik"	{ set labelBg #d3d3d3;  set pressedBg #bababa }
		"qtcurve"	{ set labelBg #d4d4d4;  set pressedBg #b1b1b1 }
		"thinkeramik"	{ set labelBg #dbdbdb;  set pressedBg #c2c2c2 }
	    }
	}

	"#efefef #dddfe4" {	;# color scheme "Plastik"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #ffffff }
		"platinum"			      { set pressedBg #c7c7c7 }
		"baghira"	{ set labelBg #f5f5f5;  set pressedBg #ececee }
		"highcolor"	{ set labelBg #e0e1e7;  set pressedBg #dddfe4 }
		"keramik"	{ set labelBg #e8e9ed;  set pressedBg #d0d2d6 }
		"phase"		{ set labelBg #dee0e5;  set pressedBg #c7c7c7 }
		"plastik"	{ set labelBg #dbdde2;  set pressedBg #babcc0 }
		"qtcurve"	{ set labelBg #ececec;  set pressedBg #c9c9c9 }
		"thinkeramik"	{ set labelBg #ececec;  set pressedBg #d6d6d6 }
	    }
	}

	"#d3c5be #aba09a" {	;# color scheme "Point Reyes Green"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #e8d9d1 }
		"platinum"			      { set pressedBg #afa49e }
		"baghira"	{ set labelBg #f5efed;  set pressedBg #d7d0cd }
		"highcolor"	{ set labelBg #ada29d;  set pressedBg #aba09a }
		"keramik"	{ set labelBg #c4bcb8;  set pressedBg #aba29e }
		"phase"		{ set labelBg #d3c5be;  set pressedBg #afa49e }
		"plastik"	{ set labelBg #ab9f99;  set pressedBg #9b908a }
		"qtcurve"	{ set labelBg #d1c3bc;  set pressedBg #b3a197 }
		"thinkeramik"	{ set labelBg #d9d0cc;  set pressedBg #c0b6b1 }
	    }
	}

	"#eed8ae #eed8ae" {	;# color scheme "Pumpkin"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #ffe0c0 }
		"platinum"			      { set pressedBg #c6b390 }
		"baghira"	{ set labelBg #fcfbea;  set pressedBg #f9f4dd }
		"highcolor"	{ set labelBg #eed8b1;  set pressedBg #eed8ae }
		"keramik"	{ set labelBg #f3e4c6;  set pressedBg #ddcdad }
		"phase"		{ set labelBg #eed8ae;  set pressedBg #c6b390 }
		"plastik"	{ set labelBg #ebd5ac;  set pressedBg #cfbc96 }
		"qtcurve"	{ set labelBg #ebd6ab;  set pressedBg #d7b980 }
		"thinkeramik"	{ set labelBg #ebdcc0;  set pressedBg #d5c4a4 }
	    }
	}

	"#d4d0c8 #d4d0c8" {	;# color scheme "Redmond 2000"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #e9e5dc }
		"platinum"			      { set pressedBg #b0ada6 }
		"baghira"	{ set labelBg #f3f2ef;  set pressedBg #eae8e4 }
		"highcolor"	{ set labelBg #d7d3cb;  set pressedBg #d4d0c8 }
		"keramik"	{ set labelBg #e1ded9;  set pressedBg #cac7c1 }
		"phase"		{ set labelBg #d5d1c9;  set pressedBg #b0ada6 }
		"plastik"	{ set labelBg #d2cdc5;  set pressedBg #b2afa7 }
		"qtcurve"	{ set labelBg #d2cdc6;  set pressedBg #b4afa4 }
		"thinkeramik"	{ set labelBg #dad7d2;  set pressedBg #c1beb8 }
	    }
	}

	"#c3c3c3 #c3c3c3" {	;# color scheme "Redmond 95"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #d6d6d6 }
		"platinum"			      { set pressedBg #a2a2a2 }
		"baghira"	{ set labelBg #eaeaea;  set pressedBg #dfdfdf }
		"highcolor"	{ set labelBg #c5c5c5;  set pressedBg #c3c3c3 }
		"keramik"	{ set labelBg #d5d5d5;  set pressedBg #bdbdbd }
		"phase"		{ set labelBg #c4c4c4;  set pressedBg #a2a2a2 }
		"plastik"	{ set labelBg #c1c1c1;  set pressedBg #a3a3a3 }
		"qtcurve"	{ set labelBg #c1c1c1;  set pressedBg #a3a3a3 }
		"thinkeramik"	{ set labelBg #cecece;  set pressedBg #b5b5b5 }
	    }
	}

	"#eeeee6 #eeeade" {	;# color scheme "Redmond XP"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #fffffc }
		"platinum"			      { set pressedBg #c6c6bf }
		"baghira"	{ set labelBg #f6f6f6;  set pressedBg #f3f2ee }
		"highcolor"	{ set labelBg #eeeae1;  set pressedBg #eeeade }
		"keramik"	{ set labelBg #f3f1e8;  set pressedBg #dddad1 }
		"phase"		{ set labelBg #efefe7;  set pressedBg #c6c6bf }
		"plastik"	{ set labelBg #ebe7dc;  set pressedBg #c9c6bc }
		"qtcurve"	{ set labelBg #ecece3;  set pressedBg #cdcdbb }
		"thinkeramik"	{ set labelBg #ebebe5;  set pressedBg #d5d5cf }
	    }
	}

	"#aeb2c3 #aeb2c3" {	;# color scheme "Solaris"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #bfc3d6 }
		"platinum"			      { set pressedBg #9194a2 }
		"baghira"	{ set labelBg #e4e7ef;  set pressedBg #d9dbe4 }
		"highcolor"	{ set labelBg #b0b4c5;  set pressedBg #aeb2c3 }
		"keramik"	{ set labelBg #c6c9d5;  set pressedBg #adb0bd }
		"phase"		{ set labelBg #aeb2c3;  set pressedBg #9194a2 }
		"plastik"	{ set labelBg #abafc0;  set pressedBg #969aa9 }
		"qtcurve"	{ set labelBg #acb0c1;  set pressedBg #8d91a5 }
		"thinkeramik"	{ set labelBg #c0c3ce;  set pressedBg #a5a7b5 }
	    }
	}

	"#eeeaee #e6f0f9" {	;# color scheme "SuSE" old
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #ffffff }
		"platinum"			      { set pressedBg #c6c3c6 }
		"baghira"	{ set labelBg #f5f5f5;  set pressedBg #f1f3f5 }
		"highcolor"	{ set labelBg #eaeef2;  set pressedBg #e6f0f9 }
		"keramik"	{ set labelBg #eef4f8;  set pressedBg #d7dfe5 }
		"phase"		{ set labelBg #efecef;  set pressedBg #c6c3c6 }
		"plastik"	{ set labelBg #e3ecf3;  set pressedBg #c0c9d2 }
		"qtcurve"	{ set labelBg #ebe7eb;  set pressedBg #cac1ca }
		"thinkeramik"	{ set labelBg #ebe8eb;  set pressedBg #d5d2d5 }
	    }
	}

	"#eeeeee #f4f4f4" {	;# color scheme "SuSE" new
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #ffffff }
		"platinum"			      { set pressedBg #c6c6c6 }
		"baghira"	{ set labelBg #f5f5f5;  set pressedBg #f1f1f1 }
		"highcolor"	{ set labelBg #f0f0f0;  set pressedBg #f4f4f4 }
		"keramik"	{ set labelBg #f6f6f6;  set pressedBg #e1e1e1 }
		"phase"		{ set labelBg #efefef;  set pressedBg #c6c6c6 }
		"plastik"	{ set labelBg #f0f0f0;  set pressedBg #cdcdcd }
		"qtcurve"	{ set labelBg #ebebeb;  set pressedBg #c7c7c7 }
		"thinkeramik"	{ set labelBg #ebebeb;  set pressedBg #d5d5d5 }
	    }
	}

	"#eaeaea #eaeaea" {	;# color scheme "SUSE-kdm"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #ffffff }
		"platinum"			      { set pressedBg #c3c3c3 }
		"baghira"	{ set labelBg #f4f4f4;  set pressedBg #efefef }
		"highcolor"	{ set labelBg #ececec;  set pressedBg #eaeaea }
		"keramik"	{ set labelBg #f1f1f1;  set pressedBg #dadada }
		"phase"		{ set labelBg #ebebeb;  set pressedBg #c3c3c3 }
		"plastik"	{ set labelBg #e7e7e7;  set pressedBg #c6c6c6 }
		"qtcurve"	{ set labelBg #e7e7e7;  set pressedBg #c4c4c4 }
		"thinkeramik"	{ set labelBg #e8e8e8;  set pressedBg #d2d2d2 }
	    }
	}

	"#d3d3d3 #d3d3d3" {	;# color scheme "System"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #e8e8e8 }
		"platinum"			      { set pressedBg #afafaf }
		"baghira"	{ set labelBg #f0f0f0;  set pressedBg #e6e6e6 }
		"highcolor"	{ set labelBg #d6d6d6;  set pressedBg #d3d3d3 }
		"keramik"	{ set labelBg #e1e1e1;  set pressedBg #c9c9c9 }
		"phase"		{ set labelBg #d2d2d2;  set pressedBg #afafaf }
		"plastik"	{ set labelBg #d0d0d0;  set pressedBg #b9b9b9 }
		"qtcurve"	{ set labelBg #d1d1d1;  set pressedBg #aeaeae }
		"thinkeramik"	{ set labelBg #d9d9d9;  set pressedBg #c0c0c0 }
	    }
	}

	"#e6e6de #f0f0ef" {	;# color scheme "Thin Keramik" old
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #fdfdf4 }
		"platinum"			      { set pressedBg #bfbfb8 }
		"baghira"	{ set labelBg #f6f6f5;  set pressedBg #f0f0f0 }
		"highcolor"	{ set labelBg #eeeeee;  set pressedBg #f0f0ef }
		"keramik"	{ set labelBg #f4f4f4;  set pressedBg #dfdfde }
		"phase"		{ set labelBg #e7e7df;  set pressedBg #bfbfb8 }
		"plastik"	{ set labelBg #ededeb;  set pressedBg #cbcbc9 }
		"qtcurve"	{ set labelBg #e3e3db;  set pressedBg #c4c4b6 }
		"thinkeramik"	{ set labelBg #e6e6e1;  set pressedBg #cfcfc9 }
	    }
	}

	"#edede1 #f6f6e9" {	;# color scheme "Thin Keramik" new
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #fffff7 }
		"platinum"			      { set pressedBg #c5c5bb }
		"baghira"	{ set labelBg #f6f6f5;  set pressedBg #f3f3f1 }
		"highcolor"	{ set labelBg #f1f1ec;  set pressedBg #f6f6e9 }
		"keramik"	{ set labelBg #f7f7f0;  set pressedBg #e3e3da }
		"phase"		{ set labelBg #edede1;  set pressedBg #c5c5bb }
		"plastik"	{ set labelBg #f4f4e6;  set pressedBg #ddddd0 }
		"qtcurve"	{ set labelBg #ebebde;  set pressedBg #cbcbb3 }
		"thinkeramik"	{ set labelBg #eaeae3;  set pressedBg #d4d4cb }
	    }
	}

	"#f6f5e8 #eeeade" {	;# color scheme "Thin Keramik II"
	    switch -- $style {
		"light, 3rd revision"		      { set pressedBg #ffffff }
		"platinum"			      { set pressedBg #cdccc1 }
		"baghira"	{ set labelBg #f7f7f7;  set pressedBg #f3f2ee }
		"highcolor"	{ set labelBg #eeeae1;  set pressedBg #eeeade }
		"keramik"	{ set labelBg #f3f1e8;  set pressedBg #dddad1 }
		"phase"		{ set labelBg #f3f2e9;  set pressedBg #cdccc1 }
		"plastik"	{ set labelBg #ebe7dc;  set pressedBg #c9c6bc }
		"qtcurve"	{ set labelBg #f4f2e5;  set pressedBg #dbd8b6 }
		"thinkeramik"	{ set labelBg #f1f1e8;  set pressedBg #dbdad0 }
	    }
	}

	"#d4d7d0 #babdb7" {	;# color scheme "Honeycomb"
	    switch -- $style {
		"cde" -
		"motif"				      { set pressedBg #b1b4ae }
		"plastique"	{ set labelBg #b8bbb5;  set pressedBg #c1c4be }
	    }
	}

	"#ebe2d2 #f7f2e8" {	;# color scheme "Norway"
	    switch -- $style {
		"cde" -
		"motif"				      { set pressedBg #c8bba3 }
		"plastique"	{ set labelBg #f4f0e6;  set pressedBg #d6cfbf }
	    }
	}

	"#302f2f #403f3e" {	;# color scheme "Obsidian Coast"
	    switch -- $style {
		"cde" -
		"motif"				      { set pressedBg #2a2929 }
		"plastique"	{ set labelBg #3f3e3d;  set pressedBg #2b2a2a }
	    }
	}

	"#d6d2d0 #dfdcd9" {	;# color schemes "Oxygen" and "Standard"
	    switch -- $style {
		"cde" -
		"motif"				      { set pressedBg #b6aeaa }
		"plastique"	{ set labelBg #dddad7;  set pressedBg #c3bfbe }
	    }
	}

	"#e0dfde #e8e7e6" {	;# c. s. "Oxygen Cold" and "Oxygen-Molecule 3.0"
	    switch -- $style {
		"cde" -
		"motif"				      { set pressedBg #bbb9b8 }
		"plastique"	{ set labelBg #e6e5e4;  set pressedBg #cdcccb }
	    }
	}

	"#e0dfd8 #e8e7df" {	;# color scheme "Steel"
	    switch -- $style {
		"cde" -
		"motif"				      { set pressedBg #babab4 }
		"plastique"	{ set labelBg #e6e5dd;  set pressedBg #cdccc5 }
	    }
	}

	"#494e58 #525863" {	;# color scheme "Wonton Soup"
	    switch -- $style {
		"cde" -
		"motif"				      { set pressedBg #3f444c }
		"plastique"	{ set labelBg #515762;  set pressedBg #424650 }
	    }
	}

	"#fcfcfc #ffffff" {	;# color scheme "Zion"
	    switch -- $style {
		"cde" -
		"motif"				      { set pressedBg #dedede }
		"plastique"	{ set labelBg #f9f9f9;  set pressedBg #e5e5e5 }
	    }
	}

	"#101010 #000000" {	;# color scheme "Zion (Reversed)"
	    switch -- $style {
		"cde" -
		"motif"				      { set pressedBg #5e5e5e }
		"plastique"	{ set labelBg #000000;  set pressedBg #0e0e0e }
	    }
	}
    }

    #
    # For some Qt styles the label colors are independent of the color scheme:
    #
    switch -- $style {
	"acqua" {
	    set labelBg #e7e7e7;  set labelFg #000000;  set pressedBg #8fbeec
	}

	"gtk+" {
	    set labelBg #e8e7e6;			set pressedBg $labelBg
	}

	"kde_xp" {
	    set labelBg #ebeadb;  set labelFg #000000;  set pressedBg #faf8f3
	}

	"lipstik" -
	"oxygen" {
	    set labelBg $bg;				set pressedBg $labelBg
	}

	"marble" {
	    set labelBg #cccccc;  set labelFg $fg;      set pressedBg $labelBg
	}

	"riscos" {
	    set labelBg #dddddd;  set labelFg #000000;  set pressedBg $labelBg
	}

	"system" -
	"systemalt" {
	    set labelBg #cbcbcb;  set labelFg #000000;  set pressedBg $labelBg
	}
    }

    #
    # The stripe background color is specified
    # by a global KDE configuration option:
    #
    if {[info exists ::env(KDE_SESSION_VERSION)] &&
	$::env(KDE_SESSION_VERSION) ne ""} {
	set val [getKdeConfigVal "Colors:View" "BackgroundAlternate"]
    } else {
	set val [getKdeConfigVal "General" "alternateBackground"]
    }
    if {$val eq "" || [string index $val 0] eq "#"} {
	set stripeBg $val
    ##nagelfar ignore
    } elseif {[scan $val "%d,%d,%d" r g b] == 3} {
	set stripeBg [format "#%02x%02x%02x" $r $g $b]
    } else {
	set stripeBg ""
    }

    #
    # The arrow color and style depend mainly on the current Qt style:
    #
    switch -- $style {
	"highcontrast" -
	"light, 2nd revision" -
	"light, 3rd revision" -
	"lipstik" -
	"phase" -
	"plastik"	{ set arrowColor $labelFg; set arrowStyle flat7x4 }

	"baghira"	{ set arrowColor $labelFg; set arrowStyle flat7x7 }

	"cleanlooks" -
	"gtk+" -
	"oxygen"	{ set arrowColor $labelFg; set arrowStyle flatAngle9x6 }

	"phase"		{ set arrowColor $labelFg; set arrowStyle flat7x4 }

	"qtcurve"	{ set arrowColor $labelFg; set arrowStyle flatAngle7x5 }

	"keramik" -
	"thinkeramik"	{ set arrowColor $labelFg; set arrowStyle flat8x5 }

	default		{ set arrowColor "";	   set arrowStyle sunken12x11 }
    }

    #
    # The tree style depends on the current Qt style:
    #
    switch -- $style {
	"baghira" -
	"cde" -
	"motif"		{ set treeStyle baghira }
	"gtk+"		{ set treeStyle gtk }
	"oxygen"	{ set treeStyle oxygen2 }
	"phase"		{ set treeStyle phase }
	"plastik"	{ set treeStyle plastik }
	"plastique"	{ set treeStyle plastique }
	"qtcurve"	{ set treeStyle klearlooks }
	default		{ set treeStyle winnative }
    }

    variable themeDefaults
    array set themeDefaults [list \
	-background		$tableBg \
	-foreground		$tableFg \
	-disabledforeground	$tableDisFg \
	-stripebackground	$stripeBg \
	-selectbackground	$selectBg \
	-selectforeground	$selectFg \
	-selectborderwidth	0 \
	-labelbackground	$labelBg \
	-labeldeactivatedBg	$labelBg \
	-labeldisabledBg	$labelBg \
	-labelactiveBg		$labelBg \
	-labelpressedBg		$pressedBg \
	-labelforeground	$labelFg \
	-labeldisabledFg	$labelDisFg \
	-labelactiveFg		$labelFg \
	-labelpressedFg		$labelFg \
	-labelborderwidth	4 \
	-labelpady		0 \
	-arrowcolor		$arrowColor \
	-arrowstyle		$arrowStyle \
	-treestyle		$treeStyle \
    ]
}

#------------------------------------------------------------------------------
# tablelist::vistaTheme
#------------------------------------------------------------------------------
proc tablelist::vistaTheme {} {
    variable themeDefaults
    array set themeDefaults [list \
	-background		SystemWindow \
	-foreground		SystemWindowText \
	-disabledforeground	SystemDisabledText \
	-stripebackground	"" \
	-selectborderwidth	0 \
	-labelforeground	SystemButtonText \
	-labeldisabledFg	SystemDisabledText \
	-labelactiveFg		SystemButtonText \
	-labelpressedFg		SystemButtonText \
    ]

    if {$::tcl_platform(osVersion) >= 10.0} {			;# Win 10
	set selectBg	#cce8ff
	set selectFg	SystemWindowText
	set labelBg	#ffffff
	set activeBg	#d9ebf9
	set pressedBg	#bcdcf4
	set labelBd	4
	set labelPadY	4
	set arrowColor	#595959
	set arrowStyle	flatAngle[defaultWinArrowSize]
	set treeStyle	win10

    } elseif {[mwutil::normalizeColor SystemHighlight] eq
	      "#3399ff"} {					;# Aero
	set selectFg	SystemWindowText
	set labelBd	4
	set labelPadY	4

	if {$::tcl_platform(osVersion) < 6.2} {			;# Win Vista/7
	    set labelBg		#ffffff
	    set activeBg	#e3f7ff
	    set pressedBg	#Bce4f9
	    set arrowColor	#569bc0
	    set arrowStyle	photo[defaultWinArrowSize]
	} else {						;# Win 8
	    set labelBg		#fcfcfc
	    set activeBg	#f4f9ff
	    set pressedBg	#f9fafb
	    set arrowColor	#569bc0
	    set arrowStyle	photo[defaultWinArrowSize]
	}

	if {$::tcl_platform(osVersion) == 6.0} {		;# Win Vista
	    set selectBg	#d8effb
	    set treeStyle	vistaAero
	} elseif {$::tcl_platform(osVersion) == 6.1} {		;# Win 7
	    set selectBg	#cee2fc
	    set treeStyle	win7Aero
	} else {						;# Win 8
	    set selectBg	#cbe8f6
	    set treeStyle	win7Aero
	}

    } else {							;# Win Classic
	set selectBg	SystemHighlight
	set selectFg	SystemHighlightText
	set labelBg	SystemButtonFace
	set activeBg	SystemButtonFace
	set pressedBg	SystemButtonFace
	set labelBd	2
	set labelPadY	0
	set arrowColor	SystemButtonShadow
	set arrowStyle	flat[defaultWinArrowSize]

	if {$::tcl_platform(osVersion) == 6.0} {		;# Win Vista
	    set treeStyle	vistaClassic
	} else {						;# Win 7/8
	    set treeStyle	win7Classic
	}
    }

    variable scalingpct
    array set themeDefaults [list \
	-selectbackground	$selectBg \
	-selectforeground	$selectFg \
	-labelbackground	$labelBg \
	-labeldeactivatedBg	$labelBg \
	-labeldisabledBg	$labelBg \
	-labelactiveBg		$activeBg \
	-labelpressedBg		$pressedBg \
	-labelborderwidth	$labelBd \
	-labelpady		[scaleutil::scale $labelPadY $scalingpct] \
	-arrowcolor		$arrowColor \
	-arrowstyle		$arrowStyle \
	-treestyle		$treeStyle \
    ]
}

#------------------------------------------------------------------------------
# tablelist::winnativeTheme
#------------------------------------------------------------------------------
proc tablelist::winnativeTheme {} {
    variable themeDefaults
    array set themeDefaults [list \
	-background		SystemWindow \
	-foreground		SystemWindowText \
	-disabledforeground	SystemDisabledText \
	-stripebackground	"" \
	-selectbackground	SystemHighlight \
	-selectforeground	SystemHighlightText \
	-selectborderwidth	0 \
	-labelbackground	SystemButtonFace \
	-labeldeactivatedBg	SystemButtonFace \
	-labeldisabledBg	SystemButtonFace \
	-labelactiveBg		SystemButtonFace \
	-labelpressedBg		SystemButtonFace \
	-labelforeground	SystemButtonText \
	-labeldisabledFg	SystemDisabledText \
	-labelactiveFg		SystemButtonText \
	-labelpressedFg		SystemButtonText \
	-labelborderwidth	2 \
	-labelpady		0 \
	-arrowcolor		"" \
	-arrowstyle		sunken8x7 \
	-treestyle		winnative \
    ]
}

#------------------------------------------------------------------------------
# tablelist::winxpblueTheme
#------------------------------------------------------------------------------
proc tablelist::winxpblueTheme {} {
    variable themeDefaults
    array set themeDefaults [list \
	-disabledforeground	#565248 \
	-stripebackground	"" \
	-selectbackground	#4a6984 \
	-selectforeground	#ffffff \
	-selectborderwidth	0 \
	-labelbackground	#ece9d8 \
	-labeldeactivatedBg	#ece9d8 \
	-labeldisabledBg	#e3e1dd \
	-labelactiveBg		#c1d2ee \
	-labelpressedBg		#bab5ab \
	-labeldisabledFg	#565248 \
	-labelborderwidth	1 \
	-labelpady		1 \
	-arrowcolor		#4d6185 \
	-arrowstyle		flat7x4 \
	-treestyle		winxpBlue \
    ]
}

#------------------------------------------------------------------------------
# tablelist::xpnativeTheme
#------------------------------------------------------------------------------
proc tablelist::xpnativeTheme {} {
    variable xpStyle
    variable themeDefaults
    array set themeDefaults [list \
	-background		SystemWindow \
	-foreground		SystemWindowText \
	-disabledforeground	SystemDisabledText \
	-stripebackground	"" \
	-selectborderwidth	0 \
	-labelforeground	SystemButtonText \
	-labeldisabledFg	SystemDisabledText \
	-labelactiveFg		SystemButtonText \
	-labelpressedFg		SystemButtonText \
    ]

    if {$::tcl_platform(osVersion) >= 10.0} {			;# Win 10
	set xpStyle	0
	set selectBg	#cce8ff
	set selectFg	SystemWindowText
	set labelBg	#ffffff
	set activeBg	#d9ebf9
	set pressedBg	#bcdcf4
	set labelBd	4
	set labelPadY	4
	set arrowColor	#595959
	set arrowStyle	flatAngle[defaultWinArrowSize]
	set treeStyle	win10

    } else {
	switch [mwutil::normalizeColor SystemHighlight] {
	    #316ac5 {						;# Win XP Blue
		set xpStyle	1
		set selectBg	SystemHighlight
		set selectFg	SystemHighlightText
		set labelBg	#ebeadb
		set activeBg	#faf8f3
		set pressedBg	#dedfd8
		set labelBd	4
		set labelPadY	4
		set arrowColor	#aca899
		set arrowStyle	flat9x5
		set treeStyle	winxpBlue

		if {[info exists ::tile::version] &&
		    [string compare $::tile::version "0.7"] < 0} {
		    set labelBd 0
		}
	    }

	    #93a070 {						;# Win XP Olive
		set xpStyle	1
		set selectBg	SystemHighlight
		set selectFg	SystemHighlightText
		set labelBg	#ebeadb
		set activeBg	#faf8f3
		set pressedBg	#dedfd8
		set labelBd	4
		set labelPadY	4
		set arrowColor	#aca899
		set arrowStyle	flat9x5
		set treeStyle	winxpOlive

		if {[info exists ::tile::version] &&
		    [string compare $::tile::version "0.7"] < 0} {
		    set labelBd 0
		}
	    }

	    #b2b4bf {						;# Win XP Silver
		set xpStyle	1
		set selectBg	SystemHighlight
		set selectFg	SystemHighlightText
		set labelBg	#f9fafd
		set activeBg	#fefefe
		set pressedBg	#ececf3
		set labelBd	4
		set labelPadY	4
		set arrowColor	#aca899
		set arrowStyle	flat9x5
		set treeStyle	winxpSilver

		if {[info exists ::tile::version] &&
		    [string compare $::tile::version "0.7"] < 0} {
		    set labelBd 0
		}
	    }

	    #3399ff {						;# Aero
		set xpStyle	0
		set selectFg	SystemWindowText
		set labelBd	4
		set labelPadY	4

		if {$::tcl_platform(osVersion) < 6.2} {		;# Win Vista/7
		    set labelBg	#ffffff
		    set activeBg	#e3f7ff
		    set pressedBg	#Bce4f9
		    set arrowColor	#569bc0
		    set arrowStyle	photo[defaultWinArrowSize]
		} else {					;# Win 8
		    set labelBg	#fcfcfc
		    set activeBg	#f4f9ff
		    set pressedBg	#f9fafb
		    set arrowColor	#569bc0
		    set arrowStyle	photo[defaultWinArrowSize]
		}

		if {$::tcl_platform(osVersion) == 6.0} {	;# Win Vista
		    set selectBg	#d8effb
		    set treeStyle	vistaAero
		} elseif {$::tcl_platform(osVersion) == 6.1} {	;# Win 7
		    set selectBg	#cee2fc
		    set treeStyle	win7Aero
		} else {					;# Win 8
		    set selectBg	#cbe8f6
		    set treeStyle	win7Aero
		}
	    }

	    default {						;# Win Classic
		set xpStyle	0
		set selectBg	SystemHighlight
		set selectFg	SystemHighlightText
		set labelBg	SystemButtonFace
		set activeBg	SystemButtonFace
		set pressedBg	SystemButtonFace
		set labelBd	2
		set labelPadY	0
		set arrowColor	SystemButtonShadow
		set arrowStyle	flat[defaultWinArrowSize]

		if {$::tcl_platform(osVersion) == 6.0} {	;# Win Vista
		    set treeStyle	vistaClassic
		} else {					;# Win 7/8
		    set treeStyle	win7Classic
		}
	    }
	}
    }

    variable scalingpct
    array set themeDefaults [list \
	-selectbackground	$selectBg \
	-selectforeground	$selectFg \
	-labelbackground	$labelBg \
	-labeldeactivatedBg	$labelBg \
	-labeldisabledBg	$labelBg \
	-labelactiveBg		$activeBg \
	-labelpressedBg		$pressedBg \
	-labelborderwidth	$labelBd \
	-labelpady		[scaleutil::scale $labelPadY $scalingpct] \
	-arrowcolor		$arrowColor \
	-arrowstyle		$arrowStyle \
	-treestyle		$treeStyle \
    ]
}

#
# Private procedures related to global KDE configuration options
# ==============================================================
#

#------------------------------------------------------------------------------
# tablelist::getKdeConfigVal
#
# Returns the value of the global KDE configuration option identified by the
# given group (section) and key.
#------------------------------------------------------------------------------
proc tablelist::getKdeConfigVal {group key} {
    variable kdeDirList

    if {![info exists kdeDirList]} {
	makeKdeDirList
    }

    #
    # Search for the entry corresponding to the given group and key in
    # the file "share/config/kdeglobals" within the KDE directories
    #
    foreach dir $kdeDirList {
	set fileName [file join $dir "share/config/kdeglobals"]
	if {[set val [readKdeConfigVal $fileName $group $key]] ne ""} {
	    return $val
	}
    }
    return ""
}

#------------------------------------------------------------------------------
# tablelist::makeKdeDirList
#
# Builds the list of the directories to be considered when searching for global
# KDE configuration options.
#------------------------------------------------------------------------------
proc tablelist::makeKdeDirList {} {
    variable kdeDirList {}

    if {[info exists ::env(KDE_SESSION_VERSION)]} {
	set ver $::env(KDE_SESSION_VERSION)
    } else {
	set ver ""
    }

    if {[info exists ::env(USER)] && $::env(USER) eq "root"} {
	set name "KDEROOTHOME"
    } else {
	set name "KDEHOME"
    }
    if {[info exists ::env($name)] && $::env($name) ne ""} {
	set localKdeDir [file normalize $::env($name)]
    } elseif {[info exists ::env(HOME)] && $::env(HOME) ne ""} {
	set localKdeDir [file normalize [file join $::env(HOME) ".kde$ver"]]
    }
    if {[info exists localKdeDir] && $localKdeDir ne "-"} {
	lappend kdeDirList $localKdeDir
    }

    if {[info exists ::env(KDEDIRS)] && $::env(KDEDIRS) ne ""} {
	foreach dir [split $::env(KDEDIRS) ":"] {
	    if {$dir ne ""} {
		lappend kdeDirList $dir
	    }
	}
    } elseif {[info exists ::env(KDEDIR)] && $::env(KDEDIR) ne ""} {
	lappend kdeDirList $::env(KDEDIR)
    }

    set prefix [exec kde$ver-config --expandvars --prefix]
    lappend kdeDirList $prefix

    set execPrefix [exec kde$ver-config --expandvars --exec-prefix]
    if {$execPrefix ne $prefix} {
	lappend kdeDirList $execPrefix
    }
}

#------------------------------------------------------------------------------
# tablelist::readKdeConfigVal
#
# Reads the value of the global KDE configuration option identified by the
# given group (section) and key from the specified file.  Note that the
# procedure performs a case-sensitive search and only works as expected for
# "simple" group and key names.
#------------------------------------------------------------------------------
proc tablelist::readKdeConfigVal {fileName group key} {
    if {[catch {open $fileName r} chan] != 0} {
	return ""
    }

    #
    # Search for the specified group
    #
    set groupFound 0
    while {[gets $chan line] >= 0} {
	set line [string trim $line]
	if {$line eq "\[$group\]"} {
	    set groupFound 1
	    break
	}
    }
    if {!$groupFound} {
	close $chan
	return ""
    }

    #
    # Search for the specified key within the group
    #
    set pattern "^$key\\s*=\\s*(.+)$"
    set keyFound 0
    while {[gets $chan line] >= 0} {
	set line [string trim $line]
	if {[string index $line 0] eq "\["} {
	    break
	}

	if {[regexp $pattern $line dummy val]} {
	    set keyFound 1
	    break
	}
    }

    close $chan
    return [expr {$keyFound ? $val : ""}]
}
