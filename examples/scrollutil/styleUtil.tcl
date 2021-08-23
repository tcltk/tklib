#==============================================================================
# Patches a few ttk widget styles and defines the style Small.Toolbutton.
#
# Copyright (c) 2019-2021  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# To set the "-autohidescrollbars" or "-setfocus" option of all scrollarea
# widgets in all demo scripts to true, uncomment the corresponding line below:
#
# option add *Scrollarea.autoHideScrollbars 1
# option add *Scrollarea.setFocus           1

foreach theme {alt clam classic default} {
    ttk::style theme settings $theme {
	#
	# TSpinbox
	#
	ttk::style map TSpinbox -fieldbackground {readonly white}

	#
	# Make sure the combobox will show whether it has the focus
	#
	ttk::style map TCombobox \
	    -fieldbackground [list {readonly focus} #4a6984] \
	    -foreground      [list {readonly focus} #ffffff]

	option add *TCombobox*Listbox.selectBackground  #4a6984
	option add *TCombobox*Listbox.selectForeground  #ffffff

	#
	# Small.Toolbutton
	#
	ttk::style configure Small.Toolbutton -padding 1
	ttk::style map Small.Toolbutton -relief [list disabled flat \
	    selected sunken pressed sunken active raised focus raised]
    }
}

if {[tk windowingsystem] eq "aqua"} {
    ttk::style theme settings aqua {
	#
	# Work around some appearance issues related to the "aqua" theme
	#
	if {[catch {winfo rgb . systemTextBackgroundColor}] == 0 &&
	    [catch {winfo rgb . systemTextColor}] == 0} {
	    foreach style {TEntry TSpinbox} {
		ttk::style configure $style \
		    -background systemTextBackgroundColor \
		    -foreground systemTextColor
	    }
	}

	#
	# Small.Toolbutton
	#
	ttk::style configure Small.Toolbutton -padding 0
    }
}

foreach theme {alt classic default} {
    #
    # Toolbutton
    #
    ttk::style theme settings $theme {
	ttk::style map Toolbutton -background \
	    [linsert [ttk::style map Toolbutton -background] 0 selected #c3c3c3]
    }
}

ttk::style theme settings clam {
    #
    # Toolbutton
    #
    ttk::style map Toolbutton -background \
	[linsert [ttk::style map Toolbutton -background] 2 selected #bab5ab]
    ttk::style map Toolbutton -lightcolor \
	[linsert [ttk::style map Toolbutton -lightcolor] 0 selected #bab5ab]
    ttk::style map Toolbutton -darkcolor \
	[linsert [ttk::style map Toolbutton -darkcolor]  0 selected #bab5ab]

    ttk::style configure TButton -padding 3 -width -9	;# default: 5, -11
    ttk::style configure Heading -padding 1		;# default: 3

    if {[catch {rename tablelist::clamTheme tablelist::_clamTheme}] == 0} {
	proc tablelist::clamTheme {} {
	    tablelist::_clamTheme

	    variable themeDefaults
	    set themeDefaults(-labelpady) 1		;# default: 3
	}
    }
}

if {[tk windowingsystem] eq "x11"} {
    font configure TkHeadingFont -weight normal		;# default: bold

    option add *selectBackground	  #4a6984	;# default: #c3c3c3
    option add *selectForeground	  #ffffff	;# default: #000000
    option add *inactiveSelectBackground  #9e9a91	;# default: #c3c3c3

    ttk::setTheme clam
}

#
# Creates a toolbutton widget which appears raised when it has the focus.
#
proc createToolbutton {w args} {
    eval ttk::button $w -style Small.Toolbutton $args

    if {[lsearch -exact {vista xpnative} $ttk::currentTheme] >= 0} {
	bindtags $w [linsert [bindtags $w] 1 Toolbtn]
    }

    return $w
}

#
# "Toolbtn" bindings for the themes "vista" and "xpnative"
#
bind Toolbtn <FocusIn>		{ %W state  active }
bind Toolbtn <FocusOut>		{ %W state !active }
bind Toolbtn <Leave>		{ %W instate focus break }
bind Toolbtn <Button1-Leave>	{ %W state !pressed }
