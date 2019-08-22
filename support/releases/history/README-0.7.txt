Overview
========

    4  new packages       in 4  modules
    10 changed packages   in 8  modules
    50 unchanged packages in 20 modules
    78 packages, total    in 30 modules, total

New in tklib 0.6
================

    Module                Package               New Version   Comments
    --------------------- --------------------- ------------- ----------
    canvas                canvas::gradient      0.2
    notifywindow          notifywindow          1.0
    persistentSelection   persistentSelection   1.0b1
    widgetPlus            widgetPlus            1.0b2
    --------------------- --------------------- ------------- ----------

Changes from tklib 0.6 to 0.6
=============================

                                         tklib 0.6     tklib 0.6
    Module          Package              Old Version   New Version   Comments
    --------------- -------------------- ------------- ------------- ------------
    controlwidget   rdial                0.3           0.7           EF EX
    crosshair       crosshair            1.1           1.2           B EF
    mentry          mentry::common       3.6           3.9           B D EF P
    plotchart       Plotchart            2.1.0         2.4.1         B D EF
    --------------- -------------------- ------------- ------------- ------------
    tablelist       tablelist::common    5.7                         API B EF P
                    tablelist::common                  6.6           API B EF P
    --------------- -------------------- ------------- ------------- ------------
    tooltip         tooltip              1.4.4         1.4.6         B EF
    --------------- -------------------- ------------- ------------- ------------
    wcb             Wcb                  3.4           3.6           EF
                    wcb                  3.4           3.6           EF
    --------------- -------------------- ------------- ------------- ------------
    widgetl         widget::listentry    0.1.1         0.1.2         B D
                    widget::listsimple   0.1.1         0.1.2         B D
    --------------- -------------------- ------------- ------------- ------------

Unchanged
=========

    autoscroll, bindDown, canvas::drag, canvas::edit::points,
    canvas::edit::polyline, canvas::edit::quadrilateral,
    canvas::highlight, canvas::mvg, canvas::snap, canvas::sqmap,
    canvas::tag, canvas::track::lines, canvas::zoom, chatwidget,
    controlwidget, ctext, cursor, datefield, diagram,
    diagram::application, diagram::attribute, diagram::basic,
    diagram::core, diagram::direction, diagram::element,
    diagram::navigation, diagram::point, getstring, history, ico,
    ipentry, khim, led, menubar, menubar::debug, menubar::node,
    menubar::tree, meter, plotanim, radioMatrix, style, style::as,
    style::lobster, swaplist, tachometer, tipstack, tkpiechart,
    voltmeter, widget::validator, xyplot

Legend  Change  Details Comments
        ------  ------- ---------
        Major   API:    ** incompatible ** API changes.

        Minor   EF :    Extended functionality, API.
                I  :    Major rewrite, but no API change

        Patch   B  :    Bug fixes.
                EX :    New examples.
                P  :    Performance enhancement.

        None    T  :    Testsuite changes.
                D  :    Documentation updates.
    
