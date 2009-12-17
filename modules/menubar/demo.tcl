#!/bin/sh
# the next line restarts this file using a tcl shell \
exec tclkit "$0" -- ${1+"$@"}

package require starkit
starkit::startup

package require Tcl 8.6
package require Tk

package require TclOO

lappend auto_path .

package require menubar
package provide AppMain 0.5

# --
# 
namespace eval Main {

	variable wid
	variable mbar
	variable wid

	proc main { } {
		variable mbar
		variable wid
		set wid 0
		
		wm withdraw .

		##
		## Create a menu bar definition
		##

		# create an instance of the menubar class
		set mbar [menubar new \
			-borderwidth 4 \
			-relief groove  \
			-foreground black \
			-background tan \
			-cursor dot \
			-activebackground red \
			-activeforeground white \
			]

		# define the menu tree for the instance
		${mbar} define {
			File M:file {
			#   Label				 Type	Tag Name(s)	
			#   ----------------- 	 ----	---------
				"New Window"	 	 C 		new
				--					 S 		s0
				"Show Macros Menu"	 C 		mshow
				"Hide Macros Menu"   C 		mhide
				"Toggle Paste State" C 		paste_state
				--					 S 		s1
				Close                C      close
				--					 S 		s2
				Exit			  	 C		exit
			}
			Edit M:items+ {
			#   Label				Type	Tag Name(s)	
			#   ----------------- 	----	---------
				"Cut"				C 		cut
				"Copy"				C 		copy
				"Paste"				C 		paste
				--					S 		s3
				"Options Sync" M:opts {
					"CheckButtons" M:chx+ {
						Apple		X 		apple+
						Bread		X 		bread
						Coffee		X 		coffee
						Donut		X 		donut+
						Eggs		X 		eggs
						}
					"RadioButtons" M:btn+ {
						"Red"		R 		color
						"Green"		R 		color+
						"Blue"		R 		color
						"~!@#%^&*()_+{}: <>?`-=;',./" R color
						}
				}
				"Options NoSync" M:opts2 {
					"CheckButtons" M:chx2+ {
						Obtuse  	X		obtuse
						Acute		X		acute+
						Right		X		right
						}
					"RadioButtons" M:btn2+ {
						"Magenta"		R 	ryb+
						"Yellow"		R 	ryb
						"Cyan"			R 	ryb
						}
				}
			}
 			Macros M:macros+ {
 			#	Label				Type	Tag Name(s) 
 			#	-----------------	----	---------
				"Add Item" 			C		item_add
				"Delete Item" 		C		item_delete
				"Add MARK Item" 	C		mark_add
				"Move MARK Up"  	C		mark_up
				"Move MARK Down"	C		mark_down
				"Delete MARK"		C		mark_del
				"Macros"		  	C 		macro_entries
				"Save Macros"  		C		serialize
				"Restore Macros" 	C		deserialize
				--COMMANDGROUP--	G		macro
 			}
			Help M:help {
			#   Label				Type	Tag Name(s)	
			#   ----------------- 	----	---------
				About			  	C 		about
				--					S 		s4
				Clear			  	C 		clear
				"Load Debugging"	C		load_debug_code
				"Test tag.cget"		C 		testcget
				"Debug Tree"		C 		debug_tree
				"Debug Nodes"		C 		debug_nodes
				"Debug Installs"	C 		debug_installs
				"ptree"				C 		ptree
				"pnodes"			C 		pnodes
				"pkeys"				C 		pkeys
			}
		}

		NewWindow
	}
	
	proc NewWindow { args } {
		variable mbar
		variable wid
		
		set w ".top${wid}"
		incr wid
		
		Gui new ${wid} ${w} ${mbar}
	}

}

# --
# 
oo::class create Gui {

	# ----------------------------------------
	# Create a toplevel with a menu bar
	constructor { wid w menubar } {
		my variable mbar
		my variable tout
		my variable wtop
		
		set mbar ${menubar}

		## 
		## Install the menu bar definition in a toplevel
		##
		
		set wtop ${w}
		
		if { ${wtop} eq "." } {
			set tout [text .t -width 25 -height 12]
			error "warning: putting menubar in toplevel '.'"
		} else {
			toplevel ${wtop}
			wm withdraw ${wtop}
			set tout [text ${wtop}.t -width 25 -height 12]
		}
		pack ${tout} -expand 1 -fill both

		## 
		## Install & Configure the menu bar
		##
		${mbar} install ${wtop} {

			# Create tags for this windows text widget. They will be 
			# used by the menubar callbacks to direct output to the
			# text widget.
			${mbar} tag.add tout ${tout}
			${mbar} tag.add gui [self object]

			${mbar} menu.configure -command {
				# file menu
				new				{::Main::NewWindow}
				mshow			{my mShow}
				mhide			{my mHide}
				paste_state		{my TogglePasteState}
				close			{my Close}
				exit			{my Exit}
				# Item menu
				cut				{my Edit cut}
				copy			{my Edit copy}
				paste			{my Edit paste}
				# boolean menu
				apple	     	{my BoolToggle}
				bread	     	{my BoolToggle}
				coffee	     	{my BoolToggle}
				donut	     	{my BoolToggle}
				eggs	     	{my BoolToggle}
				obtuse	     	{my BoolToggle}
				acute	     	{my BoolToggle}
				right	     	{my BoolToggle}
				# radio menu
				color	     	{my RadioToggle}
				ryb		     	{my RadioToggle}
				# Help menu
				about			{my About}
				clear			{my Clear}
				load_debug_code	{my LoadDebugCode}
				testcget		{my TestCget}
				debug_tree		{my Debug tree}
				debug_nodes		{my Debug nodes}
				debug_installs	{my Debug installs}
				ptree			{my print tree}
				pnodes			{my print nodes}
				pkeys			{my print keys}
			} -state {
				mhide	    	disabled
				paste	    	disabled
			} -sync {
				obtuse			no
				acute			no
				right			no
				ryb				no
			} -bind {
				exit		{1 Cntl+Q  Control-Key-q}
				cut			{2 Cntl+X  Control-Key-x}
				copy		{0 Cntl+C  Control-Key-c}
				paste		{0 Cntl+V  Control-Key-v}

				apple		{0 Cntl+A  Control-Key-a}
				bread		{0 Cntl+B  Control-Key-b}

				about		0
				debug_tree	{0 {}	  Control-Key-d}
				clear		{}
			} -background {
				opts   tan
				chx    tan
				eggs   tan
				exit red
				testcget 		lightgreen
				debug_tree 		pink
				debug_nodes 	pink
				debug_installs 	pink
				ptree  			pink
				pnodes  		pink
				pkeys  			pink
			} -foreground {
				exit white
			}

			# change the namespace for commands associated the 
			# 'macros' commands and 'macro' command group
			${mbar} menu.namespace macros ::Macros
			${mbar} menu.namespace macro  ::Macros

 			# configure the macros menu
 			${mbar} menu.configure -command {
 				item_add		{NewItem}
 				item_delete		{DeleteItem}
 				mark_add		{Mark add}
 				mark_up			{Mark up}
 				mark_down		{Mark down}
 				mark_del		{Mark delete}
 				macro_entries	{Macros}
 				serialize		{Serialize}
 				deserialize		{Deserialize}
			} -bind {
				item_add	{0 Cntl+I  Control-Key-i}
				mark_add	{0 Cntl+m  Control-Key-m}
				mark_up		{0 Cntl+U  Control-Key-u}
				mark_down	{0 Cntl+J  Control-Key-j}
				mark_del	{0 Cntl+K  Control-Key-k}
 			}
			
			# initally hide the macros menu
			${mbar} menu.hide macros
		}

		##
		## Your GUI code goes here
		##		
		
		my pout "Demo started ..."

		wm minsize ${wtop} 300 300
		wm geometry ${wtop} +[expr ${wid}*20]+[expr ${wid}*20]
		wm protocol ${wtop} WM_DELETE_WINDOW [list [self object] closeWindow ${wtop}]
		wm title ${wtop} "Demo App"
		wm focusmodel ${wtop} active
		wm deiconify ${wtop}

		#my debug
		
		return
	}
	
	method pout { txt } {
		my variable wtop
		my variable mbar
		set tout [${mbar} tag.cget ${wtop} tout]
		${tout} insert end "${txt}\n"
	}

	method mShow { args } {
		my variable mbar
		${mbar} menu.show macros
		${mbar} menu.configure -state {
			mshow		disabled
			mhide		normal
		}
	}

	method mHide { args } {
		my variable mbar
		${mbar} menu.hide macros
		${mbar} menu.configure -state {
			mshow		normal
			mhide		disabled
		}
	}

	method closeWindow { w } {
		my variable mbar
		destroy ${w}
		# check to see if we closed the last window
		if { [winfo children .] eq ""  } {
			my Exit
		}
	}

	method Close { args } {
		my closeWindow {*}${args}
	}

	method Exit { args } {
		puts "Goodbye"
		exit
	}

	method Debug { args } {
		my variable wtop
		my variable mbar
		lassign ${args} type
		my Clear
		foreach line [${mbar} debug ${type}] {
			my pout ${line}
		}
	}
	method Clear { args } {
		my variable wtop
		my variable mbar
		set tout [${mbar} tag.cget ${wtop} tout]
		${tout} delete 0.0 end
	}
	method LoadDebugCode { args } {
		my variable wtop
		my variable mbar
		${mbar} loadDebugMethod
		${mbar} tag.configure ${wtop} debug_tree -background lightgreen
		${mbar} tag.configure ${wtop} debug_nodes -background lightgreen
		${mbar} tag.configure ${wtop} debug_installs -background lightgreen
		${mbar} tag.configure ${wtop} ptree -background lightgreen
		${mbar} tag.configure ${wtop} pnodes -background lightgreen
		${mbar} tag.configure ${wtop} pkeys -background lightgreen
	}
	method TestCget { args } {
		my variable wtop
		my variable mbar
		my Clear
		my pout "user define tag: tout = [${mbar} tag.cget ${wtop} tout]"
		my pout "Command tag: exit -background = [${mbar} tag.cget ${wtop} exit -background]"
		my pout "Checkbutton tag: apple -state = [${mbar} tag.cget ${wtop} apple -state]"
		my pout "Radiobutton tag: color -state = [${mbar} tag.cget ${wtop} color -state]"
		my pout "Cascade tag: chx -background = [${mbar} tag.cget ${wtop} chx -background]"
	}

	method Edit { args } {
		my pout "Edit: [join ${args} {, }]"
	}

	method TogglePasteState { args } {
		my variable mbar
		my pout "TogglePasteState: [join ${args} {, }]"
		lassign ${args} wtop
		set value [${mbar} tag.cget ${wtop} paste -state]
		if { [${mbar} tag.cget ${wtop} paste -state] eq "normal" } {
			${mbar} tag.configure ${wtop} paste -state "disabled" -background {}
		} else {
			${mbar} tag.configure ${wtop} paste -state "normal" -background green
		}
	}

	method BoolToggle { args } {
		my pout "BoolToggle: [join ${args} {, }]"
	}

	method RadioToggle { args } {
		my pout "RadioToggle: [join ${args} {, }]"
	}

	method About { args } {
		my pout "MenuBar Demo 1.0"
	}

	method print { args } {
		my variable mbar
		lassign ${args} type wtop
		${mbar} print ${type}
	}
}

# --
# 
namespace eval Macros {

	variable next 0
	variable stream
	variable stream_next

	proc Mark { args } {
		set mbar $::Main::mbar
		
		lassign ${args} action wtop
		set gui [${mbar} tag.cget ${wtop} gui]

		set errno 0
		switch -exact -- ${action} {
		"add"	 {
			set errno [${mbar} group.add macro MARK {Mout "MARK"} Cntl+0 Control-Key-0]
 			if { ${errno} != 0 } {
				${gui} pout "warning: MARK already exists"
 			} else {
 				${mbar} group.configure macro MARK \
 					-background tan \
					-foreground white
 			}
		}
		"delete" {
			set errno [${mbar} group.delete macro MARK]
			if { ${errno} != 0 } {
				${gui} pout  "warning: MARK not found"
			}
		}
		"up"	 {
			set errno [${mbar} group.move up macro MARK]
 			if { ${errno} != 0 } {
				${gui} pout "warning: MARK move up failed"
 			}
		}
		"down"	 {
			set errno [${mbar} group.move down macro MARK]
 			if { ${errno} != 0 } {
				${gui} pout "warning: MARK move down failed"
 			}
		}}
	}
	
	proc NewItem { args } {
		variable next
		if { ${next} == 9 } { return }
		incr next
		set mbar $::Main::mbar
		set errno [${mbar} group.add macro Item${next} "Mout item${next}" Cntl+${next} Control-Key-${next}]
 		if { ${errno} != 0 } {
			lassign ${args} wtop
			set gui [${mbar} tag.cget ${wtop} gui]
			${gui} pout "warning: Item${next} already exists"
 		}	
	}
	
	proc DeleteItem { args } {
		variable next
		set mbar $::Main::mbar
		set item "Item${next}"
		${mbar} group.delete macro ${item}
		if { ${next} > 0 } {
			incr next -1
		}
	}

	proc Macros { args } {
		set mbar $::Main::mbar
		puts "---"
		puts [${mbar} group.entries macro]
	}

	proc Serialize { args } {
		variable next
		variable stream
		variable stream_next
		set mbar $::Main::mbar
		set stream [${mbar} group.serialize macro]
		set stream_next ${next}
		puts "---"
		puts ${stream}
	}

	proc Deserialize { args } {
		variable next
		variable stream
		variable stream_next
		set next ${stream_next}
		set mbar $::Main::mbar
		${mbar} group.deserialize macro ${stream}
	}

	proc Mout { args } {
		set mbar $::Main::mbar
		lassign ${args} action wtop
		set gui [${mbar} tag.cget ${wtop} gui]
		${gui} pout  "Mout: [join ${args} {, }]"
	}
}


Main::main
