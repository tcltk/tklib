# menubar.tcl --
#
#    Package that defines the menubar class. The menubar class 
#    encapsulates the definition, installation and dynamic behavior 
#    of a menubar.
#
# Copyright (c) 2009    Tom Krehbiel <tomk@users.sourceforge.net>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: menubar.tcl,v 1.2 2009/12/25 22:30:23 tomk Exp $

package require Tk
package require TclOO

package require menubar::tree

package provide menubar 0.5

# --------------------------------------------------
# DESIGN NOTES
# --------------------------------------------------
# STRUCTURE: mtree
#
# <node>
#   M - <cascade>
#   S - <separator>
#   C - <command>
#   X - <checkbutton>
#   R - {radiogroup}
#		 <radiobutton>
#   G - {commandgroup} <separator>
#		 <command>
#
# STRUCTURE: installs
#
# <wtop>
#   <node-tag>
#     +pathname
#       <pathname>
#     +callback_ns
#       <namespace>
# --------------------------------------------------


oo::class create ::menubar {

	# ------------------------------------------------------------
	#
	# new --
	#
	#    Create an instance of the menubar class.
	#
	# Parameters:
	#       args - zero or more option/value pairs
	#
	# Results:
	#       An instance of the menubar class is returned.
	#
	# Side effects:
	#       none
	#
	# ------------------------------------------------------------
	constructor { args } {
		my variable mtree
		my variable next_id
		my variable installs
		my variable tearoffpathnames
		my variable first_install

		my variable wtop
		my variable mtop
		
		# This array holds the current value for checkbutton and radiobutton items
		my variable tagVal			

		set next_id 0
	
		set mtree [menubar::tree new]

		${mtree} rename root menubar
		${mtree} key.set menubar +type cascade
		${mtree} key.set menubar +is_defined 0

		# add menubar settings
		foreach {opt value} ${args} {
			${mtree} key.set menubar ${opt} ${value}
		}
		
		set installs [dict create]
		set tearoffpathnames [dict create]
		set first_install ""
		return
	}

	# ------------------------------------------------------------
	#
	# loadDebugMethods --
	#
	#	Determine the pathname of the toplevel window for a widget.
	#
	# Parameters:
	#		none
	#
	# Results:
	#       node
	#
	# Side effects:
	#		Debug package is loaded
	#
	# ------------------------------------------------------------
	method loadDebugMethod { } {
		package require menubar::debug
	}

	# ------------------------------------------------------------
	#
	# getTopLevel --
	#
	#	Determine the pathname of the toplevel window for a widget.
	#
	# Parameters:
	#		w - window
	#
	# Results:
	#       Returns the path name of the top-of-hierarchy window 
	#		containing window.
	#
	# Side effects:
	#		none
	#
	# ------------------------------------------------------------
	method getTopLevel { w } {
		return [winfo toplevel ${w}]
	}
	

	# ------------------------------------------------------------
	#
	# ScrubString --
	#
	# 	Convert users menubar description into a tcl list, also
	# 	remove blank and comment lines from the description.
	#
	# Parameters:
	#		str - character string
	#
	# Results:
	#       list
	#
	# Side effects:
	#		none
	#
	# ------------------------------------------------------------
	method ScrubString { str } {
		foreach line [split ${str} \n] {
			set line [string trim ${line}]
			if { ${line} eq "" || [string index ${line} 0] eq "#" } { continue }
			lappend result ${line}
		}
		return [join ${result} \n]
	}

	# ------------------------------------------------------------
	#
	# define --
	#
	# 	This is the user interface to the menubar description parser.
	#
	# Parameters:
	#		definition - menubar description
	#
	# Results:
	#       none
	#
	# Side effects:
	#		Entries are added to the mtree structure.
	#
	# ------------------------------------------------------------
	method define { definition } {
		my variable mtree
		if { [${mtree} key.get menubar +is_defined] == 1 } { return }
		my MenuAdd menubar ${definition}
		${mtree} key.set menubar +is_defined 1
		return
	}

	# ------------------------------------------------------------
	#
	# MenuAdd --
	#
	# 	Parse one menu description and add it to mtree.
	# 	The new menu is a branch off the parent.
	#
	# Parameters:
	#		parent	- parent tag name
	#		desc	- menu description
	#
	# Results:
	#       none
	#
	# Side effects:
	#		Entries are added to the menu tree (mtree) structure.
	#
	# ------------------------------------------------------------
	method MenuAdd { parent desc } {
		my variable mtree
		if { ${parent} ni [${mtree} nodes] } {
			error "error: MenuAdd - tag '${parent}' doesn't exist."
		}
		set desc [my ScrubString ${desc}]
		if { ${desc} eq "" } { return 0 }
		foreach {name istype more} ${desc} {
			set node [my ParseItem ${parent} ${name} ${istype} end ${more}]
		}
		return
	} 
	
	
	# ------------------------------------------------------------
	#
	# TagCheck --
	#
	#	Check the format of a tag string.
	#
	# Parameters:
	#		tag		- tag name to be checked
	#		unique	- flag that indecates if the tag should be globally
	#				  unique. Default is true.
	#
	# Results:
	#       none
	#
	# Side effects:
	#		error is thrown if tag check fails
	#
	# ------------------------------------------------------------
	method TagCheck { tag {unique 1} } {
		my variable mtree
		set tags [${mtree} nodes]
		if { ${unique} == 1 &&  ${tag} in ${tags} } {
			error "bug: tag '${tag}' already used."
		}
		if { [regexp {^[^+\"\[\]\$\\]{1,}$} ${tag}] == 0 } {
			error "bug: tag '${tag}' not a simple string."
		}
		return
	}

	# ------------------------------------------------------------
	#
	# CreateWidgetPath --
	#
	#	Construct a unique child pathname for a parent pathname.
	#
	# Parameters:
	#		pathname	- parent tag name
	#
	# Results:
	#       child widget pathname
	#
	# Side effects:
	#		none
	#
	# ------------------------------------------------------------
	method CreateWidgetPath { pathname } {
		my variable next_id
		incr next_id
		return [join [list ${pathname} "m${next_id}"] "."]
	}

	# ------------------------------------------------------------
	#
	# ParseItem --
	#
	#	Parse one line from the user's menubar description and add the
	#	item to mtree.
	#
	# Parameters:
	#		parent	- parent tag name
	#		name	- tag name of new item
	#		istype	- type identifier (oneof: M,S,C,X,R,G)
	#		index	- position in parent's list
	#		more	- rest of item definition; varies based on istype value
	#
	# Results:
	#       fully qualified tag name of new item
	#
	# Side effects:
	#		an item is added to mtree
	#
	# ------------------------------------------------------------
	method ParseItem { parent name istype index more } {
		my variable mtree
		my variable tagVal
		my variable next_id
		switch -glob -- ${istype} {
		"M*" {
			# create a new sub-menu
			set opts [dict create +type cascade]
			set def ${more}
			set tearoff 0
			set tearoff [expr { [string index ${istype} end] eq "+" ? 1 : 0 }]
			dict set opts +tearoff ${tearoff}
			dict set opts +tearoffpathname {}
			
			dict set opts +hide 0
			set istype [string trimright ${istype} "+"]
			lassign [split ${istype} ":"] - tag
			if { ${tag} eq "" } {
				error "bug: menu (${name} ${istype}) has no tag name."
			}	
			my TagCheck ${tag}
			${mtree} insert ${parent} ${index} ${tag}
			dict set opts -label ${name}
			dict set opts -underline 0
			dict set opts -hidemargin 0
			dict for {opt val} ${opts} {
				${mtree} key.set ${tag} ${opt} ${val}
			} 
			my MenuAdd ${tag} ${def}
		}
		"S" {
			# add a separator
			set tag ${more}
			set opts [dict create +type separator]
			my TagCheck ${tag}
			${mtree} insert ${parent} ${index} ${tag}
			dict for {opt val} ${opts} {
				${mtree} key.set ${tag} ${opt} ${val}
			} 
		}
		"C" {
			# add a command
			set tag ${more}
			set opts [dict create +type command]
			my TagCheck ${tag}
			${mtree} insert ${parent} ${index} ${tag}
			dict set opts +sync "no"
			dict set opts +command {}
			dict set opts +bind {}
			dict set opts -label "${name}"
			dict set opts -underline 0
			dict for {opt val} ${opts} {
				${mtree} key.set ${tag} ${opt} ${val}
			} 
		}
		"X" {
			# add a checkbutton
			set tag ${more}
			set opts [dict create +type checkbutton]
			set value  [expr {([string index ${tag} end] eq "+") ? 1 : 0}]
			set tag [string trimright ${tag} +]
			my TagCheck ${tag}
			${mtree} insert ${parent} ${index} ${tag}
			set tagVal(${tag}%%) ${value}
			dict set opts +sync yes
			dict set opts +command {}
			dict set opts +bind {}
			dict set opts -label "${name}"
			dict set opts -underline 0
			dict set opts +variable [self namespace]::tagVal(${tag}%%)
			dict set opts -onvalue 1
			dict set opts -offvalue 0
			dict for {opt val} ${opts} {
				${mtree} key.set ${tag} ${opt} ${val}
			} 
		}
		"R" {
			# add a radiobutton
			set tag ${more}
			set value  [expr {([string index ${tag} end] eq "+") ? 1 : 0}]
			set tag [string trimright ${tag} +]
			my TagCheck ${tag} 0
			if { ${tag} ni [${mtree} nodes] } {
				${mtree} insert ${parent} ${index} ${tag}
				${mtree} key.set ${tag} +type radiogroup				
				${mtree} key.set ${tag} +sync "yes"
				${mtree} key.set ${tag} +command {}
				${mtree} key.set ${tag} +value {}
				${mtree} key.set ${tag} +initval {}
				${mtree} key.set ${tag} +variable [self namespace]::tagVal(${tag}%%)
			}
			set opts [dict create +type radiobutton]
			# tag name for radiobutton node
			incr next_id
			set _tag "${tag}_${next_id}"
			${mtree} insert ${tag} ${index} ${_tag}
			if { ${value} == 1 } {
				${mtree} key.set ${tag} +initval ${name}
			}			
			dict set opts -label "${name}"
			dict set opts -underline 0
			dict for {opt val} ${opts} {
				${mtree} key.set ${_tag} ${opt} ${val}
			} 
		}
		"G" {
			# add a command group
			set tag ${more}
			set opts [dict create +type commandgroup]
			my TagCheck ${tag}
			${mtree} insert ${parent} ${index} ${tag}
			dict for {opt val} ${opts} {
				${mtree} key.set ${tag} ${opt} ${val}
			} 
		}
		default {
			error "bug: '${name}' - unknown item type (${istype})"
		}}
		return ${tag}
	}

	# ------------------------------------------------------------
	#
	# tag.add --
	#
	#	Add a user defined tag
	#
	# Parameters:
	#		tag		- tag name
	#		value	- the tag's value
	#
	# Results:
	#       none
	#
	# Side effects:
	#		a user defined tag/value pair is added to the installs
	#		structure for the current toplevel window
	#
	# ------------------------------------------------------------
	method tag.add { tag value } {
		my variable wtop
		my variable installs
		my variable first_install
		# Only set during an install
		if { ${first_install} ne ""  } {
			dict set installs ${wtop} +tags ${tag} ${value}
		} else {
			error "error: tag - command used outside install"
		}
		return
	}

	# ------------------------------------------------------------
	#
	# tag.cget --
	#
	#	Return an option value given a window and tag
	#
	# Parameters:
	#		wtop	- toplevel pathname
	#		tag		- tag name
	#		opt		- option name
	#
	# Results:
	#       value of option
	#
	# Side effects:
	#		none
	#
	# ------------------------------------------------------------
	method tag.cget { wtop tag {opt ""} } {
		my variable mtree
		my variable installs

		if { [dict size ${installs}] == 0 } {
			error "error: tag.cget - '${mtree}' not installed."
		}
		
		# if opt isn't included then return the value of an
		# user defined (install) tag (not a menu tag)
		if { ${opt} eq "" } {
			if { [dict exists  ${installs} ${wtop} +tags ${tag}] } {
				set value [dict get ${installs} ${wtop} +tags ${tag}]
			} else {
				error "error: tag(${tag}) - not defined for toplevel(${wtop})"
			}
			return ${value}	
		}
		
		if { [${mtree} exists ${tag}] ne "" } {
			error "error: tag.cget - tag '${tag}' not found"
		}
		
		set parent_node [${mtree} parent ${tag}]
		
		switch -exact -- [${mtree} key.get ${tag} +type] {
		"cascade" {
			set parent_path [dict get ${installs} ${wtop} ${parent_node} +pathname]
			set name [${mtree} key.get ${tag} -label]
			set value [${parent_path} entrycget ${name} ${opt}]
			return ${value}
		}
		"separator" {
			return "separator"
		}
		"command" {
			set parent_path [dict get ${installs} ${wtop} ${parent_node} +pathname]
			set name [${mtree} key.get ${tag} -label]
			set value [${parent_path} entrycget ${name} ${opt}]
			return ${value}
		}
		"checkbutton" {
			set parent_path [dict get ${installs} ${wtop} ${parent_node} +pathname]
			set name [${mtree} key.get ${tag} -label]
			set value [${parent_path} entrycget ${name} ${opt}]
			return ${value}
		}
		"radiogroup" {
			# only state information is availible for radio buttons
			# because the buttons share a tag name
			if { ${opt} eq "-state" } {
				set value [${mtree} key.get ${tag} +value]
				if { ${value} eq "" } {
					set value [${mtree} key.get ${tag} +initval]
				}
				return ${value}
			}
		}
		"radiobutton" {
		}
		"commandgroup" {
		}
		"groupcommand" {
		}
		default {
		}}
		return
	}
	
	# ------------------------------------------------------------
	#
	# menu.namespace --
	#
	#	Set the namespace for a sub-tree of the menubar starting at
	#	the entry with tag name.
	#
	# Parameters:
	#		tag		- tag name
	#		ns		- new namespace
	#
	# Results:
	#       none
	#
	# Side effects:
	#		mtree is modified or an error is thrown if the command is
	#		used outside the context of the install method
	#
	# ------------------------------------------------------------
	method menu.namespace { tag ns } {
		my variable mtree
		my variable wtop
		my variable installs
		my variable first_install
		
		# Only set during an install
		if { ${first_install} ne ""  } {
			if { [${mtree} key.get ${tag} +type] ni {commandgroup cascade}  } {
				puts stderr "menu.namespace: tag (${tag}) not a commandgroup or cascade"
				return
			}
			dict set installs ${wtop} ${tag} +callback_ns ${ns}
		} else {
			error "error: menu.namespace - command used outside install"
		}
		return
	}

	# ------------------------------------------------------------
	#
	# install --
	#
	# 	Install an initial Tk menu in a toplevel window and install the
	#	rest of the menubar using the MenuInstall method. After the menubar
	#	has been installed, configure option values for all the menubar entries.
	#
	# Parameters:
	#		win		- pathname of window where menubar will be installed
	#		config	- user supplied code to configure the items on
	#				  the installed menubar
	#
	# Results:
	#       none
	#
	# Side effects:
	#		A menubar is installed and displayed.
	#
	# ------------------------------------------------------------
	method install { win config } {
		my variable mtree
		my variable wtop
		my variable mtop
		my variable installs
		my variable first_install	;# oneof: "yes", "no" or ""
		my variable ns

		if { [${mtree} key.get menubar +is_defined] != 1 } {
			error "error: install - '${mtree}' not defined."
		}

		# determine the actual path of the top level window
		# (the path can be "hidden" by megawidget code)
		set wtop [my getTopLevel ${win}]
		if { ${wtop} eq "." } {
			set mtop ".m0"
		} else {
			set mtop [join [list ${wtop} "m0"] "."]
		}
		
		if { [dict keys ${installs} ${wtop}] eq "" } {
			# puts a Destroy binding on the new toplevel
			bind ${wtop} <Destroy> [namespace code [list my WindowCleanup ${wtop}]]
			# check to see if this is the first install
			set first_install "no"
			if { [llength [dict keys ${installs}]] == 0 } {
				set first_install "yes"
			}
			# create a menu and install it as a menubar
			menu ${mtop}
			${wtop} configure -menu ${mtop}
			dict set installs ${wtop} menubar +pathname ${mtop}
			dict set installs ${wtop} menubar +callback_ns [uplevel {namespace current}]
			
			# configure the menubar
			${mtop} configure  {*}[${mtree} key.getall menubar -*]

			# create sub-menus
			foreach node [${mtree} children menubar] {
				my MenuInstall ${wtop} ${mtop} ${node}
			}
			
			# configure the new menubar		
			uplevel ${config}
			set first_install ""
		}
		return
	}
	
	# ------------------------------------------------------------
	#
	# WindowCleanup --
	#
	# 	Cleanup internal data structures associated with a toplevel window
	#	when it is destroyed
	#
	# Parameters:
	#		wtop	- pathname of toplevel window
	#
	# Results:
	#       none
	#
	# Side effects:
	#		Data is removed from internal data structures
	#
	# ------------------------------------------------------------
	method WindowCleanup { wtop } {
		my variable mtree
		my variable installs
		my variable tearoffpathnames
		if { ${wtop} in [dict keys ${installs}] } {
			dict unset installs ${wtop}
			dict unset tearoffpathnames ${wtop}
			#puts "tearoffpathnames: ${tearoffpathnames}"
		}
		return
	}

	# ------------------------------------------------------------
	#
	# MenuInstall --
	#
	#	Create Tk menu widget or menu widget entry from a definition found in
	#	the mtree structure.
	#
	# Parameters:
	#		win			- pathname of window where tk menu will be added
	#		parent_path	- pathname of parent menu 
	#		node		- mtree node containing the item to be created
	#
	# Results:
	#       none
	#
	# Side effects:
	#		A Tk menu or menu entry is created.
	#
	# ------------------------------------------------------------
	method MenuInstall { wtop parent_path node } {
		my variable mtree
		my variable installs
		my variable first_install
		
		set ns [dict get ${installs} ${wtop} menubar +callback_ns]

		switch -glob -- [${mtree} key.get ${node} +type] {
		"cascade" {
			# don't render hidden menus
			if { [${mtree} key.exists ${node} +hide] && [${mtree} key.get ${node} +hide] == 1 } {
				return
			}
			set name [${mtree} key.get ${node} -label]
			if { [string tolower ${name}] eq "help" } {
				# If menu is a help menu then the pathname must end in "help"
				# so the menu will be right justified on the menubar
				set child_path [join [list ${parent_path} "help"] "."]
			} else {
				set child_path [my CreateWidgetPath ${parent_path}]
			}

			dict set installs ${wtop} ${node} +pathname ${child_path}
			if { ${first_install} ne "" } {
				dict set installs ${wtop} ${node} +callback_ns ${ns}
			}
			menu ${child_path} \
				-tearoff [${mtree} key.get ${node} +tearoff] \
				-tearoffcommand [namespace code [list my AppendTearoffPathname ${node}]]
			set index [expr [${mtree} index ${node}]+1]
			${parent_path} insert ${index} cascade -label ${name} -menu ${child_path}
			my InstallSubTree ${wtop} ${child_path} ${node}
			my RenderTag ${wtop} ${node}
		}
		"separator" {
			${parent_path} add separator
			my RenderTag ${wtop} ${node}
		}
		"groupcommand" {
			set name [${mtree} key.get ${node} -label]
			${parent_path} add command -label ${name}
			my RenderTag ${wtop} ${node}
		}
		"command" {
			set name [${mtree} key.get ${node} -label]
			${parent_path} add command -label ${name}
			my RenderTag ${wtop} ${node}
		}
		"checkbutton" {
			set name [${mtree} key.get ${node} -label]
			${parent_path} add checkbutton -label ${name}
			my RenderTag ${wtop} ${node}
		}
		"radiogroup" {
			dict set installs ${wtop} ${node} +pathname ${parent_path}
			my InstallSubTree ${wtop} ${parent_path} ${node} 
		}
		"radiobutton" {
			set varname [${mtree} key.get [${mtree} parent ${node}] +variable]
			set name [${mtree} key.get ${node} -label]
			${parent_path} add radiobutton -label ${name} -variable ${varname}
			my RenderTag ${wtop} ${node}
		}
		"commandgroup" {
			${parent_path} add separator
			dict set installs ${wtop} ${node} +pathname ${parent_path}
			my RenderTag ${wtop} ${node}
			my InstallSubTree ${wtop} ${parent_path} ${node} 
		}
		default {
		}}
		return
	}

	# ------------------------------------------------------------
	#
	# AppendTearoffPathname --
	#
	# 	This proceedure is called after a tearoff menu has been created.
	# 	Tearoff menus are toplevel windows but we need to keep track of
	# 	the association between the toplevel window containing the menubar
	# 	and the tearoff menu.
	#
	# Parameters:
	#		node				- mtree node containing the item to be created
	#		trash				- not used
	#		tearoff_pathname	- pathname of tearoff menu
	#
	# Results:
	#       none
	#
	# Side effects:
	#		Information about the tearoff menu is saved. A WM_DELETE_WINDOW
	#		protocol handler is added to the tearoff menu. The tearoff menu
	#		geometry is ajusted and then resizing is turned off.
	#
	# ------------------------------------------------------------
	method AppendTearoffPathname { node trash tearoff_pathname } {
		my variable mtree
		my variable tearoffpathnames
		# get the toplevel that contains the menubar
		set wtop [join [lrange [split ${tearoff_pathname} "."] 0 1] "."]
		my DeleteTearoff ${wtop} ${node}
		dict set tearoffpathnames ${wtop} ${node} ${tearoff_pathname}
		lassign [winfo pointerxy .] xx yy
		wm protocol ${tearoff_pathname} WM_DELETE_WINDOW [namespace code [list my DeleteTearoff ${wtop} ${node}]]
		regexp {([0-9]+)[Xx]([0-9]+)([+-][0-9]+)([+-][0-9]+)} [wm geometry ${tearoff_pathname}] - width height x y
		wm geometry ${tearoff_pathname} +${xx}+${yy}
		if { ${width} < 120 } { set width 120 }
		wm minsize ${tearoff_pathname} ${width} 40
		update
		wm resizable ${tearoff_pathname} 0 0
		return
	}

	# ------------------------------------------------------------
	#
	# DeleteTearoff --
	#
	# 	This proceedure is called when a tearoff menu is destroyed.
	#
	# Parameters:
	#		wtop	- toplevel window that created the tearoff menu
	#		node	- mtree node that defines the menu
	#
	# Results:
	#       none
	#
	# Side effects:
	#		The tornoff menu is destroyed and its pathname is removed from
	#		the list of menus that have been tornoff.
	#
	# ------------------------------------------------------------
	method DeleteTearoff { wtop node } {
		my variable mtree
		my variable tearoffpathnames
		if { [dict exists ${tearoffpathnames} ${wtop} ${node}] } {
			destroy  [dict get ${tearoffpathnames} ${wtop} ${node}]
			dict unset tearoffpathnames ${wtop} ${node}
		}
		return
	}

	# ------------------------------------------------------------
	#
	# InstallSubTree --
	#
	#	Install all the child nodes for a given parent node.
	#
	# Parameters:
	#		wtop		- toplevel window for install
	#		parent_path	- pathname of parent node
	#		parent_node	- mtree node name of parent
	#
	# Results:
	#       none
	#
	# Side effects:
	#		The MenuInstall method is executed on all the child nodes
	#		of parent_node.
	#
	# ------------------------------------------------------------
	method InstallSubTree { wtop parent_path parent_node } {
		my variable mtree
		foreach node [${mtree} children ${parent_node}] {
			my MenuInstall ${wtop} ${parent_path} ${node}
		}
		return
	}

	# ------------------------------------------------------------
	#
	# menu.configure --
	#
	#	Add any number of option/value pairs for multiple item in the mtree
	#	stucture then update the visible rendering of the menubar.
	#
	# Parameters:
	#		args - a list of option/body pairs. Option is any of the legal
	#              option names for a menubar. The body part of the pair is
	#              a line oriented text definition of tag/value pairs where
	#			   the item associated with the tag will have the option set
	#              to the specified value.
	#
	# Results:
	#       none
	#
	# Side effects:
	#		The option values for items in the menubar are modified.
	#
	# ------------------------------------------------------------
	method menu.configure { args } {
		if { [llength ${args}] < 2 } {
			error "error: menu.configure - to few arguments."
		}
		foreach {opt settings} ${args} {
			set lines [split ${settings} \n]
			foreach line ${lines} {
				set line [string trim ${line}]
				if { ${line} eq "" || [string index ${line} 0] eq "#" } { continue }					
				lassign ${line} tag value
				my tag.configure group ${tag} ${opt} ${value}
			}
		}
		return
	}

	# ------------------------------------------------------------
	#
	# tag.configure --
	#
	#	Set any number of option/value pairs for one item in the mtree structure
	#   then update the visible rendering of the item.
	#
	# Parameters:
	#		wtop	- toplevel window containing the menubar item
	#		node	- mtree node to be configured
	#		args	- a list of option/value pairs
	#
	# Results:
	#       none
	#
	# Side effects:
	#		The option values of a menubar item are modified.
	#
	# ------------------------------------------------------------
	method tag.configure { wtop node args } {
		my variable mtree
		my variable installs
		my variable first_install

		if { [dict size ${installs}] == 0 } {
			error "error: tag.configure - '${mtree}' not installed."
		}
		if { [${mtree} exists ${node}] ne "" } {
			error "error: tag.configure - tag '${node}' not found"
		}

		# put option info in tree structure
		foreach {opt value} ${args} {
			switch -exact -- ${opt} {
			"-command" {
				set value [string trim ${value}]
				switch -exact -- [${mtree} key.get ${node} +type] {
				"radiogroup" {
					${mtree} key.set ${node} +command ${value}
				}
				"radiobutton" {
					# command is stored in 
				}
				default {
					${mtree} key.set ${node} +command ${value}
				}}
			}
			-state {
				if { ${first_install} ne "no"  } {
					${mtree} key.set ${node} ${opt} ${value}
				}
			}
			-sync {
				if { ${first_install} eq "yes"  } {
					${mtree} key.set ${node} +sync ${value}
				}
			}
			-bind {
				lassign ${value} uline accel sequence
				if { ${uline} eq "" || [string is integer ${uline}] } {
					${mtree} key.set ${node} -underline [expr {(${uline} eq "") ? -1 : ${uline}}]
				} else {
					error "tag.configure: underline value for tag (${node}) not positive integer."
				}
				${mtree} key.set ${node} -accelerator ${accel}
				${mtree} key.set ${node} +bind ${sequence}
			}
			default {
				# don't process these options
				if { ${opt} in {-accelerator -menu -offvalue -onvalue -value -variable -underline} } { continue }
				${mtree} key.set ${node} ${opt} ${value}
			}}
		}
		# update the node in all top level windows
		foreach wtop [dict keys ${installs}] {
			my RenderTag ${wtop} ${node}
		}
		return
	}

	# ------------------------------------------------------------
	#
	# IsHidden --
	#
	#	Determine if a node is visible.
	#
	# Parameters:
	#		node	- mtree node to be checked
	#
	# Results:
	#       returns 1 if the node is hiden else 0
	#
	# Side effects:
	#		none
	#
	# ------------------------------------------------------------
	method IsHidden { node } {
		my variable mtree
		if { [${mtree} key.exists ${node} +hide] && [${mtree} key.get ${node} +hide] == 1 } {
			return 1
		}
		foreach ancestor [${mtree} ancestors ${node}] {
			if { [${mtree} key.exists ${ancestor} +hide] && [${mtree} key.get ${ancestor} +hide] == 1 } {
				return 1
			}
		}
		return 0
	}

	# ------------------------------------------------------------
	#
	# RenderTag --
	#
	#	Perform Tk configure commands on a menubar item using the option
	#	settings found in the mtree structure.
	#
	# Parameters:
	#		wtop	- toplevel window containing the menubar item
	#		node	- mtree node for item
	#		varname	- (optional) shared variable name for a radiobutton group
	#
	# Results:
	#       none
	#
	# Side effects:
	#		The visible rendering of a menubar is updated.
	#
	# ------------------------------------------------------------
	method RenderTag { wtop node {varname {}} } {
		my variable mtree
		my variable installs
		my variable next_id
						
		# don't configure hidden items
		if { [my IsHidden ${node}] == 1 } {
			return
		}
		
		set parent_node [${mtree} parent ${node}]
		switch -exact -- [${mtree} key.get ${node} +type] {
		"cascade" {
			set parent_path [dict get ${installs} ${wtop} ${parent_node} +pathname]
			set name [${mtree} key.get ${node} -label]
			${parent_path} entryconfigure ${name} {*}[${mtree} key.getall ${node} -*]
		}
		"separator" {
		}
		"command" {
			set parent_path [dict get ${installs} ${wtop} ${parent_node} +pathname]
			set name [${mtree} key.get ${node} -label]
			if { [${mtree} key.get ${node} +command] eq ""  } {
				${parent_path} entryconfigure ${name} -command {}
			} else {
				${parent_path} entryconfigure ${name} -command [list [self object] commandCallback ${wtop} ${node}]
			}
			${parent_path} entryconfigure ${name} {*}[${mtree} key.getall ${node} -*]
			set sequence [${mtree} key.get ${node} +bind]
			if { ${sequence} eq "" } {
				bind ${wtop} <${sequence}> {}
			} else {
				bind ${wtop} <${sequence}> [list ${parent_path} invoke ${name}]
			}
		}
		"checkbutton" {
			set parent_path [dict get ${installs} ${wtop} ${parent_node} +pathname]
			set name [${mtree} key.get ${node} -label]
			if { [${mtree} key.get ${node} +command] eq ""  } {
				${parent_path} entryconfigure ${name} -command {}
			} else {
				${parent_path} entryconfigure ${name} -command [list [self object] commandCallback ${wtop} ${node}]
			}
			if { [${mtree} key.get ${node} +sync] eq "yes"  } {
				${parent_path} entryconfigure ${name} -variable [${mtree} key.get ${node} +variable]
			} else {
				incr next_id
				${parent_path} entryconfigure ${name} -variable [string map [list "%%" ${next_id}] [${mtree} key.get ${node} +variable]]
			}
			${parent_path} entryconfigure ${name} {*}[${mtree} key.getall ${node} -*]
			set sequence [${mtree} key.get ${node} +bind]
			if { ${sequence} eq "" } {
				bind ${wtop} <${sequence}> {}
			} else {
				bind ${wtop} <${sequence}> [list ${parent_path} invoke ${name}]
			}
		}
		"radiogroup" {
			if { [${mtree} key.get ${node} +sync] eq "yes"  } {
				set var [${mtree} key.get ${node} +variable]
				set ${var} [${mtree} key.get ${node} +initval]
			} else {
				incr next_id
				set var [string map [list "%%" ${next_id}] [${mtree} key.get ${node} +variable]]
				set ${var} [${mtree} key.get ${node} +initval]
			}
			foreach child [${mtree} children ${node}] {
				my RenderTag ${wtop} ${child} ${var}
			}
		}
		"radiobutton" {
			set parent_path [dict get ${installs} ${wtop} ${parent_node} +pathname]
			set name [${mtree} key.get ${node} -label]
			if { [${mtree} key.get ${parent_node} +command] eq ""  } {
				${parent_path} entryconfigure ${name} -command {}
			} else {
				${parent_path} entryconfigure ${name} -command [list [self object] commandCallback ${wtop} ${node}]
			}
			${parent_path} entryconfigure ${name} -variable ${varname}
			${parent_path} entryconfigure ${name} {*}[${mtree} key.getall ${node} -*]
		}
		"commandgroup" {
		}
		"groupcommand" {
			set parent_path [dict get ${installs} ${wtop} ${parent_node} +pathname]
			set name [${mtree} key.get ${node} -label]
			${parent_path} entryconfigure ${name} {*}[${mtree} key.getall ${node} -*]
			if { [${mtree} key.get ${node} +command] eq ""  } {
				${parent_path} entryconfigure ${name} -command {}
			} else {
				${parent_path} entryconfigure ${name} -command [list [self object] commandCallback ${wtop} ${node}]
			}
			set sequence [${mtree} key.get ${node} +bind]
			if { ${sequence} eq "" } {
				bind ${wtop} <${sequence}> {}
			} else {
				bind ${wtop} <${sequence}> [list ${parent_path} invoke ${name}]
			}
		}
		default {
		}}
		return
	}

	# ------------------------------------------------------------
	#
	# commandCallback --
	#
	#	Execute a command callback
	#
	# Parameters:
	#		wtop	- toplevel window containing the menubar item
	#                 that triggered the callback
	#		node	- mtree node for item
	#
	# Results:
	#       none
	#
	# Side effects:
	#		The callback code associated with node is executed in
	#       the context of the wtop window.
	#
	# ------------------------------------------------------------
	method commandCallback { wtop node } {
		my variable mtree
		my variable installs
		
		# set namespace for callbacks
		set parent [${mtree} parent ${node}]
		set parent_path [dict get ${installs} ${wtop} ${parent} +pathname]
		set name [${mtree} key.get ${node} -label]
		
		# don't execute callback if item is disabled
		set state [${parent_path} entrycget ${name} -state]
		if { ${state} eq "normal" } {
			switch -glob -- [${mtree} key.get ${node} +type] {
			"command" {
				set ns [dict get ${installs} ${wtop} ${parent} +callback_ns]
				set cmd [${mtree} key.get ${node} +command]
				if { [string equal -length 2 "::" ${cmd}] } {
					eval ${cmd} ${wtop}
				} else {
					namespace eval ${ns} ${cmd} ${wtop}
				}
			}		
			"groupcommand" {
				set ns [dict get ${installs} ${wtop} ${parent} +callback_ns]
				set cmd [${mtree} key.get ${node} +command]
				if { [string equal -length 2 "::" ${cmd}] } {
					#puts "eval $cmd"
					eval ${cmd} ${wtop}
				} else {
					#puts "namespace eval ${ns} ${cmd}"
					namespace eval ${ns} ${cmd} ${wtop}
				}
			}		
			"checkbutton" {
				set ns [dict get ${installs} ${wtop} ${parent} +callback_ns]
				set cmd [${mtree} key.get ${node} +command]
				set value [set [${parent_path} entrycget ${name} -variable]]
				if { [string equal -length 2 "::" ${cmd}] } {
					eval [list {*}${cmd} ${wtop} ${node} ${value}]
				} else {
					namespace eval ${ns} [list {*}${cmd} ${wtop} ${node} ${value}]
				}
			}		
			"radiobutton" {
				set ns [dict get ${installs} ${wtop} [${mtree} parent ${parent}] +callback_ns]
				set parent_node [${mtree} parent ${node}]
				set cmd [${mtree} key.get ${parent_node} +command]
				set cur_value [${mtree} key.get ${parent_node} +value]
				set value [set [${parent_path} entrycget ${name} -variable]]
				if { ${cur_value} eq ${value} } { return }
				${mtree} key.set ${parent_node} +value ${value}
				if { [string equal -length 2 "::" ${cmd}] } {
					eval [list {*}${cmd} ${wtop} ${parent_node} ${value}]
				} else {
					namespace eval ${ns} [list {*}${cmd} ${wtop} ${parent_node} ${value}]
				}
			}		
			default {
			}}
		}
		return
	}
			
	# ------------------------------------------------------------
	#
	# menu.show --
	#
	#	Render (i.e. show) a menubar item that is hidden.
	#
	# Parameters:
	#		node	- mtree node for item
	#
	# Results:
	#       none
	#
	# Side effects:
	#		The item is added to the menubar of all installed
	#       toplevel windows.
	#
	# ------------------------------------------------------------
	method menu.show { node } {
		my variable mtree
		my variable installs
		my variable first_install

		if { ${node} ni [${mtree} nodes] } {
			error "error: menu.show - tag '${node}' doesn't exist."
		}
		if { [${mtree} key.get ${node} +type] ne "cascade" } {
			error "error: menu.show - tag '${node}' not a menu."
		}
		if { ${first_install} eq "no" } { return }
		if { [${mtree} key.get ${node} +hide] == 1 } {
			${mtree} key.set ${node} +hide 0
			foreach wtop [dict keys ${installs}] {
				set parent_path [dict get ${installs} ${wtop} [${mtree} parent ${node}]  +pathname]
				my MenuInstall ${wtop} ${parent_path} ${node}
			}
		}
		return
	}
			
	# ------------------------------------------------------------
	#
	# menu.hide --
	#
	#	Hide a menubar item that is visible.
	#
	# Parameters:
	#		node	- mtree node for item
	#
	# Results:
	#       none
	#
	# Side effects:
	#		The item is removed from the menubar of all installed
	#       toplevel windows.
	#
	# ------------------------------------------------------------
	method menu.hide { node } {
		my variable mtree
		my variable installs
		my variable first_install

		if { ${node} ni [${mtree} nodes] } {
			error "error: menu.hide - tag '${node}' doesn't exist."
		}
		if { [${mtree} key.get ${node} +type] ne "cascade" } {
			error "error: menu.hide - tag '${node}' not a menu."
		}
		if { ${first_install} eq "no" } { return }
		if { [${mtree} key.get ${node} +hide] == 0 } {
			${mtree} key.set ${node} +hide 1
			foreach wtop [dict keys ${installs}] {
				set parent_path [dict get ${installs} ${wtop} [${mtree} parent ${node}]]
				my DeleteMenu ${wtop} ${node}
			}
		}
		return
	}

	# ------------------------------------------------------------
	#
	# DeleteMenu --
	#
	#	Delete a Tk menu.
	#
	# Parameters:
	#		wtop	- toplevel window
	#		node	- mtree node for item
	#
	# Results:
	#       none
	#
	# Side effects:
	#		The Tk menu defined by node is deleted from wtop.
	#
	# ------------------------------------------------------------
	method DeleteMenu { wtop node } {
		my variable mtree
		my variable installs
		
		set type [${mtree} key.get ${node} +type]
		switch -exact -- ${type} {
		"cascade" {
			# delete submenu entries
			set pathname [dict get ${installs} ${wtop} ${node} +pathname]
			my DeleteTearoff ${wtop} ${node}
			foreach child [${mtree} children ${node}] {
				my DeleteMenu ${wtop} ${child}
			}
			# delete the menu content
			${pathname} delete 0 end
			# delete menu
			set parent_path [dict get ${installs} ${wtop} [${mtree} parent ${node}] +pathname]
			set name [${mtree} key.get ${node} -label]
			${parent_path} delete ${name}
		}
		default {
		}}
		return
	}

	# ===== GROUP COMMANDS ====================================
	
	# ------------------------------------------------------------
	#
	# group.add --
	#
	#	Add a command definition to a group and
	#	append the command to the end of the group menu.
	#
	# Parameters:
	#		parent	- parent node in mtree
	#		args	- list of items that define the command
	#				  (i.e. name cmd accel sequence state)
	#
	# Results:
	#       Returns a 0 on success or 1 on failure.
	#
	# Side effects:
	#		A command definition is added to the commandgroup and
	#		the new command is displayed (i.e. rendered) on all
	#		installed toplevel windows.
	#
	# ------------------------------------------------------------
	method group.add { parent args } {
		my variable mtree
		my variable installs
		
		if { [${mtree} key.get ${parent} +type] ne "commandgroup"  } {
			#puts stderr "group.add: tag (${parent}) not a command group"
			return 1
		}
		
		lassign ${args} name cmd accel sequence state
 
		# don't add item if name already exists
		if { ${name} in [${mtree} children ${parent}] } {
			#puts stderr "warning: command '${name}' already used in command group '${parent}'"
			return 1
		}

		# add command to tree
		my TagCheck ${name}
		${mtree} insert ${parent} end ${name}
		${mtree} key.set ${name} +type groupcommand				
		set opts [dict create]
		dict set opts -label ${name}
		dict set opts -underline 0
		if { ${state} eq "" || ${state} ni {normal disabled active} } {
			dict set opts -state normal
		} else {
			dict set opts -state ${state}
		}
		if { ${cmd} eq "" } {
			dict set opts -state disabled
		}
		dict set opts +command ${cmd}
		if { ${accel} ne "" } {
			dict set opts -accelerator ${accel}
		}
		if { ${sequence} ne ""  } {
			dict set opts +bind ${sequence}
		}
		dict for {opt val} ${opts} {
			${mtree} key.set ${name} ${opt} ${val}
		}
		
		# update the node in all top level windows
		foreach wtop [dict keys ${installs}] {
			if { [my IsHidden ${parent}] != 1 } {
				set grandparent_node [${mtree} parent ${parent}]
				set grandparent_path [dict get ${installs} ${wtop} ${grandparent_node} +pathname]
				if { [catch {${grandparent_path} index ${name}} msg] } {
					${grandparent_path} add command -label ${name}
				}
			}
			my RenderTag ${wtop} ${name}
		}
		return 0
	}

	# ------------------------------------------------------------
	#
	# group.entries --
	#
	#	Return a list of all entries in a group.
	#
	# Parameters:
	#		parent	- the mtree commandgroup node of interest
	#
	# Results:
	#       Returns a list of mtree node names or 1 if parent isn't
	#		a commandgroup node.
	#
	# Side effects:
	#		none
	#
	# ------------------------------------------------------------
	method group.entries { parent } {
		my variable mtree
		my variable installs
		
		if { [${mtree} key.get ${parent} +type] ne "commandgroup"  } {
			#puts stderr "group.add: tag (${parent}) not a command group"
			return 1
		}

		return [${mtree} children ${parent}]
	}
	
	# ------------------------------------------------------------
	#
	# group.delete --
	#
	#	Delete a command from a commandgroup.
	#
	# Parameters:
	#		parent	- the mtree commandgroup node of interest
	#		name	- name of item to be removed from the commandgroup
	#
	# Results:
	#       Returns 0 on success or 1 on failure.
	#
	# Side effects:
	#		none
	#
	# ------------------------------------------------------------
	method group.delete { parent name } {
		my variable mtree
		my variable installs
		
		if { [${mtree} key.get ${parent} +type] ne "commandgroup"  } {
			#puts stderr "group.add: tag (${parent}) not a command group"
			return 1
		}

		# don't delete item if name doesn't exists
		if { ${name} ni [${mtree} children ${parent}] } {
			#puts stderr "warning: command '${name}' not found in command group '${parent}'"
			return 1
		}
		
		# update the node in all top level windows
		foreach wtop [dict keys ${installs}] {
			# delete menu item
			set grandparent_node [${mtree} parent ${parent}]
			if { [my IsHidden ${grandparent_node}] != 1 } {
				set grandparent_path [dict get ${installs} ${wtop} ${grandparent_node} +pathname]
				if { [catch {${grandparent_path} index ${name}} idx] } {
					#puts stderr "warning: command '${name}' not found in command group '${parent}'"
					return 1
				}
				${grandparent_path} delete ${idx}
			}
			# delete binding, if one exists
			if { [${mtree} key.exists ${name} +bind] } {
 				set sequence [${mtree} key.get ${name} +bind]
				bind ${wtop} <${sequence}> {}
			}
			
		}
		# delete the node from the menu tree
		${mtree} delete ${name}
		return 0
	}
	
	# ------------------------------------------------------------
	#
	# group.move --
	#
	#	Move a group command up/down one location within a group menu.
	#
	# Parameters:
	#		direction	- oneof: up, down
	#		parent		- the mtree commandgroup node of interest
	#		name		- name of item to be moved
	#
	# Results:
	#       Returns 0 on success or 1 on failure.
	#
	# Side effects:
	#		A menu items is move up or down on all installed menubar. 
	#
	# ------------------------------------------------------------
	method group.move { direction parent name } {
		my variable mtree
		my variable installs
		
		if { [${mtree} key.get ${parent} +type] ne "commandgroup"  } {
			#puts stderr "group.add: tag (${parent}) not a command group"
			return 1
		}

		# don't delete item if name doesn't exists
		if { ${name} ni [${mtree} children ${parent}] } {
			#puts stderr "warning: command '${name}' not found in command group '${parent}'"
			return 1
		}
		
		if { ${direction} eq "up" } {
			set neighbor "previous"
			set sign "-"
		} elseif { ${direction} eq "down" } {
			set neighbor "next"
			set sign "+"
		} else {
			return 1
		}
		
		set node ${name}
		set neighbor_node [${mtree} ${neighbor} ${node}]
		if { ${neighbor_node} eq "" } {
			# item is at top/bottom of list
			return 0
		}
		# update mtree structure
		${mtree} swap ${name} ${neighbor_node}
		# get menu index information for the move
		set grandparent_node [${mtree} parent ${parent}]
		# update the item in all top level windows
		foreach wtop [dict keys ${installs}] {
			if { [my IsHidden ${grandparent_node}] != 1 } {
				set grandparent_path [dict get ${installs} ${wtop} ${grandparent_node} +pathname]
				if { ![catch {${grandparent_path} index ${name}} old_idx] } {
					# compute new command location within group menu
					set new_idx [expr ${old_idx}${sign}1]		
					# remove the command from its current location
					${grandparent_path} delete ${old_idx}
					# insert command in the new location
				    ${grandparent_path} insert ${new_idx} command -label "${name}"
					my RenderTag ${wtop} ${name}
				}
			}
		}
		return 0
	}

	# ------------------------------------------------------------
	#
	# group.configure --
	#
	#	Modify the configuration of a command in a commandgroup.
	#
	# Parameters:
	#		parent	- the mtree commandgroup node of interest
	#		name	- name of item to be moved
	#		args	- a list of option/value pairs used to configure
	#				  the named commandgroup item.
	#
	# Results:
	#       Returns 0 on success or 1 on failure.
	#
	# Side effects:
	#		A menu items is move up or down on all installed menubar. 
	#
	# ------------------------------------------------------------
	method group.configure { parent name args } {
		my variable mtree
		my variable first_install
		my variable installs
		
		if { [${mtree} key.get ${parent} +type] ne "commandgroup"  } {
			#puts stderr "group.configure: tag (${parent}) not a command group"
			return 1
		}
 
		# don't configure item if it doesn't exists
		if { ${name} ni [${mtree} children ${parent}] } {
			#puts stderr "group.configure: command '${name}' doesn't exist in command group '${parent}'"
			return 1
		}
		
		# put option info in tree structure
		foreach {opt value} ${args} {
			switch -exact -- ${opt} {
			"-command" {
				set value [string trim ${value}]
				${mtree} key.set ${name} +command ${value}
			}
			-state {
				if { ${first_install} ne "no"  } {
					${mtree} key.set ${name} ${opt} ${value}
				}
			}
			-sync {
				if { ${first_install} eq "yes"  } {
					${mtree} key.set ${name} +sync ${value}
				}
			}
			-bind {
				lassign ${value} uline accel sequence
				if { ${uline} eq "" || [string is integer ${uline}] } {
					${mtree} key.set ${name} -underline [expr {(${uline} eq "") ? -1 : ${uline}}]
				} else {
					error "tag.configure: underline value for tag (${node}) not positive integer."
				}
				${mtree} key.set ${name} -accelerator ${accel}
				${mtree} key.set ${name} +bind ${sequence}
			}
			default {
				${mtree} key.set ${name} ${opt} ${value}
			}}
		}
		# update the node in all top level windows
		foreach wtop [dict keys ${installs}] {
			my RenderTag ${wtop} ${name}
		}
		return 0
	}

	# ------------------------------------------------------------
	#
	# group.serialize --
	#
	#	Create a serialized representation of a commandgroup.
	#
	# Parameters:
	#		node	- node name of the commandgroup
	#
	# Results:
	#       Returns a string serialization or a 1 on failure.
	#
	# Side effects:
	#		none 
	#
	# ------------------------------------------------------------
	method group.serialize { node } {
		my variable mtree
		
		if { [${mtree} key.get ${node} +type] ne "commandgroup"  } {
			#puts stderr "group.serialize: tag (${parent}) not a command group"
			return 1
		}
		
		return [${mtree} serialize ${node}]
	}

	# ------------------------------------------------------------
	#
	# group.deserialize --
	#
	#	Replace the items in a commandgroup from the definitions
	#	found in a serialized stream
	#
	# Parameters:
	#		node	- node name of the commandgroup
	#		stream	- a commandgroup serialization string
	#
	# Results:
	#       Returns 0 on success or 1 on failure
	#
	# Side effects:
	#		All the items in the commandgroup are deleted and replaced
	#		with new items defined by the serialization string. 
	#
	# ------------------------------------------------------------
	method group.deserialize { node stream } {
		my variable mtree
		my variable installs
		
		if { [${mtree} key.get ${node} +type] ne "commandgroup"  } {
			#puts stderr "group.serialize: tag (${parent}) not a command group"
			return 1
		}
		# delete the existing entries for node
		foreach name [my group.entries ${node}] {
			my group.delete ${node} ${name}
		}

		# replace the node from the serialized stream
		${mtree} deserialize ${node} ${stream}
		
		set parent ${node}
		# update the node in all top level windows
		foreach wtop [dict keys ${installs}] {
			if { [my IsHidden ${parent}] != 1 } {
				set grandparent_node [${mtree} parent ${parent}]
				set grandparent_path [dict get ${installs} ${wtop} ${grandparent_node} +pathname]
				foreach name [${mtree} children ${parent}] {
					if { [catch {${grandparent_path} index ${name}} msg] } {
						${grandparent_path} add command -label ${name}
					}
					my RenderTag ${wtop} ${name}
				}
			}
		}
		return 0
	}
}

