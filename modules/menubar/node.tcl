# node.tcl --
#
#    Package that defines the menubar::Node class. This class is a
#    privite class used by the menubar::Tree class.
#
# Copyright (c) 2009    Tom Krehbiel <tomk@users.sourceforge.net>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: node.tcl,v 1.2 2010/01/05 21:37:58 tomk Exp $

package require TclOO

package provide menubar::node 0.5

# --------------------------------------------------
#
# manubar::Node class - used by menubar::Tree class
#
# --------------------------------------------------

# --
# parent   - contains the parent node instance
# children - contains list of child node instances
# attrs    - a dictionary of attribute/value pairs
oo::class create ::menubar::node {

    # --
    # create a named node
    constructor { pnode } {
        my variable parent
        my variable children
        my variable attrs

        set parent ${pnode}
        set children {}
        set attrs [dict create]
    }

    # --
    # If 'pnode' isn't blank, set the node's parent to its
    # value; return the current parent.
    method parent { {pnode ""} } {
        my variable parent
        if { ${pnode} ne "" } {
            set parent ${pnode}
        }
        return ${parent}
    }

    # --
    # If 'clist' is empty then return the current childern list else
	# set the node's children to 'clist' and return the current childern list.
	# If the option '-force' is found then set the node's children even
	# if 'clist' is blank.
    method children { {clist ""} args } {
        my variable children
        if { [llength ${clist}] != 0 || "-force" in ${args} } {
            set children ${clist}
        }
        return ${children}
    }

    # --
    # Insert a list of node instances ('args') into the
    # child list at location 'index'.
    method insert { index args } {
        my variable children
        set children [linsert ${children} ${index} {*}${args}]
        return
    }

    # --
    # If 'kdict' isn't blank set the node attributes to its
    # value; return the current value of attributes.
    method attrs { {kdict ""} {force ""} } {
        my variable attrs
        if { ${kdict} ne "" || ${force} eq "-force" } {
            set attrs ${kdict}
        }
        return ${attrs}
    }

    method attrs.filter { {globpat ""} } {
        my variable attrs
        if { ${globpat} eq "" } {
            return ${attrs}
        } else {
            return [dict filter ${attrs} key ${globpat}]
        }
    }

    method attr.keys { {globpat ""} } {
        my variable attrs
        if { ${globpat} eq "" } {
            return [dict keys ${attrs}]
        } else {
            return [dict keys ${attrs} ${globpat}]
        }
    }

    method attr.set { key value } {
        my variable attrs
        dict set attrs ${key} ${value}
        return ${value}
    }

    method attr.unset { key } {
        my variable attrs
        dict unset attrs ${key}
        return
    }

    method attr.exists { key } {
        my variable attrs
        return [dict exist ${attrs} ${key}]
    }

    method attr.get { key } {
        my variable attrs
        if { [dict exist ${attrs} ${key}] } {
            return [dict get ${attrs} ${key}]
        }
        error "attribute '${key}' - not found"
    }

    method attr.append { key value } {
        my variable attrs
        dict append attrs ${key} ${value}
        return
    }

    method attr.lappend { key value } {
        my variable attrs
        dict lappend attrs ${key} ${value}
        return
    }
}
