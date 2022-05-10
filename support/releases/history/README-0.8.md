Overview
========

||||||
|---:|:---|:---|---:|:---|
|16|new packages|in|2|modules|
|8|changed packages|in|7|modules|
|29|internally changed packages|in|18|modules|
|28|unchanged packages|in|9|modules|
|89|packages, total|in|32|modules, total|

Legend
======

|Change|Details|Comments|
|:---|:---|:---|
|Major|API|__incompatible__ API changes|
|Minor|EF|Extended functionality, API|
||I|Major rewrite, but no API change|
|Patch|B|Bug fixes|
||EX|New examples|
||P|Performance enhancement|
|None|T|Testsuite changes|
||D|Documentation updates|

New in Tklib 0.8
================

|Module|Package|New Version|Comments|
|:---|:---|:---|:---|
|shtmlview|shtmlview::doctools|0.1||
||shtmlview::shtmlview|1.1.0||
|widget|widget|3.1||
||widget::arrowbutton|1.0||
||widget::calendar|1.0.1||
||widget::dateentry|0.97||
||widget::dialog|1.3.1||
||widget::menuentry|1.0.1||
||widget::panelframe|1.1||
||widget::ruler|1.1||
||widget::screenruler|1.2||
||widget::scrolledtext|1.0||
||widget::scrolledwindow|1.2.1||
||widget::statusbar|1.2.1||
||widget::superframe|1.0.1||
||widget::toolbar|1.2.1||
|||||

Changes from Tklib 0.7 to 0.8
=============================

|Module|Package|From 0.7|To 0.8|Comments|
|:---|:---|:---|:---|:---|
|chatwidget|chatwidget|1.1.0|1.1.4|B D EF|
|mentry|mentry::common|3.10|3.15|D EF|
|plotchart|Plotchart|2.4.1|2.5.2|D EF|
|scrollutil|scrollutil::common|1.5|1.14|D EF|
|tablelist|tablelist::common|6.8|6.18|D EF|
|tooltip|tooltip|1.4.6|1.4.7|B D|
|wcb|Wcb|3.6|3.7|D EF|
||wcb|3.6|3.7|D EF|
||||||

Invisible changes (documentation, testsuites)
=============================================

|Module|Package|From 0.7|To 0.8|Comments|
|:---|:---|:---|:---|:---|
|autoscroll|autoscroll|1.1|1.1|I|
||||||
|canvas|canvas::gradient|0.2|0.2|I|
||canvas::mvg|1|1|I|
||canvas::snap|1.0.1|1.0.1|I|
||canvas::sqmap|0.3.1|0.3.1|I|
||canvas::zoom|0.2.1|0.2.1|I|
||||||
|crosshair|crosshair|1.2|1.2|I|
|ctext|ctext|3.3|3.3|I|
|cursor|cursor|0.3.1|0.3.1|I|
||||||
|diagrams|diagram|1|1|I|
||diagram::basic|1.0.1|1.0.1|I|
||diagram::core|1|1|I|
||diagram::direction|1|1|I|
||||||
|getstring|getstring|0.1|0.1|I|
|history|history|0.1|0.1|I|
||||||
|ico|ico|0.3.2|0.3.2|I|
||ico|1.1|1.1|I|
||||||
|ipentry|ipentry|0.3|0.3|I|
|khim|khim|1.0.1|1.0.1|I|
||||||
|menubar|menubar|0.5|0.5|I|
||menubar::debug|0.5|0.5|I|
||menubar::node|0.5|0.5|I|
||menubar::tree|0.5|0.5|I|
||||||
|notifywindow|notifywindow|1.0|1.0|I|
|persistentSelection|persistentSelection|1.0b1|1.0b1|I|
|plotchart|plotanim|0.2|0.2|I|
|swaplist|swaplist|0.2|0.2|I|
||||||
|widgetl|widget::listentry|0.1.2|0.1.2|I|
||widget::listsimple|0.1.2|0.1.2|I|
|widgetPlus|widgetPlus|1.0b2|1.0b2|I|
||||||

Unchanged
=========

    bindDown, canvas::drag, canvas::edit::points,
    canvas::edit::polyline, canvas::edit::quadrilateral,
    canvas::highlight, canvas::tag, canvas::track::lines,
    controlwidget, datefield, diagram::application,
    diagram::attribute, diagram::element, diagram::navigation,
    diagram::point, led, meter, radioMatrix, rdial, style,
    style::as, style::lobster, tachometer, tipstack, tkpiechart,
    voltmeter, widget::validator, xyplot
