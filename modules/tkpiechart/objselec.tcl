# copyright (C) 1997-98 Jean-Luc Fontaine (mailto:jfontain@mygale.org)
# this program is free software: please refer to the BSD type license enclosed in this package

set rcsId {$Id: objselec.tcl,v 1.2 1998/04/20 13:37:29 jfontain Exp $}

# implements selection on a list of object identifiers (sortable list of integer), for a listbox implementation, for example

class objectSelection {

    proc objectSelection {this args} switched {$args} {
        switched::complete $this
    }

    proc ~objectSelection {this} {
        variable ${this}selected

        catch {::unset ${this}selected}
    }

    proc options {this} {
        return [::list\
            [::list -selectcommand {} {}]\
        ]
    }

    proc set-selectcommand {this value} {}                                 ;# nothing to do as value is stored at the switched level

    proc set {this ids selected} {
        variable ${this}selected

        ::set select {}
        ::set deselect {}
        foreach id $ids {
            if {[info exists ${this}selected($id)]&&($selected==[::set ${this}selected($id)])} continue                 ;# no change
            if {$selected} {
                lappend select $id
                ::set ${this}selected($id) 1
            } else {
                lappend deselect $id
                ::set ${this}selected($id) 0
            }
        }
        update $this $select $deselect
    }

    proc update {this selected deselected} {
        if {[string length $switched::($this,-selectcommand)]==0} return
        if {[llength $selected]>0} {
            uplevel #0 $switched::($this,-selectcommand) [::list $selected] 1
        }
        if {[llength $deselected]>0} {
            uplevel #0 $switched::($this,-selectcommand) [::list $deselected] 0
        }
    }

    proc unset {this ids} {
        variable ${this}selected

        foreach id $ids {
            ::unset ${this}selected($id)
        }
    }

    ### public procedures follow:

    proc add {this ids} {
        set $this $ids 0
    }

    proc remove {this ids} {
        unset $this $ids
    }

    proc select {this ids} {
        clear $this
        set $this $ids 1
        ::set objectSelection::($this,lastSelected) [lindex $ids end]            ;# keep track of last selected object for extension
    }

    proc deselect {this ids} {
        set $this $ids 0
    }

    proc toggle {this ids} {
        variable ${this}selected

        ::set select {}
        ::set deselect {}
        foreach id $ids {
            if {[::set ${this}selected($id)]} {
                lappend deselect $id
                ::set ${this}selected($id) 0
            } else {
                lappend select $id
                ::set ${this}selected($id) 1
                ::set objectSelection::($this,lastSelected) $id                  ;# keep track of last selected object for extension
            }
        }
        update $this $select $deselect
    }

    proc extend {this id} {
        variable ${this}selected

        if {[info exists objectSelection::($this,lastSelected)]} {
            ::set list [lsort -integer [array names ${this}selected]]
            ::set last [lsearch -exact $list $objectSelection::($this,lastSelected)]
            ::set index [lsearch -exact $list $id]
            clear $this
            if {$index>$last} {
                set $this [lrange $list $last $index] 1
            } else {
                set $this [lrange $list $index $last] 1
            }
        } else {
            select $this $id
        }
    }

    proc clear {this} {
        variable ${this}selected

        set $this [array names ${this}selected] 0
    }

    proc selected {this} {
        variable ${this}selected

        set list {}
        foreach id [array names ${this}selected] {
            if {[set ${this}selected($id)]} {
                lappend list $id
            }
        }
        return [lsort -integer $list]
    }

    proc list {this} {
        variable ${this}selected

        return [lsort -integer [array names ${this}selected]]
    }
}
