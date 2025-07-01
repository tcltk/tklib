#==============================================================================
# Contains procedures that create the Switch*.trough and Switch*.slider
# elements for the Toggleswitch* styles.
#
# Copyright (c) 2025  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#------------------------------------------------------------------------------
# tsw::svgFormat
#------------------------------------------------------------------------------
proc tsw::svgFormat {} {
    if {[info exists ::tk::svgFmt]} {			;# Tk 8.7b1/9 or later
	return $::tk::svgFmt
    } else {
	return [list svg -scale [expr {$::scaleutil::scalingPct / 100.0}]]
    }
}

interp alias {} tsw::createSvgImg {} image create photo -format [tsw::svgFormat]

#------------------------------------------------------------------------------
# tsw::createElements_default
#------------------------------------------------------------------------------
proc tsw::createElements_default {} {
    variable elemInfoArr
    if {[info exists elemInfoArr(default)]} {
	return ""
    }

    set troughData(1) {
<svg width="32" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="32" height="16" rx="8" }
    set troughData(2) {
<svg width="40" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="40" height="20" rx="10" }
    set troughData(3) {
<svg width="48" height="24" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="48" height="24" rx="12" }

    set sliderData(1) {
<svg width="16" height="12" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="8" cy="6" r="6" fill="#ffffff"/>
</svg>}
    set sliderData(2) {
<svg width="20" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="10" cy="8" r="8" fill="#ffffff"/>
</svg>}
    set sliderData(3) {
<svg width="24" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="12" cy="10" r="10" fill="#ffffff"/>
</svg>}

    variable onAndroid
    foreach n {1 2 3} {
	# troughOffImg
	set imgData $troughData($n)
	append imgData "fill='#c3c3c3'/>\n</svg>"
	set troughOffImg [createSvgImg -data $imgData]

	# troughOffActiveImg
	set imgData $troughData($n)
	set fill [expr {$onAndroid ? "#c3c3c3" : "#b3b3b3"}]
	append imgData "fill='$fill'/>\n</svg>"
	set troughOffActiveImg [createSvgImg -data $imgData]

	# troughOffPressedImg
	set imgData $troughData($n)
	append imgData "fill='#a3a3a3'/>\n</svg>"
	set troughOffPressedImg [createSvgImg -data $imgData]

	# troughOffDisabledImg
	set imgData $troughData($n)
	append imgData "fill='#cecece'/>\n</svg>"
	set troughOffDisabledImg [createSvgImg -data $imgData]

	# troughOnImg
	set imgData $troughData($n)
	append imgData "fill='#4a6984'/>\n</svg>"
	set troughOnImg [createSvgImg -data $imgData]

	# troughOnActiveImg
	set imgData $troughData($n)
	set fill [expr {$onAndroid ? "#4a6984" : "#587d9e"}]
	append imgData "fill='$fill'/>\n</svg>"
	set troughOnActiveImg [createSvgImg -data $imgData]

	# troughOnPressedImg
	set imgData $troughData($n)
	append imgData "fill='#6792b7'/>\n</svg>"
	set troughOnPressedImg [createSvgImg -data $imgData]

	# troughOnDisabledImg
	set imgData $troughData($n)
	append imgData "fill='#a9d7ff'/>\n</svg>"
	set troughOnDisabledImg [createSvgImg -data $imgData]

	ttk::style element create Switch$n.trough image [list $troughOffImg \
	    {selected disabled}	$troughOnDisabledImg \
	    {selected pressed}	$troughOnPressedImg \
	    {selected active}	$troughOnActiveImg \
	    selected		$troughOnImg \
	    disabled		$troughOffDisabledImg \
	    pressed		$troughOffPressedImg \
	    active		$troughOffActiveImg \
	]

	# sliderImg
	set sliderImg [createSvgImg -data $sliderData($n)]

	ttk::style element create Switch$n.slider image $sliderImg

	ttk::style layout Toggleswitch$n [list \
	    Switch.focus -sticky nswe -children [list \
		Switch.padding -sticky nswe -children [list \
		    Switch$n.trough -sticky {} -children [list \
			Switch$n.slider -side left -sticky {}
		    ]
		]
	    ]
	]
    }

    set elemInfoArr(default) 1
}

#------------------------------------------------------------------------------
# tsw::createElements_default-dark
#------------------------------------------------------------------------------
proc tsw::createElements_default-dark {} {
    variable elemInfoArr
    if {[info exists elemInfoArr(default-dark)]} {
	return ""
    }

    set troughData(1) {
<svg width="32" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="32" height="16" rx="8" }
    set troughData(2) {
<svg width="40" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="40" height="20" rx="10" }
    set troughData(3) {
<svg width="48" height="24" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="48" height="24" rx="12" }

    set sliderData(1) {
<svg width="16" height="12" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="8" cy="6" r="6" }
    set sliderData(2) {
<svg width="20" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="10" cy="8" r="8" }
    set sliderData(3) {
<svg width="24" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="12" cy="10" r="10" }

    variable onAndroid
    foreach n {1 2 3} {
	# troughOffImg
	set imgData $troughData($n)
	append imgData "fill='#585858'/>\n</svg>"
	set troughOffImg [createSvgImg -data $imgData]

	# troughOffActiveImg
	set imgData $troughData($n)
	set fill [expr {$onAndroid ? "#585858" : "#676767"}]
	append imgData "fill='$fill'/>\n</svg>"
	set troughOffActiveImg [createSvgImg -data $imgData]

	# troughOffPressedImg
	set imgData $troughData($n)
	append imgData "fill='#787878'/>\n</svg>"
	set troughOffPressedImg [createSvgImg -data $imgData]

	# troughOffDisabledImg
	set imgData $troughData($n)
	append imgData "fill='#4a4a4a'/>\n</svg>"
	set troughOffDisabledImg [createSvgImg -data $imgData]

	# troughOnImg
	set imgData $troughData($n)
	append imgData "fill='#4a6984'/>\n</svg>"
	set troughOnImg [createSvgImg -data $imgData]

	# troughOnActiveImg
	set imgData $troughData($n)
	set fill [expr {$onAndroid ? "#4a6984" : "#587d9e"}]
	append imgData "fill='$fill'/>\n</svg>"
	set troughOnActiveImg [createSvgImg -data $imgData]

	# troughOnPressedImg
	set imgData $troughData($n)
	append imgData "fill='#6792b7'/>\n</svg>"
	set troughOnPressedImg [createSvgImg -data $imgData]

	# troughOnDisabledImg
	set imgData $troughData($n)
	append imgData "fill='#3c556b'/>\n</svg>"
	set troughOnDisabledImg [createSvgImg -data $imgData]

	ttk::style element create DarkSwitch$n.trough image [list \
	    $troughOffImg \
	    {selected disabled}	$troughOnDisabledImg \
	    {selected pressed}	$troughOnPressedImg \
	    {selected active}	$troughOnActiveImg \
	    selected		$troughOnImg \
	    disabled		$troughOffDisabledImg \
	    pressed		$troughOffPressedImg \
	    active		$troughOffActiveImg \
	]

	# sliderOffImg
	set imgData $sliderData($n)
	append imgData "fill='#d3d3d3'/>\n</svg>"
	set sliderOffImg [createSvgImg -data $imgData]

	# sliderOffDisabledImg
	set imgData $sliderData($n)
	append imgData "fill='#888888'/>\n</svg>"
	set sliderOffDisabledImg [createSvgImg -data $imgData]

	# sliderOnDisabledImg
	set imgData $sliderData($n)
	append imgData "fill='#9f9f9f'/>\n</svg>"
	set sliderOnDisabledImg [createSvgImg -data $imgData]

	# sliderImg
	set imgData $sliderData($n)
	append imgData "fill='#ffffff'/>\n</svg>"
	set sliderImg [createSvgImg -data $imgData]

	ttk::style element create DarkSwitch$n.slider image [list \
	    $sliderOffImg \
	    {selected disabled}	$sliderOnDisabledImg \
	    selected		$sliderImg \
	    disabled		$sliderOffDisabledImg \
	    pressed		$sliderImg \
	    active		$sliderImg \
	]
    }

    set elemInfoArr(default-dark) 1
}

#------------------------------------------------------------------------------
# tsw::createElements_clam
#------------------------------------------------------------------------------
proc tsw::createElements_clam {} {
    set troughData(1) {
<svg width="32" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="32" height="16" rx="8" }
    set troughData(2) {
<svg width="40" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="40" height="20" rx="10" }
    set troughData(3) {
<svg width="48" height="24" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="48" height="24" rx="12" }

    set sliderData(1) {
<svg width="16" height="12" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="8" cy="6" r="6" fill="#ffffff"/>
</svg>}
    set sliderData(2) {
<svg width="20" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="10" cy="8" r="8" fill="#ffffff"/>
</svg>}
    set sliderData(3) {
<svg width="24" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="12" cy="10" r="10" fill="#ffffff"/>
</svg>}

    variable onAndroid
    foreach n {1 2 3} {
	# troughOffImg
	set imgData $troughData($n)
	append imgData "fill='#bab5ab'/>\n</svg>"
	set troughOffImg [createSvgImg -data $imgData]

	# troughOffActiveImg
	set imgData $troughData($n)
	set fill [expr {$onAndroid ? "#bab5ab" : "#aca79e"}]
	append imgData "fill='$fill'/>\n</svg>"
	set troughOffActiveImg [createSvgImg -data $imgData]

	# troughOffPressedImg
	set imgData $troughData($n)
	append imgData "fill='#9e9a91'/>\n</svg>"
	set troughOffPressedImg [createSvgImg -data $imgData]

	# troughOffDisabledImg
	set imgData $troughData($n)
	append imgData "fill='#cfc9be'/>\n</svg>"
	set troughOffDisabledImg [createSvgImg -data $imgData]

	# troughOnImg
	set imgData $troughData($n)
	append imgData "fill='#4a6984'/>\n</svg>"
	set troughOnImg [createSvgImg -data $imgData]

	# troughOnActiveImg
	set imgData $troughData($n)
	set fill [expr {$onAndroid ? "#4a6984" : "#587d9e"}]
	append imgData "fill='$fill'/>\n</svg>"
	set troughOnActiveImg [createSvgImg -data $imgData]

	# troughOnPressedImg
	set imgData $troughData($n)
	append imgData "fill='#6792b7'/>\n</svg>"
	set troughOnPressedImg [createSvgImg -data $imgData]

	# troughOnDisabledImg
	set imgData $troughData($n)
	append imgData "fill='#a9d7ff'/>\n</svg>"
	set troughOnDisabledImg [createSvgImg -data $imgData]

	ttk::style element create Switch$n.trough image [list $troughOffImg \
	    {selected disabled}	$troughOnDisabledImg \
	    {selected pressed}	$troughOnPressedImg \
	    {selected active}	$troughOnActiveImg \
	    selected		$troughOnImg \
	    disabled		$troughOffDisabledImg \
	    pressed		$troughOffPressedImg \
	    active		$troughOffActiveImg \
	]

	# sliderImg
	set sliderImg [createSvgImg -data $sliderData($n)]

	ttk::style element create Switch$n.slider image $sliderImg
    }
}

#------------------------------------------------------------------------------
# tsw::createElements_droid
#------------------------------------------------------------------------------
proc tsw::createElements_droid {} {
    set troughData(1) {
<svg width="32" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="32" height="16" rx="8" }
    set troughData(2) {
<svg width="40" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="40" height="20" rx="10" }
    set troughData(3) {
<svg width="48" height="24" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="48" height="24" rx="12" }

    set sliderData(1) {
<svg width="16" height="12" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="8" cy="6" r="6" fill="#ffffff"/>
</svg>}
    set sliderData(2) {
<svg width="20" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="10" cy="8" r="8" fill="#ffffff"/>
</svg>}
    set sliderData(3) {
<svg width="24" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="12" cy="10" r="10" fill="#ffffff"/>
</svg>}

    foreach n {1 2 3} {
	# troughOffImg
	set imgData $troughData($n)
	append imgData "fill='#c3c3c3'/>\n</svg>"
	set troughOffImg [createSvgImg -data $imgData]

	# troughOffPressedImg
	set imgData $troughData($n)
	append imgData "fill='#a3a3a3'/>\n</svg>"
	set troughOffPressedImg [createSvgImg -data $imgData]

	# troughOffDisabledImg
	set imgData $troughData($n)
	append imgData "fill='#cecece'/>\n</svg>"
	set troughOffDisabledImg [createSvgImg -data $imgData]

	# troughOnImg
	set imgData $troughData($n)
	append imgData "fill='#657a9e'/>\n</svg>"
	set troughOnImg [createSvgImg -data $imgData]

	# troughOnPressedImg
	set imgData $troughData($n)
	append imgData "fill='#86a1d1'/>\n</svg>"
	set troughOnPressedImg [createSvgImg -data $imgData]

	# troughOnDisabledImg
	set imgData $troughData($n)
	append imgData "fill='#bcd5ff'/>\n</svg>"
	set troughOnDisabledImg [createSvgImg -data $imgData]

	ttk::style element create Switch$n.trough image [list $troughOffImg \
	    {selected disabled}	$troughOnDisabledImg \
	    {selected pressed}	$troughOnPressedImg \
	    selected		$troughOnImg \
	    disabled		$troughOffDisabledImg \
	    pressed		$troughOffPressedImg \
	]

	# sliderImg
	set sliderImg [createSvgImg -data $sliderData($n)]

	ttk::style element create Switch$n.slider image $sliderImg
    }
}

#------------------------------------------------------------------------------
# tsw::createElements_plastik
#------------------------------------------------------------------------------
proc tsw::createElements_plastik {} {
    set troughData(1) {
<svg width="32" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="32" height="16" rx="8" }
    set troughData(2) {
<svg width="40" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="40" height="20" rx="10" }
    set troughData(3) {
<svg width="48" height="24" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="48" height="24" rx="12" }

    set sliderData(1) {
<svg width="16" height="12" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="8" cy="6" r="6" fill="#ffffff"/>
</svg>}
    set sliderData(2) {
<svg width="20" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="10" cy="8" r="8" fill="#ffffff"/>
</svg>}
    set sliderData(3) {
<svg width="24" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="12" cy="10" r="10" fill="#ffffff"/>
</svg>}

    foreach n {1 2 3} {
	# troughOffImg
	set imgData $troughData($n)
	append imgData "fill='#d7d7d7'/>\n</svg>"
	set troughOffImg [createSvgImg -data $imgData]

	# troughOffPressedImg
	set imgData $troughData($n)
	append imgData "fill='#b7b7b7'/>\n</svg>"
	set troughOffPressedImg [createSvgImg -data $imgData]

	# troughOffDisabledImg
	set imgData $troughData($n)
	append imgData "fill='#e2e2e2'/>\n</svg>"
	set troughOffDisabledImg [createSvgImg -data $imgData]

	# troughOnImg
	set imgData $troughData($n)
	append imgData "fill='#657a9e'/>\n</svg>"
	set troughOnImg [createSvgImg -data $imgData]

	# troughOnPressedImg
	set imgData $troughData($n)
	append imgData "fill='#86a1d1'/>\n</svg>"
	set troughOnPressedImg [createSvgImg -data $imgData]

	# troughOnDisabledImg
	set imgData $troughData($n)
	append imgData "fill='#bcd5ff'/>\n</svg>"
	set troughOnDisabledImg [createSvgImg -data $imgData]

	ttk::style element create Switch$n.trough image [list $troughOffImg \
	    {selected disabled}	$troughOnDisabledImg \
	    {selected pressed}	$troughOnPressedImg \
	    selected		$troughOnImg \
	    disabled		$troughOffDisabledImg \
	    pressed		$troughOffPressedImg \
	]

	# sliderImg
	set sliderImg [createSvgImg -data $sliderData($n)]

	ttk::style element create Switch$n.slider image $sliderImg
    }
}

#------------------------------------------------------------------------------
# tsw::createElements_awarc
#------------------------------------------------------------------------------
proc tsw::createElements_awarc {} {
    set troughData(1) {
<svg width="32" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="32" height="16" rx="8" }
    set troughData(2) {
<svg width="40" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="40" height="20" rx="10" }
    set troughData(3) {
<svg width="48" height="24" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="48" height="24" rx="12" }

    set sliderData(1) {
<svg width="16" height="12" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="8" cy="6" r="6" fill="#ffffff"/>
</svg>}
    set sliderData(2) {
<svg width="20" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="10" cy="8" r="8" fill="#ffffff"/>
</svg>}
    set sliderData(3) {
<svg width="24" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="12" cy="10" r="10" fill="#ffffff"/>
</svg>}

    variable onAndroid
    foreach n {1 2 3} {
	# troughOffImg
	set imgData $troughData($n)
	append imgData "fill='#d7d7d7'/>\n</svg>"
	set troughOffImg [createSvgImg -data $imgData]

	# troughOffActiveImg
	set imgData $troughData($n)
	set fill [expr {$onAndroid ? "#d7d7d7" : "#c7c7c7"}]
	append imgData "fill='$fill'/>\n</svg>"
	set troughOffActiveImg [createSvgImg -data $imgData]

	# troughOffPressedImg
	set imgData $troughData($n)
	append imgData "fill='#b7b7b7'/>\n</svg>"
	set troughOffPressedImg [createSvgImg -data $imgData]

	# troughOffDisabledImg
	set imgData $troughData($n)
	append imgData "fill='#e2e2e2'/>\n</svg>"
	set troughOffDisabledImg [createSvgImg -data $imgData]

	# troughOnImg
	set imgData $troughData($n)
	append imgData "fill='#5294e2'/>\n</svg>"
	set troughOnImg [createSvgImg -data $imgData]

	# troughOnActiveImg
	set imgData $troughData($n)
	set fill [expr {$onAndroid ? "#5294e2" : "#4982c8"}]
	append imgData "fill='$fill'/>\n</svg>"
	set troughOnActiveImg [createSvgImg -data $imgData]

	# troughOnPressedImg
	set imgData $troughData($n)
	append imgData "fill='#3f72af'/>\n</svg>"
	set troughOnPressedImg [createSvgImg -data $imgData]

	# troughOnDisabledImg
	set imgData $troughData($n)
	append imgData "fill='#a9d0ff'/>\n</svg>"
	set troughOnDisabledImg [createSvgImg -data $imgData]

	ttk::style element create Switch$n.trough image [list $troughOffImg \
	    {selected disabled}	$troughOnDisabledImg \
	    {selected pressed}	$troughOnPressedImg \
	    {selected active}	$troughOnActiveImg \
	    selected		$troughOnImg \
	    disabled		$troughOffDisabledImg \
	    pressed		$troughOffPressedImg \
	    active		$troughOffActiveImg \
	]

	# sliderImg
	set sliderImg [createSvgImg -data $sliderData($n)]

	ttk::style element create Switch$n.slider image $sliderImg
    }
}

#------------------------------------------------------------------------------
# tsw::createElements_awbreeze
#------------------------------------------------------------------------------
proc tsw::createElements_awbreeze {} {
    set troughData(1) {
<svg width="32" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="32" height="16" rx="8" }
    set troughData(2) {
<svg width="40" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="40" height="20" rx="10" }
    set troughData(3) {
<svg width="48" height="24" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="48" height="24" rx="12" }

    set sliderData(1) {
<svg width="16" height="12" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="8" cy="6" r="6" fill="#ffffff"/>
</svg>}
    set sliderData(2) {
<svg width="20" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="10" cy="8" r="8" fill="#ffffff"/>
</svg>}
    set sliderData(3) {
<svg width="24" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="12" cy="10" r="10" fill="#ffffff"/>
</svg>}

    variable onAndroid
    foreach n {1 2 3} {
	# troughOffImg
	set imgData $troughData($n)
	append imgData "fill='#d7d7d7'/>\n</svg>"
	set troughOffImg [createSvgImg -data $imgData]

	# troughOffActiveImg
	set imgData $troughData($n)
	set fill [expr {$onAndroid ? "#d7d7d7" : "#c7c7c7"}]
	append imgData "fill='$fill'/>\n</svg>"
	set troughOffActiveImg [createSvgImg -data $imgData]

	# troughOffPressedImg
	set imgData $troughData($n)
	append imgData "fill='#b7b7b7'/>\n</svg>"
	set troughOffPressedImg [createSvgImg -data $imgData]

	# troughOffDisabledImg
	set imgData $troughData($n)
	append imgData "fill='#e2e2e2'/>\n</svg>"
	set troughOffDisabledImg [createSvgImg -data $imgData]

	# troughOnImg
	set imgData $troughData($n)
	append imgData "fill='#3daee9'/>\n</svg>"
	set troughOnImg [createSvgImg -data $imgData]

	# troughOnActiveImg
	set imgData $troughData($n)
	set fill [expr {$onAndroid ? "#3daee9" : "#369ad0"}]
	append imgData "fill='$fill'/>\n</svg>"
	set troughOnActiveImg [createSvgImg -data $imgData]

	# troughOnPressedImg
	set imgData $troughData($n)
	append imgData "fill='#3087b6'/>\n</svg>"
	set troughOnPressedImg [createSvgImg -data $imgData]

	# troughOnDisabledImg
	set imgData $troughData($n)
	append imgData "fill='#a9e1ff'/>\n</svg>"
	set troughOnDisabledImg [createSvgImg -data $imgData]

	ttk::style element create Switch$n.trough image [list $troughOffImg \
	    {selected disabled}	$troughOnDisabledImg \
	    {selected pressed}	$troughOnPressedImg \
	    {selected active}	$troughOnActiveImg \
	    selected		$troughOnImg \
	    disabled		$troughOffDisabledImg \
	    pressed		$troughOffPressedImg \
	    active		$troughOffActiveImg \
	]

	# sliderImg
	set sliderImg [createSvgImg -data $sliderData($n)]

	ttk::style element create Switch$n.slider image $sliderImg
    }
}

#------------------------------------------------------------------------------
# tsw::createElements_awbreezedark
#------------------------------------------------------------------------------
proc tsw::createElements_awbreezedark {} {
    set troughData(1) {
<svg width="32" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="32" height="16" rx="8" }
    set troughData(2) {
<svg width="40" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="40" height="20" rx="10" }
    set troughData(3) {
<svg width="48" height="24" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="48" height="24" rx="12" }

    set sliderData(1) {
<svg width="16" height="12" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="8" cy="6" r="6" }
    set sliderData(2) {
<svg width="20" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="10" cy="8" r="8" }
    set sliderData(3) {
<svg width="24" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="12" cy="10" r="10" }

    variable onAndroid
    foreach n {1 2 3} {
	# troughOffImg
	set imgData $troughData($n)
	append imgData "fill='#585858'/>\n</svg>"
	set troughOffImg [createSvgImg -data $imgData]

	# troughOffActiveImg
	set imgData $troughData($n)
	set fill [expr {$onAndroid ? "#585858" : "#676767"}]
	append imgData "fill='$fill'/>\n</svg>"
	set troughOffActiveImg [createSvgImg -data $imgData]

	# troughOffPressedImg
	set imgData $troughData($n)
	append imgData "fill='#787878'/>\n</svg>"
	set troughOffPressedImg [createSvgImg -data $imgData]

	# troughOffDisabledImg
	set imgData $troughData($n)
	append imgData "fill='#4a4a4a'/>\n</svg>"
	set troughOffDisabledImg [createSvgImg -data $imgData]

	# troughOnImg
	set imgData $troughData($n)
	append imgData "fill='#3984ac'/>\n</svg>"
	set troughOnImg [createSvgImg -data $imgData]

	# troughOnActiveImg
	set imgData $troughData($n)
	set fill [expr {$onAndroid ? "#3984ac" : "#4197c6"}]
	append imgData "fill='$fill'/>\n</svg>"
	set troughOnActiveImg [createSvgImg -data $imgData]

	# troughOnPressedImg
	set imgData $troughData($n)
	append imgData "fill='#4aabdf'/>\n</svg>"
	set troughOnPressedImg [createSvgImg -data $imgData]

	# troughOnDisabledImg
	set imgData $troughData($n)
	append imgData "fill='#317093'/>\n</svg>"
	set troughOnDisabledImg [createSvgImg -data $imgData]

	ttk::style element create Switch$n.trough image [list $troughOffImg \
	    {selected disabled}	$troughOnDisabledImg \
	    {selected pressed}	$troughOnPressedImg \
	    {selected active}	$troughOnActiveImg \
	    selected		$troughOnImg \
	    disabled		$troughOffDisabledImg \
	    pressed		$troughOffPressedImg \
	    active		$troughOffActiveImg \
	]

	# sliderOffImg
	set imgData $sliderData($n)
	append imgData "fill='#d3d3d3'/>\n</svg>"
	set sliderOffImg [createSvgImg -data $imgData]

	# sliderOffDisabledImg
	set imgData $sliderData($n)
	append imgData "fill='#888888'/>\n</svg>"
	set sliderOffDisabledImg [createSvgImg -data $imgData]

	# sliderOnDisabledImg
	set imgData $sliderData($n)
	append imgData "fill='#9f9f9f'/>\n</svg>"
	set sliderOnDisabledImg [createSvgImg -data $imgData]

	# sliderImg
	set imgData $sliderData($n)
	append imgData "fill='#ffffff'/>\n</svg>"
	set sliderImg [createSvgImg -data $imgData]

	ttk::style element create Switch$n.slider image [list $sliderOffImg \
	    {selected disabled}	$sliderOnDisabledImg \
	    selected		$sliderImg \
	    disabled		$sliderOffDisabledImg \
	    pressed		$sliderImg \
	    active		$sliderImg \
	]
    }
}

#------------------------------------------------------------------------------
# tsw::createElements_awlight
#------------------------------------------------------------------------------
proc tsw::createElements_awlight {} {
    set troughData(1) {
<svg width="32" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="32" height="16" rx="8" }
    set troughData(2) {
<svg width="40" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="40" height="20" rx="10" }
    set troughData(3) {
<svg width="48" height="24" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="48" height="24" rx="12" }

    set sliderData(1) {
<svg width="16" height="12" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="8" cy="6" r="6" fill="#ffffff"/>
</svg>}
    set sliderData(2) {
<svg width="20" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="10" cy="8" r="8" fill="#ffffff"/>
</svg>}
    set sliderData(3) {
<svg width="24" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="12" cy="10" r="10" fill="#ffffff"/>
</svg>}

    variable onAndroid
    foreach n {1 2 3} {
	# troughOffImg
	set imgData $troughData($n)
	append imgData "fill='#d7d7d7'/>\n</svg>"
	set troughOffImg [createSvgImg -data $imgData]

	# troughOffActiveImg
	set imgData $troughData($n)
	set fill [expr {$onAndroid ? "#d7d7d7" : "#c7c7c7"}]
	append imgData "fill='$fill'/>\n</svg>"
	set troughOffActiveImg [createSvgImg -data $imgData]

	# troughOffPressedImg
	set imgData $troughData($n)
	append imgData "fill='#b7b7b7'/>\n</svg>"
	set troughOffPressedImg [createSvgImg -data $imgData]

	# troughOffDisabledImg
	set imgData $troughData($n)
	append imgData "fill='#e2e2e2'/>\n</svg>"
	set troughOffDisabledImg [createSvgImg -data $imgData]

	# troughOnImg
	set imgData $troughData($n)
	append imgData "fill='#1a497c'/>\n</svg>"
	set troughOnImg [createSvgImg -data $imgData]

	# troughOnActiveImg
	set imgData $troughData($n)
	set fill [expr {$onAndroid ? "#1a497c" : "#1f5895"}]
	append imgData "fill='$fill'/>\n</svg>"
	set troughOnActiveImg [createSvgImg -data $imgData]

	# troughOnPressedImg
	set imgData $troughData($n)
	append imgData "fill='#2568af'/>\n</svg>"
	set troughOnPressedImg [createSvgImg -data $imgData]

	# troughOnDisabledImg
	set imgData $troughData($n)
	append imgData "fill='#b5d9ff'/>\n</svg>"
	set troughOnDisabledImg [createSvgImg -data $imgData]

	ttk::style element create Switch$n.trough image [list $troughOffImg \
	    {selected disabled}	$troughOnDisabledImg \
	    {selected pressed}	$troughOnPressedImg \
	    {selected active}	$troughOnActiveImg \
	    selected		$troughOnImg \
	    disabled		$troughOffDisabledImg \
	    pressed		$troughOffPressedImg \
	    active		$troughOffActiveImg \
	]

	# sliderImg
	set sliderImg [createSvgImg -data $sliderData($n)]

	ttk::style element create Switch$n.slider image $sliderImg
    }
}

#------------------------------------------------------------------------------
# tsw::createElements_awdark
#------------------------------------------------------------------------------
proc tsw::createElements_awdark {} {
    set troughData(1) {
<svg width="32" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="32" height="16" rx="8" }
    set troughData(2) {
<svg width="40" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="40" height="20" rx="10" }
    set troughData(3) {
<svg width="48" height="24" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="48" height="24" rx="12" }

    set sliderData(1) {
<svg width="16" height="12" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="8" cy="6" r="6" }
    set sliderData(2) {
<svg width="20" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="10" cy="8" r="8" }
    set sliderData(3) {
<svg width="24" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="12" cy="10" r="10" }

    variable onAndroid
    foreach n {1 2 3} {
	# troughOffImg
	set imgData $troughData($n)
	append imgData "fill='#585858'/>\n</svg>"
	set troughOffImg [createSvgImg -data $imgData]

	# troughOffActiveImg
	set imgData $troughData($n)
	set fill [expr {$onAndroid ? "#585858" : "#676767"}]
	append imgData "fill='$fill'/>\n</svg>"
	set troughOffActiveImg [createSvgImg -data $imgData]

	# troughOffPressedImg
	set imgData $troughData($n)
	append imgData "fill='#787878'/>\n</svg>"
	set troughOffPressedImg [createSvgImg -data $imgData]

	# troughOffDisabledImg
	set imgData $troughData($n)
	append imgData "fill='#4a4a4a'/>\n</svg>"
	set troughOffDisabledImg [createSvgImg -data $imgData]

	# troughOnImg
	set imgData $troughData($n)
	append imgData "fill='#215d9c'/>\n</svg>"
	set troughOnImg [createSvgImg -data $imgData]

	# troughOnActiveImg
	set imgData $troughData($n)
	set fill [expr {$onAndroid ? "#215d9c" : "#266cb6"}]
	append imgData "fill='$fill'/>\n</svg>"
	set troughOnActiveImg [createSvgImg -data $imgData]

	# troughOnPressedImg
	set imgData $troughData($n)
	append imgData "fill='#2c7bcf'/>\n</svg>"
	set troughOnPressedImg [createSvgImg -data $imgData]

	# troughOnDisabledImg
	set imgData $troughData($n)
	append imgData "fill='#1c4d83'/>\n</svg>"
	set troughOnDisabledImg [createSvgImg -data $imgData]

	ttk::style element create Switch$n.trough image [list $troughOffImg \
	    {selected disabled}	$troughOnDisabledImg \
	    {selected pressed}	$troughOnPressedImg \
	    {selected active}	$troughOnActiveImg \
	    selected		$troughOnImg \
	    disabled		$troughOffDisabledImg \
	    pressed		$troughOffPressedImg \
	    active		$troughOffActiveImg \
	]

	# sliderOffImg
	set imgData $sliderData($n)
	append imgData "fill='#d3d3d3'/>\n</svg>"
	set sliderOffImg [createSvgImg -data $imgData]

	# sliderOffDisabledImg
	set imgData $sliderData($n)
	append imgData "fill='#888888'/>\n</svg>"
	set sliderOffDisabledImg [createSvgImg -data $imgData]

	# sliderOnDisabledImg
	set imgData $sliderData($n)
	append imgData "fill='#9f9f9f'/>\n</svg>"
	set sliderOnDisabledImg [createSvgImg -data $imgData]

	# sliderImg
	set imgData $sliderData($n)
	append imgData "fill='#ffffff'/>\n</svg>"
	set sliderImg [createSvgImg -data $imgData]

	ttk::style element create Switch$n.slider image [list $sliderOffImg \
	    {selected disabled}	$sliderOnDisabledImg \
	    selected		$sliderImg \
	    disabled		$sliderOffDisabledImg \
	    pressed		$sliderImg \
	    active		$sliderImg \
	]
    }
}

#------------------------------------------------------------------------------
# tsw::createElements_vista
#------------------------------------------------------------------------------
proc tsw::createElements_vista {} {
    variable elemInfoArr
    if {[info exists elemInfoArr(vista)]} {
	return ""
    }

    if {$::tcl_platform(osVersion) >= 11.0} {			;# Win 11+
	createElements_win11
    } else {							;# Win 10-
	createElements_win10
    }

    foreach n {1 2 3} {
	ttk::style layout Toggleswitch$n [list \
	    Switch.focus -sticky nswe -children [list \
		Switch.padding -sticky nswe -children [list \
		    Switch$n.trough -sticky {} -children [list \
			Switch$n.slider -side left -sticky {}
		    ]
		]
	    ]
	]
    }

    set elemInfoArr(vista) 1
}

#------------------------------------------------------------------------------
# tsw::createElements_win11
#------------------------------------------------------------------------------
proc tsw::createElements_win11 {} {
    set troughOffData(1) {
<svg width="32" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x="0.5" y="0.5" width="31" height="15" rx="7.5" }
    set troughOffData(2) {
<svg width="40" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x="0.5" y="0.5" width="39" height="19" rx="9.5" }
    set troughOffData(3) {
<svg width="48" height="24" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x="0.5" y="0.5" width="47" height="23" rx="11.5" }

    set troughOnData(1) {
<svg width="32" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="32" height="16" rx="8" }
    set troughOnData(2) {
<svg width="40" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x="0" y="0" width="40" height="20" rx="10" }
    set troughOnData(3) {
<svg width="48" height="24" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="48" height="24" rx="12" }

    set sliderOffData(1) {
<svg width="16" height="10" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="7" cy="5" r="4" }				;# margins L, R: 3, 5
    set sliderOffData(2) {
<svg width="20" height="14" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="9" cy="7" r="6" }				;# margins L, R: 3, 5
    set sliderOffData(3) {
<svg width="24" height="18" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="11" cy="9" r="8" }				;# margins L, R: 3, 5

    set sliderOnData(1) {
<svg width="16" height="10" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="9" cy="5" r="4" }				;# margins L, R: 5, 3
    set sliderOnData(2) {
<svg width="20" height="14" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="11" cy="7" r="6" }				;# margins L, R: 5, 3
    set sliderOnData(3) {
<svg width="24" height="18" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="13" cy="9" r="8" }				;# margins L, R: 5, 3

    set sliderActiveData(1) {
<svg width="16" height="10" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="8" cy="5" r="5" }				;# margins L, R: 3, 3
    set sliderActiveData(2) {
<svg width="20" height="14" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="10" cy="7" r="7" }				;# margins L, R: 3, 3
    set sliderActiveData(3) {
<svg width="24" height="18" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="12" cy="9" r="9" }				;# margins L, R: 3, 3

    set sliderOffPressedData(1) {
<svg width="16" height="10" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x="3" y="0" width="13" height="10" rx="5" }	;# margins L, R: 3, 0
    set sliderOffPressedData(2) {
<svg width="20" height="14" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x="3" y="0" width="17" height="14" rx="7" }	;# margins L, R: 3, 0
    set sliderOffPressedData(3) {
<svg width="24" height="18" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x="3" y="0" width="21" height="18" rx="9" }	;# margins L, R: 3, 0

    set sliderOnPressedData(1) {
<svg width="16" height="10" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x="0" y="0" width="13" height="10" rx="5" }	;# margins L, R: 0, 3
    set sliderOnPressedData(2) {
<svg width="20" height="14" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x="0" y="0" width="17" height="14" rx="7" }	;# margins L, R: 0, 3
    set sliderOnPressedData(3) {
<svg width="24" height="18" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x="0" y="0" width="21" height="18" rx="9" }	;# margins L, R: 0, 3

    foreach n {1 2 3} {
	# troughOffImg
	set imgData $troughOffData($n)
	append imgData "fill='#f6f6f6' stroke='#8a8a8a'/>\n</svg>"
	set troughOffImg [createSvgImg -data $imgData]

	# troughOffActiveImg
	set imgData $troughOffData($n)
	append imgData "fill='#ededed' stroke='#878787'/>\n</svg>"
	set troughOffActiveImg [createSvgImg -data $imgData]

	# troughOffPressedImg
	set imgData $troughOffData($n)
	append imgData "fill='#e4e4e4' stroke='#858585'/>\n</svg>"
	set troughOffPressedImg [createSvgImg -data $imgData]

	# troughOffDisabledImg
	set imgData $troughOffData($n)
	append imgData "fill='#fbfbfb' stroke='#c5c5c5'/>\n</svg>"
	set troughOffDisabledImg [createSvgImg -data $imgData]

	# troughOnImg
	set imgData $troughOnData($n)
	append imgData "fill='#005fb8'/>\n</svg>"
	set troughOnImg [createSvgImg -data $imgData]

	# troughOnActiveImg
	set imgData $troughOnData($n)
	append imgData "fill='#196ebf'/>\n</svg>"
	set troughOnActiveImg [createSvgImg -data $imgData]

	# troughOnPressedImg
	set imgData $troughOnData($n)
	append imgData "fill='#327ec5'/>\n</svg>"
	set troughOnPressedImg [createSvgImg -data $imgData]

	# troughOnDisabledImg
	set imgData $troughOnData($n)
	append imgData "fill='#c5c5c5'/>\n</svg>"
	set troughOnDisabledImg [createSvgImg -data $imgData]

	ttk::style element create Switch$n.trough image [list $troughOffImg \
	    {selected disabled}	$troughOnDisabledImg \
	    {selected pressed}	$troughOnPressedImg \
	    {selected active}	$troughOnActiveImg \
	    selected		$troughOnImg \
	    disabled		$troughOffDisabledImg \
	    pressed		$troughOffPressedImg \
	    active		$troughOffActiveImg \
	]

	# sliderOffImg
	set imgData $sliderOffData($n)
	append imgData "fill='#5d5d5d'/>\n</svg>"
	set sliderOffImg [createSvgImg -data $imgData]

	# sliderOffActiveImg
	set imgData $sliderActiveData($n)
	append imgData "fill='#5a5a5a'/>\n</svg>"
	set sliderOffActiveImg [createSvgImg -data $imgData]

	# sliderOffPressedImg
	set imgData $sliderOffPressedData($n)
	append imgData "fill='#575757'/>\n</svg>"
	set sliderOffPressedImg [createSvgImg -data $imgData]

	# sliderOffDisabledImg
	set imgData $sliderOffData($n)
	append imgData "fill='#a1a1a1'/>\n</svg>"
	set sliderOffDisabledImg [createSvgImg -data $imgData]

	# sliderOnImg
	set imgData $sliderOnData($n)
	append imgData "fill='#ffffff'/>\n</svg>"
	set sliderOnImg [createSvgImg -data $imgData]

	# sliderOnActiveImg
	set imgData $sliderActiveData($n)
	append imgData "fill='#ffffff'/>\n</svg>"
	set sliderOnActiveImg [createSvgImg -data $imgData]

	# sliderOnPressedImg
	set imgData $sliderOnPressedData($n)
	append imgData "fill='#ffffff'/>\n</svg>"
	set sliderOnPressedImg [createSvgImg -data $imgData]

	# sliderOnDisabledImg
	set imgData $sliderOnData($n)
	append imgData "fill='#ffffff'/>\n</svg>"
	set sliderOnDisabledImg [createSvgImg -data $imgData]

	ttk::style element create Switch$n.slider image [list $sliderOffImg \
	    {selected disabled}	$sliderOnDisabledImg \
	    {selected pressed}	$sliderOnPressedImg \
	    {selected active}	$sliderOnActiveImg \
	    selected		$sliderOnImg \
	    disabled		$sliderOffDisabledImg \
	    pressed		$sliderOffPressedImg \
	    active		$sliderOffActiveImg \
	]
    }
}

#------------------------------------------------------------------------------
# tsw::createElements_win10
#------------------------------------------------------------------------------
proc tsw::createElements_win10 {} {
    set troughOffData(1) {
<svg width="35" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x="1" y="1" width="33" height="14" rx="7" stroke-width="2" }
    set troughOffData(2) {
<svg width="44" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x="1" y="1" width="42" height="18" rx="9" stroke-width="2" }
    set troughOffData(3) {
<svg width="53" height="24" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x="1" y="1" width="51" height="22" rx="11" stroke-width="2" }

    set troughOnData(1) {
<svg width="35" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x="0" y="0" width="35" height="16" rx="8" }
    set troughOnData(2) {
<svg width="44" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x="0" y="0" width="44" height="20" rx="10" }
    set troughOnData(3) {
<svg width="53" height="24" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x="0" y="0" width="53" height="24" rx="12" }

    set troughPressedData(1) {
<svg width="35" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x="0" y="0" width="35" height="16" rx="8" fill="#666666"/>
</svg>}
    set troughPressedData(2) {
<svg width="44" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x="0" y="0" width="44" height="20" rx="10" fill="#666666"/>
</svg>}
    set troughPressedData(3) {
<svg width="53" height="24" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <rect x="0" y="0" width="53" height="24" rx="12" fill="#666666"/>
</svg>}

    set sliderData(1) {
<svg width="16" height="8" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="8" cy="4" r="4" }
    set sliderData(2) {
<svg width="20" height="10" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="10" cy="5" r="5" }
    set sliderData(3) {
<svg width="24" height="12" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <circle cx="12" cy="6" r="6" }

    foreach n {1 2 3} {
	# troughOffImg
	set imgData $troughOffData($n)
	append imgData "fill='#ffffff' stroke='#333333'/>\n</svg>"
	set troughOffImg [createSvgImg -data $imgData]

	# troughOffDisabledImg
	set imgData $troughOffData($n)
	append imgData "fill='#ffffff' stroke='#999999'/>\n</svg>"
	set troughOffDisabledImg [createSvgImg -data $imgData]

	# troughOnImg
	set imgData $troughOnData($n)
	append imgData "fill='#0078d7'/>\n</svg>"
	set troughOnImg [createSvgImg -data $imgData]

	# troughOnActiveImg
	set imgData $troughOnData($n)
	append imgData "fill='#4da1e3'/>\n</svg>"
	set troughOnActiveImg [createSvgImg -data $imgData]

	# troughOnDisabledImg
	set imgData $troughOnData($n)
	append imgData "fill='#cccccc'/>\n</svg>"
	set troughOnDisabledImg [createSvgImg -data $imgData]

	# troughPressedImg
	set troughPressedImg [createSvgImg -data $troughPressedData($n)]

	ttk::style element create Switch$n.trough image [list $troughOffImg \
	    {selected disabled}	$troughOnDisabledImg \
	    {selected pressed}	$troughPressedImg \
	    {selected active}	$troughOnActiveImg \
	    selected		$troughOnImg \
	    disabled		$troughOffDisabledImg \
	    pressed		$troughPressedImg \
	]

	# sliderOffImg
	set imgData $sliderData($n)
	append imgData "fill='#333333'/>\n</svg>"
	set sliderOffImg [createSvgImg -data $imgData]

	# sliderOffDisabledImg
	set imgData $sliderData($n)
	append imgData "fill='#999999'/>\n</svg>"
	set sliderOffDisabledImg [createSvgImg -data $imgData]

	# sliderOnImg
	set imgData $sliderData($n)
	append imgData "fill='#ffffff'/>\n</svg>"
	set sliderOnImg [createSvgImg -data $imgData]

	# sliderOnDisabledImg
	set imgData $sliderData($n)
	append imgData "fill='#a3a3a3'/>\n</svg>"
	set sliderOnDisabledImg [createSvgImg -data $imgData]

	# sliderPressedImg
	set imgData $sliderData($n)
	append imgData "fill='#ffffff'/>\n</svg>"
	set sliderPressedImg [createSvgImg -data $imgData]

	ttk::style element create Switch$n.slider image [list $sliderOffImg \
	    {selected disabled}	$sliderOnDisabledImg \
	    selected		$sliderOnImg \
	    disabled		$sliderOffDisabledImg \
	    pressed		$sliderPressedImg \
	]
    }
}

#------------------------------------------------------------------------------
# tsw::createElements_aqua
#------------------------------------------------------------------------------
proc tsw::createElements_aqua {} {
    variable troughImgArr
    variable sliderImgArr

    foreach n {1 2 3} {
	foreach state {off offPressed offDisabled
		       on onPressed onDisabled onBg onDisabledBg} {
	    set troughImgArr(${state}$n) [createSvgImg]
	}

	ttk::style element create Switch$n.trough image [list \
	    $troughImgArr(off$n) \
	    {selected disabled background}	$troughImgArr(onDisabledBg$n) \
	    {selected disabled}			$troughImgArr(onDisabled$n) \
	    {selected background}		$troughImgArr(onBg$n) \
	    {selected pressed}			$troughImgArr(onPressed$n) \
	    selected				$troughImgArr(on$n) \
	    disabled				$troughImgArr(offDisabled$n) \
	    pressed				$troughImgArr(offPressed$n) \
	]

	foreach state {off offPressed offDisabled
		       on onPressed onDisabled} {
	    set sliderImgArr(${state}$n) [createSvgImg]
	}

	ttk::style element create Switch$n.slider image [list \
	    $sliderImgArr(off$n) \
	    {selected disabled}		$sliderImgArr(onDisabled$n) \
	    {selected pressed}		$sliderImgArr(onPressed$n) \
	    selected			$sliderImgArr(on$n) \
	    disabled			$sliderImgArr(offDisabled$n) \
	    pressed			$sliderImgArr(offPressed$n) \
	]
    }

    updateElements_aqua
}

#------------------------------------------------------------------------------
# tsw::updateElements_aqua
#------------------------------------------------------------------------------
proc tsw::updateElements_aqua {} {
    variable troughImgArr
    variable sliderImgArr
    set darkMode [tk::unsupported::MacWindowStyle isdark .]

    set troughOffData(1) {
<svg width="26" height="15" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0.5" y="0.5" width="25" height="14" rx="7" }
    set troughOffData(2) {
<svg width="32" height="18" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0.5" y="0.5" width="31" height="17" rx="8.5" }
    set troughOffData(3) {
<svg width="38" height="22" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0.5" y="0.5" width="37" height="21" rx="10.5" }

    set troughOnData(1) {
<svg width="26" height="15" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="26" height="15" rx="7.5" }
    set troughOnData(2) {
<svg width="32" height="18" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="32" height="18" rx="9" }
    set troughOnData(3) {
<svg width="38" height="22" version="1.1" xmlns="http://www.w3.org/2000/svg">
<rect x="0" y="0" width="38" height="22" rx="11" }

    set sliderOffData(1) {
<svg width="15" height="15" version="1.1" xmlns="http://www.w3.org/2000/svg">
<circle cx="7.5" cy="7.5" r="7" }
    set sliderOffData(2) {
<svg width="18" height="18" version="1.1" xmlns="http://www.w3.org/2000/svg">
<circle cx="9" cy="9" r="8.5" }
    set sliderOffData(3) {
<svg width="22" height="22" version="1.1" xmlns="http://www.w3.org/2000/svg">
<circle cx="11" cy="11" r="10.5" }

    set sliderOnData(1) {
<svg width="15" height="15" version="1.1" xmlns="http://www.w3.org/2000/svg">
<circle cx="7.5" cy="7.5" r="6.5" }
    set sliderOnData(2) {
<svg width="18" height="18" version="1.1" xmlns="http://www.w3.org/2000/svg">
<circle cx="9" cy="9" r="8" }
    set sliderOnData(3) {
<svg width="22" height="22" version="1.1" xmlns="http://www.w3.org/2000/svg">
<circle cx="11" cy="11" r="10" }

    foreach n {1 2 3} {
	# troughImgArr(off$n)
	set imgData $troughOffData($n)
	set fill [expr {$darkMode ? "#414141" : "#d9d9d9"}]
	set strk [expr {$darkMode ? "#606060" : "#cdcdcd"}]
	append imgData "fill='$fill' stroke='$strk'/>\n</svg>"
	$troughImgArr(off$n) configure -data $imgData

	# troughImgArr(offPressed$n)
	set imgData $troughOffData($n)
	set fill [expr {$darkMode ? "#4d4d4d" : "#cbcbcb"}]
	set strk [expr {$darkMode ? "#6a6a6a" : "#c0c0c0"}]
	append imgData "fill='$fill' stroke='$strk'/>\n</svg>"
	$troughImgArr(offPressed$n) configure -data $imgData

	# troughImgArr(offDisabled$n)
	set imgData $troughOffData($n)
	set fill [expr {$darkMode ? "#282828" : "#f4f4f4"}]
	set strk [expr {$darkMode ? "#393939" : "#ededed"}]
	append imgData "fill='$fill' stroke='$strk'/>\n</svg>"
	$troughImgArr(offDisabled$n) configure -data $imgData

	# troughImgArr(on$n)
	set imgData $troughOnData($n)
	set fill [expr {$darkMode ? "systemSelectedContentBackgroundColor"
				  : "systemControlAccentColor"}]
	set fill [mwutil::normalizeColor $fill]
	if {$darkMode} {
	    # For the colors blue, purple, pink, red, orange, yellow, green,
	    # and graphite replace $fill with its counterpart for LightAqua
	    array set tmpArr {
		#0059d1 #0064e1  #803482 #7d2a7e  #c93379 #d93b86
		#d13539 #c4262b  #c96003 #d96b0a  #d19e00 #e1ac15
		#43932a #4da033  #696969 #808080

		#0058d0 #007aff  #7f3280 #953d96  #c83179 #f74f9e
		#d03439 #e0383e  #c86003 #f7821b  #cd8f0e #fcb827
		#42912a #62ba46  #686868 #989898
	    }
	    if {[info exists tmpArr($fill)]} { set fill $tmpArr($fill) }
	    array unset tmpArr
	}
	append imgData "fill='$fill'/>\n</svg>"
	$troughImgArr(on$n) configure -data $imgData

	# troughImgArr(onPressed$n)
	set imgData $troughOnData($n)
	set fill [expr {$darkMode ? "systemControlAccentColor"
				  : "systemSelectedContentBackgroundColor"}]
	set fill [mwutil::normalizeColor $fill]
	if {$darkMode} {
	    # For the colors purple, red, yellow, and graphite
	    # replace $fill with its counterpart for LightAqua
	    array set tmpArr {
		#a550a7 #953d96  #ff5257 #e0383e
		#ffc600 #ffc726  #8c8c8c #989898

		#a550a7 #7d2a7e  #f74f9e #d93b85
		#fcb827 #de9e15  #8c8c8c #808080
	    }
	    if {[info exists tmpArr($fill)]} { set fill $tmpArr($fill) }
	    array unset tmpArr
	}
	append imgData "fill='$fill'/>\n</svg>"
	$troughImgArr(onPressed$n) configure -data $imgData

	# troughImgArr(onDisabled$n)
	set imgData $troughOnData($n)
	set fill [mwutil::normalizeColor systemSelectedControlColor]
	append imgData "fill='$fill'/>\n</svg>"
	$troughImgArr(onDisabled$n) configure -data $imgData

	# troughImgArr(onBg$n)
	set imgData $troughOnData($n)
	set fill [expr {$darkMode ? "#676665" : "#b0b0b0"}]
	append imgData "fill='$fill'/>\n</svg>"
	$troughImgArr(onBg$n) configure -data $imgData

	# troughImgArr(onDisabledBg$n)
	set imgData $troughOnData($n)
	set fill [expr {$darkMode ? "#282828" : "#f4f4f4"}]
	append imgData "fill='$fill'/>\n</svg>"
	$troughImgArr(onDisabledBg$n) configure -data $imgData

	# sliderImgArr(off$n)
	set imgData $sliderOffData($n)
	set fill [expr {$darkMode ? "#cacaca" : "#ffffff"}]
	set strk [expr {$darkMode ? "#606060" : "#cdcdcd"}]
	append imgData "fill='$fill' stroke='$strk'/>\n</svg>"
	$sliderImgArr(off$n) configure -data $imgData

	# sliderImgArr(offPressed$n)
	set imgData $sliderOffData($n)
	set fill [expr {$darkMode ? "#e4e4e4" : "#f0f0f0"}]
	set strk [expr {$darkMode ? "#6a6a6a" : "#c0c0c0"}]
	append imgData "fill='$fill' stroke='$strk'/>\n</svg>"
	$sliderImgArr(offPressed$n) configure -data $imgData

	# sliderImgArr(offDisabled$n)
	set imgData $sliderOffData($n)
	set fill [expr {$darkMode ? "#595959" : "#fdfdfd"}]
	set strk [expr {$darkMode ? "#393939" : "#ededed"}]
	append imgData "fill='$fill' stroke='$strk'/>\n</svg>"
	$sliderImgArr(offDisabled$n) configure -data $imgData

	# sliderImgArr(on$n)
	set imgData $sliderOnData($n)
	set fill [expr {$darkMode ? "#cacaca" : "#ffffff"}]
	append imgData "fill='$fill'/>\n</svg>"
	$sliderImgArr(on$n) configure -data $imgData

	# sliderImgArr(onPressed$n)
	set imgData $sliderOnData($n)
	set fill [expr {$darkMode ? "#e4e4e4" : "#f0f0f0"}]
	append imgData "fill='$fill'/>\n</svg>"
	$sliderImgArr(onPressed$n) configure -data $imgData

	# sliderImgArr(onDisabled$n)
	set imgData $sliderOnData($n)
	set fill [expr {$darkMode ? "#595959" : "#fdfdfd"}]
	append imgData "fill='$fill'/>\n</svg>"
	$sliderImgArr(onDisabled$n) configure -data $imgData

	ttk::style layout Toggleswitch$n [list \
	    Switch.padding -sticky nswe -children [list \
		Switch$n.trough -sticky {} -children [list \
		    Switch$n.slider -side left -sticky {} \
		]
	    ]
	]
    }
}
