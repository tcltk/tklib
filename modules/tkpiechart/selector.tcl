set rcsId {$Id: selector.tcl,v 1.2 1998/05/24 19:18:21 jfontain Exp $}

# implements generic selection on a list of unique identifiers

class selector {

    proc selector {this args} switched {$args} {
        switched::complete $this
    }

    proc ~selector {this} {
        variable ${this}selected

        catch {::unset ${this}selected}
    }

    proc options {this} {
        return [::list\
            [::list -selectcommand {} {}]\
        ]
    }

    proc set-selectcommand {this value} {}                                 ;# nothing to do as value is stored at the switched level

    proc set {this indices selected} {
        variable ${this}selected

        ::set select {}
        ::set deselect {}
        foreach index $indices {
            if {[info exists ${this}selected($index)]&&($selected==[::set ${this}selected($index)])} continue           ;# no change
            if {$selected} {
                lappend select $index
                ::set ${this}selected($index) 1
            } else {
                lappend deselect $index
                ::set ${this}selected($index) 0
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

    proc unset {this indices} {
        variable ${this}selected

        foreach index $indices {
            ::unset ${this}selected($index)
        }
    }

    ### public procedures follow:

    proc add {this indices} {
        set $this $indices 0
    }

    proc remove {this indices} {
        unset $this $indices
    }

    proc select {this indices} {
        clear $this
        set $this $indices 1
        ::set selector::($this,lastSelected) [lindex $indices end]               ;# keep track of last selected object for extension
    }

    proc deselect {this indices} {
        set $this $indices 0
    }

    proc toggle {this indices} {
        variable ${this}selected

        ::set select {}
        ::set deselect {}
        foreach index $indices {
            if {[::set ${this}selected($index)]} {
                lappend deselect $index
                ::set ${this}selected($index) 0
            } else {
                lappend select $index
                ::set ${this}selected($index) 1
                ::set selector::($this,lastSelected) $index                      ;# keep track of last selected object for extension
            }
        }
        update $this $select $deselect
    }

    virtual proc extend {this index} {}

    proc clear {this} {
        variable ${this}selected

        set $this [array names ${this}selected] 0
    }

    virtual proc selected {this} {                  ;# derived class may want to do some additional processing, such as sorting, ...
        variable ${this}selected

        ::set list {}
        foreach index [array names ${this}selected] {
            if {[::set ${this}selected($index)]} {
                lappend list $index
            }
        }
        return $list
    }

    virtual proc list {this} {                      ;# derived class may want to do some additional processing, such as sorting, ...
        variable ${this}selected

        return [array names ${this}selected]
    }
}
