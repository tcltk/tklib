		  The Toggle Switch Widget Package Tsw

                                   by

                             Csaba Nemethi

                       csaba.nemethi@t-online.de 


What Is Tsw?
------------

Tsw is a library package for Tcl/Tk versions 8.6 or higher.  If the
version is 8.6 then in addition it is required that the tksvg extension
can be loaded into the interpreter (Tk versions 8.7 and 9.0 or higher
have built-in SVG support).  The package is written in pure Tcl/Tk code
and contains:

  - the implementation of the "toggleswitch" mega-widget, including a
    general utility module for mega-widgets;
  - two richly commented demo scripts containing the typical steps
    needed to create and handle toggleswitch widgets;
  - a tutorial in HTML format;
  - a reference page in HTML format.

A toggleswitch is a mega-widget consisting of a horizontal trough (a
fully rounded filled rectangle) and a slider (a filled circle contained
in the trunk).  It can have one of two possible switch states: on or
off.  In the on state the slider is placed at the end of the trough, and
in the off state at its beginning.  The user can toggle between these
two states with the mouse or the space key.

You can use the "switchstate" subcommand of the Tcl command associated
with a toggleswitch to change or query the widget's switch state.  By
using the "-command" configuration option, you can specify a script to
execute whenever the switch state of the widget gets toggled.  For
compatibility with the ttk::checkbutton, toggleswitch widgets also
support the "-offvalue", "-onvalue", and "-variable" options.

How to Get It?
--------------

Tsw is available for free download from the Web page

    https://www.nemethi.de

The distribution file is "tsw1.0.tar.gz" for UNIX and "tsw1_0.zip" for
Windows.  These files contain the same information, except for the
additional carriage return character preceding the linefeed at the end
of each line in the text files for Windows.

Tsw is also included in tklib, which has the address

    https://core.tcl.tk/tklib

How to Install It?
------------------

Install the package as a subdirectory of one of the directories given
by the "auto_path" variable.  For example, you can install it as a
subdirectory of the "lib" directory within your Tcl/Tk installation (at
the same level as the tk8.X or tk9.X subdirectory).

To install Tsw on UNIX, "cd" to the desired directory and unpack the
distribution file "tsw1.0.tar.gz":

    gunzip -c tsw1.0.tar.gz | tar -xf -

On most UNIX systems this can be replaced with

    tar -zxf tsw1.0.tar.gz

Both commands will create a directory named "tsw1.0", with the
subdirectories "demos", "doc", and "scripts".

On Windows, use WinZip or some other program capable of unpacking the
distribution file "tsw1_0.zip" into the directory "tsw1.0", with the
subdirectories "demos", "doc", and "scripts".

How to Use It?
--------------

To be able to use the commands and variables defined in the Tsw
package, your scripts must contain one of the lines

    package require tsw ?version?
    package require Tsw ?version?

Since the Tsw package is implemented in its own namespace called "tsw",
you must either invoke the

    namespace import tsw::toggleswitch

command to import the only public procedure of the tsw namespace, or use
the qualified name tsw::toggleswitch.  To access Tsw variables, you must
use qualified names.

For a detailed description of the commands and variables provided by Tsw
and of the examples contained in the "demos" directory, see the tutorial
"tsw.html" and the reference page "toggleswitch.html", both located in
the "doc" directory.
