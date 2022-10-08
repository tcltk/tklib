
[//000000001]: # (canvas::edit::points \- Variations on a canvas)
[//000000002]: # (Generated from file 'canvas\_epoints\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (canvas::edit::points\(n\) 0\.2 tklib "Variations on a canvas")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

canvas::edit::points \- Editing a cloud of points on a canvas

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [Class API](#section2)

  - [Instance API](#section3)

  - [Options](#section4)

  - [Bugs, Ideas, Feedback](#section5)

  - [Keywords](#keywords)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5  
package require Tk 8\.5  
package require canvas::edit::points ?0\.2?  

[__::canvas::edit__ __points__ *objectName* *canvas* *options*\.\.\.](#1)  
[__objectName__ __destroy__](#2)  
[__objectName__ __enable__](#3)  
[__objectName__ __disable__](#4)  
[__objectName__ __active__](#5)  
[__objectName__ __add__ *x* *y*](#6)  
[__objectName__ __clear__](#7)  
[__createCmd__ *canvas* *x* *y*](#8)  
[__highlightCmd__ __on__ *canvas* *item*](#9)  
[__highlightCmd__ __off__ *canvas* *state*](#10)  
[__dataCmd__ __add__ *editorObj* *id* *x* *y*](#11)  
[__dataCmd__ __remove__ *editorObj* *id*](#12)  
[__dataCmd__ __move start__ *editorObj* *id*](#13)  
[__dataCmd__ __move delta__ *editorObj* *id* *x* *y* *dx* *dy*](#14)  
[__dataCmd__ __move done__ *editorObj* *id*](#15)  

# <a name='description'></a>DESCRIPTION

This package provides a class whose instances handle editing a cloud of point
markers on a canvas\. Instances can be configured with regard to the visual
appearance of markers \(regular, and highlighted\)\. Note that instances do not
store the edited points themselves, but delegate this to a configurable object\.

# <a name='section2'></a>Class API

  - <a name='1'></a>__::canvas::edit__ __points__ *objectName* *canvas* *options*\.\.\.

    This, the class command, creates and configures a new instance of a point
    cloud editor, named *objectName*\. The instance will be connected to the
    specified *canvas* widget\.

    The result of the command is the fully qualified name of the instance
    command\.

    The options accepted here, and their values, are explained in the section
    [Options](#section4)\.

# <a name='section3'></a>Instance API

Instances of the point cloud editors provide the following API:

  - <a name='2'></a>__objectName__ __destroy__

    This method destroys the point cloud editor and releases all its internal
    resources\.

    Note that this operation does not destroy the items of the point markers the
    editor managed on the attached canvas, nor the canvas itself\.

    The result of the method is an empty string\.

  - <a name='3'></a>__objectName__ __enable__

    This method activates editing of the point cloud on the canvas\. This is the
    default after instance creation\. A call is ignored if the editor is already
    active\.

    The result of the method is an empty string\.

    The complementary method is __disable__\. The interogatory method for the
    current state is __active__\.

  - <a name='4'></a>__objectName__ __disable__

    This method disables editing of the point cloud on the canvas\. A call is
    ignored if the editor is already disabled\.

    The result of the method is an empty string\.

    The complementary method is __enable__\. The interogatory method for the
    current state is __active__\.

  - <a name='5'></a>__objectName__ __active__

    This method queries the editor state\.

    The result of the method is a boolean value, __true__ if the editor is
    active, and __false__ otherwise, i\.e\. disabled\.

    The methods to change the state are __enable__ and __disable__\.

  - <a name='6'></a>__objectName__ __add__ *x* *y*

    This method programmatically creates a point at the specified location\.

    The result of the method is an empty string\.

    Note that this method goes through the whole set of callbacks invoked when
    the user interactively creates a point, i\.e\. __\-create\-cmd__, and, more
    importantly, __\-data\-cmd__\.

    This is the method through which to load pre\-existing points into an editor
    instance\.

  - <a name='7'></a>__objectName__ __clear__

    This method programmatically removes all points from the editor\.

    The result of the method is an empty string\.

    Note that this method goes through the same callback invoked when the user
    interactively removes a point, i\.e\. __\-data\-cmd__\.

# <a name='section4'></a>Options

The class command accepts the following options

  - __\-tag__ *string*

    The value of this option is the name of the canvas tag with which to
    identify all items of all points managed by the editor\.

    This option can only be set at construction time\.

    If not specified it defaults to __POINT__

  - __\-create\-cmd__ *command\-prefix*

    The value of this option is a command prefix the editor will invoke when it
    has to create a new point\.

    This option can only be set at construction time\.

    If not specified it defaults to a command which will create a black\-bordered
    blue circle of radius 3 centered on the location of the new point\.

    The signature of this command prefix is

      * <a name='8'></a>__createCmd__ *canvas* *x* *y*

        The result of the command prefix *must* be a list of the canvas items
        it created to represent the marker\. Note here that the visual
        representation of a "point" may consist of multiple canvas items in an
        arbitrary shape\.

        The returned list of items is allowed to be empty, and such is taken as
        signal that the callback vetoed the creation of the point\.

  - __\-highlight\-cmd__ *command\-prefix*

    The value of this option is a command prefix the editor will invoke when it
    has to \(un\)highlight a point\.

    This option can only be set at construction time\.

    If not specified it defaults to a command which will re\-color the item to
    highlight in red \(and restores the color for unhighlighting\)\.

    The two signatures of this command prefix are

      * <a name='9'></a>__highlightCmd__ __on__ *canvas* *item*

        This method of the command prefix has to perform whatever is needed to
        highlight the point the *item* is a part of \(remember the note above
        about points allowed to be constructed from multiple canvas items\)\.

        The result of the command can be anything and will be passed as is as
        argument *state* to the __off__ method\.

      * <a name='10'></a>__highlightCmd__ __off__ *canvas* *state*

        This method is invoked to unhighlight a point described by the
        *state*, which is the unchanged result of the __on__ method of the
        command prefix\. The result of this method is ignored\.

        Note any interaction between dragging and highlighting of points is
        handled within the editor, and that the callback bears no responsibility
        for doing such\.

  - __\-data\-cmd__ *command\-prefix*

    The value of this option is a command prefix the editor will invoke when a
    point was edited in some way\. This is how the editor delegates the actual
    storage of point information to an outside object\.

    This option can only be set at construction time\.

    If not specified it defaults to an empty string and is ignored by the
    editor, i\.e\. not invoked\.

    The signatures of this command prefix are

      * <a name='11'></a>__dataCmd__ __add__ *editorObj* *id* *x* *y*

        This callback is invoked when a new point was added to the instance,
        either interactively, or programmatically\. See instance method
        __add__ for the latter\.

        The *id* identifies the point within the editor and will be used by
        the two other callbacks to specify which point to modify\.

        The last two arguments *x* and *y* specify the location of the new
        point in canvas coordinates\.

        The result of this method is ignored\.

      * <a name='12'></a>__dataCmd__ __remove__ *editorObj* *id*

        This callback is invoked when a point removed from the editor instance\.

        The *id* identifies the removed point within the editor\.

        The result of this method is ignored\.

      * <a name='13'></a>__dataCmd__ __move start__ *editorObj* *id*

        This callback is invoked when the movement of a point in the editor
        instance has started\.

        The *id* identifies the point within the editor about to be moved\.

        The result of this method is ignored\.

      * <a name='14'></a>__dataCmd__ __move delta__ *editorObj* *id* *x* *y* *dx* *dy*

        This callback is invoked when the point moved in the editor instance\.

        The *id* identifies the moved point within the editor, and the
        remaining arguments *x*, *y*, *dx*, and *dy* provide the new
        absolute location of the point, and full delta to the original location\.

        At the time of the calls the system is *not* committed to the move
        yet\. Only after method __move done__ was invoked and has accepted or
        rejected the last position will the editor update its internal data
        structures, either committing to the new location, or rolling the move
        back to the original one\.

        Given this the location data provided here should be saved only in
        temporary storage until then\.

        The result of this method is ignored\.

      * <a name='15'></a>__dataCmd__ __move done__ *editorObj* *id*

        This callback is invoked when the movement of a point in the editor
        instance is complete\.

        The *id* identifies the moved point within the editor\.

        The result of this method must be a boolean value\. If the method returns
        __false__ the move is vetoed and rollbed back\.

# <a name='section5'></a>Bugs, Ideas, Feedback

This document, and the package it describes, will undoubtedly contain bugs and
other problems\. Please report such in the category *canvas* of the [Tklib
Trackers](http://core\.tcl\.tk/tklib/reportlist)\. Please also report any ideas
for enhancements you may have for either package and/or documentation\.

# <a name='keywords'></a>KEYWORDS

[canvas](\.\./\.\./\.\./\.\./index\.md\#canvas),
[editing](\.\./\.\./\.\./\.\./index\.md\#editing), [point
cloud](\.\./\.\./\.\./\.\./index\.md\#point\_cloud),
[points](\.\./\.\./\.\./\.\./index\.md\#points)
