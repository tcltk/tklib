
[//000000001]: # (map\_overview \- Map display support)
[//000000002]: # (Generated from file 'map\_overview\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (map\_overview\(n\) 0\.1 tklib "Map display support")

<hr> [ <a href="../../../../toc.md">Main Table Of Contents</a> &#124; <a
href="../../../toc.md">Table Of Contents</a> &#124; <a
href="../../../../index.md">Keyword Index</a> &#124; <a
href="../../../../toc0.md">Categories</a> &#124; <a
href="../../../../toc1.md">Modules</a> &#124; <a
href="../../../../toc2.md">Applications</a> ] <hr>

# NAME

map\_overview \- Overview of the packages in the Map module

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Description](#section1)

  - [Bugs, Ideas, Feedback](#section2)

  - [Keywords](#keywords)

  - [Category](#category)

# <a name='description'></a>DESCRIPTION

  - Storage

      * File

        Definitions of simple file formats to hold geo/points, geo/boxes and
        geo/tracks, and the ability to read/write these files\. Note that
        geo/areas are closed tracks\.

          + __map::box::file__

          + __map::point::file__

          + __map::track::file__

      * Disk

        On\-disk stores for various geo/\* resources\. Exist as basic examples to
        start with, and as API demonstrators\. In the original project these
        packages were factored out of __sqlite__ was used as a store\. This
        store is however entwined too much with that project to be factored\.

          + __map::area::store::fs__

          + __map::box::store::fs__

          + __map::point::store::fs__

          + __map::track::store::fs__

      * Memory

        In\-memory stores caching geo/\* data and adding derived attributes\. The
        bridge between the actual on\-disk stores and the various widgets and
        behaviours\.

          + __map::area::store::memory__

          + __map::box::store::memory__

          + __map::point::store::memory__

          + __map::track::store::memory__

  - Widgets

    To show maps, singular geo resources, and tables of many geo resources of
    the same kind\.

      * Map

        __map::display__

      * Geo Resource Tables

          + __map::area::table\-display__

          + __map::box::table\-display__

          + __map::track::table\-display__

      * Geo Resource Display

          + __map::area::display__

          + __map::box::display__

          + __map::track::display__

  - Behaviours

    Engines attachable to __map::display__ to add custom behaviours to the
    shown map\. The two classes of engines are for displaying overlays for
    specific geo resources, and the editing/entry of specific single geo
    resources\.

      * Display

          + __map::area::map\-display__

          + __map::box::map\-display__

          + __map::point::map\-display__

          + __map::track::map\-display__

      * Editing

          + __map::box::entry__

          + __map::mark__

          + __map::track::entry__

  - Support

    __map::provider::osm__

# <a name='section2'></a>Bugs, Ideas, Feedback

This document, and the package it describes, will undoubtedly contain bugs and
other problems\. Please report such in the category *map* of the [Tklib
Trackers](http://core\.tcl\.tk/tklib/reportlist)\. Please also report any ideas
for enhancements you may have for either package and/or documentation\.

# <a name='keywords'></a>KEYWORDS

[map](\.\./\.\./\.\./\.\./index\.md\#map)

# <a name='category'></a>CATEGORY

Map Display and Supporting Utilities
