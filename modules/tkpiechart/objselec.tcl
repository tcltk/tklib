# copyright (C) 1997-98 Jean-Luc Fontaine (mailto:jfontain@mygale.org)
# this program is free software: please refer to the BSD type license enclosed in this package

set rcsId {$Id: objselec.tcl,v 1.4 1998/04/24 10:51:45 jfontain Exp $}

# implements selection on a list of object identifiers (sortable list of integer), for a listbox implementation, for example

class objectSelector {

    proc objectSelector {this args} selector {$args} {}

    proc ~objectSelector {this} {}

    ### public procedures follow:

    proc extend {this id} {
        if {[info exists selector::($this,lastSelected)]} {
            set list [list $this]
            set last [lsearch -exact $list $selector::($this,lastSelected)]
            set index [lsearch -exact $list $id]
            selector::clear $this
            if {$index>$last} {
                selector::set $this [lrange $list $last $index] 1
            } else {
                selector::set $this [lrange $list $index $last] 1
            }
        } else {
            selector::select $this $id
        }
    }

    proc selected {this} {
        return [lsort -integer [selector::_selected $this]]
    }

    proc list {this} {
        return [lsort -integer [selector::_list $this]]
    }
}
