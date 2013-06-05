# -*- tcl -*-
# sak::doc - Documentation facilities

package require sak::util
package require sak::doc

namespace eval ::sak::localdoc {}

# ###
# API commands

## ### ### ### ######### ######### #########

proc ::sak::localdoc::usage {} {
    package require sak::help
    puts stdout \n[sak::help::on localdoc]
    exit 1
}

proc ::sak::localdoc::run {} {
    package require cmdline
    package require fileutil
    package require textutil::repeat
    package require doctools      1
    package require doctools::toc 1
    package require doctools::idx 1
    package require dtplite

    set nav ../../../../home

    puts "Reindex the documentation..."
    sak::doc::imake __dummy__
    sak::doc::index __dummy__

    puts "Removing old documentation..."
    file delete -force embedded
    file mkdir embedded/man
    file mkdir embedded/www

    puts "Generating manpages..."
    dtplite::do \
	[list \
	     -exclude {*/doctools/tests/*} \
	     -exclude {*/support/*} \
	     -ext n \
	     -o embedded/man \
	     nroff .]

    # Note: Might be better to run them separately.
    # Note @: Or we shuffle the results a bit more in the post processing stage.

    set map  {
	.man     .html
	modules/ tklib/files/modules/
	apps/    tklib/files/apps/
    }

    set toc  [string map $map [fileutil::cat support/devel/sak/doc/toc.txt]]
    set apps [string map $map [fileutil::cat support/devel/sak/doc/toc_apps.txt]]
    set mods [string map $map [fileutil::cat support/devel/sak/doc/toc_mods.txt]]
    set cats [string map $map [fileutil::cat support/devel/sak/doc/toc_cats.txt]]

    puts "Generating HTML... Pass 1, draft..."
    dtplite::do \
	[list \
	     -toc $toc \
	     -nav {Tklib Home} $nav \
	     -post+toc Categories $cats \
	     -post+toc Modules $mods \
	     -post+toc Applications $apps \
	     -exclude {*/doctools/tests/*} \
	     -exclude {*/support/*} \
	     -merge \
	     -o embedded/www \
	     html .]

    puts "Generating HTML... Pass 2, resolving cross-references..."
    dtplite::do \
	[list \
	     -toc $toc \
	     -nav {Tklib Home} $nav \
	     -post+toc Categories $cats \
	     -post+toc Modules $mods \
	     -post+toc Applications $apps \
	     -exclude {*/doctools/tests/*} \
	     -exclude {*/support/*} \
	     -merge \
	     -o embedded/www \
	     html .]

    return
}

# ### ### ### ######### ######### #########

package provide sak::localdoc 1.0

##
# ###
