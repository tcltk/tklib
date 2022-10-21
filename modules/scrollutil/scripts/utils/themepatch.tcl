#==============================================================================
# Contains procedures designed for patching and unpatching the clam and default
# themes.
#
# Structure of the module:
#   - Namespace initialization
#   - Public utility procedures
#   - Private helper procedures
#
# Copyright (c) 2022  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require Tk 8.4
if {$::tk_version < 8.5 || [regexp {^8\.5a[1-5]$} $::tk_patchLevel]} {
    package require tile 0.8
}
package require scaleutil 1.6

#
# Namespace initialization
# ========================
#

namespace eval themepatch {
    #
    # Public variables:
    #
    variable version	1.2
    variable library	[file dirname [file normalize [info script]]]

    #
    # Public procedures:
    #
    namespace export	patchTheme unpatchTheme
}

package provide themepatch $themepatch::version

#
# Public utility procedures
# =========================
#

#------------------------------------------------------------------------------
# themepatch::patchTheme
#
# Patches some styles of the given theme.
#------------------------------------------------------------------------------
proc themepatch::patchTheme theme {
    switch $theme {
	clam -
	default { patchTheme_$theme }
	default {
	    return -code error "bad theme \"$theme\": must be clam or default"
	}
    }
}

#------------------------------------------------------------------------------
# themepatch::unpatchTheme
#
# Unpatches some styles of the given theme.
#------------------------------------------------------------------------------
proc themepatch::unpatchTheme theme {
    switch $theme {
	clam -
	default { unpatchTheme_$theme }
	default {
	    return -code error "bad theme \"$theme\": must be clam or default"
	}
    }
}

#
# Private helper procedures
# =========================
#

namespace eval themepatch::clam    {}
namespace eval themepatch::default {}

#------------------------------------------------------------------------------
# themepatch::patchTheme_clam
#
# Patches the styles TButton, Heading, TCheckbutton, and TRadiobutton of the
# clam theme.
#------------------------------------------------------------------------------
proc themepatch::patchTheme_clam {} {
    set pct [::scaleutil::scalingPercentage [tk windowingsystem]]

    #
    # Save the TCheckbutton and TRadiobutton layouts of the other
    # themes, because some of them might have clam as ancestor
    #
    foreach theme [ttk::style theme names] {
	if {$theme ne "clam"} {
	    ttk::style theme settings $theme {
		set ckbtnLayoutArr($theme) [ttk::style layout TCheckbutton]
		set rdbtnLayoutArr($theme) [ttk::style layout TRadiobutton]
	    }
	}
    }

    ttk::style theme settings clam {
	#
	# TButton
	#
	set pad [::scaleutil::scale 3 $pct]
	ttk::style configure TButton -padding $pad -width -9  ;# default: 5, -11

	#
	# Treeview Heading and Tablelist
	#
	ttk::style configure Heading -padding 1			;# default: 3
	if {[info exists ::tablelist::version] &&
	    $::tablelist::version < 6.18 &&
	    [llength [info procs ::tablelist::_clamTheme]] == 0} {
	    rename ::tablelist::clamTheme ::tablelist::_clamTheme
	    proc ::tablelist::clamTheme {} {
		::tablelist::_clamTheme
		variable themeDefaults
		set themeDefaults(-labelpady) 1			;# default: 3
	    }
	}

	#
	# Create the Checkbutton.image_ind and Radiobutton.image_ind elements
	#
	set pad [::scaleutil::scale 4 $pct]
        if {[lsearch -exact [ttk::style element names] \
             "Checkbutton.image_ind"]  < 0} {
	    clam::createCheckbtnIndImgs $pct
	    variable clam::ckIndArr
            set ckIndWidth [expr {[image width $ckIndArr(default)] + $pad}]
	    ttk::style element create Checkbutton.image_ind image [list \
		$ckIndArr(default) \
		{alternate disabled}	$ckIndArr(alternate_disabled) \
		{alternate pressed}	$ckIndArr(alternate_pressed) \
		alternate		$ckIndArr(alternate) \
		{selected disabled}	$ckIndArr(selected_disabled) \
		{selected pressed}	$ckIndArr(selected_pressed) \
		selected		$ckIndArr(selected) \
		disabled		$ckIndArr(disabled) \
		pressed			$ckIndArr(pressed) \
	    ] -width $ckIndWidth -sticky w
	}
        if {[lsearch -exact [ttk::style element names] \
             "Radiobutton.image_ind"]  < 0} {
	    clam::createRadiobtnIndImgs $pct
	    variable clam::rbIndArr
            set rbIndWidth [expr {[image width $rbIndArr(default)] + $pad}]
	    ttk::style element create Radiobutton.image_ind image [list \
		$rbIndArr(default) \
		{alternate disabled}	$rbIndArr(alternate_disabled) \
		{alternate pressed}	$rbIndArr(alternate_pressed) \
		alternate		$rbIndArr(alternate) \
		{selected disabled}	$rbIndArr(selected_disabled) \
		{selected pressed}	$rbIndArr(selected_pressed) \
		selected		$rbIndArr(selected) \
		disabled		$rbIndArr(disabled) \
		pressed			$rbIndArr(pressed) \
	    ] -width $rbIndWidth -sticky w
	}

	#
	# Redefine the TCheckbutton and TRadiobutton layouts
	#
	ttk::style layout TCheckbutton {
	    Checkbutton.padding -sticky nswe -children {
		Checkbutton.image_ind -side left -sticky ""
		Checkbutton.focus -side left -sticky w -children {
		    Checkbutton.label -sticky nswe
		}
	    }
	}
	ttk::style layout TRadiobutton {
	    Radiobutton.padding -sticky nswe -children {
		Radiobutton.image_ind -side left -sticky ""
		Radiobutton.focus -side left -sticky w -children {
		    Radiobutton.label -sticky nswe
		}
	    }
	}
    }

    #
    # Restore the TCheckbutton and TRadiobutton layouts of the other themes
    #
    foreach theme [array names ckbtnLayoutArr] {
	ttk::style theme settings $theme {
	    ttk::style layout TCheckbutton $ckbtnLayoutArr($theme)
	    ttk::style layout TRadiobutton $rdbtnLayoutArr($theme)
	}
    }

    #
    # Send a <<ThemeChanged>> virtual event to all widgets
    #
    ::ttk::ThemeChanged
}

#------------------------------------------------------------------------------
# themepatch::unpatchTheme_clam
#
# Unpatches the styles TButton, Heading, TCheckbutton, and TRadiobutton of the
# clam theme.
#------------------------------------------------------------------------------
proc themepatch::unpatchTheme_clam {} {
    set pct [::scaleutil::scalingPercentage [tk windowingsystem]]

    ttk::style theme settings clam {
	#
	# TButton
	#
	set pad [::scaleutil::scale 5 $pct]
	ttk::style configure TButton -padding $pad -width -11

	#
	# Treeview Heading and Tablelist
	#
	set pad [::scaleutil::scale 3 $pct]
	ttk::style configure Heading -padding $pad
	if {[info exists ::tablelist::version] &&
	    $::tablelist::version < 6.18 &&
	    [llength [info procs ::tablelist::_clamTheme]] == 1} {
	    rename ::tablelist::clamTheme ""
	    rename ::tablelist::_clamTheme ::tablelist::clamTheme
	}

	#
	# Restore the TCheckbutton and TRadiobutton layouts
	#
	ttk::style layout TCheckbutton {
	    Checkbutton.padding -sticky nswe -children {
		Checkbutton.indicator -side left -sticky ""
		Checkbutton.focus -side left -sticky w -children {
		    Checkbutton.label -sticky nswe
		}
	    }
	}
	ttk::style layout TRadiobutton {
	    Radiobutton.padding -sticky nswe -children {
		Radiobutton.indicator -side left -sticky ""
		Radiobutton.focus -side left -sticky w -children {
		    Radiobutton.label -sticky nswe
		}
	    }
	}
    }

    #
    # Send a <<ThemeChanged>> virtual event to all widgets
    #
    ::ttk::ThemeChanged
}

#------------------------------------------------------------------------------
# themepatch::patchTheme_default
#
# Patches the styles TCheckbutton and TRadiobutton of the default theme.
#------------------------------------------------------------------------------
proc themepatch::patchTheme_default {} {
    set pct [::scaleutil::scalingPercentage [tk windowingsystem]]
    set pad [::scaleutil::scale 5 $pct]

    #
    # Save the TCheckbutton and TRadiobutton layouts of the
    # other themes, because they have default as ancestor
    #
    foreach theme [ttk::style theme names] {
	if {$theme ne "default"} {
	    ttk::style theme settings $theme {
		set ckbtnLayoutArr($theme) [ttk::style layout TCheckbutton]
		set rdbtnLayoutArr($theme) [ttk::style layout TRadiobutton]
	    }
	}
    }

    ttk::style theme settings default {
	#
	# Create the Checkbutton.image_ind and Radiobutton.image_ind elements
	#
        if {[lsearch -exact [ttk::style element names] \
             "Checkbutton.image_ind"]  < 0} {
	    default::createCheckbtnIndImgs $pct
	    variable default::ckIndArr
            set ckIndWidth [expr {[image width $ckIndArr(default)] + $pad}]
	    ttk::style element create Checkbutton.image_ind image [list \
		$ckIndArr(default) \
		{alternate disabled}	$ckIndArr(alternate_disabled) \
		{alternate pressed}	$ckIndArr(alternate_pressed) \
		alternate		$ckIndArr(alternate) \
		{selected disabled}	$ckIndArr(selected_disabled) \
		{selected pressed}	$ckIndArr(selected_pressed) \
		selected		$ckIndArr(selected) \
		disabled		$ckIndArr(disabled) \
		pressed			$ckIndArr(pressed) \
	    ] -width $ckIndWidth -sticky w
	}
        if {[lsearch -exact [ttk::style element names] \
             "Radiobutton.image_ind"]  < 0} {
	    default::createRadiobtnIndImgs $pct
	    variable default::rbIndArr
            set rbIndWidth [expr {[image width $rbIndArr(default)] + $pad}]
	    ttk::style element create Radiobutton.image_ind image [list \
		$rbIndArr(default) \
		{alternate disabled}	$rbIndArr(alternate_disabled) \
		{alternate pressed}	$rbIndArr(alternate_pressed) \
		alternate		$rbIndArr(alternate) \
		{selected disabled}	$rbIndArr(selected_disabled) \
		{selected pressed}	$rbIndArr(selected_pressed) \
		selected		$rbIndArr(selected) \
		disabled		$rbIndArr(disabled) \
		pressed			$rbIndArr(pressed) \
	    ] -width $rbIndWidth -sticky w
	}

	#
	# Redefine the TCheckbutton and TRadiobutton layouts
	#
	ttk::style layout TCheckbutton {
	    Checkbutton.padding -sticky nswe -children {
		Checkbutton.image_ind -side left -sticky ""
		Checkbutton.focus -side left -sticky w -children {
		    Checkbutton.label -sticky nswe
		}
	    }
	}
	ttk::style layout TRadiobutton {
	    Radiobutton.padding -sticky nswe -children {
		Radiobutton.image_ind -side left -sticky ""
		Radiobutton.focus -side left -sticky w -children {
		    Radiobutton.label -sticky nswe
		}
	    }
	}
    }

    #
    # Restore the TCheckbutton and TRadiobutton layouts of the other themes
    #
    foreach theme [array names ckbtnLayoutArr] {
	ttk::style theme settings $theme {
	    ttk::style layout TCheckbutton $ckbtnLayoutArr($theme)
	    ttk::style layout TRadiobutton $rdbtnLayoutArr($theme)
	}
    }

    #
    # Send a <<ThemeChanged>> virtual event to all widgets
    #
    ::ttk::ThemeChanged
}

#------------------------------------------------------------------------------
# themepatch::unpatchTheme_default
#
# Unpatches the styles TCheckbutton and TRadiobutton of the default theme.
#------------------------------------------------------------------------------
proc themepatch::unpatchTheme_default {} {
    ttk::style theme settings default {
	#
	# Restore the TCheckbutton and TRadiobutton layouts
	#
	ttk::style layout TCheckbutton {
	    Checkbutton.padding -sticky nswe -children {
		Checkbutton.indicator -side left -sticky ""
		Checkbutton.focus -side left -sticky w -children {
		    Checkbutton.label -sticky nswe
		}
	    }
	}
	ttk::style layout TRadiobutton {
	    Radiobutton.padding -sticky nswe -children {
		Radiobutton.indicator -side left -sticky ""
		Radiobutton.focus -side left -sticky w -children {
		    Radiobutton.label -sticky nswe
		}
	    }
	}
    }

    #
    # Send a <<ThemeChanged>> virtual event to all widgets
    #
    ::ttk::ThemeChanged
}

#------------------------------------------------------------------------------
# themepatch::clam::createCheckbtnIndImgs
#
# Creates the images used by the style element Checkbutton.image_ind of the
# clam theme.
#------------------------------------------------------------------------------
proc themepatch::clam::createCheckbtnIndImgs pct {
    variable ckIndArr
    switch $pct {
	100 {
	    set ckIndArr(default) [image create photo -data "
R0lGODlhDwAPAKECAJ6ake7r5////////yH5BAEKAAMALAAAAAAPAA8AAAInHI6JFu3vThC0WhHk
3RnMbXUfSIlkZZ6YpqanS8KgzEnQnRnKDgwFADs="]
	    set ckIndArr(disabled) [image create photo -data "
R0lGODlhDwAPAKEDAJ6ake7r59za1f///yH5BAEKAAMALAAAAAAPAA8AAAInHI6JFu3vThC0WhHk
3RnMbXUfSIlkZZ6YpqanS8KgzEnQnRnKDgwFADs="]
	    set ckIndArr(pressed) [image create photo -data "
R0lGODlhDwAPAHAAACH5BAEAAAMALAAAAAAPAA8AgZ6ake7r57q1qwAAAAInHI6JFu3vThC0WhHk
3RnMbXUfSIlkZZ6YpqanS8KgzEnQnRnKDgwFADs="]
	    set ckIndArr(alternate) [image create photo -data "
R0lGODlhDwAPAKEDAJ6ake7r51iVvP///yH5BAEKAAMALAAAAAAPAA8AAAInHI6JFu3vThC0WhHk
3RnMbXUfSIlkZZ6YpqanS8KgzEnQnRnKDgwFADs="]
	    set ckIndArr(alternate_disabled) [image create photo -data "
R0lGODlhDwAPAKEDAJ6ake7r56CgoP///yH5BAEKAAMALAAAAAAPAA8AAAInHI6JFu3vThC0WhHk
3RnMbXUfSIlkZZ6YpqanS8KgzEnQnRnKDgwFADs="]
	    set ckIndArr(alternate_pressed) [image create photo -data "
R0lGODlhDwAPAKEDAJ6ake7r53+22P///yH5BAEKAAMALAAAAAAPAA8AAAInHI6JFu3vThC0WhHk
3RnMbXUfSIlkZZ6YpqanS8KgzEnQnRnKDgwFADs="]
	    set ckIndArr(selected) [image create photo -data "
R0lGODlhDwAPAKEBAFiVvP///////////yH5BAEKAAIALAAAAAAPAA8AAAIaFI6Jpu0Po5wg0GBd
rrthLmEdNFLm2TCSUAAAOw=="]
	    set ckIndArr(selected_disabled) [image create photo -data "
R0lGODlhDwAPAKEBAKCgoP///////////yH5BAEKAAIALAAAAAAPAA8AAAIaFI6Jpu0Po5wg0GBd
rrthLmEdNFLm2TCSUAAAOw=="]
	    set ckIndArr(selected_pressed) [image create photo -data "
R0lGODlhDwAPAKEBAH+22P///////////yH5BAEKAAIALAAAAAAPAA8AAAIaFI6Jpu0Po5wg0GBd
rrthLmEdNFLm2TCSUAAAOw=="]
	}

	125 {
	    set ckIndArr(default) [image create photo -data "
R0lGODlhEgASAKECAJ6ake7r5////////yH5BAEKAAMALAAAAAASABIAAAIvHI6pYOEPYzhB2Ivx
BDV7u3VfFo5eaWpUqnLshb4xO6e1eY/5t5+UBHQwFkTEoAAAOw=="]
	    set ckIndArr(disabled) [image create photo -data "
R0lGODlhEgASAKEDAJ6ake7r59za1f///yH5BAEKAAMALAAAAAASABIAAAIvHI6pYOEPYzhB2Ivx
BDV7u3VfFo5eaWpUqnLshb4xO6e1eY/5t5+UBHQwFkTEoAAAOw=="]
	    set ckIndArr(pressed) [image create photo -data "
R0lGODlhEgASAKEDAJ6ake7r57q1q////yH5BAEKAAMALAAAAAASABIAAAIvHI6pYOEPYzhB2Ivx
BDV7u3VfFo5eaWpUqnLshb4xO6e1eY/5t5+UBHQwFkTEoAAAOw=="]
	    set ckIndArr(alternate) [image create photo -data "
R0lGODlhEgASAKEDAJ6ake7r51iVvP///yH5BAEKAAMALAAAAAASABIAAAIvHI6pYOEPYzhB2Ivx
BDV7u3VfFo5eaWpUqnLshb4xO6e1eY/5t5+UBHQwFkTEoAAAOw=="]
	    set ckIndArr(alternate_disabled) [image create photo -data "
R0lGODlhEgASAKEDAJ6ake7r56CgoP///yH5BAEKAAMALAAAAAASABIAAAIvHI6pYOEPYzhB2Ivx
BDV7u3VfFo5eaWpUqnLshb4xO6e1eY/5t5+UBHQwFkTEoAAAOw=="]
	    set ckIndArr(alternate_pressed) [image create photo -data "
R0lGODlhEgASAKEDAJ6ake7r53+22P///yH5BAEKAAMALAAAAAASABIAAAIvHI6pYOEPYzhB2Ivx
BDV7u3VfFo5eaWpUqnLshb4xO6e1eY/5t5+UBHQwFkTEoAAAOw=="]
	    set ckIndArr(selected) [image create photo -data "
R0lGODlhEgASAKEBAFiVvP///////////yH5BAEKAAIALAAAAAASABIAAAIdFI6pYOsPo5y0ymBB
wHVf5F1YOG1cl6XqOjWVUAAAOw=="]
	    set ckIndArr(selected_disabled) [image create photo -data "
R0lGODlhEgASAKEBAKCgoP///////////yH5BAEKAAIALAAAAAASABIAAAIdFI6pYOsPo5y0ymBB
wHVf5F1YOG1cl6XqOjWVUAAAOw=="]
	    set ckIndArr(selected_pressed) [image create photo -data "
R0lGODlhEgASAKEBAH+22P///////////yH5BAEKAAIALAAAAAASABIAAAIdFI6pYOsPo5y0ymBB
wHVf5F1YOG1cl6XqOjWVUAAAOw=="]
	}

	150 {
	    set ckIndArr(default) [image create photo -data "
R0lGODlhFgAWAKECAJ6ake7r5////////yH5BAEKAAMALAAAAAAWABYAAAI7HI6pauEPYzxB2Ivz
DVT7zAHVR4Yj6Znop65a62JwbM20HeOuvvKoX+rQNsKhAMgqDk2SpgRgWEgXgwIAOw=="]
	    set ckIndArr(disabled) [image create photo -data "
R0lGODlhFgAWAKEDAJ6ake7r59za1f///yH5BAEKAAMALAAAAAAWABYAAAI7HI6pauEPYzxB2Ivz
DVT7zAHVR4Yj6Znop65a62JwbM20HeOuvvKoX+rQNsKhAMgqDk2SpgRgWEgXgwIAOw=="]
	    set ckIndArr(pressed) [image create photo -data "
R0lGODlhFgAWAKEDAJ6ake7r59za1f///yH5BAEKAAMALAAAAAAWABYAAAI7HI6pauEPYzxB2Ivz
DVT7zAHVR4Yj6Znop65a62JwbM20HeOuvvKoX+rQNsKhAMgqDk2SpgRgWEgXgwIAOw=="]
	    set ckIndArr(alternate) [image create photo -data "
R0lGODlhFgAWAKEDAJ6ake7r51iVvP///yH5BAEKAAMALAAAAAAWABYAAAI7HI6pauEPYzxB2Ivz
DVT7zAHVR4Yj6Znop65a62JwbM20HeOuvvKoX+rQNsKhAMgqDk2SpgRgWEgXgwIAOw=="]
	    set ckIndArr(alternate_disabled) [image create photo -data "
R0lGODlhFgAWAKEDAJ6ake7r56CgoP///yH5BAEKAAMALAAAAAAWABYAAAI7HI6pauEPYzxB2Ivz
DVT7zAHVR4Yj6Znop65a62JwbM20HeOuvvKoX+rQNsKhAMgqDk2SpgRgWEgXgwIAOw=="]
	    set ckIndArr(alternate_pressed) [image create photo -data "
R0lGODlhFgAWAKEDAJ6ake7r53+22P///yH5BAEKAAMALAAAAAAWABYAAAI7HI6pauEPYzxB2Ivz
DVT7zAHVR4Yj6Znop65a62JwbM20HeOuvvKoX+rQNsKhAMgqDk2SpgRgWEgXgwIAOw=="]
	    set ckIndArr(selected) [image create photo -data "
R0lGODlhFgAWAKEBAFiVvP///////////yH5BAEKAAIALAAAAAAWABYAAAImFI6pausPo5y02otf
CBlsjn2ZKG0JWZqeSn1o5XZsR9f2XTWZUAAAOw=="]
	    set ckIndArr(selected_disabled) [image create photo -data "
R0lGODlhFgAWAKEBAKCgoP///////////yH5BAEKAAIALAAAAAAWABYAAAImFI6pausPo5y02otf
CBlsjn2ZKG0JWZqeSn1o5XZsR9f2XTWZUAAAOw=="]
	    set ckIndArr(selected_pressed) [image create photo -data "
R0lGODlhFgAWAKEBAH+22P///////////yH5BAEKAAIALAAAAAAWABYAAAImFI6pausPo5y02otf
CBlsjn2ZKG0JWZqeSn1o5XZsR9f2XTWZUAAAOw=="]
	}

	175 {
	    set ckIndArr(default) [image create photo -data "
R0lGODlhGQAZAMICAJ6ake7r5////6CclKCck6ypof///////yH5BAEKAAcALAAAAAAZABkAAANI
eLDc/kuFSau9cwXBu/9goIFkKQJbqXZnuqrtu8ayOdYkjX/6zt6+Hyro6QWNPuROiWPWnDLoSzoD
EqkwwADD5RIOBYgYckgAADs="]
	    set ckIndArr(disabled) [image create photo -data "
R0lGODlhGQAZAMIGAJ6ake7r59za1aCclKCck6ypof///////yH5BAEKAAcALAAAAAAZABkAAANI
eLDc/kuFSau9cwXBu/9goIFkKQJbqXZnuqrtu8ayOdYkjX/6zt6+Hyro6QWNPuROiWPWnDLoSzoD
EqkwwADD5RIOBYgYckgAADs="]
	    set ckIndArr(pressed) [image create photo -data "
R0lGODlhGQAZAMIGAJ6ake7r57q1q6CclKCck6ypof///////yH5BAEKAAcALAAAAAAZABkAAANI
eLDc/kuFSau9cwXBu/9goIFkKQJbqXZnuqrtu8ayOdYkjX/6zt6+Hyro6QWNPuROiWPWnDLoSzoD
EqkwwADD5RIOBYgYckgAADs="]
	    set ckIndArr(alternate) [image create photo -data "
R0lGODlhGQAZAMIGAJ6ake7r51iVvKCclKCck6ypof///////yH5BAEKAAcALAAAAAAZABkAAANI
eLDc/kuFSau9cwXBu/9goIFkKQJbqXZnuqrtu8ayOdYkjX/6zt6+Hyro6QWNPuROiWPWnDLoSzoD
EqkwwADD5RIOBYgYckgAADs="]
	    set ckIndArr(alternate_disabled) [image create photo -data "
R0lGODlhGQAZAMIGAJ6ake7r56CgoKCclKCck6ypof///////yH5BAEKAAcALAAAAAAZABkAAANI
eLDc/kuFSau9cwXBu/9goIFkKQJbqXZnuqrtu8ayOdYkjX/6zt6+Hyro6QWNPuROiWPWnDLoSzoD
EqkwwADD5RIOBYgYckgAADs="]
	    set ckIndArr(alternate_pressed) [image create photo -data "
R0lGODlhGQAZAMIGAJ6ake7r53+22KCclKCck6ypof///////yH5BAEKAAcALAAAAAAZABkAAANI
eLDc/kuFSau9cwXBu/9goIFkKQJbqXZnuqrtu8ayOdYkjX/6zt6+Hyro6QWNPuROiWPWnDLoSzoD
EqkwwADD5RIOBYgYckgAADs="]
	    set ckIndArr(selected) [image create photo -data "
R0lGODlhGQAZAKEBAFiVvP///////////yH5BAEKAAIALAAAAAAZABkAAAIuFI6pe8YPo5y02osz
DkEj3nlgmI0iOHGLmaofSrFsNc5WTW7w6fX+DwwmHD1BAQA7"]
	    set ckIndArr(selected_disabled) [image create photo -data "
R0lGODlhGQAZAKEBAKCgoP///////////yH5BAEKAAIALAAAAAAZABkAAAIuFI6pe8YPo5y02osz
DkEj3nlgmI0iOHGLmaofSrFsNc5WTW7w6fX+DwwmHD1BAQA7"]
	    set ckIndArr(selected_pressed) [image create photo -data "
R0lGODlhGQAZAKEBAH+22P///////////yH5BAEKAAIALAAAAAAZABkAAAIuFI6pe8YPo5y02osz
DkEj3nlgmI0iOHGLmaofSrFsNc5WTW7w6fX+DwwmHD1BAQA7"]
	}

	200 {
	    set ckIndArr(default) [image create photo -data "
R0lGODlhHAAcAKECAJ6ake7r5////////yH5BAEKAAMALAAAAAAcABwAAAJNHI6pqxYPo5zyBIGz
3jwH24XiB1ziqZEmiqos675nLId0zd14Cu557+OVghtd0OhD7pQ4Zs0pg76kMCBRQG1ZidmZhQIO
fwyMshkwKAAAOw=="]
	    set ckIndArr(disabled) [image create photo -data "
R0lGODlhHAAcAKEDAJ6ake7r59za1f///yH5BAEKAAMALAAAAAAcABwAAAJNHI6pqxYPo5zyBIGz
3jwH24XiB1ziqZEmiqos675nLId0zd14Cu557+OVghtd0OhD7pQ4Zs0pg76kMCBRQG1ZidmZhQIO
fwyMshkwKAAAOw=="]
	    set ckIndArr(pressed) [image create photo -data "
R0lGODlhHAAcAKEDAJ6ake7r57q1q////yH5BAEKAAMALAAAAAAcABwAAAJNHI6pqxYPo5zyBIGz
3jwH24XiB1ziqZEmiqos675nLId0zd14Cu557+OVghtd0OhD7pQ4Zs0pg76kMCBRQG1ZidmZhQIO
fwyMshkwKAAAOw=="]
	    set ckIndArr(alternate) [image create photo -data "
R0lGODlhHAAcAKEDAJ6ake7r51iVvP///yH5BAEKAAMALAAAAAAcABwAAAJNHI6pqxYPo5zyBIGz
3jwH24XiB1ziqZEmiqos675nLId0zd14Cu557+OVghtd0OhD7pQ4Zs0pg76kMCBRQG1ZidmZhQIO
fwyMshkwKAAAOw=="]
	    set ckIndArr(alternate_disabled) [image create photo -data "
R0lGODlhHAAcAKEDAJ6ake7r56CgoP///yH5BAEKAAMALAAAAAAcABwAAAJNHI6pqxYPo5zyBIGz
3jwH24XiB1ziqZEmiqos675nLId0zd14Cu557+OVghtd0OhD7pQ4Zs0pg76kMCBRQG1ZidmZhQIO
fwyMshkwKAAAOw=="]
	    set ckIndArr(alternate_pressed) [image create photo -data "
R0lGODlhHAAcAKEDAJ6ake7r53+22P///yH5BAEKAAMALAAAAAAcABwAAAJNHI6pqxYPo5zyBIGz
3jwH24XiB1ziqZEmiqos675nLId0zd14Cu557+OVghtd0OhD7pQ4Zs0pg76kMCBRQG1ZidmZhQIO
fwyMshkwKAAAOw=="]
	    set ckIndArr(selected) [image create photo -data "
R0lGODlhHAAcAKEBAFiVvP///////////yH5BAEKAAIALAAAAAAcABwAAAI5FI6pq8YPo5y02ouz
1iFs1XnfEYpfaXLliE7d07ovuFI1ecshvl9ojPnNVDli6nQcKZfMpjPhWAoKADs="]
	    set ckIndArr(selected_disabled) [image create photo -data "
R0lGODlhHAAcAKEBAKCgoP///////////yH5BAEKAAIALAAAAAAcABwAAAI5FI6pq8YPo5y02ouz
1iFs1XnfEYpfaXLliE7d07ovuFI1ecshvl9ojPnNVDli6nQcKZfMpjPhWAoKADs="]
	    set ckIndArr(selected_pressed) [image create photo -data "
R0lGODlhHAAcAKEBAH+22P///////////yH5BAEKAAIALAAAAAAcABwAAAI5FI6pq8YPo5y02ouz
1iFs1XnfEYpfaXLliE7d07ovuFI1ecshvl9ojPnNVDli6nQcKZfMpjPhWAoKADs="]
	}
    }
}

#------------------------------------------------------------------------------
# themepatch::clam::createRadiobtnIndImgs
#
# Creates the images used by the style element Radiobutton.image_ind of the
# clam theme.
#------------------------------------------------------------------------------
proc themepatch::clam::createRadiobtnIndImgs pct {
    variable rbIndArr
    switch $pct {
	100 {
	    set rbIndArr(default) [image create photo -data "
R0lGODlhDwAPAKECAJ6ake7r5////////yH5BAEKAAMALAAAAAAPAA8AAAIxnA2Zx5MB4WIAinvl
qbhngAReF4DcSD5oeq5C2a6w6L4mjZahq4d41ttUIrCGUNEoAAA7"]
	    set rbIndArr(disabled) [image create photo -data "
R0lGODlhDwAPAKEDAJ6ake7r59za1f///yH5BAEKAAMALAAAAAAPAA8AAAIxnA2Zx5MB4WIAinvl
qbhngAReF4DcSD5oeq5C2a6w6L4mjZahq4d41ttUIrCGUNEoAAA7"]
	    set rbIndArr(pressed) [image create photo -data "
R0lGODlhDwAPAKEDAJ6ake7r57q1q////yH5BAEKAAMALAAAAAAPAA8AAAIxnA2Zx5MB4WIAinvl
qbhngAReF4DcSD5oeq5C2a6w6L4mjZahq4d41ttUIrCGUNEoAAA7"]
	    set rbIndArr(alternate) [image create photo -data "
R0lGODlhDwAPAKEDAJ6ake7r51iVvP///yH5BAEKAAMALAAAAAAPAA8AAAIxnA2Zx5MB4WIAinvl
qbhngAReF4DcSD5oeq5C2a6w6L4mjZahq4d41ttUIrCGUNEoAAA7"]
	    set rbIndArr(alternate_disabled) [image create photo -data "
R0lGODlhDwAPAKEDAJ6ake7r56CgoP///yH5BAEKAAMALAAAAAAPAA8AAAIxnA2Zx5MB4WIAinvl
qbhngAReF4DcSD5oeq5C2a6w6L4mjZahq4d41ttUIrCGUNEoAAA7"]
	    set rbIndArr(alternate_pressed) [image create photo -data "
R0lGODlhDwAPAKEDAJ6ake7r53+22P///yH5BAEKAAMALAAAAAAPAA8AAAIxnA2Zx5MB4WIAinvl
qbhngAReF4DcSD5oeq5C2a6w6L4mjZahq4d41ttUIrCGUNEoAAA7"]
	    set rbIndArr(selected) [image create photo -data "
R0lGODlhDwAPAKEBAFiVvP///////////yH5BAEKAAIALAAAAAAPAA8AAAImlA2Zx6K/GJxnWvSC
hi7rbQHfGI5faQahSD6dcrrvClR0sza20hQAOw=="]
	    set rbIndArr(selected_disabled) [image create photo -data "
R0lGODlhDwAPAKEBAKCgoP///////////yH5BAEKAAIALAAAAAAPAA8AAAImlA2Zx6K/GJxnWvSC
hi7rbQHfGI5faQahSD6dcrrvClR0sza20hQAOw=="]
	    set rbIndArr(selected_pressed) [image create photo -data "
R0lGODlhDwAPAKEBAH+22P///////////yH5BAEKAAIALAAAAAAPAA8AAAImlA2Zx6K/GJxnWvSC
hi7rbQHfGI5faQahSD6dcrrvClR0sza20hQAOw=="]
	}

	125 {
	    set rbIndArr(default) [image create photo -data "
R0lGODlhEgASAKECAJ6ake7r5////////yH5BAEKAAMALAAAAAASABIAAAJAnA+pxwgBY2rmBYEz
BO3lr3HVBZaB6JXgOaTqmpDvd7ozVsu3kO+hfWMBVayW7lU0BkUIiCnJiEU2TEpLMWkUAAA7"]
	    set rbIndArr(disabled) [image create photo -data "
R0lGODlhEgASAKEDAJ6ake7r59za1f///yH5BAEKAAMALAAAAAASABIAAAJAnA+pxwgBY2rmBYEz
BO3lr3HVBZaB6JXgOaTqmpDvd7ozVsu3kO+hfWMBVayW7lU0BkUIiCnJiEU2TEpLMWkUAAA7"]
	    set rbIndArr(pressed) [image create photo -data "
R0lGODlhEgASAKEDAJ6ake7r57q1q////yH5BAEKAAMALAAAAAASABIAAAJAnA+pxwgBY2rmBYEz
BO3lr3HVBZaB6JXgOaTqmpDvd7ozVsu3kO+hfWMBVayW7lU0BkUIiCnJiEU2TEpLMWkUAAA7"]
	    set rbIndArr(alternate) [image create photo -data "
R0lGODlhEgASAKEDAJ6ake7r51iVvP///yH5BAEKAAMALAAAAAASABIAAAJAnA+pxwgBY2rmBYEz
BO3lr3HVBZaB6JXgOaTqmpDvd7ozVsu3kO+hfWMBVayW7lU0BkUIiCnJiEU2TEpLMWkUAAA7"]
	    set rbIndArr(alternate_disabled) [image create photo -data "
R0lGODlhEgASAKEDAJ6ake7r56CgoP///yH5BAEKAAMALAAAAAASABIAAAJAnA+pxwgBY2rmBYEz
BO3lr3HVBZaB6JXgOaTqmpDvd7ozVsu3kO+hfWMBVayW7lU0BkUIiCnJiEU2TEpLMWkUAAA7"]
	    set rbIndArr(alternate_pressed) [image create photo -data "
R0lGODlhEgASAKEDAJ6ake7r53+22P///yH5BAEKAAMALAAAAAASABIAAAJAnA+pxwgBY2rmBYEz
BO3lr3HVBZaB6JXgOaTqmpDvd7ozVsu3kO+hfWMBVayW7lU0BkUIiCnJiEU2TEpLMWkUAAA7"]
	    set rbIndArr(selected) [image create photo -data "
R0lGODlhEgASAKEBAFiVvP///////////yH5BAEKAAIALAAAAAASABIAAAItlA+px6ifmoEUtFod
phOGH3AUCG4JSZpoua2f6prAKnrs08lLLl+9ZJIwOI0CADs="]
	    set rbIndArr(selected_disabled) [image create photo -data "
R0lGODlhEgASAKEBAKCgoP///////////yH5BAEKAAIALAAAAAASABIAAAItlA+px6ifmoEUtFod
phOGH3AUCG4JSZpoua2f6prAKnrs08lLLl+9ZJIwOI0CADs="]
	    set rbIndArr(selected_pressed) [image create photo -data "
R0lGODlhEgASAKEBAH+22P///////////yH5BAEKAAIALAAAAAASABIAAAItlA+px6ifmoEUtFod
phOGH3AUCG4JSZpoua2f6prAKnrs08lLLl+9ZJIwOI0CADs="]
	}

	150 {
	    set rbIndArr(default) [image create photo -data "
R0lGODlhFgAWAKECAJ6ake7r5////////yH5BAEKAAMALAAAAAAWABYAAAJQnG+gi90aolQOwSCy
jtSBqIVbADyYiGakdabimrTuWw7fnK43nkN8v/uFSEGhymfcIJMCnewHK0JrtucMFjNiY9bh9nBB
caiVi4RYKS86jgIAOw=="]
	    set rbIndArr(disabled) [image create photo -data "
R0lGODlhFgAWAKEDAJ6ake7r59za1f///yH5BAEKAAMALAAAAAAWABYAAAJQnG+gi90aolQOwSCy
jtSBqIVbADyYiGakdabimrTuWw7fnK43nkN8v/uFSEGhymfcIJMCnewHK0JrtucMFjNiY9bh9nBB
caiVi4RYKS86jgIAOw=="]
	    set rbIndArr(pressed) [image create photo -data "
R0lGODlhFgAWAKEDAJ6ake7r57q1q////yH5BAEKAAMALAAAAAAWABYAAAJQnG+gi90aolQOwSCy
jtSBqIVbADyYiGakdabimrTuWw7fnK43nkN8v/uFSEGhymfcIJMCnewHK0JrtucMFjNiY9bh9nBB
caiVi4RYKS86jgIAOw=="]
	    set rbIndArr(alternate) [image create photo -data "
R0lGODlhFgAWAKEDAJ6ake7r51iVvP///yH5BAEKAAMALAAAAAAWABYAAAJQnG+gi90aolQOwSCy
jtSBqIVbADyYiGakdabimrTuWw7fnK43nkN8v/uFSEGhymfcIJMCnewHK0JrtucMFjNiY9bh9nBB
caiVi4RYKS86jgIAOw=="]
	    set rbIndArr(alternate_disabled) [image create photo -data "
R0lGODlhFgAWAKEDAJ6ake7r56CgoP///yH5BAEKAAMALAAAAAAWABYAAAJQnG+gi90aolQOwSCy
jtSBqIVbADyYiGakdabimrTuWw7fnK43nkN8v/uFSEGhymfcIJMCnewHK0JrtucMFjNiY9bh9nBB
caiVi4RYKS86jgIAOw=="]
	    set rbIndArr(alternate_pressed) [image create photo -data "
R0lGODlhFgAWAKEDAJ6ake7r53+22P///yH5BAEKAAMALAAAAAAWABYAAAJQnG+gi90aolQOwSCy
jtSBqIVbADyYiGakdabimrTuWw7fnK43nkN8v/uFSEGhymfcIJMCnewHK0JrtucMFjNiY9bh9nBB
caiVi4RYKS86jgIAOw=="]
	    set rbIndArr(selected) [image create photo -data "
R0lGODlhFgAWAKEBAFiVvP///////////yH5BAEKAAIALAAAAAAWABYAAAI8lG+gi90LmTuxymcz
zpryLmTBGHQWSVphhaLf0rYvELtvnd54OePqKaskgCPQTOg5XobKSXPCVEE3S0QBADs="]
	    set rbIndArr(selected_disabled) [image create photo -data "
R0lGODlhFgAWAKEBAKCgoP///////////yH5BAEKAAIALAAAAAAWABYAAAI8lG+gi90LmTuxymcz
zpryLmTBGHQWSVphhaLf0rYvELtvnd54OePqKaskgCPQTOg5XobKSXPCVEE3S0QBADs="]
	    set rbIndArr(selected_pressed) [image create photo -data "
R0lGODlhFgAWAKEBAH+22P///////////yH5BAEKAAIALAAAAAAWABYAAAI8lG+gi90LmTuxymcz
zpryLmTBGHQWSVphhaLf0rYvELtvnd54OePqKaskgCPQTOg5XobKSXPCVEE3S0QBADs="]
	}

	175 {
	    set rbIndArr(default) [image create photo -data "
R0lGODlhGQAZAKECAJ6ake7r5////////yH5BAEKAAMALAAAAAAZABkAAAJcnH+gC+g/VJg0KOhk
ELyLeWHA5JUcCI3mejaIyrLWu8XrbMD27ep7OfP9gJKhrGg0WYTJD7LZWdagLWYyOG3irD9cJDv0
fqHisbGcI9lQohH4tMS83JW4/MFYyAsAOw=="]
	    set rbIndArr(disabled) [image create photo -data "
R0lGODlhGQAZAKEDAJ6ake7r59za1f///yH5BAEKAAMALAAAAAAZABkAAAJcnH+gC+g/VJg0KOhk
ELyLeWHA5JUcCI3mejaIyrLWu8XrbMD27ep7OfP9gJKhrGg0WYTJD7LZWdagLWYyOG3irD9cJDv0
fqHisbGcI9lQohH4tMS83JW4/MFYyAsAOw=="]
	    set rbIndArr(pressed) [image create photo -data "
R0lGODlhGQAZAKEDAJ6ake7r57q1q////yH5BAEKAAMALAAAAAAZABkAAAJcnH+gC+g/VJg0KOhk
ELyLeWHA5JUcCI3mejaIyrLWu8XrbMD27ep7OfP9gJKhrGg0WYTJD7LZWdagLWYyOG3irD9cJDv0
fqHisbGcI9lQohH4tMS83JW4/MFYyAsAOw=="]
	    set rbIndArr(alternate) [image create photo -data "
R0lGODlhGQAZAKEDAJ6ake7r51iVvP///yH5BAEKAAMALAAAAAAZABkAAAJcnH+gC+g/VJg0KOhk
ELyLeWHA5JUcCI3mejaIyrLWu8XrbMD27ep7OfP9gJKhrGg0WYTJD7LZWdagLWYyOG3irD9cJDv0
fqHisbGcI9lQohH4tMS83JW4/MFYyAsAOw=="]
	    set rbIndArr(alternate_disabled) [image create photo -data "
R0lGODlhGQAZAKEDAJ6ake7r56CgoP///yH5BAEKAAMALAAAAAAZABkAAAJcnH+gC+g/VJg0KOhk
ELyLeWHA5JUcCI3mejaIyrLWu8XrbMD27ep7OfP9gJKhrGg0WYTJD7LZWdagLWYyOG3irD9cJDv0
fqHisbGcI9lQohH4tMS83JW4/MFYyAsAOw=="]
	    set rbIndArr(alternate_pressed) [image create photo -data "
R0lGODlhGQAZAKEDAJ6ake7r53+22P///yH5BAEKAAMALAAAAAAZABkAAAJcnH+gC+g/VJg0KOhk
ELyLeWHA5JUcCI3mejaIyrLWu8XrbMD27ep7OfP9gJKhrGg0WYTJD7LZWdagLWYyOG3irD9cJDv0
fqHisbGcI9lQohH4tMS83JW4/MFYyAsAOw=="]
	    set rbIndArr(selected) [image create photo -data "
R0lGODlhGQAZAKEBAFiVvP///////////yH5BAEKAAIALAAAAAAZABkAAAJHlH+gC+gvmFTQzUsr
3nB7631JyBlbgKIllrZYdLUyucg2Ddgzrbt8r/oBcbnei3W7mJCpEozIQEAloGkHWnmSsiMntxut
FAAAOw=="]
	    set rbIndArr(selected_disabled) [image create photo -data "
R0lGODlhGQAZAKEBAKCgoP///////////yH5BAEKAAIALAAAAAAZABkAAAJHlH+gC+gvmFTQzUsr
3nB7631JyBlbgKIllrZYdLUyucg2Ddgzrbt8r/oBcbnei3W7mJCpEozIQEAloGkHWnmSsiMntxut
FAAAOw=="]
	    set rbIndArr(selected_pressed) [image create photo -data "
R0lGODlhGQAZAKEBAH+22P///////////yH5BAEKAAIALAAAAAAZABkAAAJHlH+gC+gvmFTQzUsr
3nB7631JyBlbgKIllrZYdLUyucg2Ddgzrbt8r/oBcbnei3W7mJCpEozIQEAloGkHWnmSsiMntxut
FAAAOw=="]
	}

	200 {
	    set rbIndArr(default) [image create photo -data "
R0lGODlhHAAcAKECAJ6ake7r5////////yH5BAEKAAMALAAAAAAcABwAAAJqnI+gq+h/VJh0Nvhk
ELxzC2DR5JWdJQKbyX5htrZt8I7yLdBJjJu6oerdfkHhLFQ0HpNKn6S55EFPz2mJxrTmqlpX1qr7
NolS6G8gFp7RZeOaPX0D2zL5iO5BidAqOmif0FfxB5jBsLBXAAA7"]
	    set rbIndArr(disabled) [image create photo -data "
R0lGODlhHAAcAKEDAJ6ake7r59za1f///yH5BAEKAAMALAAAAAAcABwAAAJqnI+gq+h/VJh0Nvhk
ELxzC2DR5JWdJQKbyX5htrZt8I7yLdBJjJu6oerdfkHhLFQ0HpNKn6S55EFPz2mJxrTmqlpX1qr7
NolS6G8gFp7RZeOaPX0D2zL5iO5BidAqOmif0FfxB5jBsLBXAAA7"]
	    set rbIndArr(pressed) [image create photo -data "
R0lGODlhHAAcAKEDAJ6ake7r57q1q////yH5BAEKAAMALAAAAAAcABwAAAJqnI+gq+h/VJh0Nvhk
ELxzC2DR5JWdJQKbyX5htrZt8I7yLdBJjJu6oerdfkHhLFQ0HpNKn6S55EFPz2mJxrTmqlpX1qr7
NolS6G8gFp7RZeOaPX0D2zL5iO5BidAqOmif0FfxB5jBsLBXAAA7"]
	    set rbIndArr(alternate) [image create photo -data "
R0lGODlhHAAcAKEDAJ6ake7r51iVvP///yH5BAEKAAMALAAAAAAcABwAAAJqnI+gq+h/VJh0Nvhk
ELxzC2DR5JWdJQKbyX5htrZt8I7yLdBJjJu6oerdfkHhLFQ0HpNKn6S55EFPz2mJxrTmqlpX1qr7
NolS6G8gFp7RZeOaPX0D2zL5iO5BidAqOmif0FfxB5jBsLBXAAA7"]
	    set rbIndArr(alternate_disabled) [image create photo -data "
R0lGODlhHAAcAKEDAJ6ake7r56CgoP///yH5BAEKAAMALAAAAAAcABwAAAJqnI+gq+h/VJh0Nvhk
ELxzC2DR5JWdJQKbyX5htrZt8I7yLdBJjJu6oerdfkHhLFQ0HpNKn6S55EFPz2mJxrTmqlpX1qr7
NolS6G8gFp7RZeOaPX0D2zL5iO5BidAqOmif0FfxB5jBsLBXAAA7"]
	    set rbIndArr(alternate_pressed) [image create photo -data "
R0lGODlhHAAcAKEDAJ6ake7r53+22P///yH5BAEKAAMALAAAAAAcABwAAAJqnI+gq+h/VJh0Nvhk
ELxzC2DR5JWdJQKbyX5htrZt8I7yLdBJjJu6oerdfkHhLFQ0HpNKn6S55EFPz2mJxrTmqlpX1qr7
NolS6G8gFp7RZeOaPX0D2zL5iO5BidAqOmif0FfxB5jBsLBXAAA7"]
	    set rbIndArr(selected) [image create photo -data "
R0lGODlhHAAcAKEBAFiVvP///////////yH5BAEKAAIALAAAAAAcABwAAAJQlI+gq+h/mFwQzkur
wRzo3llgmIxgaXIRF7QuybqyGstzqth6gAO73fvdUsIXrtgKIns+IQ3zUwk6OtKUOUFhM6ut5+H9
MDUbHFmLOYuymgIAOw=="]
	    set rbIndArr(selected_disabled) [image create photo -data "
R0lGODlhHAAcAKEBAKCgoP///////////yH5BAEKAAIALAAAAAAcABwAAAJQlI+gq+h/mFwQzkur
wRzo3llgmIxgaXIRF7QuybqyGstzqth6gAO73fvdUsIXrtgKIns+IQ3zUwk6OtKUOUFhM6ut5+H9
MDUbHFmLOYuymgIAOw=="]
	    set rbIndArr(selected_pressed) [image create photo -data "
R0lGODlhHAAcAKEBAH+22P///////////yH5BAEKAAIALAAAAAAcABwAAAJQlI+gq+h/mFwQzkur
wRzo3llgmIxgaXIRF7QuybqyGstzqth6gAO73fvdUsIXrtgKIns+IQ3zUwk6OtKUOUFhM6ut5+H9
MDUbHFmLOYuymgIAOw=="]
	}
    }
}

#------------------------------------------------------------------------------
# themepatch::default::createCheckbtnIndImgs
#
# Creates the images used by the style element Checkbutton.image_ind of the
# default theme.
#------------------------------------------------------------------------------
proc themepatch::default::createCheckbtnIndImgs pct {
    variable ckIndArr
    switch $pct {
	100 {
	    set ckIndArr(default) [image create photo -data "
R0lGODlhDwAPAKEBAIKCgv///////////yH5BAEKAAIALAAAAAAPAA8AAAIgFI6JFu3vDpxNUmhv
BPrl/mnhNVLldGJcV60sYCgyXAAAOw=="]
	    set ckIndArr(disabled) [image create photo -data "
R0lGODlhDwAPAKECAIKCgtnZ2f///////yH5BAEKAAIALAAAAAAPAA8AAAIgFI6JFu3vDpxNUmhv
BPrl/mnhNVLldGJcV60sYCgyXAAAOw=="]
	    set ckIndArr(pressed) [image create photo -data "
R0lGODlhDwAPAKECAIKCgsPDw////////yH5BAEKAAIALAAAAAAPAA8AAAIgFI6JFu3vDpxNUmhv
BPrl/mnhNVLldGJcV60sYCgyXAAAOw=="]
	    set ckIndArr(alternate) [image create photo -data "
R0lGODlhDwAPAKECAIKCgliVvP///////yH5BAEKAAIALAAAAAAPAA8AAAIgFI6JFu3vDpxNUmhv
BPrl/mnhNVLldGJcV60sYCgyXAAAOw=="]
	    set ckIndArr(alternate_disabled) [image create photo -data "
R0lGODlhDwAPAKECAIKCgqOjo////////yH5BAEKAAIALAAAAAAPAA8AAAIgFI6JFu3vDpxNUmhv
BPrl/mnhNVLldGJcV60sYCgyXAAAOw=="]
	    set ckIndArr(alternate_pressed) [image create photo -data "
R0lGODlhDwAPAKECAIKCgn+22P///////yH5BAEKAAIALAAAAAAPAA8AAAIgFI6JFu3vDpxNUmhv
BPrl/mnhNVLldGJcV60sYCgyXAAAOw=="]
	    set ckIndArr(selected) [image create photo -data "
R0lGODlhDwAPAKEBAFiVvP///////////yH5BAEKAAIALAAAAAAPAA8AAAIaFI6Jpu0Po5wg0GBd
rrthLmEdNFLm2TCSUAAAOw=="]
	    set ckIndArr(selected_disabled) [image create photo -data "
R0lGODlhDwAPAKEBAKOjo////////////yH5BAEKAAIALAAAAAAPAA8AAAIaFI6Jpu0Po5wg0GBd
rrthLmEdNFLm2TCSUAAAOw=="]
	    set ckIndArr(selected_pressed) [image create photo -data "
R0lGODlhDwAPAKEBAH+22P///////////yH5BAEKAAIALAAAAAAPAA8AAAIaFI6Jpu0Po5wg0GBd
rrthLmEdNFLm2TCSUAAAOw=="]
	}

	125 {
	    set ckIndArr(default) [image create photo -data "
R0lGODlhEgASAKEBAIKCgv///////////yH5BAEKAAIALAAAAAASABIAAAImFI6pYOEPYziyPmor
znHzC3xdKIKleU7k6Ynt93JxNlu1Ziz6IRQAOw=="]
	    set ckIndArr(disabled) [image create photo -data "
R0lGODlhEgASAKECAIKCgtnZ2f///////yH5BAEKAAIALAAAAAASABIAAAImFI6pYOEPYziyPmor
znHzC3xdKIKleU7k6Ynt93JxNlu1Ziz6IRQAOw=="]
	    set ckIndArr(pressed) [image create photo -data "
R0lGODlhEgASAKECAIKCgsPDw////////yH5BAEKAAIALAAAAAASABIAAAImFI6pYOEPYziyPmor
znHzC3xdKIKleU7k6Ynt93JxNlu1Ziz6IRQAOw=="]
	    set ckIndArr(alternate) [image create photo -data "
R0lGODlhEgASAKECAIKCgliVvP///////yH5BAEKAAIALAAAAAASABIAAAImFI6pYOEPYziyPmor
znHzC3xdKIKleU7k6Ynt93JxNlu1Ziz6IRQAOw=="]
	    set ckIndArr(alternate_disabled) [image create photo -data "
R0lGODlhEgASAKECAIKCgqOjo////////yH5BAEKAAIALAAAAAASABIAAAImFI6pYOEPYziyPmor
znHzC3xdKIKleU7k6Ynt93JxNlu1Ziz6IRQAOw=="]
	    set ckIndArr(alternate_pressed) [image create photo -data "
R0lGODlhEgASAKECAIKCgn+22P///////yH5BAEKAAIALAAAAAASABIAAAImFI6pYOEPYziyPmor
znHzC3xdKIKleU7k6Ynt93JxNlu1Ziz6IRQAOw=="]
	    set ckIndArr(selected) [image create photo -data "
R0lGODlhEgASAKEBAFiVvP///////////yH5BAEKAAIALAAAAAASABIAAAIdFI6pYOsPo5y0ymBB
wHVf5F1YOG1cl6XqOjWVUAAAOw=="]
	    set ckIndArr(selected_disabled) [image create photo -data "
R0lGODlhEgASAKEBAKOjo////////////yH5BAEKAAIALAAAAAASABIAAAIdFI6pYOsPo5y0ymBB
wHVf5F1YOG1cl6XqOjWVUAAAOw=="]
	    set ckIndArr(selected_pressed) [image create photo -data "
R0lGODlhEgASAKEBAH+22P///////////yH5BAEKAAIALAAAAAASABIAAAIdFI6pYOsPo5y0ymBB
wHVf5F1YOG1cl6XqOjWVUAAAOw=="]
	}

	150 {
	    set ckIndArr(default) [image create photo -data "
R0lGODlhFgAWAKEBAIKCgv///////////yH5BAEKAAIALAAAAAAWABYAAAIxFI6pauEPYzyyVmqz
w9ryLn0gJI4bYIZoSq7s+T6lOY81eHe5tme953r9LoaFcSEoAAA7"]
	    set ckIndArr(disabled) [image create photo -data "
R0lGODlhFgAWAKECAIKCgtnZ2f///////yH5BAEKAAIALAAAAAAWABYAAAIxFI6pauEPYzyyVmqz
w9ryLn0gJI4bYIZoSq7s+T6lOY81eHe5tme953r9LoaFcSEoAAA7"]
	    set ckIndArr(pressed) [image create photo -data "
R0lGODlhFgAWAKECAIKCgsPDw////////yH5BAEKAAIALAAAAAAWABYAAAIxFI6pauEPYzyyVmqz
w9ryLn0gJI4bYIZoSq7s+T6lOY81eHe5tme953r9LoaFcSEoAAA7"]
	    set ckIndArr(alternate) [image create photo -data "
R0lGODlhFgAWAKECAIKCgliVvP///////yH5BAEKAAIALAAAAAAWABYAAAIxFI6pauEPYzyyVmqz
w9ryLn0gJI4bYIZoSq7s+T6lOY81eHe5tme953r9LoaFcSEoAAA7"]
	    set ckIndArr(alternate_disabled) [image create photo -data "
R0lGODlhFgAWAKECAIKCgqOjo////////yH5BAEKAAIALAAAAAAWABYAAAIxFI6pauEPYzyyVmqz
w9ryLn0gJI4bYIZoSq7s+T6lOY81eHe5tme953r9LoaFcSEoAAA7"]
	    set ckIndArr(alternate_pressed) [image create photo -data "
R0lGODlhFgAWAKECAIKCgn+22P///////yH5BAEKAAIALAAAAAAWABYAAAIxFI6pauEPYzyyVmqz
w9ryLn0gJI4bYIZoSq7s+T6lOY81eHe5tme953r9LoaFcSEoAAA7"]
	    set ckIndArr(selected) [image create photo -data "
R0lGODlhFgAWAKEBAFiVvP///////////yH5BAEKAAIALAAAAAAWABYAAAImFI6pausPo5y02otf
CBlsjn2ZKG0JWZqeSn1o5XZsR9f2XTWZUAAAOw=="]
	    set ckIndArr(selected_disabled) [image create photo -data "
R0lGODlhFgAWAKEBAKOjo////////////yH5BAEKAAIALAAAAAAWABYAAAImFI6pausPo5y02otf
CBlsjn2ZKG0JWZqeSn1o5XZsR9f2XTWZUAAAOw=="]
	    set ckIndArr(selected_pressed) [image create photo -data "
R0lGODlhFgAWAKEBAH+22P///////////yH5BAEKAAIALAAAAAAWABYAAAImFI6pausPo5y02otf
CBlsjn2ZKG0JWZqeSn1o5XZsR9f2XTWZUAAAOw=="]
	}

	175 {
	    set ckIndArr(default) [image create photo -data "
R0lGODlhGQAZAMIBAIKCgv///6CclKCck6ypof///////////yH5BAEKAAcALAAAAAAZABkAAAM8
eLDc/kuFSau9c+G9Nf+UB37i2AEmiaYn27pXCWfrHNZ2IM873Ls/VjA1NBVHR1BSlQsJmpPBgQCp
Qg4JADs="]
	    set ckIndArr(disabled) [image create photo -data "
R0lGODlhGQAZAMIFAIKCgtnZ2aCclKCck6ypof///////////yH5BAEKAAcALAAAAAAZABkAAAM8
eLDc/kuFSau9c+G9Nf+UB37i2AEmiaYn27pXCWfrHNZ2IM873Ls/VjA1NBVHR1BSlQsJmpPBgQCp
Qg4JADs="]
	    set ckIndArr(pressed) [image create photo -data "
R0lGODlhGQAZAMIFAIKCgsPDw6CclKCck6ypof///////////yH5BAEKAAcALAAAAAAZABkAAAM8
eLDc/kuFSau9c+G9Nf+UB37i2AEmiaYn27pXCWfrHNZ2IM873Ls/VjA1NBVHR1BSlQsJmpPBgQCp
Qg4JADs="]
	    set ckIndArr(alternate) [image create photo -data "
R0lGODlhGQAZAMIFAIKCgliVvKCclKCck6ypof///////////yH5BAEKAAcALAAAAAAZABkAAAM8
eLDc/kuFSau9c+G9Nf+UB37i2AEmiaYn27pXCWfrHNZ2IM873Ls/VjA1NBVHR1BSlQsJmpPBgQCp
Qg4JADs="]
	    set ckIndArr(alternate_disabled) [image create photo -data "
R0lGODlhGQAZAMIFAIKCgqOjo6CclKCck6ypof///////////yH5BAEKAAcALAAAAAAZABkAAAM8
eLDc/kuFSau9c+G9Nf+UB37i2AEmiaYn27pXCWfrHNZ2IM873Ls/VjA1NBVHR1BSlQsJmpPBgQCp
Qg4JADs="]
	    set ckIndArr(alternate_pressed) [image create photo -data "
R0lGODlhGQAZAMIFAIKCgn+22KCclKCck6ypof///////////yH5BAEKAAcALAAAAAAZABkAAAM8
eLDc/kuFSau9c+G9Nf+UB37i2AEmiaYn27pXCWfrHNZ2IM873Ls/VjA1NBVHR1BSlQsJmpPBgQCp
Qg4JADs="]
	    set ckIndArr(selected) [image create photo -data "
R0lGODlhGQAZAKEBAFiVvP///////////yH5BAEKAAIALAAAAAAZABkAAAIuFI6pe8YPo5y02osz
DkEj3nlgmI0iOHGLmaofSrFsNc5WTW7w6fX+DwwmHD1BAQA7"]
	    set ckIndArr(selected_disabled) [image create photo -data "
R0lGODlhGQAZAKEBAKOjo////////////yH5BAEKAAIALAAAAAAZABkAAAIuFI6pe8YPo5y02osz
DkEj3nlgmI0iOHGLmaofSrFsNc5WTW7w6fX+DwwmHD1BAQA7"]
	    set ckIndArr(selected_pressed) [image create photo -data "
R0lGODlhGQAZAKEBAH+22P///////////yH5BAEKAAIALAAAAAAZABkAAAIuFI6pe8YPo5y02osz
DkEj3nlgmI0iOHGLmaofSrFsNc5WTW7w6fX+DwwmHD1BAQA7"]
	}

	200 {
	    set ckIndArr(default) [image create photo -data "
R0lGODlhHAAcAKEBAIKCgv///////////yH5BAEKAAIALAAAAAAcABwAAAJBFI6pqxYPo5zy0Iuf
zTzu3n1gJo5XaU5o6gEstr5B/NKsneKmPvKgH3LJVMJhy1gpImdKJJDzJDWNUZiBgc0CBAUAOw=="]
	    set ckIndArr(disabled) [image create photo -data "
R0lGODlhHAAcAKECAIKCgtnZ2f///////yH5BAEKAAIALAAAAAAcABwAAAJBFI6pqxYPo5zy0Iuf
zTzu3n1gJo5XaU5o6gEstr5B/NKsneKmPvKgH3LJVMJhy1gpImdKJJDzJDWNUZiBgc0CBAUAOw=="]
	    set ckIndArr(pressed) [image create photo -data "
R0lGODlhHAAcAKECAIKCgsPDw////////yH5BAEKAAIALAAAAAAcABwAAAJBFI6pqxYPo5zy0Iuf
zTzu3n1gJo5XaU5o6gEstr5B/NKsneKmPvKgH3LJVMJhy1gpImdKJJDzJDWNUZiBgc0CBAUAOw=="]
	    set ckIndArr(alternate) [image create photo -data "
R0lGODlhHAAcAKECAIKCgliVvP///////yH5BAEKAAIALAAAAAAcABwAAAJBFI6pqxYPo5zy0Iuf
zTzu3n1gJo5XaU5o6gEstr5B/NKsneKmPvKgH3LJVMJhy1gpImdKJJDzJDWNUZiBgc0CBAUAOw=="]
	    set ckIndArr(alternate_disabled) [image create photo -data "
R0lGODlhHAAcAKECAIKCgqOjo////////yH5BAEKAAIALAAAAAAcABwAAAJBFI6pqxYPo5zy0Iuf
zTzu3n1gJo5XaU5o6gEstr5B/NKsneKmPvKgH3LJVMJhy1gpImdKJJDzJDWNUZiBgc0CBAUAOw=="]
	    set ckIndArr(alternate_pressed) [image create photo -data "
R0lGODlhHAAcAKECAIKCgn+22P///////yH5BAEKAAIALAAAAAAcABwAAAJBFI6pqxYPo5zy0Iuf
zTzu3n1gJo5XaU5o6gEstr5B/NKsneKmPvKgH3LJVMJhy1gpImdKJJDzJDWNUZiBgc0CBAUAOw=="]
	    set ckIndArr(selected) [image create photo -data "
R0lGODlhHAAcAKEBAFiVvP///////////yH5BAEKAAIALAAAAAAcABwAAAI5FI6pq8YPo5y02ouz
1iFs1XnfEYpfaXLliE7d07ovuFI1ecshvl9ojPnNVDli6nQcKZfMpjPhWAoKADs="]
	    set ckIndArr(selected_disabled) [image create photo -data "
R0lGODlhHAAcAKEBAKOjo////////////yH5BAEKAAIALAAAAAAcABwAAAI5FI6pq8YPo5y02ouz
1iFs1XnfEYpfaXLliE7d07ovuFI1ecshvl9ojPnNVDli6nQcKZfMpjPhWAoKADs="]
	    set ckIndArr(selected_pressed) [image create photo -data "
R0lGODlhHAAcAKEBAH+22P///////////yH5BAEKAAIALAAAAAAcABwAAAI5FI6pq8YPo5y02ouz
1iFs1XnfEYpfaXLliE7d07ovuFI1ecshvl9ojPnNVDli6nQcKZfMpjPhWAoKADs="]
	}
    }
}

#------------------------------------------------------------------------------
# themepatch::default::createRadiobtnIndImgs
#
# Creates the images used by the style element Radiobutton.image_ind of the
# default theme.
#------------------------------------------------------------------------------
proc themepatch::default::createRadiobtnIndImgs pct {
    variable rbIndArr
    switch $pct {
	100 {
	    set rbIndArr(default) [image create photo -data "
R0lGODlhDwAPAKEBAIKCgv///////////yH5BAEKAAIALAAAAAAPAA8AAAIolA2Zx5IB4WIgWnnq
vQBt7nzbI1pkKWlocKKdKnahm5VyBrN3o0xHAQA7"]
	    set rbIndArr(disabled) [image create photo -data "
R0lGODlhDwAPAKECAIKCgtnZ2f///////yH5BAEKAAIALAAAAAAPAA8AAAIolA2Zx5IB4WIgWnnq
vQBt7nzbI1pkKWlocKKdKnahm5VyBrN3o0xHAQA7"]
	    set rbIndArr(pressed) [image create photo -data "
R0lGODlhDwAPAKECAIKCgsPDw////////yH5BAEKAAIALAAAAAAPAA8AAAIolA2Zx5IB4WIgWnnq
vQBt7nzbI1pkKWlocKKdKnahm5VyBrN3o0xHAQA7"]
	    set rbIndArr(alternate) [image create photo -data "
R0lGODlhDwAPAKECAIKCgliVvP///////yH5BAEKAAIALAAAAAAPAA8AAAIolA2Zx5IB4WIgWnnq
vQBt7nzbI1pkKWlocKKdKnahm5VyBrN3o0xHAQA7"]
	    set rbIndArr(alternate_disabled) [image create photo -data "
R0lGODlhDwAPAKECAIKCgqOjo////////yH5BAEKAAIALAAAAAAPAA8AAAIolA2Zx5IB4WIgWnnq
vQBt7nzbI1pkKWlocKKdKnahm5VyBrN3o0xHAQA7"]
	    set rbIndArr(alternate_pressed) [image create photo -data "
R0lGODlhDwAPAKECAIKCgn+22P///////yH5BAEKAAIALAAAAAAPAA8AAAIolA2Zx5IB4WIgWnnq
vQBt7nzbI1pkKWlocKKdKnahm5VyBrN3o0xHAQA7"]
	    set rbIndArr(selected) [image create photo -data "
R0lGODlhDwAPAKEBAFiVvP///////////yH5BAEKAAIALAAAAAAPAA8AAAImlA2Zx6K/GJxnWvSC
hi7rbQHfGI5faQahSD6dcrrvClR0sza20hQAOw=="]
	    set rbIndArr(selected_disabled) [image create photo -data "
R0lGODlhDwAPAKEBAKOjo////////////yH5BAEKAAIALAAAAAAPAA8AAAImlA2Zx6K/GJxnWvSC
hi7rbQHfGI5faQahSD6dcrrvClR0sza20hQAOw=="]
	    set rbIndArr(selected_pressed) [image create photo -data "
R0lGODlhDwAPAKEBAH+22P///////////yH5BAEKAAIALAAAAAAPAA8AAAImlA2Zx6K/GJxnWvSC
hi7rbQHfGI5faQahSD6dcrrvClR0sza20hQAOw=="]
	}

	125 {
	    set rbIndArr(default) [image create photo -data "
R0lGODlhEgASAKEBAIKCgv///////////yH5BAEKAAIALAAAAAASABIAAAIylA+pxwgBY2rmxQtB
sxjr2oXBx4mSUJpSqo6smrTea8bySXfkPSLy56tRUKzJsKIwMgoAOw=="]
	    set rbIndArr(disabled) [image create photo -data "
R0lGODlhEgASAKECAIKCgtnZ2f///////yH5BAEKAAIALAAAAAASABIAAAIylA+pxwgBY2rmxQtB
sxjr2oXBx4mSUJpSqo6smrTea8bySXfkPSLy56tRUKzJsKIwMgoAOw=="]
	    set rbIndArr(pressed) [image create photo -data "
R0lGODlhEgASAKECAIKCgsPDw////////yH5BAEKAAIALAAAAAASABIAAAIylA+pxwgBY2rmxQtB
sxjr2oXBx4mSUJpSqo6smrTea8bySXfkPSLy56tRUKzJsKIwMgoAOw=="]
	    set rbIndArr(alternate) [image create photo -data "
R0lGODlhEgASAKECAIKCgliVvP///////yH5BAEKAAIALAAAAAASABIAAAIylA+pxwgBY2rmxQtB
sxjr2oXBx4mSUJpSqo6smrTea8bySXfkPSLy56tRUKzJsKIwMgoAOw=="]
	    set rbIndArr(alternate_disabled) [image create photo -data "
R0lGODlhEgASAKECAIKCgqOjo////////yH5BAEKAAIALAAAAAASABIAAAIylA+pxwgBY2rmxQtB
sxjr2oXBx4mSUJpSqo6smrTea8bySXfkPSLy56tRUKzJsKIwMgoAOw=="]
	    set rbIndArr(alternate_pressed) [image create photo -data "
R0lGODlhEgASAKECAIKCgn+22P///////yH5BAEKAAIALAAAAAASABIAAAIylA+pxwgBY2rmxQtB
sxjr2oXBx4mSUJpSqo6smrTea8bySXfkPSLy56tRUKzJsKIwMgoAOw=="]
	    set rbIndArr(selected) [image create photo -data "
R0lGODlhEgASAKEBAFiVvP///////////yH5BAEKAAIALAAAAAASABIAAAItlA+px6ifmoEUtFod
phOGH3AUCG4JSZpoua2f6prAKnrs08lLLl+9ZJIwOI0CADs="]
	    set rbIndArr(selected_disabled) [image create photo -data "
R0lGODlhEgASAKEBAKOjo////////////yH5BAEKAAIALAAAAAASABIAAAItlA+px6ifmoEUtFod
phOGH3AUCG4JSZpoua2f6prAKnrs08lLLl+9ZJIwOI0CADs="]
	    set rbIndArr(selected_pressed) [image create photo -data "
R0lGODlhEgASAKEBAH+22P///////////yH5BAEKAAIALAAAAAASABIAAAItlA+px6ifmoEUtFod
phOGH3AUCG4JSZpoua2f6prAKnrs08lLLl+9ZJIwOI0CADs="]
	}

	150 {
	    set rbIndArr(default) [image create photo -data "
R0lGODlhFgAWAKEBAIKCgv///////////yH5BAEKAAIALAAAAAAWABYAAAJAlG+gi90aolQOQYkj
dSD7+XxiAFjjVyanmHarV7ovLM/YZd91Tu45ziMJfK9WUKj6mZTLYgVIqxygPSlnsXEUAAA7"]
	    set rbIndArr(disabled) [image create photo -data "
R0lGODlhFgAWAKECAIKCgtnZ2f///////yH5BAEKAAIALAAAAAAWABYAAAJAlG+gi90aolQOQYkj
dSD7+XxiAFjjVyanmHarV7ovLM/YZd91Tu45ziMJfK9WUKj6mZTLYgVIqxygPSlnsXEUAAA7"]
	    set rbIndArr(pressed) [image create photo -data "
R0lGODlhFgAWAKECAIKCgsPDw////////yH5BAEKAAIALAAAAAAWABYAAAJAlG+gi90aolQOQYkj
dSD7+XxiAFjjVyanmHarV7ovLM/YZd91Tu45ziMJfK9WUKj6mZTLYgVIqxygPSlnsXEUAAA7"]
	    set rbIndArr(alternate) [image create photo -data "
R0lGODlhFgAWAKECAIKCgliVvP///////yH5BAEKAAIALAAAAAAWABYAAAJAlG+gi90aolQOQYkj
dSD7+XxiAFjjVyanmHarV7ovLM/YZd91Tu45ziMJfK9WUKj6mZTLYgVIqxygPSlnsXEUAAA7"]
	    set rbIndArr(alternate_disabled) [image create photo -data "
R0lGODlhFgAWAKECAIKCgqOjo////////yH5BAEKAAIALAAAAAAWABYAAAJAlG+gi90aolQOQYkj
dSD7+XxiAFjjVyanmHarV7ovLM/YZd91Tu45ziMJfK9WUKj6mZTLYgVIqxygPSlnsXEUAAA7"]
	    set rbIndArr(alternate_pressed) [image create photo -data "
R0lGODlhFgAWAKECAIKCgn+22P///////yH5BAEKAAIALAAAAAAWABYAAAJAlG+gi90aolQOQYkj
dSD7+XxiAFjjVyanmHarV7ovLM/YZd91Tu45ziMJfK9WUKj6mZTLYgVIqxygPSlnsXEUAAA7"]
	    set rbIndArr(selected) [image create photo -data "
R0lGODlhFgAWAKEBAFiVvP///////////yH5BAEKAAIALAAAAAAWABYAAAI8lG+gi90LmTuxymcz
zpryLmTBGHQWSVphhaLf0rYvELtvnd54OePqKaskgCPQTOg5XobKSXPCVEE3S0QBADs="]
	    set rbIndArr(selected_disabled) [image create photo -data "
R0lGODlhFgAWAKEBAKOjo////////////yH5BAEKAAIALAAAAAAWABYAAAI8lG+gi90LmTuxymcz
zpryLmTBGHQWSVphhaLf0rYvELtvnd54OePqKaskgCPQTOg5XobKSXPCVEE3S0QBADs="]
	    set rbIndArr(selected_pressed) [image create photo -data "
R0lGODlhFgAWAKEBAH+22P///////////yH5BAEKAAIALAAAAAAWABYAAAI8lG+gi90LmTuxymcz
zpryLmTBGHQWSVphhaLf0rYvELtvnd54OePqKaskgCPQTOg5XobKSXPCVEE3S0QBADs="]
	}

	175 {
	    set rbIndArr(default) [image create photo -data "
R0lGODlhGQAZAKEBAIKCgv///////////yH5BAEKAAIALAAAAAAZABkAAAJMlH+gC+gvVJg0KOhk
3bZhwIWTl4kmaYDmiahrSLovnM6sbHNaDuM8tftVgsKRT0gsNo45D9MWK1paUlQECXnqMBFth5s4
XsAZxhhSAAA7"]
	    set rbIndArr(disabled) [image create photo -data "
R0lGODlhGQAZAKECAIKCgtnZ2f///////yH5BAEKAAIALAAAAAAZABkAAAJMlH+gC+gvVJg0KOhk
3bZhwIWTl4kmaYDmiahrSLovnM6sbHNaDuM8tftVgsKRT0gsNo45D9MWK1paUlQECXnqMBFth5s4
XsAZxhhSAAA7"]
	    set rbIndArr(pressed) [image create photo -data "
R0lGODlhGQAZAKECAIKCgsPDw////////yH5BAEKAAIALAAAAAAZABkAAAJMlH+gC+gvVJg0KOhk
3bZhwIWTl4kmaYDmiahrSLovnM6sbHNaDuM8tftVgsKRT0gsNo45D9MWK1paUlQECXnqMBFth5s4
XsAZxhhSAAA7"]
	    set rbIndArr(alternate) [image create photo -data "
R0lGODlhGQAZAKECAIKCgliVvP///////yH5BAEKAAIALAAAAAAZABkAAAJMlH+gC+gvVJg0KOhk
3bZhwIWTl4kmaYDmiahrSLovnM6sbHNaDuM8tftVgsKRT0gsNo45D9MWK1paUlQECXnqMBFth5s4
XsAZxhhSAAA7"]
	    set rbIndArr(alternate_disabled) [image create photo -data "
R0lGODlhGQAZAKECAIKCgqOjo////////yH5BAEKAAIALAAAAAAZABkAAAJMlH+gC+gvVJg0KOhk
3bZhwIWTl4kmaYDmiahrSLovnM6sbHNaDuM8tftVgsKRT0gsNo45D9MWK1paUlQECXnqMBFth5s4
XsAZxhhSAAA7"]
	    set rbIndArr(alternate_pressed) [image create photo -data "
R0lGODlhGQAZAKECAIKCgn+22P///////yH5BAEKAAIALAAAAAAZABkAAAJMlH+gC+gvVJg0KOhk
3bZhwIWTl4kmaYDmiahrSLovnM6sbHNaDuM8tftVgsKRT0gsNo45D9MWK1paUlQECXnqMBFth5s4
XsAZxhhSAAA7"]
	    set rbIndArr(selected) [image create photo -data "
R0lGODlhGQAZAKEBAFiVvP///////////yH5BAEKAAIALAAAAAAZABkAAAJHlH+gC+gvmFTQzUsr
3nB7631JyBlbgKIllrZYdLUyucg2Ddgzrbt8r/oBcbnei3W7mJCpEozIQEAloGkHWnmSsiMntxut
FAAAOw=="]
	    set rbIndArr(selected_disabled) [image create photo -data "
R0lGODlhGQAZAKEBAKOjo////////////yH5BAEKAAIALAAAAAAZABkAAAJHlH+gC+gvmFTQzUsr
3nB7631JyBlbgKIllrZYdLUyucg2Ddgzrbt8r/oBcbnei3W7mJCpEozIQEAloGkHWnmSsiMntxut
FAAAOw=="]
	    set rbIndArr(selected_pressed) [image create photo -data "
R0lGODlhGQAZAKEBAH+22P///////////yH5BAEKAAIALAAAAAAZABkAAAJHlH+gC+gvmFTQzUsr
3nB7631JyBlbgKIllrZYdLUyucg2Ddgzrbt8r/oBcbnei3W7mJCpEozIQEAloGkHWnmSsiMntxut
FAAAOw=="]
	}

	200 {
	    set rbIndArr(default) [image create photo -data "
R0lGODlhHAAcAKEBAIKCgv///////////yH5BAEKAAIALAAAAAAcABwAAAJZlI+gq+h/VJh0Nvhk
3RbgyIWUhwHiGZCOiZ6qwbZuIqNqXIsknnMe3/MBgxUNMWQ8bpLK0VDJbKaex590BLtaQNIXtfYS
fG2QMfJjLn5g5suarQu/2Qw3pAAAOw=="]
	    set rbIndArr(disabled) [image create photo -data "
R0lGODlhHAAcAKECAIKCgtnZ2f///////yH5BAEKAAIALAAAAAAcABwAAAJZlI+gq+h/VJh0Nvhk
3RbgyIWUhwHiGZCOiZ6qwbZuIqNqXIsknnMe3/MBgxUNMWQ8bpLK0VDJbKaex590BLtaQNIXtfYS
fG2QMfJjLn5g5suarQu/2Qw3pAAAOw=="]
	    set rbIndArr(pressed) [image create photo -data "
R0lGODlhHAAcAKECAIKCgsPDw////////yH5BAEKAAIALAAAAAAcABwAAAJZlI+gq+h/VJh0Nvhk
3RbgyIWUhwHiGZCOiZ6qwbZuIqNqXIsknnMe3/MBgxUNMWQ8bpLK0VDJbKaex590BLtaQNIXtfYS
fG2QMfJjLn5g5suarQu/2Qw3pAAAOw=="]
	    set rbIndArr(alternate) [image create photo -data "
R0lGODlhHAAcAKECAIKCgliVvP///////yH5BAEKAAIALAAAAAAcABwAAAJZlI+gq+h/VJh0Nvhk
3RbgyIWUhwHiGZCOiZ6qwbZuIqNqXIsknnMe3/MBgxUNMWQ8bpLK0VDJbKaex590BLtaQNIXtfYS
fG2QMfJjLn5g5suarQu/2Qw3pAAAOw=="]
	    set rbIndArr(alternate_disabled) [image create photo -data "
R0lGODlhHAAcAKECAIKCgqOjo////////yH5BAEKAAIALAAAAAAcABwAAAJZlI+gq+h/VJh0Nvhk
3RbgyIWUhwHiGZCOiZ6qwbZuIqNqXIsknnMe3/MBgxUNMWQ8bpLK0VDJbKaex590BLtaQNIXtfYS
fG2QMfJjLn5g5suarQu/2Qw3pAAAOw=="]
	    set rbIndArr(alternate_pressed) [image create photo -data "
R0lGODlhHAAcAKECAIKCgn+22P///////yH5BAEKAAIALAAAAAAcABwAAAJZlI+gq+h/VJh0Nvhk
3RbgyIWUhwHiGZCOiZ6qwbZuIqNqXIsknnMe3/MBgxUNMWQ8bpLK0VDJbKaex590BLtaQNIXtfYS
fG2QMfJjLn5g5suarQu/2Qw3pAAAOw=="]
	    set rbIndArr(selected) [image create photo -data "
R0lGODlhHAAcAKEBAFiVvP///////////yH5BAEKAAIALAAAAAAcABwAAAJQlI+gq+h/mFwQzkur
wRzo3llgmIxgaXIRF7QuybqyGstzqth6gAO73fvdUsIXrtgKIns+IQ3zUwk6OtKUOUFhM6ut5+H9
MDUbHFmLOYuymgIAOw=="]
	    set rbIndArr(selected_disabled) [image create photo -data "
R0lGODlhHAAcAKEBAKOjo////////////yH5BAEKAAIALAAAAAAcABwAAAJQlI+gq+h/mFwQzkur
wRzo3llgmIxgaXIRF7QuybqyGstzqth6gAO73fvdUsIXrtgKIns+IQ3zUwk6OtKUOUFhM6ut5+H9
MDUbHFmLOYuymgIAOw=="]
	    set rbIndArr(selected_pressed) [image create photo -data "
R0lGODlhHAAcAKEBAH+22P///////////yH5BAEKAAIALAAAAAAcABwAAAJQlI+gq+h/mFwQzkur
wRzo3llgmIxgaXIRF7QuybqyGstzqth6gAO73fvdUsIXrtgKIns+IQ3zUwk6OtKUOUFhM6ut5+H9
MDUbHFmLOYuymgIAOw=="]
	}
    }
}
