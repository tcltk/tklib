#==============================================================================
# Contains a procedure designed for patching the clam theme.
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

namespace eval clampatch {
    #
    # Public variables:
    #
    variable version	1.1
    variable library	[file dirname [file normalize [info script]]]

    #
    # Public procedures:
    #
    namespace export	patchClamTheme unpatchClamTheme
}

package provide clampatch $clampatch::version

#
# Public utility procedures
# =========================
#

#------------------------------------------------------------------------------
# clampatch::patchClamTheme
#
# Patches the clam theme styles TButton, Heading, TCheckbutton, and
# TRadiobutton.
#------------------------------------------------------------------------------
proc clampatch::patchClamTheme {} {
    set pct [::scaleutil::scalingPercentage [tk windowingsystem]]

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
	    createCheckbtnIndImgs $pct
	    variable ckIndArr
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
	    createRadiobtnIndImgs $pct
	    variable rbIndArr
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

	#
	# Send a <<ThemeChanged>> virtual event to all widgets
	#
	::ttk::ThemeChanged
    }
}

#------------------------------------------------------------------------------
# clampatch::unpatchClamTheme
#
# Unpatches the clam theme styles TButton, Heading, TCheckbutton, and
# TRadiobutton.
#------------------------------------------------------------------------------
proc clampatch::unpatchClamTheme {} {
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

	#
	# Send a <<ThemeChanged>> virtual event to all widgets
	#
	::ttk::ThemeChanged
    }
}

# Private helper procedures
# =========================
#

#------------------------------------------------------------------------------
# clampatch::createCheckbtnIndImgs
#
# Creates the images used by the clam style element Checkbutton.image_ind.
#------------------------------------------------------------------------------
proc clampatch::createCheckbtnIndImgs pct {
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
	    set ckIndArr(selected) [image create photo -data "
R0lGODlhDwAPAMICAJ6ake7r5////0pphP///////////////yH5BAEKAAQALAAAAAAPAA8AAAM3
SLDcrCHKKVcQOGsR7P4dcH3CgIXjNpicV2Yri2JrWZ9ufOMivPOp12ZGyhCLLRFl2VE4ngBCAgA7"]
	    set ckIndArr(selected_disabled) [image create photo -data "
R0lGODlhDwAPAMIEAJ6ake7r59za1ZmZmf///////////////yH5BAEKAAQALAAAAAAPAA8AAAM3
SLDcrCHKKVcQOGsR7P4dcH3CgIXjNpicV2Yri2JrWZ9ufOMivPOp12ZGyhCLLRFl2VE4ngBCAgA7"]
	    set ckIndArr(selected_pressed) [image create photo -data "
R0lGODlhDwAPAHAAACH5BAEAAAQALAAAAAAPAA8Agp6ake7r57q1q0pphAAAAAAAAAAAAAAAAAM3
SLDcrCHKKVcQOGsR7P4dcH3CgIXjNpicV2Yri2JrWZ9ufOMivPOp12ZGyhCLLRFl2VE4ngBCAgA7"]
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
	    set ckIndArr(selected) [image create photo -data "
R0lGODlhEgASAMICAJ6ake7r5////0pphP///////////////yH5BAEKAAQALAAAAAASABIAAANC
SLDcDirISWtYQejN+QVZJ2pfOHblqQ1beg4sib1wO68bHMtgzuqom0BXC/Z8O48QN3KpbMcnzyQt
Wa4SyGPLICQAADs="]
	    set ckIndArr(selected_disabled) [image create photo -data "
R0lGODlhEgASAMIEAJ6ake7r59za1ZmZmf///////////////yH5BAEKAAQALAAAAAASABIAAANC
SLDcDirISWtYQejN+QVZJ2pfOHblqQ1beg4sib1wO68bHMtgzuqom0BXC/Z8O48QN3KpbMcnzyQt
Wa4SyGPLICQAADs="]
	    set ckIndArr(selected_pressed) [image create photo -data "
R0lGODlhEgASAMIEAJ6ake7r57q1q0pphP///////////////yH5BAEKAAQALAAAAAASABIAAANC
SLDcDirISWtYQejN+QVZJ2pfOHblqQ1beg4sib1wO68bHMtgzuqom0BXC/Z8O48QN3KpbMcnzyQt
Wa4SyGPLICQAADs="]
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
	    set ckIndArr(selected) [image create photo -data "
R0lGODlhFgAWAMICAJ6ake7r5////0pphP///////////////yH5BAEKAAQALAAAAAAWABYAAANT
SLDc7irISWtdQejN+w6YJ3YgkI1oeaKiym7D8IVvLGsua99CPu4cX4wDDNIENk3RaILtkh4f8jmS
TofVo5NlfeG03m8zzFyRexiL2gJQPN4PQgIAOw=="]
	    set ckIndArr(selected_disabled) [image create photo -data "
R0lGODlhFgAWAMIEAJ6ake7r59za1ZmZmf///////////////yH5BAEKAAQALAAAAAAWABYAAANT
SLDc7irISWtdQejN+w6YJ3YgkI1oeaKiym7D8IVvLGsua99CPu4cX4wDDNIENk3RaILtkh4f8jmS
TofVo5NlfeG03m8zzFyRexiL2gJQPN4PQgIAOw=="]
	    set ckIndArr(selected_pressed) [image create photo -data "
R0lGODlhFgAWAMIEAJ6ake7r59za1UpphP///////////////yH5BAEKAAQALAAAAAAWABYAAANT
SLDc7irISWtdQejN+w6YJ3YgkI1oeaKiym7D8IVvLGsua99CPu4cX4wDDNIENk3RaILtkh4f8jmS
TofVo5NlfeG03m8zzFyRexiL2gJQPN4PQgIAOw=="]
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
	    set ckIndArr(selected) [image create photo -data "
R0lGODlhGQAZAMICAJ6ake7r5////0pphKCclKCck6ypof///yH5BAEKAAcALAAAAAAZABkAAANj
eLDc/kuFSau9cwXBu/9goIFkKQJbqXZnuqrt+w0DO8ocXXMxru+C3usHFKqIHiENhEzeBDpP04nq
/HLX0JM4/Ri5S9MTmxVXZ9GV0QqEjXFUFzw+157rNgJmvy8cDBCBEAcJADs="]
	    set ckIndArr(selected_disabled) [image create photo -data "
R0lGODlhGQAZAMIHAJ6ake7r59za1ZmZmaCclKCck6ypof///yH5BAEKAAcALAAAAAAZABkAAANj
eLDc/kuFSau9cwXBu/9goIFkKQJbqXZnuqrt+w0DO8ocXXMxru+C3usHFKqIHiENhEzeBDpP04nq
/HLX0JM4/Ri5S9MTmxVXZ9GV0QqEjXFUFzw+157rNgJmvy8cDBCBEAcJADs="]
	    set ckIndArr(selected_pressed) [image create photo -data "
R0lGODlhGQAZAMIHAJ6ake7r57q1q0pphKCclKCck6ypof///yH5BAEKAAcALAAAAAAZABkAAANj
eLDc/kuFSau9cwXBu/9goIFkKQJbqXZnuqrt+w0DO8ocXXMxru+C3usHFKqIHiENhEzeBDpP04nq
/HLX0JM4/Ri5S9MTmxVXZ9GV0QqEjXFUFzw+157rNgJmvy8cDBCBEAcJADs="]
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
	    set ckIndArr(selected) [image create photo -data "
R0lGODlhHAAcAMICAJ6ake7r5////0pphP///////////////yH5BAEKAAQALAAAAAAcABwAAANw
SLDc/k6FSau9dgXBu/9gF2hhaY7AZq4eqrKsC4fDIJKzV9ucnHM7nsCXCwqJMOMRlzS2mLWS8kPc
gaZUqLWDzaa4QaAzVFWOyUyBeVtCqs2xtDgc/17ZKzc4p//d7H4gfYGDfi4YiIkjChCNjgAECQA7"]
	    set ckIndArr(selected_disabled) [image create photo -data "
R0lGODlhHAAcAMIEAJ6ake7r59za1ZmZmf///////////////yH5BAEKAAQALAAAAAAcABwAAANw
SLDc/k6FSau9dgXBu/9gF2hhaY7AZq4eqrKsC4fDIJKzV9ucnHM7nsCXCwqJMOMRlzS2mLWS8kPc
gaZUqLWDzaa4QaAzVFWOyUyBeVtCqs2xtDgc/17ZKzc4p//d7H4gfYGDfi4YiIkjChCNjgAECQA7"]
	    set ckIndArr(selected_pressed) [image create photo -data "
R0lGODlhHAAcAMIEAJ6ake7r57q1q0pphP///////////////yH5BAEKAAQALAAAAAAcABwAAANw
SLDc/k6FSau9dgXBu/9gF2hhaY7AZq4eqrKsC4fDIJKzV9ucnHM7nsCXCwqJMOMRlzS2mLWS8kPc
gaZUqLWDzaa4QaAzVFWOyUyBeVtCqs2xtDgc/17ZKzc4p//d7H4gfYGDfi4YiIkjChCNjgAECQA7"]
	}
    }

    set ckIndArr(alternate_pressed) $ckIndArr(pressed)
}

#------------------------------------------------------------------------------
# clampatch::createRadiobtnIndImgs
#
# Creates the images used by the clam style element Radiobutton.image_ind.
#------------------------------------------------------------------------------
proc clampatch::createRadiobtnIndImgs pct {
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
	    set rbIndArr(selected) [image create photo -data "
R0lGODlhDwAPAMICAJ6ake7r5////0pphP///////////////yH5BAEKAAQALAAAAAAPAA8AAAM+
SKrQvZC0QOmDgIq97cpc2AFMwA0oF5Dghr7q5L6wsLZ0fZtCntqyWQ0o4fV+xKIotPpomE1MpnKL
fBwkSAIAOw=="]
	    set rbIndArr(selected_disabled) [image create photo -data "
R0lGODlhDwAPAMIEAJ6ake7r59za1ZmZmf///////////////yH5BAEKAAQALAAAAAAPAA8AAAM+
SKrQvZC0QOmDgIq97cpc2AFMwA0oF5Dghr7q5L6wsLZ0fZtCntqyWQ0o4fV+xKIotPpomE1MpnKL
fBwkSAIAOw=="]
	    set rbIndArr(selected_pressed) [image create photo -data "
R0lGODlhDwAPAMIEAJ6ake7r57q1q0pphP///////////////yH5BAEKAAQALAAAAAAPAA8AAAM+
SKrQvZC0QOmDgIq97cpc2AFMwA0oF5Dghr7q5L6wsLZ0fZtCntqyWQ0o4fV+xKIotPpomE1MpnKL
fBwkSAIAOw=="]
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
	    set rbIndArr(selected) [image create photo -data "
R0lGODlhEgASAMICAJ6ake7r5////0pphP///////////////yH5BAEKAAQALAAAAAASABIAAANL
SLrQvpCBQGuLagbBOwXR1I0emG1kGphiN7zDuBItB8Nygwr3XdY9HGcFDMaGOpfxt+P1crSmr3RK
qUxRKxWiUc0wusoHi6E5LpEEADs="]
	    set rbIndArr(selected_disabled) [image create photo -data "
R0lGODlhEgASAMIEAJ6ake7r59za1ZmZmf///////////////yH5BAEKAAQALAAAAAASABIAAANL
SLrQvpCBQGuLagbBOwXR1I0emG1kGphiN7zDuBItB8Nygwr3XdY9HGcFDMaGOpfxt+P1crSmr3RK
qUxRKxWiUc0wusoHi6E5LpEEADs="]
	    set rbIndArr(selected_pressed) [image create photo -data "
R0lGODlhEgASAMIEAJ6ake7r57q1q0pphP///////////////yH5BAEKAAQALAAAAAASABIAAANL
SLrQvpCBQGuLagbBOwXR1I0emG1kGphiN7zDuBItB8Nygwr3XdY9HGcFDMaGOpfxt+P1crSmr3RK
qUxRKxWiUc0wusoHi6E5LpEEADs="]
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
	    set rbIndArr(selected) [image create photo -data "
R0lGODlhFgAWAMICAJ6ake7r5////0pphP///////////////yH5BAEKAAQALAAAAAAWABYAAANk
SLoK/ixGF6p1ktEguq+YBFRe+QXAxJlsh2pra75N7A34wNKjmeezVK/0+wWHnWKxhEIKlMYPhQjF
Mae3qk7qfEKDhK4SHLYlgeSybJdadNc0Nwke14zMAlA7E75bmnwiDyESCQA7"]
	    set rbIndArr(selected_disabled) [image create photo -data "
R0lGODlhFgAWAMIEAJ6ake7r59za1ZmZmf///////////////yH5BAEKAAQALAAAAAAWABYAAANk
SLoK/ixGF6p1ktEguq+YBFRe+QXAxJlsh2pra75N7A34wNKjmeezVK/0+wWHnWKxhEIKlMYPhQjF
Mae3qk7qfEKDhK4SHLYlgeSybJdadNc0Nwke14zMAlA7E75bmnwiDyESCQA7"]
	    set rbIndArr(selected_pressed) [image create photo -data "
R0lGODlhFgAWAMIEAJ6ake7r57q1q0pphP///////////////yH5BAEKAAQALAAAAAAWABYAAANk
SLoK/ixGF6p1ktEguq+YBFRe+QXAxJlsh2pra75N7A34wNKjmeezVK/0+wWHnWKxhEIKlMYPhQjF
Mae3qk7qfEKDhK4SHLYlgeSybJdadNc0Nwke14zMAlA7E75bmnwiDyESCQA7"]
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
	    set rbIndArr(selected) [image create photo -data "
R0lGODlhGQAZAMICAJ6ake7r5////0pphP///////////////yH5BAEKAAQALAAAAAAZABkAAANz
SLoL/oDJSVy4ODgqbRBgKFwbB1xiCpLUqb5rxLgwrM1f/d4KnQ5A4E7mCwWPqlsRdGwmLb+mU6RZ
Sqehas54Daa00e7gCxWJhdSyufusbLnYLPENR5MbdF0Mp2/z+3sTJ3lfPC2DO1UcM4MZiouCECUU
CQA7"]
	    set rbIndArr(selected_disabled) [image create photo -data "
R0lGODlhGQAZAMIEAJ6ake7r59za1ZmZmf///////////////yH5BAEKAAQALAAAAAAZABkAAANz
SLoL/oDJSVy4ODgqbRBgKFwbB1xiCpLUqb5rxLgwrM1f/d4KnQ5A4E7mCwWPqlsRdGwmLb+mU6RZ
Sqehas54Daa00e7gCxWJhdSyufusbLnYLPENR5MbdF0Mp2/z+3sTJ3lfPC2DO1UcM4MZiouCECUU
CQA7"]
	    set rbIndArr(selected_pressed) [image create photo -data "
R0lGODlhGQAZAMIEAJ6ake7r57q1q0pphP///////////////yH5BAEKAAQALAAAAAAZABkAAANz
SLoL/oDJSVy4ODgqbRBgKFwbB1xiCpLUqb5rxLgwrM1f/d4KnQ5A4E7mCwWPqlsRdGwmLb+mU6RZ
Sqehas54Daa00e7gCxWJhdSyufusbLnYLPENR5MbdF0Mp2/z+3sTJ3lfPC2DO1UcM4MZiouCECUU
CQA7"]
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
	    set rbIndArr(selected) [image create photo -data "
R0lGODlhHAAcAMICAJ6ake7r5////0pphP///////////////yH5BAEKAAQALAAAAAAcABwAAAOH
SLoM/o7JuVy4+EY6bRBgCGoAV11iGmom8KnwWHZvHAfzae8C3tQ8lU/hig2OyNusqEI6BzAfM/V8
Ri3NqjWFm4a0W1EXCAI7hViq+Yj2ltdQbloEj4vndPOV4H5X93xkX2FyOkGARIKHPTmJi3cUfTtD
kSg8LCZ8Loo9XZkNmxkkn5EQD5kJADs="]
	    set rbIndArr(selected_disabled) [image create photo -data "
R0lGODlhHAAcAMIEAJ6ake7r59za1ZmZmf///////////////yH5BAEKAAQALAAAAAAcABwAAAOH
SLoM/o7JuVy4+EY6bRBgCGoAV11iGmom8KnwWHZvHAfzae8C3tQ8lU/hig2OyNusqEI6BzAfM/V8
Ri3NqjWFm4a0W1EXCAI7hViq+Yj2ltdQbloEj4vndPOV4H5X93xkX2FyOkGARIKHPTmJi3cUfTtD
kSg8LCZ8Loo9XZkNmxkkn5EQD5kJADs="]
	    set rbIndArr(selected_pressed) [image create photo -data "
R0lGODlhHAAcAMIEAJ6ake7r57q1q0pphP///////////////yH5BAEKAAQALAAAAAAcABwAAAOH
SLoM/o7JuVy4+EY6bRBgCGoAV11iGmom8KnwWHZvHAfzae8C3tQ8lU/hig2OyNusqEI6BzAfM/V8
Ri3NqjWFm4a0W1EXCAI7hViq+Yj2ltdQbloEj4vndPOV4H5X93xkX2FyOkGARIKHPTmJi3cUfTtD
kSg8LCZ8Loo9XZkNmxkkn5EQD5kJADs="]
	}
    }

    set rbIndArr(alternate_pressed) $rbIndArr(pressed)
}
