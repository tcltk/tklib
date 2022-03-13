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
    variable version	1.0
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
R0lGODlhDQANAIACAH98de7r5ywAAAAADQANAAACGYSPGMsd5iKMbdJlb6Zbgst0jlh94JOkRgEA
Ow=="]
	    set ckIndArr(pressed) [image create photo -data "
R0lGODlhDQANAIACAH98ddza1SwAAAAADQANAAACGYSPGMsd5iKMbdJlb6Zbgst0jlh94JOkRgEA
Ow=="]
	    set ckIndArr(alternate) [image create photo -data "
R0lGODlhDQANAIACAH98dViVvCwAAAAADQANAAACGYSPGMsd5iKMbdJlb6Zbgst0jlh94JOkRgEA
Ow=="]
	    set ckIndArr(alternate_disabled) [image create photo -data "
R0lGODlhDQANAIACAH98daCgoCwAAAAADQANAAACGYSPGMsd5iKMbdJlb6Zbgst0jlh94JOkRgEA
Ow=="]
	    set ckIndArr(selected) [image create photo -data "
R0lGODdhDQANAKEDAEpphH98de7r5////ywAAAAADQANAAACI4yPKMst5iKMAqzpgH1h7apdHQh+
k4Y2WKqOnuRSnMwk9lEAADs="]
	    set ckIndArr(selected_disabled) [image create photo -data "
R0lGODlhDQANAKEDAH98dZmZmdza1f///ywAAAAADQANAAACI4SPKMst5iKMIqzpgn1g7apdHQh+
k4Y2WKqOnuRSnMwk9lEAADs="]
	    set ckIndArr(selected_pressed) [image create photo -data "
R0lGODlhDQANAKEDAEpphH98ddza1f///ywAAAAADQANAAACI4yPKMst5iKMAqzpgH1h7apdHQh+
k4Y2WKqOnuRSnMwk9lEAADs="]
	}

	125 {
	    set ckIndArr(default) [image create photo -data "
R0lGODdhEAAQAIABAH98df///ywAAAAAEAAQAAACIISPacHtvp5kcb5qG85hZ2+BkyiRF8BBaEqt
rKkqslEAADs="]
	    set ckIndArr(pressed) [image create photo -data "
R0lGODlhEAAQAIACAH98ddza1SwAAAAAEAAQAAACIISPacHtvp5kcb5qG85hZ2+BkyiRF8BBaEqt
rKkqslEAADs="]
	    set ckIndArr(alternate) [image create photo -data "
R0lGODlhEAAQAIACAH98dViVvCwAAAAAEAAQAAACIISPacHtvp5kcb5qG85hZ2+BkyiRF8BBaEqt
rKkqslEAADs="]
	    set ckIndArr(alternate_disabled) [image create photo -data "
R0lGODlhEAAQAIACAH98daCgoCwAAAAAEAAQAAACIISPacHtvp5kcb5qG85hZ2+BkyiRF8BBaEqt
rKkqslEAADs="]
	    set ckIndArr(selected) [image create photo -data "
R0lGODdhEAAQAKEDAEpphH98de7r5////ywAAAAAEAAQAAACLIyPacLtvp5kcb46QcMPaBpY3idU
5AiFjCegaTOyl7rKc2dxVknvoJ9SCA0FADs="]
	    set ckIndArr(selected_disabled) [image create photo -data "
R0lGODlhEAAQAKEDAH98dZmZmdza1f///ywAAAAAEAAQAAACLISPacLtvp5kcb46Q8MvaApY3idU
5AiFjCegaTOyl7rKc2dxVknvoJ9SCA0FADs="]
	    set ckIndArr(selected_pressed) [image create photo -data "
R0lGODlhEAAQAKEDAEpphH98ddza1f///ywAAAAAEAAQAAACLIyPacLtvp5kcb46QcMPaBpY3idU
5AiFjCegaTOyl7rKc2dxVknvoJ9SCA0FADs="]
	}

	150 {
	    set ckIndArr(default) [image create photo -data "
R0lGODdhFAAUAIACAH98de7r5ywAAAAAFAAUAAACJ4SPqcHt3wycT9Jr78y6gr59oDeSZSSeAVey
owvCnazRWHralML3BQA7"]
	    set ckIndArr(pressed) [image create photo -data "
R0lGODlhFAAUAIACAH98ddza1SwAAAAAFAAUAAACJ4SPqcHt3wycT9Jr78y6gr59oDeSZSSeAVey
owvCnazRWHralML3BQA7"]
	    set ckIndArr(alternate) [image create photo -data "
R0lGODlhFAAUAIACAH98dViVvCwAAAAAFAAUAAACJ4SPqcHt3wycT9Jr78y6gr59oDeSZSSeAVey
owvCnazRWHralML3BQA7"]
	    set ckIndArr(alternate_disabled) [image create photo -data "
R0lGODlhFAAUAIACAH98daCgoCwAAAAAFAAUAAACJ4SPqcHt3wycT9Jr78y6gr59oDeSZSSeAVey
owvCnazRWHralML3BQA7"]
	    set ckIndArr(selected) [image create photo -data "
R0lGODdhFAAUAKEDAEpphH98de7r5////ywAAAAAFAAUAAACOoyPqcLt3wycT9Jr78wagBhojPcx
3ESWwvmkTuY57huOsTDTTZrrO0859So1mWpTFPmUS6Yp6VRIpwUAOw=="]
	    set ckIndArr(selected_disabled) [image create photo -data "
R0lGODlhFAAUAKEDAH98dZmZmdza1f///ywAAAAAFAAUAAACOoSPqcLt3wycT9Jr78w6hAhojPcx
3ESWwvmkTuY57huOsTDTTZrrO0859So1mWpTFPmUS6Yp6VRIpwUAOw=="]
	    set ckIndArr(selected_pressed) [image create photo -data "
R0lGODlhFAAUAKEDAEpphH98ddza1f///ywAAAAAFAAUAAACOoyPqcLt3wycT9Jr78wagBhojPcx
3ESWwvmkTuY57huOsTDTTZrrO0859So1mWpTFPmUS6Yp6VRIpwUAOw=="]
	}

	175 {
	    set ckIndArr(default) [image create photo -data "
R0lGODdhFwAXAIACAH98de7r5ywAAAAAFwAXAAACMISPqRftD6OJtM6K3c14c+p9UChqQAme6Kiu
pvuQqFzSov3hnJ7xXQvzWYCuhfFYAAA7"]
	    set ckIndArr(pressed) [image create photo -data "
R0lGODlhFwAXAIACAH98ddza1SwAAAAAFwAXAAACMISPqRftD6OJtM6K3c14c+p9UChqQAme6Kiu
pvuQqFzSov3hnJ7xXQvzWYCuhfFYAAA7"]
	    set ckIndArr(alternate) [image create photo -data "
R0lGODlhFwAXAIACAH98dViVvCwAAAAAFwAXAAACMISPqRftD6OJtM6K3c14c+p9UChqQAme6Kiu
pvuQqFzSov3hnJ7xXQvzWYCuhfFYAAA7"]
	    set ckIndArr(alternate_disabled) [image create photo -data "
R0lGODlhFwAXAIACAH98daCgoCwAAAAAFwAXAAACMISPqRftD6OJtM6K3c14c+p9UChqQAme6Kiu
pvuQqFzSov3hnJ7xXQvzWYCuhfFYAAA7"]
	    set ckIndArr(selected) [image create photo -data "
R0lGODdhFwAXAKEDAEpphH98de7r5////ywAAAAAFwAXAAACSYyPqSftD6OJtM6K3c148wYAWvA5
odh42YkKasW2bxQ/W0iz0I2b+k4CnYRDSVAQq1E8yd7ySCxaoFHOzNmhlkbbZ9f4BS7GiwIAOw=="]
	    set ckIndArr(selected_disabled) [image create photo -data "
R0lGODlhFwAXAKEDAH98dZmZmdza1f///ywAAAAAFwAXAAACSYSPqSftD6OJtM6K3c148xYEGvA5
odh42YkKasW2bxQ/W0iz0I2b+k4CnYRDSVAQq1E8yd7ySCxaoFHOzNmhlkbbZ9f4BS7GiwIAOw=="]
	    set ckIndArr(selected_pressed) [image create photo -data "
R0lGODlhFwAXAKEDAEpphH98ddza1f///ywAAAAAFwAXAAACSYyPqSftD6OJtM6K3c148wYAWvA5
odh42YkKasW2bxQ/W0iz0I2b+k4CnYRDSVAQq1E8yd7ySCxaoFHOzNmhlkbbZ9f4BS7GiwIAOw=="]
	}

	200 {
	    set ckIndArr(default) [image create photo -data "
R0lGODdhGgAaAIACAH98de7r5ywAAAAAGgAaAAACN4SPqRrtD6Mzslpq88Na834BoCeOoXmi0qdO
Zbu9cMPCdXurObqb/fgDBTtD0ix2dCVpi6bTUAAAOw=="]
	    set ckIndArr(pressed) [image create photo -data "
R0lGODlhGgAaAIACAH98ddza1SwAAAAAGgAaAAACN4SPqRrtD6Mzslpq88Na834BoCeOoXmi0qdO
Zbu9cMPCdXurObqb/fgDBTtD0ix2dCVpi6bTUAAAOw=="]
	    set ckIndArr(alternate) [image create photo -data "
R0lGODlhGgAaAIACAH98dViVvCwAAAAAGgAaAAACN4SPqRrtD6Mzslpq88Na834BoCeOoXmi0qdO
Zbu9cMPCdXurObqb/fgDBTtD0ix2dCVpi6bTUAAAOw=="]
	    set ckIndArr(alternate_disabled) [image create photo -data "
R0lGODlhGgAaAIACAH98daCgoCwAAAAAGgAaAAACN4SPqRrtD6Mzslpq88Na834BoCeOoXmi0qdO
Zbu9cMPCdXurObqb/fgDBTtD0ix2dCVpi6bTUAAAOw=="]
	    set ckIndArr(selected) [image create photo -data "
R0lGODdhGgAaAKEDAEpphH98de7r5////ywAAAAAGgAaAAACVoyPqSrtD6Mzslpq88Na8/4AwBSA
kDg2H4imwqq1LmzJc8nKGy6IlQ3hoCLAIK8V0kWEyJ5yebQ9oUmpS7KyeniOYobW3P6uX66Jeq7Q
0i8zW7WIyw0FADs="]
	    set ckIndArr(selected_disabled) [image create photo -data "
R0lGODlhGgAaAKEDAH98dZmZmdza1f///ywAAAAAGgAaAAACVoSPqSrtD6Mzslpq88Na8/4EwQSA
kDg2H4imwqq1LmzJc8nKGy6IlQ3hoCLAIK8V0kWEyJ5yebQ9oUmpS7KyeniOYobW3P6uX66Jeq7Q
0i8zW7WIyw0FADs="]
	    set ckIndArr(selected_pressed) [image create photo -data "
R0lGODlhGgAaAKEDAEpphH98ddza1f///ywAAAAAGgAaAAACVoyPqSrtD6Mzslpq88Na8/4AwBSA
kDg2H4imwqq1LmzJc8nKGy6IlQ3hoCLAIK8V0kWEyJ5yebQ9oUmpS7KyeniOYobW3P6uX66Jeq7Q
0i8zW7WIyw0FADs="]
	}
    }

    set ckIndArr(alternate_pressed)	$ckIndArr(pressed)
    set ckIndArr(disabled)		$ckIndArr(pressed)
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
R0lGODlhDQANAKECAH98de7r5////////yH5BAEKAAIALAAAAAANAA0AAAIhlAWZdxn/lgGwxmkr
QNm6Dn1gIIJlt1Emtk5quDGIEhsFADs="]
	    set rbIndArr(pressed) [image create photo -data "
R0lGODlhDQANAKECAH98ddza1f///////yH5BAEKAAIALAAAAAANAA0AAAIhlAWZdxn/lgGwxmkr
QNm6Dn1gIIJlt1Emtk5quDGIEhsFADs="]
	    set rbIndArr(alternate) [image create photo -data "
R0lGODlhDQANAKECAH98dViVvP///////yH5BAEKAAIALAAAAAANAA0AAAIhlAWZdxn/lgGwxmkr
QNm6Dn1gIIJlt1Emtk5quDGIEhsFADs="]
	    set rbIndArr(alternate_disabled) [image create photo -data "
R0lGODlhDQANAKECAH98daCgoP///////yH5BAEKAAIALAAAAAANAA0AAAIhlAWZdxn/lgGwxmkr
QNm6Dn1gIIJlt1Emtk5quDGIEhsFADs="]
	    set rbIndArr(selected) [image create photo -data "
R0lGODlhDQANAKEDAEpphH98de7r5////yH5BAEKAAMALAAAAAANAA0AAAIonBeZdyn/lgmwxgmB
hgFlvUWUAJbiU4InmQIrq14jzGFWPc0ikytMAQA7"]
	    set rbIndArr(selected_disabled) [image create photo -data "
R0lGODlhDQANAKEDAH98dZmZmdza1f///yH5BAEKAAMALAAAAAANAA0AAAIonAeZdyn/lgGwxgmD
hgBlvUWUAJbiU4InmQYrq14jzGFWPc0ikytMAQA7"]
	    set rbIndArr(selected_pressed) [image create photo -data "
R0lGODlhDQANAKEDAEpphH98ddza1f///yH5BAEKAAMALAAAAAANAA0AAAIonBeZdyn/lgmwxgmB
hgFlvUWUAJbiU4InmQIrq14jzGFWPc0ikytMAQA7"]
	}

	125 {
	    set rbIndArr(default) [image create photo -data "
R0lGODlhEAAQAKECAH98de7r5////////yH5BAEKAAIALAAAAAAQABAAAAIqlA2px5IBY2ogWnnq
3QBt7nzfI15kKWkodK4t2qllF7oZTMks3TjKxCgAADs="]
	    set rbIndArr(pressed) [image create photo -data "
R0lGODlhEAAQAKECAH98ddza1f///////yH5BAEKAAIALAAAAAAQABAAAAIqlA2px5IBY2ogWnnq
3QBt7nzfI15kKWkodK4t2qllF7oZTMks3TjKxCgAADs="]
	    set rbIndArr(alternate) [image create photo -data "
R0lGODlhEAAQAKECAH98dViVvP///////yH5BAEKAAIALAAAAAAQABAAAAIqlA2px5IBY2ogWnnq
3QBt7nzfI15kKWkodK4t2qllF7oZTMks3TjKxCgAADs="]
	    set rbIndArr(alternate_disabled) [image create photo -data "
R0lGODlhEAAQAKECAH98daCgoP///////yH5BAEKAAIALAAAAAAQABAAAAIqlA2px5IBY2ogWnnq
3QBt7nzfI15kKWkodK4t2qllF7oZTMks3TjKxCgAADs="]
	    set rbIndArr(selected) [image create photo -data "
R0lGODlhEAAQAKEDAEpphH98de7r5////yH5BAEKAAMALAAAAAAQABAAAAI2nB2px5MCY2ohWnnq
3QFZAAJWp0FhOJbnKakr2EYvDD3mHMvr6Hwo1ttcOh5hjVJqNTKKCaMAADs="]
	    set rbIndArr(selected_disabled) [image create photo -data "
R0lGODlhEAAQAKEDAH98dZmZmdza1f///yH5BAEKAAMALAAAAAAQABAAAAI2nA2px5MCY2ogWnnq
3QDZAAZWp0FhOJbnKakr2EYvDD3mHMvr6Hwo1ttcOh5hjVJqNTKKCaMAADs="]
	    set rbIndArr(selected_pressed) [image create photo -data "
R0lGODlhEAAQAKEDAEpphH98ddza1f///yH5BAEKAAMALAAAAAAQABAAAAI2nB2px5MCY2ohWnnq
3QFZAAJWp0FhOJbnKakr2EYvDD3mHMvr6Hwo1ttcOh5hjVJqNTKKCaMAADs="]
	}

	150 {
	    set rbIndArr(default) [image create photo -data "
R0lGODlhFAAUAKECAH98de7r5////////yH5BAEKAAIALAAAAAAUABQAAAI5lC+gi30aolTOQIkj
RSD7yX0f8IgimZhjqo5d610wJs/aa985iM9oD0OxgiFfoxYTHoGBTeWxcCIKADs="]
	    set rbIndArr(pressed) [image create photo -data "
R0lGODlhFAAUAKECAH98ddza1f///////yH5BAEKAAIALAAAAAAUABQAAAI5lC+gi30aolTOQIkj
RSD7yX0f8IgimZhjqo5d610wJs/aa985iM9oD0OxgiFfoxYTHoGBTeWxcCIKADs="]
	    set rbIndArr(alternate) [image create photo -data "
R0lGODlhFAAUAKECAH98dViVvP///////yH5BAEKAAIALAAAAAAUABQAAAI5lC+gi30aolTOQIkj
RSD7yX0f8IgimZhjqo5d610wJs/aa985iM9oD0OxgiFfoxYTHoGBTeWxcCIKADs="]
	    set rbIndArr(alternate_disabled) [image create photo -data "
R0lGODlhFAAUAKECAH98daCgoP///////yH5BAEKAAIALAAAAAAUABQAAAI5lC+gi30aolTOQIkj
RSD7yX0f8IgimZhjqo5d610wJs/aa985iM9oD0OxgiFfoxYTHoGBTeWxcCIKADs="]
	    set rbIndArr(selected) [image create photo -data "
R0lGODlhFAAUAKEDAEpphH98de7r5////yH5BAEKAAMALAAAAAAUABQAAAJLnD+hi30qolTOQIkj
RSH7yX1f8HjACXhkkqFoRnaY68JyRNPYhefvdBP4fprg8LQLCn0w1ky3s5iIIKmoWbpGOUpbJdHd
fC0LMaIAADs="]
	    set rbIndArr(selected_disabled) [image create photo -data "
R0lGODlhFAAUAKEDAH98dZmZmdza1f///yH5BAEKAAMALAAAAAAUABQAAAJLnD+gi30qolTOQIkj
RSD7yX0f8HjBGXhkkqFoRnaY68JyRNPYhefvdBP4fprg8LQLCn0w1ky3s5iIIKmoWbpGOUpbJdHd
fC0LMaIAADs="]
	    set rbIndArr(selected_pressed) [image create photo -data "
R0lGODlhFAAUAKEDAEpphH98ddza1f///yH5BAEKAAMALAAAAAAUABQAAAJLnD+hi30qolTOQIkj
RSH7yX1f8HjACXhkkqFoRnaY68JyRNPYhefvdBP4fprg8LQLCn0w1ky3s5iIIKmoWbpGOUpbJdHd
fC0LMaIAADs="]
	}

	175 {
	    set rbIndArr(default) [image create photo -data "
R0lGODlhFwAXAKECAH98de7r5////////yH5BAEKAAIALAAAAAAXABcAAAJFlG+gC+iugpxBPRSp
ru2BDUrd8YXhKJTmNqorm7xnKptZzbr4dO+87uv5OENKA1jrIGWtIWppg+xQJKiICkFaLh7G9lEA
ADs="]
	    set rbIndArr(pressed) [image create photo -data "
R0lGODlhFwAXAKECAH98ddza1f///////yH5BAEKAAIALAAAAAAXABcAAAJFlG+gC+iugpxBPRSp
ru2BDUrd8YXhKJTmNqorm7xnKptZzbr4dO+87uv5OENKA1jrIGWtIWppg+xQJKiICkFaLh7G9lEA
ADs="]
	    set rbIndArr(alternate) [image create photo -data "
R0lGODlhFwAXAKECAH98dViVvP///////yH5BAEKAAIALAAAAAAXABcAAAJFlG+gC+iugpxBPRSp
ru2BDUrd8YXhKJTmNqorm7xnKptZzbr4dO+87uv5OENKA1jrIGWtIWppg+xQJKiICkFaLh7G9lEA
ADs="]
	    set rbIndArr(alternate_disabled) [image create photo -data "
R0lGODlhFwAXAKECAH98daCgoP///////yH5BAEKAAIALAAAAAAXABcAAAJFlG+gC+iugpxBPRSp
ru2BDUrd8YXhKJTmNqorm7xnKptZzbr4dO+87uv5OENKA1jrIGWtIWppg+xQJKiICkFaLh7G9lEA
ADs="]
	    set rbIndArr(selected) [image create photo -data "
R0lGODlhFwAXAKEDAEpphH98de7r5////yH5BAEKAAMALAAAAAAXABcAAAJWnG+hG+iuhJxCPRSp
ru2FDUrd8YXhOJTmNqoUAMNg50rxzabbzbM1D9RkJsAeZWgrxoQ/pezYdDJ3ylxNUMzpqEvtdiXE
gL2J8QRFujIv6RmanWJYLgUAOw=="]
	    set rbIndArr(selected_disabled) [image create photo -data "
R0lGODlhFwAXAKEDAH98dZmZmdza1f///yH5BAEKAAMALAAAAAAXABcAAAJWnG+gC+iuhJxCPRSp
ru2BDUrd8YXhOJTmNqpUAMNg50rxzabbzbM1D9RkJsAeZWgrxoQ/pezYdDJ3ylxNUMzpqEvtdiXE
gL2J8QRFujIv6RmanWJYLgUAOw=="]
	    set rbIndArr(selected_pressed) [image create photo -data "
R0lGODlhFwAXAKEDAEpphH98ddza1f///yH5BAEKAAMALAAAAAAXABcAAAJWnG+hG+iuhJxCPRSp
ru2FDUrd8YXhOJTmNqoUAMNg50rxzabbzbM1D9RkJsAeZWgrxoQ/pezYdDJ3ylxNUMzpqEvtdiXE
gL2J8QRFujIv6RmanWJYLgUAOw=="]
	}

	200 {
	    set rbIndArr(default) [image create photo -data "
R0lGODlhGgAaAKECAH98de7r5////////yH5BAEKAAIALAAAAAAaABoAAAJOlH+gq+gvVJh0Nohk
3RbgyIWU9wDiGZAJiqogK6omfJIzHXo3nu/8pvlxgsIKsdhBAn3IY/OltCktq2e16ILysgZm6+Mc
ckve1BjMWHwKADs="]
	    set rbIndArr(pressed) [image create photo -data "
R0lGODlhGgAaAKECAH98ddza1f///////yH5BAEKAAIALAAAAAAaABoAAAJOlH+gq+gvVJh0Nohk
3RbgyIWU9wDiGZAJiqogK6omfJIzHXo3nu/8pvlxgsIKsdhBAn3IY/OltCktq2e16ILysgZm6+Mc
ckve1BjMWHwKADs="]
	    set rbIndArr(alternate) [image create photo -data "
R0lGODlhGgAaAKECAH98dViVvP///////yH5BAEKAAIALAAAAAAaABoAAAJOlH+gq+gvVJh0Nohk
3RbgyIWU9wDiGZAJiqogK6omfJIzHXo3nu/8pvlxgsIKsdhBAn3IY/OltCktq2e16ILysgZm6+Mc
ckve1BjMWHwKADs="]
	    set rbIndArr(alternate_disabled) [image create photo -data "
R0lGODlhGgAaAKECAH98daCgoP///////yH5BAEKAAIALAAAAAAaABoAAAJOlH+gq+gvVJh0Nohk
3RbgyIWU9wDiGZAJiqogK6omfJIzHXo3nu/8pvlxgsIKsdhBAn3IY/OltCktq2e16ILysgZm6+Mc
ckve1BjMWHwKADs="]
	    set rbIndArr(selected) [image create photo -data "
R0lGODlhGgAaAKEDAEpphH98de7r5////yH5BAEKAAMALAAAAAAaABoAAAJmnH+hq+g/lJh0Nohk
3TbgyIWU9wTiKZAJiqogK6pmCNR2bMybzQOhp6v0er/gZDjkaIRIntIoaDo3S4r0RoVea0/O1pel
SX+vHZJcNk+VKxg6537D4yMItPWpxlwY/Yj/kcOw8FEAADs="]
	    set rbIndArr(selected_disabled) [image create photo -data "
R0lGODlhGgAaAKEDAH98dZmZmdza1f///yH5BAEKAAMALAAAAAAaABoAAAJmnH+gq+g/lJh0Nohk
3RbgyIWU9wDiKZAJiqogK6pmGNR2bMybzQehp6v0er/gZDjkaIRIntIoaDo3S4r0RoVea0/O1pel
SX+vHZJcNk+VKxg6537D4yMItPWpxlwY/Yj/kcOw8FEAADs="]
	    set rbIndArr(selected_pressed) [image create photo -data "
R0lGODlhGgAaAKEDAEpphH98ddza1f///yH5BAEKAAMALAAAAAAaABoAAAJmnH+hq+g/lJh0Nohk
3TbgyIWU9wTiKZAJiqogK6pmCNR2bMybzQOhp6v0er/gZDjkaIRIntIoaDo3S4r0RoVea0/O1pel
SX+vHZJcNk+VKxg6537D4yMItPWpxlwY/Yj/kcOw8FEAADs="]
	}
    }

    set rbIndArr(alternate_pressed)	$rbIndArr(pressed)
    set rbIndArr(disabled)		$rbIndArr(pressed)
}
