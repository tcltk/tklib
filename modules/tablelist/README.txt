       The Multi-Column Listbox and Tree Widget Package Tablelist

                                   by

                             Csaba Nemethi

                       csaba.nemethi@t-online.de 


What Is Tablelist?
------------------

Tablelist is a library package for Tcl/Tk versions 8.4 or higher,
written in pure Tcl/Tk code.  It contains:

  - the implementation of the "tablelist" mega-widget, including a
    general utility module for mega-widgets;
  - a demo script containing a useful procedure that displays the
    configuration options of an arbitrary widget in a tablelist and
    enables you to edit their values interactively;
  - a demo script implementing a widget browser based on a tablelist
    used as multi-column listbox;
  - a demo script implementing a widget browser based on a tablelist
    used as multi-column tree widget;
  - a demo script implementing a directory viewer based on a tablelist
    used as multi-column tree widget;
  - a demo script showing several ways to improve the appearance of a
    tablelist widget;
  - five further demo scripts, illustrating the interactive cell
    editing with the aid of various widgets from the Tk core and from
    the packages tile, BWidget, Iwidgets, combobox (by Bryan Oakley),
    Mentry, and Tsw;
  - one further demo script, with a tablelist widget containing
    embedded windows;
  - tile-based counterparts of the above-mentioned demo scripts;
  - a tutorial in HTML format;
  - reference pages in HTML format.

A tablelist is a multi-column listbox and tree widget.  The width of
each column can be dynamic (i.e., just large enough to hold all its
elements, including the header) or static (specified in characters or
pixels).  The columns are, per default, resizable.  The alignment of
each column can be specified as "left", "right", or "center".

The columns, rows, and cells can be configured individually.  Several
of the global and column-specific options refer to the header titles,
implemented as label widgets.  For instance, the "-labelcommand" option
specifies a Tcl command to be invoked when mouse button 1 is released
over a header label.  The most common value of this option sorts the
items based on the respective column.

The Tablelist package provides a great variety of tree styles
controlling the look & feel of the column that displays the tree
hierarchy with the aid of indentations and expand/collapse controls.

Interactive editing of the elements of a tablelist widget can be
enabled for individual cells and for entire columns.  A great variety
of widgets from the Tk core and from the packages tile, BWidget,
Iwidgets, combobox, ctext, Mentry (or Mentry_tile), and Tsw is supported
for being used as embedded edit window.  In addition, a rich set of
keyboard bindings is provided for a comfortable navigation between the
editable cells.

The Tcl command corresponding to a tablelist widget is very similar to
the one associated with a normal listbox.  There are column-, row-, and
cell-specific counterparts of the "configure" and "cget" subcommands
("columnconfigure", "rowconfigure", "cellconfigure", ...).  They can be
used, among others, to insert images and embedded windows into the cells
and the header labels.  The "index", "nearest", and "see" command
options refer to the rows, but similar subcommands are provided for the
columns and cells ("columnindex", "cellindex", ...).  The items can be
sorted with the "sort", "sortbycolumn", and "sortbycolumnlist" command
options.

The bindings defined for the body of a tablelist widget make it behave
just like a normal listbox.  This includes the support for the virtual
event <<ListboxSelect>> (which is equivalent to <<TablelistSelect>>).
In addition, version 2.3 or higher of the widget callback package Wcb
(written in pure Tcl/Tk code as well) can be used to define callbacks
for the "activate", "selection set", and "selection clear" commands,
and Wcb version 3.0 or higher also supports callbacks for the
"activatecell", "cellselection set", and "cellselection clear"
commands.  The download location of Wcb is

    https://www.nemethi.de

How to Get It?
--------------

Tablelist is available for free download from the same URL as Wcb.  The
distribution file is "tablelist7.7.tar.gz" for UNIX and
"tablelist7_7.zip" for Windows.  These files contain the same
information, except for the additional carriage return character
preceding the linefeed at the end of each line in the text files for
Windows.

Tablelist is also included in tklib, which has the address

    https://core.tcl.tk/tklib

How to Install It?
------------------

Install the package as a subdirectory of one of the directories given
by the "auto_path" variable.  For example, you can install it as a
subdirectory of the "lib" directory within your Tcl/Tk installation.

To install Tablelist on UNIX, "cd" to the desired directory and unpack
the distribution file "tablelist7.7.tar.gz":

    gunzip -c tablelist7.7.tar.gz | tar -xf -

On most UNIX systems this can be replaced with

    tar -zxf tablelist7.7.tar.gz

Both commands will create a directory named "tablelist7.7 with the
subdirectories "demos", "doc", and "scripts".

On Windows, use WinZip or some other program capable of unpacking the
distribution file "tablelist7_7.zip" into the directory "tablelist7.7",
with the subdirectories "demos", "doc", and "scripts".

The file "tablelistEdit.tcl" in the "scripts" directory is only needed
for applications making use of interactive cell editing.  Similarly, the
file "tablelistMove.tcl" in the same directory is only required for
scripts invoking the "move" or "movecolumn" tablelist command.  Finally,
the file "tablelistThemes.tcl" is only needed for applications using
the Tablelist_tile package (see next section).

How to Use It?
--------------

The Tablelist distribution provides two packages, called Tablelist and
Tablelist_tile.  The main difference between the two is that
Tablelist_tile enables the tile-based, theme-specific appearance of
tablelist widgets; this package requires tile 0.6 or higher.  It is not
possible to use both packages in one and the same application, because
both are implemented in the same "tablelist" namespace and provide
identical commands.

To be able to access the commands and variables of the Tablelist
package, your scripts must contain one of the lines

    package require tablelist ?version?
    package require Tablelist ?version?

Likewise, to be able to access the commands and variables of the
Tablelist_tile package, your scripts must contain one of the lines

    package require tablelist_tile ?version?
    package require Tablelist_tile ?version?

Since the packages Tablelist and Tablelist_tile are implemented in the
"tablelist" namespace, you must either import the procedures you need,
or use qualified names like "tablelist::tablelist".

For a detailed description of the commands and variables provided by
Tablelist and of the examples contained in the "demos" directory, see
the tutorial "tablelist.html" and the reference pages, all located in
the "doc" directory.
