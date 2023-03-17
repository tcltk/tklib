#==============================================================================
# Contains procedures that create the SVG images used by the style elements
# Checkbutton.image_ind and Radiobutton.image_ind of the alt, clam, and default
# themes.
#
# Copyright (c) 2022-2023  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#------------------------------------------------------------------------------
# themepatch::alt::createCheckbtnIndImgs_svg
#
# Creates the SVG images used by the style element Checkbutton.image_ind of the
# alt theme.
#------------------------------------------------------------------------------
proc themepatch::alt::createCheckbtnIndImgs_svg fmt {
    variable ckIndArr
    set ckIndArr(default) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#888" rx="2"/>
	 <rect x="1" y="1" width="14" height="14" fill="#fff" rx="1"/>
	</svg>
    }]
    set ckIndArr(disabled) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#888" rx="2"/>
	 <rect x="1" y="1" width="14" height="14" fill="#d9d9d9" rx="1"/>
	</svg>
    }]
    set ckIndArr(pressed) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#888" rx="2"/>
	 <rect x="1" y="1" width="14" height="14" fill="#c3c3c3" rx="1"/>
	</svg>
    }]
    set ckIndArr(alternate) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#888" rx="2"/>
	 <rect x="1" y="1" width="14" height="14" fill="#fff" rx="1"/>
	 <path d="m4 8h8" fill="none" stroke="#000" stroke-width="2"/>
	</svg>
    }]
    set ckIndArr(alt_disabled) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#888" rx="2"/>
	 <rect x="1" y="1" width="14" height="14" fill="#d9d9d9" rx="1"/>
	 <path d="m4 8h8" fill="none" stroke="#a3a3a3" stroke-width="2"/>
	</svg>
    }]
    set ckIndArr(alt_pressed) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#888" rx="2"/>
	 <rect x="1" y="1" width="14" height="14" fill="#c3c3c3" rx="1"/>
	 <path d="m4 8h8" fill="none" stroke="#000" stroke-width="2"/>
	</svg>
    }]
    set ckIndArr(selected) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#888" rx="2"/>
	 <rect x="1" y="1" width="14" height="14" fill="#fff" rx="1"/>
	 <path d="m4.5 8 3 3 4-6" fill="none" stroke="#000" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
	</svg>
    }]
    set ckIndArr(sel_disabled) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#888" rx="2"/>
	 <rect x="1" y="1" width="14" height="14" fill="#d9d9d9" rx="1"/>
	 <path d="m4.5 8 3 3 4-6" fill="none" stroke="#a3a3a3" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
	</svg>
    }]
    set ckIndArr(sel_pressed) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#888" rx="2"/>
	 <rect x="1" y="1" width="14" height="14" fill="#c3c3c3" rx="1"/>
	 <path d="m4.5 8 3 3 4-6" fill="none" stroke="#000" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
	</svg>
    }]
}

#------------------------------------------------------------------------------
# themepatch::alt::createRadiobtnIndImgs_svg
#
# Creates the SVG images used by the style element Radiobutton.image_ind of the
# alt theme.
#------------------------------------------------------------------------------
proc themepatch::alt::createRadiobtnIndImgs_svg fmt {
    variable rbIndArr
    set rbIndArr(default) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#888"/>
	 <circle cx="8" cy="8" r="7" fill="#fff"/>
	</svg>
    }]
    set rbIndArr(disabled) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#888"/>
	 <circle cx="8" cy="8" r="7" fill="#d9d9d9"/>
	</svg>
    }]
    set rbIndArr(pressed) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#888"/>
	 <circle cx="8" cy="8" r="7" fill="#c3c3c3"/>
	</svg>
    }]
    set rbIndArr(alternate) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#888"/>
	 <circle cx="8" cy="8" r="7" fill="#fff"/>
	 <path d="m4 8h8" fill="none" stroke="#000" stroke-width="2"/>
	</svg>
    }]
    set rbIndArr(alt_disabled) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#888"/>
	 <circle cx="8" cy="8" r="7" fill="#d9d9d9"/>
	 <path d="m4 8h8" fill="none" stroke="#a3a3a3" stroke-width="2"/>
	</svg>
    }]
    set rbIndArr(alt_pressed) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#888"/>
	 <circle cx="8" cy="8" r="7" fill="#c3c3c3"/>
	 <path d="m4 8h8" fill="none" stroke="#000" stroke-width="2"/>
	</svg>
    }]
    set rbIndArr(selected) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#888"/>
	 <circle cx="8" cy="8" r="7" fill="#fff"/>
	 <circle cx="8" cy="8" r="4"/>
	</svg>
    }]
    set rbIndArr(sel_disabled) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#888"/>
	 <circle cx="8" cy="8" r="7" fill="#d9d9d9"/>
	 <circle cx="8" cy="8" r="4" fill="#a3a3a3"/>
	</svg>
    }]
    set rbIndArr(sel_pressed) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#888"/>
	 <circle cx="8" cy="8" r="7" fill="#c3c3c3"/>
	 <circle cx="8" cy="8" r="4"/>
	</svg>
    }]
}

#------------------------------------------------------------------------------
# themepatch::clam::createCheckbtnIndImgs_svg
#
# Creates the SVG images used by the style element Checkbutton.image_ind of the
# clam theme.
#------------------------------------------------------------------------------
proc themepatch::clam::createCheckbtnIndImgs_svg fmt {
    variable ckIndArr
    set ckIndArr(default) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#9e9a91" rx="2"/>
	 <rect x="1" y="1" width="14" height="14" fill="#fff" rx="1"/>
	</svg>
    }]
    set ckIndArr(disabled) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#9e9a91" rx="2"/>
	 <rect x="1" y="1" width="14" height="14" fill="#dcdad5" rx="1"/>
	</svg>
    }]
    set ckIndArr(pressed) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#9e9a91" rx="2"/>
	 <rect x="1" y="1" width="14" height="14" fill="#bab5ab" rx="1"/>
	</svg>
    }]
    set ckIndArr(alternate) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#5895bc" rx="2"/>
	 <path d="m4 8h8" fill="none" stroke="#fff" stroke-width="2"/>
	</svg>
    }]
    set ckIndArr(alt_disabled) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#a0a0a0" rx="2"/>
	 <path d="m4 8h8" fill="none" stroke="#fff" stroke-width="2"/>
	</svg>
    }]
    set ckIndArr(alt_pressed) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#7fb6d8" rx="2"/>
	 <path d="m4 8h8" fill="none" stroke="#fff" stroke-width="2"/>
	</svg>
    }]
    set ckIndArr(selected) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#5895bc" rx="2"/>
	 <path d="m5 5 6 6m0-6-6 6" fill="none" stroke="#fff" stroke-linecap="round" stroke-width="2"/>
	</svg>
    }]
    set ckIndArr(sel_disabled) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#a0a0a0" rx="2"/>
	 <path d="m5 5 6 6m0-6-6 6" fill="none" stroke="#fff" stroke-linecap="round" stroke-width="2"/>
	</svg>
    }]
    set ckIndArr(sel_pressed) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#7fb6d8" rx="2"/>
	 <path d="m5 5 6 6m0-6-6 6" fill="none" stroke="#fff" stroke-linecap="round" stroke-width="2"/>
	</svg>
    }]
}

#------------------------------------------------------------------------------
# themepatch::clam::createRadiobtnIndImgs_svg
#
# Creates the SVG images used by the style element Radiobutton.image_ind of the
# clam theme.
#------------------------------------------------------------------------------
proc themepatch::clam::createRadiobtnIndImgs_svg fmt {
    variable rbIndArr
    set rbIndArr(default) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#9e9a91"/>
	 <circle cx="8" cy="8" r="7" fill="#fff"/>
	</svg>
    }]
    set rbIndArr(disabled) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#9e9a91"/>
	 <circle cx="8" cy="8" r="7" fill="#dcdad5"/>
	</svg>
    }]
    set rbIndArr(pressed) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#9e9a91"/>
	 <circle cx="8" cy="8" r="7" fill="#bab5ab"/>
	</svg>
    }]
    set rbIndArr(alternate) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#5895bc"/>
	 <path d="m4 8h8" fill="none" stroke="#fff" stroke-width="2"/>
	</svg>
    }]
    set rbIndArr(alt_disabled) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#a0a0a0"/>
	 <path d="m4 8h8" fill="none" stroke="#fff" stroke-width="2"/>
	</svg>
    }]
    set rbIndArr(alt_pressed) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#7fb6d8"/>
	 <path d="m4 8h8" fill="none" stroke="#fff" stroke-width="2"/>
	</svg>
    }]
    set rbIndArr(selected) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#5895bc"/>
	 <circle cx="8" cy="8" r="3" fill="#fff"/>
	</svg>
    }]
    set rbIndArr(sel_disabled) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#a0a0a0"/>
	 <circle cx="8" cy="8" r="3" fill="#fff"/>
	</svg>
    }]
    set rbIndArr(sel_pressed) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#7fb6d8"/>
	 <circle cx="8" cy="8" r="3" fill="#fff"/>
	</svg>
    }]
}

#------------------------------------------------------------------------------
# themepatch::default::createCheckbtnIndImgs_svg
#
# Creates the SVG images used by the style element Checkbutton.image_ind of the
# default theme.
#------------------------------------------------------------------------------
proc themepatch::default::createCheckbtnIndImgs_svg fmt {
    variable ckIndArr
    set ckIndArr(default) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#888" rx="2"/>
	 <rect x="1" y="1" width="14" height="14" fill="#fff" rx="1"/>
	</svg>
    }]
    set ckIndArr(disabled) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#888" rx="2"/>
	 <rect x="1" y="1" width="14" height="14" fill="#d9d9d9" rx="1"/>
	</svg>
    }]
    set ckIndArr(pressed) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#888" rx="2"/>
	 <rect x="1" y="1" width="14" height="14" fill="#c3c3c3" rx="1"/>
	</svg>
    }]
    set ckIndArr(alternate) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#5cacee" rx="2"/>
	 <path d="m4 8h8" fill="none" stroke="#fff" stroke-width="2"/>
	</svg>
    }]
    set ckIndArr(alt_disabled) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#a3a3a3" rx="2"/>
	 <path d="m4 8h8" fill="none" stroke="#fff" stroke-width="2"/>
	</svg>
    }]
    set ckIndArr(alt_pressed) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#7fb6d8" rx="2"/>
	 <path d="m4 8h8" fill="none" stroke="#fff" stroke-width="2"/>
	</svg>
    }]
    set ckIndArr(selected) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#5cacee" rx="2"/>
	 <path d="m4.5 8 3 3 4-6" fill="none" stroke="#fff" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
	</svg>
    }]
    set ckIndArr(sel_disabled) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#a3a3a3" rx="2"/>
	 <path d="m4.5 8 3 3 4-6" fill="none" stroke="#fff" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
	</svg>
    }]
    set ckIndArr(sel_pressed) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <rect x="0" y="0" width="16" height="16" fill="#7fb6d8" rx="2"/>
	 <path d="m4.5 8 3 3 4-6" fill="none" stroke="#fff" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
	</svg>
    }]
}

#------------------------------------------------------------------------------
# themepatch::default::createRadiobtnIndImgs_svg
#
# Creates the SVG images used by the style element Radiobutton.image_ind of the
# default theme.
#------------------------------------------------------------------------------
proc themepatch::default::createRadiobtnIndImgs_svg fmt {
    variable rbIndArr
    set rbIndArr(default) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#888"/>
	 <circle cx="8" cy="8" r="7" fill="#fff"/>
	</svg>
    }]
    set rbIndArr(disabled) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#888"/>
	 <circle cx="8" cy="8" r="7" fill="#d9d9d9"/>
	</svg>
    }]
    set rbIndArr(pressed) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#888"/>
	 <circle cx="8" cy="8" r="7" fill="#c3c3c3"/>
	</svg>
    }]
    set rbIndArr(alternate) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#5cacee"/>
	 <path d="m4 8h8" fill="none" stroke="#fff" stroke-width="2"/>
	</svg>
    }]
    set rbIndArr(alt_disabled) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#a3a3a3"/>
	 <path d="m4 8h8" fill="none" stroke="#fff" stroke-width="2"/>
	</svg>
    }]
    set rbIndArr(alt_pressed) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#7fb6d8"/>
	 <path d="m4 8h8" fill="none" stroke="#fff" stroke-width="2"/>
	</svg>
    }]
    set rbIndArr(selected) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#5cacee"/>
	 <circle cx="8" cy="8" r="3" fill="#fff"/>
	</svg>
    }]
    set rbIndArr(sel_disabled) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#a3a3a3"/>
	 <circle cx="8" cy="8" r="3" fill="#fff"/>
	</svg>
    }]
    set rbIndArr(sel_pressed) [image create photo -format $fmt -data {
	<svg width="16" height="16" version="1.1" xmlns="http://www.w3.org/2000/svg">
	 <circle cx="8" cy="8" r="8" fill="#7fb6d8"/>
	 <circle cx="8" cy="8" r="3" fill="#fff"/>
	</svg>
    }]
}
