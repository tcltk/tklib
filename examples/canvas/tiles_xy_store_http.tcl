## -*- tcl -*-
# ### ### ### ######### ######### #########

# @@ Meta Begin
# Package tiles::xy::store::http 1.0
#
# Meta platform    tcl
# Meta description Filesystem based based tile storage, xy tiles.
# Meta subject     tile filesystem storage xy
# Meta require     {Tcl 8.5}
# Meta require     snit
#
# # --- --- --- --------- --------- ---------
# Meta ak::api::desc  
# Meta ak::api::desc  
# Meta ak::api::desc  
# Meta ak::api::desc  
# Meta ak::api::desc  
# Meta ak::api::desc  
# Meta ak::api::desc  
#
# # --- --- --- --------- --------- ---------
# @@ Meta End

# ### ### ### ######### ######### #########
## Requisites

package require Tcl 8.4 ; # No {*}-expansion :(, no ** either, nor lassign
package require snit
package require fileutil
package require http

# ### ### ### ######### ######### #########
##

snit::type tiles::xy::store::http {

    # ### ### ### ######### ######### #########
    ## API

    constructor {n baseurl} {
	set mybase $baseurl
	set N [expr {1 << $n}] ; # == 2^n
	set myrows $N
	set mycols $N
	return
    }

    method rows       {} { return $myrows    }
    method columns    {} { return $mycols }
    method tileheight {} { return 256    }
    method tilewidth  {} { return 256 }

    method get {key donecmd} {
	if {[llength $key] != 2} {
	    return -code error "Bad key '$key', expected 2 elements"
	}

	foreach {r c} $key break

	# Requests outside of the valid range are rejected
	# immediately, without even going to the net.

	if {($r < 0) || ($r >= $myrows) ||
	    ($c < 0) || ($c >= $mycols)} {
	    after idle [linsert $donecmd end unset $key]
	}

	# Compose full url of the requested tile and initiate its
	# download. A download is done if and only if there is no
	# download of this tile already in progress. If there is we
	# simply register the new request with that download. When the
	# download is done we convert the data to an in-memory image
	# and provide it to all requests which were made.

	set tileurl $mybase/$c/$r.png

	lappend mypending($tileurl) $donecmd
	if {[llength $mypending($tileurl)] < 2} {
	    # We keep the retrieved image data in memory, 256x256 is
	    # not that large for todays RAM sizes.

	    if {[catch {
		set token [http::geturl $tileurl \
			       -binary 1 -command [mymethod Done]]

	    }]} {
		puts $::errorInfo

		# Some errors, like invalid urls raise sync errors,
		# even if -command is specified.
		after idle [linsert $donecmd end unset $key]
		return
	    }

	    #puts "GET\t($tileurl) = $token"
	    set mytoken($token) [list $tileurl $key]
	}
    }

    method Done {token} {
	#puts GOT/$token
	foreach {tileurl key} $mytoken($token) break
	unset    mytoken($token)

	set status [http::status $token]
	set ncode  [http::ncode $token]

	puts URL|$tileurl
	puts STT|$status
	puts COD|[http::code $token]
	puts NCO|[http::ncode $token]
	#puts ERR|[http::error $token]
	if {[catch {
	    set data   [http::data $token]
	    http::cleanup $token

	    set requests $mypending($tileurl)
	    unset mypending($tileurl)

	    if {($status ne "ok") || ($ncode != 200)} {
		# error, eof, and other non-ok conditions.
		foreach d $requests { 
		    after idle [linsert $d end unset $key]
		}
		# FUTURE: Return some fixed 'undefined' tile.
	    } else {
		# ok. this code assumes that there are no url redirections
		# to follow, but that we directly get the image data.

		#puts \t|[string length $data]|

		set tile  [image create photo -data $data]
		foreach d $requests { 
		    after idle [linsert $d end set $key $tile]
		}
	    }
	}]} {
	    puts $::errorInfo
	    puts $data
	}
	return
    }

    # ### ### ### ######### ######### #########
    ## Internal commands

    # ### ### ### ######### ######### #########
    ## State

    variable mybase       {} ; # Base path to the tile directories.
    variable myrows       {} ; # Base path to the tile directories.
    variable mycols       {} ; # Base path to the tile directories.
    variable mypending -array {} ; # Meta information about the tile directory.
    variable mytoken -array {} ; # Meta information about the tile directory.

    # ### ### ### ######### ######### #########
}

# ### ### ### ######### ######### #########
## Ready

package provide tiles::xy::store::http 1.0
