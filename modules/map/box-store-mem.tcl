## -*- tcl -*-
# # ## ### ##### ######## ############# ######################
## (c) 2022 Andreas Kupries

# @@ Meta Begin
# Package map::box::store::memory 0
# Meta author      {Andreas Kupries}
# Meta location    https://core.tcl.tk/tklib
# Meta platform    tcl
# Meta summary	   In-memory store for geobox definitions
# Meta description In-memory store for geobox definitions, with
# Meta description memoized calculation of extended attributes.
# Meta description Base data is taken from a backing store.
# Meta description Anything API-compatible to map::box::store::fs
# Meta subject	   {center, geobox
# Meta subject	   {diameter, geobox}
# Meta subject	   {geobox pixels, zoom}
# Meta subject	   {geobox, center}
# Meta subject	   {geobox, diameter}
# Meta subject	   {geobox, memory store}
# Meta subject	   {geobox, perimeter length}
# Meta subject	   {length, geobox, perimeter}
# Meta subject	   {memory store, geobox}
# Meta subject	   {perimeter length, geobox}
# Meta subject	   {pixels, zoom, geobox}
# Meta subject	   {store, geobox, memory}
# Meta subject	   {zoom, geobox pixels}
# Meta require     {Tcl 8.6-}
# Meta require     debug
# Meta require     debug::caller
# Meta require     {map::slippy 0.8}
# Meta require     snit
# @@ Meta End

package provide map::box::store::memory 0.1

# # ## ### ##### ######## ############# ######################
## API
#
##  <class> OBJ backend-store
#
##  <obj> ids			-> list (id...)
##  <obj> get ID		-> dict (names, geo, diameter, perimeter, center)
##  <obj> visible GEOBOX	-> list (id...)
##  <obj> pixels ID ZOOM	-> list (point)
#
# # ## ### ##### ######## ############# ######################
## Requirements

package require Tcl 8.6
#
#                               ;# Tcllib
package require debug		;# - Narrative Tracing
package require debug::caller   ;#
package require map::slippy 0.8	;# - Map utilities
package require snit            ;# - OO system

# # ## ### ##### ######## ############# ######################
## Ensemble setup.

namespace eval map             { namespace export box    ; namespace ensemble create }
namespace eval map::box        { namespace export store  ; namespace ensemble create }
namespace eval map::box::store { namespace export memory ; namespace ensemble create }

debug level  tklib/map/box/store/memory
debug prefix tklib/map/box/store/memory {<[pid]> [debug caller] | }

# # ## ### ##### ######## ############# ######################

snit::type ::map::box::store::memory {

    # . . .. ... ..... ........ ............. .....................
    ## State
    #
    # - Backing store, command prefix
    # - Pixel store     :: dict (id -> zoom -> pointbox)
    # - Attribute store :: dict (id -> attr)
    #              attr :: dict ("name"     -> string
    #                            "geobox"   -> geobox
    #                            "diameter" -> double
    #                            "length"   -> double
    #                            "center"   -> geo)

    variable mystore  {}
    variable myattr   {}
    variable mypixels {}

    # . . .. ... ..... ........ ............. .....................
    ## Lifecycle

    constructor {store} {
	debug.tklib/map/box/store/memory {}

	set mystore $store
	return
    }

    destructor {
	debug.tklib/map/box/store/memory {}
	return
    }

    # . . .. ... ..... ........ ............. .....................
    ## API

    delegate method * to mystore except get	;# ids, visible

    method get {id} {
	debug.tklib/map/box/store/memory {}

	if {![dict exists $myattr $id]} {
	    dict set myattr $id [$self Attributes $id]
	}
	return [dict get $myattr $id]
    }

    method pixels {id zoom} {
	debug.tklib/map/box/store/memory {}

	if {![dict exists $mypixels $id $zoom]} {
	    dict set mypixels $id $zoom [$self Pixels $zoom $id]
	}
	return [dict get $mypixels $id $zoom]
    }

    # . . .. ... ..... ........ ............. .....................
    ## Helpers

    method Attributes {id} {
	set attr [DO get $id]
	set gbox [dict get $attr geobox]

	set center    [::map slippy geo box center    $gbox]
	set diameter  [::map slippy geo box diameter  $gbox]
	set perimeter [::map slippy geo box perimeter $gbox]

	dict set attr center    $center
	dict set attr diameter  $diameter
	dict set attr perimeter $perimeter

	#puts |$id|$attr|

	return $attr
    }

    method Pixels {zoom id} {
	debug.tklib/map/box/store/memory {}

	set attr [DO get $id]
	set gbox [dict get $attr geobox]
	set pbox [map slippy geo box 2point $zoom $gbox]

	return $pbox
    }

    proc DO {args} {
	debug.tklib/map/box/store/memory {}

	upvar 1 mystore mystore
	return [uplevel #0 [list {*}$mystore {*}$args]]
    }

    # . . .. ... ..... ........ ............. .....................
}

# # ## ### ##### ######## ############# ######################
return
