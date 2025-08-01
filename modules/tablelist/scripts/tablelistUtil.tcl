#==============================================================================
# Contains private utility procedures for tablelist widgets.
#
# Structure of the module:
#   - Namespace initialization
#   - Private utility procedures
#
# Copyright (c) 2000-2025  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#
# Namespace initialization
# ========================
#

namespace eval tablelist {
    #
    # alignment -> anchor mapping
    #
    variable anchors
    array set anchors {
	left	w
	right	e
	center	center
    }

    #
    # <alignment, changeSnipSide> -> snipSide mapping
    #
    variable snipSides
    array set snipSides {
	left,0		r
	left,1		l
	right,0		l
	right,1		r
	center,0	r
	center,1	l
    }

    #
    # <incrArrowType, sortOrder> -> direction mapping
    #
    variable directions
    array set directions {
	up,increasing	Up
	up,decreasing	Dn
	down,increasing	Dn
	down,decreasing	Up
    }

    variable specialAquaHandling [expr {$usingTile && ($::tk_version >= 8.6 ||
	[regexp {^8\.5\.(9|[1-9][0-9])$} $::tk_patchLevel]) &&
	[lsearch -exact [winfo server .] "AppKit"] >= 0}]

    variable extendedAquaSupport [expr {
	[lsearch -exact [image types] "nsimage"] >= 0}]

    variable aquaCrash [expr {$winSys eq "aqua" &&
	[lsearch -exact {8.6.11 8.6.12 8.7a5} $::tk_patchLevel] >= 0}]
}

#
# Private utility procedures
# ==========================
#

#------------------------------------------------------------------------------
# tablelist::destroyed
#
# Checks whether the tablelist widget win got destroyed by some custom script.
#------------------------------------------------------------------------------
proc tablelist::destroyed win {
    #
    # A bit safer than using "winfo exists", because the widget might have
    # been destroyed and its name reused for a new non-tablelist widget:
    #
    return [expr {![array exists ::tablelist::ns${win}::data]}]
}

#------------------------------------------------------------------------------
# tablelist::rowIndex
#
# Checks the row index idx and returns either its numerical value or an error.
# endIsSize must be a boolean value: if true, end refers to the number of items
# in the tablelist, i.e., to the item just after the last one; if false, end
# refers to 1 less than the number of items, i.e., to the last item in the
# tablelist.  checkRange must be a boolean value: if true, it is additionally
# checked whether the numerical value corresponding to idx is within the
# allowed range.
#------------------------------------------------------------------------------
proc tablelist::rowIndex {win idx endIsSize {checkRange 0}} {
    upvar ::tablelist::ns${win}::data data

    if {[isInteger $idx]} {
	set index [expr {int($idx)}]
    } elseif {[string first $idx "end"] == 0} {
	if {$endIsSize} {
	    set index $data(itemCount)
	} else {
	    set index $data(lastRow)
	}
    } elseif {[string first $idx "last"] == 0} {
	set index $data(lastRow)
    } elseif {[string first $idx "top"] == 0} {
	synchronize $win
	displayItems $win
	set textIdx [$data(body) index @0,0]
	set index [expr {int($textIdx) - 1}]
    } elseif {[string first $idx "bottom"] == 0} {
	synchronize $win
	displayItems $win
	set textIdx [$data(body) index @0,$data(btmY)]
	set index [expr {int($textIdx) - 1}]
	if {$index > $data(lastRow)} {
	    set index $data(lastRow)
	}
    } elseif {[string first $idx "active"] == 0 && [string length $idx] >= 2} {
	set index $data(activeRow)
    } elseif {[string first $idx "anchor"] == 0 && [string length $idx] >= 2} {
	set index $data(anchorRow)
    ##nagelfar ignore
    } elseif {[scan $idx "@%d,%d%n" x y count] == 3 &&
	      $count == [string length $idx]} {
	synchronize $win
	displayItems $win
	incr x -[winfo x $data(body)]
	incr y -[winfo y $data(body)]
	set textIdx [$data(body) index @$x,$y]
	set index [expr {int($textIdx) - 1}]
	if {$index > $data(lastRow)} {
	    set index $data(lastRow)
	}
    ##nagelfar ignore
    } elseif {[scan $idx "k%d%n" num count] == 2 &&
	      $count == [string length $idx]} {
	set index [keyToRow $win k$num]
    } else {
	set idxIsEmpty [expr {$idx eq ""}]
	set itemCount $data(itemCount)
	for {set row 0} {$row < $itemCount} {incr row} {
	    set key [lindex $data(keyList) $row]
	    set hasName [info exists data($key-name)]
	    if {($hasName && $idx eq $data($key-name)) ||
		(!$hasName && $idxIsEmpty)} {
		set index $row
		break
	    }
	}
	if {$row == $data(itemCount)} {
	    return -code error \
		   "bad row index \"$idx\": must be active, anchor, end, last,\
		    top, bottom, @x,y, a number, a full key, or a name"
	}
    }

    if {$checkRange && ($index < 0 || $index > $data(lastRow))} {
	return -code error "row index \"$idx\" out of range"
    } else {
	return $index
    }
}

#------------------------------------------------------------------------------
# tablelist::hdr_rowIndex
#
# Checks the header row index idx and returns either its numerical value or an
# error.  endIsSize must be a boolean value: if true, end refers to the number
# of header items in the tablelist, i.e., to the header item just after the
# last one; if false, end refers to 1 less than the number of header items,
# i.e., to the last header item in the tablelist.  checkRange must be a boolean
# value: if true, it is additionally checked whether the numerical value
# corresponding to idx is within the allowed range.
#------------------------------------------------------------------------------
proc tablelist::hdr_rowIndex {win idx endIsSize {checkRange 0}} {
    upvar ::tablelist::ns${win}::data data

    if {[isInteger $idx]} {
	set index [expr {int($idx)}]
    } elseif {[string first $idx "end"] == 0} {
	if {$endIsSize} {
	    set index $data(hdr_itemCount)
	} else {
	    set index $data(hdr_lastRow)
	}
    } elseif {[string first $idx "last"] == 0} {
	set index $data(hdr_lastRow)
    ##nagelfar ignore
    } elseif {[scan $idx "@%d,%d%n" x y count] == 3 &&
	      $count == [string length $idx]} {
	incr x -[winfo x $data(hdr)]
	incr y -[winfo y $data(hdr)]
	if {!$data(-showlabels)} {
	    incr y
	}
	set textIdx [$data(hdrTxt) index @$x,$y]
	set index [expr {int($textIdx) - 2}]
	if {$index < 0} {
	    set index 0
	}
	if {$index > $data(hdr_lastRow)} {
	    set index $data(hdr_lastRow)
	}
    ##nagelfar ignore
    } elseif {[scan $idx "hk%d%n" num count] == 2 &&
	      $count == [string length $idx]} {
	set index [hdr_keyToRow $win hk$num]
    } else {
	set idxIsEmpty [expr {$idx eq ""}]
	set hdr_itemCount $data(hdr_itemCount)
	for {set row 0} {$row < $hdr_itemCount} {incr row} {
	    set key [lindex $data(hdr_keyList) $row]
	    set hasName [info exists data($key-name)]
	    if {($hasName && $idx eq $data($key-name)) ||
		(!$hasName && $idxIsEmpty)} {
		set index $row
		break
	    }
	}
	if {$row == $data(hdr_itemCount)} {
	    return -code error \
		   "bad header row index \"$idx\": must be end, last, @x,y,\
		    a number, a full header key, or a name"
	}
    }

    if {$checkRange && ($index < 0 || $index > $data(hdr_lastRow))} {
	return -code error "header row index \"$idx\" out of range"
    } else {
	return $index
    }
}

#------------------------------------------------------------------------------
# tablelist::colIndex
#
# Checks the column index idx and returns either its numerical value or an
# error.  checkRange must be a boolean value: if true, it is additionally
# checked whether the numerical value corresponding to idx is within the
# allowed range.
#------------------------------------------------------------------------------
proc tablelist::colIndex {win idx checkRange {decrX 1}} {
    upvar ::tablelist::ns${win}::data data

    if {[isInteger $idx]} {
	set index [expr {int($idx)}]
    } elseif {[string first $idx "end"] == 0 ||
	      [string first $idx "last"] == 0} {
	set index $data(lastCol)
    } elseif {[string first $idx "left"] == 0} {
	return [colIndex $win @0,0 $checkRange 0]
    } elseif {[string first $idx "right"] == 0} {
	return [colIndex $win @$data(rightX),0 $checkRange 0]
    } elseif {[string first $idx "active"] == 0 && [string length $idx] >= 2} {
	set index $data(activeCol)
    } elseif {[string first $idx "anchor"] == 0 && [string length $idx] >= 2} {
	set index $data(anchorCol)
    ##nagelfar ignore
    } elseif {[scan $idx "@%d,%d%n" x y count] == 3 &&
	      $count == [string length $idx]} {
	synchronize $win
	displayItems $win
	if {$decrX} {
	    incr x -[winfo x $data(body)]
	    if {$x > $data(rightX)} {
		set x $data(rightX)
	    } elseif {$x < 0} {
		set x 0
	    }
	}

	#
	# Get the (scheduled) x coordinate of $data(hdrTxtFrm)
	#
	set bbox [$data(hdrTxt) bbox 1.0]
	set viewChanged 0
	if {[llength $bbox] == 0} {
	    $data(hdrTxt) yview 0
	    set bbox [$data(hdrTxt) bbox 1.0]
	    set viewChanged 1
	}
	set baseX [lindex $bbox 0]
	if {$viewChanged} {
	    $data(hdrTxt) yview 1
	}

	set lastVisibleCol -1
	for {set col 0} {$col < $data(colCount)} {incr col} {
	    if {$data($col-elide) || $data($col-hide)} {
		continue
	    }

	    set lastVisibleCol $col
	    set w $data(hdrTxtFrmLbl)$col
	    set wX [expr {$baseX + [lindex [place configure $w -x] 4]}]
	    if {$x >= $wX && $x < $wX + [winfo width $w]} {
		return $col
	    }
	}
	set index $lastVisibleCol
    } else {
	set idxIsEmpty [expr {$idx eq ""}]
	for {set col 0} {$col < $data(colCount)} {incr col} {
	    set hasName [info exists data($col-name)]
	    if {($hasName && $idx eq $data($col-name)) ||
		(!$hasName && $idxIsEmpty)} {
		set index $col
		break
	    }
	}
	if {$col == $data(colCount)} {
	    return -code error \
		   "bad column index \"$idx\": must be active, anchor,\
		    end, last, left, right, @x,y, a number, or a name"
	}
    }

    if {$checkRange && ($index < 0 || $index > $data(lastCol))} {
	return -code error "column index \"$idx\" out of range"
    } else {
	return $index
    }
}

#------------------------------------------------------------------------------
# tablelist::colIndex2
#
# Returns the numerical equivalent of the column index idx.  Invoked by the
# dicttoitem and itemtodict subcommands.
#------------------------------------------------------------------------------
proc tablelist::colIndex2 {win idx} {
    upvar ::tablelist::ns${win}::data data

    if {[isInteger $idx]} {
	return [expr {int($idx)}]
    } elseif {[string first $idx "end"] == 0 ||
	      [string first $idx "last"] == 0} {
	return $data(lastCol)
    } elseif {[string first $idx "left"] == 0} {
	return [colIndex $win @0,0 0 0]
    } elseif {[string first $idx "right"] == 0} {
	return [colIndex $win @$data(rightX),0 0 0]
    } elseif {[string first $idx "active"] == 0 && [string length $idx] >= 2} {
	return $data(activeCol)
    } elseif {[string first $idx "anchor"] == 0 && [string length $idx] >= 2} {
	return $data(anchorCol)
    ##nagelfar ignore
    } elseif {[scan $idx "@%d,%d%n" x y count] == 3 &&
	      $count == [string length $idx]} {
	return [colIndex $win @$x,$y 0 1]
    } else {
	set idxIsEmpty [expr {$idx eq ""}]
	for {set col 0} {$col < $data(colCount)} {incr col} {
	    set hasName [info exists data($col-name)]
	    if {($hasName && $idx eq $data($col-name)) ||
		(!$hasName && $idxIsEmpty)} {
		return $col
	    }
	}

	return -1
    }
}

#------------------------------------------------------------------------------
# tablelist::cellIndex
#
# Checks the cell index idx and returns either a list of the form {row col} or
# an error.  checkRange must be a boolean value: if true, it is additionally
# checked whether the two numerical values corresponding to idx are within the
# respective allowed ranges.
#------------------------------------------------------------------------------
proc tablelist::cellIndex {win idx checkRange} {
    upvar ::tablelist::ns${win}::data data

    set lst [split $idx ","]
    if {[llength $lst] == 2 &&
	[catch {rowIndex $win [lindex $lst 0] 0} row] == 0 &&
	[catch {colIndex $win [lindex $lst 1] 0} col] == 0} {
	# nothing
    } elseif {[string first $idx "end"] == 0 ||
	      [string first $idx "last"] == 0} {
	set row [rowIndex $win $idx 0]
	set col [colIndex $win $idx 0]
    } elseif {[string first $idx "active"] == 0 && [string length $idx] >= 2} {
	set row $data(activeRow)
	set col $data(activeCol)
    } elseif {[string first $idx "anchor"] == 0 && [string length $idx] >= 2} {
	set row $data(anchorRow)
	set col $data(anchorCol)
    } elseif {[string index $idx 0] eq "@" &&
	      [catch {rowIndex $win $idx 0} row] == 0 &&
	      [catch {colIndex $win $idx 0} col] == 0} {
	# nothing
    } else {
	return -code error \
	       "bad cell index \"$idx\": must be active, anchor, end, last,\
	        @x,y, or row,col, where row must be active, anchor, end, last,\
		top, bottom, a number, a full key, or a name, and col must be\
		active, anchor, end, last, left, right, a number, or a name"
    }

    if {$checkRange && ($row < 0 || $row > $data(lastRow) ||
	$col < 0 || $col > $data(lastCol))} {
	return -code error "cell index \"$idx\" out of range"
    } else {
	return [list $row $col]
    }
}

#------------------------------------------------------------------------------
# tablelist::hdr_cellIndex
#
# Checks the header cell index idx and returns either a list of the form {row
# col} or an error.  checkRange must be a boolean value: if true, it is
# additionally checked whether the two numerical values corresponding to idx
# are within the respective allowed ranges.
#------------------------------------------------------------------------------
proc tablelist::hdr_cellIndex {win idx checkRange} {
    upvar ::tablelist::ns${win}::data data

    set lst [split $idx ","]
    if {[llength $lst] == 2 &&
	[catch {hdr_rowIndex $win [lindex $lst 0] 0} row] == 0 &&
	[catch {colIndex $win [lindex $lst 1] 0} col] == 0} {
	# nothing
    } elseif {[string first $idx "end"] == 0 ||
	      [string first $idx "last"] == 0} {
	set row [hdr_rowIndex $win $idx 0]
	set col [colIndex $win $idx 0]
    } elseif {[string index $idx 0] eq "@" &&
	      [catch {hdr_rowIndex $win $idx 0} row] == 0 &&
	      [catch {colIndex $win $idx 0} col] == 0} {
	# nothing
    } else {
	return -code error \
	       "bad header cell index \"$idx\": must be end, last, @x,y, or\
	        row,col, where row must be end, last, a number, a full header\
		key, or a name, and col must be active, anchor, end, last,\
		left, right, a number, or a name"
    }

    if {$checkRange && ($row < 0 || $row > $data(hdr_lastRow) ||
	$col < 0 || $col > $data(lastCol))} {
	return -code error "header cell index \"$idx\" out of range"
    } else {
	return [list $row $col]
    }
}

#------------------------------------------------------------------------------
# tablelist::adjustRowIndex
#
# Sets the row index specified by $rowName to the index of the nearest
# (viewable) row.
#------------------------------------------------------------------------------
proc tablelist::adjustRowIndex {win rowName {forceViewable 0}} {
    upvar ::tablelist::ns${win}::data data $rowName row

    #
    # Don't operate on row directly, because $rowName might
    # be data(activeRow), in which case any temporary changes
    # made on row would trigger the activeTrace procedure
    #
    set _row $row
    if {$_row > $data(lastRow)} {
	set _row $data(lastRow)
    }
    if {$_row < 0} {
	set _row 0
    }

    if {$forceViewable} {
	set _rowSav $_row
	set itemCount $data(itemCount)
	for {} {$_row < $itemCount} {incr _row} {
	    set key [lindex $data(keyList) $_row]
	    if {![info exists data($key-elide)] &&
		![info exists data($key-hide)]} {
		set row $_row
		return ""
	    }
	}
	for {set _row [expr {$_rowSav - 1}]} {$_row >= 0} {incr _row -1} {
	    set key [lindex $data(keyList) $_row]
	    if {![info exists data($key-elide)] &&
		![info exists data($key-hide)]} {
		set row $_row
		return ""
	    }
	}
	set row 0
    } else {
	set row $_row
    }
}

#------------------------------------------------------------------------------
# tablelist::adjustColIndex
#
# Sets the column index specified by $colName to the index of the nearest
# (viewable) column.
#------------------------------------------------------------------------------
proc tablelist::adjustColIndex {win colName {forceViewable 0}} {
    upvar ::tablelist::ns${win}::data data $colName col

    #
    # Don't operate on col directly, because $colName might
    # be data(activeCol), in which case any temporary changes
    # made on col would trigger the activeTrace procedure
    #
    set _col $col
    if {$_col > $data(lastCol)} {
	set _col $data(lastCol)
    }
    if {$_col < 0} {
	set _col 0
    }

    if {$forceViewable} {
	set _colSav $_col
	for {} {$_col < $data(colCount)} {incr _col} {
	    if {!$data($_col-hide)} {
		set col $_col
		return ""
	    }
	}
	for {set _col [expr {$_colSav - 1}]} {$_col >= 0} {incr _col -1} {
	    if {!$data($_col-hide)} {
		set col $_col
		return ""
	    }
	}
	set _col 0
    } else {
	set col $_col
    }
}

#------------------------------------------------------------------------------
# tablelist::nodeIndexToKey
#
# Checks the node index idx and returns either the corresponding full key or
# "root", or an error.
#------------------------------------------------------------------------------
proc tablelist::nodeIndexToKey {win idx} {
    if {[string first $idx "root"] == 0} {
	return "root"
    } elseif {[catch {rowIndex $win $idx 0} row] == 0} {
	upvar ::tablelist::ns${win}::data data
	if {$row < 0 || $row > $data(lastRow)} {
	    return -code error "node index \"$idx\" out of range"
	} else {
	    return [lindex $data(keyList) $row]
	}
    } else {
	return -code error \
	       "bad node index \"$idx\": must be root, active, anchor, end,\
		last, top, bottom, @x,y, a number, a full key, or a name"
    }
}

#------------------------------------------------------------------------------
# tablelist::depth
#
# Returns the number of steps from the node with the given full key to the root
# node of the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::depth {win key} {
    upvar ::tablelist::ns${win}::data data

    set depth 0
    while {$key ne "root"} {
	incr depth
	set key $data($key-parent)
    }

    return $depth
}

#------------------------------------------------------------------------------
# tablelist::topLevelKey
#
# Returns the full key of the top-level item of the tablelist widget win having
# the item with the given key as descendant.
#------------------------------------------------------------------------------
proc tablelist::topLevelKey {win key} {
    upvar ::tablelist::ns${win}::data data

    set parentKey $data($key-parent)
    while {$parentKey ne "root"} {
	set key $data($key-parent)
	set parentKey $data($key-parent)
    }

    return $key
}

#------------------------------------------------------------------------------
# tablelist::descCount
#
# Returns the number of descendants of the node with the given full key of the
# tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::descCount {win key} {
    upvar ::tablelist::ns${win}::data data

    if {$key eq "root"} {
	return $data(itemCount)
    } else {
	#
	# Level-order traversal
	#
	set count 0
	set lst1 [list $key]
	while {[llength $lst1] != 0} {
	    set lst2 {}
	    foreach key $lst1 {
		incr count [llength $data($key-childList)]
		foreach childKey $data($key-childList) {
		    lappend lst2 $childKey
		}
	    }
	    set lst1 $lst2
	}

	return $count
    }
}

#------------------------------------------------------------------------------
# tablelist::nodeRow
#
# Returns the row of the child item identified by childIdx of the node given by
# parentKey within the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::nodeRow {win parentKey childIdx} {
    upvar ::tablelist::ns${win}::data data

    if {[isInteger $childIdx]} {
	if {$childIdx < [llength $data($parentKey-childList)]} {
	    set childKey [lindex $data($parentKey-childList) $childIdx]
	    return [keyToRow $win $childKey]
	} else {
	    return [expr {[keyToRow $win $parentKey] +
			  [descCount $win $parentKey] + 1}]
	}
    } elseif {[string first $childIdx "end"] == 0} {
	return [expr {[keyToRow $win $parentKey] +
		      [descCount $win $parentKey] + 1}]
    } elseif {[string first $childIdx "last"] == 0} {
	set childKey [lindex $data($parentKey-childList) end]
	return [keyToRow $win $childKey]
    } else {
	return -code error \
	       "bad child index \"$childIdx\": must be end, last, or a number"
    }
}

#------------------------------------------------------------------------------
# tablelist::keyToRow
#
# Returns the row corresponding to the given full key within the tablelist
# widget win.
#------------------------------------------------------------------------------
proc tablelist::keyToRow {win key} {
    upvar ::tablelist::ns${win}::data data
    if {$key eq "root"} {
	return -1
    } elseif {$data(keyToRowMapValid) && [info exists data($key-row)]} {
	return $data($key-row)
    } else {
	#
	# Speed up the search by starting at the last found position
	#
	set row [lsearch -exact -start $data(searchStartIdx) \
		 $data(keyList) $key]
	if {$row < 0 && $data(searchStartIdx) != 0} {
	    set row [lsearch -exact $data(keyList) $key]
	}
	if {$row >= 0} {
	    set data(searchStartIdx) $row
	}

	return $row
    }
}

#------------------------------------------------------------------------------
# tablelist::hdr_keyToRow
#
# Returns the header row corresponding to the given full header key within the
# tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::hdr_keyToRow {win key} {
    upvar ::tablelist::ns${win}::data data
    return [lsearch -exact $data(hdr_keyList) $key]
}

#------------------------------------------------------------------------------
# tablelist::updateKeyToRowMap
#
# Updates the key -> row map associated with the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::updateKeyToRowMap win {
    upvar ::tablelist::ns${win}::data data
    unset data(mapId)

    set row 0
    foreach key $data(keyList) {
	set data($key-row) $row
	incr row
    }

    set data(keyToRowMapValid) 1
}

#------------------------------------------------------------------------------
# tablelist::findTabs
#
# Searches for the first and last occurrences of the tab character in the cell
# range specified by firstCol and lastCol in the given line of the text widget
# descendant w of the tablelist widget win.  Assigns the index of the first tab
# to $idx1Name and the index of the last tab to $idx2Name.  It is assumed that
# both columns are non-hidden (but there may be hidden ones between them).
#------------------------------------------------------------------------------
proc tablelist::findTabs {win w line firstCol lastCol idx1Name idx2Name} {
    upvar ::tablelist::ns${win}::data data $idx1Name idx1 $idx2Name idx2

    if {$::tk_version >= 8.5} {
	set idxList [$w search -all -elide "\t" $line.0 $line.end]
	if {[llength $idxList] == 0} {
	    return 0
	}

	set idx1 [lindex $idxList [expr {2*$firstCol}]]
	set idx2 [lindex $idxList [expr {2*$lastCol + 1}]]
	return 1
    } else {
	variable pu
	set endIdx $line.end

	set idx $line.1
	for {set col 0} {$col < $firstCol} {incr col} {
	    set idx [$w search -elide "\t" $idx $endIdx]+2$pu
	    if {$idx eq "+2$pu"} {
		return 0
	    }
	}
	set idx1 [$w index $idx-1$pu]

	for {} {$col < $lastCol} {incr col} {
	    set idx [$w search -elide "\t" $idx $endIdx]+2$pu
	    if {$idx eq "+2$pu"} {
		return 0
	    }
	}
	set idx2 [$w search -elide "\t" $idx $endIdx]
	if {$idx2 eq ""} {
	    return 0
	}

	return 1
    }
}

#------------------------------------------------------------------------------
# tablelist::sortStretchableColList
#
# Replaces the column indices different from end and last in the list of the
# stretchable columns of the tablelist widget win with their numerical
# equivalents and sorts the resulting list.
#------------------------------------------------------------------------------
proc tablelist::sortStretchableColList win {
    upvar ::tablelist::ns${win}::data data
    if {[llength $data(-stretch)] == 0 || $data(-stretch) eq "all"} {
	return ""
    }

    set containsEnd 0
    foreach elem $data(-stretch) {
	if {[string first $elem "end"] == 0 ||
	    [string first $elem "last"] == 0} {
	    set containsEnd 1
	} else {
	    set tmp([colIndex $win $elem 0]) ""
	}
    }

    set data(-stretch) [lsort -integer [array names tmp]]
    if {$containsEnd} {
	lappend data(-stretch) end
    }
}

#------------------------------------------------------------------------------
# tablelist::deleteColData
#
# Cleans up the data associated with the col'th column of the tablelist widget
# win.
#------------------------------------------------------------------------------
proc tablelist::deleteColData {win col} {
    upvar ::tablelist::ns${win}::data data
    if {$data(editCol) == $col} {
	set data(editCol) -1
	set data(editRow) -1
    }

    #
    # Remove the elements having names of the form $col-*
    #
    if {[info exists data($col-redispId)]} {
	after cancel $data($col-redispId)
    }
    array unset data $col-*

    #
    # Remove the elements having names of the form hk*,$col-*
    #
    array unset data hk*,$col-*

    #
    # Remove the elements having names of the form k*,$col-*
    #
    foreach name [array names data k*,$col-*] {
	unset data($name)
	if {[string match "k*,$col-font" $name]} {
	    incr data(cellTagRefCount) -1
	} elseif {[string match "k*,$col-image" $name]} {
	    incr data(imgCount) -1
	} elseif {[string match "k*,$col-window" $name]} {
	    incr data(winCount) -1
	} elseif {[string match "k*,$col-indent" $name]} {
	    incr data(indentCount) -1
	}
    }

    #
    # Remove col from the list of stretchable columns if explicitly specified
    #
    if {$data(-stretch) ne "all"} {
	set stretchableCols {}
	foreach elem $data(-stretch) {
	    if {$elem != $col} {
		lappend stretchableCols $elem
	    }
	}
	set data(-stretch) $stretchableCols
    }
}

#------------------------------------------------------------------------------
# tablelist::deleteColAttribs
#
# Cleans up the attributes associated with the col'th column of the tablelist
# widget win.
#------------------------------------------------------------------------------
proc tablelist::deleteColAttribs {win col} {
    upvar ::tablelist::ns${win}::attribs attribs

    #
    # Remove the elements having names of the
    # form $col-*, hk*,$col-*, and k*,$col-*
    #
    array unset attribs $col-*
    array unset attribs hk*,$col-*
    array unset attribs k*,$col-*
}

#------------------------------------------------------------------------------
# tablelist::deleteColSelStates
#
# Cleans up the selection states associated with the col'th column of the
# tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::deleteColSelStates {win col} {
    upvar ::tablelist::ns${win}::selStates selStates

    #
    # Remove the elements having names of the form k*,$col
    #
    array unset selStates k*,$col
}

#------------------------------------------------------------------------------
# tablelist::moveColData
#
# Moves the elements of oldArrName corresponding to oldCol to those of
# newArrName corresponding to newCol.
#------------------------------------------------------------------------------
proc tablelist::moveColData {oldArrName newArrName imgArrName oldCol newCol} {
    upvar $oldArrName oldArr $newArrName newArr $imgArrName imgArr

    foreach specialCol {editCol -treecolumn treeCol} {
	if {$oldArr($specialCol) == $oldCol} {
	    set newArr($specialCol) $newCol
	}
    }

    set callerProc [lindex [info level -1] 0]
    if {$callerProc eq "moveCol"} {
	foreach specialCol {activeCol anchorCol} {
	    if {$oldArr($specialCol) == $oldCol} {
		set newArr($specialCol) $newCol
	    }
	}
    }

    if {$newCol < $newArr(colCount)} {
	foreach l [getSublabels $newArr(hdrTxtFrmLbl)$newCol] {
	    destroy $l
	}
	set newArr(fmtCmdFlagList) \
	    [lreplace $newArr(fmtCmdFlagList) $newCol $newCol 0]
    }

    #
    # Move the elements of oldArr having names of the form $oldCol-*
    # to those of newArr having names of the form $newCol-*
    #
    array unset newArr $newCol-*
    foreach oldName [array names oldArr $oldCol-*] {
	regsub "$oldCol-" $oldName "$newCol-" newName
	set newArr($newName) $oldArr($oldName)
	unset oldArr($oldName)

	set tail [lindex [split $newName "-"] 1]
	switch $tail {
	    formatcommand {
		if {$newCol < $newArr(colCount)} {
		    set newArr(fmtCmdFlagList) \
			[lreplace $newArr(fmtCmdFlagList) $newCol $newCol 1]
		}
	    }
	    labelimage -
	    labelwindow {
		set imgArr($newCol-$tail) $newArr($newName)
		unset newArr($newName)
	    }
	}
    }

    #
    # Move the elements of oldArr having names of the form hk*,$oldCol-*
    # to those of newArr having names of the form hk*,$newCol-*
    #
    array unset newArr hk*,$newCol-*
    foreach oldName [array names oldArr hk*,$oldCol-*] {
	regsub -- ",$oldCol-" $oldName ",$newCol-" newName
	set newArr($newName) $oldArr($oldName)
	unset oldArr($oldName)
    }

    #
    # Move the elements of oldArr having names of the form k*,$oldCol-*
    # to those of newArr having names of the form k*,$newCol-*
    #
    array unset newArr k*,$newCol-*
    foreach oldName [array names oldArr k*,$oldCol-*] {
	regsub -- ",$oldCol-" $oldName ",$newCol-" newName
	set newArr($newName) $oldArr($oldName)
	unset oldArr($oldName)
    }

    #
    # Replace oldCol with newCol in the list of
    # stretchable columns if explicitly specified
    #
    if {[info exists oldArr(-stretch)] && $oldArr(-stretch) ne "all"} {
	set stretchableCols {}
	foreach elem $oldArr(-stretch) {
	    if {$elem == $oldCol} {
		lappend stretchableCols $newCol
	    } else {
		lappend stretchableCols $elem
	    }
	}
	set newArr(-stretch) $stretchableCols
    }
}

#------------------------------------------------------------------------------
# tablelist::moveColAttribs
#
# Moves the elements of oldArrName corresponding to oldCol to those of
# newArrName corresponding to newCol.
#------------------------------------------------------------------------------
proc tablelist::moveColAttribs {oldArrName newArrName oldCol newCol} {
    upvar $oldArrName oldArr $newArrName newArr

    #
    # Move the elements of oldArr having names of the form $oldCol-*
    # to those of newArr having names of the form $newCol-*
    #
    array unset newArr $newCol-*
    foreach oldName [array names oldArr $oldCol-*] {
	regsub "$oldCol-" $oldName "$newCol-" newName
	set newArr($newName) $oldArr($oldName)
	unset oldArr($oldName)
    }

    #
    # Move the elements of oldArr having names of the form hk*,$oldCol-*
    # to those of newArr having names of the form hk*,$newCol-*
    #
    array unset newArr hk*,$newCol-*
    foreach oldName [array names oldArr hk*,$oldCol-*] {
	regsub -- ",$oldCol-" $oldName ",$newCol-" newName
	set newArr($newName) $oldArr($oldName)
	unset oldArr($oldName)
    }

    #
    # Move the elements of oldArr having names of the form k*,$oldCol-*
    # to those of newArr having names of the form k*,$newCol-*
    #
    array unset newArr k*,$newCol-*
    foreach oldName [array names oldArr k*,$oldCol-*] {
	regsub -- ",$oldCol-" $oldName ",$newCol-" newName
	set newArr($newName) $oldArr($oldName)
	unset oldArr($oldName)
    }
}

#------------------------------------------------------------------------------
# tablelist::moveColSelStates
#
# Moves the elements of oldArrName corresponding to oldCol to those of
# newArrName corresponding to newCol.
#------------------------------------------------------------------------------
proc tablelist::moveColSelStates {oldArrName newArrName oldCol newCol} {
    upvar $oldArrName oldArr $newArrName newArr

    #
    # Move the elements of oldArr having names of the form k*,$oldCol
    # to those of newArr having names of the form k*,$newCol
    #
    array unset newArr k*,$newCol
    foreach oldName [array names oldArr k*,$oldCol] {
	regsub -- ",$oldCol" $oldName ",$newCol" newName
	set newArr($newName) $oldArr($oldName)
	unset oldArr($oldName)
    }
}

#------------------------------------------------------------------------------
# tablelist::condUpdateListVar
#
# Updates the list variable of the tablelist widget win if present.
#------------------------------------------------------------------------------
proc tablelist::condUpdateListVar win {
    upvar ::tablelist::ns${win}::data data
    if {$data(hasListVar)} {
	upvar #0 $data(-listvariable) var
	trace remove variable var {write unset} $data(listVarTraceCmd)
	set var {}
	foreach item $data(itemList) {
	    lappend var [lrange $item 0 $data(lastCol)]
	}
	trace add variable var {write unset} $data(listVarTraceCmd)
    }
}

#------------------------------------------------------------------------------
# tablelist::reconfigColLabels
#
# Reconfigures the labels of the col'th column of the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::reconfigColLabels {win imgArrName col} {
    upvar ::tablelist::ns${win}::data data $imgArrName imgArr

    set optList {-labelalign -labelborderwidth -labelfont -labelforeground
		 -labelpady -labelrelief -labelvalign}
    variable usingTile
    if {!$usingTile} {
	lappend optList -labelbackground -labelheight
    }

    foreach opt $optList {
	if {[info exists data($col$opt)]} {
	    doColConfig $col $win $opt $data($col$opt)
	} else {
	    doColConfig $col $win $opt ""
	}
    }

    if {[info exists imgArr($col-labelimage)]} {
	doColConfig $col $win -labelimage $imgArr($col-labelimage)
    }
    if {[info exists imgArr($col-labelwindow)]} {
	doColConfig $col $win -labelwindow $imgArr($col-labelwindow)
    }
}

#------------------------------------------------------------------------------
# tablelist::charsToPixels
#
# Returns the width in pixels of the string consisting of a given number of "0"
# characters.
#------------------------------------------------------------------------------
proc tablelist::charsToPixels {win font charCount} {
    return [expr {[font measure $font -displayof $win "0"] * $charCount}]
}

#------------------------------------------------------------------------------
# tablelist::strRange
#
# Gets the largest initial (for snipSide = r) or final (for snipSide = l) range
# of characters from str whose width, when displayed in the given font, is no
# greater than pixels decremented by the width of snipStr.  Returns a string
# obtained from this substring by appending (for snipSide = r) or prepending
# (for snipSide = l) (part of) snipStr to it.
#------------------------------------------------------------------------------
proc tablelist::strRange {win str font pixels snipSide snipStr} {
    if {$pixels < 0} {
	return ""
    }

    if {$snipSide eq ""} {
	return $str
    }


    set width [font measure $font -displayof $win $str]
    if {$width <= $pixels} {
	return $str
    }

    set snipWidth [font measure $font -displayof $win $snipStr]
    if {$pixels <= $snipWidth} {
	set str $snipStr
	set snipStr ""
    } else {
	incr pixels -$snipWidth
    }

    if {$snipSide eq "r"} {
	set idx [expr {[string length $str]*$pixels/$width - 1}]
	set subStr [string range $str 0 $idx]
	set width [font measure $font -displayof $win $subStr]
	if {$width < $pixels} {
	    while 1 {
		incr idx
		set subStr [string range $str 0 $idx]
		set width [font measure $font -displayof $win $subStr]
		if {$width > $pixels} {
		    incr idx -1
		    set subStr [string range $str 0 $idx]
		    return $subStr$snipStr
		} elseif {$width == $pixels} {
		    return $subStr$snipStr
		}
	    }
	} elseif {$width == $pixels} {
	    return $subStr$snipStr
	} else {
	    while 1 {
		incr idx -1
		set subStr [string range $str 0 $idx]
		set width [font measure $font -displayof $win $subStr]
		if {$width <= $pixels} {
		    return $subStr$snipStr
		}
	    }
	}

    } else {
	set idx [expr {[string length $str]*($width - $pixels)/$width}]
	set subStr [string range $str $idx end]
	set width [font measure $font -displayof $win $subStr]
	if {$width < $pixels} {
	    while 1 {
		incr idx -1
		set subStr [string range $str $idx end]
		set width [font measure $font -displayof $win $subStr]
		if {$width > $pixels} {
		    incr idx
		    set subStr [string range $str $idx end]
		    return $snipStr$subStr
		} elseif {$width == $pixels} {
		    return $snipStr$subStr
		}
	    }
	} elseif {$width == $pixels} {
	    return $snipStr$subStr
	} else {
	    while 1 {
		incr idx
		set subStr [string range $str $idx end]
		set width [font measure $font -displayof $win $subStr]
		if {$width <= $pixels} {
		    return $snipStr$subStr
		}
	    }
	}
    }
}

#------------------------------------------------------------------------------
# tablelist::adjustItem
#
# Returns the list obtained by adjusting the list specified by item to the
# length expLen.
#------------------------------------------------------------------------------
proc tablelist::adjustItem {item expLen} {
    set len [llength $item]
    if {$len == $expLen} {
	return $item
    } elseif {$len > $expLen} {
	return [lrange $item 0 [expr {$expLen - 1}]]
    } else {
	for {set n $len} {$n < $expLen} {incr n} {
	    lappend item ""
	}
	return $item
    }
}

#------------------------------------------------------------------------------
# tablelist::formatElem
#
# Returns the string obtained by formatting the last argument.
#------------------------------------------------------------------------------
proc tablelist::formatElem {win key row col text} {
    upvar ::tablelist::ns${win}::data data
    array set data [list fmtKey $key fmtRow $row fmtCol $col]

    return [uplevel #0 $data($col-formatcommand) [list $text]]
}

#------------------------------------------------------------------------------
# tablelist::formatItem
#
# Returns the list obtained by formatting the elements of the last argument.
#------------------------------------------------------------------------------
proc tablelist::formatItem {win key row item} {
    upvar ::tablelist::ns${win}::data data
    array set data [list fmtKey $key fmtRow $row]
    set formattedItem {}
    set col 0
    foreach text $item fmtCmdFlag $data(fmtCmdFlagList) {
	if {$fmtCmdFlag} {
	    set data(fmtCol) $col
	    set text [uplevel #0 $data($col-formatcommand) [list $text]]
	}
	lappend formattedItem $text
	incr col
    }

    return $formattedItem
}

#------------------------------------------------------------------------------
# tablelist::hasChars
#
# Checks whether at least one element of the given list is a nonempty string.
#------------------------------------------------------------------------------
proc tablelist::hasChars list {
    foreach str $list {
	if {$str ne ""} {
	    return 1
	}
    }

    return 0
}

#------------------------------------------------------------------------------
# tablelist::getListWidth
#
# Returns the max. number of pixels that the elements of the given list would
# use in the specified font when displayed in the window win.
#------------------------------------------------------------------------------
proc tablelist::getListWidth {win list font} {
    set width 0
    foreach str $list {
	set strWidth [font measure $font -displayof $win $str]
	if {$strWidth > $width} {
	    set width $strWidth
	}
    }

    return $width
}

#------------------------------------------------------------------------------
# tablelist::joinList
#
# Returns the string formed by joining together with "\n" the strings obtained
# by applying strRange to the elements of the given list, with the specified
# arguments.
#------------------------------------------------------------------------------
proc tablelist::joinList {win list font pixels snipSide snipStr} {
    set list2 {}
    foreach str $list {
	lappend list2 [strRange $win $str $font $pixels $snipSide $snipStr]
    }

    return [join $list2 "\n"]
}

#------------------------------------------------------------------------------
# tablelist::displayIndent
#
# Displays an indentation image in a label widget to be embedded into the
# specified cell of the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::displayIndent {win key col width} {
    upvar ::tablelist::ns${win}::data data
    set w $data(body).ind_$key,$col

    if {![winfo exists $w]} {
	#
	# Create a label widget and replace the binding tag Label with
	# $data(bodyTag) and TablelistBody in the list of its binding tags
	#
	set idx [string last "g" $data($key,$col-indent)]
	set img [string range $data($key,$col-indent) 0 $idx]
	tk::label $w -anchor e -background $data(-background) -borderwidth 0 \
		     -height 0 -highlightthickness 0 -image $img \
		     -padx 0 -pady 0 -relief flat -takefocus 0 -width $width
	bindtags $w [lreplace [bindtags $w] 1 1 $data(bodyTag) TablelistBody]
    }

    updateColorsWhenIdle $win
    return $w
}

#------------------------------------------------------------------------------
# tablelist::displayImage
#
# Displays an image in a label widget to be embedded into the specified cell of
# the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::displayImage {win key col anchor width} {
    upvar ::tablelist::ns${win}::data data
    set inBody [string match "k*" $key]
    if {$inBody} {
	set w $data(body).img_$key,$col
    } else {
	set w $data(hdrTxt).img_$key,$col
    }

    if {![winfo exists $w]} {
	#
	# Create a label widget and replace the binding tag Label
	# with either $data(bodyTag) and TablelistBody or data(headerTag)
	# and TablelistHeader in the list of its binding tags
	#
	tk::label $w -anchor $anchor -background $data(-background) \
		     -borderwidth 0 -height 0 -highlightthickness 0 \
		     -image $data($key,$col-image) -padx 0 -pady 0 \
		     -relief flat -takefocus 0 -width $width
	if {$inBody} {
	    bindtags $w [lreplace [bindtags $w] 1 1 $data(bodyTag) \
			 TablelistBody]
	} else {
	    bindtags $w [lreplace [bindtags $w] 1 1 $data(headerTag) \
			 TablelistHeader]
	}
    }

    if {$inBody} {
	updateColorsWhenIdle $win
    } else {
	hdr_updateColorsWhenIdle $win
    }
    return $w
}

#------------------------------------------------------------------------------
# tablelist::displayText
#
# Displays the given text in a message widget to be embedded into the specified
# cell of the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::displayText {win key col text font pixels alignment} {
    upvar ::tablelist::ns${win}::data data
    set inBody [string match "k*" $key]
    if {$inBody} {
	set w $data(body).msg_$key,$col
    } else {
	set w $data(hdrTxt).msg_$key,$col
    }

    if {![winfo exists $w]} {
	#
	# Create a message widget and replace the binding tag Message
	# with either $data(bodyTag) and TablelistBody or data(headerTag)
	# and TablelistHeader in the list of its binding tags
	#
	message $w -background $data(-background) -borderwidth 0 \
		   -highlightthickness 0 -padx 0 -pady 0 -relief flat \
		   -takefocus 0
	if {$inBody} {
	    bindtags $w [lreplace [bindtags $w] 1 1 $data(bodyTag) \
			 TablelistBody]
	} else {
	    bindtags $w [lreplace [bindtags $w] 1 1 $data(headerTag) \
			 TablelistHeader]
	}
    }

    variable anchors
    set width $pixels
    if {$pixels == 0} {
	set width 1000000
    }
    $w configure -anchor $anchors($alignment) -font $font \
		 -justify $alignment -text $text -width $width

    if {$inBody} {
	updateColorsWhenIdle $win
    } else {
	hdr_updateColorsWhenIdle $win
    }
    return $w
}

#------------------------------------------------------------------------------
# tablelist::getAuxData
#
# Gets the name, type, and width of the image or window associated with the
# specified cell of the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::getAuxData {win key col auxTypeName auxWidthName {pixels 0}} {
    upvar ::tablelist::ns${win}::data data \
	  $auxTypeName auxType $auxWidthName auxWidth

    if {[info exists data($key,$col-window)]} {
	if {$pixels != 0 && [getOpt $win $key $col -stretchwindow]} {
	    set auxType 3				;# dynamic-width window
	    set auxWidth [expr {$pixels + $data($col-delta)}]
	} else {
	    set auxType 2				;# static-width window
	    set auxWidth $data($key,$col-reqWidth)
	}

	if {[string match "k*" $key]} {
	    return $data(body).frm_$key,$col
	} else {
	    return $data(hdrTxt).frm_$key,$col
	}
    } elseif {[info exists data($key,$col-image)]} {
	set auxType 1					;# image
	set auxWidth [image width $data($key,$col-image)]
	return [list ::tablelist::displayImage $win $key $col w 0]
    } else {
	set auxType 0					;# none
	set auxWidth 0
	return ""
    }
}

#------------------------------------------------------------------------------
# tablelist::getIndentData
#
# Gets the creation script and width of the label displaying the indentation
# image associated with the specified cell of the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::getIndentData {win key col indentWidthName} {
    upvar ::tablelist::ns${win}::data data $indentWidthName indentWidth

    if {[info exists data($key,$col-indent)]} {
	#
	# Speed optimization: Replaced the regexp below with string operations
	#
	### regexp {^.+Img([0-9]+)$} $data($key,$col-indent) dummy depth
	set idx [string last "g" $data($key,$col-indent)]
	set depth [string range $data($key,$col-indent) [incr idx] end]

	variable treeLabelWidths
	set indentWidth $treeLabelWidths($data(-treestyle),$depth)
	return [list ::tablelist::displayIndent $win $key $col 0]
    } else {
	set indentWidth 0
	return ""
    }
}

#------------------------------------------------------------------------------
# tablelist::getMaxTextWidth
#
# Returns the number of pixels available for displaying the text of a static-
# width tablelist cell.
#------------------------------------------------------------------------------
proc tablelist::getMaxTextWidth {pixels auxWidth indentWidth} {
    if {$indentWidth != 0} {
	incr pixels -$indentWidth
	if {$pixels <= 0} {
	    set pixels 1
	}
    }

    if {$auxWidth == 0} {
	return $pixels
    } else {
	variable scaled4
	set lessPixels [expr {$pixels - $auxWidth - $scaled4 - 1}]
	if {$lessPixels > 0} {
	    return $lessPixels
	} else {
	    return 1
	}
    }
}

#------------------------------------------------------------------------------
# tablelist::adjustElem
#
# Prepares the text specified by $textName and the auxiliary object width
# specified by $auxWidthName for insertion into a cell of the tablelist widget
# win.
#------------------------------------------------------------------------------
proc tablelist::adjustElem {win textName auxWidthName indentWidthName font
			    pixels snipSide snipStr} {
    upvar $textName text $auxWidthName auxWidth $indentWidthName indentWidth

    if {$pixels == 0} {				;# convention: dynamic width
	if {$auxWidth != 0 && $text ne ""} {
	    variable scaled4
	    incr auxWidth [expr {$scaled4 - 1}]
	}
    } elseif {$indentWidth >= $pixels} {
	set indentWidth $pixels
	set text ""				;# can't display the text
	set auxWidth 0				;# can't display the aux. object
    } else {
	incr pixels -$indentWidth
	if {$auxWidth == 0} {			;# no image or window
	    set text [strRange $win $text $font $pixels $snipSide $snipStr]
	} elseif {$text eq ""} {		;# aux. object w/o text
	    if {$auxWidth > $pixels} {
		set auxWidth $pixels
	    }
	} else {				;# both aux. object and text
	    variable scaled4
	    set neededPixels [expr {$auxWidth + $scaled4 + 1}]
	    if {$neededPixels <= $pixels} {
		incr pixels -$neededPixels
		incr auxWidth [expr {$scaled4 - 1}]
		set text [strRange $win $text $font $pixels $snipSide $snipStr]
	    } elseif {$auxWidth <= $pixels} {
		set text ""			;# can't display the text
	    } else {
		set auxWidth $pixels
		set text ""			;# can't display the text
	    }
	}
    }
}

#------------------------------------------------------------------------------
# tablelist::adjustMlElem
#
# Prepares the list specified by $listName and the auxiliary object width
# specified by $auxWidthName for insertion into a multiline cell of the
# tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::adjustMlElem {win listName auxWidthName indentWidthName font
			      pixels snipSide snipStr} {
    upvar $listName list $auxWidthName auxWidth $indentWidthName indentWidth

    set list2 {}
    if {$pixels == 0} {				;# convention: dynamic width
	if {$auxWidth != 0 && [hasChars $list]} {
	    variable scaled4
	    incr auxWidth [expr {$scaled4 - 1}]
	}
    } elseif {$indentWidth >= $pixels} {
	set indentWidth $pixels
	foreach str $list {
	    lappend list2 ""
	}
	set list $list2				;# can't display the text
	set auxWidth 0				;# can't display the aux. object
    } else {
	incr pixels -$indentWidth
	if {$auxWidth == 0} {			;# no image or window
	    foreach str $list {
		lappend list2 \
		    [strRange $win $str $font $pixels $snipSide $snipStr]
	    }
	    set list $list2
	} elseif {![hasChars $list]} {		;# aux. object w/o text
	    if {$auxWidth > $pixels} {
		set auxWidth $pixels
	    }
	} else {				;# both aux. object and text
	    variable scaled4
	    set neededPixels [expr {$auxWidth + $scaled4 + 1}]
	    if {$neededPixels <= $pixels} {
		incr pixels -$neededPixels
		incr auxWidth [expr {$scaled4 - 1}]
		foreach str $list {
		    lappend list2 \
			[strRange $win $str $font $pixels $snipSide $snipStr]
		}
		set list $list2
	    } elseif {$auxWidth <= $pixels} {
		foreach str $list {
		    lappend list2 ""
		}
		set list $list2			;# can't display the text
	    } else {
		set auxWidth $pixels
		foreach str $list {
		    lappend list2 ""
		}
		set list $list2			;# can't display the text
	    }
	}
    }
}

#------------------------------------------------------------------------------
# tablelist::getElemWidth
#
# Returns the number of pixels that the given text together with the aux.
# object (image or window) of the specified width would use when displayed in a
# cell of a dynamic-width column of the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::getElemWidth {win text auxWidth indentWidth cellFont} {
    if {[string match "*\n*" $text]} {
	set list [split $text "\n"]
	if {$auxWidth != 0 && [hasChars $list]} {
	    variable scaled4
	    incr auxWidth [expr {$scaled4 + 1}]
	}
	return [expr {[getListWidth $win $list $cellFont] +
		      $auxWidth + $indentWidth}]
    } else {
	if {$auxWidth != 0 && $text ne ""} {
	    variable scaled4
	    incr auxWidth [expr {$scaled4 + 1}]
	}
	return [expr {[font measure $cellFont -displayof $win $text] +
		      $auxWidth + $indentWidth}]
    }
}

#------------------------------------------------------------------------------
# tablelist::insertOrUpdateIndent
#
# Sets the width of the indentation label embedded into the text widget w at
# the given index to the specified value, after inserting the label if needed.
# Returns 1 if the label had to be inserted and 0 otherwise.
#------------------------------------------------------------------------------
proc tablelist::insertOrUpdateIndent {w index indent indentWidth} {
    if {[catch {$w window cget $index -create} script] == 0 &&
	[string match "::tablelist::displayIndent *" $script]} {
	if {$indentWidth != [lindex $script end]} {
	    set padY [expr {[$w cget -spacing1] == 0}]
	    set script [lreplace $script end end $indentWidth]
	    $w window configure $index -pady $padY -create $script

	    set path [lindex [$w dump -window $index] 1]
	    if {$path ne ""} {
		$path configure -width $indentWidth
	    }
	}
	return 0
    } else {
	set padY [expr {[$w cget -spacing1] == 0}]
	set indent [lreplace $indent end end $indentWidth]
	$w window create $index -pady $padY -create $indent
	$w tag add elidedWin $index
	return 1
    }
}

#------------------------------------------------------------------------------
# tablelist::insertElem
#
# Inserts the given text and auxiliary object (image or window) into the text
# widget w, just before the character position specified by index.  The object
# will follow the text if alignment is "right", and will precede it otherwise.
#------------------------------------------------------------------------------
proc tablelist::insertElem {w index text aux auxType alignment valignment} {
    set index [$w index $index]

    if {$auxType == 0} {				;# no image or window
	$w insert $index $text
    } elseif {$alignment eq "right"} {
	set padY [expr {[$w cget -spacing1] == 0}]
	if {$auxType == 1} {					;# image
	    set aux [lreplace $aux 4 4 e]
	    $w window create $index -align $valignment -padx 1 -pady $padY \
		-create $aux
	    $w tag add elidedWin $index
	} else {						;# window
	    if {$auxType == 2} {				;# static width
		place $aux.w -anchor ne -relwidth "" -relx 1.0
	    } else {						;# dynamic width
		place $aux.w -anchor ne -relwidth 1.0 -relx 1.0
	    }
	    $w window create $index -align $valignment -padx 1 -pady $padY \
		-window $aux
	}
	$w insert $index $text
    } else {
	$w insert $index $text
	set padY [expr {[$w cget -spacing1] == 0}]
	if {$auxType == 1} {					;# image
	    set aux [lreplace $aux 4 4 w]
	    $w window create $index -align $valignment -padx 1 -pady $padY \
		-create $aux
	    $w tag add elidedWin $index
	} else {						;# window
	    if {$auxType == 2} {				;# static width
		place $aux.w -anchor nw -relwidth "" -relx 0.0
	    } else {						;# dynamic width
		place $aux.w -anchor nw -relwidth 1.0 -relx 0.0
	    }
	    $w window create $index -align $valignment -padx 1 -pady $padY \
		-window $aux
	}
    }
}

#------------------------------------------------------------------------------
# tablelist::insertMlElem
#
# Inserts the given message widget and auxiliary object (image or window) into
# the text widget w, just before the character position specified by index.
# The object will follow the message widget if alignment is "right", and will
# precede it otherwise.
#------------------------------------------------------------------------------
proc tablelist::insertMlElem {w index msgScript aux auxType alignment
			      valignment} {
    set index [$w index $index]
    set padY [expr {[$w cget -spacing1] == 0}]

    if {$auxType == 0} {				;# no image or window
	$w window create $index -pady $padY -create $msgScript
	$w tag add elidedWin $index
    } elseif {$alignment eq "right"} {
	if {$auxType == 1} {					;# image
	    set aux [lreplace $aux 4 4 e]
	    $w window create $index -align $valignment -padx 1 -pady $padY \
		-create $aux
	    $w tag add elidedWin $index
	} else {						;# window
	    if {$auxType == 2} {				;# static width
		place $aux.w -anchor ne -relwidth "" -relx 1.0
	    } else {						;# dynamic width
		place $aux.w -anchor ne -relwidth 1.0 -relx 1.0
	    }
	    $w window create $index -align $valignment -padx 1 -pady $padY \
		-window $aux
	}
	$w window create $index -pady $padY -create $msgScript
	$w tag add elidedWin $index
    } else {
	$w window create $index -pady $padY -create $msgScript
	$w tag add elidedWin $index
	if {$auxType == 1} {					;# image
	    set aux [lreplace $aux 4 4 w]
	    $w window create $index -align $valignment -padx 1 -pady $padY \
		-create $aux
	    $w tag add elidedWin $index
	} else {						;# window
	    if {$auxType == 2} {				;# static width
		place $aux.w -anchor nw -relwidth "" -relx 0.0
	    } else {						;# dynamic width
		place $aux.w -anchor nw -relwidth 1.0 -relx 0.0
	    }
	    $w window create $index -align $valignment -padx 1 -pady $padY \
		-window $aux
	}
    }
}

#------------------------------------------------------------------------------
# tablelist::updateCell
#
# Updates the content of the text widget w starting at index1 and ending just
# before index2 by keeping the auxiliary object (image or window) (if any) and
# replacing only the text between the two character positions.
#------------------------------------------------------------------------------
proc tablelist::updateCell {w index1 index2 text aux auxType auxWidth
			    indent indentWidth alignment valignment} {
    variable pu
    if {$indentWidth != 0} {
	if {[insertOrUpdateIndent $w $index1 $indent $indentWidth]} {
	    set index2 $index2+1$pu
	}
	set index1 $index1+1$pu
    }

    if {$auxWidth == 0} {				;# no image or window
	#
	# Work around a Tk peculiarity on Windows, related to deleting
	# an embedded window while resizing a text widget interactively
	#
	set path [lindex [$w dump -window $index1] 1]
	if {$path ne "" && [winfo class $path] eq "Message"} {
	    $path configure -text ""
	    $w window configure $index1 -window ""
	}

	if {$::tk_version >= 8.5} {
	    $w replace $index1 $index2 $text
	} else {
	    $w delete $index1 $index2
	    $w insert $index1 $text
	}
    } else {
	#
	# Check whether the image label or the frame containing a
	# window is mapped at the first or last position of the cell
	#
	if {$auxType == 1} {					;# image
	    if {[setImgLabelWidth $w $index1 $auxWidth]} {
		set auxFound 1
		set fromIdx $index1+1$pu
		set toIdx $index2
	    } elseif {[setImgLabelWidth $w $index2-1$pu $auxWidth]} {
		set auxFound 1
		set fromIdx $index1
		set toIdx $index2-1$pu
	    } else {
		set auxFound 0
		set fromIdx $index1
		set toIdx $index2
	    }
	} else {						;# window
	    if {[$aux cget -width] != $auxWidth} {
		$aux configure -width $auxWidth
	    }

	    if {[lindex [$w dump -window $index1] 1] eq $aux} {
		set auxFound 1
		set fromIdx $index1+1$pu
		set toIdx $index2
	    } elseif {[lindex [$w dump -window $index2-1$pu] 1] eq $aux} {
		set auxFound 1
		set fromIdx $index1
		set toIdx $index2-1$pu
	    } else {
		set auxFound 0
		set fromIdx $index1
		set toIdx $index2
	    }
	}

	#
	# Work around a Tk peculiarity on Windows, related to deleting
	# an embedded window while resizing a text widget interactively
	#
	set path [lindex [$w dump -window $fromIdx] 1]
	if {$path ne "" && [winfo class $path] eq "Message"} {
	    $path configure -text ""
	    $w window configure $fromIdx -window ""
	}

	$w delete $fromIdx $toIdx

	if {$auxFound} {
	    #
	    # Adjust the aux. window and insert the text
	    #
	    if {$alignment eq "right"} {
		if {$auxType == 1} {				;# image
		    setImgLabelAnchor $w $index1 e
		} else {					;# window
		    if {$auxType == 2} {			;# static width
			place $aux.w -anchor ne -relwidth "" -relx 1.0
		    } else {					;# dynamic width
			place $aux.w -anchor ne -relwidth 1.0 -relx 1.0
		    }
		}
		set index $index1
	    } else {
		if {$auxType == 1} {				;# image
		    setImgLabelAnchor $w $index1 w
		} else {					;# window
		    if {$auxType == 2} {			;# static width
			place $aux.w -anchor nw -relwidth "" -relx 0.0
		    } else {					;# dynamic width
			place $aux.w -anchor nw -relwidth 1.0 -relx 0.0
		    }
		}
		set index $index1+1$pu
	    }
	    if {$valignment ne [$w window cget $index1 -align]} {
		$w window configure $index1 -align $valignment
	    }
	    $w insert $index $text
	} else {
	    #
	    # Insert the text and the aux. window
	    #
	    if {$auxType == 1} {				;# image
		set aux [lreplace $aux end end $auxWidth]
	    } else {						;# window
		if {[$aux cget -width] != $auxWidth} {
		    $aux configure -width $auxWidth
		}
	    }
	    insertElem $w $index1 $text $aux $auxType $alignment $valignment
	}
    }
}

#------------------------------------------------------------------------------
# tablelist::updateMlCell
#
# Updates the content of the text widget w starting at index1 and ending just
# before index2 by keeping the auxiliary object (image or window) (if any) and
# replacing only the multiline text between the two character positions.
#------------------------------------------------------------------------------
proc tablelist::updateMlCell {w index1 index2 msgScript aux auxType auxWidth
			      indent indentWidth alignment valignment} {
    variable pu
    if {$indentWidth != 0} {
	if {[insertOrUpdateIndent $w $index1 $indent $indentWidth]} {
	    set index2 $index2+1$pu
	}
	set index1 $index1+1$pu
    }

    if {$auxWidth == 0} {				;# no image or window
	set areEqual [$w compare $index1 == $index2]
	$w delete $index1+1$pu $index2
	set padY [expr {[$w cget -spacing1] == 0}]
	if {[catch {$w window cget $index1 -create} script] == 0 &&
	    [string match "::tablelist::displayText*" $script]} {
	    $w window configure $index1 -pady $padY -create $msgScript

	    set path [lindex [$w dump -window $index1] 1]
	    if {$path ne "" && [winfo class $path] eq "Message"} {
		set msgScript [string map {"%%" "%"} $msgScript]
		eval $msgScript
	    }
	} else {
	    if {!$areEqual} {
		$w delete $index1
	    }
	    $w window create $index1 -pady $padY -create $msgScript
	    $w tag add elidedWin $index1
	}
    } else {
	#
	# Check whether the image label or the frame containing a
	# window is mapped at the first or last position of the cell
	#
	$w mark set index2Mark $index2
	if {$auxType == 1} {					;# image
	    if {[setImgLabelWidth $w $index1 $auxWidth]} {
		set auxFound 1
		if {$alignment eq "right"} {
		    $w delete $index1+1$pu $index2
		}
	    } elseif {[setImgLabelWidth $w $index2-1$pu $auxWidth]} {
		set auxFound 1
		if {$alignment ne "right"} {
		    $w delete $index1 $index2-1$pu
		}
	    } else {
		set auxFound 0
		$w delete $index1 $index2
	    }
	} else {						;# window
	    if {[$aux cget -width] != $auxWidth} {
		$aux configure -width $auxWidth
	    }

	    if {[lindex [$w dump -window $index1] 1] eq $aux} {
		set auxFound 1
		if {$alignment eq "right"} {
		    $w delete $index1+1$pu $index2
		}
	    } elseif {[lindex [$w dump -window $index2-1$pu] 1] eq $aux} {
		set auxFound 1
		if {$alignment ne "right"} {
		    $w delete $index1 $index2-1$pu
		}
	    } else {
		set auxFound 0
		$w delete $index1 $index2
	    }
	}

	if {$auxFound} {
	    #
	    # Adjust the aux. window and insert the message widget
	    #
	    if {$alignment eq "right"} {
		if {$auxType == 1} {				;# image
		    setImgLabelAnchor $w index2Mark-1$pu e
		} else {					;# window
		    if {$auxType == 2} {			;# static width
			place $aux.w -anchor ne -relwidth "" -relx 1.0
		    } else {					;# dynamic width
			place $aux.w -anchor ne -relwidth 1.0 -relx 1.0
		    }
		}
		set auxIdx index2Mark-1$pu
		set msgIdx index2Mark-2$pu
	    } else {
		if {$auxType == 1} {				;# image
		    setImgLabelAnchor $w $index1 w
		} else {					;# window
		    if {$auxType == 2} {			;# static width
			place $aux.w -anchor nw -relwidth "" -relx 0.0
		    } else {					;# dynamic width
			place $aux.w -anchor nw -relwidth 1.0 -relx 0.0
		    }
		}
		set auxIdx $index1
		set msgIdx $index1+1$pu
	    }
	    if {$valignment ne [$w window cget $auxIdx -align]} {
		$w window configure $auxIdx -align $valignment
	    }

	    set padY [expr {[$w cget -spacing1] == 0}]
	    if {[catch {$w window cget $msgIdx -create} script] == 0 &&
		[string match "::tablelist::displayText*" $script]} {
		$w window configure $msgIdx -pady $padY -create $msgScript

		set path [lindex [$w dump -window $msgIdx] 1]
		if {$path ne "" && [winfo class $path] eq "Message"} {
		    set msgScript [string map {"%%" "%"} $msgScript]
		    eval $msgScript
		}
	    } elseif {$alignment eq "right"} {
		$w window create index2Mark-1$pu -pady $padY -create $msgScript
		$w tag add elidedWin index2Mark-1$pu
		$w delete $index1 index2Mark-2$pu
	    } else {
		$w window create $index1+1$pu -pady $padY -create $msgScript
		$w tag add elidedWin $index1+1$pu
		$w delete $index1+2$pu index2Mark
	    }
	} else {
	    #
	    # Insert the message and aux. windows
	    #
	    if {$auxType == 1} {				;# image
		set aux [lreplace $aux end end $auxWidth]
	    } else {						;# window
		if {[$aux cget -width] != $auxWidth} {
		    $aux configure -width $auxWidth
		}
	    }
	    insertMlElem $w $index1 $msgScript $aux $auxType $alignment \
			 $valignment
	}
    }
}

#------------------------------------------------------------------------------
# tablelist::setImgLabelWidth
#
# Sets the width of the image label embedded into the text widget w at the
# given index to the specified value.
#------------------------------------------------------------------------------
proc tablelist::setImgLabelWidth {w index width} {
    if {[catch {$w window cget $index -create} script] == 0 &&
	[string match "::tablelist::displayImage *" $script]} {
	if {$width != [lindex $script end]} {
	    set padY [expr {[$w cget -spacing1] == 0}]
	    set script [lreplace $script end end $width]
	    $w window configure $index -pady $padY -create $script

	    set path [lindex [$w dump -window $index] 1]
	    if {$path ne ""} {
		$path configure -width $width
	    }
	}

	return 1
    } else {
	return 0
    }
}

#------------------------------------------------------------------------------
# tablelist::setImgLabelAnchor
#
# Sets the anchor of the image label embedded into the text widget w at the
# given index to the specified value.
#------------------------------------------------------------------------------
proc tablelist::setImgLabelAnchor {w index anchor} {
    set script [$w window cget $index -create]
    if {$anchor ne [lindex $script 4]} {
	set padY [expr {[$w cget -spacing1] == 0}]
	set script [lreplace $script 4 4 $anchor]
	$w window configure $index -pady $padY -create $script

	set path [lindex [$w dump -window $index] 1]
	if {$path ne ""} {
	    $path configure -anchor $anchor
	}
    }
}

#------------------------------------------------------------------------------
# tablelist::appendComplexElem
#
# Adjusts the given text and the width of the auxiliary object (image or
# window) corresponding to the specified cell of the tablelist widget win, and
# inserts the text and the auxiliary object (if any) just before the newline
# character at the end of the specified line of the tablelist's body.
#------------------------------------------------------------------------------
proc tablelist::appendComplexElem {win key row col text pixels alignment
				   snipStr cellFont cellTags line} {
    #
    # Adjust the cell text and the image or window width
    #
    set multiline [string match "*\n*" $text]
    upvar ::tablelist::ns${win}::data data
    if {$pixels == 0} {				;# convention: dynamic width
	if {$data($col-maxPixels) > 0} {
	    if {$data($col-reqPixels) > $data($col-maxPixels)} {
		set pixels $data($col-maxPixels)
	    }
	}
    }
    set aux [getAuxData $win $key $col auxType auxWidth $pixels]
    set indent [getIndentData $win $key $col indentWidth]
    set maxTextWidth $pixels
    if {$pixels != 0} {
	incr pixels $data($col-delta)
	set maxTextWidth [getMaxTextWidth $pixels $auxWidth $indentWidth]

	if {$data($col-wrap) && !$multiline} {
	    if {[font measure $cellFont -displayof $win $text] >
		$maxTextWidth} {
		set multiline 1
	    }
	}
    }
    variable snipSides
    set snipSide $snipSides($alignment,$data($col-changesnipside))
    if {$multiline} {
	set list [split $text "\n"]
	if {$data($col-wrap)} {
	    set snipSide ""
	}
	adjustMlElem $win list auxWidth indentWidth $cellFont $pixels \
		     $snipSide $snipStr
	set msgScript [list ::tablelist::displayText $win $key $col \
		       [join $list "\n"] $cellFont $maxTextWidth $alignment]
	set msgScript [string map {"%" "%%"} $msgScript]
    } else {
	adjustElem $win text auxWidth indentWidth $cellFont $pixels \
		   $snipSide $snipStr
    }

    #
    # Insert the text and the auxiliary object (if any) just before the newline
    #
    set inBody [string match "k*" $key]
    set w [expr {$inBody ? $data(body) : $data(hdrTxt)}]
    set idx [$w index $line.end]
    variable pu
    if {$auxWidth == 0} {				;# no image or window
	if {$multiline} {
	    $w insert $line.end "\t\t" $cellTags
	    set padY [expr {[$w cget -spacing1] == 0}]
	    $w window create $line.end-1$pu -pady $padY -create $msgScript
	    $w tag add elidedWin $line.end-1$pu
	} else {
	    $w insert $line.end "\t$text\t" $cellTags
	}
    } else {
	$w insert $line.end "\t\t" $cellTags
	if {$auxType == 1} {					;# image
	    #
	    # Update the creation script for the image label
	    #
	    set aux [lreplace $aux end end $auxWidth]
	} else {						;# window
	    #
	    # Create a frame and evaluate the script that
	    # creates a child window within the frame
	    #
	    tk::frame $aux -borderwidth 0 -class TablelistWindow -container 0 \
			   -height $data($key,$col-reqHeight) \
			   -highlightthickness 0 -padx 0 -pady 0 -relief flat \
			   -takefocus 0 -width $auxWidth
	    if {$inBody} {
		bindtags $aux [linsert [bindtags $aux] 1 \
			       $data(bodyTag) TablelistBody]
	    } else {
		bindtags $aux [linsert [bindtags $aux] 1 \
			       $data(headerTag) TablelistHeader]
	    }
	    uplevel #0 $data($key,$col-window) [list $win $row $col $aux.w]
	    set reqHeight [winfo reqheight $aux.w]
	    if {$reqHeight != 1 && $reqHeight != $data($key,$col-reqHeight)} {
		set data($key,$col-reqHeight) $reqHeight
		$aux configure -height $reqHeight
	    }
	}
	if {$multiline} {
	    insertMlElem $w $line.end-1$pu $msgScript $aux $auxType \
			 $alignment [getOpt $win $key $col -valign]
	} else {
	    insertElem $w $line.end-1$pu $text $aux $auxType \
		       $alignment [getOpt $win $key $col -valign]
	}
    }

    #
    # Insert the indentation image, if any
    #
    if {$indentWidth != 0} {
	variable pu
	insertOrUpdateIndent $w $idx+1$pu $indent $indentWidth
    }
}

#------------------------------------------------------------------------------
# tablelist::makeColFontAndTagLists
#
# Builds the lists data(colFontList) of the column fonts and data(colTagsList)
# of the column tag names for the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::makeColFontAndTagLists win {
    upvar ::tablelist::ns${win}::data data
    set widgetFont $data(-font)
    set data(colFontList) {}
    set data(colTagsList) {}
    set data(hasColTags) 0
    set viewable [winfo viewable $win]

    for {set col 0} {$col < $data(colCount)} {incr col} {
	set tagNames {}

	if {[info exists data($col-font)]} {
	    lappend data(colFontList) $data($col-font)
	    lappend tagNames col-font-$data($col-font)
	    set data(hasColTags) 1
	} else {
	    lappend data(colFontList) $widgetFont
	}

	if {$viewable && $data($col-hide)} {
	    lappend tagNames hiddenCol
	    set data(hasColTags) 1
	}

	lappend data(colTagsList) $tagNames
    }
}

#------------------------------------------------------------------------------
# tablelist::makeSortAndArrowColLists
#
# Builds the lists data(sortColList) of the sort columns and data(arrowColList)
# of the arrow columns for the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::makeSortAndArrowColLists win {
    upvar ::tablelist::ns${win}::data data
    set data(sortColList) {}
    set data(arrowColList) {}

    #
    # Build a list of {col sortRank} pairs and sort it based on sortRank
    #
    set pairList {}
    for {set col 0} {$col < $data(colCount)} {incr col} {
	if {$data($col-sortRank) > 0} {
	    lappend pairList [list $col $data($col-sortRank)]
	}
    }
    set pairList [lsort -integer -index 1 $pairList]

    #
    # Build data(sortColList) and data(arrowColList), and update
    # the sort ranks to have values from 1 to [llength $pairList]
    #
    set sortRank 1
    foreach pair $pairList {
	set col [lindex $pair 0]
	lappend data(sortColList) $col
	set data($col-sortRank) $sortRank
	if {$sortRank < 10 && $data(-showarrow) && $data($col-showarrow)} {
	    lappend data(arrowColList) $col
	    configCanvas $win $col
	    raiseArrow $win $col
	}
	incr sortRank
    }

    #
    # Special handling for the "aqua" theme if Cocoa is being used:
    # Deselect all header labels and select that of the main sort column
    #
    variable specialAquaHandling
    variable currentTheme
    if {$specialAquaHandling && $currentTheme eq "aqua"} {
	for {set col 0} {$col < $data(colCount)} {incr col} {
	    configLabel $data(hdrTxtFrmLbl)$col -selected 0
	}

	if {[llength $data(sortColList)] != 0} {
	    set col [lindex $data(sortColList) 0]
	    configLabel $data(hdrTxtFrmLbl)$col -selected 1
	    raise $data(hdrTxtFrmLbl)$col
	}
    }
}

#------------------------------------------------------------------------------
# tablelist::setupColumns
#
# Updates the value of the -colums configuration option for the tablelist
# widget win by using the width, title, and alignment specifications given in
# the columns argument, and creates the corresponding label (and separator)
# widgets if createLabels is true.
#------------------------------------------------------------------------------
proc tablelist::setupColumns {win columns createLabels} {
    variable usingTile
    variable configSpecs
    variable configOpts
    variable alignments
    upvar ::tablelist::ns${win}::data data

    set argCount [llength $columns]
    set colConfigVals {}

    #
    # Check the syntax of columns before performing any changes
    #
    for {set n 0} {$n < $argCount} {incr n} {
	#
	# Get the column width
	#
	set width [lindex $columns $n]
	##nagelfar ignore
	set width [format "%d" $width]	;# integer check with error message

	#
	# Get the column title
	#
	if {[incr n] == $argCount} {
	    return -code error "column title missing"
	}
	set title [lindex $columns $n]

	#
	# Get the column alignment
	#
	set alignment left
	if {[incr n] < $argCount} {
	    set next [lindex $columns $n]
	    if {[isInteger $next]} {
		incr n -1
	    } else {
		set alignment [mwutil::fullOpt "alignment" $next $alignments]
	    }
	}

	#
	# Append the properly formatted values of width,
	# title, and alignment to the list colConfigVals
	#
	lappend colConfigVals $width $title $alignment
    }

    #
    # Save the value of colConfigVals in data(-columns)
    #
    set data(-columns) $colConfigVals

    #
    # Delete the labels, canvases, and separators if requested
    #
    if {$createLabels} {
	foreach w [winfo children $data(hdrTxtFrm)] {
	    if {$w ne $data(hdrTxtFrmFrm)} {
		destroy $w
	    }
	}
	foreach w [winfo children $win] {
	    if {[regexp {^(vsep[0-9]+|hsep2)$} [winfo name $w]]} {
		destroy $w
	    }
	}
	set data(fmtCmdFlagList) {}
	set data(hiddenColCount) 0
    }

    #
    # Build the list data(colList), and create
    # the labels and canvases if requested
    #
    regexp {^(flat|flatAngle|sunken|photo)([0-9]+)x([0-9]+)$} \
	   $data(-arrowstyle) dummy arrowRelief arrowWidth arrowHeight
    set widgetFont $data(-font)
    set oldColCount $data(colCount)
    set data(colList) {}
    set data(colCount) 0
    set data(lastCol) -1
    set col 0
    foreach {width title alignment} $data(-columns) {
	#
	# Append the width in pixels and the
	# alignment to the list data(colList)
	#
	if {$width > 0} {		;# convention: width in characters
	    set pixels [charsToPixels $win $widgetFont $width]
	    set data($col-lastStaticWidth) $pixels
	} elseif {$width < 0} {		;# convention: width in pixels
	    set pixels [expr {(-1)*$width}]
	    set data($col-lastStaticWidth) $pixels
	} else {			;# convention: dynamic width
	    set pixels 0
	}
	lappend data(colList) $pixels $alignment
	incr data(colCount)
	set data(lastCol) $col

	if {$createLabels} {
	    set data($col-elide) 0
	    foreach {name val} {
		delta 0  lastStaticWidth 0  maxPixels 0  isSnipped 0
		sortOrder ""  sortRank 0  checkState 0
		allowduplicates 1  changesnipside 0  changetitlesnipside 0
		editable 0  editwindow entry  hide 0  labelvalign center
		maxwidth 0  resizable 1  showarrow 1  showlinenumbers 0
		sortmode ascii  stretchwindow 0  valign center  wrap 0
	    } {
		if {![info exists data($col-$name)]} {
		    set data($col-$name) $val
		}
	    }
	    lappend data(fmtCmdFlagList) [info exists data($col-formatcommand)]
	    incr data(hiddenColCount) $data($col-hide)

	    #
	    # Create the label
	    #
	    set w $data(hdrTxtFrmLbl)$col
	    if {$usingTile} {
		ttk::label $w -style Tablelist.Heading -image "" \
			      -padding {1 1 1 1} -takefocus 0 -text "" \
			      -textvariable "" -wraplength 0
	    } else {
		tk::label $w -bitmap "" -highlightthickness 0 -image "" \
			     -takefocus 0 -text "" -textvariable "" \
			     -wraplength 0
	    }
	    set defVal [lindex [$w configure -underline] 3]
	    $w configure -underline $defVal	;# -1 or "" (see TIP #577)

	    #
	    # Apply to it the current configuration options
	    #
	    foreach opt $configOpts {
		set optGrp [lindex $configSpecs($opt) 2]
		if {$optGrp eq "l"} {
		    set optTail [string range $opt 6 end]
		    if {[info exists data($col$opt)]} {
			configLabel $w -$optTail $data($col$opt)
		    } else {
			configLabel $w -$optTail $data($opt)
		    }
		} elseif {$optGrp eq "c"} {
		    configLabel $w $opt $data($opt)
		}
	    }
	    catch {configLabel $w -state $data(-state)}

	    #
	    # Replace the binding tag (T)Label with $data(labelTag) and
	    # TablelistLabel in the list of binding tags of the label
	    #
	    bindtags $w [lreplace [bindtags $w] 1 1 \
			 $data(labelTag) TablelistLabel]

	    #
	    # Create a canvas containing the sort arrows
	    #
	    set w $data(hdrTxtFrmCanv)$col
	    canvas $w -borderwidth 0 -highlightthickness 0 \
		      -relief flat -takefocus 0
	    createArrows $w $arrowWidth $arrowHeight $arrowRelief

	    #
	    # Apply to it the current configuration options
	    #
	    foreach opt $configOpts {
		if {[lindex $configSpecs($opt) 2] eq "c"} {
		    $w configure $opt $data($opt)
		}
	    }

	    #
	    # Replace the binding tag Canvas with $data(labelTag) and
	    # TablelistArrow in the list of binding tags of the canvas
	    #
	    bindtags $w [lreplace [bindtags $w] 1 1 \
			 $data(labelTag) TablelistArrow]

	    if {[info exists data($col-labelimage)]} {
		doColConfig $col $win -labelimage $data($col-labelimage)
	    }
	    if {[info exists data($col-labelwindow)]} {
		doColConfig $col $win -labelwindow $data($col-labelwindow)
	    }
	}

	#
	# Configure the edit window if present
	#
	if {$col == $data(editCol) &&
	    [winfo class $data(bodyFrmEd)] ne "Mentry"} {
	    catch {$data(bodyFrmEd) configure -justify $alignment}
	}

	incr col
    }
    set data(hasFmtCmds) [expr {[lsearch -exact $data(fmtCmdFlagList) 1] >= 0}]

    #
    # Clean up the images, data, attributes, and selection
    # states associated with the deleted columns
    #
    set imgNames [image names]
    for {set col $data(colCount)} {$col < $oldColCount} {incr col} {
	set w $data(hdrTxtFrmCanv)$col
	foreach shape {triangleUp darkLineUp lightLineUp
		       triangleDn darkLineDn lightLineDn} {
	    if {[lsearch -exact $imgNames ${shape}Img$w] >= 0} {
		image delete ${shape}Img$w
	    }
	}

	deleteColData $win $col
	deleteColAttribs $win $col
	deleteColSelStates $win $col
    }

    #
    # Update data(-treecolumn) and data(treeCol) if needed
    #
    if {$createLabels} {
	set treeCol $data(-treecolumn)
	adjustColIndex $win treeCol
	set data(treeCol) $treeCol
	if {$data(colCount) != 0} {
	    set data(-treecolumn) $treeCol
	}
    }

    #
    # Create the separators if needed
    #
    if {$createLabels && $data(-showseparators)} {
	createSeps $win
    }
}

#------------------------------------------------------------------------------
# tablelist::createSeps
#
# Creates and manages the separators in the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::createSeps win {
    upvar ::tablelist::ns${win}::data data
    variable usingTile
    set sepX [getSepX]

    for {set col 0} {$col < $data(colCount)} {incr col} {
	#
	# Create the col'th separator and attach it to
	# the right edge of the col'th header label
	#
	set w $data(vsep)$col
	if {$usingTile} {
	    ttk::separator $w -style Seps$win.TSeparator \
			      -cursor $data(-cursor) -orient vertical \
			      -takefocus 0
	} else {
	    tk::frame $w -background $data(-background) -borderwidth 1 \
			 -container 0 -cursor $data(-cursor) \
			 -highlightthickness 0 -relief sunken \
			 -takefocus 0 -width 2
	}
	place $w -in $data(hdrTxtFrmLbl)$col -anchor ne -bordermode outside \
		 -relx 1.0 -x $sepX

	#
	# Replace the binding tag TSeparator or Frame with $data(bodyTag)
	# and TablelistBody in the list of binding tags of the separator
	#
	bindtags $w [lreplace [bindtags $w] 1 1 $data(bodyTag) TablelistBody]
    }

    #
    # Create the lower horizontal separator
    #
    set w $data(hsep)2
    if {$usingTile} {
	ttk::separator $w -style Seps$win.TSeparator -cursor $data(-cursor) \
			  -takefocus 0
    } else {
	tk::frame $w -background $data(-background) -borderwidth 1 \
		     -container 0 -cursor $data(-cursor) -height 2 \
		     -highlightthickness 0 -relief sunken -takefocus 0
    }

    #
    # Replace the binding tag TSeparator or Frame with $data(bodyTag) and
    # TablelistBody in the list of binding tags of the horizontal separator
    #
    bindtags $w [lreplace [bindtags $w] 1 1 $data(bodyTag) TablelistBody]

    adjustSepsWhenIdle $win
}

#------------------------------------------------------------------------------
# tablelist::adjustSepsWhenIdle
#
# Arranges for the height and vertical position of each separator in the
# tablelist widget win to be adjusted at idle time.
#------------------------------------------------------------------------------
proc tablelist::adjustSepsWhenIdle win {
    upvar ::tablelist::ns${win}::data data
    if {[info exists data(sepsId)]} {
	return ""
    }

    set script [list tablelist::adjustSeps $win]
    variable aquaCrash
    if {$aquaCrash} { set script [list after 0 $script] }
    set data(sepsId) [after idle $script]
}

#------------------------------------------------------------------------------
# tablelist::adjustSeps
#
# Adjusts the height and position of each separator in the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::adjustSeps win {
    upvar ::tablelist::ns${win}::data data
    if {[info exists data(sepsId)]} {
	after cancel $data(sepsId)
	unset data(sepsId)
    }

    variable winSys
    set onWindows [expr {$winSys eq "win32"}]
    variable usingTile
    set sepX [getSepX]

    #
    # Get the height to be applied to the column separators
    # and place or unmanage the lower horizontal separator
    #
    set w $data(body)
    if {$data(-fullseparators)} {
	set sepHeight [winfo height $w]

	if {[winfo exists $data(hsep)2]} {
	    place forget $data(hsep)2
	}
    } else {
	set btmTextIdx [$w index @0,$data(btmY)]
	set btmLine [expr {int($btmTextIdx)}]
	if {$btmLine > $data(itemCount)} {
	    set btmLine $data(itemCount)
	    set btmTextIdx $btmLine.0
	}
	set dlineinfo [$w dlineinfo $btmTextIdx]
	if {$data(itemCount) == 0 || [llength $dlineinfo] == 0} {
	    set sepHeight 0
	} else {
	    foreach {x y width height baselinePos} $dlineinfo {}
	    set sepHeight [expr {$y + $height}]
	}

	if {$data(-showhorizseparator) && $data(-showseparators) &&
	    $sepHeight > 0 && $sepHeight < [winfo height $w]} {
	    set width [expr {[winfo reqwidth $data(hdrTxtFrm)] + $sepX -
			     [winfo reqheight $data(hsep)2] + 1}]
	    if {$onWindows && !$usingTile} {
		incr width
	    }
	    place $data(hsep)2 -in $w -y $sepHeight -width $width
	} elseif {[winfo exists $data(hsep)2]} {
	    place forget $data(hsep)2
	}
    }

    #
    # Set the height of the vertical main separator (if any) and attach
    # the latter to the right edge of the last non-hidden title column
    #
    set startCol [expr {$data(-titlecolumns) - 1}]
    if {$startCol > $data(lastCol)} {
	set startCol $data(lastCol)
    }
    for {set col $startCol} {$col >= 0} {incr col -1} {
	if {!$data($col-hide)} {
	    break
	}
    }
    set mainSepHeight [expr {$sepHeight + [winfo height $data(hdr)] - 1}]
    set w $data(vsep)
    if {$col < 0 || $mainSepHeight == 0} {
	if {[winfo exists $w]} {
	    place forget $w
	}
    } else {
	if {!$data(-showlabels)} {
	    if {$data(hdr_itemCount) == 0} {
		incr mainSepHeight
	    } else {
		incr mainSepHeight \
		     [$data(hdrTxt) count -update -ypixels 1.0 2.0]
	    }
	}
	place $w -in $data(hdrTxtFrmLbl)$col -anchor ne -bordermode outside \
		 -height $mainSepHeight -relx 1.0 -x $sepX -y 1
	raise $w
    }

    #
    # Place or unmanage the upper horizontal separator (if any)
    #
    set w $data(hsep)1
    if {[winfo exists $w]} {
	if {$data(hdr_itemCount) == 0} {
	    place forget $w
	} else {
	    set width [expr {[winfo reqwidth $data(hdrTxtFrm)] + $sepX -
			     [winfo reqheight $data(hsep)1] + 1}]
	    if {$onWindows && !$usingTile} {
		incr width
	    }
	    place $w -in $data(hdr) -anchor sw -rely 1.0 -width $width
	    raise $w
	}
    }

    #
    # Set the height and vertical position of the other column separators
    #
    if {$sepHeight == 0 && $data(hdr_itemCount) == 0} {
	set relY 0.0
	set y -10
    } elseif {$data(-showlabels)} {
	set relY 1.0
	if {$usingTile || $onWindows} {
	    set y 0
	    incr sepHeight 1
	} else {
	    set y -1
	    incr sepHeight 2
	}
    } else {
	set relY 0.0
	if {$usingTile || $onWindows} {
	    set y 1
	    incr sepHeight 2
	} else {
	    set y 0
	    incr sepHeight 3
	}
    }
    variable currentTheme
    variable newAquaSupport
    if {$usingTile && $currentTheme eq "aqua" && $newAquaSupport} {
	incr y -4
    }
    incr sepHeight [expr {[winfo reqheight $data(hdr)] -
			  [winfo reqheight $data(hdrTxtFrm)]}]
    if {!$data(-showlabels)} {
	incr sepHeight -1
	if {$data(hdr_itemCount) != 0} {
	    incr sepHeight [$data(hdrTxt) count -update -ypixels 1.0 2.0]
	}
    }
    foreach w [winfo children $win] {
	if {[regexp {^vsep[0-9]+$} [winfo name $w]]} {
	    place configure $w -height $sepHeight -rely $relY -y $y
	}
    }
}

#------------------------------------------------------------------------------
# tablelist::getSepX
#
# Returns the value of the -x option to be used when placing a separator
# relative to the corresponding header label, with -anchor ne.
#------------------------------------------------------------------------------
proc tablelist::getSepX {} {
    set x 1
    variable usingTile
    if {$usingTile} {
	variable currentTheme
	variable xpStyle
	if {($currentTheme eq "aqua") ||
	    ($currentTheme eq "xpnative" && $xpStyle)} {
	    set x 0
	} elseif {$currentTheme eq "tileqt"} {
	    switch -- [string tolower [tileqt_currentThemeName]] {
		cleanlooks -
		gtk+ -
		oxygen	{ set x 0 }
		qtcurve	{ set x 2 }
	    }
	}
    }

    return $x
}

#------------------------------------------------------------------------------
# tablelist::adjustColumns
#
# Applies some configuration options to the labels of the tablelist widget win,
# places them in the header frame, computes and sets the tab stops for both
# text widgets, and adjusts the width and height of the header frame.  The
# whichWidths argument specifies the dynamic-width columns or labels whose
# widths are to be computed when performing these operations.  The stretchCols
# argument specifies whether to stretch the stretchable columns.
#------------------------------------------------------------------------------
proc tablelist::adjustColumns {win whichWidths stretchCols} {
    set compAllColWidths   [expr {$whichWidths eq "allCols"}]
    set compAllLabelWidths [expr {$whichWidths eq "allLabels"}]

    variable usingTile
    variable currentTheme
    variable newAquaSupport
    set aquaTheme [expr {$usingTile && $currentTheme eq "aqua"}]

    #
    # Configure the labels and compute the positions
    # of the tab stops to be set in both text widgets
    #
    upvar ::tablelist::ns${win}::data data
    set data(hdrWidth) 0
    variable centerArrows
    set tabs {}
    set col 0
    set x 0
    foreach {pixels alignment} $data(colList) {
	set w $data(hdrTxtFrmLbl)$col

	#
	# Adjust the col'th label
	#
	if {[info exists data($col-labelalign)]} {
	    set labelAlignment $data($col-labelalign)
	} else {
	    set labelAlignment $alignment
	}
	if {$pixels != 0} {			;# convention: static width
	    incr pixels $data($col-delta)
	}
	adjustLabel $win $col $pixels $labelAlignment

	if {$pixels == 0} {			;# convention: dynamic width
	    #
	    # Compute the column or label width if requested
	    #
	    if {$compAllColWidths || [lsearch -exact $whichWidths $col] >= 0} {
		computeColWidth $win $col
	    } elseif {$compAllLabelWidths ||
		      [lsearch -exact $whichWidths l$col] >= 0} {
		computeLabelWidth $win $col
	    }

	    set pixels $data($col-reqPixels)
	    if {$data($col-maxPixels) > 0 && $pixels > $data($col-maxPixels)} {
		set pixels $data($col-maxPixels)
		incr pixels $data($col-delta)
		adjustLabel $win $col $pixels $labelAlignment
	    } else {
		incr pixels $data($col-delta)
	    }
	}

	if {$col == $data(editCol) &&
	    ![string match "*Checkbutton" [winfo class $data(bodyFrmEd)]]} {
	    adjustEditWindow $win $pixels
	}

	set canvas $data(hdrTxtFrmCanv)$col
	if {[lsearch -exact $data(arrowColList) $col] >= 0 &&
	    !$data($col-elide) && !$data($col-hide)} {
	    #
	    # Center the canvas horizontally just below the upper edge of
	    # the label, or place it to the left side of the label if the
	    # latter is right-justified and to its right side otherwise
	    #
	    if {$centerArrows} {
		place $canvas -in $w -anchor n -bordermode outside \
			      -relx 0.4999 -y 1
	    } else {
		set y 0
		if {([winfo reqheight $w] - [winfo reqheight $canvas]) % 2 == 0
		    && $data(arrowHeight) == 5} {
		    set y -1
		}
		if {$aquaTheme && $newAquaSupport} {
		   incr y -4
		}
		if {$labelAlignment eq "right"} {
		    place $canvas -in $w -anchor w -bordermode outside \
				  -relx 0.0 -x $data(charWidth) \
				  -rely 0.4999 -y $y
		} else {
		    place $canvas -in $w -anchor e -bordermode outside \
				  -relx 1.0 -x -$data(charWidth) \
				  -rely 0.4999 -y $y
		}
	    }
	    raise $canvas
	} else {
	    place forget $canvas
	}

	#
	# Place the label in the header frame
	#
	if {$data($col-elide) || $data($col-hide)} {
	    foreach l [getSublabels $w] {
		place forget $l
	    }
	    place $w -x [expr {$x - 1}] -relheight 1.0 -width 1
	    lower $w
	} else {
	    set x2 $x
	    set labelPixels [expr {$pixels + 2*$data(charWidth)}]
	    if {$aquaTheme && !$newAquaSupport} {
		incr x2 -1
		incr labelPixels
		if {$col == 0} {
		    incr x2 -1
		    incr labelPixels
		}
	    }

	    set y 0
	    if {$aquaTheme && $newAquaSupport} {
		set y 4
	    }
	    place $w -x $x2 -y $y -relheight 1.0 -width $labelPixels
	    raise $w $data(hdrTxtFrmFrm)
	}

	#
	# Append a tab stop and the alignment to the tabs list
	#
	if {!$data($col-elide) && !$data($col-hide)} {
	    incr x $data(charWidth)
	    switch $alignment {
		left {
		    lappend tabs $x left
		    incr x $pixels
		}
		right {
		    incr x $pixels
		    lappend tabs $x right
		}
		center {
		    lappend tabs [expr {$x + $pixels/2}] center
		    incr x $pixels
		}
	    }
	    incr x $data(charWidth)
	    lappend tabs $x left
	}

	incr col
    }
    place configure $data(hdrFrm) -x $x

    #
    # Apply the value of tabs to both text widgets
    #
    $data(hdrTxt) configure -tabs $tabs
    if {[info exists data(colBeingResized)]} {
	$data(body) tag configure visibleLines -tabs $tabs
    } else {
	$data(body) configure -tabs $tabs
    }

    #
    # Adjust the width and height of the frames data(hdrTxtFrm) and data(hdr)
    #
    $data(hdrTxtFrm) configure -width $x
    if {$data(-width) <= 0} {
	if {$stretchCols} {
	    $data(hdr) configure -width $x
	    $data(lb) configure -width [expr {$x / $data(charWidth)}]
	}
    } else {
	$data(hdr) configure -width 0
    }
    set data(hdrWidth) $x
    adjustHeaderHeight $win

    #
    # Stretch the stretchable columns if requested, and update
    # the scrolled column offset and the horizontal scrollbar
    #
    if {$stretchCols} {
	stretchColumnsWhenIdle $win
    }
    if {![info exists data(colBeingResized)]} {
	updateScrlColOffsetWhenIdle $win
    }
    updateHScrlbarWhenIdle $win

    set titleColsWidth [getTitleColsWidth $win]
    set cornerFrmWidth $titleColsWidth
    if {$cornerFrmWidth == 0} {
	set cornerFrmWidth 1
    } else {
	incr cornerFrmWidth -1
    }
    if {$cornerFrmWidth != [winfo reqwidth $data(cornerFrm-sw)]} {
	$data(cornerFrm-sw) configure -width $cornerFrmWidth
	genVirtualEvent $win <<TablelistTitleColsWidthChanged>> $titleColsWidth
    }
}

#------------------------------------------------------------------------------
# tablelist::adjustLabel
#
# Applies some configuration options to the col'th label of the tablelist
# widget win as well as to the label's sublabels (if any), and places the
# sublabels.
#------------------------------------------------------------------------------
proc tablelist::adjustLabel {win col pixels alignment} {
    #
    # Apply some configuration options to the label and its sublabels (if any)
    #
    upvar ::tablelist::ns${win}::data data
    set w $data(hdrTxtFrmLbl)$col
    variable anchors
    set anchor $anchors($alignment)
    set borderWidth [winfo pixels $w [$w cget -borderwidth]]
    if {$borderWidth < 0} {
	set borderWidth 0
    }
    set padX [expr {$data(charWidth) - $borderWidth}]
    if {$padX < 0} {
	set padX 0
    }
    set padL $padX
    set padR $padX
    set marginL $data(charWidth)
    set marginR $data(charWidth)
    variable usingTile
    variable currentTheme
    variable newAquaSupport
    set aquaTheme [expr {$usingTile && $currentTheme eq "aqua"}]
    if {$aquaTheme && !$newAquaSupport} {
	incr padL
	incr marginL
	if {$col == 0} {
	    incr padL
	    incr marginL
	}
	set padding [$w cget -padding]
	lset padding 0 $padL
	lset padding 2 $padR
	$w configure -anchor $anchor -justify $alignment -padding $padding
    } else {
	configLabel $w -anchor $anchor -justify $alignment -padx $padX
    }
    if {[winfo exists $w-il]} {
	if {[winfo class $w-il] eq "Label"} {
	    set auxWidth [image width [$w-il cget -image]]
	} else {
	    set auxWidth [winfo reqwidth $w-il.f]
	}
	$w-tl configure -anchor $anchor -justify $alignment
    } else {
	set auxWidth 0
    }

    #
    # Make room for the canvas displaying an up- or down-arrow if needed
    #
    set title [lindex $data(-columns) [expr {3*$col + 1}]]
    set labelFont [$w cget -font]
    set spaces ""
    set spacePixels 0
    if {[lsearch -exact $data(arrowColList) $col] >= 0} {
	set canvas $data(hdrTxtFrmCanv)$col
	set canvasWidth $data(arrowWidth)
	variable centerArrows
	if {[llength $data(arrowColList)] > 1} {
	    variable scalingpct
	    if {$scalingpct > 150} {
		incr canvasWidth [expr {$centerArrows ? 7 : 9}]
	    } else {
		incr canvasWidth 6
	    }
	    $canvas itemconfigure sortRank \
		    -image sortRank$data($col-sortRank)Img$win
	}
	$canvas configure -width $canvasWidth

	if {!$centerArrows} {
	    set spaceWidth [font measure $labelFont -displayof $w " "]
	    set spaces "  "
	    set n 2
	    while {$n*$spaceWidth < $canvasWidth + $data(charWidth)} {
		append spaces " "
		incr n
	    }
	    set spacePixels [expr {$n * $spaceWidth}]
	}
    }

    set data($col-isSnipped) 0
    if {$pixels == 0} {				;# convention: dynamic width
	#
	# Set the label text
	#
	if {$auxWidth == 0} {				;# no image
	    if {$title eq ""} {
		set text $spaces
	    } else {
		set lines {}
		foreach line [split $title "\n"] {
		    if {$alignment eq "right"} {
			lappend lines $spaces$line
		    } else {
			lappend lines $line$spaces
		    }
		}
		set text [join $lines "\n"]
	    }
	    $w configure -text $text
	} elseif {$title eq ""} {			;# image w/o text
	    $w configure -text ""
	    set text $spaces
	    $w-tl configure -text $text
	    $w-il configure -width $auxWidth
	} else {					;# both image and text
	    $w configure -text ""
	    set lines {}
	    foreach line [split $title "\n"] {
		if {$alignment eq "right"} {
		    lappend lines "$spaces$line "
		} else {
		    lappend lines " $line$spaces"
		}
	    }
	    set text [join $lines "\n"]
	    $w-tl configure -text $text
	    $w-il configure -width $auxWidth
	}
    } else {
	#
	# Clip each line of title according to pixels and alignment
	#
	set lessPixels [expr {$pixels - $spacePixels}]
	variable snipSides
	set snipSide $snipSides($alignment,$data($col-changetitlesnipside))
	if {$auxWidth == 0} {				;# no image
	    if {$title eq ""} {
		set text $spaces
	    } else {
		set lines {}
		foreach line [split $title "\n"] {
		    set lineSav $line
		    set line [strRange $win $line $labelFont \
			      $lessPixels $snipSide $data(-snipstring)]
		    if {$line eq $lineSav} {
			set data($col-isSnipped) 1
		    }
		    if {$alignment eq "right"} {
			lappend lines $spaces$line
		    } else {
			lappend lines $line$spaces
		    }
		}
		set text [join $lines "\n"]
	    }
	    $w configure -text $text
	} elseif {$title eq ""} {			;# image w/o text
	    $w configure -text ""
	    if {$auxWidth + $spacePixels <= $pixels} {
		set text $spaces
		$w-tl configure -text $text
		$w-il configure -width $auxWidth
	    } elseif {$spacePixels < $pixels} {
		set text $spaces
		$w-tl configure -text $text
		$w-il configure -width [expr {$pixels - $spacePixels}]
	    } else {
		set auxWidth 0				;# can't disp. the image
		set text ""
	    }
	} else {					;# both image and text
	    $w configure -text ""
	    set gap [font measure $labelFont -displayof $win " "]
	    if {$auxWidth + $gap + $spacePixels <= $pixels} {
		incr lessPixels -[expr {$auxWidth + $gap}]
		set lines {}
		foreach line [split $title "\n"] {
		    set lineSav $line
		    set line [strRange $win $line $labelFont \
			      $lessPixels $snipSide $data(-snipstring)]
		    if {$line ne $lineSav} {
			set data($col-isSnipped) 1
		    }
		    if {$alignment eq "right"} {
			lappend lines "$spaces$line "
		    } else {
			lappend lines " $line$spaces"
		    }
		}
		set text [join $lines "\n"]
		$w-tl configure -text $text
		$w-il configure -width $auxWidth
	    } elseif {$auxWidth + $spacePixels <= $pixels} {
		set data($col-isSnipped) 1
		set text $spaces		;# can't display the orig. text
		$w-tl configure -text $text
		$w-il configure -width $auxWidth
	    } elseif {$spacePixels < $pixels} {
		set data($col-isSnipped) 1
		set text $spaces		;# can't display the orig. text
		$w-tl configure -text $text
		$w-il configure -width [expr {$pixels - $spacePixels}]
	    } else {
		set data($col-isSnipped) 1
		set auxWidth 0			;# can't display the image
		set text ""			;# can't display the text
	    }
	}
    }

    #
    # Place the label's sublabels (if any)
    #
    if {$auxWidth == 0} {
	if {[winfo exists $w-il]} {
	    place forget $w-il
	    place forget $w-tl
	}
    } else {
	if {$text eq ""} {
	    place forget $w-tl
	}

	variable usingTile
	if {$usingTile} {
	    set padding [$w cget -padding]
	    set padT [lindex $padding 1]
	    set padB [lindex $padding 3]
	} else {
	    set padT [$w cget -pady]
	    set padB $padT
	}
	set y 0
	set marginT [expr {$borderWidth + $padT}]
	set marginB [expr {$borderWidth + $padB}]
	set ilReqWidth [winfo reqwidth $w-il]

	if {$aquaTheme && $newAquaSupport} {
	    set y -5
	    incr marginT -4
	    incr marginB  4
	}

	switch $alignment {
	    left {
		incr marginL

		switch $data($col-labelvalign) {
		    center {
			place $w-il -in $w -anchor w -bordermode outside \
			    -relx 0.0 -x $marginL -rely 0.4999 -y $y
		    }
		    top {
			place $w-il -in $w -anchor nw -bordermode outside \
			    -relx 0.0 -x $marginL -rely 0.0 -y $marginT
		    }
		    bottom {
			place $w-il -in $w -anchor sw -bordermode outside \
			    -relx 0.0 -x $marginL -rely 1.0 -y -$marginB
		    }
		}

		if {$usingTile} {
		    set padding [$w cget -padding]
		    lset padding 0 [expr {$padL + $ilReqWidth + 1}]
		    $w configure -padding $padding -text $text
		} elseif {$text ne ""} {
		    set textX [expr {$marginL + $ilReqWidth}]
		    place $w-tl -in $w -anchor w -bordermode outside \
				-relx 0.0 -x $textX -rely 0.4999
		}
	    }

	    right {
		incr marginR

		switch $data($col-labelvalign) {
		    center {
			place $w-il -in $w -anchor e -bordermode outside \
			    -relx 1.0 -x -$marginR -rely 0.4999 -y $y
		    }
		    top {
			place $w-il -in $w -anchor ne -bordermode outside \
			    -relx 1.0 -x -$marginR -rely 0.0 -y $marginT
		    }
		    bottom {
			place $w-il -in $w -anchor se -bordermode outside \
			    -relx 1.0 -x -$marginR -rely 1.0 -y -$marginB
		    }
		}

		if {$usingTile} {
		    set padding [$w cget -padding]
		    lset padding 2 [expr {$padR + $ilReqWidth + 1}]
		    $w configure -padding $padding -text $text
		} elseif {$text ne ""} {
		    set textX [expr {-$marginR - $ilReqWidth}]
		    place $w-tl -in $w -anchor e -bordermode outside \
				-relx 1.0 -x $textX -rely 0.4999
		}
	    }

	    center {
		if {$text eq ""} {
		    switch $data($col-labelvalign) {
			center {
			    place $w-il -in $w -anchor center -bordermode \
				inside -relx 0.4999 -x 0 -rely 0.4999 -y $y
			}
			top {
			    place $w-il -in $w -anchor n -bordermode \
				inside -relx 0.4999 -x 0 -rely 0.0 -y $marginT
			}
			bottom {
			    place $w-il -in $w -anchor s -bordermode \
				inside -relx 0.4999 -x 0 -rely 1.0 -y -$marginB
			}
		    }
		} else {
		    set reqWidth [expr {$ilReqWidth + [winfo reqwidth $w-tl]}]
		    set ilX [expr {-$reqWidth/2}]

		    switch $data($col-labelvalign) {
			center {
			    place $w-il -in $w -anchor w -bordermode inside \
				-relx 0.4999 -x $ilX -rely 0.4999 -y $y
			}
			top {
			    place $w-il -in $w -anchor nw -bordermode inside \
				-relx 0.4999 -x $ilX -rely 0.0 -y $marginT
			}
			bottom {
			    place $w-il -in $w -anchor sw -bordermode inside \
				-relx 0.4999 -x $ilX -rely 1.0 -y -$marginB
			}
		    }

		    if {$usingTile} {
			set padding [$w cget -padding]
			lset padding 0 [expr {$padL + $ilReqWidth}]
			$w configure -padding $padding -text $text
		    } else {
			set tlX [expr {$reqWidth + $ilX}]
			place $w-tl -in $w -anchor e -bordermode inside \
			    -relx 0.4999 -x $tlX -rely 0.4999 -y 0
		    }
		}
	    }
	}

	raise $w-il
    }
}

#------------------------------------------------------------------------------
# tablelist::computeColWidth
#
# Computes the width of the col'th column of the tablelist widget win to be just
# large enough to hold all the elements of the column (including its label).
#------------------------------------------------------------------------------
proc tablelist::computeColWidth {win col} {
    upvar ::tablelist::ns${win}::data data
    set fmtCmdFlag [lindex $data(fmtCmdFlagList) $col]
    set data($col-elemWidth) 0
    set data($col-widestCount) 0

    #
    # Column elements in the header text widget
    #
    set row -1
    foreach item $data(hdr_itemList) {
	incr row

	if {$col >= [llength $item] - 1} {
	    continue
	}

	set key [lindex $item end]

	set text [lindex $item $col]
	if {$fmtCmdFlag} {
	    set text [formatElem $win $key $row $col $text]
	}
	if {[string match "*\t*" $text]} {
	    set text [mapTabs $text]
	}
	getAuxData $win $key $col auxType auxWidth
	set cellFont [getCellFont $win $key $col]
	set elemWidth [getElemWidth $win $text $auxWidth 0 $cellFont]
	if {$elemWidth == $data($col-elemWidth)} {
	    incr data($col-widestCount)
	} elseif {$elemWidth > $data($col-elemWidth)} {
	    set data($col-elemWidth) $elemWidth
	    set data($col-widestCount) 1
	}
    }

    #
    # Column elements in the body text widget
    #
    set row -1
    foreach item $data(itemList) {
	incr row

	if {$col >= [llength $item] - 1} {
	    continue
	}

	set key [lindex $item end]
	if {[info exists data($key-elide)] || [info exists data($key-hide)]} {
	    continue
	}

	set text [lindex $item $col]
	if {$fmtCmdFlag} {
	    set text [formatElem $win $key $row $col $text]
	}
	if {[string match "*\t*" $text]} {
	    set text [mapTabs $text]
	}
	getAuxData $win $key $col auxType auxWidth
	getIndentData $win $key $col indentWidth
	set cellFont [getCellFont $win $key $col]
	set elemWidth [getElemWidth $win $text $auxWidth $indentWidth $cellFont]
	if {$elemWidth == $data($col-elemWidth)} {
	    incr data($col-widestCount)
	} elseif {$elemWidth > $data($col-elemWidth)} {
	    set data($col-elemWidth) $elemWidth
	    set data($col-widestCount) 1
	}
    }

    set data($col-reqPixels) $data($col-elemWidth)

    #
    # Column label
    #
    computeLabelWidth $win $col
}

#------------------------------------------------------------------------------
# tablelist::computeLabelWidth
#
# Computes the requested width of the col'th label of the tablelist widget win
# and adjusts the column's width accordingly.
#------------------------------------------------------------------------------
proc tablelist::computeLabelWidth {win col} {
    upvar ::tablelist::ns${win}::data data
    set w $data(hdrTxtFrmLbl)$col
    if {[winfo exists $w-il]} {
	variable usingTile
	if {$usingTile} {
	    set netLabelWidth [expr {[winfo reqwidth $w] - 2*$data(charWidth)}]
	} else {
	    set netLabelWidth [winfo reqwidth $w-il]
	    set alignment [lindex $data(colList) [expr {2*$col + 1}]]
	    if {$alignment ne "center"} {
		incr netLabelWidth
	    }

	    set text [$w-tl cget -text]
	    if {$text ne ""} {
		incr netLabelWidth [winfo reqwidth $w-tl]
	    }
	}
    } else {
	set netLabelWidth [expr {[winfo reqwidth $w] - 2*$data(charWidth)}]
    }

    if {$netLabelWidth < $data($col-elemWidth)} {
	set data($col-reqPixels) $data($col-elemWidth)
    } else {
	set data($col-reqPixels) $netLabelWidth
    }
}

#------------------------------------------------------------------------------
# tablelist::adjustHeaderHeight
#
# Sets the height of the header frame of the tablelist widget win to the max.
# height of its children.
#------------------------------------------------------------------------------
proc tablelist::adjustHeaderHeight win {
    #
    # Set the height of the header frame and some of its descendants
    #
    upvar ::tablelist::ns${win}::data data
    $data(hdrTxt) tag raise tinyFont
    $data(hdrTxt) tag remove tinyFont 2.0 end
    if {$data(-showlabels)} {
	#
	# Compute the max. label height
	#
	set maxLabelHeight [winfo reqheight $data(hdrFrmLbl)]
	for {set col 0} {$col < $data(colCount)} {incr col} {
	    set w $data(hdrTxtFrmLbl)$col
	    if {[winfo manager $w] eq ""} {
		continue
	    }

	    set reqHeight [winfo reqheight $w]
	    if {$reqHeight > $maxLabelHeight} {
		set maxLabelHeight $reqHeight
	    }

	    foreach l [getSublabels $w] {
		if {[winfo manager $l] eq ""} {
		    continue
		}

		set borderWidth [winfo pixels $w [$w cget -borderwidth]]
		if {$borderWidth < 0} {
		    set borderWidth 0
		}
		set reqHeight [expr {[winfo reqheight $l] + 2*$borderWidth}]
		if {$reqHeight > $maxLabelHeight} {
		    set maxLabelHeight $reqHeight
		}
	    }
	}

	$data(hdrTxtFrm) configure -height $maxLabelHeight
	if {$data(hdr_itemCount) == 0} {
	    set hdrHeight $maxLabelHeight
	} else {
	    set hdrHeight [$data(hdrTxt) count -update -ypixels 1.0 end]
	    incr hdrHeight 2
	}
	$data(hdr) configure -height $hdrHeight
	$data(hdrFrm) configure -height $maxLabelHeight
	$data(cornerFrmFrm) configure -height $maxLabelHeight

	place configure $data(hdrTxt) -y 0
	place configure $data(hdrFrm) -y 0
	place configure $data(cornerFrmFrm) -y 0
    } else {
	$data(hdrTxtFrm) configure -height 1
	if {$data(hdr_itemCount) == 0} {
	    set hdrHeight 1
	    set y -1
	} else {
	    set hdrHeight [$data(hdrTxt) count -update -ypixels 2.0 end]
	    incr hdrHeight 2
	    set y -2
	    $data(hdrTxt) yview 1
	}
	$data(hdr) configure -height $hdrHeight
	$data(hdrFrm) configure -height 1
	$data(cornerFrmFrm) configure -height 1

	place configure $data(hdrTxt) -y $y
	place configure $data(hdrFrm) -y -1
	place configure $data(cornerFrmFrm) -y -1
    }

    set cornerFrmHeight $hdrHeight
    if {$data(hdr_itemCount) != 0} {
	variable usingTile
	variable currentTheme
	if {$usingTile && $currentTheme eq "aqua"} {
	    incr cornerFrmHeight -1
	} else {
	    incr cornerFrmHeight -2
	}
    }
    if {$cornerFrmHeight != [winfo reqheight $data(cornerFrm-ne)]} {
	$data(cornerFrm-ne) configure -height $cornerFrmHeight
	genVirtualEvent $win <<TablelistHeaderHeightChanged>> $hdrHeight
    }

    adjustSepsWhenIdle $win
}

#------------------------------------------------------------------------------
# tablelist::stretchColumnsWhenIdle
#
# Arranges for the stretchable columns of the tablelist widget win to be
# stretched at idle time.
#------------------------------------------------------------------------------
proc tablelist::stretchColumnsWhenIdle win {
    upvar ::tablelist::ns${win}::data data
    if {[info exists data(stretchId)]} {
	return ""
    }

    set script [list tablelist::stretchColumns $win -1]
    variable aquaCrash
    if {$aquaCrash} { set script [list after 0 $script] }
    set data(stretchId) [after idle $script]
}

#------------------------------------------------------------------------------
# tablelist::stretchColumns
#
# Stretches the stretchable columns to fill the tablelist window win
# horizontally.  The colOfFixedDelta argument specifies the column for which
# the stretching is to be made using a precomputed amount of pixels.
#------------------------------------------------------------------------------
proc tablelist::stretchColumns {win colOfFixedDelta} {
    upvar ::tablelist::ns${win}::data data
    if {$colOfFixedDelta < 0} {
	unset data(stretchId)
    }

    set forceAdjust $data(forceAdjust)
    set data(forceAdjust) 0

    if {$data(hdrWidth) == 0} {
	return ""
    }

    #
    # Get the list data(stretchableCols) of the
    # numerical indices of the stretchable columns
    #
    set data(stretchableCols) {}
    if {$data(-stretch) eq "all"} {
	for {set col 0} {$col < $data(colCount)} {incr col} {
	    lappend data(stretchableCols) $col
	}
    } else {
	foreach col $data(-stretch) {
	    lappend data(stretchableCols) [colIndex $win $col 0]
	}
    }

    #
    # Compute the total number data(delta) of pixels by which the
    # columns are to be stretched and the total amount
    # data(stretchablePixels) of stretchable column widths in pixels
    #
    set data(delta) [winfo width $data(hdr)]
    set data(stretchablePixels) 0
    set lastColToStretch -1
    set col 0
    foreach {pixels alignment} $data(colList) {
	if {$data($col-hide)} {
	    incr col
	    continue
	}

	if {$pixels == 0} {			;# convention: dynamic width
	    set pixels $data($col-reqPixels)
	    if {$data($col-maxPixels) > 0} {
		if {$pixels > $data($col-maxPixels)} {
		    set pixels $data($col-maxPixels)
		}
	    }
	}
	incr data(delta) -[expr {$pixels + 2*$data(charWidth)}]
	if {[lsearch -exact $data(stretchableCols) $col] >= 0} {
	    incr data(stretchablePixels) $pixels
	    set lastColToStretch $col
	}

	incr col
    }
    if {$data(delta) < 0} {
	set delta 0
    } else {
	set delta $data(delta)
    }
    if {$data(stretchablePixels) == 0 && !$forceAdjust} {
	return ""
    }

    #
    # Distribute the value of delta to the stretchable
    # columns, proportionally to their widths in pixels
    #
    set rest $delta
    set col 0
    foreach {pixels alignment} $data(colList) {
	if {$data($col-hide) ||
	    [lsearch -exact $data(stretchableCols) $col] < 0} {
	    set data($col-delta) 0
	} else {
	    set oldDelta $data($col-delta)
	    if {$pixels == 0} {			;# convention: dynamic width
		set dynamic 1
		set pixels $data($col-reqPixels)
		if {$data($col-maxPixels) > 0} {
		    if {$pixels > $data($col-maxPixels)} {
			set pixels $data($col-maxPixels)
			set dynamic 0
		    }
		}
	    } else {
		set dynamic 0
	    }
	    if {$data(stretchablePixels) == 0} {
		set data($col-delta) 0
	    } else {
		if {$col != $colOfFixedDelta} {
		    set data($col-delta) \
			[expr {$delta*$pixels/$data(stretchablePixels)}]
		}
		incr rest -$data($col-delta)
	    }
	    if {$col == $lastColToStretch} {
		incr data($col-delta) $rest
	    }
	    if {!$dynamic && $data($col-delta) != $oldDelta} {
		redisplayColWhenIdle $win $col
	    }
	}

	incr col
    }

    #
    # Adjust the columns and schedule a view update for execution at idle time
    #
    adjustColumns $win {} 0
    updateViewWhenIdle $win 1
}

#------------------------------------------------------------------------------
# tablelist::moveActiveTag
#
# Moves the "active" tag to the line or cell that displays the active item or
# element of the tablelist widget win in its body text child.
#------------------------------------------------------------------------------
proc tablelist::moveActiveTag win {
    upvar ::tablelist::ns${win}::data data
    set w $data(body)
    $w tag remove curRow 1.0 end
    $w tag remove active 1.0 end

    if {$data(itemCount) == 0 || $data(colCount) == 0} {
	return ""
    }

    set activeLine [expr {$data(activeRow) + 1}]
    set activeCol $data(activeCol)
    if {$data(-selecttype) eq "row"} {
	$w tag add active $activeLine.0 $activeLine.end
	updateColors $win $activeLine.0 $activeLine.end
    } elseif {$activeLine > 0 && $activeCol >= 0 &&
	      $activeCol < $data(colCount) && !$data($activeCol-hide)} {
	$w tag add curRow $activeLine.0 $activeLine.end
	findTabs $win $w $activeLine $activeCol $activeCol tabIdx1 tabIdx2
	variable pu
	$w tag add active $tabIdx1 $tabIdx2+1$pu
	updateColors $win $activeLine.0 $activeLine.end
    }
}

#------------------------------------------------------------------------------
# tablelist::updateColorsWhenIdle
#
# Arranges for the background and foreground colors of the label, frame, and
# message widgets containing the currently visible images, embedded windows,
# and multiline elements in the body text widget of the tablelist widget win to
# be updated at idle time.
#------------------------------------------------------------------------------
proc tablelist::updateColorsWhenIdle win {
    upvar ::tablelist::ns${win}::data data
    if {[info exists data(colorsId)]} {
	return ""
    }

    set script [list tablelist::updateColors $win]
    variable aquaCrash
    if {$aquaCrash} { set script [list after 0 $script] }
    set data(colorsId) [after idle $script]
}

#------------------------------------------------------------------------------
# tablelist::updateColors
#
# Updates the background and foreground colors of the label, frame, and message
# widgets containing the currently visible images, embedded windows, and
# multiline elements in the body text widget of the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::updateColors {win {fromTextIdx ""} {toTextIdx ""}} {
    upvar ::tablelist::ns${win}::data data
    if {$fromTextIdx eq ""} {
	set updateAll 1

	if {[info exists data(colorsId)]} {
	    after cancel $data(colorsId)
	    unset data(colorsId)
	}
    } else {
	set updateAll 0
    }

    if {$data(itemCount) == 0 || [info exists data(dispId)]} {
	return ""
    }

    set leftCol [colIndex $win @0,0 0 0]
    if {$leftCol < 0} {
	return ""
    }

    variable pu
    set w $data(body)
    if {$updateAll} {
	set topTextIdx [$w index @0,0]
	set btmTextIdx [$w index @0,$data(btmY)]
	set fromTextIdx "$topTextIdx linestart"
	set toTextIdx   "$btmTextIdx lineend"

	$w tag remove select $fromTextIdx $toTextIdx
	$w tag remove itembg $fromTextIdx $toTextIdx
	set hasItemBg   [expr {$data(-itembackground) ne ""}]
	set hasStripeBg [expr {$data(-stripebackground) ne ""}]
	set hasStripeFg [expr {$data(-stripeforeground) ne ""}]

	foreach tag [$w tag names] {
	    if {[string match "*-*ground-*" $tag]} {
		$w tag remove $tag $fromTextIdx $toTextIdx
	    }
	}

	if {$data(isDisabled)} {
	    $w tag add disabled $fromTextIdx $toTextIdx
	}

	if {$data(-colorizecommand) eq ""} {
	    set hasColorizeCmd 0
	} else {
	    set hasColorizeCmd 1
	    set colorizeCmd $data(-colorizecommand)
	}

	variable disp
	set rightCol [colIndex $win @$data(rightX),0 0 0]
	set topLine [expr {int($topTextIdx)}]
	set btmLine [expr {int($btmTextIdx)}]
	if {$btmLine > $data(itemCount)} {
	    set btmLine $data(itemCount)
	}
	for {set line $topLine} {$line <= $btmLine} \
	    {set line [expr {int([$w index "$line.end + 1 $disp c"])}]} {
	    if {![findTabs $win $w $line $leftCol $leftCol tabIdx1 tabIdx2]} {
		continue
	    }

	    if {$hasItemBg} {
		$w tag add itembg $line.0 $line.end
	    }

	    #
	    # Handle the -stripebackground and -stripeforeground
	    # column configuration options, as well as the
	    # -(select)background and -(select)foreground column,
	    # row, and cell configuration options in this row
	    #
	    set row [expr {$line - 1}]
	    set key [lindex $data(keyList) $row]
	    set lineTagNames [$w tag names $line.0]
	    set inStripe [expr {[lsearch -exact $lineTagNames stripe] >= 0}]
	    for {set col $leftCol} {$col <= $rightCol} {incr col} {
		set textIdx2 [$w index $tabIdx2+1$pu]

		if {$inStripe} {
		    foreach opt {-stripebackground -stripeforeground} {
			set name $col$opt
			if {[info exists data($name)]} {
			    $w tag add col$opt-$data($name) $tabIdx1 $textIdx2
			}
		    }
		}

		set selected [cellSelection $win includes $row $col $row $col]
		if {$selected} {
		    $w tag add select $tabIdx1 $textIdx2
		}
		foreach optTail {background foreground} {
		    set normalOpt -$optTail
		    set selectOpt -select$optTail
		    foreach level      [list col row cell] \
			    normalName [list $col$normalOpt $key$normalOpt \
					$key,$col$normalOpt] \
			    selectName [list $col$selectOpt $key$selectOpt \
					$key,$col$selectOpt] {
			if {$selected} {
			    if {[info exists data($selectName)]} {
				$w tag add $level$selectOpt-$data($selectName) \
				       $tabIdx1 $textIdx2
			    }
			} else {
			    if {[info exists data($normalName)]} {
				$w tag add $level$normalOpt-$data($normalName) \
				       $tabIdx1 $textIdx2
			    }
			}
		    }
		}

		if {$hasColorizeCmd} {
		    uplevel #0 $colorizeCmd [list $win $w $key $row $col \
			$tabIdx1 $tabIdx2 $inStripe $selected]
		}

		set tabIdx1 $textIdx2
		set tabIdx2 [$w search -elide "\t" $tabIdx1+1$pu $line.end]
	    }
	}
    }

    set hasExpCollCtrlSelImgs \
	[expr {[info exists ::tablelist::$data(-treestyle)_collapsedSelImg]}]

    foreach {dummy path textIdx} [$w dump -window $fromTextIdx $toTextIdx] {
	if {$path eq ""} {
	    continue
	}

	set class [winfo class $path]
	set isLabel   [expr {$class eq "Label"}]
	set isTblWin  [expr {$class eq "TablelistWindow"}]
	set isMessage [expr {$class eq "Message"}]
	if {!$isLabel && !$isTblWin && !$isMessage} {
	    continue
	}

	set name [winfo name $path]
	foreach {key col} [split [string range $name 4 end] ","] {}
	if {[info exists data($key-elide)] || [info exists data($key-hide)]} {
	    continue
	}

	set tagNames [$w tag names $textIdx]
	set selected [expr {[lsearch -exact $tagNames select] >= 0}]
	set inStripe [expr {[lsearch -exact $tagNames stripe] >= 0}]

	#
	# If the widget is an indentation label then conditionally remove the
	# "active" and "select" tags from its text position and the preceding
	# one, or change its image to become the "normal" or "selected" one
	#
	if {$path eq "$w.ind_$key,$col"} {
	    if {$data(protectIndents)} {
		set fromTextIdx [$w index $textIdx-1$pu]
		set toTextIdx   [$w index $textIdx+1$pu]

		$w tag remove curRow $fromTextIdx $toTextIdx
		$w tag remove active $fromTextIdx $toTextIdx

		if {$updateAll && $selected} {
		    $w tag remove select $fromTextIdx $toTextIdx
		    foreach tag [$w tag names $fromTextIdx] {
			if {[string match "*-selectbackground-*" $tag] ||
			    [string match "*-selectforeground-*" $tag]} {
			    $w tag remove $tag $fromTextIdx $toTextIdx
			}
		    }
		    set selected 0
		    foreach optTail {background foreground} {
			set opt -$optTail
			foreach level [list col row cell] \
				name  [list $col$opt $key$opt $key,$col$opt] {
			    if {[info exists data($name)]} {
				$w tag add $level$opt-$data($name) \
				       $fromTextIdx $toTextIdx
			    }
			}
		    }
		}
	    } elseif {$hasExpCollCtrlSelImgs} {
		set curIndent $data($key,$col-indent)
		if {$selected} {
		    set newIndent [string map {
			"SelActImg" "SelActImg" "ActImg" "SelActImg"
			"SelImg" "SelImg" "collapsedImg" "collapsedSelImg"
			"expandedImg" "expandedSelImg"
		    } $curIndent]
		} else {
		    set newIndent [string map {"Sel" ""} $curIndent]
		}

		if {$curIndent ne $newIndent} {
		    set data($key,$col-indent) $newIndent
		    set idx [string last "g" $newIndent]
		    set img [string range $newIndent 0 $idx]
		    $path configure -image $img
		}
	    }
	}

	if {!$updateAll} {
	    continue
	}

	#
	# Set the widget's background and foreground
	# colors to those of the containing cell
	#
	set isImgLabel [expr {$path eq "$w.img_$key,$col"}]
	if {$data(isDisabled)} {
	    set bg $data(-background)
	    set fg $data(-disabledforeground)
	} elseif {$selected} {
	    if {$isImgLabel &&
		[info exists data($key,$col-imagebackground)]} {
		set bg $data($key,$col-imagebackground)
	    } elseif {[info exists data($key,$col-selectbackground)]} {
		set bg $data($key,$col-selectbackground)
	    } elseif {[info exists data($key-selectbackground)]} {
		set bg $data($key-selectbackground)
	    } elseif {[info exists data($col-selectbackground)]} {
		set bg $data($col-selectbackground)
	    } else {
		set bg $data(-selectbackground)
	    }

	    if {$isMessage || $isTblWin} {
		if {[info exists data($key,$col-selectforeground)]} {
		    set fg $data($key,$col-selectforeground)
		} elseif {[info exists data($key-selectforeground)]} {
		    set fg $data($key-selectforeground)
		} elseif {[info exists data($col-selectforeground)]} {
		    set fg $data($col-selectforeground)
		} else {
		    set fg $data(-selectforeground)
		}
	    }
	} else {
	    if {$isImgLabel &&
		[info exists data($key,$col-imagebackground)]} {
		set bg $data($key,$col-imagebackground)
	    } elseif {[info exists data($key,$col-background)]} {
		set bg $data($key,$col-background)
	    } elseif {[info exists data($key-background)]} {
		set bg $data($key-background)
	    } elseif {$inStripe} {
		if {[info exists data($col-stripebackground)]} {
		    set bg $data($col-stripebackground)
		} elseif {$hasStripeBg} {
		    set bg $data(-stripebackground)
		} else {
		    set bg $data(-background)
		}
	    } else {
		if {[info exists data($col-background)]} {
		    set bg $data($col-background)
		} elseif {$hasItemBg} {
		    set bg $data(-itembackground)
		} else {
		    set bg $data(-background)
		}
	    }

	    if {$isMessage || $isTblWin} {
		if {[info exists data($key,$col-foreground)]} {
		    set fg $data($key,$col-foreground)
		} elseif {[info exists data($key-foreground)]} {
		    set fg $data($key-foreground)
		} elseif {$inStripe} {
		    if {[info exists data($col-stripeforeground)]} {
			set fg $data($col-stripeforeground)
		    } elseif {$hasStripeFg} {
			set fg $data(-stripeforeground)
		    } else {
			set fg $data(-foreground)
		    }
		} else {
		    if {[info exists data($col-foreground)]} {
			set fg $data($col-foreground)
		    } else {
			set fg $data(-foreground)
		    }
		}
	    }
	}
	if {[$path cget -background] ne $bg} {
	    #
	    # Guard against the deletion of embedded images
	    #
	    catch {$path configure -background $bg}
	}
	if {$isMessage && [$path cget -foreground] ne $fg} {
	    $path configure -foreground $fg
	}
	if {$isTblWin} {
	    set cmd [getOpt $win $key $col -windowupdate]
	    if {$cmd ne ""} {
		uplevel #0 $cmd [list $win [keyToRow $win $key] $col \
		    $path.w -background $bg -foreground $fg]
	    }
	}
    }
}

#------------------------------------------------------------------------------
# tablelist::hdr_updateColorsWhenIdle
#
# Arranges for the background and foreground colors of the label, frame, and
# message widgets containing the currently visible images, embedded windows,
# and multiline elements in the header text widget of the tablelist widget win
# to be updated at idle time.
#------------------------------------------------------------------------------
proc tablelist::hdr_updateColorsWhenIdle win {
    upvar ::tablelist::ns${win}::data data
    if {[info exists data(hdr_colorsId)]} {
	return ""
    }

    set script [list tablelist::hdr_updateColors $win]
    variable aquaCrash
    if {$aquaCrash} { set script [list after 0 $script] }
    set data(hdr_colorsId) [after idle $script]
}

#------------------------------------------------------------------------------
# tablelist::hdr_updateColors
#
# Updates the background and foreground colors of the label, frame, and message
# widgets containing the currently visible images, embedded windows, and
# multiline elements in the header text widget of the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::hdr_updateColors win {
    upvar ::tablelist::ns${win}::data data
    if {[info exists data(hdr_colorsId)]} {
	after cancel $data(hdr_colorsId)
	unset data(hdr_colorsId)
    }

    if {$data(hdr_itemCount) == 0} {
	return ""
    }

    set leftCol [colIndex $win @0,0 0 0]
    if {$leftCol < 0} {
	return ""
    }

    set w $data(hdrTxt)
    $w tag remove itembg 2.0 end
    set hasItemBg [expr {$data(-itembackground) ne ""}]

    foreach tag [$w tag names] {
	if {[string match "*-*ground-*" $tag]} {
	    $w tag remove $tag 2.0 end
	}
    }

    if {$data(isDisabled)} {
	$w tag add disabled 2.0 end
    }

    if {$data(-colorizecommand) eq ""} {
	set hasColorizeCmd 0
    } else {
	set hasColorizeCmd 1
	set colorizeCmd $data(-colorizecommand)
    }

    variable pu
    set rightCol [colIndex $win @$data(rightX),0 0 0]
    set hdr_itemCount $data(hdr_itemCount)
    for {set row 0; set line 2} {$row < $hdr_itemCount} {incr row; incr line} {
	if {![findTabs $win $w $line $leftCol $leftCol tabIdx1 tabIdx2]} {
	    continue
	}

	set key [lindex $data(hdr_keyList) $row]

	if {$hasItemBg} {
	    $w tag add itembg $line.0 $line.end
	}

	for {set col $leftCol} {$col <= $rightCol} {incr col} {
	    set textIdx2 [$w index $tabIdx2+1$pu]

	    foreach opt {-background -foreground} {
		foreach level [list col row cell] \
			name  [list $col$opt $key$opt $key,$col$opt] {
		    if {[info exists data($name)]} {
			$w tag add $level$opt-$data($name) $tabIdx1 $textIdx2
		    }
		}
	    }

	    if {$hasColorizeCmd} {
		uplevel #0 $colorizeCmd [list $win $w $key $row $col \
		    $tabIdx1 $tabIdx2 0 0]
	    }

	    set tabIdx1 $textIdx2
	    set tabIdx2 [$w search -elide "\t" $tabIdx1+1$pu $line.end]
	}
    }

    foreach {dummy path textIdx} [$w dump -window 2.0 end] {
	if {$path eq ""} {
	    continue
	}

	set class [winfo class $path]
	set isLabel   [expr {$class eq "Label"}]
	set isTblWin  [expr {$class eq "TablelistWindow"}]
	set isMessage [expr {$class eq "Message"}]
	if {!$isLabel && !$isTblWin && !$isMessage} {
	    continue
	}

	set name [winfo name $path]
	foreach {key col} [split [string range $name 4 end] ","] {}

	#
	# Set the widget's background and foreground
	# colors to those of the containing cell
	#
	if {$data(isDisabled)} {
	    set bg $data(-background)
	    set fg $data(-disabledforeground)
	} else {
	    if {$path eq "$w.img_$key,$col" &&
		[info exists data($key,$col-imagebackground)]} {
		set bg $data($key,$col-imagebackground)
	    } elseif {[info exists data($key,$col-background)]} {
		set bg $data($key,$col-background)
	    } elseif {[info exists data($key-background)]} {
		set bg $data($key-background)
	    } else {
		if {[info exists data($col-background)]} {
		    set bg $data($col-background)
		} elseif {$hasItemBg} {
		    set bg $data(-itembackground)
		} else {
		    set bg $data(-background)
		}
	    }

	    if {$isMessage || $isTblWin} {
		if {[info exists data($key,$col-foreground)]} {
		    set fg $data($key,$col-foreground)
		} elseif {[info exists data($key-foreground)]} {
		    set fg $data($key-foreground)
		} else {
		    if {[info exists data($col-foreground)]} {
			set fg $data($col-foreground)
		    } else {
			set fg $data(-foreground)
		    }
		}
	    }
	}
	if {[$path cget -background] ne $bg} {
	    #
	    # Guard against the deletion of embedded images
	    #
	    catch {$path configure -background $bg}
	}
	if {$isMessage && [$path cget -foreground] ne $fg} {
	    $path configure -foreground $fg
	}
	if {$isTblWin} {
	    set cmd [getOpt $win $key $col -windowupdate]
	    if {$cmd ne ""} {
		uplevel #0 $cmd [list $win [hdr_keyToRow $win $key] $col \
		    $path.w -background $bg -foreground $fg]
	    }
	}
    }
}

#------------------------------------------------------------------------------
# tablelist::updateScrlColOffsetWhenIdle
#
# Arranges for the scrolled column offset of the tablelist widget win to be
# updated at idle time.
#------------------------------------------------------------------------------
proc tablelist::updateScrlColOffsetWhenIdle win {
    upvar ::tablelist::ns${win}::data data
    if {[info exists data(offsetId)]} {
	return ""
    }

    set script [list tablelist::updateScrlColOffset $win]
    variable aquaCrash
    if {$aquaCrash} { set script [list after 0 $script] }
    set data(offsetId) [after idle $script]
}

#------------------------------------------------------------------------------
# tablelist::updateScrlColOffset
#
# Updates the scrolled column offset of the tablelist widget win to fit into
# the allowed range.
#------------------------------------------------------------------------------
proc tablelist::updateScrlColOffset win {
    upvar ::tablelist::ns${win}::data data
    unset data(offsetId)

    set maxScrlColOffset [getMaxScrlColOffset $win]
    if {$data(scrlColOffset) > $maxScrlColOffset} {
	set data(scrlColOffset) $maxScrlColOffset
	hdr_adjustElidedText $win
	adjustElidedText $win
	redisplayVisibleItems $win
    }
}

#------------------------------------------------------------------------------
# tablelist::updateHScrlbarWhenIdle
#
# Arranges for the horizontal scrollbar associated with the tablelist widget
# win to be updated at idle time.
#------------------------------------------------------------------------------
proc tablelist::updateHScrlbarWhenIdle win {
    upvar ::tablelist::ns${win}::data data
    if {[info exists data(hScrlbarId)]} {
	return ""
    }

    set script [list tablelist::updateHScrlbar $win]
    variable aquaCrash
    if {$aquaCrash} { set script [list after 0 $script] }
    set data(hScrlbarId) [after idle $script]
}

#------------------------------------------------------------------------------
# tablelist::updateHScrlbar
#
# Updates the horizontal scrollbar associated with the tablelist widget win by
# invoking the command specified as the value of the -xscrollcommand option.
#------------------------------------------------------------------------------
proc tablelist::updateHScrlbar {win args} {
    upvar ::tablelist::ns${win}::data data
    if {[info exists data(hScrlbarId)]} {
	after cancel $data(hScrlbarId)
	unset data(hScrlbarId)
    }

    set xView [expr {[llength $args] == 0 ? [xviewSubCmd $win {}] : $args}]
    foreach {frac1 frac2} $xView {}
    foreach {frac1Old frac2Old} $data(xView) {}
    set leftCol  [columnindexSubCmd $win left]
    set rightCol [columnindexSubCmd $win right]
    if {$frac1 != $frac1Old || $frac2 != $frac2Old} {
	if {$data(-xscrollcommand) ne ""} {
	    eval $data(-xscrollcommand) $frac1 $frac2
	}

	genVirtualEvent $win <<TablelistXViewChanged>> [list $leftCol $rightCol]
    } elseif {$frac1 == 0 && $frac2 == 1 && $rightCol != $data(rightCol)} {
	genVirtualEvent $win <<TablelistXViewChanged>> [list $leftCol $rightCol]
    }
    array set data [list xView $xView rightCol $rightCol]
}

#------------------------------------------------------------------------------
# tablelist::updateVScrlbarWhenIdle
#
# Arranges for the vertical scrollbar associated with the tablelist widget win
# to be updated at idle time.
#------------------------------------------------------------------------------
proc tablelist::updateVScrlbarWhenIdle win {
    upvar ::tablelist::ns${win}::data data
    if {[info exists data(vScrlbarId)]} {
	return ""
    }

    set script [list tablelist::updateVScrlbar $win]
    variable aquaCrash
    if {$aquaCrash} { set script [list after 0 $script] }
    set data(vScrlbarId) [after idle $script]
}

#------------------------------------------------------------------------------
# tablelist::updateVScrlbar
#
# Updates the vertical scrollbar associated with the tablelist widget win by
# invoking the command specified as the value of the -yscrollcommand option.
#------------------------------------------------------------------------------
proc tablelist::updateVScrlbar win {
    upvar ::tablelist::ns${win}::data data
    if {[info exists data(vScrlbarId)]} {
	after cancel $data(vScrlbarId)
	unset data(vScrlbarId)
    }

    set yView [yviewSubCmd $win {}]
    foreach {frac1 frac2} $yView {}
    foreach {frac1Old frac2Old} $data(yView) {}
    set topRow [indexSubCmd $win top]
    set btmRow [indexSubCmd $win bottom]
    if {$frac1 != $frac1Old || $frac2 != $frac2Old} {
	if {$data(-yscrollcommand) ne ""} {
	    eval $data(-yscrollcommand) $frac1 $frac2
	}

	genVirtualEvent $win <<TablelistYViewChanged>> [list $topRow $btmRow]
    } elseif {$frac1 == 0 && $frac2 == 1 && $btmRow != $data(btmRow)} {
	genVirtualEvent $win <<TablelistYViewChanged>> [list $topRow $btmRow]
    }
    array set data [list yView $yView btmRow $btmRow]

    if {[winfo viewable $win] && ![info exists data(colBeingResized)] &&
	![info exists data(redrawId)]} {
	set data(redrawId) [after 50 [list tablelist::forceRedraw $win]]
    }

    event generate $win <<TablelistViewUpdated>>
}

#------------------------------------------------------------------------------
# tablelist::forceRedraw
#
# Enforces a redraw of the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::forceRedraw win {
    upvar ::tablelist::ns${win}::data data
    unset data(redrawId)

    set w $data(body)
    set fromTextIdx "[$w index @0,0] linestart"
    set toTextIdx "[$w index @0,$data(btmY)] lineend"
    $w tag add redraw $fromTextIdx $toTextIdx
    $w tag remove redraw $fromTextIdx $toTextIdx

    workAroundAquaTkBugs $win
}

#------------------------------------------------------------------------------
# tablelist::workAroundAquaTkBugs
#
# Works around some Tk bugs on Mac OS X/11+.
#------------------------------------------------------------------------------
proc tablelist::workAroundAquaTkBugs win {
    variable winSys
    if {$winSys eq "aqua" && [winfo viewable $win]} {
	set par [winfo parent $win]
	if {[mwutil::containsPointer $par]} {
	    event generate $par <Leave>
	    event generate $par <Enter>
	} else {
	    event generate $par <Enter>
	    event generate $par <Leave>
	}

	upvar ::tablelist::ns${win}::data data
	raise $data(body)
	lower $data(body)

	if {[winfo exists $data(bodyFrm)]} {
	    lower $data(bodyFrm)
	    raise $data(bodyFrm)
	}
    }
}

#------------------------------------------------------------------------------
# tablelist::adjustElidedText
#
# Updates the elided text ranges of the body text widget of the tablelist
# widget win.
#------------------------------------------------------------------------------
proc tablelist::adjustElidedText win {
    upvar ::tablelist::ns${win}::data data
    if {[info exists data(dispId)]} {
	return ""
    }

    #
    # Remove the "hiddenCol" tag
    #
    set w $data(body)
    $w tag remove hiddenCol 1.0 end

    #
    # Add the "hiddenCol" tag to the contents of the hidden
    # columns from the top to the bottom window line
    #
    variable disp
    variable pu
    if {$data(hiddenColCount) > 0 && $data(itemCount) > 0} {
	set topLine [expr {int([$w index @0,0])}]
	set btmLine [expr {int([$w index @0,$data(btmY)])}]
	if {$btmLine > $data(itemCount)} {
	    set btmLine $data(itemCount)
	}
	for {set line $topLine} {$line <= $btmLine} \
	    {set line [expr {int([$w index "$line.end + 1 $disp c"])}]} {
	    set textIdx1 $line.0
	    for {set col 0; set count 0} \
		{$col < $data(colCount) && $count < $data(hiddenColCount)} \
		{incr col} {
		set textIdx2 \
		    [$w search -elide "\t" $textIdx1+1$pu $line.end]+1$pu
		if {$textIdx2 eq "+1$pu"} {
		    break
		}
		if {$data($col-hide)} {
		    incr count
		    $w tag add hiddenCol $textIdx1 $textIdx2
		}
		set textIdx1 $textIdx2
	    }

	    #
	    # Update btmLine because it may
	    # change due to the "hiddenCol" tag
	    #
	    set btmLine [expr {int([$w index @0,$data(btmY)])}]
	    if {$btmLine > $data(itemCount)} {
		set btmLine $data(itemCount)
	    }
	}

	if {[lindex [$w yview] 1] == 1} {
	    for {set line $btmLine} {$line >= $topLine} \
		{set line [expr {int([$w index "$line.0 - 1 $disp c"])}]} {
		set textIdx1 $line.0
		for {set col 0; set count 0} \
		    {$col < $data(colCount) && $count < $data(hiddenColCount)} \
		    {incr col} {
		    set textIdx2 \
			[$w search -elide "\t" $textIdx1+1$pu $line.end]+1$pu
		    if {$textIdx2 eq "+1$pu"} {
			break
		    }
		    if {$data($col-hide)} {
			incr count
			$w tag add hiddenCol $textIdx1 $textIdx2
		    }
		    set textIdx1 $textIdx2
		}

		if {$line == 1} {
		    break
		}

		#
		# Update topLine because it may
		# change due to the "hiddenCol" tag
		#
		set topLine [expr {int([$w index @0,0])}]
	    }
	}
    }

    if {$data(-titlecolumns) == 0} {
	return ""
    }

    #
    # Remove the "elidedCol" tag
    #
    $w tag remove elidedCol 1.0 end
    for {set col 0} {$col < $data(colCount)} {incr col} {
	set data($col-elide) 0
    }

    if {$data(scrlColOffset) == 0} {
	adjustColumns $win {} 0
	return ""
    }

    #
    # Find max. $data(scrlColOffset) non-hidden columns with indices >=
    # $data(-titlecolumns) and retain the first and last of these indices
    #
    set firstCol $data(-titlecolumns)
    while {$firstCol < $data(colCount) && $data($firstCol-hide)} {
	incr firstCol
    }
    if {$firstCol >= $data(colCount)} {
	return ""
    }
    set lastCol $firstCol
    set nonHiddenCount 1
    while {$nonHiddenCount < $data(scrlColOffset) &&
	   $lastCol < $data(colCount)} {
	incr lastCol
	if {!$data($lastCol-hide)} {
	    incr nonHiddenCount
	}
    }

    #
    # Add the "elidedCol" tag to the contents of these
    # columns from the top to the bottom window line
    #
    if {$data(itemCount) > 0} {
	set topLine [expr {int([$w index @0,0])}]
	set btmLine [expr {int([$w index @0,$data(btmY)])}]
	if {$btmLine > $data(itemCount)} {
	    set btmLine $data(itemCount)
	}
	for {set line $topLine} {$line <= $btmLine} \
	    {set line [expr {int([$w index "$line.end + 1 $disp c"])}]} {
	    if {[findTabs $win $w $line $firstCol $lastCol \
		 tabIdx1 tabIdx2]} {
		$w tag add elidedCol $tabIdx1 $tabIdx2+1$pu
	    }

	    #
	    # Update btmLine because it may change due to the "elidedCol" tag
	    #
	    set btmLine [expr {int([$w index @0,$data(btmY)])}]
	    if {$btmLine > $data(itemCount)} {
		set btmLine $data(itemCount)
	    }
	}

	if {[lindex [$w yview] 1] == 1} {
	    for {set line $btmLine} {$line >= $topLine} \
		{set line [expr {int([$w index "$line.0 - 1 $disp c"])}]} {
		if {[findTabs $win $w $line $firstCol $lastCol \
		     tabIdx1 tabIdx2]} {
		    $w tag add elidedCol $tabIdx1 $tabIdx2+1$pu
		}

		if {$line == 1} {
		    break
		}

		#
		# Update topLine because it may
		# change due to the "elidedCol" tag
		#
		set topLine [expr {int([$w index @0,0])}]
	    }
	}
    }

    #
    # Adjust the columns
    #
    for {set col $firstCol} {$col <= $lastCol} {incr col} {
	set data($col-elide) 1
    }
    adjustColumns $win {} 0
}

#------------------------------------------------------------------------------
# tablelist::hdr_adjustElidedText
#
# Updates the elided text ranges of the header text widget of the tablelist
# widget win.
#------------------------------------------------------------------------------
proc tablelist::hdr_adjustElidedText win {
    #
    # Remove the "hiddenCol" tag
    #
    upvar ::tablelist::ns${win}::data data
    set w $data(hdrTxt)
    $w tag remove hiddenCol 1.0 end

    #
    # Add the "hiddenCol" tag to the contents of the hidden columns
    #
    variable pu
    if {$data(hiddenColCount) > 0} {
	set hdr_itemCount $data(hdr_itemCount)
	for {set row 0; set line 2} {$row < $hdr_itemCount} \
	    {incr row; incr line} {
	    set textIdx1 $line.0
	    for {set col 0; set count 0} \
		{$col < $data(colCount) && $count < $data(hiddenColCount)} \
		{incr col} {
		set textIdx2 \
		    [$w search -elide "\t" $textIdx1+1$pu $line.end]+1$pu
		if {$textIdx2 eq "+1$pu"} {
		    break
		}
		if {$data($col-hide)} {
		    incr count
		    $w tag add hiddenCol $textIdx1 $textIdx2
		}
		set textIdx1 $textIdx2
	    }
	}
    }

    if {$data(-titlecolumns) == 0} {
	return ""
    }

    #
    # Remove the "elidedCol" tag
    #
    $w tag remove elidedCol 1.0 end
    for {set col 0} {$col < $data(colCount)} {incr col} {
	set data($col-elide) 0
    }

    if {$data(scrlColOffset) == 0} {
	adjustColumns $win {} 0
	return ""
    }

    #
    # Find max. $data(scrlColOffset) non-hidden columns with indices >=
    # $data(-titlecolumns) and retain the first and last of these indices
    #
    set firstCol $data(-titlecolumns)
    while {$firstCol < $data(colCount) && $data($firstCol-hide)} {
	incr firstCol
    }
    if {$firstCol >= $data(colCount)} {
	return ""
    }
    set lastCol $firstCol
    set nonHiddenCount 1
    while {$nonHiddenCount < $data(scrlColOffset) &&
	   $lastCol < $data(colCount)} {
	incr lastCol
	if {!$data($lastCol-hide)} {
	    incr nonHiddenCount
	}
    }

    #
    # Add the "elidedCol" tag to the contents of these columns
    #
    set hdr_itemCount $data(hdr_itemCount)
    for {set row 0; set line 2} {$row < $hdr_itemCount} {incr row; incr line} {
	if {[findTabs $win $w $line $firstCol $lastCol \
	     tabIdx1 tabIdx2]} {
	    $w tag add elidedCol $tabIdx1 $tabIdx2+1$pu
	}
    }

    #
    # Adjust the columns
    #
    for {set col $firstCol} {$col <= $lastCol} {incr col} {
	set data($col-elide) 1
    }
    adjustColumns $win {} 0
}

#------------------------------------------------------------------------------
# tablelist::redisplayWhenIdle
#
# Arranges for the items of the tablelist widget win to be redisplayed at idle
# time.
#------------------------------------------------------------------------------
proc tablelist::redisplayWhenIdle win {
    upvar ::tablelist::ns${win}::data data
    if {[info exists data(redispId)] || $data(itemCount) == 0} {
	return ""
    }

    set script [list tablelist::redisplay $win]
    variable aquaCrash
    if {$aquaCrash} { set script [list after 0 $script] }
    set data(redispId) [after idle $script]

    #
    # Cancel the execution of all delayed redisplayCol commands
    #
    foreach name [array names data *-redispId] {
	after cancel $data($name)
	unset data($name)
    }
}

#------------------------------------------------------------------------------
# tablelist::redisplay
#
# Redisplays the items of the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::redisplay win {
    upvar ::tablelist::ns${win}::data data
    if {[info exists data(redispId)]} {
	after cancel $data(redispId)
	unset data(redispId)
    }

    variable snipSides
    set snipStr $data(-snipstring)

    set w $data(hdrTxt)
    set hdr_newItemList {}
    set row 0
    set line 2
    foreach item $data(hdr_itemList) {
	#
	# Empty the line, clip the elements if necessary,
	# and insert them with the corresponding tags
	#
	$w delete $line.0 $line.end
	set keyIdx [expr {[llength $item] - 1}]
	set key [lindex $item end]
	set hasRowFont [info exists data($key-font)]
	set newItem {}
	set col 0
	foreach fmtCmdFlag $data(fmtCmdFlagList) \
		colFont $data(colFontList) \
		colTags $data(colTagsList) \
		{pixels alignment} $data(colList) {
	    if {$col < $keyIdx} {
		set text [lindex $item $col]
	    } else {
		set text ""
	    }
	    lappend newItem $text

	    if {$fmtCmdFlag} {
		set text [formatElem $win $key $row $col $text]
	    }
	    if {[string match "*\t*" $text]} {
		set text [mapTabs $text]
	    }

	    #
	    # Build the list of tags to be applied to the cell
	    #
	    if {$hasRowFont} {
		set cellFont $data($key-font)
	    } else {
		set cellFont $colFont
	    }
	    set cellTags $colTags
	    if {[info exists data($key,$col-font)]} {
		set cellFont $data($key,$col-font)
		lappend cellTags cell-font-$data($key,$col-font)
	    }

	    #
	    # Insert the text and the label or window
	    # (if any) into the header text widget
	    #
	    appendComplexElem $win $key $row $col $text $pixels \
			      $alignment $snipStr $cellFont $cellTags $line

	    incr col
	}

	if {[info exists data($key-font)]} {
	    $w tag add row-font-$data($key-font) $line.0 $line.end
	}

	lappend newItem $key
	lappend hdr_newItemList $newItem

	incr row
	incr line
    }

    set data(hdr_itemList) $hdr_newItemList

    #
    # Save some data of the edit window if present
    #
    if {[set editCol $data(editCol)] >= 0} {
	set editRow $data(editRow)
	saveEditData $win
    }

    variable pu
    set rowTagRefCount $data(rowTagRefCount)
    set cellTagRefCount $data(cellTagRefCount)
    set isSimple [expr {$data(imgCount) == 0 && $data(winCount) == 0 &&
			$data(indentCount) == 0}]
    set w $data(body)
    displayItems $win
    set padY [expr {[$w cget -spacing1] == 0}]
    set newItemList {}
    set row 0
    set line 1
    foreach item $data(itemList) {
	#
	# Empty the line, clip the elements if necessary,
	# and insert them with the corresponding tags
	#
	$w delete $line.0 $line.end
	set keyIdx [expr {[llength $item] - 1}]
	set key [lindex $item end]
	if {$rowTagRefCount == 0} {
	    set hasRowFont 0
	} else {
	    set hasRowFont [info exists data($key-font)]
	}
	set newItem {}
	set col 0
	if {$isSimple} {
	    set insertArgs {}
	    set multilineData {}
	    foreach fmtCmdFlag $data(fmtCmdFlagList) \
		    colFont $data(colFontList) \
		    colTags $data(colTagsList) \
		    {pixels alignment} $data(colList) {
		if {$col < $keyIdx} {
		    set text [lindex $item $col]
		} else {
		    set text ""
		}
		lappend newItem $text

		if {$fmtCmdFlag} {
		    set text [formatElem $win $key $row $col $text]
		}
		if {[string match "*\t*" $text]} {
		    set text [mapTabs $text]
		}

		#
		# Build the list of tags to be applied to the cell
		#
		if {$hasRowFont} {
		    set cellFont $data($key-font)
		} else {
		    set cellFont $colFont
		}
		set cellTags $colTags
		if {$cellTagRefCount != 0} {
		    if {[info exists data($key,$col-font)]} {
			set cellFont $data($key,$col-font)
			lappend cellTags cell-font-$data($key,$col-font)
		    }
		}

		#
		# Clip the element if necessary
		#
		set multiline [string match "*\n*" $text]
		if {$pixels == 0} {		;# convention: dynamic width
		    if {$data($col-maxPixels) > 0} {
			if {$data($col-reqPixels) > $data($col-maxPixels)} {
			    set pixels $data($col-maxPixels)
			}
		    }
		}
		if {$pixels != 0} {
		    incr pixels $data($col-delta)

		    if {$data($col-wrap) && !$multiline} {
			if {[font measure $cellFont -displayof $win $text] >
			    $pixels} {
			    set multiline 1
			}
		    }

		    set snipSide \
			$snipSides($alignment,$data($col-changesnipside))
		    if {$multiline} {
			set list [split $text "\n"]
			if {$data($col-wrap)} {
			    set snipSide ""
			}
			set text [joinList $win $list $cellFont \
				  $pixels $snipSide $snipStr]
		    } elseif {!$data(-displayondemand)} {
			set text [strRange $win $text $cellFont \
				  $pixels $snipSide $snipStr]
		    }
		}

		if {$multiline} {
		    lappend insertArgs "\t\t" $cellTags
		    lappend multilineData \
			    $col $text $cellFont $pixels $alignment
		} elseif {$data(-displayondemand)} {
		    lappend insertArgs "\t\t" $cellTags
		} else {
		    lappend insertArgs "\t$text\t" $cellTags
		}

		incr col
	    }

	    #
	    # Insert the item into the body text widget
	    #
	    if {[llength $insertArgs] != 0} {
		eval [list $w insert $line.0] $insertArgs
	    }

	    #
	    # Embed the message widgets displaying multiline elements
	    #
	    foreach {col text font pixels alignment} $multilineData {
		if {[findTabs $win $w $line $col $col tabIdx1 tabIdx2]} {
		    set msgScript [list ::tablelist::displayText $win $key \
				   $col $text $font $pixels $alignment]
		    set msgScript [string map {"%" "%%"} $msgScript]
		    $w window create $tabIdx2 -pady $padY -create $msgScript
		    $w tag add elidedWin $tabIdx2
		}
	    }

	} else {
	    foreach fmtCmdFlag $data(fmtCmdFlagList) \
		    colFont $data(colFontList) \
		    colTags $data(colTagsList) \
		    {pixels alignment} $data(colList) {
		if {$col < $keyIdx} {
		    set text [lindex $item $col]
		} else {
		    set text ""
		}
		lappend newItem $text

		if {$fmtCmdFlag} {
		    set text [formatElem $win $key $row $col $text]
		}
		if {[string match "*\t*" $text]} {
		    set text [mapTabs $text]
		}

		#
		# Build the list of tags to be applied to the cell
		#
		if {$hasRowFont} {
		    set cellFont $data($key-font)
		} else {
		    set cellFont $colFont
		}
		set cellTags $colTags
		if {$cellTagRefCount != 0} {
		    if {[info exists data($key,$col-font)]} {
			set cellFont $data($key,$col-font)
			lappend cellTags cell-font-$data($key,$col-font)
		    }
		}

		#
		# Insert the text and the label or window
		# (if any) into the body text widget
		#
		appendComplexElem $win $key $row $col $text $pixels \
				  $alignment $snipStr $cellFont $cellTags $line

		incr col
	    }
	}

	if {$rowTagRefCount != 0} {
	    if {[info exists data($key-font)]} {
		$w tag add row-font-$data($key-font) $line.0 $line.end
	    }
	}

	if {[info exists data($key-elide)]} {
	    $w tag add elidedRow $line.0 $line.end+1$pu
	}
	if {[info exists data($key-hide)]} {
	    $w tag add hiddenRow $line.0 $line.end+1$pu
	}

	lappend newItem $key
	lappend newItemList $newItem

	set row $line
	incr line
    }

    set data(itemList) $newItemList

    #
    # Conditionally move the "active" tag to the active line or cell
    #
    if {$data(ownsFocus)} {
	moveActiveTag $win
    }

    #
    # Adjust the elided text and restore the stripes in the body text widget
    #
    hdr_adjustElidedText $win
    adjustElidedText $win
    redisplayVisibleItems $win
    makeStripes $win

    #
    # Restore the edit window if it was present before
    #
    if {$editCol >= 0} {
	doEditCell $win $editRow $editCol 1
    }
}

#------------------------------------------------------------------------------
# tablelist::redisplayVisibleItems
#
# Redisplays the visible items of the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::redisplayVisibleItems win {
    upvar ::tablelist::ns${win}::data data
    if {$data(itemCount) == 0} {
	return ""
    }

    set leftCol [colIndex $win @0,0 0 0]
    if {$leftCol < 0} {
	return ""
    }

    set w $data(body)
    displayItems $win

    set topTextIdx [$w index @0,0]
    set btmTextIdx [$w index @0,$data(btmY)]
    set fromTextIdx "$topTextIdx linestart"
    set toTextIdx   "$btmTextIdx lineend"
    $w tag remove elidedWin $fromTextIdx $toTextIdx

    if {!$data(-displayondemand)} {
	return ""
    }

    variable disp
    variable snipSides
    variable pu

    set rightCol [colIndex $win @$data(rightX),0 0 0]
    set topLine [expr {int($topTextIdx)}]
    set btmLine [expr {int($btmTextIdx)}]
    if {$btmLine > $data(itemCount)} {
	set btmLine $data(itemCount)
    }
    set snipStr $data(-snipstring)

    for {set line $topLine} {$line <= $btmLine} \
	{set line [expr {int([$w index "$line.end + 1 $disp c"])}]} {
	if {![findTabs $win $w $line $leftCol $leftCol tabIdx1 tabIdx2]} {
	    continue
	}

	set row [expr {$line - 1}]
	set item [lindex $data(itemList) $row]
	set key [lindex $item end]

	#
	# Format the item
	#
	set dispItem [lrange $item 0 $data(lastCol)]
	if {$data(hasFmtCmds)} {
	    set dispItem [formatItem $win $key $row $dispItem]
	}
	if {[string match "*\t*" $dispItem]} {
	    set dispItem [mapTabs $dispItem]
	}

	set textIdx1 [$w index $tabIdx1+1$pu]
	for {set col $leftCol} {$col <= $rightCol} {incr col} {
	    #
	    # Nothing to do if the text is empty or is already displayed,
	    # or interactive editing for this cell is in progress
	    #
	    set text [lindex $dispItem $col]
	    if {$text eq "" || [$w get $textIdx1 $tabIdx2] ne "" ||
		($row == $data(editRow) && $col == $data(editCol))} {
		set textIdx1 [$w index $tabIdx2+2$pu]
		set tabIdx2 [$w search -elide "\t" $textIdx1 $line.end]
		continue
	    }

	    set pixels [lindex $data(colList) [expr {2*$col}]]
	    if {$pixels == 0} {			;# convention: dynamic width
		if {$data($col-maxPixels) > 0} {
		    if {$data($col-reqPixels) > $data($col-maxPixels)} {
			set pixels $data($col-maxPixels)
		    }
		}
	    }
	    if {$pixels != 0} {
		incr pixels $data($col-delta)
	    }

	    #
	    # Nothing to do if the cell has an (indentation)
	    # image or window, or contains multiline text
	    #
	    set aux [getAuxData $win $key $col auxType auxWidth $pixels]
	    set indent [getIndentData $win $key $col indentWidth]
	    set multiline [string match "*\n*" $text]
	    if {$auxWidth != 0 || $indentWidth != 0 || $multiline} {
		set textIdx1 [$w index $tabIdx2+2$pu]
		set tabIdx2 [$w search -elide "\t" $textIdx1 $line.end]
		continue
	    }

	    #
	    # Adjust the cell text
	    #
	    set maxTextWidth $pixels
	    if {[info exists data($key,$col-font)]} {
		set cellFont $data($key,$col-font)
	    } elseif {[info exists data($key-font)]} {
		set cellFont $data($key-font)
	    } else {
		set cellFont [lindex $data(colFontList) $col]
	    }
	    if {$pixels != 0} {
		set maxTextWidth \
		    [getMaxTextWidth $pixels $auxWidth $indentWidth]

		if {$data($col-wrap) && !$multiline} {
		    if {[font measure $cellFont -displayof $win $text] >
			$maxTextWidth} {
			#
			# The element is displayed as multiline text
			#
			set textIdx1 [$w index $tabIdx2+2$pu]
			set tabIdx2 [$w search -elide "\t" $textIdx1 $line.end]
			continue
		    }
		}
	    }
	    set alignment [lindex $data(colList) [expr {2*$col + 1}]]
	    set snipSide $snipSides($alignment,$data($col-changesnipside))
	    adjustElem $win text auxWidth indentWidth $cellFont $pixels \
		       $snipSide $snipStr

	    #
	    # Update the text widget's content between the two tabs
	    #
	    $w mark set tabMark2 [$w index $tabIdx2]
	    updateCell $w $textIdx1 $tabIdx2 $text $aux $auxType $auxWidth \
		       $indent $indentWidth $alignment ""

	    set textIdx1 [$w index tabMark2+2$pu]
	    set tabIdx2 [$w search -elide "\t" $textIdx1 $line.end]
	}
    }
}

#------------------------------------------------------------------------------
# tablelist::redisplayColWhenIdle
#
# Arranges for the elements of the col'th column of the tablelist widget win to
# be redisplayed at idle time.
#------------------------------------------------------------------------------
proc tablelist::redisplayColWhenIdle {win col} {
    upvar ::tablelist::ns${win}::data data
    if {[info exists data($col-redispId)] || [info exists data(redispId)]} {
	return ""
    }

    set script [list tablelist::redisplayCol $win $col 0 last]
    variable aquaCrash
    if {$aquaCrash} { set script [list after 0 $script] }
    set data($col-redispId) [after idle $script]
}

#------------------------------------------------------------------------------
# tablelist::redisplayCol
#
# Redisplays the elements of the col'th column of the tablelist widget win, in
# the range specified by first and last.  Prior to that, it redisplays the
# elements of the specified column in the header text widget.
#------------------------------------------------------------------------------
proc tablelist::redisplayCol {win col first last {inBody 1}} {
    upvar ::tablelist::ns${win}::data data
    set allRows [expr {$first == 0 && $last eq "last"}]
    if {$allRows && [info exists data($col-redispId)]} {
	after cancel $data($col-redispId)
	unset data($col-redispId)
    }

    if {$col > $data(lastCol) || $first < 0} {
	return ""
    }

    set fmtCmdFlag [lindex $data(fmtCmdFlagList) $col]
    set colFont [lindex $data(colFontList) $col]
    set snipStr $data(-snipstring)

    set pixels [lindex $data(colList) [expr {2*$col}]]
    if {$pixels == 0} {				;# convention: dynamic width
	if {$data($col-maxPixels) > 0} {
	    if {$data($col-reqPixels) > $data($col-maxPixels)} {
		set pixels $data($col-maxPixels)
	    }
	}
    }
    if {$pixels != 0} {
	incr pixels $data($col-delta)
    }
    set alignment [lindex $data(colList) [expr {2*$col + 1}]]
    variable snipSides
    set snipSide $snipSides($alignment,$data($col-changesnipside))
    variable pu

    if {$inBody} {
	set hdr_first 0
	set hdr_last $data(hdr_lastRow)
    } else {
	set hdr_first $first
	set hdr_last $last
    }

    set w $data(hdrTxt)
    for {set row $hdr_first; set line [expr {$hdr_first + 2}]} \
	{$row <= $hdr_last} {incr row; incr line} {
	set item [lindex $data(hdr_itemList) $row]
	set key [lindex $item end]

	#
	# Adjust the cell text and the image or window width
	#
	set text [lindex $item $col]
	if {$fmtCmdFlag} {
	    set text [formatElem $win $key $row $col $text]
	}
	if {[string match "*\t*" $text]} {
	    set text [mapTabs $text]
	}
	set multiline [string match "*\n*" $text]
	set aux [getAuxData $win $key $col auxType auxWidth $pixels]
	set indentWidth 0
	set maxTextWidth $pixels
	if {[info exists data($key,$col-font)]} {
	    set cellFont $data($key,$col-font)
	} elseif {[info exists data($key-font)]} {
	    set cellFont $data($key-font)
	} else {
	    set cellFont $colFont
	}
	if {$pixels != 0} {
	    set maxTextWidth [getMaxTextWidth $pixels $auxWidth 0]

	    if {$data($col-wrap) && !$multiline} {
		if {[font measure $cellFont -displayof $win $text] >
		    $maxTextWidth} {
		    set multiline 1
		}
	    }
	}
	if {$multiline} {
	    set list [split $text "\n"]
	    set snipSide2 $snipSide
	    if {$data($col-wrap)} {
		set snipSide2 ""
	    }
	    adjustMlElem $win list auxWidth indentWidth $cellFont \
			 $pixels $snipSide2 $snipStr
	    set msgScript [list ::tablelist::displayText $win $key $col \
			   [join $list "\n"] $cellFont $maxTextWidth $alignment]
	    set msgScript [string map {"%" "%%"} $msgScript]
	} else {
	    adjustElem $win text auxWidth indentWidth $cellFont \
		       $pixels $snipSide $snipStr
	}

	#
	# Update the text widget's content between the two tabs
	#
	if {[findTabs $win $w $line $col $col tabIdx1 tabIdx2]} {
	    if {$auxType > 1 && $auxWidth > 0 && ![winfo exists $aux]} {
		#
		# Create a frame and evaluate the script that
		# creates a child window within the frame
		#
		tk::frame $aux -borderwidth 0 -class TablelistWindow \
			       -container 0 -height $data($key,$col-reqHeight) \
			       -highlightthickness 0 -padx 0 -pady 0 \
			       -relief flat -takefocus 0 -width $auxWidth
		bindtags $aux [linsert [bindtags $aux] 1 \
			       $data(bodyTag) TablelistBody]
		uplevel #0 $data($key,$col-window) [list $win $row $col $aux.w]
		set reqHeight [winfo reqheight $aux.w]
		if {$reqHeight != 1 &&
		    $reqHeight != $data($key,$col-reqHeight)} {
		    set data($key,$col-reqHeight) $reqHeight
		    $aux configure -height $reqHeight
		}
	    }

	    if {$multiline} {
		updateMlCell $w $tabIdx1+1$pu $tabIdx2 $msgScript $aux \
			     $auxType $auxWidth "" 0 $alignment \
			     [getOpt $win $key $col -valign]
	    } else {
		updateCell $w $tabIdx1+1$pu $tabIdx2 $text $aux \
			   $auxType $auxWidth "" 0 $alignment \
			   [getOpt $win $key $col -valign]
	    }
	}
    }

    if {!$inBody} {
	return ""
    }

    if {$last eq "last"} {
	set last $data(lastRow)
    }

    set w $data(body)
    displayItems $win
    for {set row $first; set line [expr {$first + 1}]} {$row <= $last} \
	{set row $line; incr line} {
	if {$row == $data(editRow) && $col == $data(editCol)} {
	    continue
	}

	set item [lindex $data(itemList) $row]
	set key [lindex $item end]
	if {!$allRows &&
	    ([info exists data($key-elide)] ||
	     [info exists data($key-hide)])} {
	    continue
	}

	#
	# Adjust the cell text and the image or window width
	#
	set text [lindex $item $col]
	if {$fmtCmdFlag} {
	    set text [formatElem $win $key $row $col $text]
	}
	if {[string match "*\t*" $text]} {
	    set text [mapTabs $text]
	}
	set multiline [string match "*\n*" $text]
	set aux [getAuxData $win $key $col auxType auxWidth $pixels]
	set indent [getIndentData $win $key $col indentWidth]
	set maxTextWidth $pixels
	if {[info exists data($key,$col-font)]} {
	    set cellFont $data($key,$col-font)
	} elseif {[info exists data($key-font)]} {
	    set cellFont $data($key-font)
	} else {
	    set cellFont $colFont
	}
	if {$pixels != 0} {
	    set maxTextWidth [getMaxTextWidth $pixels $auxWidth $indentWidth]

	    if {$data($col-wrap) && !$multiline} {
		if {[font measure $cellFont -displayof $win $text] >
		    $maxTextWidth} {
		    set multiline 1
		}
	    }
	}
	if {$multiline} {
	    set list [split $text "\n"]
	    set snipSide2 $snipSide
	    if {$data($col-wrap)} {
		set snipSide2 ""
	    }
	    adjustMlElem $win list auxWidth indentWidth $cellFont \
			 $pixels $snipSide2 $snipStr
	    set msgScript [list ::tablelist::displayText $win $key $col \
			   [join $list "\n"] $cellFont $maxTextWidth $alignment]
	    set msgScript [string map {"%" "%%"} $msgScript]
	} else {
	    adjustElem $win text auxWidth indentWidth $cellFont \
		       $pixels $snipSide $snipStr
	}

	#
	# Update the text widget's content between the two tabs
	#
	if {[findTabs $win $w $line $col $col tabIdx1 tabIdx2]} {
	    if {$auxType > 1 && $auxWidth > 0 && ![winfo exists $aux]} {
		#
		# Create a frame and evaluate the script that
		# creates a child window within the frame
		#
		tk::frame $aux -borderwidth 0 -class TablelistWindow \
			       -container 0 -height $data($key,$col-reqHeight) \
			       -highlightthickness 0 -padx 0 -pady 0 \
			       -relief flat -takefocus 0 -width $auxWidth
		bindtags $aux [linsert [bindtags $aux] 1 \
			       $data(bodyTag) TablelistBody]
		uplevel #0 $data($key,$col-window) [list $win $row $col $aux.w]
		set reqHeight [winfo reqheight $aux.w]
		if {$reqHeight != 1 &&
		    $reqHeight != $data($key,$col-reqHeight)} {
		    set data($key,$col-reqHeight) $reqHeight
		    $aux configure -height $reqHeight
		}
	    }

	    if {$multiline} {
		updateMlCell $w $tabIdx1+1$pu $tabIdx2 $msgScript $aux \
			     $auxType $auxWidth $indent $indentWidth \
			     $alignment [getOpt $win $key $col -valign]
	    } else {
		updateCell $w $tabIdx1+1$pu $tabIdx2 $text $aux \
			   $auxType $auxWidth $indent $indentWidth \
			   $alignment [getOpt $win $key $col -valign]
	    }
	}
    }
}

#------------------------------------------------------------------------------
# tablelist::makeStripesWhenIdle
#
# Arranges for the stripes in the body of the tablelist widget win to be
# redrawn at idle time.
#------------------------------------------------------------------------------
proc tablelist::makeStripesWhenIdle win {
    upvar ::tablelist::ns${win}::data data
    if {[info exists data(stripesId)] || $data(itemCount) == 0} {
	return ""
    }

    set script [list tablelist::makeStripes $win]
    variable aquaCrash
    if {$aquaCrash} { set script [list after 0 $script] }
    set data(stripesId) [after idle $script]
}

#------------------------------------------------------------------------------
# tablelist::makeStripes
#
# Redraws the stripes in the body of the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::makeStripes win {
    upvar ::tablelist::ns${win}::data data
    if {[info exists data(stripesId)]} {
	after cancel $data(stripesId)
	unset data(stripesId)
    }

    if {[info exists data(dispId)]} {
	return ""
    }

    set w $data(body)
    $w tag remove stripe 1.0 end
    if {$data(-stripebackground) ne "" || $data(-stripeforeground) ne ""} {
	set count 0
	set inStripe 0
	set itemCount $data(itemCount)
	for {set row 0; set line 1} {$row < $itemCount} \
	    {set row $line; incr line} {
	    set key [lindex $data(keyList) $row]
	    if {![info exists data($key-elide)] &&
		![info exists data($key-hide)]} {
		if {$inStripe} {
		    $w tag add stripe $line.0 $line.end
		}

		if {[incr count] == $data(-stripeheight)} {
		    set count 0
		    set inStripe [expr {!$inStripe}]
		}
	    }
	}
    }

    updateColors $win
}

#------------------------------------------------------------------------------
# tablelist::showLineNumbersWhenIdle
#
# Arranges for the line numbers in the tablelist widget win to be redisplayed
# at idle time.
#------------------------------------------------------------------------------
proc tablelist::showLineNumbersWhenIdle win {
    upvar ::tablelist::ns${win}::data data
    if {[info exists data(lineNumsId)] || $data(itemCount) == 0} {
	return ""
    }

    set script [list tablelist::showLineNumbers $win]
    variable aquaCrash
    if {$aquaCrash} { set script [list after 0 $script] }
    set data(lineNumsId) [after idle $script]
}

#------------------------------------------------------------------------------
# tablelist::showLineNumbers
#
# Redisplays the line numbers (if any) in the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::showLineNumbers win {
    upvar ::tablelist::ns${win}::data data
    unset data(lineNumsId)

    #
    # Update the item list
    #
    set colIdxList {}
    for {set col 0} {$col < $data(colCount)} {incr col} {
	if {!$data($col-showlinenumbers)} {
	    continue
	}

	lappend colIdxList $col

	set newItemList {}
	set line 1
	foreach item $data(itemList) {
	    set item [lreplace $item $col $col $line]
	    lappend newItemList $item
	    set key [lindex $item end]
	    if {![info exists data($key-hide)]} {
		incr line
	    }
	}
	set data(itemList) $newItemList

	redisplayColWhenIdle $win $col
    }

    if {[llength $colIdxList] == 0} {
	return ""
    }

    #
    # Update the list variable if present, and adjust the columns
    #
    condUpdateListVar $win
    adjustColumns $win $colIdxList 1
    return ""
}

#------------------------------------------------------------------------------
# tablelist::updateViewWhenIdle
#
# Arranges for the visible part of the body text widget of the tablelist widget
# win to be updated at idle time.
#------------------------------------------------------------------------------
proc tablelist::updateViewWhenIdle {win {reschedule 0}} {
    upvar ::tablelist::ns${win}::data data
    if {[info exists data(viewId)]} {
	if {$reschedule} {
	    after cancel $data(viewId)
	} else {
	    return ""
	}
    }

    set script [list tablelist::updateView $win]
    variable aquaCrash
    if {$aquaCrash} { set script [list after 0 $script] }
    set data(viewId) [after idle $script]
}

#------------------------------------------------------------------------------
# tablelist::updateView
#
# Updates the visible part of the body text widget of the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::updateView {win {row -1}} {
    upvar ::tablelist::ns${win}::data data
    if {[info exists data(viewId)]} {
	after cancel $data(viewId)
	unset data(viewId)

	hdr_adjustElidedText $win
	hdr_updateColors $win
	adjustHeaderHeight $win
    }

    adjustElidedText $win
    redisplayVisibleItems $win
    if {$::tk_version >= 8.5 && $row >= 0} {
	$data(body) yview $row
    }
    updateColors $win
    adjustSeps $win
    updateVScrlbar $win
}

#------------------------------------------------------------------------------
# tablelist::purgeWidgets
#
# Destroys those label widgets containing embedded images and those message
# widgets containing multiline elements that are outside the currently visible
# range of lines of the body of the tablelist widget win or are contained in
# hidden rows or columns, or in descendants of collapsed nodes.
#------------------------------------------------------------------------------
proc tablelist::purgeWidgets win {
    if {[destroyed $win]} {
	return ""
    }

    upvar ::tablelist::ns${win}::data data
    if {$data(topRowChanged)} {
	set data(topRowChanged) 0
    } elseif {$data(winSizeChanged)} {
	set data(winSizeChanged) 0
    } else {
	set w $data(body)
	set fromTextIdx "[$w index @0,0] linestart"
	set toTextIdx "[$w index @0,$data(btmY)] lineend"

	set winList {}
	set count 0
	foreach {dummy path textIdx} [$w dump -window 1.0 end] {
	    if {$count == 50} {
		break
	    }

	    if {$path eq ""} {
		continue
	    }

	    set class [winfo class $path]
	    if {$class ne "Label" && $class ne "Message"} {
		continue
	    }

	    if {[$w compare $textIdx < $fromTextIdx] ||
		[$w compare $textIdx > $toTextIdx]} {
		$w tag add elidedWin $textIdx
		lappend winList $path
		incr count
	    } else {
		set tagNames [$w tag names $textIdx]
		if {[lsearch -glob $tagNames hidden*] >= 0 ||
		    [lsearch -glob $tagNames elided*] >= 0} {
		    lappend winList $path
		    incr count
		}
	    }
	}
	eval destroy $winList
    }

    after 1000 [list tablelist::purgeWidgets $win]
}

#------------------------------------------------------------------------------
# tablelist::synchronize
#
# This procedure is invoked either as an idle callback after the list variable
# associated with the tablelist widget win was written, or directly, upon
# execution of some widget commands.  It makes sure that the content of the
# widget is synchronized with the value of the list variable.
#------------------------------------------------------------------------------
proc tablelist::synchronize win {
    #
    # Nothing to do if the list variable was not written
    #
    upvar ::tablelist::ns${win}::data data
    if {![info exists data(syncId)]} {
	return ""
    }

    #
    # Here we are in the case that the procedure was scheduled for
    # execution at idle time.  However, it might have been invoked
    # directly, before the idle time occured; in this case we should
    # cancel the execution of the previously scheduled idle callback.
    #
    after cancel $data(syncId)	;# no harm if data(syncId) is no longer valid
    unset data(syncId)

    upvar #0 $data(-listvariable) var
    if {[catch {foreach item $var {llength $item}} err] != 0} {
	condUpdateListVar $win
	return -code error "value of variable \"$data(-listvariable)\" is not\
			    a list of lists ($err)"
    }

    set newCount [llength $var]
    if {$newCount < $data(itemCount)} {
	#
	# Delete the items with indices >= newCount from the widget
	#
	set updateCount $newCount
	deleteRows $win $newCount $data(lastRow) 0
    } elseif {$newCount > $data(itemCount)} {
	#
	# Insert the items of var with indices
	# >= data(itemCount) into the widget
	#
	set updateCount $data(itemCount)
	insertRows $win $data(itemCount) [lrange $var $data(itemCount) end] 0 \
		   root $data(itemCount)
    } else {
	set updateCount $newCount
    }

    #
    # Update the first updateCount items of the internal list
    #
    set itemsChanged 0
    for {set row 0} {$row < $updateCount} {incr row} {
	set oldItem [lindex $data(itemList) $row]
	set newItem [adjustItem [lindex $var $row] $data(colCount)]
	lappend newItem [lindex $oldItem end]

	if {$oldItem ne $newItem} {
	    set data(itemList) [lreplace $data(itemList) $row $row $newItem]
	    set itemsChanged 1
	}
    }

    #
    # If necessary, adjust the columns and make sure
    # that the items will be redisplayed at idle time
    #
    if {$itemsChanged} {
	adjustColumns $win allCols 1
	redisplayWhenIdle $win
	showLineNumbersWhenIdle $win
	updateViewWhenIdle $win
    }
}

#------------------------------------------------------------------------------
# tablelist::getSublabels
#
# Returns the list of the existing sublabels $w-il and $w-tl associated with
# the label widget w.
#------------------------------------------------------------------------------
proc tablelist::getSublabels w {
    set lst {}
    foreach lbl [list $w-il $w-tl] {
	if {[winfo exists $lbl]} {
	    lappend lst $lbl
	}
    }

    return $lst
}

#------------------------------------------------------------------------------
# tablelist::parseLabelPath
#
# Extracts the path name of the tablelist widget as well as the column number
# from the path name w of a header label.
#------------------------------------------------------------------------------
proc tablelist::parseLabelPath {w winName colName} {
    if {![winfo exists $w]} {
	return 0
    }

    upvar $winName win $colName col
    return [regexp {^(\..+)\.hdr\.t\.f\.l([0-9]+)$} $w dummy win col]
}

#------------------------------------------------------------------------------
# tablelist::configLabel
#
# This procedure configures the label widget w according to the options and
# their values given in args.  It is needed for label widgets with sublabels.
#------------------------------------------------------------------------------
proc tablelist::configLabel {w args} {
    foreach {opt val} $args {
	switch -- $opt {
	    -active {
		if {[winfo class $w] eq "TLabel"} {
		    $w instate !selected {
			set state [expr {$val ? "active" : "!active"}]
			$w state $state
			variable themeDefaults
			if {$val} {
			    set bg $themeDefaults(-labelactiveBg)
			} else {
			    set bg $themeDefaults(-labelbackground)
			}
			foreach l [getSublabels $w] {
			    if {[winfo class $l] eq "Label"} {
				$l configure -background $bg
			    }
			}
		    }
		} else {
		    set state [expr {$val ? "active" : "normal"}]
		    catch {
			$w configure -state $state
			foreach l [getSublabels $w] {
			    if {[winfo class $l] eq "Label"} {
				$l configure -state $state
			    }
			}
		    }
		}

		parseLabelPath $w win col
		upvar ::tablelist::ns${win}::data data
		if {[lsearch -exact $data(arrowColList) $col] >= 0} {
		    configCanvas $win $col
		}
	    }

	    -activebackground -
	    -activeforeground -
	    -disabledforeground -
	    -cursor {
		$w configure $opt $val
		foreach l [getSublabels $w] {
		    if {[winfo class $l] eq "Label"} {
			$l configure $opt $val
		    }
		}
	    }

	    -background -
	    -font {
		if {[winfo class $w] eq "TLabel" && $val eq ""} {
		    variable themeDefaults
		    set val $themeDefaults(-label[string range $opt 1 end])
		}
		$w configure $opt $val
		foreach l [getSublabels $w] {
		    if {[winfo class $l] eq "Label"} {
			$l configure $opt $val
		    }
		}
	    }

	    -foreground {
		if {[winfo class $w] eq "TLabel"} {
		    variable themeDefaults
		    if {[winfo rgb $w $val] eq
			[winfo rgb $w $themeDefaults(-labelforeground)]} {
			set val ""    ;# for automatic adaptation to the states
		    }
		    $w instate !disabled {
			$w configure $opt $val
		    }
		} else {
		    $w configure $opt $val
		    foreach l [getSublabels $w] {
			if {[winfo class $l] eq "Label"} {
			    $l configure $opt $val
			}
		    }
		}
	    }

	    -padx {
		if {[winfo class $w] eq "TLabel"} {
		    set val [winfo pixels $w $val]
		    set padding [$w cget -padding]
		    lset padding 0 $val
		    lset padding 2 $val
		    $w configure -padding $padding
		} else {
		    $w configure $opt $val
		}
	    }

	    -pady {
		if {[winfo class $w] eq "TLabel"} {
		    set val [winfo pixels $w $val]
		    set padding [$w cget -padding]
		    lset padding 1 $val
		    lset padding 3 $val
		    $w configure -padding $padding
		} else {
		    $w configure $opt $val
		}
	    }

	    -pressed {
		if {[winfo class $w] eq "TLabel"} {
		    set state [expr {$val ? "pressed" : "!pressed"}]
		    $w state $state
		    variable themeDefaults
		    if {$val} {
			if {[$w instate selected]} {
			    set bg $themeDefaults(-labelselectedpressedBg)
			} else {
			    set bg $themeDefaults(-labelpressedBg)
			}
		    } else {
			if {[$w instate selected]} {
			    set bg $themeDefaults(-labelselectedBg)
			} elseif {[$w instate active]} {
			    set bg $themeDefaults(-labelactiveBg)
			} else {
			    set bg $themeDefaults(-labelbackground)
			}
		    }
		    foreach l [getSublabels $w] {
			if {[winfo class $l] eq "Label"} {
			    $l configure -background $bg
			}
		    }

		    parseLabelPath $w win col
		    upvar ::tablelist::ns${win}::data data
		    if {[lsearch -exact $data(arrowColList) $col] >= 0} {
			configCanvas $win $col
		    }
		}
	    }

	    -selected {
		if {[winfo class $w] eq "TLabel"} {
		    set state [expr {$val ? "selected" : "!selected"}]
		    $w state $state
		    variable themeDefaults
		    if {$val} {
			if {[$w instate pressed]} {
			    set bg $themeDefaults(-labelselectedpressedBg)
			} else {
			    set bg $themeDefaults(-labelselectedBg)
			}
		    } else {
			if {[$w instate pressed]} {
			    set bg $themeDefaults(-labelpressedBg)
			} else {
			    set bg $themeDefaults(-labelbackground)
			}
		    }
		    foreach l [getSublabels $w] {
			if {[winfo class $l] eq "Label"} {
			    $l configure -background $bg
			}
		    }

		    parseLabelPath $w win col
		    upvar ::tablelist::ns${win}::data data
		    if {[lsearch -exact $data(arrowColList) $col] >= 0} {
			configCanvas $win $col
		    }
		}
	    }

	    -state {
		$w configure $opt $val
		if {[winfo class $w] eq "TLabel"} {
		    variable themeDefaults
		    if {$val eq "disabled"} {
			#
			# Set the label's foreground color to the theme-
			# specific one (needed for current tile versions)
			#
			$w configure -foreground ""

			set bg $themeDefaults(-labeldisabledBg)
			if {$bg eq ""} {
			    set bg [expr {[$w instate background] ?
				    $themeDefaults(-labeldeactivatedBg) :
				    $themeDefaults(-labelbackground)}]
			}
		    } else {
			#
			# Restore the label's foreground color
			# (needed for current tile versions)
			#
			if {[parseLabelPath $w win col]} {
			    upvar ::tablelist::ns${win}::data data
			    if {[info exists data($col-labelforeground)]} {
				set fg $data($col-labelforeground)
			    } else {
				set fg $data(-labelforeground)
			    }
			    configLabel $w -foreground $fg
			}

			set bg [expr {[$w instate background] ?
				$themeDefaults(-labeldeactivatedBg) :
				$themeDefaults(-labelbackground)}]
		    }
		    foreach l [getSublabels $w] {
			if {[winfo class $l] eq "Label"} {
			    $l configure -background $bg
			}
		    }
		} else {
		    foreach l [getSublabels $w] {
			if {[winfo class $l] eq "Label"} {
			    $l configure $opt $val
			}
		    }
		}
	    }

	    default {
		if {$val ne [$w cget $opt]} {
		    $w configure $opt $val
		}
	    }
	}
    }
}

#------------------------------------------------------------------------------
# tablelist::createArrows
#
# Creates two arrows in the canvas w.
#------------------------------------------------------------------------------
proc tablelist::createArrows {w width height relief} {
    set pct $::scaleutil::scalingPct
    set wWidth  [expr {$width  > 0 ? $width  : int(8 * $pct / 100.0)}]
    set wHeight [expr {$height > 0 ? $height : int(4 * $pct / 100.0)}]

    variable centerArrows
    if {$pct > 150} {
	set minHeight [expr {$centerArrows ? 8 : 10}]
    } else {
	set minHeight 6
    }
    if {$wHeight < $minHeight} {
	set wHeight $minHeight
	set y [expr {$centerArrows ? 0 : 1}]
    } else {
	set y 0
    }

    $w configure -width $wWidth -height $wHeight

    #
    # Delete any existing arrow image items from
    # the canvas and the corresponding images
    #
    set imgNames [image names]
    foreach shape {triangleUp darkLineUp lightLineUp
		   triangleDn darkLineDn lightLineDn} {
	$w delete $shape
	if {[lsearch -exact $imgNames ${shape}Img$w] >= 0} {
	    image delete ${shape}Img$w
	}
    }

    #
    # Create the arrow images and canvas image items
    # corresponding to the procedure's arguments
    #
    $relief${width}x${height}Arrows $w
    set imgNames [image names]
    foreach shape {triangleUp darkLineUp lightLineUp
		   triangleDn darkLineDn lightLineDn} {
	if {[lsearch -exact $imgNames ${shape}Img$w] >= 0} {
	    $w create image 0 $y -anchor nw -image ${shape}Img$w -tags $shape
	}
    }

    #
    # Create the sort rank image item
    #
    $w delete sortRank
    set x [expr {$wWidth + 2}]
    if {!$centerArrows} {
	set y [expr {$wHeight - $minHeight}]
    }
    $w create image $x $y -anchor nw -tags sortRank
}

#------------------------------------------------------------------------------
# tablelist::configCanvas
#
# Sets the background color of the canvas displaying an up- or down-arrow for
# the given column, and fills the two arrows contained in the canvas.
#------------------------------------------------------------------------------
proc tablelist::configCanvas {win col} {
    upvar ::tablelist::ns${win}::data data
    set w $data(hdrTxtFrmLbl)$col

    if {[winfo class $w] eq "TLabel"} {
	variable themeDefaults
	set labelBg $themeDefaults(-labelbackground)
	set fg [$w cget -foreground]
	set labelFg $fg
	if {$fg eq ""} {
	    set labelFg $themeDefaults(-labelforeground)
	}

	if {[$w instate disabled]} {
	    set labelBg $themeDefaults(-labeldisabledBg)
	    if {$labelBg eq ""} {
		set labelBg [expr {[$w instate background] ?
			     $themeDefaults(-labeldeactivatedBg) :
			     $themeDefaults(-labelbackground)}]
	    }
	    set labelFg $themeDefaults(-labeldisabledFg)
	} elseif {[$win instate background]} {
	    set labelBg $themeDefaults(-labeldeactivatedBg)
	} else {
	    foreach state {active pressed selected} {
		$w instate $state {
		    set labelBg $themeDefaults(-label${state}Bg)
		    if {$fg eq ""} {
			set labelFg $themeDefaults(-label${state}Fg)
		    }
		}
	    }
	    $w instate {selected pressed} {
		set labelBg $themeDefaults(-labelselectedpressedBg)
		if {$fg eq ""} {
		    set labelFg $themeDefaults(-labelselectedpressedFg)
		}
	    }
	}
    } else {
	set labelBg [$w cget -background]
	set labelFg [$w cget -foreground]

	catch {
	    set state [$w cget -state]
	    if {$state eq "disabled"} {
		set labelFg [$w cget -disabledforeground]
	    } elseif {$state eq "active"} {
		variable winSys
		if {$winSys ne "aqua"} {
		    set labelBg [$w cget -activebackground]
		    set labelFg [$w cget -activeforeground]
		}
	    }
	}
    }

    set canvas $data(hdrTxtFrmCanv)$col
    $canvas configure -background $labelBg
    sortRank$data($col-sortRank)Img$win configure -foreground $labelFg

    if {$data(isDisabled)} {
	fillArrows $canvas $data(-arrowdisabledcolor) $data(-arrowstyle)
    } else {
	fillArrows $canvas $data(-arrowcolor) $data(-arrowstyle)
    }
}

#------------------------------------------------------------------------------
# tablelist::fillArrows
#
# Fills the two arrows contained in the canvas w with the given color, or with
# the background color of the canvas if color is an empty string.  Also fills
# the arrow's borders (if any) with the corresponding 3-D shadow colors.
#------------------------------------------------------------------------------
proc tablelist::fillArrows {w color arrowStyle} {
    set bgColor [$w cget -background]
    if {$color eq ""} {
	set color $bgColor
    }

    getShadows $w $color darkColor lightColor

    foreach dir {Up Dn} {
	if {[image type triangle${dir}Img$w] eq "bitmap"} {
	    triangle${dir}Img$w configure \
		-foreground $color -background $bgColor
	} elseif {[string match "photo*0x0" $arrowStyle]} {
	    setSvgImgForeground triangle${dir}Img$w $color
	}

	if {[string match "sunken*" $arrowStyle]} {
	    darkLine${dir}Img$w  configure -foreground $darkColor
	    lightLine${dir}Img$w configure -foreground $lightColor
	}
    }
}

#------------------------------------------------------------------------------
# tablelist::getShadows
#
# Computes the shadow colors for a 3-D border from a given (background) color.
# This is the Tcl-counterpart of the function TkpGetShadows() in the Tk
# distribution file unix/tkUnix3d.c.
#------------------------------------------------------------------------------
proc tablelist::getShadows {w color darkColorName lightColorName} {
    upvar $darkColorName darkColor $lightColorName lightColor

    set rgb [winfo rgb $w $color]
    foreach {r g b} $rgb {}
    set maxIntens [lindex [winfo rgb $w white] 0]

    #
    # Compute the dark shadow color
    #
    if {$r*0.5*$r + $g*1.0*$g + $b*0.28*$b < $maxIntens*0.05*$maxIntens} {
	#
	# The background is already very dark: make the dark
	# color a little lighter than the background by increasing
	# each color component 1/4th of the way to $maxIntens
	#
	foreach comp $rgb {
	    lappend darkRGB [expr {($maxIntens + 3*$comp)/4}]
	}
    } else {
	#
	# Compute the dark color by cutting 40% from
	# each of the background color components.
	#
	foreach comp $rgb {
	    lappend darkRGB [expr {60*$comp/100}]
	}
    }
    set darkColor [eval format "#%04x%04x%04x" $darkRGB]

    #
    # Compute the light shadow color
    #
    if {$g > $maxIntens*0.95} {
	#
	# The background is already very bright: make the
	# light color a little darker than the background
	# by reducing each color component by 10%
	#
	foreach comp $rgb {
	    lappend lightRGB [expr {90*$comp/100}]
	}
    } else {
	#
	# Compute the light color by boosting each background
	# color component by 40% or half-way to white, whichever
	# is greater (the first approach works better for
	# unsaturated colors, the second for saturated ones)
	#
	foreach comp $rgb {
	    set comp1 [expr {140*$comp/100}]
	    if {$comp1 > $maxIntens} {
		set comp1 $maxIntens
	    }
	    set comp2 [expr {($maxIntens + $comp)/2}]
	    lappend lightRGB [expr {($comp1 > $comp2) ? $comp1 : $comp2}]
	}
    }
    set lightColor [eval format "#%04x%04x%04x" $lightRGB]
}

#------------------------------------------------------------------------------
# tablelist::raiseArrow
#
# Raises one of the two arrows contained in the canvas associated with the
# given column of the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::raiseArrow {win col} {
    upvar ::tablelist::ns${win}::data data
    set w $data(hdrTxtFrmCanv)$col
    variable directions
    set dir $directions($data(-incrarrowtype),$data($col-sortOrder))

    if {[string match "photo*" $data(-arrowstyle)]} {
	$w itemconfigure triangle$dir -state normal
	set dir [expr {($dir eq "Up") ? "Dn" : "Up"}]
	$w itemconfigure triangle$dir -state hidden
    } else {
	$w raise triangle$dir
	$w raise darkLine$dir
	$w raise lightLine$dir
    }
}

#------------------------------------------------------------------------------
# tablelist::isHdrTxtFrXPosVisible
#
# Checks whether the given x position in the header text widget component of
# the tablelist widget win is visible.
#------------------------------------------------------------------------------
proc tablelist::isHdrTxtFrXPosVisible {win x} {
    upvar ::tablelist::ns${win}::data data
    foreach {fraction1 fraction2} [$data(hdrTxt) xview] {}
    return [expr {$x >= $fraction1 * $data(hdrWidth) &&
		  $x <  $fraction2 * $data(hdrWidth)}]
}

#------------------------------------------------------------------------------
# tablelist::getScrlContentWidth
#
# Returns the total width of the non-hidden scrollable columns of the tablelist
# widget win, in the specified range.
#------------------------------------------------------------------------------
proc tablelist::getScrlContentWidth {win scrlColOffset lastCol} {
    upvar ::tablelist::ns${win}::data data
    set scrlContentWidth 0
    set nonHiddenCount 0
    for {set col $data(-titlecolumns)} {$col <= $lastCol} {incr col} {
	if {!$data($col-hide) && [incr nonHiddenCount] > $scrlColOffset} {
	    incr scrlContentWidth [colWidth $win $col -total]
	}
    }

    return $scrlContentWidth
}

#------------------------------------------------------------------------------
# tablelist::getTitleColsWidth
#
# Returns the total width of the non-hidden title columns of the tablelist
# widget win.
#------------------------------------------------------------------------------
proc tablelist::getTitleColsWidth win {
    upvar ::tablelist::ns${win}::data data
    set titleColsWidth 0
    for {set col 0} {$col < $data(-titlecolumns) && $col < $data(colCount)} \
	{incr col} {
	if {!$data($col-hide)} {
	    incr titleColsWidth [colWidth $win $col -total]
	}
    }

    return $titleColsWidth
}

#------------------------------------------------------------------------------
# tablelist::getScrlWindowWidth
#
# Returns the number of pixels obtained by subtracting the total width of the
# non-hidden title columns from the width of the header frame of the tablelist
# widget win.
#------------------------------------------------------------------------------
proc tablelist::getScrlWindowWidth win {
    upvar ::tablelist::ns${win}::data data
    set scrlWindowWidth [winfo width $data(hdr)]
    incr scrlWindowWidth -[getTitleColsWidth $win]

    return $scrlWindowWidth
}

#------------------------------------------------------------------------------
# tablelist::getMaxScrlColOffset
#
# Returns the max. scrolled column offset of the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::getMaxScrlColOffset win {
    #
    # Get the number of non-hidden scrollable columns
    #
    upvar ::tablelist::ns${win}::data data
    set maxScrlColOffset 0
    for {set col $data(-titlecolumns)} {$col < $data(colCount)} {incr col} {
	if {!$data($col-hide)} {
	    incr maxScrlColOffset
	}
    }

    #
    # Decrement maxScrlColOffset while the total width of the
    # non-hidden scrollable columns starting with this offset
    # is less than the width of the window's scrollable part
    #
    set scrlWindowWidth [getScrlWindowWidth $win]
    if {$scrlWindowWidth > 0} {
	while {$maxScrlColOffset > 0} {
	    incr maxScrlColOffset -1
	    set scrlContentWidth \
		[getScrlContentWidth $win $maxScrlColOffset $data(lastCol)]
	    if {$scrlContentWidth == $scrlWindowWidth} {
		break
	    } elseif {$scrlContentWidth > $scrlWindowWidth} {
		incr maxScrlColOffset
		break
	    }
	}
    }

    return $maxScrlColOffset
}

#------------------------------------------------------------------------------
# tablelist::changeScrlColOffset
#
# Changes the scrolled column offset of the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::changeScrlColOffset {win scrlColOffset} {
    #
    # Make sure the offset is non-negative and no
    # greater than the max. scrolled column offset
    #
    if {$scrlColOffset < 0} {
	set scrlColOffset 0
    } else {
	set maxScrlColOffset [getMaxScrlColOffset $win]
	if {$scrlColOffset > $maxScrlColOffset} {
	    set scrlColOffset $maxScrlColOffset
	}
    }

    #
    # Update data(scrlColOffset) and adjust the
    # elided text in the tablelist's body if necessary
    #
    upvar ::tablelist::ns${win}::data data
    if {$scrlColOffset != $data(scrlColOffset)} {
	set data(scrlColOffset) $scrlColOffset
	hdr_adjustElidedText $win
	adjustElidedText $win
	redisplayVisibleItems $win
    }
}

#------------------------------------------------------------------------------
# tablelist::scrlXOffsetToColOffset
#
# Returns the scrolled column offset of the tablelist widget win, corresponding
# to the desired x offset.
#------------------------------------------------------------------------------
proc tablelist::scrlXOffsetToColOffset {win scrlXOffset} {
    upvar ::tablelist::ns${win}::data data
    set scrlColOffset 0
    set scrlContentWidth 0
    for {set col $data(-titlecolumns)} {$col < $data(colCount)} {incr col} {
	if {$data($col-hide)} {
	    continue
	}

	incr scrlContentWidth [colWidth $win $col -total]
	if {$scrlContentWidth > $scrlXOffset} {
	    break
	} else {
	    incr scrlColOffset
	}
    }

    return $scrlColOffset
}

#------------------------------------------------------------------------------
# tablelist::scrlColOffsetToXOffset
#
# Returns the x offset corresponding to the specified scrolled column offset of
# the tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::scrlColOffsetToXOffset {win scrlColOffset} {
    upvar ::tablelist::ns${win}::data data
    set scrlXOffset 0
    set nonHiddenCount 0
    for {set col $data(-titlecolumns)} {$col < $data(colCount)} {incr col} {
	if {$data($col-hide)} {
	    continue
	}

	if {[incr nonHiddenCount] > $scrlColOffset} {
	    break
	} else {
	    incr scrlXOffset [colWidth $win $col -total]
	}
    }

    return $scrlXOffset
}

#------------------------------------------------------------------------------
# tablelist::getVertComplTopRow
#
# Returns the row number of the topmost vertically complete item visible in the
# tablelist window win.
#------------------------------------------------------------------------------
proc tablelist::getVertComplTopRow win {
    upvar ::tablelist::ns${win}::data data
    set w $data(body)

    set topTextIdx [$w index @0,0]
    set topRow [expr {int($topTextIdx) - 1}]

    foreach {x y width height baselinePos} [$w dlineinfo $topTextIdx] {}
    if {$y < 0} {		;# top row incomplete in vertical direction
	set topTextIdx [$w index @0,[incr y $height]]
	set topRow [expr {int($topTextIdx) - 1}]
    }

    return $topRow
}

#------------------------------------------------------------------------------
# tablelist::getVertComplBtmRow
#
# Returns the row number of the bottommost vertically complete item visible in
# the tablelist window win.
#------------------------------------------------------------------------------
proc tablelist::getVertComplBtmRow win {
    upvar ::tablelist::ns${win}::data data
    set w $data(body)

    set btmTextIdx [$w index @0,$data(btmY)]
    set btmRow [expr {int($btmTextIdx) - 1}]
    if {$btmRow > $data(lastRow)} {
	set btmRow $data(lastRow)
    }

    foreach {x y width height baselinePos} [$w dlineinfo $btmTextIdx] {}
    set y2 [expr {$y + $height}]
    set text [$w get @0,$y @[expr {$data(rightX) + 1}],$y]
    if {[$w compare [$w index @0,$y] == [$w index @0,$y2]] &&
	$text ne ""} {			;# btm row incomplete in vertical dir.
	set btmTextIdx [$w index @0,[incr y -1]]
	set btmRow [expr {int($btmTextIdx) - 1}]
    }

    return $btmRow
}

#------------------------------------------------------------------------------
# tablelist::getViewableRowCount
#
# Returns the number of viewable rows of the tablelist widget win in the
# specified range.
#------------------------------------------------------------------------------
proc tablelist::getViewableRowCount {win first last} {
    upvar ::tablelist::ns${win}::data data
    if {$data(nonViewableRowCount) == 0} {
	#
	# Speed optimization
	#
	set count [expr {$last - $first + 1}]
	return [expr {$count >= 0 ? $count : 0}]
    } elseif {$first == 0 && $last == $data(lastRow)} {
	#
	# Speed optimization
	#
	return [expr {$data(itemCount) - $data(nonViewableRowCount)}]
    } else {
	set count 0
	for {set row $first} {$row <= $last} {incr row} {
	    set key [lindex $data(keyList) $row]
	    if {![info exists data($key-elide)] &&
		![info exists data($key-hide)]} {
		incr count
	    }
	}
	return $count
    }
}

#------------------------------------------------------------------------------
# tablelist::viewableRowOffsetToRowIndex
#
# Returns the row index corresponding to the given viewable row offset in the
# tablelist widget win.
#------------------------------------------------------------------------------
proc tablelist::viewableRowOffsetToRowIndex {win offset} {
    upvar ::tablelist::ns${win}::data data
    if {$data(nonViewableRowCount) == 0} {
	return $offset
    } else {
	#
	# Rebuild the list data(viewableRowList) of the row
	# indices indicating the viewable rows if needed
	#
	if {[lindex $data(viewableRowList) 0] == -1} {
	    set data(viewableRowList) {}
	    set itemCount $data(itemCount)
	    for {set row 0} {$row < $itemCount} {incr row} {
		set key [lindex $data(keyList) $row]
		if {![info exists data($key-elide)] &&
		    ![info exists data($key-hide)]} {
		    lappend data(viewableRowList) $row
		}
	    }
	}

	if {$offset >= [llength $data(viewableRowList)]} {
	    return $data(itemCount)			;# this is out of range
	} elseif {$offset < 0} {
	    return 0
	} else {
	    return [lindex $data(viewableRowList) $offset]
	}
    }
}

#------------------------------------------------------------------------------
# tablelist::createCkbtn
#
# Creates a frame widget w to be embedded into the specified cell of the
# tablelist widget win, along with a checkbutton child.
#------------------------------------------------------------------------------
proc tablelist::createCkbtn {cmd win row col w} {
    upvar ::tablelist::ns${win}::data data \
	  ::tablelist::ns${win}::checkStates checkStates
    set item [lindex $data(itemList) $row]
    set key [lindex $item end]
    set checkStates($key,$col) [lindex $item $col]

    tk::frame $w -borderwidth 0 -container 0 -highlightthickness 0 \
		 -padx 0 -pady 0 -relief flat -takefocus 0
    makeCkbtn $w.ckbtn
    $w.ckbtn configure -variable ::tablelist::ns${win}::checkStates($key,$col)

    if {$cmd ne ""} {
	##nagelfar ignore
	$w.ckbtn configure -command [format {
	    after idle [list %s %s [%s index %s] %d]
	} $cmd $win $win $key $col]
    }
}

#------------------------------------------------------------------------------
# tablelist::hdr_createCkbtn
#
# Creates a frame widget w to be embedded into the specified header cell of the
# tablelist widget win, along with a checkbutton child.
#------------------------------------------------------------------------------
proc tablelist::hdr_createCkbtn {cmd win row col w} {
    upvar ::tablelist::ns${win}::data data \
	  ::tablelist::ns${win}::checkStates checkStates
    set item [lindex $data(hdr_itemList) $row]
    set key [lindex $item end]
    set checkStates($key,$col) [lindex $item $col]

    tk::frame $w -borderwidth 0 -container 0 -highlightthickness 0 \
		 -padx 0 -pady 0 -relief flat -takefocus 0
    makeCkbtn $w.ckbtn
    $w.ckbtn configure -variable ::tablelist::ns${win}::checkStates($key,$col)

    if {$cmd ne ""} {
	##nagelfar ignore
	$w.ckbtn configure -command [format {
	    after idle [list %s %s [%s header index %s] %d]
	} $cmd $win $win $key $col]
    }
}

#------------------------------------------------------------------------------
# tablelist::makeCkbtn
#
# Creates a checkbutton widget of the given path name and manages it in its
# parent, which is supposed to be a frame widget.
#------------------------------------------------------------------------------
proc tablelist::makeCkbtn w {
    checkbutton $w -highlightthickness 0 -padx 0 -pady 0 -takefocus 0

    set frm [winfo parent $w]
    variable winSys
    switch $winSys {
	x11 {
	    variable checkedImg
	    variable uncheckedImg
	    if {![info exists checkedImg]} {
		createCheckbuttonImgs
	    }

	    $w configure -borderwidth 0 -indicatoron 0 -image $uncheckedImg \
		-offrelief sunken -selectimage $checkedImg
	    if {$::tk_version >= 8.5} {
		variable tristateImg
		$w configure -tristateimage $tristateImg
	    }
	    pack $w
	    return [list [winfo reqwidth $w] [winfo reqheight $w]]
	}

	win32 {
	    variable checkedImg
	    variable uncheckedImg
	    if {![info exists checkedImg]} {
		createCheckbuttonImgs
	    }

	    $w configure -borderwidth 0 -indicatoron 0 -image $uncheckedImg \
		-offrelief sunken -selectimage $checkedImg
	    if {$::tk_version >= 8.5} {
		variable tristateImg
		$w configure -tristateimage $tristateImg
	    }
	    pack $w
	    return [list [winfo reqwidth $w] [winfo reqheight $w]]
	}

	aqua {
	    $w configure -borderwidth 0 -font "system"
	    $frm configure -width 12 -height 12
	    variable newAquaSupport
	    if {$newAquaSupport} {
		place $w -x -1 -y -2
	    } else {
		place $w -x -1 -y -3
	    }
	    return {12 12}
	}
    }
}

#------------------------------------------------------------------------------
# tablelist::createTtkCkbtn
#
# Creates a frame widget w to be embedded into the specified cell of the
# tablelist widget win, along with a ttk::checkbutton child.
#------------------------------------------------------------------------------
proc tablelist::createTtkCkbtn {cmd win row col w} {
    upvar ::tablelist::ns${win}::data data \
	  ::tablelist::ns${win}::checkStates checkStates
    set item [lindex $data(itemList) $row]
    set key [lindex $item end]
    set checkStates($key,$col) [lindex $item $col]

    tk::frame $w -borderwidth 0 -container 0 -highlightthickness 0 \
		 -padx 0 -pady 0 -relief flat -takefocus 0
    makeTtkCkbtn $w.ckbtn
    $w.ckbtn configure -variable ::tablelist::ns${win}::checkStates($key,$col)

    if {$cmd ne ""} {
	##nagelfar ignore
	$w.ckbtn configure -command [format {
	    after idle [list %s %s [%s index %s] %d]
	} $cmd $win $win $key $col]
    }
}

#------------------------------------------------------------------------------
# tablelist::hdr_createTtkCkbtn
#
# Creates a frame widget w to be embedded into the specified header cell of the
# tablelist widget win, along with a ttk::checkbutton child.
#------------------------------------------------------------------------------
proc tablelist::hdr_createTtkCkbtn {cmd win row col w} {
    upvar ::tablelist::ns${win}::data data \
	  ::tablelist::ns${win}::checkStates checkStates
    set item [lindex $data(hdr_itemList) $row]
    set key [lindex $item end]
    set checkStates($key,$col) [lindex $item $col]

    tk::frame $w -borderwidth 0 -container 0 -highlightthickness 0 \
		 -padx 0 -pady 0 -relief flat -takefocus 0
    makeTtkCkbtn $w.ckbtn
    $w.ckbtn configure -variable ::tablelist::ns${win}::checkStates($key,$col)

    if {$cmd ne ""} {
	##nagelfar ignore
	$w.ckbtn configure -command [format {
	    after idle [list %s %s [%s header index %s] %d]
	} $cmd $win $win $key $col]
    }
}

#------------------------------------------------------------------------------
# tablelist::makeTtkCkbtn
#
# Creates a ttk::checkbutton widget of the given path name and manages it in
# its parent, which is supposed to be a frame widget.
#------------------------------------------------------------------------------
proc tablelist::makeTtkCkbtn w {
    if {$::tk_version < 8.5 || [regexp {^8\.5a[1-5]$} $::tk_patchLevel]} {
	package require tile 0.6[-]
    }
    createTileAliases

    #
    # Define the layout Tablelist.TCheckbutton
    #
    set ckbtnLayout [style layout TCheckbutton]
    variable currentTheme
    switch -- $currentTheme {
	alt -
	default {
	    if {[string first "Checkbutton.indicator" $ckbtnLayout] >= 0} {
		style layout Tablelist.TCheckbutton { Checkbutton.indicator }
		styleConfig Tablelist.TCheckbutton -indicatormargin 0
	    } else {		;# see procedure themepatch::patch_default
		style layout Tablelist.TCheckbutton { Checkbutton.image_ind }
	    }
	}

	aqua {
	    catch {style layout Tablelist.TCheckbutton { Checkbutton.button }}
	}

	clam {
	    if {[string first "Checkbutton.indicator" $ckbtnLayout] >= 0} {
		style layout Tablelist.TCheckbutton { Checkbutton.indicator }
		set margin [expr {[info exists ::tk::scalingPct] ?
				  0 : {0 0 1 1}}]
		styleConfig Tablelist.TCheckbutton -indicatormargin $margin
	    } else {		;# see procedure themepatch::patch_clam
		style layout Tablelist.TCheckbutton { Checkbutton.image_ind }
	    }
	}

	vista -
	xpnative {
	    if {[string first "Checkbutton.indicator" $ckbtnLayout] >= 0} {
		style layout Tablelist.TCheckbutton { Checkbutton.indicator }
	    } else {		;# see procedure scaleutil::patchWinTheme
		style layout Tablelist.TCheckbutton { Checkbutton.vsapi_ind }
	    }
	}

	default {
	    style layout Tablelist.TCheckbutton { Checkbutton.indicator }
	    styleConfig Tablelist.TCheckbutton -indicatormargin 0
	}
    }

    ttk::checkbutton $w -style Tablelist.TCheckbutton -takefocus 0

    #
    # Adjust the dimensions of the ttk::checkbutton's parent and
    # manage the checkbutton, depending on the current theme
    #

    set isAwTheme \
	[llength [info commands ::ttk::theme::${currentTheme}::setTextColors]]
    set frm [winfo parent $w]
    if {$isAwTheme} {
	set height [winfo reqheight $w]
	incr height -1
	$frm configure -width $height -height $height
	place $w -x 0
	return [list $height $height]
    }

    switch -- $currentTheme {
	alt -
	blue -
	Breeze - breeze - breeze-dark -
	clam -
	default -
	sun-valley-light - sun-valley-dark -
	winxpblue {
	    set height [winfo reqheight $w]
	    $frm configure -width $height -height $height
	    place $w -x 0
	    return [list $height $height]
	}

	aqua {
	    variable extendedAquaSupport
	    if {$extendedAquaSupport} {
		$frm configure -width 14 -height 14
		place $w -x -2 -y -3
		return {14 14}
	    } else {
		$frm configure -width 16 -height 16
		variable newAquaSupport
		if {$newAquaSupport} {
		    if {[tk::unsupported::MacWindowStyle isdark .]} {
			place $w -x 0 -y -2
		    } else {
			place $w -x -1 -y -2
		    }
		} else {
		    place $w -x -3 -y -3
		}
		return {16 16}
	    }
	}

	Aquativo - aquativo -
	Arc - arc {
	    $frm configure -width 14 -height 14
	    place $w -x -1 -y -1
	    return {14 14}
	}

	droid {
	    switch $::ttk::theme::droid::dpi {
		120 {
		    set width 18; set height 19
		    place $w -x -4
		}
		160 {
		    set width 25; set height 25
		    place $w -x -5
		}
		240 {
		    set width 37; set height 38
		    place $w -x -8
		}
		320 {
		    set width 50; set height 50
		    place $w -x -10
		}
		400 {
		    set width 61; set height 62
		    place $w -x -13
		}
	    }
	    $frm configure -width $width -height $height
	    return [list $width $height]
	}

	clearlooks {
	    $frm configure -width 13 -height 13
	    place $w -x -2 -y -2
	    return {13 13}
	}

	keramik - keramik_alt {
	    $frm configure -width 16 -height 16
	    place $w -x -1 -y -1
	    return {16 16}
	}

	plastik {
	    $frm configure -width 15 -height 15
	    place $w -x -2 -y 1
	    return {15 15}
	}

	sriv - srivlg {
	    $frm configure -width 15 -height 17
	    place $w -x -1
	    return {15 17}
	}

	tileqt {
	    switch -- [string tolower [tileqt_currentThemeName]] {
		acqua {
		    $frm configure -width 17 -height 18
		    place $w -x -1 -y -2
		    return {17 18}
		}
		cde -
		cleanlooks -
		motif {
		    $frm configure -width 13 -height 13
		    if {[info exists ::env(KDE_SESSION_VERSION)] &&
			$::env(KDE_SESSION_VERSION) ne ""} {
			place $w -x -2
		    } else {
			place $w -x 0
		    }
		    return {13 13}
		}
		gtk+ {
		    $frm configure -width 15 -height 15
		    place $w -x -1 -y -1
		    return {15 15}
		}
		kde_xp {
		    $frm configure -width 13 -height 13
		    place $w -x 0
		    return {13 13}
		}
		keramik -
		thinkeramik {
		    $frm configure -width 16 -height 16
		    place $w -x 0
		    return {16 16}
		}
		oxygen {
		    $frm configure -width 17 -height 17
		    place $w -x -2 -y -1
		    return {17 17}
		}
		default {
		    set height [winfo reqheight $w]
		    $frm configure -width $height -height $height
		    place $w -x 0
		    return [list $height $height]
		}
	    }
	}

	vista -
	xpnative {
	    set height [winfo reqheight $w]
	    $frm configure -width $height -height $height
	    if {[string first "Checkbutton.indicator" $ckbtnLayout] >= 0} {
		place $w -x 0
	    } else {		;# see procedure scaleutil::patchWinTheme
		variable scalingpct
		place $w -x -[expr {2 * [scaleutil::scale 2 $scalingpct]}]
	    }
	    return [list $height $height]
	}

	winnative {
	    set height [winfo reqheight $w]
	    $frm configure -width $height -height $height
	    if {[info exists ::tile::version]} {
		place $w -x -2
	    } else {
		place $w -x 0
	    }
	    return [list $height $height]
	}

	default {
	    pack $w
	    return [list [winfo reqwidth $w] [winfo reqheight $w]]
	}
    }
}
