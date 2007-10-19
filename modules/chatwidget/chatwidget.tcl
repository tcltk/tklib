# chatwidget.tcl --
#
#	This package provides a composite widget suitable for use in chat
#	applications. A number of panes managed by panedwidgets are available
#	for displaying user names, chat text and for entering new comments.
#	The main display area makes use of text widget peers to enable a split
#	view for history or searching.
#
# Copyright (C) 2007 Pat Thoyts <patthoyts@users.sourceforge.net>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# RCS: @(#) $Id: chatwidget.tcl,v 1.1 2007/10/19 11:41:39 patthoyts Exp $

package require Tk 8.5

namespace eval chatwidget {
    variable version 1.0.0

    namespace export chatwidget

    ttk::style layout ChatwidgetFrame {
        Entry.field -sticky news -border 1 -children {
            ChatwidgetFrame.padding -sticky news
        }
    }
}

proc chatwidget::chatwidget {w args} {
    Create $w
    interp hide {} $w
    interp alias {} $w {} [namespace origin WidgetProc] $w
    return $w
}

proc chatwidget::WidgetProc {self cmd args} {
    switch -- $cmd {
        hook {
            if {[llength $args] < 2} {
                return -code error "wrong \# args: should be\
                    \"$self hook add|remove type script ?priority?\""
            }
            return [uplevel 1 [list [namespace origin Hook] $self] $args]
        }
        message {
            return [uplevel 1 [list [namespace origin Message] $self] $args]
        }
        name {
            return [uplevel 1 [list [namespace origin Name] $self] $args]
        }
        topic {
            return [uplevel 1 [list [namespace origin Topic] $self] $args]
        }
        names {
            return [uplevel 1 [list [namespace origin Names] $self] $args]
        }
        entry {
            return [uplevel 1 [list [namespace origin Entry] $self] $args]
        }
        default { return [uplevel 1 [list $self.text $cmd] $args] }
    }
    return
}

proc chatwidget::Topic {self cmd args} {
    upvar #0 [namespace current]::$self state
    switch -exact -- $cmd {
        show { grid $self.topic -row 0 -column 0 -sticky new }
        hide { grid forget $self.topic }
        set  { set state(topic) [lindex $args 0] }
        default {
            return -code error "bad option \"$cmd\":\
                must be show, hide or set"
        }
    }
}

proc chatwidget::Names {self args} {
    if {[llength $args] == 0} {
        return $self.names
    }
    if {[llength $args] == 1 && [lindex $args 0] eq "hide"} {
        return [$self.inner forget $self.namesf]
    }
    if {[llength $args] == 1 && [lindex $args 0] eq "show"} {
        return [$self.inner add $self.namesf]
    }
    return [uplevel 1 [list $self.names] $args] 
}

proc chatwidget::Entry {self args} {
    if {[llength $args] == 0} {
        return $self.entry
    }
    if {[llength $args] == 1 && [lindex $args 0] eq "text"} {
        return [$self.entry get 1.0 end-1c]
    }
    return [uplevel 1 [list $self.entry] $args]
}

proc chatwidget::Message {self text args} {
    upvar #0 [namespace current]::$self state

    set mark end
    set type normal
    set nick Unknown
    set time [clock seconds]
    set tags {}

    while {[string match -* [set option [lindex $args 0]]]} {
        switch -exact -- $option {
            -nick { set nick [Pop args 1] }
            -time { set time [Pop args 1] }
            -type { set type [Pop args 1] }
            -mark { set type [Pop args 1] }
            -tags { set tags [Pop args 1] }
            default {
                return -code error "unknown option \"$option\""
            }
        }
        Pop args
    }

    if {[catch {Hook $self run message $text \
                    -mark $mark -type $type -nick $nick \
                    -time $time -tags $tags}] == 3} then {
        return
    }

    if {$type ne "system"} { lappend tags NICK-$nick }
    lappend tags TYPE-$type
    $self.text configure -state normal
    set ts [clock format $time -format "\[%H:%M\]\t"]
    $self.text insert $mark $ts [concat BOOKMARK STAMP $tags]
    if {$type eq "action"} {
        $self.text insert $mark "   * $nick " [concat BOOKMARK NICK $tags]
        lappend tags ACTION
    } elseif {$type eq "system"} {
    } else {
        $self.text insert $mark "$nick\t" [concat BOOKMARK NICK $tags]
    }
    if {$type ne "system"} { lappend tags MSG NICK-$nick }
    $self.text insert $mark $text $tags
    $self.text insert $mark "\n" $tags
    $self.text configure -state disabled
    if {$state(autoscroll)} {
        $self.text see end
    }
    return
}

# $w name add ericthered -group admin -color red
# state(names) {{pat -color red -group admin -thing wilf} {eric ....}}
proc chatwidget::Name {self cmd args} {
    upvar #0 [namespace current]::$self state
    switch -exact -- $cmd {
        list {
            switch -exact -- [lindex $args 0] {
                -full {
                    return $state(names)
                }
                default {
                    foreach item $state(names) { lappend r [lindex $item 0] }
                    return $r
                }
            }
        }
        add {
            if {[llength $args] < 1 || ([llength $args] % 2) != 1} {
                return -code error "wrong # args: should be\
                    \"add nick ?-group group ...?\""
            }
            set nick [lindex $args 0]
            if {[set ndx [lsearch -exact -index 0 $state(names) $nick]] == -1} {
                array set opts {-group {} -colour black}
                array set opts [lrange $args 1 end]
                lappend state(names) [linsert [array get opts] 0 $nick]
            } else {
                array set opts [lrange [lindex $state(names) $ndx] 1 end]
                array set opts [lrange $args 1 end]
                lset state(names) $ndx [linsert [array get opts] 0 $nick]
            }
            UpdateNames $self
        }
        delete {
            if {[llength $args] != 1} {
                return -code error "wrong # args: should be \"delete nick\""
            }
            set nick [lindex $args 0]
            if {[set ndx [lsearch -exact -index 0 $state(names) $nick]] != -1} {
                set state(names) [lreplace $state(names) $ndx $ndx]
                UpdateNames $self
            }
        }
        default {
            return -code error "bad name option \"$cmd\":\
                must be list, names, add or delete"
        }
    }
}

proc chatwidget::UpdateNames {self} {
    upvar #0 [namespace current]::$self state
    
    foreach tagname [lsearch -all -inline [$self.names tag names] NICK-*] {
        $self.names tag delete $tagname
    }
    foreach tagname [lsearch -all -inline [$self.names tag names] GROUP-*] {
        $self.names tag delete $tagname
    }

    $self.names configure -state normal
    $self.names delete 1.0 end
    array set groups {}
    foreach item $state(names) {
        set group {}
        if {[set ndx [lsearch $item -group]] != -1} {
            set group [lindex $item [incr ndx]]
        }
        lappend groups($group) [lindex $item 0]
    }

    foreach group [array names groups] {
        Hook $self run names_group $group
        $self.names insert end "$group\n" [list SUBTITLE GROUP-$group]
        foreach nick [lsort -dictionary $groups($group)] {
            $self.names tag configure NICK-$nick
            unset -nocomplain opts ; array set opts {}
            if {[set ndx [lsearch -exact -index 0 $state(names) $nick]] != -1} {
                array set opts [lrange [lindex $state(names) $ndx] 1 end]
                if {[info exists opts(-color)]} {
                    $self.names tag configure NICK-$nick -foreground $opts(-color)
                    $self.text tag configure NICK-$nick -foreground $opts(-color)
                }
                eval [linsert [lindex $state(names) $ndx] 0 Hook $self run names_nick]
            }
            $self.names insert end $nick\n [list NICK NICK-$nick GROUP-$group]
        }
    }

    $self.names configure -state disabled
}

proc chatwidget::Pop {varname {nth 0}} {
    upvar $varname args
    set r [lindex $args $nth]
    set args [lreplace $args $nth $nth]
    return $r
}

proc chatwidget::Hook {self do type args} {
    upvar #0 [namespace current]::$self state
    set valid {message post names_group names_nick}
    if {[lsearch -exact $valid $type] == -1} {
        return -code error "unknown hook type \"$type\":\
                must be one of [join $valid ,]"
    }
    switch -exact -- $do {
	add {
            if {[llength $args] < 1 || [llength $args] > 2} {
                return -code error "wrong # args: should be \"add hook cmd ?priority?\""
            }
            foreach {cmd pri} $args break
            if {$pri eq {}} { set pri 50 }
            lappend state(hook,$type) [list $cmd $pri]
            set state(hook,$type) [lsort -real -index 1 [lsort -unique $state(hook,$type)]]
	}
        remove {
            if {[llength $args] != 1} {
                return -code error "wrong # args: should be \"remove hook cmd\""
            }
            if {![info exists state(hook,$type)]} { return }
            for {set ndx 0} {$ndx < [llength $state(hook,$type)]} {incr ndx} {
                set item [lindex $state(hook,$type) $ndx]
                if {[lindex $item 0] eq [lindex $args 0]} {
                    set state(hook,$type) [lreplace $state(hook,$type) $ndx $ndx]
                    break
                }
            }
            set state(hook,$type)
        }
        run {
            if {![info exists state(hook,$type)]} { return }
            set res ""
            foreach item $state(hook,$type) {
                foreach {cmd pri} $item break
                set code [catch {eval $cmd $args} err]
                if {$code} {
                    ::bgerror "error running \"$type\" hook: $err"
                    break
                } else {
                    lappend res $err
                }
            }
            return $res
        }
        list {
            if {[info exists state(hook,$type)]} {
                return $state(hook,$type)
            }
        }
	default {
	    return -code error "unknown hook action \"$do\":\
                must be add, remove, list or run"
	}
    }
}

proc chatwidget::Grid {w {row 0} {column 0}} {
    grid rowconfigure $w $row -weight 1
    grid columnconfigure $w $column -weight 1
}

proc chatwidget::Create {self} {
    upvar #0 [set State [namespace current]::$self] state
    set state(history) {}
    set state(current) 0
    set state(autoscroll) 1
    set state(names) {}

    if {[lsearch -exact [font names] ChatwidgetFont] == -1} {
        eval [list font create ChatwidgetFont] [font configure TkTextFont]
        eval [list font create ChatwidgetBoldFont] [font configure ChatwidgetFont] -weight bold
    }

    set f [ttk::frame $self]
    set outer [ttk::panedwindow $f.outer -orient vertical]
    set inner [ttk::panedwindow $f.inner -orient horizontal]

    # Create a topic/subject header
    ttk::frame $f.topic
    ttk::label $f.topic.label -anchor w -text Topic
    #ttk::label $f.topic.text -anchor w -relief solid -textvariable [set State](topic)
    ttk::entry $f.topic.text -state disabled -textvariable [set State](topic)
    grid $f.topic.label $f.topic.text -sticky new -pady {2 0} -padx 1
    Grid $f.topic 0 1

    # Create the usernames scrolled text
    ttk::frame $f.namesf -style ChatwidgetFrame
    text $f.names -borderwidth 0 -relief flat -font ChatwidgetFont \
        -yscrollcommand [list [namespace origin AutoScrollSet] $self $f.namesvs $f.namesf 0]
    ttk::scrollbar $f.namesvs -command [list $f.names yview]
    $f.names configure -width 10 -height 10 -state disabled
    bindtags $f.names [linsert [bindtags $f.names] 1 ChatwidgetNames]
    grid $f.names $f.namesvs -in $f.namesf -sticky news -padx 1 -pady 1
    Grid $f.namesf 0 0

    # Create the chat display
    ttk::frame $f.textf -style ChatwidgetFrame
    set peers [ttk::panedwindow $f.peers -orient vertical]
    ttk::frame $f.textfupper
    ttk::frame $f.textflower
    text $f.text -borderwidth 0 -relief flat -state disabled -font ChatwidgetFont \
        -yscrollcommand [list [namespace origin AutoScrollSet] $self $f.textvs $f.textflower 1]
    ttk::scrollbar $f.textvs -command [list $f.text yview]
    grid $f.text $f.textvs -in $f.textflower -sticky news
    Grid $f.textflower 0 0
    $f.text peer create $f.textpeer -borderwidth 0 -relief flat -state disabled -font ChatwidgetFont\
        -yscrollcommand [list [namespace origin AutoScrollSet] $self $f.textpvs $f.textfupper 0]
    ttk::scrollbar $f.textpvs -command [list $f.textpeer yview]
    $f.text configure -height 5
    grid $f.textpeer $f.textpvs -in $f.textfupper -sticky news
    Grid $f.textfupper 0 0
    $peers add $f.textfupper
    $peers add $f.textflower -weight 1
    grid $peers -in $f.textf -sticky news -padx 1 -pady 1
    Grid $f.textf 0 0
    bindtags $f.text [linsert [bindtags $f.text] 1 ChatwidgetText]
    
    # Create the entry widget
    ttk::frame $f.entryf -style ChatwidgetFrame
    text $f.entry -borderwidth 0 -relief flat -font ChatwidgetFont \
        -yscrollcommand [list [namespace origin AutoScrollSet] $self $f.entryvs $f.entryf 0]
    ttk::scrollbar $f.entryvs -command [list $f.entry yview]
    $f.entry configure -height 1
    bindtags $f.entry [linsert [bindtags $f.entry] 1 ChatwidgetEntry]
    grid $f.entry $f.entryvs -in $f.entryf -sticky news -padx 1 -pady 1
    Grid $f.entryf 0 0

    bind ChatwidgetEntry <Return> "[namespace origin Post] \[winfo parent %W\]"
    bind ChatwidgetEntry <KP_Enter> "[namespace origin Post] \[winfo parent %W\]"
    bind ChatwidgetEntry <Shift-Return> "#"
    bind ChatwidgetEntry <Control-Return> "#"
    bind ChatwidgetEntry <Key-Up>   "[namespace origin History] \[winfo parent %W\] prev"
    bind ChatwidgetEntry <Key-Down> "[namespace origin History] \[winfo parent %W\] next"
    bind ChatwidgetEntry <Key-Tab> "[namespace origin Nickcomplete] \[winfo parent %W\]"
    bind ChatwidgetEntry <Key-Prior> "\[winfo parent %W\] yview scroll -1 pages"
    bind ChatwidgetEntry <Key-Next> "\[winfo parent %W\] yview scroll 1 pages"
    bind $self <Destroy> "+unset -nocomplain [namespace current]::%W"
    bind $peers <Map> [list [namespace origin PaneMap] %W 0]
    bind $inner <Map> [list [namespace origin PaneMap] %W -90]
    bind $outer <Map> [list [namespace origin PaneMap] %W -28]

    bind ChatwidgetText <<ThemeChanged>> {
        ttk::style layout ChatwidgetFrame {
            Entry.field -sticky news -border 1 -children {
                ChatwidgetFrame.padding -sticky news
            }
        }
    }

    $f.names tag configure SUBTITLE -background grey80 -font ChatwidgetBoldFont

    $inner add $f.textf -weight 1
    $inner add $f.namesf
    $outer add $inner -weight 1
    $outer add $f.entryf
    
    grid $outer -row 1 -column 0 -sticky news -padx 1 -pady 1
    grid columnconfigure $f 0 -weight 1
    grid rowconfigure $f 1 -weight 1
    return $self
}

# Set initial position of sash
proc chatwidget::PaneMap {pane offset} {
    bind $pane <Map> {}
    if {[llength [$pane panes]] > 1} {
        if {$offset < 0} {
            if {[$pane cget -orient] eq "horizontal"} {set axis width} else {set axis height}
            after idle [list $pane sashpos 0 [expr {[winfo $axis $pane] + $offset}]]
        } else {
            after idle [list $pane sashpos 0 $offset]
        }
    }
}

# Handle auto-scroll smarts. This will cause the scrollbar to be removed if
# not required and to disable autoscroll for the text widget if we are not
# tracking the bottom line.
proc chatwidget::AutoScrollSet {self scrollbar frame set f1 f2} {
    upvar #0 [namespace current]::$self state
    $scrollbar set $f1 $f2
    if {($f1 == 0) && ($f2 == 1)} {
	grid remove $scrollbar
    } else {
        grid $scrollbar -in $frame
    }
    if {$set} {
        set state(autoscroll) [expr {(1.0 - $f2) < 1.0e-6 }]
    }
}

proc chatwidget::Post {self} {
    set msg [$self entry get 1.0 end-1c]
    if {$msg eq ""} { return -code break "" }
    if {[catch {Hook $self run post $msg}] != 3} {
        $self entry delete 1.0 end
        upvar #0 [namespace current]::$self state
        set state(history) [lrange [lappend state(history) $msg] end-50 end]
        set state(current) [llength $state(history)]
    }
    return -code break ""
}

proc chatwidget::History {self dir} {
    upvar #0 [namespace current]::$self state
    switch -exact -- $dir {
        prev {
            if {$state(current) == 0} { return }
            if {$state(current) == [llength $state(history)]} {
                set state(temp) [$self entry get 1.0 end-1c]
            }
            if {$state(current)} { incr state(current) -1 }
            $self entry delete 1.0 end
            $self entry insert 1.0 [lindex $state(history) $state(current)]
            return
        }
        next {
            if {$state(current) == [llength $state(history)]} { return }
            if {[incr state(current)] == [llength $state(history)] && [info exists state(temp)]} {
                set msg $state(temp)
            } else {
                set msg [lindex $state(history) $state(current)]
            }
            $self entry delete 1.0 end
            $self entry insert 1.0 $msg
        }
        default {
            return -code error "invalid direction \"$dir\":
                must be either prev or next"
        }
    }
}

proc chatwidget::Nickcomplete {self} {
    upvar #0 [namespace current]::$self state
    if {[info exists state(nickcompletion)]} {
        foreach {index matches after} $state(nickcompletion) break
        after cancel $after
        incr index
        if {$index > [llength $matches]} { set index 0 }
        set delta 2c
    } else {
        set delta 1c
        set partial [$self entry get "insert - $delta wordstart" "insert - $delta wordend"]
        set matches [lsearch -all -inline -glob -index 0 $state(names) $partial*]
        set index 0
    }
    switch -exact -- [llength $matches] {
        0 { bell ; return -code break ""}
        1 { set match [lindex [lindex $matches 0] 0]}
        default {
            set match [lindex [lindex $matches $index] 0]
            set state(nickcompletion) [list $index $matches \
                [after 2000 [list [namespace origin NickcompleteCleanup] $self]]]
        }
    }
    $self entry delete "insert - $delta wordstart" "insert - $delta wordend"
    $self entry insert insert "$match "
    return -code break ""
}

proc chatwidget::NickcompleteCleanup {self} {
    upvar #0 [namespace current]::$self state
    if {[info exists state(nickcompletion)]} {
        unset state(nickcompletion)
    }
}
    
package provide chatwidget $chatwidget::version
