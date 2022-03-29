
[//000000001]: # (shtmlview \- Basic HTML and Markdown viewer widget)
[//000000002]: # (Generated from file 'shtmlview\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2018\-2022, Detlef Groth <detlef\(at\)dgroth\(dot\)de>)
[//000000004]: # (Copyright &copy; 2009, Robert Heller)
[//000000005]: # (Copyright &copy; 2000, Clif Flynt)
[//000000006]: # (Copyright &copy; 1995\-1999, Stephen Uhler)
[//000000007]: # (shtmlview\(n\) 1\.0\.0 tklib "Basic HTML and Markdown viewer widget")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

shtmlview \- Extended Tcl/Tk text widget with basic support for rendering of HTML
and Markdown markup

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [INSTALLATION](#section2)

  - [COMMANDS](#section3)

  - [WIDGET OPTIONS](#section4)

  - [WIDGET COMMANDS](#section5)

  - [BINDINGS FOR THE WIDGET](#section6)

  - [EXAMPLE](#section7)

  - [CHANGELOG](#section8)

  - [TODO](#section9)

  - [Thanks](#section10)

  - [Bugs, Ideas, Feedback](#section11)

  - [Code Copyright](#section12)

  - [See Also](#seealso)

  - [Keywords](#keywords)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tk  
package require snit  
package require Markdown ;\# optional Markdown support  
package require img::jpeg ;\# optional jpeg image support  
package require shtmlview::shtmlview ?1\.0\.0?  

[__::shtmlview::shtmlview__ *pathName* ?*options*?](#1)  
[*pathName* __back__](#2)  
[*pathName* __browse__ *filename* ?args?](#3)  
[*pathName* __dosearch__ *string* *direction*](#4)  
[*pathName* __forward__](#5)  
[*pathName* __getFiles__](#6)  
[*pathName* __getHistory__](#7)  
[*pathName* __getTextWidget__](#8)  
[*pathName* __helptext__ *cmd* ?*options*?](#9)  
[*pathName* __home__](#10)  
[*pathName* __open__](#11)  
[*pathName* __reload__](#12)  
[*pathName* __url__](#13)  

# <a name='description'></a>DESCRIPTION

The __shtmlview::shtmlview__ package provides the
__shtmlview::shtmlview__ widget which is a standard tk text widget with
support for rendering a reasonable subset of html tags and, if the tcllib
library Markdown is available, as well for Markdown files\. It is a pure Tcl/Tk
widget which does not need any compilation\.

The widget is not\(\!\) to be intended to be used as a web browser\. It only
supports relative links on a local filesystem, it does not\(\!\) support style
sheets, it does not support any http\(s\) or webserver like links or images\. It is
tought as a fallback widget in cases where no other possibilities exists to
display HTML or Markdown markup inside a Tk application\. So it can be used in
cases where the developer has control over the used subset of HTML markup or as
a fallback mechanism where no other possibilities exists to display HTML or
Markdown documents\.

The widget is intended to be used for instance as a help viewer or in other
cases where the developer has control about the used html tags\. Comments and
feedbacks are welcome\. The __shtmlview::shtmlview__ widget overloads the
text widget and provides new commands, named __back__, __browse__,
__dosearch__, __forward__, __home__, __open__, __reload__,
__url__ and new options, named __\-browsecmd__, __\-home__,
__\-tablesupport__, __\-toolbar__\.

Furthermore the file shtmlview\.tcl can be used as standalone application to
render Markdown and HTML files by executing __shtmlview\.tcl filename__ in
the terminal\.

The __::shtmlview::shtmlview__ command creates creates a new window \(given
by the pathName argument\) and makes it into __::shtmlview::shtmlview__
widget\. The __::shtmlview::shtmlview__ command returns its pathName
argument\. At the time this command is invoked, there must not exist a window
named pathName, but pathName's parent must exist\. The API described in this
document is not the whole API offered by the snit object
__::shtmlview::shtmlview__\. Instead, it is the subset of that API that is
expected not to change in future versions\.

Background: __::shtmlview::shtmlview__ is a pure Tcl/Tk widget based on the
library htmllib developed in the 90ties by Stephen Uhler and Clif Flynt\. This
library was wrapped into the excellent mega\-widget framework snit by Robert
Heller in 2009\. His widget however was tied directly into a help system\. The
author of this document just isolated the display part and added some functions
such as changing font size and a few buttons in the toolbar\. Also a rudimentary
display of data tables was added\. Later as well support for inline images and
extended keybindings and Markdown support was added\.

# <a name='section2'></a>INSTALLATION

The widget requires the tcllib __[snit](\.\./\.\./\.\./\.\./index\.md\#snit)__
package and optional, if desired to display Markdown files, the tcllib
__Markdown__ library\. The __shtmlview::shtmlview__ package is delivered
as a normal Tcl package folder which can be placed anywhere on your file system
or in a folder belonging to your Tcl library path\. In case you installed it into
a non\-standard folder just use append your __auto\_path__ variable as shown
below:

    lappend auto_path /path/to/parent-folder ;# of shtmlview folder
    package require shtmlview::shtmlview

Alternatively you can directly source the file shtmlview\.tcl into your Tcl
application\.

# <a name='section3'></a>COMMANDS

  - <a name='1'></a>__::shtmlview::shtmlview__ *pathName* ?*options*?

    Creates and configures a shtmlview widget\.

# <a name='section4'></a>WIDGET OPTIONS

To configure the internal text widget the helptext command courld be used
directly\.

  - __\-browsecmd__ cmd

    Each time a HTML or Markdown page is rendered the given __\-browsecmd__
    is invoked\. The actual URL is appended as first argument to the command\.

  - __\-historycombo__ boolean

    If true \(default is false\) displays a ttk::combobox if the tile package is
    available in the toolbar\. Can be only set a widget creation\.

  - __\-home__ string

    Set's the homepage filename of the shtmlview widget\. If not set, the first
    page browsed will be automatically set as the home page\.

  - __\-tablesupport__ boolean

    If true \(default\) the widget will provide some table support\. This will have
    some undesired results if table tags are misused as markup tool\. Simple html
    tables with th and td tags should display however well if no internal markup
    inside those tags is implemented\.

  - __\-toolbar__ boolean

    If true \(default\) a toolbar will be displayed on top providing standard
    buttons for methods __back__, __forward__ and __home__ as well
    as search facilities for the widget\. Default: true

# <a name='section5'></a>WIDGET COMMANDS

Each shtmlview widget created with the above command supports the following
commands and options:

  - <a name='2'></a>*pathName* __back__

    Displays the previous HTML and Markdown page in the browsing history if any\.

  - <a name='3'></a>*pathName* __browse__ *filename* ?args?

    Displays the HTML or Markdown page given by filename\(s\)\. The first given
    filename will be shown in the widget, the other, optional given filenames
    will be added to the history stack only and can be walked using the history
    keys, f and b\.

  - <a name='4'></a>*pathName* __dosearch__ *string* *direction*

    Search and hilights the given string from the current index either in the
    given direction either forward \(default\) or backwards\.

  - <a name='5'></a>*pathName* __forward__

    Displays the next HTML or Markdown page in the browsing history if any\.

  - <a name='6'></a>*pathName* __getFiles__

    This command returns a list of all visited files, cleaned up for multiple
    entries and without anchor links\.

  - <a name='7'></a>*pathName* __getHistory__

    This command returns a list of the current history of visited files and
    anchors\.

  - <a name='8'></a>*pathName* __getTextWidget__

    This commands returns the internal pathname of the text widget\. The
    developer can that way thereafter deal directly with the internal text
    widget if required\. Alternatively the __helptext__ command can be used\.
    See below\.

  - <a name='9'></a>*pathName* __helptext__ *cmd* ?*options*?

    This command exposes the internal text widget\. See the following example:

    ::shtmlview::shtmlview .help
    .help browse index.html
    .help helptext configure -background yellow

  - <a name='10'></a>*pathName* __home__

    Displays the first HTML or Markdown page which was called by *pathName*
    __browse__ or set by __\-home__\.

  - <a name='11'></a>*pathName* __open__

    Displays a standard file dialog to open a HTML or Markdown page to be
    displayed in the __shtmlview::shtmlview__ widget\.

  - <a name='12'></a>*pathName* __reload__

    Reloads and redisplays the current HTML or Markdown page visible inside the
    __shtmlview::shtmlview__ widget\.

  - <a name='13'></a>*pathName* __url__

    Returns the current URL displayed in the __::shtmlview::shtmlview__
    widget\.

# <a name='section6'></a>BINDINGS FOR THE WIDGET

The widget contain standard navigation key bindings to browse the content of an
HTML or Markdown page\. Furthermore the keypress s and r are bound to the start
of forward and reverse searches in the content\. The keys 'n' \(next\) and 'p'
\(previous\) are used to repeat the current search\. The keys 'f' and 'b' keys are
bound to browsing forward and backward in the browse history\. The 'q' key
deletes the current file from the history and displays the next one\. The 'TAB'
key browses to the next hyperlink, and pressing the Return/Enter key process the
current link\. The key combination 'Ctrl\-r' reloads the current page\.

# <a name='section7'></a>EXAMPLE

    package require Tk
    package require snit
    package require shtmlview::shtmlview
    proc browsed {url} {
        puts "You browsed $url"
    }
    set help [::shtmlview::shtmlview .help -toolbar true  -browsecmd browsed]
    $help browse index.html
    pack $help -fill both -expand true -side left
    package require Markdown
    $help browser test.md

Further examples are in the source package for __shtmlview::shtmlview__\.

# <a name='section8'></a>CHANGELOG

2022\-02\-25 version 0\.9\.2

  - fix for tk\_textCopy and documentation update

2022\-03\-06 version 0\.9\.3

  - support for MouseWheel bindings

  - fixing hyperlinks to http\(s\) links

  - support for file\-anchor links like 'file\.html\#anchor'

  - support for '\#' as link to the top

  - thanks to aplsimple for suggestions and bug reports

2022\-03\-26 version 1\.0\.0

  - HTML 3\.2 tags div, sub, sup, small, big

  - initial support for Markdown files

  - initial support for base64 encoded inline image files

  - support for jpg images if img::jpeg library is available

  - support for svg images if critcl and librsvg\-dev\(el\) or terminal application
    rsvg\-convert or cairosvg are available

  - back and forward as well for anchors

  - first and last browse entry buttons for history

  - history with full file path to allow directory changes

  - improved usage line and install option

  - keyboard bindings for next and previous search

  - return and tab for links

  - historycombo option

  - toolbar fix

  - browse fix for non\-existing files

  - removed unused css/stylesheet and web forms code

  - thanks to pepdiz for bug\-reports and suggestions

# <a name='section9'></a>TODO

  - Markdown rendering using tcllib library Markdown in case URL ends with \.md
    \(done\)

  - Support for SVG images for instance using svgconvert
    https://wiki\.tcl\-lang\.org/page/svgconvert at least on Linux/Windows

  - More tags, see tag history add 3\.2 tags:
    http://www\.martinrinehart\.com/frontend\-engineering/engineers/html/html\-tag\-history\.html
    \(done\)

# <a name='section10'></a>Thanks

Stephen Uhler, Clif Flynt and Robert Heller, they provided the majority of the
code in this widget\.

# <a name='section11'></a>Bugs, Ideas, Feedback

This document, and the package it describes, will undoubtedly contain bugs and
other problems\. Please report such to the author of this package\. Please also
report any ideas for enhancements you may have for either package and/or
documentation\.

# <a name='section12'></a>Code Copyright

BSD License type:

Sun Microsystems, Inc\. The following terms apply to all files a ssociated with
the software unless explicitly disclaimed in individual files\.

The authors hereby grant permission to use, copy, modify, distribute, and
license this software and its documentation for any purpose, provided that
existing copyright notices are retained in all copies and that this notice is
included verbatim in any distributions\. No written agreement, license, or
royalty fee is required for any of the authorized uses\. Modifications to this
software may be copyrighted by their authors and need not follow the licensing
terms described here, provided that the new terms are clearly indicated on the
first page of each file where they apply\.

IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY FOR DIRECT,
INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE
OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY DERIVATIVES THEREOF, EVEN IF THE
AUTHORS HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE\.

THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES, INCLUDING,
BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE, AND NON\-INFRINGEMENT\. THIS SOFTWARE IS PROVIDED ON AN "AS
IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE NO OBLIGATION TO PROVIDE
MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS\.

RESTRICTED RIGHTS: Use, duplication or disclosure by the government is subject
to the restrictions as set forth in subparagraph \(c\) \(1\) \(ii\) of the Rights in
Technical Data and Computer Software Clause as DFARS 252\.227\-7013 and FAR
52\.227\-19\.

# <a name='seealso'></a>SEE ALSO

[text](\.\./\.\./\.\./\.\./index\.md\#text)

# <a name='keywords'></a>KEYWORDS

[html](\.\./\.\./\.\./\.\./index\.md\#html), [text](\.\./\.\./\.\./\.\./index\.md\#text),
[widget](\.\./\.\./\.\./\.\./index\.md\#widget)

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2018\-2022, Detlef Groth <detlef\(at\)dgroth\(dot\)de>  
Copyright &copy; 2009, Robert Heller  
Copyright &copy; 2000, Clif Flynt  
Copyright &copy; 1995\-1999, Stephen Uhler
