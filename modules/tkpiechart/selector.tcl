set rcsId {$Id: selector.tcl,v 1.4.1.1 2000/07/30 19:47:35 jfontain Exp $}

# implements generic selection on a list of unique identifiers

class selector {

    proc selector {this args} switched {$args} {
        ::set selector::($this,order) 0
        switched::complete $this
    }

    proc ~selector {this} {
        variable ${this}selected
        variable ${this}order

        catch {::unset ${this}selected ${this}order}
    }

    proc options {this} {
        return [::list\
            [::list -selectcommand {} {}]\
        ]
    }

    proc set-selectcommand {this value} {}                                 ;# nothing to do as value is stored at the switched level

    proc set {this indices selected} {
        variable ${this}selected
        variable ${this}order

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
            ::set ${this}order($index) $selector::($this,order)                                        ;# keep track of action order
            incr selector::($this,order)
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
        variable ${this}order

        foreach index $indices {
            ::unset ${this}selected($index) ${this}order($index)
        }
    }

    proc ordered {this index1 index2} {                                    ;# used for sorting with lsort command according to order
        variable ${this}order

        return [expr {[::set ${this}order($index1)]-[::set ${this}order($index2)]}]
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
        variable ${this}order

        ::set select {}
        ::set deselect {}
        foreach index $indices {
            if {[::set ${this}selected($index)]} {
                lappend deselect $index
                ::set ${this}selected($index) 0
                if {[info exists selector::($this,lastSelected)]&&($index==$selector::($this,lastSelected))} {
                    ::unset selector::($this,lastSelected)                     ;# too complicated to find out what was selected last
                }
            } else {
                lappend select $index
                ::set ${this}selected($index) 1
                ::set selector::($this,lastSelected) $index                      ;# keep track of last selected object for extension
            }
            ::set ${this}order($index) $selector::($this,order)                                        ;# keep track of action order
            incr selector::($this,order)
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
        foreach {index value} [array get ${this}selected] {
            if {$value} {
                lappend list $index
            }
        }
        return [lsort -command "ordered $this" $list]                                                                     ;# ordered
    }

    virtual proc list {this} {                      ;# derived class may want to do some additional processing, such as sorting, ...
        variable ${this}selected

        return [lsort -command "ordered $this" [array names ${this}selected]]                                             ;# ordered
    }

}
