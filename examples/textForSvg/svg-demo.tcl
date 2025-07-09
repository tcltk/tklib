#! /usr/bin/env wish

# Example script for module textForSvg.
# Copyright © Keith Nash 2021-2025 All Rights Reserved except as licensed below.
# Tklib license.

namespace eval :: {
    variable binary           {}
    variable borderX          50.0
    variable borderY          50.0
    variable cnv              .right.cnv
    variable configDict       {binary {} directory {} family {} pixels {} monofam {} monopix {}}
    variable currentExample   1
    variable directory        {}
    variable examples
    variable fileName         {}
    variable formattedExample 01
    variable markedExample    1
    variable openDir          $::env(HOME)
    variable svgBinaryString  {}
    variable toggledTxt       {Shrink >>}
    variable totalExamples    220
    variable txt              .left.txt
}

proc createMainGui {} {
    destroy .top .bot .left .right

    frame  .top
    panedwindow .bot -sashrelief groove -sashwidth 2p -sashpad 0p -bd 0 -showhandle 1 -handlesize 8p

    frame  .left
    text   .left.txt     \
            -bg    white \
            -width 60    \
            -wrap  word  \
            -undo  1     \
            -highlightcolor #d9d9d9 \
            -yscrollcommand {.left.scroll set}

    scrollbar .left.scroll    \
            -orient  vertical \
            -command {.left.txt yview}

    frame  .right -bg white
    canvas .right.cnv -bg white -width 750 -height 820 -xscrollcommand {.right.horiz set} -yscrollcommand {.right.vert set}
    scrollbar .right.horiz -orient horizontal -command {.right.cnv xview}
    scrollbar .right.vert  -orient vertical   -command {.right.cnv yview}

    bind .left.txt <Shift-Return>   {RunConverter; break}
    bind .left.txt <Control-Return> {RunConverter; break}

    bind .right.cnv <Configure> AdjustScroll
    return
}

proc createButtonBar {} {
    destroy .top.group1 .top.group2 .top.group3 .top.group4 .top.group5

    labelframe  .top.group1 -relief groove -bd 2 -labelanchor n    -text {Example Code}
    labelframe  .top.group5 -relief flat   -bd 2 -labelanchor n    -text { }
    labelframe  .top.group2 -relief groove -bd 2 -labelanchor n    -text {Source Files}
    labelframe  .top.group3 -relief flat   -bd 2 -labelanchor n    -text { }
    labelframe  .top.group4 -relief flat   -bd 2 -labelanchor n    -text { }

    button      .top.group1.b0 -padx 1m -command prevExample       -text <
    label       .top.group1.b1            -textvariable formattedExample -width 3
    button      .top.group1.b2 -padx 1m -command nextExample       -text >
    label       .top.group1.b3             -bg      #d0cfce        -text {  }
    button      .top.group1.b4 -padx 0  -command mapExamplesScreen -text {See List} -width 8 

    button      .top.group2.b4 -padx 2m -command fileOpen          -text Open...
    button      .top.group2.b5 -padx 2m -command fileSave          -text Save
    button      .top.group2.b6 -padx 2m -command fileSaveAs        -text {Save As...}

    button      .top.group3.b0 -padx 2m -command RunConverter      -text Run
    button      .top.group3.b3 -padx 2m -command imageSaveAs       -text {Save Image As...}
    button      .top.group3.b2 -padx 2m -command showConfigScreen  -text {Configure, Help}
    button      .top.group3.b4 -padx 2m -command showAboutScreen   -text {About}

    button      .top.group4.b1 -padx 2m -command toggleCanvasSize  -textvariable toggledTxt -width 11 -anchor e

    button      .top.group5.b0 -padx 2m -command ClearText         -text Clear

    return
}

proc mapGui {} {
    pack .top -expand 0 -fill x
    pack .bot -expand 1 -fill both

    .bot add .left  -sticky nsew -stretch always
    .bot add .right -sticky nsew -stretch always

    pack .left.scroll -side left -anchor nw -expand 0 -fill y
    pack .left.txt    -side left -anchor nw -expand 1 -fill both

    grid .right.cnv .right.vert -sticky nsew
    grid .right.horiz -sticky nsew
    grid columnconfigure .right 0 -weight 1
    grid rowconfigure .right 0 -weight 1

    pack .top.group1 -side left  -anchor nw -expand 0 -fill none -padx {3 0}    -pady {0 2p}
    pack .top.group5 -side left  -anchor nw -expand 0 -fill none -padx 5p       -pady {0 2p}
    pack .top.group2 -side left  -anchor nw -expand 0 -fill none -padx 0        -pady {0 2p}
    pack .top.group3 -side left  -anchor nw -expand 0 -fill none -padx 5p       -pady {0 2p}
    pack .top.group4 -side right -anchor ne -expand 0 -fill none -padx 0        -pady {0 2p}

    pack .top.group1.b0 -side left -padx 2p -pady 2p -anchor nw -fill y
    pack .top.group1.b1 -side left -padx 0  -pady 2p -anchor nw -fill y
    pack .top.group1.b2 -side left -padx 2p -pady 2p -anchor nw -fill y
    pack .top.group1.b3 -side left -padx 7p -pady 2p -anchor nw -fill y
    pack .top.group1.b4 -side left -padx 2p -pady 2p -anchor nw -fill y

    pack .top.group2.b4 -side left -padx 2p -pady 2p -anchor nw
    pack .top.group2.b5 -side left -padx 2p -pady 2p -anchor nw
    pack .top.group2.b6 -side left -padx 2p -pady 2p -anchor nw

    pack .top.group3.b0 -side left -padx 2p -pady 2p -anchor nw
    pack .top.group3.b3 -side left -padx 2p -pady 2p -anchor nw
    pack .top.group3.b2 -side left -padx 2p -pady 2p -anchor nw
    pack .top.group3.b4 -side left -padx 2p -pady 2p -anchor nw

    pack .top.group4.b1 -side left -padx 0  -pady 2p -anchor nw

    pack .top.group5.b0 -side left -padx 0  -pady 2p -anchor nw

    return
}

# Command maps everything except the
# highest-level window .left.hfr

proc createConfigScreen {} {
    destroy .left.hfr
    option add *TCombobox*Listbox.background #ffffff

    set msg1 [MakeMessage {
        |• If the pikchr binary is in the PATH, its directory can be left blank.
    }]
    set msg2 [MakeMessage {
        |• The default family for the standard font is Arial or a substitute.
        |• The default height for the standard font is 16 pixels.  The value
        |   may need adjustment for font families other than Arial.
    }]
    set msg3 [MakeMessage {
        |• The default family for the monospace font is Andale Mono or a substitute.
        |• The default height for the monospace font is 13 pixels.  The value may
        |   need adjustment for font families other than Andale Mono.
    }]

    frame         .left.hfr
    frame         .left.hfr.fr2


    # PIKCHR
    labelframe    .left.hfr.fr2.f3 \
                      -relief      groove \
                      -bd          2 \
                      -labelanchor n \
                      -text        {Location Of Pikchr Binary} \
                      -font        TkHeadingFont
    label         .left.hfr.fr2.f3.help1 -text $msg1 -justify left -anchor w

    label         .left.hfr.fr2.f3.lab0 -font TkHeadingFont -text {Binary:}
    entry         .left.hfr.fr2.f3.ent0 -width 16 -bg white

    label         .left.hfr.fr2.f3.lab1 -font TkHeadingFont -text {Directory:}
    entry         .left.hfr.fr2.f3.ent1 -width 30 -bg white


    # STD FONT
    labelframe    .left.hfr.fr2.f4 \
                      -relief      groove \
                      -bd          2 \
                      -labelanchor n \
                      -font        TkHeadingFont \
                      -text        {Standard Font}
    label         .left.hfr.fr2.f4.help2 -text $msg2 -justify left -anchor w

    label         .left.hfr.fr2.f4.lab2 -font TkHeadingFont -text {Standard Font Family:}
    ttk::combobox .left.hfr.fr2.f4.com2 -values [FontFamilies]

    label         .left.hfr.fr2.f4.lab3 -font TkHeadingFont -text {Standard Font Height (pixels):}
    entry         .left.hfr.fr2.f4.ent3 -width 6 -bg white


    # MONO FONT
    labelframe    .left.hfr.fr2.f5 \
                      -relief      groove \
                      -bd          2 \
                      -labelanchor n \
                      -font        TkHeadingFont \
                      -text        {Monospace Font}
    label         .left.hfr.fr2.f5.help3 -text $msg3 -justify left -anchor w

    label         .left.hfr.fr2.f5.lab4 -font TkHeadingFont -text {Monospace Font Family:}
    ttk::combobox .left.hfr.fr2.f5.com3 -values [FontFamilies mono]

    label         .left.hfr.fr2.f5.lab5 -font TkHeadingFont -text {Monospace Font Height (pixels):}
    entry         .left.hfr.fr2.f5.ent4 -width 6 -bg white


    # BUTTONS
    frame       .left.hfr.fr2.f6
    frame       .left.hfr.fr2.f6.fr

    labelframe  .left.hfr.fr2.f6.fr.bbar1 \
                    -relief      groove \
                    -bd          2 \
                    -labelanchor n \
                    -text        {Restore Defaults}
    button      .left.hfr.fr2.f6.fr.bbar1.b2 \
                    -activebackground #dcddff \
                    -background       #d0cfff \
                    -width            5 \
                    -text             Sans \
                    -command          {pickFont Sans}
    button      .left.hfr.fr2.f6.fr.bbar1.b3 \
                    -activebackground #dcddff \
                    -background       #d0cfff \
                    -width            5 \
                    -text             Serif \
                    -command          {pickFont Serif}
    button      .left.hfr.fr2.f6.fr.bbar1.b4 \
                    -activebackground #dcddff \
                    -background       #d0cfff \
                    -width            5 \
                    -text             Mono \
                    -command          {pickFont Mono}

    labelframe  .left.hfr.fr2.f6.fr.bbar2 \
                    -relief      groove \
                    -bd          2 \
                    -labelanchor n \
                    -text        Actions
    button      .left.hfr.fr2.f6.fr.bbar2.b0 \
                    -activebackground #dcddff \
                    -background       #d0cfff \
                    -width            6 \
                    -text             Cancel \
                    -command          cancelConfigScreen
    button      .left.hfr.fr2.f6.fr.bbar2.b1 \
                    -activebackground #dcddff \
                    -background       #d0cfff \
                    -width            6 \
                    -text             Save \
                    -command          saveAndApplyConfigScreen


    # GEOM
    place   .left.hfr.fr2    -anchor nw -x 5p -y 5p
    pack    .left.hfr.fr2.f3 -anchor nw -fill x
    pack    .left.hfr.fr2.f4 -anchor nw -fill x -pady {5p 0}
    pack    .left.hfr.fr2.f5 -anchor nw -fill x -pady {5p 0}
    pack    .left.hfr.fr2.f6 -anchor nw -fill x -pady {5p 0}

    grid    .left.hfr.fr2.f3.help1 -columnspan 2        -sticky nsw -padx 5p       -pady 3p
    grid    .left.hfr.fr2.f3.lab0 .left.hfr.fr2.f3.ent0 -sticky nse -padx {15p 3p}
    grid    .left.hfr.fr2.f3.lab1 .left.hfr.fr2.f3.ent1 -sticky nse -padx {15p 3p} -pady {0 3p}

    grid    .left.hfr.fr2.f4.help2 -columnspan 2        -sticky nsw -padx 5p       -pady 3p
    grid    .left.hfr.fr2.f4.lab2 .left.hfr.fr2.f4.com2 -sticky nse -padx {15p 3p}
    grid    .left.hfr.fr2.f4.lab3 .left.hfr.fr2.f4.ent3 -sticky nse -padx {15p 3p} -pady {0 3p}

    grid    .left.hfr.fr2.f5.help3 -columnspan 2        -sticky nsw -padx 5p       -pady 3p
    grid    .left.hfr.fr2.f5.lab4 .left.hfr.fr2.f5.com3 -sticky nse -padx {15p 3p}
    grid    .left.hfr.fr2.f5.lab5 .left.hfr.fr2.f5.ent4 -sticky nse -padx {15p 3p} -pady {0 3p}

    grid configure       .left.hfr.fr2.f3.ent0 -sticky nsw  -padx {0 13p}
    grid configure       .left.hfr.fr2.f3.ent1 -sticky nsew -padx {0  3p}
    grid configure       .left.hfr.fr2.f4.com2 -sticky nsw  -padx {0 13p}
    grid configure       .left.hfr.fr2.f4.ent3 -sticky nsw  -padx {0 13p}
    grid configure       .left.hfr.fr2.f5.com3 -sticky nsw  -padx {0 13p}
    grid configure       .left.hfr.fr2.f5.ent4 -sticky nsw  -padx {0 13p}
    grid columnconfigure .left.hfr.fr2.f3 0 -weight 0
    grid columnconfigure .left.hfr.fr2.f3 1 -weight 1
    grid columnconfigure .left.hfr.fr2.f4 0 -weight 0
    grid columnconfigure .left.hfr.fr2.f4 1 -weight 1
    grid columnconfigure .left.hfr.fr2.f5 0 -weight 0
    grid columnconfigure .left.hfr.fr2.f5 1 -weight 1

    pack .left.hfr.fr2.f6.fr -padx 5p -pady 3p -side top -anchor n
    pack .left.hfr.fr2.f6.fr.bbar1 -side left -padx 18p
    pack .left.hfr.fr2.f6.fr.bbar2 -side left -padx 18p

    pack .left.hfr.fr2.f6.fr.bbar1.b2 -side left -padx 3p -pady 3p
    pack .left.hfr.fr2.f6.fr.bbar1.b3 -side left -padx 3p -pady 3p
    pack .left.hfr.fr2.f6.fr.bbar1.b4 -side left -padx 3p -pady 3p

    pack .left.hfr.fr2.f6.fr.bbar2.b0 -side left -padx 3p -pady 3p
    pack .left.hfr.fr2.f6.fr.bbar2.b1 -side left -padx 3p -pady 3p
    return
}

proc showConfigScreen {} {
    ValuesToConfigScreen
    place .left.hfr -x 0 -y 0 -anchor nw -relheight 1.0 -relwidth 1.0
    SetButtonsState disabled
    .top.group3.b2 configure \
            -text             Cancel \
            -state            normal \
            -command          cancelConfigScreen \
            -background       #d0cfff \
            -activebackground #dcddff
    .top.group4.b1 configure \
            -background       #d0cfff \
            -activebackground #dcddff
    return
}

proc cancelConfigScreen {} {
    place forget .left.hfr
    .top.group3.b2 configure \
            -text             {Configure, Help} \
            -command          showConfigScreen \
            -background       [.top.group2.b4 cget -background] \
            -activebackground [.top.group2.b4 cget -activebackground]
    .top.group4.b1 configure \
            -background       [.top.group2.b4 cget -background] \
            -activebackground [.top.group2.b4 cget -activebackground]
    SetButtonsState normal
    return
}

proc ValuesToConfigScreen {} {
    variable configDict

    .left.hfr.fr2.f3.ent0 delete 0 end
    .left.hfr.fr2.f3.ent0 insert 0 [dict get $configDict binary]
    .left.hfr.fr2.f3.ent1 delete 0 end
    .left.hfr.fr2.f3.ent1 insert 0 [dict get $configDict directory]

    .left.hfr.fr2.f4.com2 set [dict get [font actual [list [dict get $configDict family] 10]] -family]

    .left.hfr.fr2.f4.ent3 delete 0 end
    .left.hfr.fr2.f4.ent3 insert 0 [dict get $configDict pixels]

    .left.hfr.fr2.f5.com3 set [dict get [font actual [list [dict get $configDict monofam] 10]] -family]

    .left.hfr.fr2.f5.ent4 delete 0 end
    .left.hfr.fr2.f5.ent4 insert 0 [dict get $configDict monopix]

    return
}

proc saveAndApplyConfigScreen {} {
    variable configDict

    set data {}
    dict set data binary    [.left.hfr.fr2.f3.ent0 get]
    dict set data directory [.left.hfr.fr2.f3.ent1 get]
    dict set data family    [.left.hfr.fr2.f4.com2 get]
    dict set data pixels    [.left.hfr.fr2.f4.ent3 get]
    dict set data monofam   [.left.hfr.fr2.f5.com3 get]
    dict set data monopix   [.left.hfr.fr2.f5.ent4 get]

    set map [list \\\\ / \\ /]
    dict set data directory [string map $map [dict get $data directory]]

    if {[ValidateConfigValues $data]} {
        ReportError {one or more values are invalid}
        return
    }

    set configDict $data
    SaveConfigToFile

    ApplyConfigValues
    cancelConfigScreen
    RunConverter
    return
}

proc pickFont {style} {
    set fam [textForSvg::getDefaultFontFamily $style]
    if {$style eq {Mono}} {
        set pix 13
        .left.hfr.fr2.f5.com3 set $fam
        .left.hfr.fr2.f5.ent4 delete 0 end
        .left.hfr.fr2.f5.ent4 insert end $pix
    } else {
        set pix 16
        .left.hfr.fr2.f4.com2 set $fam
        .left.hfr.fr2.f4.ent3 delete 0 end
        .left.hfr.fr2.f4.ent3 insert end $pix
    }
    return
}


proc SaveConfigToFile {} {
    variable configDict

    if {$::tcl_platform(platform) eq {windows}} {
        set bak .bak
        set DOT {}
    } else {
        set bak ~
        set DOT .
    }

    set configName [file join $::env(HOME) ${DOT}svg-text-demo-settings.cfg]

    if {[file exists ${configName}]} {
        if {[file exists ${configName}${bak}]} {
            file delete -force -- ${configName}${bak}
        }
        file rename -force -- ${configName} ${configName}${bak}
    }
    set fout [open ${configName} w]
    puts $fout $configDict
    close $fout
    return
}

proc ApplyConfigValues {} {
    variable configDict
    variable binary
    variable directory

    set binary                           [dict get $configDict binary]
    set directory                        [dict get $configDict directory]
    set tryFont                          [dict get $configDict family]
    textForSvg::configure -defaultheight [dict get $configDict pixels]

    if {[textForSvg::fontIsPresent $tryFont]} {
        textForSvg::configure -defaultfont $tryFont      
    }

    set tryFont                          [dict get $configDict monofam]
    textForSvg::configure -monoheight    [dict get $configDict monopix]

    if {[textForSvg::fontIsPresent $tryFont]} {
        textForSvg::configure -monofont $tryFont
    }

    return
}

# From WHD.
proc MakeMessage {in} {
    regsub -all -line {^\s*\|} [string trim $in] {}
}

proc FontFamilies {{style any}} {
    if {$style ni {any mono}} {
        return -code error "argument \"style\" must be \"any\" or \"mono\""
    }
    set ls {}
    set ff [lsort -unique [font families]]
    foreach fnt $ff {
        if {[string match {Noto Sans *} $fnt] || [string match {Noto Serif *} $fnt]} {
            # Skip the localized subfonts.
        } else {
            lappend ls $fnt
        }
    }

    if {$style eq {mono}} {
        set ff $ls
        set ls {}
        foreach fnt $ff {
            if {[font metrics [list $fnt 10] -fixed]} {
                lappend ls $fnt
            }
        }
    }
    return $ls
}

# Command maps everything except the
# highest-level window .left.afr

proc createAboutScreen {} {
    destroy .left.afr

    set msg3 [MakeMessage {
        |• Tk (8.7, 9.x) and tksvg (for Tk 8.6) can draw SVG images,
        |   but without text labels.
        |• Module textForSvg implements a subset of SVG text labels.
        |• The goal is to allow Tk 8.6+ to fully display SVG images
        |   generated by the pikchr command.  The module is tested
        |   by comparison with SVG rendering in the Google Chrome®
        |   web browser.
        |• The pikchr example code is taken without modification or
        |   omission from the pikchr site at https://pikchr.org/ and
        |   is released under the pikchr license (0-clause BSD).
        |• N.B. Some examples have deliberate errors.  This is
        |   mentioned in a comment added to the example source code.
        |
        |• Module textForSvg is © 2021-2025 Keith Nash and is
        |   released under the Tklib license.
    }]

    frame      .left.afr
    frame      .left.afr.fr2
    labelframe .left.afr.fr2.f3 \
                   -relief      groove \
                   -bd          2 \
                   -labelanchor n \
                   -text        {About textForSvg} \
                   -font        TkHeadingFont
    label      .left.afr.fr2.f3.lab1 -text $msg3 -justify left -anchor w
    button     .left.afr.fr2.f3.b0 \
                   -text             Cancel \
                   -command          cancelAboutScreen \
                   -activebackground #dcddff \
                   -background       #d0cfff

    place      .left.afr.fr2         -anchor nw -x 5p -y 5p
    pack       .left.afr.fr2.f3      -anchor n
    pack       .left.afr.fr2.f3.lab1 -anchor n -pady 5p -padx 3p
    pack       .left.afr.fr2.f3.b0   -anchor n -pady 5p -padx 3p

    return
}

proc showAboutScreen {} {
    place .left.afr -x 0 -y 0 -anchor nw -relheight 1.0 -relwidth 1.0
    SetButtonsState disabled
    .top.group3.b4 configure \
            -text             Cancel \
            -state            normal \
            -command          cancelAboutScreen \
            -background       #d0cfff \
            -activebackground #dcddff
    .top.group4.b1 configure \
            -background       #d0cfff \
            -activebackground #dcddff
    return
}

proc cancelAboutScreen {} {
    place forget .left.afr
    .top.group3.b4 configure \
            -text             {About} \
            -command          showAboutScreen \
            -background       [.top.group2.b4 cget -background] \
            -activebackground [.top.group2.b4 cget -activebackground]
    .top.group4.b1 configure \
            -background       [.top.group2.b4 cget -background] \
            -activebackground [.top.group2.b4 cget -activebackground]
    SetButtonsState normal
    return
}

proc getInitConfigValues {} {
    GetDefaultConfigValues
    set res [GetFileConfigValues]
    ApplyConfigValues
    if {$res} {
        ReportError {configuration file could not be loaded or had bad contents}
        # Continue with default values.
        return
    }
    return
}

proc GetDefaultConfigValues {} {
    variable configDict

    set bin pikchr
    if {$::tcl_platform(platform) eq {windows}} {
        append bin .exe
    }

    dict set configDict binary    $bin
    dict set configDict directory {}
    dict set configDict family    [textForSvg::getDefaultFontFamily Sans]
    dict set configDict pixels    16
    dict set configDict monofam   [textForSvg::getDefaultFontFamily Mono]
    dict set configDict monopix   13

    return
}

# Read config file values into configDict.
# Return 1 if there is a problem with the file or the values; 0 for no problem or no file.

proc GetFileConfigValues {} {
    variable configDict

    # If valid data available from stored configuration file, use it.
    # Otherwise, keep existing values.

    if {$::tcl_platform(platform) eq {windows}} {
        set DOT {}
    } else {
        set DOT .
    }

    set configName [file join $::env(HOME) ${DOT}svg-text-demo-settings.cfg]

    if {![file exists $configName]} {
        return 0
    }
    if {![file readable $configName]} {
        return 1
    }
    if {[catch {
        set fin  [open ${configName}]
        set data [read $fin]
        close $fin
    }]} {
        return 1
    }
    if {[ValidateConfigValues $data]} {
        return 1
    }

    dict set configDict binary    [dict get $data binary]
    dict set configDict directory [dict get $data directory]
    dict set configDict family    [dict get $data family]
    dict set configDict pixels    [dict get $data pixels]
    dict set configDict monofam   [dict get $data monofam]
    dict set configDict monopix   [dict get $data monopix]

    return 0
}

# ------------------------------------------------------------------------------
#  Proc ValidateConfigValues
# ------------------------------------------------------------------------------
# Test the configuration data in argument "data".
# Return 0 if data accepted, 1 if rejected.
# Reject data that has square brackets, dollar sign, or backslash.
# Reject data if it is not a valid list.
# Reject data if it is not a dict with keys binary, directory, family, and pixels.
# Reject data if "binary" value is empty.
# Reject data if "family" value is not in [font families].
# Reject data if "pixels" value is not a number >= 1.0.
# ------------------------------------------------------------------------------

proc ValidateConfigValues {data} {
    set cleanData [string map [list \[ {} \] {} \$ {} \\ /] $data]
    if {$cleanData ne $data} {
        return 1
    }
    if {![string is list -strict $data]} {
        return 1
    }
    foreach key {binary directory family pixels} {
        if {![dict exists $data $key]} {
            return 1
        }
    }

    set bin  [dict get $data binary]
    set fam  [dict get $data family]
    set pix  [dict get $data pixels]
    set mfam [dict get $data monofam]
    set mpix [dict get $data monopix]
    if {$bin eq {}} {
        return 1
    }
    if {$fam ni [font families]} {
        return 1
    }
    if {![string is double -strict $pix] || ($pix < 1.0)} {
        return 1
    }
    if {$mfam ni [font families]} {
        return 1
    }
    if {![string is double -strict $mpix] || ($mpix < 1.0)} {
        return 1
    }
    return 0
}

# Command maps everything except the
# highest-level window .left.fr

proc createExamplesScreen {} {
    variable totalExamples
    set Nwide 15
    set Nhigh 15
    if {($Nwide * $Nhigh) < $totalExamples} {
        ReportError "Have $totalExamples examples; but \
                buttons for [expr {$Nwide * $Nhigh}]."
        return
    }

    destroy .left.fr
    frame   .left.fr
    frame   .left.fr.fr2 -bd 2 -relief groove
    place   .left.fr.fr2 -x 13p -y 13p -anchor nw

    set sta normal
    for {set i 0} {$i < $Nhigh} {incr i} {
        set row {}
        for {set j 0} {$j < $Nwide} {incr j} {
            set k [expr {$i * $Nwide + $j + 1}]
            if {$k > $totalExamples} {
                break
            }
            button .left.fr.fr2.b$k        \
                    -text    [format %03u $k]      \
                    -command [list loadExample $k] \
                    -cursor  arrow                 \
                    -state   $sta \
                    -bd      1p -padx 1p -pady 1p
            lappend row .left.fr.fr2.b$k
        }
        grid {*}$row -padx 1p -pady 1p
    }
    return
}

proc mapExamplesScreen {} {
    place .left.fr -x 0 -y 0 -anchor nw -relheight 1.0 -relwidth 1.0
    SetButtonsState disabled
    .top.group1.b4 configure \
            -text             Cancel \
            -command          unmapExamplesScreen \
            -state            normal \
            -background       #d0cfff \
            -activebackground #dcddff
    .top.group4.b1 configure \
            -background       #d0cfff \
            -activebackground #dcddff
    return
}

proc unmapExamplesScreen {} {
    place forget .left.fr
    .top.group1.b4 configure \
            -text             {See List}  \
            -command          mapExamplesScreen \
            -background       [.top.group2.b4 cget -background] \
            -activebackground [.top.group2.b4 cget -activebackground]
    .top.group4.b1 configure \
            -background       [.top.group2.b4 cget -background] \
            -activebackground [.top.group2.b4 cget -activebackground]

    SetButtonsState normal
    return
}

proc prevExample {} {
    variable currentExample
    variable formattedExample

    if {$currentExample == 1} {
        return
    } else {
        incr currentExample -1
        set formattedExample [format %03u $currentExample]
        .top.group1.b2 configure -state normal
    }
    if {$currentExample == 1} {
        .top.group1.b0 configure -state disabled
    }
    loadExample $currentExample
    return
}

proc nextExample {} {
    variable currentExample
    variable formattedExample
    variable totalExamples

    if {$currentExample == $totalExamples} {
        return
    } else {
        incr currentExample
        set formattedExample [format %03u $currentExample]
        .top.group1.b0 configure -state normal
    }
    if {$currentExample == $totalExamples} {
        .top.group1.b2 configure -state disabled
    }
    loadExample $currentExample
    return
}

proc SetButtonsState {bst} {
    variable currentExample
    variable totalExamples

    foreach wbut {
        .top.group1.b0
        .top.group1.b1
        .top.group1.b2
        .top.group1.b4
        .top.group5.b0
        .top.group2.b4
        .top.group2.b5
        .top.group2.b6
        .top.group3.b0
        .top.group3.b2
        .top.group3.b3
        .top.group3.b4
    } {
        $wbut configure -state $bst
    }

    if {$currentExample == 1} {
        .top.group1.b0 configure -state disabled
    }
    if {$currentExample == $totalExamples} {
        .top.group1.b2 configure -state disabled
    }
    return
}

proc markSelectedExample {} {
    variable currentExample
    variable markedExample

    UnmarkExample  $markedExample
    MarkExample    $currentExample
    set markedExample $currentExample
    return
}

proc MarkExample {i} {
    .left.fr.fr2.b$i configure -bd 2p -relief sunken
    grid configure .left.fr.fr2.b$i -padx 0p -pady 0p
    return
}

proc UnmarkExample {i} {
    .left.fr.fr2.b$i configure -bd 1p -relief raised
    grid configure .left.fr.fr2.b$i -padx 1p -pady 1p
    return
}

proc toggleCanvasSize {} {
    variable toggledTxt

    if {$toggledTxt eq {Unshrink <<}} {
        UnshrinkCanvas
    } else {
        ShrinkCanvas
    }
    return
}

proc UnshrinkCanvas {} {
    variable toggledTxt
    variable cnv

    if {$toggledTxt eq {Unshrink <<}} {
        set toggledTxt {Shrink >>}
        # $cnv configure -width 750
        .bot paneconfigure .right -hide 0
    }
    return
}

proc ShrinkCanvas {} {
    variable toggledTxt
    variable cnv

    if {$toggledTxt eq {Shrink >>}} {
        set toggledTxt {Unshrink <<}
        # $cnv configure -width 5
        .bot paneconfigure .right -hide 1
    }
    return
}

proc fileOpen {} {
    variable txt
    variable fileName
    variable openDir

    set fileTypes {{{PIKCHR Source} .pikchr} {{All Files} *}}
    set opts {}
    lappend opts -filetypes $fileTypes -parent . -title "Open Pikchr Source File"

    if {$::tcl_platform(platform) eq {windows}} {
        lappend opts -defaultextension .pikchr
    }

    if {$openDir ne {}} {
        lappend opts -initialdir $openDir
    }

    set file [tk_getOpenFile {*}$opts]
    if {$file eq {}} {
        return
    }
    set fileName $file
    set openDir [file dirname $file]

    set fin [open $file]
    set data [read $fin]
    close $fin

    ClearText
    set fileName $file
    $txt insert end $data
    RunConverter
    return
}

# Return Value: 1 for success, 0 for failure.
proc fileSave {{again 0}} {
    variable fileName
    variable txt

    if {($fileName eq {}) && !$again} {
        return [fileSaveAs]
    } elseif {$fileName eq {}} {
        return 0
    }
    set data [$txt get 1.0 end-1c]
    set fout [open $fileName w]
    puts -nonewline $fout $data
    close $fout
    return 1
}

# Return Value: 1 for success, 0 for failure.
proc fileSaveAs {} {
    variable fileName
    variable openDir

    set fileTypes {{{PIKCHR Source} .pikchr} {{All Files} *}}
    set opts {}
    lappend opts -filetypes $fileTypes -parent . -title "Save Pikchr Source File As"

    if {$::tcl_platform(platform) eq {windows}} {
        lappend opts -defaultextension .pikchr
    }

    if {$fileName eq {}} {
        lappend opts -initialdir $openDir
    } else {
        set fn [file normalize $fileName]
        set fd [file dirname $fn]
        set ft [file tail $fn]
        lappend opts -initialdir $fd -initialfile $ft
    }
    set file [tk_getSaveFile {*}$opts]
    if {$file eq {}} {
        return 0
    }
    set openDir [file dirname $file]
    set fileName $file
    fileSave 1
}

proc loadExample {i} {
    variable currentExample
    variable formattedExample
    variable examples
    variable txt
    variable fileName

    set fileName {}
    set currentExample $i
    set formattedExample [format %03u $currentExample]
    set data [string trim $examples($i) \n]\n
    clearDisplay
    $txt insert end $data
    unmapExamplesScreen
    markSelectedExample
    RunConverter
    return
}

proc clearDisplay {} {
    ClearText
    ClearImage
    return
}

proc ClearText {} {
    variable txt

    $txt delete 1.0 end-1c
    return
}

proc ClearImage {} {
    variable cnv
    variable svgBinaryString

    set svgBinaryString {}
    $cnv delete {*}[$cnv find all]
    catch {image delete img1}
    return
}

proc imageSaveAs {{extn .png}} {
    variable fileName
    variable openDir

    if {$extn ni {.png .svg}} {
        set extn *
    }

    if {$fileName ne {}} {
        set fileInitials [list \
                -initialfile [file rootname [file tail $fileName]] \
                -initialdir  [file dirname $fileName] \
        ]
    } else {
        set fileInitials [list -initialdir $openDir]
    }

    if {$::tcl_platform(platform) eq {windows}} {
        set defaultExt [list -defaultextension $extn]
    } else {
        set defaultExt {}
    }

    set fileTypes { \
            {{PNG Images}    .png}     \
            {{SVG Images}    .svg}     \
            {{All Files}     *}        \
    }
    set newFilePath [tk_getSaveFile    \
            -filetypes $fileTypes      \
            -title     "Save Image As" \
            -parent    .               \
            {*}$fileInitials           \
            {*}$defaultExt]


    if {$newFilePath eq ""} {
        # User has cancelled.
        return
    }

    # We've got a new filename $newFilePath from the requester.
    set openDir [file dirname $newFilePath]
    imageSave $newFilePath
    return
}

proc imageSave {file} {
    variable cnv
    variable svgBinaryString

    if {[file extension $file] eq {.svg}} {
        set data $svgBinaryString
        set opts {-translation binary}
    } else {
        set data [textForSvg::imageCreatePhoto -- -data $svgBinaryString]
        set opts {-translation binary}
    }
    set fout [open $file w]
    fconfigure $fout {*}$opts
    puts -nonewline $fout $data
    close $fout
    return
}

# ------------------------------------------------------------------------------
#  Proc RunConverter
# ------------------------------------------------------------------------------
# The command executed by the "Run" button.  Reads Pikchr source from the left
# window, and draws the SVG image in the right window as a canvas with image and
# text items.
#
# Arguments: none
# Return Value: none
# ------------------------------------------------------------------------------

proc RunConverter {} {
    variable txt
    variable cnv
    variable borderX
    variable borderY

    set txtIn [$txt get 1.0 end-1c]
    set xmlData [Pik2Svg $txtIn]
    UnshrinkCanvas
    SvgToImage $xmlData $borderX $borderY
    AdjustScroll
    $cnv xview moveto 0
    $cnv yview moveto 0
    return
}

proc AdjustScroll {} {
    variable cnv
    variable borderX
    variable borderY

    set imgName img1

    if {"img1" in [image names]} {
        set imgW [image width $imgName]
        set imgH [image height $imgName]
    } else {
        set imgW 0
        set imgH 0
    }
    set maxW [expr {max($imgW + 2 * $borderX, [winfo width $cnv])}]
    set maxH [expr {max($imgH + 2 * $borderY, [winfo height $cnv])}]
    $cnv configure -scrollregion [list 0 0 $maxW $maxH]

    return
}

# ------------------------------------------------------------------------------
#  Proc Pik2Svg
# ------------------------------------------------------------------------------
# Convert pikchr source to SVG image data.
#
# Arguments:
# pik         - data in pikchr format, Tcl string
#
# Return Value: data in SVG format, Tcl string
# ------------------------------------------------------------------------------

proc Pik2Svg {pik} {
    variable binary
    variable directory

    if {$directory eq {}} {
        # binary is in the PATH
        set path $binary
    } else {
        set path [file join [file normalize $directory] $binary]
    }
    if {$::tcl_platform(platform) eq "windows"} {
        set bin pikchr.exe
    } else {
        set bin pikchr
    }
    if {![file exists $path]} {
        ReportError "Requested file \"$path\" does not exist.\nClick the\
                \"Configure, Help\" button\nto specify the $bin file."
        return
    }
    if {![file executable $path]} {
        ReportError "Requested file \"$path\" is not executable."
        return
    }

    if {[catch {exec $path --svg-only - << $pik} svg]} {
        ReportError $svg
        return
    }
    string range $svg [string first {<svg } $svg] end
}


# ------------------------------------------------------------------------------
#  Proc SvgToImage
# ------------------------------------------------------------------------------
# Use SVG data to create a canvas with SVG image item and text items for labels.
#
# Arguments:
# xmlData     - SVG image data as a Tcl string
# xoff        - horizontal offset
# yoff        - vertical offset
#
# Return Value: none
# ------------------------------------------------------------------------------

proc SvgToImage {xmlData {xoff 0.0} {yoff 0.0}} {
    variable cnv
    variable svgBinaryString

    ClearImage
    set xmlDataBinary [string trim [textForSvg::strictConvertTo $xmlData utf-8]]
    if {$xmlDataBinary ni {{} {<!-- empty pikchr diagram -->}}} {
        set svgBinaryString $xmlDataBinary
        image create photo img1 -data $xmlDataBinary
        set item [$cnv create image $xoff $yoff -image img1 -anchor nw]
        textForSvg::addText $xmlData $cnv $xoff $yoff 0
    }
    return
}


proc loadPackages {} {
    set err 0
    set missing {}
    foreach {pkg ver} {
        Tcl        8.6-
        Tk         8.6-
        htmlparse  {}
        Img        {}
        tdom       0.9
        tksvg      0.14
        textForSvg 1.0-
        base64     {}
    } {
        if {($::tk_version > 8.6) && ($pkg eq {tksvg})} {
            continue
        }
        if {$ver eq {}} {
            set blurb $pkg
        } else {
            set blurb "$pkg version $ver"
        }
        if {[catch {package require $pkg {*}$ver} res]} {
            append msg "$res\n"
            lappend missing $pkg
            set err 1
        } else {
            append msg "package $pkg version $res was successfully loaded\n"
        }
    }
    if {$err} {
        append msg "\nErrors with package(s) [join $missing {, }] - cannot continue."
        set msg [string trim $msg]

        after idle "[list .dlg.msg configure -font TkDefaultFont -wraplength 5i]
                    [list wm transient .dlg {}]
                    wm withdraw ."

        tk_dialog .dlg Packages $msg {} 0 OK
        destroy .dlg
        wm deiconify .
    }
    return $err
}

proc ReportError {msg} {
    after idle [list .dlg.msg configure -font TkDefaultFont -wraplength 5i -justify center]
    after idle [list wm transient .dlg .]
    after idle [list bind .dlg <Unmap> NoHide]
    tk_dialog .dlg Error $msg {} 0 OK
    destroy .dlg
    return
}

proc NoHide {} {
    set w .dlg
    if {    ([winfo ismapped .])
         && ([winfo exists $w])
         && (![winfo ismapped $w])
    } {
        wm deiconify $w
        focus -force [focus -lastfor $w]
    }
    return
}


proc mainScript {} {
    variable currentExample

    if {[loadPackages]} {
        exit
    }
    getInitConfigValues
    definePikchrExamples
    createMainGui
    createButtonBar
    mapGui
    createExamplesScreen
    createConfigScreen
    createAboutScreen
    clearDisplay
    markSelectedExample
    loadExample $currentExample

    update idletasks
    wm geometry . [wm geometry .]

    return
}

proc definePikchrExamples {} {
    variable examples
    variable totalExamples

    # In the text below, examples have \ at EOL doubled
    # so the characters are not consumed by Tcl.

    array unset examples

#indent-4
set examples(1) {
# pikchr.org file doc/homepage.md extract 01

arrow right 200% "Markdown" "Source"
box rad 10px "Markdown" "Formatter" "(markdown.c)" fit
arrow right 200% "HTML+SVG" "Output"
arrow <-> down 70% from last box.s
box same "Pikchr" "Formatter" "(pikchr.c)" fit
}
set examples(2) {
# pikchr.org file doc/boxobj.md extract 01

A: box thick
line thin color gray left 70% from 2mm left of A.nw
line same from 2mm left of A.sw
text "height" at (7/8<previous.start,previous.end>,1/2<1st line,2ndline>)
line thin color gray from previous text.n up until even with 1st line ->
line thin color gray from previous text.s down until even with 2nd line ->
X1: line thin color gray down 50% from 2mm below A.sw
X2: line thin color gray down 50% from 2mm below A.se
text "width" at (1/2<X1,X2>,6/8<X1.start,X1.end>)
line thin color gray from previous text.w left until even with X1 ->
line thin color gray from previous text.e right until even with X2 ->
}
set examples(3) {
# pikchr.org file doc/boxobj.md extract 02

A: box thick rad 0.3*boxht
line thin color gray left 70% from 2mm left of (A.w,A.n)
line same from 2mm left of (A.w,A.s)
text "height" at (7/8<previous.start,previous.end>,1/2<1st line,2ndline>)
line thin color gray from previous text.n up until even with 1st line ->
line thin color gray from previous text.s down until even with 2nd line ->
X1: line thin color gray down 50% from 2mm below (A.w,A.s)
X2: line thin color gray down 50% from 2mm below (A.e,A.s)
text "width" at (1/2<X1,X2>,6/8<X1.start,X1.end>)
line thin color gray from previous text.w left until even with X1 ->
line thin color gray from previous text.e right until even with X2 ->
X3: line thin color gray right 70% from 2mm right of (A.e,A.s)
X4: line thin color gray right 70% from A.rad above start of X3
text "radius" at (6/8<X4.start,X4.end>,1/2<X3,X4>)
line thin color gray from (previous,X3) down 30% <-
line thin color gray from (previous text,X4) up 30% <-
}
set examples(4) {
# pikchr.org file doc/boxobj.md extract 03

A: box thin
dot ".c" above at A
dot ".n" above at A.n
dot " .ne" ljust above at A.ne
dot " .e" ljust at A.e
dot " .se" ljust below at A.se
dot ".s" below at A.s
dot ".sw " rjust below at A.sw
dot ".w " rjust at A.w
dot ".nw " rjust above at A.nw

A: box thin at 2.0*boxwid right of previous box rad 15px
dot ".c" above at A
dot ".n" above at A.n
dot " .ne" ljust above at A.ne
dot " .e" ljust at A.e
dot " .se" ljust below at A.se
dot ".s" below at A.s
dot ".sw " rjust below at A.sw
dot ".w " rjust at A.w
dot ".nw " rjust above at A.nw
}
set examples(5) {
# pikchr.org file doc/chop.md extract 01

file "A"
cylinder "B" at 5cm heading 125 from A
arrow <-> from A to B "from A to B" aligned above color red
arrow <-> from A to B chop "from A to B chop" aligned below color blue
}
set examples(6) {
# pikchr.org file doc/circleobj.md extract 01

A: circle thick rad 120%
line thin color gray left 70% from 2mm left of (A.w,A.n)
line same from 2mm left of (A.w,A.s)
text "height" at (7/8<previous.start,previous.end>,1/2<1st line,2ndline>)
line thin color gray from previous text.n up until even with 1st line ->
line thin color gray from previous text.s down until even with 2nd line ->
X1: line thin color gray down 50% from 2mm below (A.w,A.s)
X2: line thin color gray down 50% from 2mm below (A.e,A.s)
text "width" at (1/2<X1,X2>,6/8<X1.start,X1.end>)
line thin color gray from previous text.w left until even with X1 ->
line thin color gray from previous text.e right until even with X2 ->
X3: line thin color gray right 70% from 2mm right of (A.e,A.s)
X4: line thin color gray right 70% from A.rad above start of X3
text "radius" at (6/8<X4.start,X4.end>,1/2<X3,X4>)
line thin color gray from (previous,X3) down 30% <-
line thin color gray from (previous text,X4) up 30% <-
line thin color gray <-> from A.sw to A.ne
line thin color gray from A.ne go 0.5*A.rad ne then 0.25*A.rad east
text " diameter" ljust at end of previous line
}
set examples(7) {
# pikchr.org file doc/circleobj.md extract 02

A: circle thin
dot ".c" above at A
dot ".n" above at A.n
dot " .ne" ljust above at A.ne
dot " .e" ljust at A.e
dot " .se" ljust below at A.se
dot ".s" below at A.s
dot ".sw " rjust below at A.sw
dot ".w " rjust at A.w
dot ".nw " rjust above at A.nw
}
set examples(8) {
# pikchr.org file doc/compassangle.md extract 01

C: dot
arrow up from C; text " 0&deg;"
arrow right from C; text "  90&deg;" rjust
arrow down from C; text "180&deg;" below
arrow left from C; text "270&deg;  " ljust
}
set examples(9) {
# pikchr.org file doc/cylinderobj.md extract 01

A: cylinder thick rad 150%
line thin color gray left 70% from 2mm left of (A.w,A.n)
line same from 2mm left of (A.w,A.s)
text "height" at (7/8<previous.start,previous.end>,1/2<1st line,2ndline>)
line thin color gray from previous text.n up until even with 1st line ->
line thin color gray from previous text.s down until even with 2nd line ->
X1: line thin color gray down 50% from 2mm below (A.w,A.s)
X2: line thin color gray down 50% from 2mm below (A.e,A.s)
text "width" at (1/2<X1,X2>,6/8<X1.start,X1.end>)
line thin color gray from previous text.w left until even with X1 ->
line thin color gray from previous text.e right until even with X2 ->
X3: line thin color gray right 70% from 2mm right of (A.e,A.ne)
X4: line thin color gray right 70% from A.rad below start of X3
text "radius" at (6/8<X4.start,X4.end>,1/2<X3,X4>)
line thin color gray from (previous,X4) down 30% <-
line thin color gray from (previous text,X3) up 30% <-
}
set examples(10) {
# pikchr.org file doc/cylinderobj.md extract 02

A: cylinder thin rad 80%
dot ".c" below at A
dot ".n" above at A.n
dot " .ne" ljust above at A.ne
dot " .e" ljust at A.e
dot " .se" ljust below at A.se
dot ".s" below at A.s
dot ".sw " rjust below at A.sw
dot ".w " rjust at A.w
dot ".nw " rjust above at A.nw
}
set examples(11) {
# pikchr.org file doc/diamondobj.md extract 01

D: diamond "Cardinal" "Points"
   dot ".n" above at D.n
   dot " .e" ljust at D.e
   dot ".s" below at D.s
   dot ".w " rjust at D.w
}
set examples(12) {
# pikchr.org file doc/diamondobj.md extract 02

box width 150% invis "“Diamond”" "Label"
line from last.w to last.n to last.e to last.s close
}
set examples(13) {
# pikchr.org file doc/diamondobj.md extract 03
# Deliberate Error: text overflow.

box invis "“Diamond”" "Label"
line from last.w to last.n to last.e to last.s close
}
set examples(14) {
# pikchr.org file doc/diamondobj.md extract 04

text "Unfitted:"
diamond "D"
text "Properly fitted:"
diamond "D" fit
text "Badly fitted:"
box invis "D" fit
line from last.w to last.n to last.e to last.s close
}
set examples(15) {
# pikchr.org file doc/diamondobj.md extract 05

D: diamond "Ordinal" "Points"
   dot " .ne" ljust above at D.ne
   dot " .se" ljust below at D.se
   dot ".sw " rjust below at D.sw
   dot ".nw " rjust above at D.nw
}
set examples(16) {
# pikchr.org file doc/diamondobj.md extract 06

D:  diamond thick "Diamond" "Dimensions" width 125% height 125%

X1: line thin color gray left 70% from 4mm left of (D.w,D.n)
X2: line same from 4mm left of (D.w,D.s)
    text "height" small at 1/2 way between X1 and X2
    line thin color gray from previous text.n up   until even with X1 ->
    line thin color gray from previous text.s down until even with X2 ->
X3: line thin color gray down 50% from 2mm below (D.w,D.s)
X4: line same from 2mm below (D.e,D.s)
    text "width" small at 1/2 way between X3 and X4
    line thin color gray from previous text.w left  until even with X3 ->
    line thin color gray from previous text.e right until even with X4 ->

    diamondht  *= 1.25
    diamondwid *= 1.25
    diamond thick "Diamond" "Dimensions" at 1.5in right of D
}
set examples(17) {
# pikchr.org file doc/differences.md extract 01

oval "oval"
move
diamond "diamond"
move
cylinder "cylinder"
move
file "file"
move
dot "  dot" ljust
}
set examples(18) {
# pikchr.org file doc/differences.md extract 02

box rad 15px "box" "radius 15px"
}
set examples(19) [UnguardBs {
# pikchr.org file doc/differences.md extract 03

arrow rad 10px go heading 30 then go 200% heading 175 \\
  then go 150% west "arrow" below "radius 10px" below
}]
set examples(20) {
# pikchr.org file doc/differences.md extract 04

boxrad = 12px
box color blue "color blue"
move
box fill lightgray "fill lightgray"
move
box color white fill blue "color white" "fill blue"
}
set examples(21) {
# pikchr.org file doc/differences.md extract 05

boxrad = 12px
box thin "thin"
move
box "(default)" italic
move
box thick "thick"
move
box thick thick "thick" "thick"
}
set examples(22) [UnguardBs {
# pikchr.org file doc/differences.md extract 06

box "bold" bold "italic" italic "big" big "small" small "monospace" mono fit
line from 1cm right of previous.se to 3cm right of previous.ne \\
   "aligned" above aligned
}]
set examples(23) {
# pikchr.org file doc/differences.md extract 07

box "default" italic "box" italic
move
box "width 150%" width 150%
move
box "wid 75%" wid 75%
}
set examples(24) {
# pikchr.org file doc/differences.md extract 08

file "A"
cylinder "B" at 5cm heading 125 from A
arrow <-> from A to B chop "from A to B chop" aligned above
}
set examples(25) {
# pikchr.org file doc/differences.md extract 09

box thick thick fill lightgray "box" "thick" "fill lightgray"
move
file same as last box "file" "same as" "last box" rad filerad
}
set examples(26) {
# pikchr.org file doc/ellipseobj.md extract 01

A: ellipse thick
line thin color gray left 70% from 2mm left of (A.w,A.n)
line same from 2mm left of (A.w,A.s)
text "height" at (7/8<previous.start,previous.end>,1/2<1st line,2ndline>)
line thin color gray from previous text.n up until even with 1st line ->
line thin color gray from previous text.s down until even with 2nd line ->
X1: line thin color gray down 50% from 2mm below (A.w,A.s)
X2: line thin color gray down 50% from 2mm below (A.e,A.s)
text "width" at (1/2<X1,X2>,6/8<X1.start,X1.end>)
line thin color gray from previous text.w left until even with X1 ->
line thin color gray from previous text.e right until even with X2 ->
}
set examples(27) {
# pikchr.org file doc/ellipseobj.md extract 02

A: ellipse thin
dot ".c" below at A
dot ".n" above at A.n
dot " .ne" ljust above at A.ne
dot " .e" ljust at A.e
dot " .se" ljust below at A.se
dot ".s" below at A.s
dot ".sw " rjust below at A.sw
dot ".w " rjust at A.w
dot ".nw " rjust above at A.nw
}
set examples(28) [UnguardBs {
# pikchr.org file doc/examples.md extract 01

box color red wid 2.6in \\
    "Click on any diagram on this page" big \\
    "to see the Pikchr source text" big
}]
set examples(29) [UnguardBs {
# pikchr.org file doc/differences.md extract 15

scale = 0.8
linewid *= 0.5
circle "C0" fit
circlerad = previous.radius
arrow
circle "C1"
arrow
circle "C2"
arrow
circle "C4"
arrow
circle "C6"
circle "C3" at dist(C2,C4) heading 30 from C2

d1 = dist(C2,C3.ne)+2mm
line thin color gray from d1 heading 30 from C2 \\
   to d1+1cm heading 30 from C2
line thin color gray from d1 heading 0 from C2 \\
   to d1+1cm heading 0 from C2
spline thin color gray <-> \\
   from d1+8mm heading 0 from C2 \\
   to d1+8mm heading 10 from C2 \\
   to d1+8mm heading 20 from C2 \\
   to d1+8mm heading 30 from C2 \\
   "30&deg;" aligned below small

X1: line thin color gray from circlerad+1mm heading 300 from C3 \\
        to circlerad+6mm heading 300 from C3
X2: line thin color gray from circlerad+1mm heading 300 from C2 \\
        to circlerad+6mm heading 300 from C2
line thin color gray <-> from X2 to X1 "distance" aligned above small \\
    "C2 to C4" aligned below small
}]
set examples(30) [UnguardBs {
# pikchr.org file doc/teardown01.md extract 02

linewid *= 0.5
circle "C0" fit
circlerad = previous.radius
arrow
circle "C1"
arrow
circle "C2"
arrow
circle "C4"
arrow
circle "C6"
circle "C3" at dist(C2,C4) heading 30 from C2

d1 = dist(C2,C3.ne)+2mm
line thin color gray from d1 heading 30 from C2 \\
   to d1+1cm heading 30 from C2
line thin color gray from d1 heading 0 from C2 \\
   to d1+1cm heading 0 from C2
spline thin color gray <-> \\
   from d1+8mm heading 0 from C2 \\
   to d1+8mm heading 10 from C2 \\
   to d1+8mm heading 20 from C2 \\
   to d1+8mm heading 30 from C2 \\
   "30&deg;" aligned below small

X1: line thin color gray from circlerad+1mm heading 300 from C3 \\
        to circlerad+6mm heading 300 from C3
X2: line thin color gray from circlerad+1mm heading 300 from C2 \\
        to circlerad+6mm heading 300 from C2
line thin color gray <-> from X2 to X1 "distance" aligned above small \\
    "C2 to C4" aligned below small
}]
set examples(31) [UnguardBs {
# pikchr.org file tests/test54.pikchr

margin = 4mm
All: [
file thick thick fill lightgray \\
   "wide-file" "test 1" "abcde" "uvwxyz" "bottom" fit
move
cylinder thick thick fill lightgray "cylinder" "test 1" fit
move
diamond thick thick fill lightgray "wide-diamond" "test 1" "abcde" "uvwxyz" \\
     "bottom" fit
]
text "Fit &amp; Background for" "File, Cylinder, and Diamond" \\
   with .s at .2 above All.n
}]
set examples(32) {
# pikchr.org file fuzzcases/monospace.pikchr

box "monospace" monospace fit
}
set examples(33) [UnguardBs {
# pikchr.org file doc/examples.md extract 06

scale = 0.8
fill = white
linewid *= 0.5
circle "C0" fit
circlerad = previous.radius
arrow
circle "C1"
arrow
circle "C2"
arrow
circle "C4"
arrow
circle "C6"
circle "C3" at dist(C2,C4) heading 30 from C2
arrow
circle "C5"
arrow from C2 to C3 chop
C3P: circle "C3'" at dist(C4,C6) heading 30 from C6
arrow right from C3P.e
C5P: circle "C5'"
arrow from C6 to C3P chop

box height C3.y-C2.y \\
    width (C5P.e.x-C0.w.x)+linewid \\
    with .w at 0.5*linewid west of C0.w \\
    behind C0 \\
    fill 0xc6e2ff thin color gray
box same width previous.e.x - C2.w.x \\
    with .se at previous.ne \\
    fill 0x9accfc
"trunk" below at 2nd last box.s
"feature branch" above at last box.n

circle "C0" at 3.7cm south of C0
arrow
circle "C1"
arrow
circle "C2"
arrow
circle "C4"
arrow
circle "C6"
circle "C3" at dist(C2,C4) heading 30 from C2
arrow
circle "C5"
arrow
circle "C7"
arrow from C2 to C3 chop
arrow from C6 to C7 chop

box height C3.y-C2.y \\
    width (C7.e.x-C0.w.x)+1.5*C1.radius \\
    with .w at 0.5*linewid west of C0.w \\
    behind C0 \\
    fill 0xc6e2ff thin color gray
box same width previous.e.x - C2.w.x \\
    with .se at previous.ne \\
    fill 0x9accfc
"trunk" below at 2nd last box.s
"feature branch" above at last box.n
}]
set examples(34) {
# pikchr.org file tests/test40.pikchr

$one = 1.0
$one += 2.0
$two = $one
$two *= 3.0
print $one, $two
$three -= 11
$three /= 2
print $three
box "should be..." italic "3 9" bold "-5.5" bold fit
}
set examples(35) [UnguardBs {
# pikchr.org file doc/examples.md extract 10

        circle "DISK"
        arrow "character" "defns" right 150%
CPU:    box "CPU" "(16-bit mini)"
        arrow <- from top of CPU up "input " rjust
        move right from CPU.e
CRT:    "   CRT" ljust
        line from CRT - 0,0.075 up 0.15 \\
                then right 0.5 \\
                then right 0.5 up 0.25 \\
                then down 0.5+0.15 \\
                then left 0.5 up 0.25 \\
                then left 0.5
        arrow from CPU.e right until even with previous.start
Paper:  CRT + 1.05,0.75
        arrow <- from Paper down 1.5
        " ...  paper" ljust at end of last arrow + 0, 0.25
        circle rad 0.05 at Paper + (-0.055, -0.25)
        circle rad 0.05 at Paper + (0.055, -0.25)
        "   rollers" ljust at Paper + (0.1, -0.25)
}]
set examples(36) {
# pikchr.org file doc/fileobj.md extract 01

A: file thick rad 100%
line thin color gray left 70% from 2mm left of (A.w,A.n)
line same from 2mm left of (A.w,A.s)
text "height" at (7/8<previous.start,previous.end>,1/2<1st line,2ndline>)
line thin color gray from previous text.n up until even with 1st line ->
line thin color gray from previous text.s down until even with 2nd line ->
X1: line thin color gray down 50% from 2mm below (A.w,A.s)
X2: line thin color gray down 50% from 2mm below (A.e,A.s)
text "width" at (1/2<X1,X2>,6/8<X1.start,X1.end>)
line thin color gray from previous text.w left until even with X1 ->
line thin color gray from previous text.e right until even with X2 ->
X3: line thin color gray right 70% from 2mm right of (A.e,A.n)
X4: line thin color gray right 70% from A.rad below start of X3
text "radius" at (6/8<X4.start,X4.end>,1/2<X3,X4>)
line thin color gray from (previous,X4) down 30% <-
line thin color gray from (previous text,X3) up 30% <-
}
set examples(37) {
# pikchr.org file doc/fileobj.md extract 02

A: file thin rad 80%
dot ".c" below at A
dot ".n" above at A.n
dot " .ne" ljust above at A.ne
dot " .e" ljust at A.e
dot " .se" ljust below at A.se
dot ".s" below at A.s
dot ".sw " rjust below at A.sw
dot ".w " rjust at A.w
dot ".nw " rjust above at A.nw
}
set examples(38) {
# pikchr.org file doc/fit.md extract 01

box "with" "\"fit\"" fit
move
box "without" "\"fit\""
}
set examples(39) [UnguardBs {
# pikchr.org file doc/examples.md extract 02

            filewid *= 1.2
  Src:      file "pikchr.y"; move
  LemonSrc: file "lemon.c"; move
  Lempar:   file "lempar.c"; move
            arrow down from LemonSrc.s
  CC1:      oval "C-Compiler" ht 50%
            arrow " generates" ljust above
  Lemon:    oval "lemon" ht 50%
            arrow from Src chop down until even with CC1 \\
              then to Lemon.nw rad 20px
            "Pikchr source " rjust "code input " rjust \\
              at 2nd vertex of previous
            arrow from Lempar chop down until even with CC1 \\
              then to Lemon.ne rad 20px
            " parser template" ljust " resource file" ljust \\
              at 2nd vertex of previous
  PikSrc:   file "pikchr.c" with .n at lineht below Lemon.s
            arrow from Lemon to PikSrc chop
            arrow down from PikSrc.s
  CC2:      oval "C-Compiler" ht 50%
            arrow
  Out:      file "pikchr.o" "or" "pikchr.exe" wid 110%
}]
set examples(40) [UnguardBs {
# pikchr.org file doc/build.md extract 01

            filewid *= 1.2
  Src:      file "pikchr.y"; move
  LemonSrc: file "lemon.c"; move
  Lempar:   file "lempar.c"; move
            arrow down from LemonSrc.s
  CC1:      oval "C-Compiler" ht 50%
            arrow " generates" ljust above
  Lemon:    oval "lemon" ht 50%
            arrow from Src chop down until even with CC1 \\
              then to Lemon.nw rad 10px
            "Pikchr source " rjust "code input " rjust \\
              at 2nd vertex of previous
            arrow from Lempar chop down until even with CC1 \\
              then to Lemon.ne rad 10px
            " parser" ljust " template" ljust \\
              at 2nd vertex of previous
  PikSrc:   file "pikchr.c" with .n at lineht below Lemon.s
            arrow from Lemon to PikSrc chop
            arrow down from PikSrc.s
  CC2:      oval "C-Compiler" ht 50%
            arrow
  Out:      file "pikchr.o" "or" "pikchr.exe" wid 110%
            spline <- from 1mm west of Src.w go 60% heading 250 \\
               then go 40% heading 45 then go 60% heading 250 \\
               thin color gray
            box invis "Canonical" ljust small "Source code" ljust small fit \\
               with .e at end of last spline width 90%
            spline <- from 1mm west of PikSrc.w go 60% heading 250 \\
               then go 40% heading 45 then go 60% heading 250 \\
               thin color gray
            box invis "Generated" ljust small \\
              "C-code" ljust small fit \\
               with .e at end of last spline width 90%
}]
set examples(41) [UnguardBs {
# pikchr.org file examples/swimlane.pikchr

# demo label: Swimlanes
    $laneh = 0.75

    # Draw the lanes
    down
    box width 3.5in height $laneh fill 0xacc9e3
    box same fill 0xc5d8ef
    box same as first box
    box same as 2nd box
    line from 1st box.sw+(0.2,0) up until even with 1st box.n \\
      "Alan" above aligned
    line from 2nd box.sw+(0.2,0) up until even with 2nd box.n \\
      "Betty" above aligned
    line from 3rd box.sw+(0.2,0) up until even with 3rd box.n \\
      "Charlie" above aligned
    line from 4th box.sw+(0.2,0) up until even with 4th box.n \\
       "Darlene" above aligned

    # fill in content for the Alice lane
    right
A1: circle rad 0.1in at end of first line + (0.2,-0.2) \\
       fill white thickness 1.5px "1" 
    arrow right 50%
    circle same "2"
    arrow right until even with first box.e - (0.65,0.0)
    ellipse "future" fit fill white height 0.2 width 0.5 thickness 1.5px
A3: circle same at A1+(0.8,-0.3) "3" fill 0xc0c0c0
    arrow from A1 to last circle chop "fork!" below aligned

    # content for the Betty lane
B1: circle same as A1 at A1-(0,$laneh) "1"
    arrow right 50%
    circle same "2"
    arrow right until even with first ellipse.w
    ellipse same "future"
B3: circle same at A3-(0,$laneh) "3"
    arrow right 50%
    circle same as A3 "4"
    arrow from B1 to 2nd last circle chop

    # content for the Charlie lane
C1: circle same as A1 at B1-(0,$laneh) "1"
    arrow 50%
    circle same "2"
    arrow right 0.8in "goes" "offline"
C5: circle same as A3 "5"
    arrow right until even with first ellipse.w \\
      "back online" above "pushes 5" below "pulls 3 &amp; 4" below
    ellipse same "future"

    # content for the Darlene lane
D1: circle same as A1 at C1-(0,$laneh) "1"
    arrow 50%
    circle same "2"
    arrow right until even with C5.w
    circle same "5"
    arrow 50%
    circle same as A3 "6"
    arrow right until even with first ellipse.w
    ellipse same "future"
D3: circle same as B3 at B3-(0,2*$laneh) "3"
    arrow 50%
    circle same "4"
    arrow from D1 to D3 chop
}]
set examples(42) {
# pikchr.org file doc/numprop.md extract 01

box "radius 0"
move
box "radius 5px" rad 5px
move
box "radius 20px" rad 20px
}
set examples(43) {
# pikchr.org file doc/numprop.md extract 02

C: cylinder
line thin left from C.nw - (2mm,0)
line thin left from C.nw - (2mm,C.radius)
arrow <- from 3/4<first line.start,first line.end> up 30%
arrow <- from 3/4<2nd line.start,2nd line.end> down 30%
text "radius" above at end of 1st arrow
}
set examples(44) {
# pikchr.org file doc/numprop.md extract 03

cylinder "radius 50%" rad 50%
move
cylinder "radius 100%" rad 100%
move
cylinder "radius 200%" "height 200%" rad 200% ht 200%
}
set examples(45) {
# pikchr.org file doc/numprop.md extract 04

F: file
line thin from 2mm right of (F.e,F.n) right 75%
line thin from F.rad below start of previous right 75%
arrow <- from 3/4<first line.start,first line.end> up 30%
arrow <- from 3/4<2nd line.start,2nd line.end> down 30%
text "radius" above at end of 1st arrow
}
set examples(46) [UnguardBs {
# pikchr.org file doc/numprop.md extract 05

line go 2cm heading 40 then 4cm heading 165 then 1cm heading 280\\
   "radius" "0"
move to 3cm right of previous.start
line same "radius" "15px" rad 15px
move to 3cm right of previous.start
line same  "radius" "30px" rad 30px
}]
set examples(47) {
# pikchr.org file doc/ovalobj.md extract 01

A: oval thick
X0: line thin color gray left 70% from 2mm left of (A.w,A.n)
X1: line same from 2mm left of (A.w,A.s)
text "height" at (7/8<previous.start,previous.end>,1/2<X0,X1>)
line thin color gray from previous text.n up until even with X0 ->
line thin color gray from previous text.s down until even with X1 ->
X2: line thin color gray down 50% from 2mm below (A.w,A.s)
X3: line thin color gray down 50% from 2mm below (A.e,A.s)
text "width" at (1/2<X2,X3>,6/8<X2.start,X2.end>)
line thin color gray from previous text.w left until even with X2 ->
line thin color gray from previous text.e right until even with X3 ->

A: oval thick wid A.ht ht A.wid at 2.0*A.wid right of A
X0: line thin color gray left 70% from 2mm left of (A.w,A.n)
X1: line same from 2mm left of (A.w,A.s)
text "height" at (7/8<previous.start,previous.end>,1/2<X0,X1>)
line thin color gray from previous text.n up until even with X0 ->
line thin color gray from previous text.s down until even with X1 ->
X2: line thin color gray down 50% from 2mm below (A.w,A.s)
X3: line thin color gray down 50% from 2mm below (A.e,A.s)
text "width" at (1/2<X2,X3>,6/8<X2.start,X2.end>)
line thin color gray from previous text.w left until even with X2 ->
line thin color gray from previous text.e right until even with X3 ->
}
set examples(48) {
# pikchr.org file doc/ovalobj.md extract 02

A: oval thin
dot ".c" below at A
dot ".n" above at A.n
dot " .ne" ljust above at A.ne
dot " .e" ljust at A.e
dot " .se" ljust below at A.se
dot ".s" below at A.s
dot ".sw " rjust below at A.sw
dot ".w " rjust at A.w
dot ".nw " rjust above at A.nw

A: oval thin  wid A.ht ht A.wid at 2.0*A.wid right of A
dot ".c" below at A
dot ".n" above at A.n
dot " .ne" ljust above at A.ne
dot " .e" ljust at A.e
dot " .se" ljust below at A.se
dot ".s" below at A.s
dot ".sw " rjust below at A.sw
dot ".w " rjust at A.w
dot ".nw " rjust above at A.nw
}
set examples(49) [UnguardBs {
# pikchr.org file doc/pathattr.md extract 01

leftmargin = 1cm
A1: arrow thick right 4cm up 3cm
dot at A1.start
X1: line thin color gray from (0,-3mm) down 0.4cm
X2: line same from (4cm,-3mm) down 0.4cm
arrow thin color gray from X1 to X2 "4cm" above
X3: line same from (4cm+3mm,0) right 0.4cm
X4: line same from (4cm+3mm,3cm) right .4cm
arrow thin color gray from X3 to X4 "3cm" aligned above
X5: line same from A1.start go 4mm heading 90+53.13010235
X6: line same from A1.end go 4mm heading 90+53.13010235
arrow thin color gray from X5 to X6 "5cm" below aligned
line same from (0,1cm) up 1cm
spline -> from 1.5cm heading 0 from A1.start \\
   to 1.5cm heading 10 from A1.start \\
   to 1.5cm heading 20 from A1.start \\
   to 1.5cm heading 30 from A1.start \\
   to 1.5cm heading 40 from A1.start \\
   to 1.5cm heading 53.13 from A1.start \\
   thin color gray "53.13&deg;" aligned center small
}]
set examples(50) {
# pikchr.org file doc/pathattr.md extract 02

leftmargin = 1cm
A1: arrow thick right 4cm then up 3cm
dot at A1.start
X1: line thin color gray from (0,-3mm) down 0.4cm
X2: line same from (4cm,-3mm) down 0.4cm
arrow thin color gray from X1 to X2 "4cm" above
X3: line same from (4cm+3mm,0) right 0.4cm
X4: line same from (4cm+3mm,3cm) right .4cm
arrow thin color gray from X3 to X4 "3cm" aligned above
}
set examples(51) {
# pikchr.org file doc/pathattr.md extract 03

box "Origin"
Obstacle: oval ht 300% wid 30% with .n at linewid right of Origin.ne;
box "Destination" with .nw at linewid right of Obstacle.n
line invis from 1st oval.s to 1st oval.n "Obstacle" aligned
}
set examples(52) [UnguardBs {
# pikchr.org file doc/pathattr.md extract 05

box "Origin"
Obstacle: oval ht 300% wid 30% with .n at linewid right of Origin.ne;
box "Destination" with .nw at linewid right of Obstacle.n
line invis from 1st oval.s to 1st oval.n "Obstacle" aligned
X: \\
   arrow from Origin.s \\
      down until even with 1cm below Obstacle.s \\
      then right until even with Destination.s \\
      then to Destination.s

line invis color gray from X.start to 2nd vertex of X \\
    "down until even with" aligned small \\
    "1cm below Obstacle.s" aligned small
line invis color gray from 2nd vertex of X to 3rd vertex of X \\
    "right until even with Destination.s" aligned small above
line invis color gray from 3rd vertex of X to 4th vertex of X \\
    "to Destination.s" aligned small above

# Evidence that the alternative arrow is equivalent:
assert( 2nd vertex of X == (Origin.s, 1cm below Obstacle.s) )
assert( 3rd vertex of X == (Destination.s, 1cm below Obstacle.s) )
}]
set examples(53) [UnguardBs {
# pikchr.org file doc/pathattr.md extract 07

line right 2cm then down .5cm then up 1cm right 1cm \\
   then up 1cm left 1cm then down .5cm then left 2cm \\
   close "with 'close'"
dot color red at last line.end

move to 2.5cm south of last line.start
line right 2cm then down .5cm then up 1cm right 1cm \\
   then up 1cm left 1cm then down .5cm then left 2cm \\
   then down 1cm "without 'close'"
dot color red at last line.end
}]
set examples(54) {
# pikchr.org file doc/place.md extract 01

B: box thick thick color blue

circle ".n" fit at 1.5cm heading 0 from B.n
    arrow thin from previous to B.n chop
circle ".north" fit at 3cm heading 15 from B.north
    arrow thin from previous to B.north chop
circle ".t" fit at 1.5cm heading 30 from B.t
    arrow thin from previous to B.t chop
circle ".top" fit at 3cm heading -15 from B.top
    arrow thin from previous to B.top chop
circle ".ne" fit at 1cm ne of B.ne; arrow thin from previous to B.ne chop
circle ".e" fit at 2cm heading 50 from B.e; arrow thin from previous to B.e chop
circle ".right" fit at 3cm heading 75 from B.right
    arrow thin from previous to B.right chop
circle ".end&sup1;" fit at 3cm heading 100 from B.end
    arrow thin from previous to B.end chop
circle ".se" fit at 1cm heading 110 from B.se
    arrow thin from previous to B.se chop
circle ".s" fit at 1.5cm heading 180 from B.s
    arrow thin from previous to B.s chop
circle ".south" fit at 3cm heading 195 from B.south
    arrow thin from previous to B.south chop
circle ".bot" fit at 1.8cm heading 215 from B.bot
    arrow thin from previous to B.bot chop
circle ".bottom" fit at 2.7cm heading 160 from B.bottom
    arrow thin from previous to B.bottom chop
circle ".sw" fit at 1cm sw of B.sw; arrow thin from previous to B.sw chop
circle ".w" fit at 2cm heading 270 from B.w
    arrow thin from previous to B.w chop
circle ".left" fit at 3cm heading 180+75 from B.left
    arrow thin from previous to B.left chop
circle ".start&sup1;" fit at 2.5cm heading 295 from B.start
    arrow thin from previous to B.start chop
circle ".nw" fit at 1cm nw of B.nw; arrow thin from previous to B.nw chop
circle ".c" fit at 2.5cm heading -25 from B.c
    line thin from previous to 0.5<previous,B.c> chop
    arrow thin from previous.end to B.c
circle ".center" fit at 3.6cm heading 180-44 from B.center
    line thin from previous to 0.5<previous,B.center> chop
    arrow thin from previous.end to B.center
circle "&lambda;" fit at 2.5cm heading 250 from B
    line from previous to 0.5<previous,B> chop
    arrow thin from previous.end to B
}
set examples(55) {
# pikchr.org file doc/place.md extract 02

B: ellipse thick thick color blue

circle ".n" fit at 1.5cm heading 0 from B.n
    arrow thin from previous to B.n chop
circle ".north" fit at 3cm heading 15 from B.north
    arrow thin from previous to B.north chop
circle ".t" fit at 1.5cm heading 30 from B.t
    arrow thin from previous to B.t chop
circle ".top" fit at 3cm heading -15 from B.top
    arrow thin from previous to B.top chop
circle ".ne" fit at 1cm ne of B.ne; arrow thin from previous to B.ne chop
circle ".e" fit at 2cm heading 50 from B.e; arrow thin from previous to B.e chop
circle ".right" fit at 3cm heading 75 from B.right
    arrow thin from previous to B.right chop
circle ".end&sup1;" fit at 3cm heading 100 from B.end
    arrow thin from previous to B.end chop
circle ".se" fit at 1cm heading 110 from B.se
    arrow thin from previous to B.se chop
circle ".s" fit at 1.5cm heading 180 from B.s
    arrow thin from previous to B.s chop
circle ".south" fit at 3cm heading 195 from B.south
    arrow thin from previous to B.south chop
circle ".bot" fit at 1.8cm heading 215 from B.bot
    arrow thin from previous to B.bot chop
circle ".bottom" fit at 2.7cm heading 160 from B.bottom
    arrow thin from previous to B.bottom chop
circle ".sw" fit at 1cm sw of B.sw; arrow thin from previous to B.sw chop
circle ".w" fit at 2cm heading 270 from B.w
    arrow thin from previous to B.w chop
circle ".left" fit at 3cm heading 180+75 from B.left
    arrow thin from previous to B.left chop
circle ".start&sup1;" fit at 2.5cm heading 295 from B.start
    arrow thin from previous to B.start chop
circle ".nw" fit at 1cm nw of B.nw; arrow thin from previous to B.nw chop
circle ".c" fit at 2.5cm heading -25 from B.c
    line thin from previous to 0.5<previous,B.c> chop
    arrow thin from previous.end to B.c
circle ".center" fit at 3.6cm heading 180-44 from B.center
    line thin from previous to 0.5<previous,B.center> chop
    arrow thin from previous.end to B.center
circle "&lambda;" fit at 2.5cm heading 250 from B
    line from previous to 0.5<previous,B> chop
    arrow thin from previous.end to B
}
set examples(56) [UnguardBs {
# pikchr.org file doc/place.md extract 03

B: line thick thick color blue go 0.8 heading 350 then go 0.4 heading 120 \\
    then go 0.5 heading 35 \\
    then go 1.2 heading 190  then go 0.4 heading 340 "+"

   line thin dashed color gray from B.nw to B.ne to B.se to B.sw close

circle ".n" fit at 1.5cm heading 0 from B.n
    arrow thin from previous to B.n chop
circle ".north" fit at 3cm heading 15 from B.north
    arrow thin from previous to B.north chop
circle ".t" fit at 1.5cm heading 30 from B.t
    arrow thin from previous to B.t chop
circle ".top" fit at 3cm heading -15 from B.top
    arrow thin from previous to B.top chop
circle ".ne" fit at 1cm ne of B.ne; arrow thin from previous to B.ne chop
circle ".e" fit at 2cm heading 50 from B.e; arrow thin from previous to B.e chop
circle ".right" fit at 3cm heading 75 from B.right
    arrow thin from previous to B.right chop
circle ".end" fit at 2cm heading 120 from B.end
    arrow thin from previous to B.end chop
circle ".se" fit at 1cm heading 170 from B.se
    arrow thin from previous to B.se chop
circle ".s" fit at 1.5cm heading 180 from B.s
    arrow thin from previous to B.s chop
circle ".south" fit at 3cm heading 195 from B.south
    arrow thin from previous to B.south chop
circle ".bot" fit at 1.8cm heading 215 from B.bot
    arrow thin from previous to B.bot chop
circle ".bottom" fit at 2.7cm heading 160 from B.bottom
    arrow thin from previous to B.bottom chop
circle ".sw" fit at 1cm sw of B.sw; arrow thin from previous to B.sw chop
circle ".w" fit at 2cm heading 300 from B.w
    arrow thin from previous to B.w chop
circle ".left" fit at 3cm heading 280 from B.left
    arrow thin from previous to B.left chop
circle ".start" fit at 2.5cm heading 265 from B.start
    arrow thin from previous to B.start chop
circle ".nw" fit at 1cm nw of B.nw; arrow thin from previous to B.nw chop
circle ".c" fit at 2.5cm heading -15 from B.c
    line thin from previous to 0.5<previous,B.c> chop
    arrow thin from previous.end to B.c
circle ".center" fit at 3.3cm heading 110 from B.center
    line thin from previous to 0.5<previous,B.center> chop
    arrow thin from previous.end to B.center
circle "&lambda;" fit at 1.7cm heading 250 from B
    line from previous to 0.5<previous,B> chop
    arrow thin from previous.end to B
}]
set examples(57) [UnguardBs {
# pikchr.org file doc/place.md extract 04

B: line -> thick color blue go 0.8 heading 350 then go 0.4 heading 120 \\
    then go 0.5 heading 35 \\
    then go 1.2 heading 190  then go 0.4 heading 340

oval "1st vertex" fit at 2cm heading 250 from 1st vertex of B
    arrow thin from previous to 1st vertex of B chop
oval "2nd vertex" fit at 2cm west of 2nd vertex of B
    arrow thin from previous to 2nd vertex of B chop
oval "3rd vertex" fit at 2cm north of 3rd vertex of B
    arrow thin from previous to 3rd vertex of B chop
oval "4th vertex" fit at 2cm east of 4th vertex of B
    arrow thin from previous to 4th vertex of B chop
oval "5th vertex" fit at 2cm east of 5th vertex of B
    arrow thin from previous to 5th vertex of B chop
oval "6th vertex" fit at 2cm heading 200 from 6th vertex of B
    arrow thin from previous to 6th vertex of B chop
}]
set examples(58) {
# pikchr.org file doc/position.md extract 01

leftmargin = 1cm;
P1: dot; text "P1" with .s at 2mm above P1
P2: dot at P1+(2cm,-2cm); text "P2" with .s at 2mm above P2
dot at (P1,P2); text "(P1,P2)" with .s at 2mm above last dot
dot at (P2,P1); text "(P2,P1)" with .s at 2mm above last dot
}
set examples(59) {
# pikchr.org file doc/position.md extract 02

P1: dot; text "P1" with .s at 2mm above P1
P2: dot at P1+(4cm,1.5cm); text "P2" with .s at 2mm above P2
line thin color gray dotted from -.5<P1,P2> to 1.5<P1,P2>
dot at 3/4<P1,P2>; text "3/4<P1,P2>" at (last dot,P1)
   arrow thin color gray from last text.n to 1mm south of last dot
dot at -0.25 of the way between P1 and P2
   text "-0.25 of the way between P1 and P2" at (last dot,P2)
   arrow thin color gray from last text.s to 1mm north of last dot
}
set examples(60) {
# pikchr.org file doc/stmt.md extract 01

/* 01 */        down
/* 02 */  Root: dot "First \"Root\"" above color red
/* 03 */        circle wid 50% at Root + (1.5cm, -1.5cm)
/* 04 */        arrow dashed from previous to Root chop
/* 05 */  Root: 3cm right of Root   // Move the location of Root 3cm right
/* 06 */        arrow from last circle to Root chop
/* 07 */        dot "Second \"Root\"" above color blue at Root
}
set examples(61) {
# pikchr.org file doc/stmt.md extract 03

   box "Normal"
   move
   box "Double" "Thick" thickness 2*(thickness)
}
set examples(62) {
# pikchr.org file doc/stmt.md extract 04

   oval "Hello, World!" fit
   print "Oval at: ",previous.x, ",", previous.y
   line
   oval "2nd oval" fit
   print "2nd oval at: ",previous.x, ",", previous.y
}
set examples(63) [UnguardBs {
# pikchr.org file tests/narrow.pikchr

stickwidth=.045
box height 1 width stickwidth fill 0xC89DC7
move width stickwidth
box height 1 width stickwidth fill 0x9FAAD2
move width stickwidth
box height 1 width stickwidth fill 0x72B6C0
move width stickwidth
box height 1 width stickwidth fill 0x77B89D
move width stickwidth
box height 1 width stickwidth fill 0xA0B280
move width stickwidth
box height 1 width stickwidth fill 0xC5A685
move width stickwidth
box height 1 width stickwidth fill 0xD59CA7
move same
line <-
move same
box "Lines should all be" ljust \\
     "the same width." ljust \\
     "No round-off errors." ljust fit thickness 0
}]
set examples(64) {
# pikchr.org file doc/homepage.md extract 02
# Same as example 001.

   arrow right 200% "Markdown" "Source"
   box rad 10px "Markdown" "Formatter" "(markdown.c)" fit
   arrow right 200% "HTML+SVG" "Output"
   arrow <-> down 70% from last box.s
   box same "Pikchr" "Formatter" "(pikchr.c)" fit
}
set examples(65) {
# pikchr.org file doc/textattr.md extract 01

  line "on the line" wid 150%
}
set examples(66) {
# pikchr.org file doc/textattr.md extract 02

  line "above" above; move; line "below" below
}
set examples(67) {
# pikchr.org file doc/textattr.md extract 03

  line wid 300% "text without \"above\"" "text without \"below\""
}
set examples(68) {
# pikchr.org file doc/textattr.md extract 04

  line width 200% "first above" above "second above" above
  move
  line same "first below" below "second below" below
}
set examples(69) {
# pikchr.org file doc/textattr.md extract 05

   line wid 200% "ljust" ljust above "rjust" rjust below
   dot color red at previous.c
}
set examples(70) {
# pikchr.org file doc/textattr.md extract 06

   box "ljust" ljust "longer line" ljust "even longer line" ljust fit
   move
   box "rjust" rjust "longer line" rjust "even longer line" rjust fit
}
set examples(71) [UnguardBs {
# pikchr.org file doc/textattr.md extract 07

  box wid 300% \\
     "above-ljust" above ljust \\
     "above-rjust" above rjust \\
     "centered" center \\
     "below-ljust" below ljust \\
     "below-rjust" below rjust
}]
set examples(72) {
# pikchr.org file doc/textattr.md extract 08

  box "bold" bold "italic" italic "bold-italic" bold italic fit
}
set examples(73) {
# pikchr.org file doc/textattr.md extract 09

  box "monospace" monospace fit
}
set examples(74) {
# pikchr.org file doc/textattr.md extract 10

  arrow go 150% heading 30 "aligned" aligned above
  move to 1cm east of previous.end
  arrow go 150% heading 170 "aligned" aligned above
  move to 1cm east of previous.end
  arrow go 150% north "aligned" aligned above
}
set examples(75) {
# pikchr.org file doc/textattr.md extract 11

  box ht 200% wid 50%
  line invis from previous.s to previous.n "rotated text" aligned
}
set examples(76) [UnguardBs {
# pikchr.org file doc/textattr.md extract 12

  box "small small" small small "small" small \\
    "(normal)" italic \\
    "big" big "big big" big big ht 200%
}]
set examples(77) {
# pikchr.org file doc/usepikchr.md extract 03

arrow; box "Hello!"; arrow
}
set examples(78) {
# pikchr.org file doc/usepikchr.md extract 05

arrow; box "Hello" "again"; arrow <-
}
set examples(79) {
# pikchr.org file doc/usepikchr.md extract 06

arrow ->; box "Click to" "toggle"; arrow <-
}
set examples(80) {
# pikchr.org file doc/usepikchr.md extract 07

arrow ->; box "Click to" "toggle" "(centered)"; arrow <-
}
set examples(81) {
# pikchr.org file doc/usepikchr.md extract 09

arrow; ellipse "Hi, Y'all"; arrow
}
set examples(82) {
# pikchr.org file doc/userman.md extract 01

     line; box "Hello," "World!"; arrow
}
set examples(83) [UnguardBs {
# pikchr.org file examples/headings01.pikchr

# demo label: Cardinal headings
   linerad = 5px
C: circle "Center" rad 150%
   circle "N"  at 1.0 n  of C; arrow from C to last chop ->
   circle "NE" at 1.0 ne of C; arrow from C to last chop <-
   circle "E"  at 1.0 e  of C; arrow from C to last chop <->
   circle "SE" at 1.0 se of C; arrow from C to last chop ->
   circle "S"  at 1.0 s  of C; arrow from C to last chop <-
   circle "SW" at 1.0 sw of C; arrow from C to last chop <->
   circle "W"  at 1.0 w  of C; arrow from C to last chop ->
   circle "NW" at 1.0 nw of C; arrow from C to last chop <-
   arrow from 2nd circle to 3rd circle chop
   arrow from 4th circle to 3rd circle chop
   arrow from SW to S chop <->
   circle "ESE" at 2.0 heading 112.5 from Center \\
      thickness 150% fill lightblue radius 75%
   arrow from Center to ESE thickness 150% <-> chop
   arrow from ESE up 1.35 then to NE chop
   line dashed <- from E.e to (ESE.x,E.y)
   line dotted <-> thickness 50% from N to NW chop
}]
set examples(84) {
# pikchr.org file doc/userman.md extract 07

    down
    line
    box  "Hello,"  "World!"
    arrow
}
set examples(85) {
# pikchr.org file doc/userman.md extract 08

    left
    line
    box  "Hello,"  "World!"
    arrow
}
set examples(86) {
# pikchr.org file doc/userman.md extract 09

    up
    line
    box  "Hello,"  "World!"
    arrow
}
set examples(87) {
# pikchr.org file doc/userman.md extract 17

A: box
dot color red at A.nw ".nw " rjust above
dot same at A.w ".w " rjust
dot same at A.sw ".sw " rjust below
dot same at A.s ".s" below
dot same at A.se " .se" ljust below
dot same at A.e " .e" ljust
dot same at A.ne " .ne" ljust above
dot same at A.n ".n" above
dot same at A.c " .c" ljust
A: circle at 1.5 right of A
dot color red at A.nw ".nw " rjust above
dot same at A.w ".w " rjust
dot same at A.sw ".sw " rjust below
dot same at A.s ".s" below
dot same at A.se " .se" ljust below
dot same at A.e " .e" ljust
dot same at A.ne " .ne" ljust above
dot same at A.n ".n" above
dot same at A.c " .c" ljust
A: cylinder at 1.5 right of A
dot color red at A.nw ".nw " rjust above
dot same at A.w ".w " rjust
dot same at A.sw ".sw " rjust below
dot same at A.s ".s" below
dot same at A.se " .se" ljust below
dot same at A.e " .e" ljust
dot same at A.ne " .ne" ljust above
dot same at A.n ".n" above
dot same at A.c " .c" ljust
}
set examples(88) [UnguardBs {
# pikchr.org file doc/userman.md extract 22

  B1: box
      circle at 2cm right of B1

  X1: line thin color gray down 50% from 2mm south of B1.s
  X2: line same from (last circle.s,X1.start)
      arrow <-> thin from 3/4<X1.start,X1.end> right until even with X2 \\
         "2cm" above color gray
      assert( last arrow.width == 2cm )
}]
set examples(89) [UnguardBs {
# pikchr.org file doc/userman.md extract 24

  B1: box
  C1: circle with .w at 2cm right of B1.e

  X1: line thin color gray down 50% from 2mm south of B1.se
  X2: line same from (C1.w,X1.start)
      arrow <-> thin from 3/4<X1.start,X1.end> right until even with X2 \\
         "2cm" above color gray
      assert( last arrow.width == 2cm )
}]
set examples(90) {
# pikchr.org file doc/userman.md extract 36

A: box thick
line thin color gray left 70% from 2mm left of A.nw
line same from 2mm left of A.sw
text "height" at (7/8<previous.start,previous.end>,1/2<1st line,2ndline>)
line thin color gray from previous text.n up until even with 1st line ->
line thin color gray from previous text.s down until even with 2nd line ->
X1: line thin color gray down 50% from 2mm below A.sw
X2: line thin color gray down 50% from 2mm below A.se
text "width" at (1/2<X1,X2>,6/8<X1.start,X1.end>)
line thin color gray from previous text.w left until even with X1 ->
line thin color gray from previous text.e right until even with X2 ->
}
set examples(91) {
# pikchr.org file doc/userman.md extract 37

A: box thick rad 0.3*boxht
line thin color gray left 70% from 2mm left of (A.w,A.n)
line same from 2mm left of (A.w,A.s)
text "height" at (7/8<previous.start,previous.end>,1/2<1st line,2ndline>)
line thin color gray from previous text.n up until even with 1st line ->
line thin color gray from previous text.s down until even with 2nd line ->
X1: line thin color gray down 50% from 2mm below (A.w,A.s)
X2: line thin color gray down 50% from 2mm below (A.e,A.s)
text "width" at (1/2<X1,X2>,6/8<X1.start,X1.end>)
line thin color gray from previous text.w left until even with X1 ->
line thin color gray from previous text.e right until even with X2 ->
X3: line thin color gray right 70% from 2mm right of (A.e,A.s)
X4: line thin color gray right 70% from A.rad above start of X3
text "radius" at (6/8<X4.start,X4.end>,1/2<X3,X4>)
line thin color gray from (previous,X3) down 30% <-
line thin color gray from (previous text,X4) up 30% <-
}
set examples(92) {
# pikchr.org file doc/userman.md extract 38

A: cylinder thick rad 150%
line thin color gray left 70% from 2mm left of (A.w,A.n)
line same from 2mm left of (A.w,A.s)
text "height" at (7/8<previous.start,previous.end>,1/2<1st line,2ndline>)
line thin color gray from previous text.n up until even with 1st line ->
line thin color gray from previous text.s down until even with 2nd line ->
X1: line thin color gray down 50% from 2mm below (A.w,A.s)
X2: line thin color gray down 50% from 2mm below (A.e,A.s)
text "width" at (1/2<X1,X2>,6/8<X1.start,X1.end>)
line thin color gray from previous text.w left until even with X1 ->
line thin color gray from previous text.e right until even with X2 ->
X3: line thin color gray right 70% from 2mm right of (A.e,A.ne)
X4: line thin color gray right 70% from A.rad below start of X3
text "radius" at (6/8<X4.start,X4.end>,1/2<X3,X4>)
line thin color gray from (previous,X4) down 30% <-
line thin color gray from (previous text,X3) up 30% <-
}
set examples(93) {
# pikchr.org file doc/userman.md extract 39

A: file thick rad 100%
line thin color gray left 70% from 2mm left of (A.w,A.n)
line same from 2mm left of (A.w,A.s)
text "height" at (7/8<previous.start,previous.end>,1/2<1st line,2ndline>)
line thin color gray from previous text.n up until even with 1st line ->
line thin color gray from previous text.s down until even with 2nd line ->
X1: line thin color gray down 50% from 2mm below (A.w,A.s)
X2: line thin color gray down 50% from 2mm below (A.e,A.s)
text "width" at (1/2<X1,X2>,6/8<X1.start,X1.end>)
line thin color gray from previous text.w left until even with X1 ->
line thin color gray from previous text.e right until even with X2 ->
X3: line thin color gray right 70% from 2mm right of (A.e,A.n)
X4: line thin color gray right 70% from A.rad below start of X3
text "radius" at (6/8<X4.start,X4.end>,1/2<X3,X4>)
line thin color gray from (previous,X4) down 30% <-
line thin color gray from (previous text,X3) up 30% <-
}
set examples(94) {
# pikchr.org file doc/userman.md extract 40

A: circle thick rad 120%
line thin color gray left 70% from 2mm left of (A.w,A.n)
line same from 2mm left of (A.w,A.s)
text "height" at (7/8<previous.start,previous.end>,1/2<1st line,2ndline>)
line thin color gray from previous text.n up until even with 1st line ->
line thin color gray from previous text.s down until even with 2nd line ->
X1: line thin color gray down 50% from 2mm below (A.w,A.s)
X2: line thin color gray down 50% from 2mm below (A.e,A.s)
text "width" at (1/2<X1,X2>,6/8<X1.start,X1.end>)
line thin color gray from previous text.w left until even with X1 ->
line thin color gray from previous text.e right until even with X2 ->
X3: line thin color gray right 70% from 2mm right of (A.e,A.s)
X4: line thin color gray right 70% from A.rad above start of X3
text "radius" at (6/8<X4.start,X4.end>,1/2<X3,X4>)
line thin color gray from (previous,X3) down 30% <-
line thin color gray from (previous text,X4) up 30% <-
line thin color gray <-> from A.sw to A.ne
line thin color gray from A.ne go 0.5*A.rad ne then 0.25*A.rad east
text " diameter" ljust at end of previous line
}
set examples(95) {
# pikchr.org file doc/userman.md extract 41

A: ellipse thick
line thin color gray left 70% from 2mm left of (A.w,A.n)
line same from 2mm left of (A.w,A.s)
text "height" at (7/8<previous.start,previous.end>,1/2<1st line,2ndline>)
line thin color gray from previous text.n up until even with 1st line ->
line thin color gray from previous text.s down until even with 2nd line ->
X1: line thin color gray down 50% from 2mm below (A.w,A.s)
X2: line thin color gray down 50% from 2mm below (A.e,A.s)
text "width" at (1/2<X1,X2>,6/8<X1.start,X1.end>)
line thin color gray from previous text.w left until even with X1 ->
line thin color gray from previous text.e right until even with X2 ->
}
set examples(96) {
# pikchr.org file doc/userman.md extract 42

A: oval thick
X0: line thin color gray left 70% from 2mm left of (A.w,A.n)
X1: line same from 2mm left of (A.w,A.s)
text "height" at (7/8<previous.start,previous.end>,1/2<X0,X1>)
line thin color gray from previous text.n up until even with X0 ->
line thin color gray from previous text.s down until even with X1 ->
X2: line thin color gray down 50% from 2mm below (A.w,A.s)
X3: line thin color gray down 50% from 2mm below (A.e,A.s)
text "width" at (1/2<X2,X3>,6/8<X2.start,X2.end>)
line thin color gray from previous text.w left until even with X2 ->
line thin color gray from previous text.e right until even with X3 ->

A: oval thick wid A.ht ht A.wid at 2.0*A.wid right of A
X0: line thin color gray left 70% from 2mm left of (A.w,A.n)
X1: line same from 2mm left of (A.w,A.s)
text "height" at (7/8<previous.start,previous.end>,1/2<X0,X1>)
line thin color gray from previous text.n up until even with X0 ->
line thin color gray from previous text.s down until even with X1 ->
X2: line thin color gray down 50% from 2mm below (A.w,A.s)
X3: line thin color gray down 50% from 2mm below (A.e,A.s)
text "width" small at (1/2<X2,X3>,6/8<X2.start,X2.end>)
line thin color gray from previous text.w left until even with X2 ->
line thin color gray from previous text.e right until even with X3 ->
}
set examples(97) {
# pikchr.org file doc/userman.md extract 43

diamond "Sharp" "diamond" height 150%
move
diamond same "“Rounded”" "diamond?" "Sorry; no." rad 150%
}
set examples(98) {
# pikchr.org file doc/userman.md extract 44

    down
    box "Auto-fit text annotation" "as is" fit
    move 50%
    box "Auto-fix text annotation" "with 125% width" fit width 125%
}
set examples(99) {
# pikchr.org file doc/userman.md extract 45

    boxwid = 0; boxht = 0;
    box "Hello";
    move
    box "A longer label" "with multiple lines" "of label text"
}
set examples(100) {
# pikchr.org file doc/userman.md extract 46

   boxwid = 0
   boxht = 0
   right
   box "normal"
   move
   box "thin" thin
   move
   box "thick" thick
   move
   box "thick thick thick" thick thick thick
   move
   box "invisible" invisible
}
set examples(101) {
# pikchr.org file doc/userman.md extract 47

   boxwid = 0
   boxht = 0
   box "fully visible"
   box invisible color gray "outline invisible"
   box same solid "outline visible again" fit
}
set examples(102) {
# pikchr.org file doc/userman.md extract 48

   box "Color: CadetBlue" "Fill: Bisque" fill Bisque color CadetBlue fit
   move
   oval "Color: White" "Fill: RoyalBlue" color White fill ROYALBLUE fit
}
set examples(103) [UnguardBs {
# pikchr.org file doc/userman.md extract 49

   line go 3cm heading 150 then 3cm west close \\
                                      /* ^^^^^ nota bene! */ \\
       fill 0x006000 color White "green" below "triangle" below
}]
set examples(104) {
# pikchr.org file doc/userman.md extract 50

   box "box containing" "three lines" "of text" fit
   move
   arrow "Labeled" "line" wid 200%
}
set examples(105) {
# pikchr.org file doc/userman.md extract 51

  line "on the line" wid 150%
}
set examples(106) {
# pikchr.org file doc/userman.md extract 52

  line "above" above; move; line "below" below
}
set examples(107) {
# pikchr.org file doc/userman.md extract 53

  line wid 300% "text without \"above\"" "text without \"below\""
}
set examples(108) {
# pikchr.org file doc/userman.md extract 54

  line width 200% "first above" above "second above" above
  move
  line same "first below" below "second below" below
}
set examples(109) {
# pikchr.org file doc/userman.md extract 55

   line wid 200% "ljust" ljust above "rjust" rjust below
   dot color red at previous.c
}
set examples(110) {
# pikchr.org file doc/userman.md extract 56

   box "ljust" ljust "longer line" ljust "even longer line" ljust fit
   move
   box "rjust" rjust "longer line" rjust "even longer line" rjust fit
}
set examples(111) [UnguardBs {
# pikchr.org file doc/userman.md extract 57

  box wid 300% \\
     "above-ljust" above ljust \\
     "above-rjust" above rjust \\
     "centered" center \\
     "below-ljust" below ljust \\
     "below-rjust" below rjust
}]
set examples(112) {
# pikchr.org file doc/userman.md extract 58

  box "bold" bold "italic" italic "bold-italic" bold italic fit
}
set examples(113) {
# pikchr.org file doc/userman.md extract 59

  box "monospace" monospace fit
}
set examples(114) {
# pikchr.org file doc/userman.md extract 60

  arrow go 150% heading 30 "aligned" aligned above
  move to 1cm east of previous.end
  arrow go 150% heading 170 "aligned" aligned above
  move to 1cm east of previous.end
  arrow go 150% north "aligned" aligned above
}
set examples(115) {
# pikchr.org file doc/userman.md extract 61

  box ht 200% wid 50%
  line invis from previous.s to previous.n "rotated text" aligned
}
set examples(116) {
# pikchr.org file doc/userman.md extract 62

  circle "C1" fit
  circle "C0" at C1+(2.5cm,-0.3cm) fit
  arrow from C0 to C1 "aligned" aligned above chop
}
set examples(117) {
# pikchr.org file doc/userman.md extract 63

  circle "C1" fit
  circle "C0" at C1+(2.5cm,-0.3cm) fit
  arrow from C1 to C0 "aligned" aligned above <- chop
}
set examples(118) [UnguardBs {
# pikchr.org file doc/userman.md extract 64

  box "small small" small small "small" small \\
    "(normal)" italic \\
    "big" big "big big" big big ht 200%
}]
set examples(119) [UnguardBs {
# pikchr.org file doc/userman.md extract 65

arrow up 1.5cm right 1.5cm then down .5cm right 1cm then up .5cm right .3cm \\
   then down 2.5cm right 1cm "text"
box color red thin thin width previous.wid height previous.ht \\
   with .c at previous.c
dot at last arrow.c color red behind last arrow
}]
set examples(120) [UnguardBs {
# pikchr.org file doc/userman.md extract 66

arrow up 1.5cm right 1.5cm then down .5cm right 1cm then up .5cm right .3cm \\
   then down 2.5cm right 1cm
box color red thin thin width previous.wid height previous.ht \\
   with .c at previous.c
dot at last arrow.c color red behind last arrow
line invis from 2nd vertex of last arrow to 3rd vertex of last arrow \\
   "text" below aligned
}]
set examples(121) {
# pikchr.org file doc/userman.md extract 67

C1: cylinder "text in a" "cylinder" rad 120%
    dot color red at C1.c
    dot color blue at 0.75*C1.rad below C1.c
}
set examples(122) {
# pikchr.org file doc/userman.md extract 68
# Deliberate Error: text overflow.  FIX: see previous example.

C1: cylinder rad 120%
    text "text in a" "cylinder" at C1.c
}
set examples(123) {
# pikchr.org file doc/userman.md extract 69

    A: [
      oval "Hello"
      arrow
      box "World" radius 4px
    ]
    Border: box thin width A.width+0.5in height A.height+0.5in at A.center
}
set examples(124) {
# pikchr.org file doc/userman.md extract 70

    A: [
      oval "Hello"
      arrow
      box "World" radius 4px
    ]
    Border: box thin width A.width+0.5in height A.height+0.5in at A.center
}
set examples(125) {
# pikchr.org file doc/userman.md extract 71

    A: [
      oval "Hello"
      arrow
      box "World" radius 4px
    ]
    Caption: text "Diagram Caption" italic with .n at 0.1in below A.s
}
set examples(126) [UnguardBs {
# pikchr.org file doc/userman.md extract 05

box "box"
circle "circle" at 1 right of previous
ellipse "ellipse" at 1 right of previous
oval "oval" at 1 right of previous
cylinder "cylinder" at .8 below first box
file "file" at 1 right of previous
diamond "diamond" at 1 right of previous
line "line" above from .8 below last cylinder.w
arrow "arrow" above from 1 right of previous
spline from previous+(1.8cm,-.2cm) \\
   go right .15 then .3 heading 30 then .5 heading 160 then .4 heading 20 \\
   then right .15
"spline" at 3rd vertex of previous
dot at .6 below last line
text "dot" with .s at .2cm above previous.n
arc from 1 right of previous dot
text "arc" at (previous.start, previous.end)
text "text" at 1.3 right of start of previous arc
}]
set examples(127) [UnguardBs {
# pikchr.org file examples/objects.pikchr

# demo label: Object types
AllObjects: [

# First row of objects
box "box"
box rad 10px "box (with" "rounded" "corners)" at 1in right of previous
circle "circle" at 1in right of previous
ellipse "ellipse" at 1in right of previous

# second row of objects
OVAL1: oval "oval" at 1in below first box
oval "(tall &amp;" "thin)" "oval" width OVAL1.height height OVAL1.width \\
    at 1in right of previous
cylinder "cylinder" at 1in right of previous
file "file" at 1in right of previous

# third row shows line-type objects
dot "dot" above at 1in below first oval
line right from 1.8cm right of previous "lines" above
arrow right from 1.8cm right of previous "arrows" above
spline from 1.8cm right of previous \\
   go right .15 then .3 heading 30 then .5 heading 160 then .4 heading 20 \\
   then right .15
"splines" at 3rd vertex of previous

# The third vertex of the spline is not actually on the drawn
# curve.  The third vertex is a control point.  To see its actual
# position, uncomment the following line:
#dot color red at 3rd vertex of previous spline

# Draw various lines below the first line
line dashed right from 0.3cm below start of previous line
line dotted right from 0.3cm below start of previous
line thin   right from 0.3cm below start of previous
line thick  right from 0.3cm below start of previous


# Draw arrows with different arrowhead configurations below
# the first arrow
arrow <-  right from 0.4cm below start of previous arrow
arrow <-> right from 0.4cm below start of previous

# Draw splines with different arrowhead configurations below
# the first spline
spline same from .4cm below start of first spline ->
spline same from .4cm below start of previous <-
spline same from .4cm below start of previous <->

] # end of AllObjects

# Label the whole diagram
text "Examples Of Pikchr Objects" big bold  at .8cm above north of AllObjects
}]
set examples(128) {
# pikchr.org file doc/macro.md extract 01

$r = 0.2in
linerad = 0.75*$r
linewid = 0.25

# Start and end blocks
#
box "define-statement" bold fit
line down 50% from last box.sw
START: dot rad 250% color black
X0: last.e
move right 3.2in
END: box wid 5% ht 25% fill black
X9: last.w

# The main rule
#
arrow from X0 right 2*linerad+arrowht
oval "\"define\"" fit
arrow
oval "MACRONAME" fit
arrow
oval "{...}" fit
line right to X9
}
set examples(129) [UnguardBs {
# pikchr.org file doc/examples.md extract 04

$r = 0.2in
linerad = 0.75*$r
linewid = 0.25

# Start and end blocks
#
box "element" bold fit
line down 50% from last box.sw
dot rad 250% color black
X0: last.e + (0.3,0)
arrow from last dot to X0
move right 3.9in
box wid 5% ht 25% fill black
X9: last.w - (0.3,0)
arrow from X9 to last box.w


# The main rule that goes straight through from start to finish
#
box "object-definition" italic fit at 11/16 way between X0 and X9
arrow to X9
arrow from X0 to last box.w

# The LABEL: rule
#
arrow right $r from X0 then down 1.25*$r then right $r
oval " LABEL " fit
arrow 50%
oval "\":\"" fit
arrow 200%
box "position" italic fit
arrow
line right until even with X9 - ($r,0) \\
  then up until even with X9 then to X9
arrow from last oval.e right $r*0.5 then up $r*0.8 right $r*0.8
line up $r*0.45 right $r*0.45 then right

# The VARIABLE = rule
#
arrow right $r from X0 then down 2.5*$r then right $r
oval " VARIABLE " fit
arrow 70%
box "assignment-operator" italic fit
arrow 70%
box "expr" italic fit
line right until even with X9 - ($r,0) \\
  then up until even with X9 then to X9

# The PRINT rule
#
arrow right $r from X0 then down 3.75*$r then right $r
oval "\"print\"" fit
arrow
box "print-args" italic fit
line right until even with X9 - ($r,0) \\
  then up until even with X9 then to X9
}]
set examples(130) [UnguardBs {
# pikchr.org file grammar/gram01.pikchr

$r = 0.2in
linerad = 0.75*$r
linewid = 0.25

# Start and end blocks
#
box "statement-list" bold fit
line down 75% from last box.sw
dot rad 250% color black
X0: last.e + (0.3,0)
arrow from last dot to X0
move right 2in
box wid 5% ht 25% fill black
X9: last.w - (0.3,0)
arrow from X9 to last box.w


# The main rule that goes straight through from start to finish
#
box "statement" italic fit at 0.5<X0,X9>
arrow to X9
arrow from X0 to last box.w

# The by-pass line
#
arrow right $r from X0 then up $r \\
  then right until even with 1/2 way between X0 and X9
line right until even with X9 - ($r,0) \\
  then down until even with X9 then right $r

# The Loop-back rule
#
oval "\"&#92;n\"" fit at $r*1.2 below 1/2 way between X0 and X9
line right $r from X9-($r/2,0) then down until even with last oval \\
   then to last oval.e ->
line from last oval.w left until even with X0-($r,0) \\
   then up until even with X0 then right $r
oval "\";\"" fit at $r*1.2 below last oval
line from 2*$r right of 2nd last oval.e left $r \\
   then down until even with last oval \\
   then to last oval.e ->
line from last oval.w left $r then up until even with 2nd last oval \\
   then left 2*$r ->
}]
set examples(131) [UnguardBs {
# pikchr.org file grammar/gram02.pikchr

$r = 0.2in
linerad = 0.75*$r
linewid = 0.25

# Start and end blocks
#
box "statement" bold fit
line down 50% from last box.sw
START: dot rad 250% color black
X0: last.e
move right 4.5in
END: box wid 5% ht 25% fill black
X9: last.w


# The LABEL: rule
#
arrow right $r from X0 then down 1.25*$r then right $r
oval "LABEL" fit
arrow 50%
oval "\":\"" fit
arrow 200%
box "position" italic fit
arrow
line right until even with X9 - ($r,0) \\
  then up until even with X9 then to X9
arrow from last oval.e right $r*0.5 then up $r*0.8 right $r*0.8
line up $r*0.45 right $r*0.45 then right
X2: previous.end

# The main top-line rule
arrow from START.e to linerad right of X2
box "object-definition" fit
arrow to X9

# The VARIABLE = rule
#
arrow right $r from X0 then down 2.5*$r then right $r
oval "VARIABLE" fit
arrow 70%
box "assignment-operator" italic fit
arrow 70%
box "expr" italic fit
line right until even with X9 - ($r,0) \\
  then up until even with X9 then to X9

# The macro rule
#
arrow right $r from X0 then down 3.75*$r then right $r
oval "\"define\""fit
arrow
oval "MACRONAME" fit
arrow
oval "{...}" fit
line right until even with X9-($r,0) \\
  then up even with X9 then to X9

# The PRINT rule
#
arrow right $r from X0 then down 5.0*$r then right $r
oval "\"print\"" fit
arrow
box "print-args" italic fit
line right until even with X9 - ($r,0) \\
  then up until even with X9 then to X9

# The ASSERT rule
#
arrow right $r from X0 then down 6.25*$r then right $r
oval "\"assert\"" fit
arrow 2*arrowht
oval "\"(\"" fit
A1: arrow right 2*linerad + arrowht
box "position" fit
arrow 2*arrowht
oval "\"==\"" fit
arrow 2*arrowht
box "position" fit
A2: arrow same as A1
oval "\")\"" fit
line right even with $r left of X9 then up until even with VARIABLE.n
arrow from A1.start right linerad then down 1.25*$r then right linerad+arrowht
box "expr" fit
arrow 2*arrowht
oval "\"==\"" fit
arrow same
box "expr" fit
line right even with linerad right of A2.start \\
    then up even with A2 then right linerad
}]
set examples(132) [UnguardBs {
# pikchr.org file grammar/gram03.pikchr

$r = 0.2in
linerad = 0.75*$r
linewid = 0.25

# Start and end blocks
#
box "object-definition" bold fit
line down 50% from last box.sw
START: dot rad 250% color black
X0: last.e
move right 3.2in
END: box wid 5% ht 25% fill black
X9: last.w

# The main rule
#
arrow from X0 right 2*linerad+arrowht
TYPENAME: box "object-type-name" fit

# The text-attribute rule
#
arrow right linerad from X0 then down 1.25*$r then right linerad+arrowht
TEXT: box "text-attribute" fit
line right even with linerad right of TYPENAME.e \\
     then up even with TYPENAME then right linerad
X3: previous.end

# The attribute loop
ATTR: box "attribute" fit with .w at X3 + (2*linerad+arrowht, -1.25*$r)
arrow from TYPENAME.e right even with ATTR
arrow to X9
arrow from (ATTR.e,X9) right linerad then down even with ATTR then to ATTR.e
line from ATTR.w left linerad then up even with X9 then right linerad
}]
set examples(133) [UnguardBs {
# pikchr.org file grammar/gram04.pikchr

$r = 0.2in
linerad = 0.75*$r
linewid = 0.25

# Start and end blocks
#
box "object-type-name" bold fit
line down 50% from last box.sw
START: dot rad 250% color black
X0: last.e
X1: X0+(linerad,0)
X2: X1+(linerad+arrowht,0)
move right 1.7in
END: box wid 5% ht 25% fill black
X9: last.w
X8: linerad+arrowht west of X9
X7: linerad west of X8

# The choices
#
arrow from X0 to X2
oval "\"arc\"" fit
arrow to X7
arrow to X9

define keyword {
  right
  oval $1 fit with .w at 1.25*$r below last oval.w
  arrow right even with X7
  line right even with X8 then up linerad
  arrow from (X1,last oval.n) down even with last oval then to last oval.w
}
keyword("\"arrow\"")
keyword("\"box\"")
keyword("\"circle\"")
keyword("\"cylinder\"")
keyword("\"dot\"")
keyword("\"ellipse\"")
keyword("\"file\"")
keyword("\"line\"")
keyword("\"move\"")
keyword("\"oval\"")
keyword("\"spline\"")

right
oval "\"text\"" fit with .w at 1.25*$r below last oval.w
arrow right even with X7
line right even with X8 then up even with X9 then right linerad
arrow from X0 right even with X1 then down even with last oval \\
    then right to last oval.w
}]
set examples(134) {
# pikchr.org file tests/autochop01.pikchr

C: box "box"

line from C to 3cm heading  00 from C chop;
line from C to 3cm heading  10 from C chop;
line from C to 3cm heading  20 from C chop;
line from C to 3cm heading  30 from C chop;
line from C to 3cm heading  40 from C chop;
line from C to 3cm heading  50 from C chop;
line from C to 3cm heading  60 from C chop;
line from C to 3cm heading  70 from C chop;
line from C to 3cm heading  80 from C chop;
line from C to 3cm heading  90 from C chop;
line from C to 3cm heading 100 from C chop;
line from C to 3cm heading 110 from C chop;
line from C to 3cm heading 120 from C chop;
line from C to 3cm heading 130 from C chop;
line from C to 3cm heading 140 from C chop;
line from C to 3cm heading 150 from C chop;
line from C to 3cm heading 160 from C chop;
line from C to 3cm heading 170 from C chop;
line from C to 3cm heading 180 from C chop;
line from C to 3cm heading 190 from C chop;
line from C to 3cm heading 200 from C chop;
line from C to 3cm heading 210 from C chop;
line from C to 3cm heading 220 from C chop;
line from C to 3cm heading 230 from C chop;
line from C to 3cm heading 240 from C chop;
line from C to 3cm heading 250 from C chop;
line from C to 3cm heading 260 from C chop;
line from C to 3cm heading 270 from C chop;
line from C to 3cm heading 280 from C chop;
line from C to 3cm heading 290 from C chop;
line from C to 3cm heading 300 from C chop;
line from C to 3cm heading 310 from C chop;
line from C to 3cm heading 320 from C chop;
line from C to 3cm heading 330 from C chop;
line from C to 3cm heading 340 from C chop;
line from C to 3cm heading 350 from C chop;
}
set examples(135) {
# pikchr.org file tests/autochop02.pikchr

C: box "box" radius 10px

line from C to 3cm heading  00 from C chop;
line from C to 3cm heading  10 from C chop;
line from C to 3cm heading  20 from C chop;
line from C to 3cm heading  30 from C chop;
line from C to 3cm heading  40 from C chop;
line from C to 3cm heading  50 from C chop;
line from C to 3cm heading  60 from C chop;
line from C to 3cm heading  70 from C chop;
line from C to 3cm heading  80 from C chop;
line from C to 3cm heading  90 from C chop;
line from C to 3cm heading 100 from C chop;
line from C to 3cm heading 110 from C chop;
line from C to 3cm heading 120 from C chop;
line from C to 3cm heading 130 from C chop;
line from C to 3cm heading 140 from C chop;
line from C to 3cm heading 150 from C chop;
line from C to 3cm heading 160 from C chop;
line from C to 3cm heading 170 from C chop;
line from C to 3cm heading 180 from C chop;
line from C to 3cm heading 190 from C chop;
line from C to 3cm heading 200 from C chop;
line from C to 3cm heading 210 from C chop;
line from C to 3cm heading 220 from C chop;
line from C to 3cm heading 230 from C chop;
line from C to 3cm heading 240 from C chop;
line from C to 3cm heading 250 from C chop;
line from C to 3cm heading 260 from C chop;
line from C to 3cm heading 270 from C chop;
line from C to 3cm heading 280 from C chop;
line from C to 3cm heading 290 from C chop;
line from C to 3cm heading 300 from C chop;
line from C to 3cm heading 310 from C chop;
line from C to 3cm heading 320 from C chop;
line from C to 3cm heading 330 from C chop;
line from C to 3cm heading 340 from C chop;
line from C to 3cm heading 350 from C chop;
}
set examples(136) {
# pikchr.org file tests/autochop03.pikchr

C: circle "circle"

line from C to 3cm heading  00 from C chop;
line from C to 3cm heading  10 from C chop;
line from C to 3cm heading  20 from C chop;
line from C to 3cm heading  30 from C chop;
line from C to 3cm heading  40 from C chop;
line from C to 3cm heading  50 from C chop;
line from C to 3cm heading  60 from C chop;
line from C to 3cm heading  70 from C chop;
line from C to 3cm heading  80 from C chop;
line from C to 3cm heading  90 from C chop;
line from C to 3cm heading 100 from C chop;
line from C to 3cm heading 110 from C chop;
line from C to 3cm heading 120 from C chop;
line from C to 3cm heading 130 from C chop;
line from C to 3cm heading 140 from C chop;
line from C to 3cm heading 150 from C chop;
line from C to 3cm heading 160 from C chop;
line from C to 3cm heading 170 from C chop;
line from C to 3cm heading 180 from C chop;
line from C to 3cm heading 190 from C chop;
line from C to 3cm heading 200 from C chop;
line from C to 3cm heading 210 from C chop;
line from C to 3cm heading 220 from C chop;
line from C to 3cm heading 230 from C chop;
line from C to 3cm heading 240 from C chop;
line from C to 3cm heading 250 from C chop;
line from C to 3cm heading 260 from C chop;
line from C to 3cm heading 270 from C chop;
line from C to 3cm heading 280 from C chop;
line from C to 3cm heading 290 from C chop;
line from C to 3cm heading 300 from C chop;
line from C to 3cm heading 310 from C chop;
line from C to 3cm heading 320 from C chop;
line from C to 3cm heading 330 from C chop;
line from C to 3cm heading 340 from C chop;
line from C to 3cm heading 350 from C chop;
}
set examples(137) {
# pikchr.org file tests/autochop04.pikchr

C: ellipse "ellipse"

line from C to 3cm heading  00 from C chop;
line from C to 3cm heading  10 from C chop;
line from C to 3cm heading  20 from C chop;
line from C to 3cm heading  30 from C chop;
line from C to 3cm heading  40 from C chop;
line from C to 3cm heading  50 from C chop;
line from C to 3cm heading  60 from C chop;
line from C to 3cm heading  70 from C chop;
line from C to 3cm heading  80 from C chop;
line from C to 3cm heading  90 from C chop;
line from C to 3cm heading 100 from C chop;
line from C to 3cm heading 110 from C chop;
line from C to 3cm heading 120 from C chop;
line from C to 3cm heading 130 from C chop;
line from C to 3cm heading 140 from C chop;
line from C to 3cm heading 150 from C chop;
line from C to 3cm heading 160 from C chop;
line from C to 3cm heading 170 from C chop;
line from C to 3cm heading 180 from C chop;
line from C to 3cm heading 190 from C chop;
line from C to 3cm heading 200 from C chop;
line from C to 3cm heading 210 from C chop;
line from C to 3cm heading 220 from C chop;
line from C to 3cm heading 230 from C chop;
line from C to 3cm heading 240 from C chop;
line from C to 3cm heading 250 from C chop;
line from C to 3cm heading 260 from C chop;
line from C to 3cm heading 270 from C chop;
line from C to 3cm heading 280 from C chop;
line from C to 3cm heading 290 from C chop;
line from C to 3cm heading 300 from C chop;
line from C to 3cm heading 310 from C chop;
line from C to 3cm heading 320 from C chop;
line from C to 3cm heading 330 from C chop;
line from C to 3cm heading 340 from C chop;
line from C to 3cm heading 350 from C chop;
}
set examples(138) {
# pikchr.org file tests/autochop05.pikchr

C: oval "oval"

line from C to 3cm heading  00 from C chop;
line from C to 3cm heading  10 from C chop;
line from C to 3cm heading  20 from C chop;
line from C to 3cm heading  30 from C chop;
line from C to 3cm heading  40 from C chop;
line from C to 3cm heading  50 from C chop;
line from C to 3cm heading  60 from C chop;
line from C to 3cm heading  70 from C chop;
line from C to 3cm heading  80 from C chop;
line from C to 3cm heading  90 from C chop;
line from C to 3cm heading 100 from C chop;
line from C to 3cm heading 110 from C chop;
line from C to 3cm heading 120 from C chop;
line from C to 3cm heading 130 from C chop;
line from C to 3cm heading 140 from C chop;
line from C to 3cm heading 150 from C chop;
line from C to 3cm heading 160 from C chop;
line from C to 3cm heading 170 from C chop;
line from C to 3cm heading 180 from C chop;
line from C to 3cm heading 190 from C chop;
line from C to 3cm heading 200 from C chop;
line from C to 3cm heading 210 from C chop;
line from C to 3cm heading 220 from C chop;
line from C to 3cm heading 230 from C chop;
line from C to 3cm heading 240 from C chop;
line from C to 3cm heading 250 from C chop;
line from C to 3cm heading 260 from C chop;
line from C to 3cm heading 270 from C chop;
line from C to 3cm heading 280 from C chop;
line from C to 3cm heading 290 from C chop;
line from C to 3cm heading 300 from C chop;
line from C to 3cm heading 310 from C chop;
line from C to 3cm heading 320 from C chop;
line from C to 3cm heading 330 from C chop;
line from C to 3cm heading 340 from C chop;
line from C to 3cm heading 350 from C chop;
}
set examples(139) {
# pikchr.org file tests/autochop06.pikchr

C: cylinder "cylinder"

line from C to 3cm heading  00 from C chop;
line from C to 3cm heading  10 from C chop;
line from C to 3cm heading  20 from C chop;
line from C to 3cm heading  30 from C chop;
line from C to 3cm heading  40 from C chop;
line from C to 3cm heading  50 from C chop;
line from C to 3cm heading  60 from C chop;
line from C to 3cm heading  70 from C chop;
line from C to 3cm heading  80 from C chop;
line from C to 3cm heading  90 from C chop;
line from C to 3cm heading 100 from C chop;
line from C to 3cm heading 110 from C chop;
line from C to 3cm heading 120 from C chop;
line from C to 3cm heading 130 from C chop;
line from C to 3cm heading 140 from C chop;
line from C to 3cm heading 150 from C chop;
line from C to 3cm heading 160 from C chop;
line from C to 3cm heading 170 from C chop;
line from C to 3cm heading 180 from C chop;
line from C to 3cm heading 190 from C chop;
line from C to 3cm heading 200 from C chop;
line from C to 3cm heading 210 from C chop;
line from C to 3cm heading 220 from C chop;
line from C to 3cm heading 230 from C chop;
line from C to 3cm heading 240 from C chop;
line from C to 3cm heading 250 from C chop;
line from C to 3cm heading 260 from C chop;
line from C to 3cm heading 270 from C chop;
line from C to 3cm heading 280 from C chop;
line from C to 3cm heading 290 from C chop;
line from C to 3cm heading 300 from C chop;
line from C to 3cm heading 310 from C chop;
line from C to 3cm heading 320 from C chop;
line from C to 3cm heading 330 from C chop;
line from C to 3cm heading 340 from C chop;
line from C to 3cm heading 350 from C chop;
}
set examples(140) {
# pikchr.org file tests/autochop07.pikchr

C: file "file"

line from C to 3cm heading  00 from C chop;
line from C to 3cm heading  10 from C chop;
line from C to 3cm heading  20 from C chop;
line from C to 3cm heading  30 from C chop;
line from C to 3cm heading  40 from C chop;
line from C to 3cm heading  50 from C chop;
line from C to 3cm heading  60 from C chop;
line from C to 3cm heading  70 from C chop;
line from C to 3cm heading  80 from C chop;
line from C to 3cm heading  90 from C chop;
line from C to 3cm heading 100 from C chop;
line from C to 3cm heading 110 from C chop;
line from C to 3cm heading 120 from C chop;
line from C to 3cm heading 130 from C chop;
line from C to 3cm heading 140 from C chop;
line from C to 3cm heading 150 from C chop;
line from C to 3cm heading 160 from C chop;
line from C to 3cm heading 170 from C chop;
line from C to 3cm heading 180 from C chop;
line from C to 3cm heading 190 from C chop;
line from C to 3cm heading 200 from C chop;
line from C to 3cm heading 210 from C chop;
line from C to 3cm heading 220 from C chop;
line from C to 3cm heading 230 from C chop;
line from C to 3cm heading 240 from C chop;
line from C to 3cm heading 250 from C chop;
line from C to 3cm heading 260 from C chop;
line from C to 3cm heading 270 from C chop;
line from C to 3cm heading 280 from C chop;
line from C to 3cm heading 290 from C chop;
line from C to 3cm heading 300 from C chop;
line from C to 3cm heading 310 from C chop;
line from C to 3cm heading 320 from C chop;
line from C to 3cm heading 330 from C chop;
line from C to 3cm heading 340 from C chop;
line from C to 3cm heading 350 from C chop;
}
set examples(141) [UnguardBs {
# pikchr.org file tests/autochop08.pikchr

circle "C0"
move
circle "C1"
box at C0.c width 11cm height 2.5cm
arrow from C0 to C1 chop color red
move
text "bug report 2021-07-17" \\
     "forum 73eea815afda0715" \\
     "arrow C0 to C1 chopped" \\
     "C0 and box have same center" \\
     at 0.5 between last box.w and C0.w
}]
set examples(142) [UnguardBs {
# pikchr.org file tests/autochop09.pikchr

circle "C0" fit color blue
C1: circle at C0 radius 2.5*C0.radius color red
text "C1" with .n at C1.n color red
circle "X1" at 8*C0.radius heading 60 from C0 fit color blue
circle "X2" at 8*C0.radius heading 80 from C0 fit color red
circle "X3" at 8*C0.radius heading 100 from C0 fit color blue
circle "X4" at 8*C0.radius heading 120 from C0 fit color red
arrow color blue from C0 to X1 chop
arrow color red from C1 to X2 chop
arrow color blue from X3 to C0 chop
arrow color red from X4 to C1 chop

text "chop bug 2021-07-17" \\
     "forum 1d46e3a0bc5c5631" \\
     "red lines to red circles" \\
     "blue lines to blue circle" \\
     at 2cm below C0
}]
set examples(143) {
# pikchr.org file tests/autochop10.pikchr

C: diamond "diamond"

line from C to 3cm heading  00 from C chop;
line from C to 3cm heading  10 from C chop;
line from C to 3cm heading  20 from C chop;
line from C to 3cm heading  30 from C chop;
line from C to 3cm heading  40 from C chop;
line from C to 3cm heading  50 from C chop;
line from C to 3cm heading  60 from C chop;
line from C to 3cm heading  70 from C chop;
line from C to 3cm heading  80 from C chop;
line from C to 3cm heading  90 from C chop;
line from C to 3cm heading 100 from C chop;
line from C to 3cm heading 110 from C chop;
line from C to 3cm heading 120 from C chop;
line from C to 3cm heading 130 from C chop;
line from C to 3cm heading 140 from C chop;
line from C to 3cm heading 150 from C chop;
line from C to 3cm heading 160 from C chop;
line from C to 3cm heading 170 from C chop;
line from C to 3cm heading 180 from C chop;
line from C to 3cm heading 190 from C chop;
line from C to 3cm heading 200 from C chop;
line from C to 3cm heading 210 from C chop;
line from C to 3cm heading 220 from C chop;
line from C to 3cm heading 230 from C chop;
line from C to 3cm heading 240 from C chop;
line from C to 3cm heading 250 from C chop;
line from C to 3cm heading 260 from C chop;
line from C to 3cm heading 270 from C chop;
line from C to 3cm heading 280 from C chop;
line from C to 3cm heading 290 from C chop;
line from C to 3cm heading 300 from C chop;
line from C to 3cm heading 310 from C chop;
line from C to 3cm heading 320 from C chop;
line from C to 3cm heading 330 from C chop;
line from C to 3cm heading 340 from C chop;
line from C to 3cm heading 350 from C chop;
}
set examples(144) {
# pikchr.org file tests/colortest1.pikchr

box "red" fill red fit
move
box "orange" fill orange fit
move
box "yellow" fill yellow fit
move
box "green" fill green fit
move
box "blue" fill blue fit
move
box "violet" fill violet fit

box "red" color red fit with .nw at 1cm below 1st box.sw
move
box "orange" color orange fit
move
box "yellow" color yellow fit
move
box "green" color green fit
move
box "blue" color blue fit
move
box "violet" color violet fit
}
set examples(145) {
# pikchr.org file tests/diamond01.pikchr

D1: diamond "First Diamond"
arrow
D2: diamond "Above" above "Below" below
arrow
D3: diamond "Fitted" fit
arrow from D2.s down 1cm
down
D4: diamond "Long string above" above "Below1" below fit
right
arrow
D5: diamond width 300% "thin" fit
arrow from D3.e right 2cm
right
D6: diamond height 300% "tall" above "diamond" below fit
}
set examples(146) [UnguardBs {
# pikchr.org file tests/expr.pikchr

      linerad = 10px
      linewid *= 0.5
      $h = 0.21
margin = 1cm
debug_label_color = Red
color = lightgray
 
      circle radius 10%
OUT:  6.3in right of previous.e  # FIX ME
IN_X: linerad east of first circle.e

      # The literal-value line
      arrow
LTV:  box "literal-value" fit
      arrow right even with linerad+2*arrowht east of OUT
      circle same

      # The bind-parameter line
      right
BNDP: oval "bind-parameter" fit with .w at 1.25*$h below LTV.w
      arrow right even with OUT; line right linerad then up linerad
      arrow from first circle.e right linerad then down even with BNDP \\
        then to BNDP.w

      # The table column reference line
      right
SN:   oval "schema-name" fit with .w at 2.0*$h below BNDP.w
      arrow 2*arrowht
      oval "." bold fit
      arrow
TN:   oval "table-name" fit
      arrow right 2*arrowht
      oval "." bold fit
      arrow
CN:   oval "column-name" fit
      arrow right even with OUT; line right linerad then up linerad
      arrow from (IN_X,SN.n) down even with SN then to SN.w
TN_Y: 0.375*$h above TN.n
      arrow from (IN_X,linerad above TN_Y) down linerad \\
         then right even with SN
      arrow right right even with TN
      line right even with linerad+arrowht west of CN.w \\
         then down even with CN then right linerad
      line from (linerad+2*arrowht left of TN.w,TN_Y) right linerad \\
         then down even with TN then right linerad

      # Unary operators
      right
UOP:  oval "unary-operator" fit with .w at 1.25*$h below SN.w
      arrow right even with OUT; line right linerad then up linerad
      arrow from (IN_X,UOP.n) down even with UOP then to UOP.w

      # Binary operators
      right
BINY: box "expr" fit with .w at 1.25*$h below UOP.w
      arrow 2*arrowht
      oval "binary-operator" fit
      arrow 2*arrowht
      box "expr" fit
      arrow right even with OUT; line right linerad then up linerad
      arrow from (IN_X,BINY.n) down even with BINY then to BINY.w
 
      # Function calls
      right
FUNC: oval "function-name" fit with .w at 2.0*$h below BINY.w
      arrow 1.5*arrowht
FLP:  oval "(" bold fit
      arrow
FDCT: oval "DISTINCT" fit
      arrow
FEXP: box "expr" fit
      arrow 150%
FRP:  oval ")" bold fit
      arrow right linerad then down $h then right 2*arrowht
FFC:  box "filter-clause" fit
FA1:  arrow right linerad then up even with FUNC then right 2*arrowht
      arrow right linerad then down $h then right 2*arrowht
FOC:  box "over-clause" fit
      arrow right even with OUT; line right linerad then up linerad
      arrow from (IN_X,FUNC.n) down even with FUNC then to FUNC.w

             # filter clause bypass
             arrow from FRP.e right even with FFC
             line to arrowht left of FA1.end

             # over clause bypass
             arrow from FA1.end right even with OUT
             line right linerad then up linerad

             # expr loop
      FCMA:  oval "," bold fit at 1.25*$h above FEXP
             arrow from FEXP.e right linerad then up even with FCMA \\
               then to FCMA.e
             line from FCMA.w left even with 2*arrowht west of FEXP.w \\
               then down even with FEXP then right linerad

             # "*" argument list
      FSTR:  oval "*" bold fit with .w at 1.25*$h below FDCT.w
             arrow from FLP.e right linerad then down even with FSTR \\
                then to FSTR.w
      FA2:   arrow from FSTR.e right even with linerad+2*arrowht west of FRP.w
             line right linerad then up even with FRP then right linerad

             # empty argument list
             arrow from (linerad east of FLP.e,FSTR.n) \\
                down even with $h below FSTR then right even with FDCT.w
             arrow right even with FA2.end
             line right linerad then up even with FSTR.n

      # parenthesized and vector expressions
      right
PRN:  oval "(" bold fit with .w at 3.0*$h below FUNC.w
      arrow
PEXP: box "expr" fit
      arrow
      oval ")" bold fit
      arrow right even with OUT; line right linerad then up linerad
      arrow from (IN_X,PRN.n) down even with PRN then to PRN.w

             # expr loop
      PCMA:  oval "," bold fit at 1.25*$h above PEXP
             arrow from PEXP.e right linerad then up even with PCMA \\
               then to PCMA.e
             line from PCMA.w left even with 2*arrowht left of PEXP.w \\
               then down even with PEXP then right linerad

      # CAST expression
      right
CAST: oval "CAST" fit with .w at 1.25*$h below PRN.w
      arrow 2*arrowht
      oval "(" bold fit
      arrow 2*arrowht
      box "expr" fit
      arrow 2*arrowht
      oval "AS" fit
      arrow 2*arrowht
      box "type-name" fit
      arrow 2*arrowht
      oval ")" bold fit
      arrow right even with OUT; line right linerad then up linerad
      arrow from (IN_X,CAST.n) down even with CAST then to CAST.w

      # COLLATE expression
      right
COLL: box "expr" fit with .w at 1.25*$h below CAST.w
      arrow 2*arrowht
      oval "COLLATE" fit
      arrow 2*arrowht
      oval "collation-name" fit
      arrow right even with OUT; line right linerad then up linerad
      arrow from (IN_X,COLL.n) down even with COLL then to COLL.w

      # LIKE expressions
      right
LIKE: box "expr" fit with .w at 1.25*$h below COLL.w
      arrow
LNOT: oval "NOT" fit
      arrow 150%
LOP1: oval "LIKE" fit
LOP2: oval "GLOB" fit with .w at 1.25*$h below LOP1.w
LOP3: oval "REGEXP" fit with .w at 1.25*$h below LOP2.w
LOP4: oval "MATCH" fit with .w at 1.25*$h below LOP3.w
LE2:  box "expr" fit with .w at (4*arrowht+linerad east of LOP3.e,LIKE)
      arrow from LE2.e right linerad then down $h then right 2*arrowht
LESC: oval "ESCAPE" fit
      arrow 2*arrowht
      box "expr" fit
LA1:  arrow right linerad then up even with LIKE then right
      arrow right even with OUT; line right linerad then up linerad
      arrow from (IN_X,LIKE.n) down even with LIKE then to LIKE.w

            # NOT bypass
            line from linerad*2 west of LNOT.w \\
              right linerad then down $h \\
              then right even with arrowht east of LNOT.e \\
              then up even with LNOT then right linerad

            # Inputs to the operators
       LX1: 2*arrowht west of LOP1.w
            arrow from linerad west of LX1 right linerad \\
               then down even with LOP4 then to LOP4.w
            arrow from (LX1,LOP2.n) down even with LOP2 then to LOP2.w
            arrow from (LX1,LOP3.n) down even with LOP3 then to LOP3.w

            # Outputs from the operators
       LX2: 2*arrowht east of LOP3.e
            arrow from LOP4.e right even with LX2
            arrow right linerad then up even with LE2 then to LE2.w
            arrow from LOP3.e right even with LX2
            line right linerad then up linerad
            arrow from LOP2.e right even with LX2
            line right linerad then up linerad
            line from LOP1.e to arrowht west of LE2.w

            # ESCAPE bypass
            arrow from LE2.e right even with LESC
            line to arrowht left of LA1.end

      # ISNULL and NOTNULL operators
      right
NNUL: box "expr" fit with .w at 5.0*$h below LIKE.w
      arrow
NN1:  oval "ISNULL" fit
      arrow right even with OUT; line right linerad then up linerad
      arrow from (IN_X,NNUL.n) down even with NNUL then to NNUL.w
NN2:  oval "NOTNULL" fit with .w at 1.25*$h below NN1.w
      right
NN3:  oval "NOT" fit with .w at 1.25*$h below NN2.w
      arrow 2*arrowht
NN3B: oval "NULL" fit
NNA1: arrow 2*arrowht
      arrow right linerad then up even with NN1 then right
      arrow from NN2.e right even with NNA1.end
      line right linerad then up linerad
      arrow from NNUL.e right linerad then down even with NN3 then to NN3.w
      arrow from NNUL.e right linerad then down even with NN2 then to NN2.w

      # The IS operator
      right
IS:   box "expr" fit with .w at 3.75*$h below NNUL.w
      arrow 2*arrowht
      oval "IS" fit
      arrow
ISN:  oval "NOT" fit
      arrow
      box "expr" fit
      arrow right even with OUT; line right linerad then up linerad
      arrow from (IN_X,IS.n) down even with IS then to IS.w
      # NOT bypass
      line from 3*arrowht west of ISN.w right linerad \\
         then down 0.8*$h then right even with arrowht east of ISN.e \\
         then up even with ISN then right linerad

      # The BETWEEN operator
      right
BTW:  box "expr" fit with .w at 1.5*$h below IS.w
      arrow
BTWN: oval "NOT" fit
      arrow
      oval "BETWEEN" fit
      arrow 2*arrowht
      box "expr" fit
      arrow 2*arrowht
      oval "AND" fit
      arrow 2*arrowht
      box "expr" fit
      arrow right even with OUT; line right linerad then up linerad
      arrow from (IN_X,BTW.n) down even with BTW then to BTW.w
      # NOT bypass
      line from 3*arrowht west of BTWN.w right linerad \\
         then down 0.8*$h then right even with arrowht east of BTWN.e \\
         then up even with BTWN then right linerad

      # The IN operator
      right
IN:   box "expr" fit with .w at 1.75*$h below BTW.w
      arrow
INNT: oval "NOT" fit
      arrow
ININ: oval "IN" fit
      arrow
INLP: oval "(" bold fit
      arrow
INSS: box "select-stmt" fit
      arrow
      oval ")" bold fit
      arrow right even with OUT; line right linerad then up linerad
      arrow from (IN_X,IN.n) down even with IN then to IN.w

             # NOT bypass
             line from 3*arrowht west of INNT.w right linerad \\
             then down 0.8*$h then right even with arrowht east of INNT.e \\
             then up even with INNT then right linerad

             # select-stmt bypass
             line from 3*arrowht west of INSS.w right linerad \\
             then up 0.8*$h then right even with arrowht east of INSS.e \\
             then up even with INSS then right linerad

             # expr list instead of select-stmt
       INE1: box "expr" fit at 1.25*$h below INSS
             arrow from 3*arrowht west of INSS.w right linerad \\
               then down even with INE1 then to INE1.w
             line from INE1.e right even with arrowht east of INSS.e \\
               then up even with INSS then right linerad

             # expr loop
       INC1: oval "," bold fit at 1.25*$h below INE1
             arrow from INE1.e right linerad then down even with INC1 \\
                then to INC1.e
             line from INC1.w left even with 2*arrowht west of INE1.w \\
                then up even with INE1 then right linerad

             # reference-to-table choice as RHS
       INSN: oval "schema-name" fit with .w at 4.25*$h below INLP.w
             arrow from INSN.e right 1.5*arrowht
       INDT: oval "." bold fit
             arrow 150%
       INTF: oval "table-function" fit
             arrow 1.5*arrowht
       INL2: oval "(" bold fit
             arrow 125%
       INE2: box "expr" fit
             arrow 125%
       INR2: oval ")" bold fit
             arrow right even with OUT; line right linerad then up linerad

             # table reference branch
             right
       INTB: oval "table-name" fit with .w at 2*$h above INTF.w
             arrow right even with OUT; line right linerad then up linerad
             arrow from linerad+2*arrowht west of INTF.w right linerad \\
                then up even with INTB then to INTB.w

             # expr-list no table-valued-functions
       INC2: oval "," bold fit at 1.1*$h above INE2
             arrow from INE2.e right linerad then up even with INC2 \\
               then to INC2.e
             line from INC2.w right even with 2*arrowht west of INE2.w \\
               then down even with INE2 then right linerad

             # expr-list bypass for table-valued functions
             line from INL2.e right linerad then down .7*$h \\
                then right even with 2*arrowht left of INR2.w \\
                then up even with INR2 then right linerad

             # links from IN operator to table references
             arrow from ININ.e right linerad then down even with INSN \\
                then to INSN.w

             # schema-name bypass
       INY3: 0.45*$h above INSN.n
             arrow from (linerad east of ININ.e,linerad above INY3) \\
                down linerad then right even with arrowht right of INSN.e
             line right even with arrowht east of INDT.e \\
                then down even with INDT then right linerad

      # NOT? EXISTS? (SELECT) clause
      right
NE:   oval "NOT" fit with .w at (IN.w,1.5*$h below INSN)
      arrow
NEE:  oval "EXISTS" fit
      arrow
NELP: oval "(" bold fit
      arrow 2*arrowht
      box "select-stmt" fit
      arrow 2*arrowht
      oval ")" bold fit
      arrow right even with OUT; line right linerad then up linerad
      arrow from (IN_X,NE.n) down even with NE then to NE.w
NE_Y: 0.375*$h above NE.n
      arrow from (IN_X,linerad above NE_Y) down linerad \\
         then right even with NE
      line right even with linerad+arrowht west of NELP.w \\
         then down even with NELP then right linerad
      line from (linerad+2*arrowht left of NEE.w,NE_Y) right linerad \\
         then down even with NEE then right linerad
      
      # CASE expressions
      right
CS:   oval "CASE" fit with .w at 1.25*$h below NE.w
      arrow
CSE1: box "expr" fit
      arrow 150%
CSW:  oval "WHEN" fit
      arrow 2*arrowht
CSE2: box "expr" fit
      arrow 2*arrowht
      oval "THEN" fit
      arrow 2*arrowht
CSE3: box "expr" fit
      arrow 200%
CSEL: oval "ELSE" fit
      arrow 2*arrowht
CSE4: box "expr" fit
      arrow
      oval "END" fit
      arrow right even with OUT; line right linerad then up linerad
      arrow from (IN_X,CS.n) down even with CS then to CS.w
      # first expr bypass
CSY:  0.9*$h below CS
      line from CS.e right linerad then down even with CSY \\
         then right even with arrowht east of CSE1.e then up even with CSE1 \\
         then right linerad
      # when clause loop
      arrow from CSE3.e right linerad then down even with CSY \\
         then left even with CSE2
      line left even with 2*arrowht west of CSW.w \\
         then up even with CSW then right linerad
      # ELSE clause bypass
      line from linerad+2*arrowht west of CSEL.w right linerad \\
         then down even with CSY then right even with arrowht east of CSE4.e \\
         then up even with CSE4 then right linerad

      # The RAISE function
      right
RSE:  box "raise-function" fit with .w at 1.9*$h below CS.w
      arrow right even with OUT; 
      line right linerad then up even with first circle then right linerad
      arrow from (IN_X,BNDP.n) down even with RSE then to RSE.w
}]
set examples(147) [UnguardBs {
# pikchr.org file tests/fonts01.pikchr

ROW1: \\
box "left" ljust \\
    "normal text"\\
    "right" rjust fit
box "left" ljust italic \\
    "italic text" italic \\
    "right" rjust italic fit
box "left" ljust bold \\
    "bold text" bold \\
    "right" rjust bold fit
box "left" ljust mono \\
    "monospace text" monospace \\
    "right" rjust mono fit
ROW2: \\
box "left" ljust bold italic\\
    "bold italic text" italic bold \\
   "right" rjust italic bold fit with nw at ROW1.sw
box "left" ljust bold mono \\
    "bold monospace text" mono bold \\
    "right" rjust monospace bold fit
box "left" ljust italic mono \\
    "italic monospace text" mono italic \\
    "right" rjust monospace italic fit
ROW3: \\
box "left" ljust bold italic mono \\
    "bold italic text" italic monospace bold \\
    "right" rjust monospace italic bold fit with nw at ROW2.sw
ROW4: \\
box "left" ljust big \\
    "normal big text" big\\
    "right" rjust big fit with nw at ROW3.sw
box "left" ljust italic big \\
    "big italic text" italic big \\
    "right" rjust italic big fit
box "left" big ljust bold \\
    "big bold text" big bold \\
    "right" rjust big bold fit
box "left" ljust big mono \\
    "big monospace text" big monospace \\
    "right" rjust mono big fit
ROW5: \\
box "left" ljust big bold italic\\
    "big bold italic text" big italic bold \\
   "right" rjust italic bold big fit with nw at ROW4.sw
box "left" ljust bold mono big \\
    "big bold monospace text" mono big bold \\
    "right" rjust monospace bold big fit
box "left" ljust italic mono big \\
    "big italic monospace text" mono big italic \\
    "right" rjust monospace italic big fit
ROW6: \\
box "left" ljust bold italic big mono \\
    "big bold italic mono text" italic monospace big bold \\
    "right" rjust monospace italic bold big fit with nw at ROW5.sw
}]
set examples(148) {
# pikchr.org file tests/test01.pikchr

    right;
    circle "C0";
A0: arrow;
    circle "C1";
A1: arrow; circle "C2";
    arrow;
    circle "C4";
    arrow;
    circle "C6"
    circle "C3" at (C4.x-C2.x) ne of C2;
    arrow;
    circle "C5"
    arrow from C2.ne to C3.sw

assert( previous == last arrow )
assert( previous == 6th arrow )

# Demonstrate that a new point can be established using LABEL: notation
AS: start of last arrow
AE: end of last arrow

# Validate various kinds of expressions and locations as a test of
# parser expression processing and layout
#
assert( last arrow.start.x == C2.ne.x )
assert( AS.y == C2.ne.y )
assert( last arrow.end.x == C3.sw.x )
assert( AE.y == C3.sw.y )
assert( AE == C3.sw )
assert( 1st last arrow.end == C3.sw )
assert( start of A0 == C0.e )

assert( C0.y == C1.y );
assert( C0.y == C2.y );
assert( C0.y == C4.y );
assert( C0.y == C6.y );
assert( C3.y == C5.y );
}
set examples(149) [UnguardBs {
# pikchr.org file tests/test02.pikchr

/* First generate the main graph */
scale = 0.75
Main: [
  circle "C0"
  arrow
  circle "C1"
  arrow
  circle "C2"
  arrow
  circle "C4"
  arrow
  circle "C6"
]
Branch: [
  circle "C3"
  arrow
  circle "C5"
] with .sw at Main.C2.n + (0.35,0.35)
arrow from Main.C2 to Branch.C3 chop

/* Now generate the background colors */
layer = 0
$featurecolor = 0xfedbce
$maincolor = 0xd9fece
$divY = (Branch.y + Main.y)/2
$divH = (Branch.y - Main.y)
box fill $featurecolor color $featurecolor \\
    width Branch.width*1.5 height $divH \\
    at Branch
box fill $maincolor color $maincolor \\
    width Main.width+0.1 height $divH \\
    at Main
"main" ljust at 0.1 se of nw of 2nd box
"feature" ljust at 0.1 se of nw of 1st box
}]
set examples(150) [UnguardBs {
# pikchr.org file doc/teardown01.md extract 01

/* 01 */ scale = 0.8
/* 02 */ fill = white
/* 03 */ linewid *= 0.5
/* 04 */ circle "C0" fit
/* 05 */ circlerad = previous.radius
/* 06 */ arrow
/* 07 */ circle "C1"
/* 08 */ arrow
/* 09 */ circle "C2"
/* 10 */ arrow
/* 11 */ circle "C4"
/* 12 */ arrow
/* 13 */ circle "C6"
/* 14 */ circle "C3" at dist(C2,C4) heading 30 from C2
/* 15 */ arrow
/* 16 */ circle "C5"
/* 17 */ arrow from C2 to C3 chop
/* 18 */ C3P: circle "C3'" at dist(C4,C6) heading 30 from C6
/* 19 */ arrow right from C3P.e
/* 20 */ C5P: circle "C5'"
/* 21 */ arrow from C6 to C3P chop
/* 22 */ box height C3.y-C2.y \\
/* 23 */     width (C5P.e.x-C0.w.x)+linewid \\
/* 24 */     with .w at 0.5*linewid west of C0.w \\
/* 25 */     behind C0 \\
/* 26 */     fill 0xc6e2ff thin color gray
/* 27 */ box same width previous.e.x - C2.w.x \\
/* 28 */     with .se at previous.ne \\
/* 29 */     fill 0x9accfc
/* 30 */ "trunk" below at 2nd last box.s
/* 31 */ "feature branch" above at last box.n
}]
set examples(151) [UnguardBs {
# pikchr.org file tests/test58.pikchr

scale = 0.8

All: [
circle "C0" fit fill white
arrow right 50%
$arrowlen = previous.wid
circle same "C1"
A1: arrow same thickness 0.5*(thickness)
#                        ^^^^^^^^^^^^^^^
# demonstrate access to the "thickness" variable by
# enclosing it in parentheses
circle same "C2"
arrow same as 1st arrow
circle same "C4"
arrow same
circle same "C6"
circle same "C3" at dist(C2,C4) heading 30 from C2
arrow right 50%
circle same "C5"
arrow from C2 to C3 chop
C3P: circle same "C3'" at dist(C4,C6) heading 30 from C6
arrow right 50% from C3P.e
C5P: circle same "C5'"
arrow from C6 to C3P chop

box height C3.y-C2.y \\
    width dist(C5P.e,C0.w)+1.5*C1.rad \\
    with .w at 0.5*$arrowlen west of C0.w \\
    behind C0 \\
    fill 0xc6e2ff color 0xaac5df
box same width previous.e.x - C2.w.x \\
    with .se at previous.ne \\
    fill 0x9accfc

spline <- thin from 1mm south of A1.center down .8cm then right .5cm color gray
"  0.5*(thickness)" ljust small at previous.end
dot at previous.c
assert( A1.thickness == 1st arrow.thickness/2 )
right

circle "C0" fit fill white at 3.5cm south of C0
arrow right 50%
circle same "C1"
arrow same
circle same "C2"
arrow same
circle same "C4"
arrow same
circle same "C6"
circle same "C3" at dist(C2,C4) heading 30 from C2
arrow right 50%
circle same "C5"
arrow same
circle same "C7"
arrow from C2 to C3 chop
arrow from C6 to C7 chop

box height C3.y-C2.y \\
    width dist(C7.e,C0.w)+1.5*C1.radius \\
    with .w at 0.5*$arrowlen west of C0.w \\
    behind C0 \\
    fill 0xc6e2ff color 0xaac5df
box same width previous.e.x - C2.w.x \\
    with .se at previous.ne \\
    fill 0x9accfc
]

"Rebase vs. Merge" big big bold with .s at 3mm north of All.n
}]
set examples(152) [UnguardBs {
# pikchr.org file tests/test03.pikchr

right
B1: box "One"; line
B2: box "Two"; arrow
B3: box "Three"; down; arrow down 50%; circle "Hi!"; left;
spline -> left 2cm then to One.se
Macro: [
  B4: box "four"
  B5: box "five"
  B6: box "six"
] with n at 3cm below s of 2nd box

arrow from s of 2nd box to Macro.B5.n

spline -> from e of last circle right 1cm then down 1cm then to Macro.B4.e

box width Macro.width+0.1 height Macro.height+0.1 at Macro color Red
box width Macro.B5.width+0.05 \\
    height Macro.B5.height+0.05 at Macro.B5 color blue
}]
set examples(153) {
# pikchr.org file tests/test06.pikchr

B1: box "one" width 1 height 1 at 2,2;
B2: box thickness 300% dotted 0.03 "two" at 1,3;
print "B2.n: ",B2.n.x,",",B2.n.y
print "B2.c: ",B2.c.x,",",B2.c.y
print "B2.e: ",B2.e.x,",",B2.e.y
scale = 1
box "three" "four" ljust "five" with .n at 0.1 below B2.s width 50%

#  Text demo: <text x="100" y="100" text-anchor="end" dominant-baseline="central">I love SVG!</text>
}
set examples(154) {
# pikchr.org file tests/test07.pikchr

B: box "This is" "<b>" "box \"B\"" color DarkRed

   "B.nw" rjust above at 0.05 left of B.nw
   "B.w" rjust at 0.05 left of B.w
   "B.sw" rjust below at 0.05 left of B.sw;  $abc = DarkBlue
   "B.s" below at B.s
   // C++ style comments allowed.
   "B.se" ljust below at 0.05 right of B.se color DarkBlue
   "B.e" ljust at 0.05 right of B.e  /* C-style comments */
   "B.ne" ljust above at 0.05 right of B.ne
   "B.n" center above at B.n
print "this is a test: " /*comment ignored*/, $abc
print "Colors:", Orange, Black, White, Red, Green, Blue

#   line from B.ne + (0.05,0) right 1.0 then down 2.5 then left 1.5
}
set examples(155) [UnguardBs {
# pikchr.org file tests/test08.pikchr

     debug = 1;

     box "one" width 80% height 80%
     box "two" width 150% color DarkRed   # Comment does not mask newline
     arrow "xyz" above                   // Comment does not mask newline
     box "three" height 150% color DarkBlue
     down
     arrow
B4:  box "four"
B45: box "4.5" fill SkyBlue
     move
B5:  box "five"
     left
B6:  box "six"
     up
     box "seven" width 50% height 50%

     line from 0.1 right of B4.e right 1 then down until even with B5 \\
         then to B5 rad 0.1 chop

     arrow from B6 left even with 2nd box then up to 2nd box chop rad 0.1
     arrow from 1/2 way between B6.w and B6.sw left until even with first box \\
         then up to first box rad 0.1 chop

oval wid 25% ht B4.n.y - B45.s.y at (B6.x,B4.s.y)
arrow from last box to last oval chop
arrow <- from B4.w left until even with last oval.e
arrow <- from B45 left until even with last oval.e chop
}]
set examples(156) {
# pikchr.org file tests/test10.pikchr

C: "+";    $x = 0
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
   $x = $x + 10
   line from 0.5 heading $x from C to 1.0 heading $x from C
}
set examples(157) {
# pikchr.org file tests/test12.pikchr

circle "One"
arrow
circle "Two"; down
arrow down 40%
circle "Three"
move
circle "Four"
}
set examples(158) {
# pikchr.org file tests/test13.pikchr

// margin = 1
line up 1 right 2
linewid = 0
arrow left 2
move left 0.1
line <-> down 1 "height " rjust
}
set examples(159) {
# pikchr.org file tests/test14.pikchr

print "1in=",1in
print "1cm=",1cm
print "1mm=",1mm
print "1pt=",1pt
print "1px=",1px
print "1pc=",1pc
scale = 0.25
circle "in" radius 1in
circle "cm" radius 2.54cm
circle "mm" radius 25.4mm
circle "pt" radius 72pt
circle "px" radius 96px
circle "pc" radius 6pc

circle "in" radius 0.5*1in with .n at s of 1st circle
circle "cm" radius 0.5*2.54cm
circle "mm" radius 25.4mm * 0.5
circle "pt" radius 72pt * 0.5
circle "px" radius 96px * 0.5
circle "pc" radius 6pc  * 0.5
}
set examples(160) {
# pikchr.org file tests/test15.pikchr

ellipse "document"
arrow
box "PIC"
arrow
box "TBL/EQN" "(optional)" dashed
arrow
box "TROFF"
arrow
ellipse "typesetter"
}
set examples(161) {
# pikchr.org file tests/test16.pikchr

box "this is" "a box"
}
set examples(162) {
# pikchr.org file tests/test17.pikchr

line "this is" "a line"
}
set examples(163) {
# pikchr.org file tests/test22.pikchr

box invisible "input"; arrow; box invisible "output"
}
set examples(164) {
# pikchr.org file tests/test23.pikchr

margin = 24pt;
linewid *= 1.75
arrow "on top of"; move
arrow "above" "below"; move
arrow "above" above; move
arrow "below" below; move
arrow "above" "on top of" "below"

move to start of first arrow down 1in;
right
arrow "way above" "above" "on the line" "below" "way below"
move; arrow "way above" "above" "below" "way below"

move to start of first arrow down 2in;
right
box "first line" "second line" "third line" "fourth  line" "fifth line" fit
move
box "first line" "second line" "third line" "fourth  line" fit
move
box "first line" "second line" "third line" fit
move
box "first line" "second line" fit
move
box "first line" fit

move to start of first arrow down 3in;
right
box "first above" above "second above" above "third" fit
dot color red at last box
move 2cm
box "    3 leading spaces" "&" "3 trailing spaces   " fit
}
set examples(165) {
# pikchr.org file tests/test23b.pikchr

margin = 24pt;
linewid *= 1.75
charht = 0.14
//thickness *= 8
print charht, thickness
arrow "on top of"; move
arrow "above" "below"; move
arrow "above" above; move
arrow "below" below; move
arrow "above" "on top of" "below"

move to start of first arrow down 1in;
right
arrow "way a||bove" "ab||ove" "on t||he line" "below" "way below"
move; arrow "way above" "above" "below" "way below"
move; arrow "way above" above "above" above
move; arrow "below" below "way below" below
move; arrow "above-1" above "above-2" above "floating"

move to start of first arrow down 2in;
right
arrow "above-1" above "above-2" above "below" below
move; arrow "below-1" below "below-2" below "floating"
move; arrow "below-1" below "below-2" below "above" above

move to start of first arrow down 3in;
right
box "first line" "second line" "third line" "fourth  line" "fifth line" fit
move
box "first line" "second line" "third line" "fourth  line" fit
move
box "first line" "second line" "third line" fit
move
box "first line" "second line" fit
move
box "first line" fit

move to start of first arrow down 4in;
right
box "first above" above "second above" above "third" fit
dot color red at last box
}
set examples(166) {
# pikchr.org file tests/test23c.pikchr

linewid *= 2
arrow "Big" big "Small" small thin
box invis "thin" "line" fit
move
arrow "Big Big" big big "Small Small" small small thick
box invis "thick" "line" fit
box thick "Thick" with .nw at .5 below start of 1st arrow
move
box thick thick "Thick" "Thick"
move
box thin "Thin"
move
box thin thin "Thin" "Thin"
}
set examples(167) {
# pikchr.org file tests/test28.pikchr

box "Box"
arrow
cylinder "One"
down
arrow
ellipse "Ellipse"
up
arrow from One.n
circle "Circle"
right
arrow from One.e <-
circle "E" radius 50%
circle "NE" radius 50% at 0.5 ne of One.ne
arrow from NE.sw to One.ne 
circle "SE" radius 50% at 0.5 se of One.se
arrow from SE.nw to One.se

spline from One.sw left 0.2 down 0.2 then to Box.se ->
spline from Circle.w left 0.3 then left 0.2 down 0.2 then to One.nw ->
}
set examples(168) [UnguardBs {
# pikchr.org file tests/test29.pikchr

# Demonstrate the ability to close and fill a line with the "fill"
# attribute - treating it as a polygon.
#
line right 1 then down 0.25 then up .5 right 0.5 \\
   then up .5 left 0.5 then down 0.25 then left 1 close fill blue
move
box "Box to right" "of the" "polygon"
move
line "not a" "polygon" right 1in fill red
move to w of 1st line then down 3.5cm
line same as 1st line
}]
set examples(169) {
# pikchr.org file tests/test31.pikchr

box "1"
[ box "2"; arrow "3" above; box "4" ] with .n at last box.s - (0,0.1)
"Thing 2: " rjust at last [].w

dot at last box.s color red
dot at last [].n color blue
}
set examples(170) {
# pikchr.org file tests/test36.pikchr

h = .5;  dh = .02;  dw = .1
[
    Ptr: [
        boxht = h; boxwid = dw
     A: box
     B: box
     C: box
        box wid 2*boxwid "..."
     D: box
    ]
  Block: [
        boxht = 2*dw;
        boxwid = 2*dw
        movewid = 2*dh
     A: box; move
     B: box; move
     C: box; move
        box invis "..." wid 2*boxwid; move
     D: box
  ] with .n at Ptr.s - (0,h/2)
  arrow from Ptr.A to Block.A.nw + (dh,0)
  arrow from Ptr.B to Block.B.nw + (dh,0)
  arrow from Ptr.C to Block.C.nw + (dh,0)
  arrow from Ptr.D to Block.D.nw + (dh,0)
]
box dashed ht last [].ht+dw wid last [].wid+dw at last []
}
set examples(171) {
# pikchr.org file tests/test37.pikchr

# Change from the original:
# Need fixing:
#    * "bottom of last box"
#    * ".t"
#
define ndblock {
  box wid boxwid/2 ht boxht/2
  down;  box same with .t at bottom of last box;   box same
}
boxht = .2; boxwid = .3; circlerad = .3; dx = 0.05
down; box; box; box; box ht 3*boxht "." "." "."
L: box; box; box invis wid 2*boxwid "hashtab:" with .e at 1st box .w
right
Start: box wid .5 with .sw at 1st box.ne + (.4,.2) "..."
N1: box wid .2 "n1";  D1: box wid .3 "d1"
N3: box wid .4 "n3";  D3: box wid .3 "d3"
box wid .4 "..."
N2: box wid .5 "n2";  D2: box wid .2 "d2"
arrow right from 2nd box
ndblock
spline -> right .2 from 3rd last box then to N1.sw + (dx,0)
spline -> right .3 from 2nd last box then to D1.sw + (dx,0)
arrow right from last box
ndblock
spline -> right .2 from 3rd last box to N2.sw-(dx,.2) to N2.sw+(dx,0)
spline -> right .3 from 2nd last box to D2.sw-(dx,.2) to D2.sw+(dx,0)
arrow right 2*linewid from L
ndblock
spline -> right .2 from 3rd last box to N3.sw + (dx,0)
spline -> right .3 from 2nd last box to D3.sw + (dx,0)
circlerad = .3
circle invis "ndblock"  at last box.e + (1.2,.2)
arrow dashed from last circle.w to 5/8<last circle.w,2nd last box> chop
box invis wid 2*boxwid "ndtable:" with .e at Start.w
}
set examples(172) {
# pikchr.org file tests/test38.pikchr
# Deliberate Error: text overflow. FIX: see next example.

# Need fixing:
#
#    *  ".bot" as an abbreviation for ".bottom"
#    *  "up from top of LA"
#
        arrow "source" "code"
LA:     box "lexical" "analyzer"
        arrow "tokens" above
P:      box "parser"
        arrow "intermediate" "code"
Sem:    box "semantic" "checker"
        arrow
        arrow <-> up from top of LA
LC:     box "lexical" "corrector"
        arrow <-> up from top of P
Syn:    box "syntactic" "corrector"
        arrow up
DMP:    box "diagnostic" "message" "printer"
        arrow <-> right  from east of DMP
ST:     box "symbol" "table"
        arrow from LC.ne to DMP.sw
        arrow from Sem.nw to DMP.se
        arrow <-> from Sem.top to ST.bot
}
set examples(173) {
# pikchr.org file tests/test38b.pikchr

# Need fixing:
#
#    *  ".bot" as an abbreviation for ".bottom"
#    *  "up from top of LA"
#
        arrow "source" "code"
LA:     box "lexical" "analyzer"
        arrow "tokens" above
P:      box "parser"
        arrow "intermediate" "code" wid 180%
Sem:    box "semantic" "checker"
        arrow
        arrow <-> up from top of LA
LC:     box "lexical" "corrector"
        arrow <-> up from top of P
Syn:    box "syntactic" "corrector"
        arrow up
DMP:    box "diagnostic" "message" "printer"
        arrow <-> right  from east of DMP
ST:     box "symbol" "table"
        arrow from LC.ne to DMP.sw
        arrow from Sem.nw to DMP.se
        arrow <-> from Sem.top to ST.bot
}
set examples(174) {
# pikchr.org file doc/examples.md extract 09

        arrow "source" "code"
LA:     box "lexical" "analyzer"
        arrow "tokens" above
P:      box "parser"
        arrow "intermediate" "code" wid 200%
Sem:    box "semantic" "checker"
        arrow
        arrow <-> up from top of LA
LC:     box "lexical" "corrector"
        arrow <-> up from top of P
Syn:    box "syntactic" "corrector"
        arrow up
DMP:    box "diagnostic" "message" "printer"
        arrow <-> right  from east of DMP
ST:     box "symbol" "table"
        arrow from LC.ne to DMP.sw
        arrow from Sem.nw to DMP.se
        arrow <-> from Sem.top to ST.bot
}
set examples(175) {
# pikchr.org file tests/test41.pikchr

# Corner test

box "C"

$d = 1in
circle rad 50% "N" at $d n of C; arrow from last circle to C.n chop
circle same "NE" at $d ne of C; arrow from last circle to C.ne chop
circle same "E" at $d e of C; arrow from last circle to C.e chop
circle same "SE" at $d se of C; arrow from last circle to C.se chop
circle same "S" at $d s of C; arrow from last circle to C.s chop
circle same "SW" at $d sw of C; arrow from last circle to C.sw chop
circle same "W" at $d w of C; arrow from last circle to C.w chop
circle same "NW" at $d nw of C; arrow from last circle to C.nw chop

box "C" at 3*$d east of C radius 15px

circle rad 50% "N" at $d n of C; arrow from last circle to C.n chop
circle same "NE" at $d ne of C; arrow from last circle to C.ne chop
circle same "E" at $d e of C; arrow from last circle to C.e chop
circle same "SE" at $d se of C; arrow from last circle to C.se chop
circle same "S" at $d s of C; arrow from last circle to C.s chop
circle same "SW" at $d sw of C; arrow from last circle to C.sw chop
circle same "W" at $d w of C; arrow from last circle to C.w chop
circle same "NW" at $d nw of C; arrow from last circle to C.nw chop

ellipse "C" at 2.5*$d south of 1st box

circle rad 50% "N" at $d n of C; arrow from last circle to C.n chop
circle same "NE" at $d ne of C; arrow from last circle to C.ne chop
circle same "E" at $d e of C; arrow from last circle to C.e chop
circle same "SE" at $d se of C; arrow from last circle to C.se chop
circle same "S" at $d s of C; arrow from last circle to C.s chop
circle same "SW" at $d sw of C; arrow from last circle to C.sw chop
circle same "W" at $d w of C; arrow from last circle to C.w chop
circle same "NW" at $d nw of C; arrow from last circle to C.nw chop

circle "C" at 3*$d east of last ellipse

circle rad 50% "N" at $d n of C; arrow from last circle to C.n chop
circle same "NE" at $d ne of C; arrow from last circle to C.ne chop
circle same "E" at $d e of C; arrow from last circle to C.e chop
circle same "SE" at $d se of C; arrow from last circle to C.se chop
circle same "S" at $d s of C; arrow from last circle to C.s chop
circle same "SW" at $d sw of C; arrow from last circle to C.sw chop
circle same "W" at $d w of C; arrow from last circle to C.w chop
circle same "NW" at $d nw of C; arrow from last circle to C.nw chop

cylinder "C" at 2.5*$d south of last ellipse
circle rad 50% "N" at $d n of C; arrow from last circle to C.n chop
circle same "NE" at $d ne of C; arrow from last circle to C.ne chop
circle same "E" at $d e of C; arrow from last circle to C.e chop
circle same "SE" at $d se of C; arrow from last circle to C.se chop
circle same "S" at $d s of C; arrow from last circle to C.s chop
circle same "SW" at $d sw of C; arrow from last circle to C.sw chop
circle same "W" at $d w of C; arrow from last circle to C.w chop
circle same "NW" at $d nw of C; arrow from last circle to C.nw chop

oval "C" at 3*$d east of last cylinder
circle rad 50% "N" at $d n of C; arrow from last circle to C.n chop
circle same "NE" at $d ne of C; arrow from last circle to C.ne chop
circle same "E" at $d e of C; arrow from last circle to C.e chop
circle same "SE" at $d se of C; arrow from last circle to C.se chop
circle same "S" at $d s of C; arrow from last circle to C.s chop
circle same "SW" at $d sw of C; arrow from last circle to C.sw chop
circle same "W" at $d w of C; arrow from last circle to C.w chop
circle same "NW" at $d nw of C; arrow from last circle to C.nw chop

file "C" at 2.5*$d south of last cylinder
circle rad 50% "N" at $d n of C; arrow from last circle to C.n chop
circle same "NE" at $d ne of C; arrow from last circle to C.ne chop
circle same "E" at $d e of C; arrow from last circle to C.e chop
circle same "SE" at $d se of C; arrow from last circle to C.se chop
circle same "S" at $d s of C; arrow from last circle to C.s chop
circle same "SW" at $d sw of C; arrow from last circle to C.sw chop
circle same "W" at $d w of C; arrow from last circle to C.w chop
circle same "NW" at $d nw of C; arrow from last circle to C.nw chop

diamond "C" at 2.5*$d south of last oval
circle rad 50% "N" at $d n of C; arrow from last circle to C.n chop
circle same "NE" at $d ne of C; arrow from last circle to C.ne chop
circle same "E" at $d e of C; arrow from last circle to C.e chop
circle same "SE" at $d se of C; arrow from last circle to C.se chop
circle same "S" at $d s of C; arrow from last circle to C.s chop
circle same "SW" at $d sw of C; arrow from last circle to C.sw chop
circle same "W" at $d w of C; arrow from last circle to C.w chop
circle same "NW" at $d nw of C; arrow from last circle to C.nw chop
}
set examples(176) {
# pikchr.org file tests/test42.pikchr

C: ellipse "ellipse"

line from C to 2cm heading  00 from C chop;
line from C to 2cm heading  10 from C chop;
line from C to 2cm heading  20 from C chop;
line from C to 2cm heading  30 from C chop;
line from C to 2cm heading  40 from C chop;
line from C to 2cm heading  50 from C chop;
line from C to 2cm heading  60 from C chop;
line from C to 2cm heading  70 from C chop;
line from C to 2cm heading  80 from C chop;
line from C to 2cm heading  90 from C chop;
line from C to 2cm heading 100 from C chop;
line from C to 2cm heading 110 from C chop;
line from C to 2cm heading 120 from C chop;
line from C to 2cm heading 130 from C chop;
line from C to 2cm heading 140 from C chop;
line from C to 2cm heading 150 from C chop;
line from C to 2cm heading 160 from C chop;
line from C to 2cm heading 170 from C chop;
line from C to 2cm heading 180 from C chop;
line from C to 2cm heading 190 from C chop;
line from C to 2cm heading 200 from C chop;
line from C to 2cm heading 210 from C chop;
line from C to 2cm heading 220 from C chop;
line from C to 2cm heading 230 from C chop;
line from C to 2cm heading 240 from C chop;
line from C to 2cm heading 250 from C chop;
line from C to 2cm heading 260 from C chop;
line from C to 2cm heading 270 from C chop;
line from C to 2cm heading 280 from C chop;
line from C to 2cm heading 290 from C chop;
line from C to 2cm heading 300 from C chop;
line from C to 2cm heading 310 from C chop;
line from C to 2cm heading 320 from C chop;
line from C to 2cm heading 330 from C chop;
line from C to 2cm heading 340 from C chop;
line from C to 2cm heading 350 from C chop;
}
set examples(177) [UnguardBs {
# pikchr.org file tests/test43.pikchr

scale = 0.75
box "One"
arrow right 200% "Bold" bold above "Italic" italic below
circle "Two"
circle "Bold-Italic" bold italic aligned fit \\
   at 4cm heading 143 from Two
arrow from Two to last circle "above" aligned above "below" aligned below chop
circle "C2" fit at 4cm heading 50 from Two
arrow from Two to last circle "above" aligned above "below "aligned below chop
circle "C3" fit at 4cm heading 200 from Two
arrow from last circle to Two <- \\
  "above-rjust" aligned rjust above \\
  "below-rjust" aligned rjust below chop
}]
set examples(178) {
# pikchr.org file tests/test44.pikchr

debug=1
file "*.md" rad 20%
arrow
box rad 10px "Markdown" "Interpreter"
arrow right 120% "HTML" above
file " HTML "
}
set examples(179) [UnguardBs {
# pikchr.org file tests/test45.pikchr
# Deliberate Error: slight text overflow "ljust"

ALL: [
file "ljust" italic "*.md" ljust "*.txt" ljust "*.wiki" ljust rad 20%
arrow
box rad 10px "Markdown" mono ljust "Interpreter" monospace ljust \\
   "(monospace)" mono ljust italic fit
arrow right 200% "above" above "rjust " rjust below " ljust" ljust below
file "rjust" italic "*.htm" rjust "*.js" rjust
arrow down from first box.s "rjust " rjust " ljust" ljust
box "rjust" rjust above "center" center "ljust" ljust above \\
    "rjust" rjust below "ljust" ljust below big big
]
box invis "Text Justification Rules" big bold fit with .s at 0.2 above ALL.n
}]
set examples(180) [UnguardBs {
# pikchr.org file tests/test46.pikchr

# Test case for all production rule:
#
#     position ::= object edge
#
All: [

B: box dashed

circle ".n" fit at 1.5cm heading 0 from B.n
    arrow thin from previous to B.n chop
circle ".north" fit at 3cm heading 15 from B.north
    arrow thin from previous to B.north chop
circle ".t" fit at 1.5cm heading 30 from B.t
    arrow thin from previous to B.t chop
circle ".top" fit at 3cm heading -15 from B.top
    arrow thin from previous to B.top chop
circle ".ne" fit at 1cm ne of B.ne; arrow thin from previous to B.ne chop
circle ".e" fit at 2cm heading 50 from B.e; arrow thin from previous to B.e chop
circle ".right" fit at 3cm heading 75 from B.right
    arrow thin from previous to B.right chop
circle ".end&sup1;" fit at 3cm heading 100 from B.end
    arrow thin from previous to B.end chop
circle ".se" fit at 1cm heading 110 from B.se
    arrow thin from previous to B.se chop
circle ".s" fit at 1.5cm heading 180 from B.s
    arrow thin from previous to B.s chop
circle ".south" fit at 3cm heading 195 from B.south
    arrow thin from previous to B.south chop
circle ".bot" fit at 1.8cm heading 215 from B.bot
    arrow thin from previous to B.bot chop
circle ".bottom" fit at 2.7cm heading 160 from B.bottom
    arrow thin from previous to B.bottom chop
circle ".sw" fit at 1cm sw of B.sw; arrow thin from previous to B.sw chop
circle ".w" fit at 2cm heading 270 from B.w
    arrow thin from previous to B.w chop
circle ".left" fit at 3cm heading 180+75 from B.left
    arrow thin from previous to B.left chop
circle ".start&sup1;" fit at 2.5cm heading 295 from B.start
    arrow thin from previous to B.start chop
circle ".nw" fit at 1cm nw of B.nw; arrow thin from previous to B.nw chop
circle ".c" fit at 2.5cm heading -25 from B.c
    line thin from previous to 0.5<previous,B.c> chop
    arrow thin from previous.end to B.c
circle ".center" fit at 3.6cm heading 180-44 from B.center
    line thin from previous to 0.5<previous,B.center> chop
    arrow thin from previous.end to B.center
circle "&lambda;" fit at 2.5cm heading 250 from B
    line from previous to 0.5<previous,B> chop
    arrow thin from previous.end to B

]
"21 Names For 9 Boundary Points" big big with .s at .5cm above All.n
"&sup1; \"start\" and \"end\" assume a \"right\" layout direction" below \\
  with .n at 2mm below All.s
}]
set examples(181) [UnguardBs {
# pikchr.org file tests/test47.pikchr

# Test case for all production rule:
#
#     position ::= object edge
#
All: [

B: line thick thick color blue go 0.8 heading 350 then go 0.4 heading 120 \\
    then go 0.5 heading 35 \\
    then go 1.2 heading 190  then go 0.4 heading 340 "+"

   line thin dashed color gray from B.nw to B.ne to B.se to B.sw close

circle ".n" fit at 1.5cm heading 0 from B.n
    arrow thin from previous to B.n chop
circle ".north" fit at 3cm heading 15 from B.north
    arrow thin from previous to B.north chop
circle ".t" fit at 1.5cm heading 30 from B.t
    arrow thin from previous to B.t chop
circle ".top" fit at 3cm heading -15 from B.top
    arrow thin from previous to B.top chop
circle ".ne" fit at 1cm ne of B.ne; arrow thin from previous to B.ne chop
circle ".e" fit at 2cm heading 50 from B.e; arrow thin from previous to B.e chop
circle ".right" fit at 3cm heading 75 from B.right
    arrow thin from previous to B.right chop
circle ".end" fit at 2cm heading 120 from B.end
    arrow thin from previous to B.end chop
circle ".se" fit at 1cm heading 170 from B.se
    arrow thin from previous to B.se chop
circle ".s" fit at 1.5cm heading 180 from B.s
    arrow thin from previous to B.s chop
circle ".south" fit at 3cm heading 195 from B.south
    arrow thin from previous to B.south chop
circle ".bot" fit at 1.8cm heading 215 from B.bot
    arrow thin from previous to B.bot chop
circle ".bottom" fit at 2.7cm heading 160 from B.bottom
    arrow thin from previous to B.bottom chop
circle ".sw" fit at 1cm sw of B.sw; arrow thin from previous to B.sw chop
circle ".w" fit at 2cm heading 300 from B.w
    arrow thin from previous to B.w chop
circle ".left" fit at 3cm heading 280 from B.left
    arrow thin from previous to B.left chop
circle ".start" fit at 2.5cm heading 265 from B.start
    arrow thin from previous to B.start chop
circle ".nw" fit at 1cm nw of B.nw; arrow thin from previous to B.nw chop
circle ".c" fit at 2.5cm heading -15 from B.c
    line thin from previous to 0.5<previous,B.c> chop
    arrow thin from previous.end to B.c
circle ".center" fit at 3.3cm heading 110 from B.center
    line thin from previous to 0.5<previous,B.center> chop
    arrow thin from previous.end to B.center
circle "&lambda;" fit at 1.7cm heading 250 from B
    line from previous to 0.5<previous,B> chop
    arrow thin from previous.end to B

]
"21 Names For 11 Boundary Points" big big with .s at .5cm above All.n
}]
set examples(182) [UnguardBs {
# pikchr.org file tests/test47b.pikchr

# Test case for all production rule:
#
#     position ::= object edge
#
All: [

B: line thick thick color blue go 0.8 heading 350 then go 0.4 heading 120 \\
    then go 0.5 heading 35 \\
    then go 1.2 heading 190  then go 0.4 heading 340 close "+"

   line thin dashed color gray from B.nw to B.ne to B.se to B.sw close

circle ".n" fit at 1.5cm heading 0 from B.n
    arrow thin from previous to B.n chop
circle ".north" fit at 3cm heading 15 from B.north
    arrow thin from previous to B.north chop
circle ".t" fit at 1.5cm heading 30 from B.t
    arrow thin from previous to B.t chop
circle ".top" fit at 3cm heading -15 from B.top
    arrow thin from previous to B.top chop
circle ".ne" fit at 1cm ne of B.ne; arrow thin from previous to B.ne chop
circle ".e" fit at 2cm heading 50 from B.e; arrow thin from previous to B.e chop
circle ".right" fit at 3cm heading 75 from B.right
    arrow thin from previous to B.right chop
circle ".end" fit at 2cm heading 95 from B.end
    arrow thin from previous to B.end chop
circle ".se" fit at 1cm heading 170 from B.se
    arrow thin from previous to B.se chop
circle ".s" fit at 1.5cm heading 180 from B.s
    arrow thin from previous to B.s chop
circle ".south" fit at 3cm heading 195 from B.south
    arrow thin from previous to B.south chop
circle ".bot" fit at 1.8cm heading 215 from B.bot
    arrow thin from previous to B.bot chop
circle ".bottom" fit at 2.7cm heading 160 from B.bottom
    arrow thin from previous to B.bottom chop
circle ".sw" fit at 1cm sw of B.sw; arrow thin from previous to B.sw chop
circle ".w" fit at 2cm heading 300 from B.w
    arrow thin from previous to B.w chop
circle ".left" fit at 3cm heading 280 from B.left
    arrow thin from previous to B.left chop
circle ".start" fit at 2.5cm heading 265 from B.start
    arrow thin from previous to B.start chop
circle ".nw" fit at 1cm nw of B.nw; arrow thin from previous to B.nw chop
circle ".c" fit at 2.5cm heading -15 from B.c
    line thin from previous to 0.5<previous,B.c> chop
    arrow thin from previous.end to B.c
circle ".center" fit at 3.3cm heading 130 from B.center
    line thin from previous to 0.5<previous,B.center> chop
    arrow thin from previous.end to B.center
circle "&lambda;" fit at 1.7cm heading 250 from B
    line from previous to 0.5<previous,B> chop
    arrow thin from previous.end to B

]
"21 Names For 11 Boundary Points" big big above \\
    "On a closed polygon" above with .s at 0.2cm below All.n
}]
set examples(183) [UnguardBs {
# pikchr.org file tests/test48.pikchr

# Test case for all production rule:
#
#     position ::= object edge
#
All: [

B: line thick color blue go 0.8 heading 350 then go 0.4 heading 120 \\
    then go 0.5 heading 35 \\
    then go 1.2 heading 190  then go 0.4 heading 340 "+"


oval "1st vertex" fit at 2cm heading 250 from 1st vertex of B
    arrow thin from previous to 1st vertex of B chop
oval "2nd vertex" fit at 2cm west of 2nd vertex of B
    arrow thin from previous to 2nd vertex of B chop
oval "3rd vertex" fit at 2cm north of 3rd vertex of B
    arrow thin from previous to 3rd vertex of B chop
oval "4th vertex" fit at 2cm east of 4th vertex of B
    arrow thin from previous to 4th vertex of B chop
oval "5th vertex" fit at 2cm east of 5th vertex of B
    arrow thin from previous to 5th vertex of B chop
oval "6th vertex" fit at 2cm south of 6th vertex of B
    arrow thin from previous to 6th vertex of B chop


]
"Names Of Vertexes" big big with .s at .5cm above All.n
}]
set examples(184) {
# pikchr.org file tests/test49.pikchr

dot "A" above
dot "B" above at 3 heading 130 from A
dot "(A,B)" above at (A,B)
dot "(B,A)" above at (B,A)
}
set examples(185) [UnguardBs {
# pikchr.org file tests/test50.pikchr

All: [
CW: box "cwal"
line <-
S2: box "s2"
line <-
CL: box "client"
arc -> color red cw from CL.s to CW.s
]
text "Red arc is fully visible" "Pikchr forum 2020-09-14" \\
  with .s at 5mm above All.n
}]
set examples(186) [UnguardBs {
# pikchr.org file tests/test51.pikchr

One: [
CW: box "cwal"
line <-
S2: box "s2"
line <-
CL: box "client"
down
line ->
line -> left until even with CW
line -> color red go up to CW.s
]
text "Red line should be an arrow" "Pikchr forum 2020-09-14" \\
  with .s at 2mm above One.n

Two: [
right
CW: box "cwal"
line <-
S2: box "s2"
line <-
CL: box "client"
down
line ->
line -> left until even with CW
up
line -> to CW.s color red
] with .n at 1cm below One.s
}]
set examples(187) {
# pikchr.org file tests/test52.pikchr

All: [
  file "A"
  cylinder "B" at 5cm heading 125 from A
  X: line from A to B chop "from A to B" aligned above
  dot color red at X.c
  dot color red at X.start
  dot color red at X.end
]
"Text Alignment" big "On A Chopped Line" big with .s at .3cm above All.n
}
set examples(188) {
# pikchr.org file tests/test53.pikchr

line color green
dot color red
line color blue

text "\"dot\" object causes no motion" with .s at 8mm above last dot

assert( 1st dot.start == 1st dot.end )
assert( 1st line.end == 2nd line.start )
}
set examples(189) [UnguardBs {
# pikchr.org file tests/test55.pikchr

    lineht *= 0.4
    $margin = lineht*2.5
#    scale = 0.5
#    fontscale = 1.125
    down
In: box "Interface" wid 150% ht 75% fill white
    arrow
CP: box same "SQL Command" "Processor"
    arrow
VM: box same "Virtual Machine"
    arrow down 1.25*$margin
BT: box same "B-Tree"
    arrow
    box same "Pager"
    arrow
OS: box same "OS Interface"
    box same with .w at 1.25*$margin east of 1st box.e "Tokenizer"
    arrow
    box same "Parser"
    arrow
CG: box same ht 200% "Code" "Generator"
UT: box same as 1st box at (Tokenizer,Pager) "Utilities"
    move lineht
TC: box same "Test Code"
    arrow from CP to 1/4<Tokenizer.sw,Tokenizer.nw> chop
    arrow from 1/3<CG.nw,CG.sw> to CP chop

    box ht (In.n.y-VM.s.y)+$margin wid In.wid+$margin \\
       at CP fill 0xd8ecd0 behind In
    line invis from 0.25*$margin east of last.sw up last.ht \\
        "Core" italic aligned

    box ht (BT.n.y-OS.s.y)+$margin wid In.wid+$margin \\
       at Pager fill 0xd0ece8 behind In
    line invis from 0.25*$margin east of last.sw up last.ht \\
       "Backend" italic aligned

    box ht (Tokenizer.n.y-CG.s.y)+$margin wid In.wid+$margin \\
       at 1/2<Tokenizer.n,CG.s> fill 0xe8d8d0 behind In
    line invis from 0.25*$margin west of last.se up last.ht \\
       "SQL Compiler" italic aligned

    box ht (UT.n.y-TC.s.y)+$margin wid In.wid+$margin \\
       at 1/2<UT,TC> fill 0xe0ecc8 behind In
    line invis from 0.25*$margin west of last.se up last.ht \\
      "Accessories" italic aligned
}]
set examples(190) [UnguardBs {
# pikchr.org file doc/examples.md extract 03

    lineht *= 0.4
    $margin = lineht*2.5
    scale = 0.75
    fontscale = 1.1
    charht *= 1.15
    down
In: box "Interface" wid 150% ht 75% fill white
    arrow
CP: box same "SQL Command" "Processor"
    arrow
VM: box same "Virtual Machine"
    arrow down 1.25*$margin
BT: box same "B-Tree"
    arrow
    box same "Pager"
    arrow
OS: box same "OS Interface"
    box same with .w at 1.25*$margin east of 1st box.e "Tokenizer"
    arrow
    box same "Parser"
    arrow
CG: box same ht 200% "Code" "Generator"
UT: box same as 1st box at (Tokenizer,Pager) "Utilities"
    move lineht
TC: box same "Test Code"
    arrow from CP to 1/4<Tokenizer.sw,Tokenizer.nw> chop
    arrow from 1/3<CG.nw,CG.sw> to CP chop

    box ht (In.n.y-VM.s.y)+$margin wid In.wid+$margin \\
       at CP fill 0xd8ecd0 behind In
    line invis from 0.25*$margin east of last.sw up last.ht \\
        "Core" italic aligned

    box ht (BT.n.y-OS.s.y)+$margin wid In.wid+$margin \\
       at Pager fill 0xd0ece8 behind In
    line invis from 0.25*$margin east of last.sw up last.ht \\
       "Backend" italic aligned

    box ht (Tokenizer.n.y-CG.s.y)+$margin wid In.wid+$margin \\
       at 1/2<Tokenizer.n,CG.s> fill 0xe8d8d0 behind In
    line invis from 0.25*$margin west of last.se up last.ht \\
       "SQL Compiler" italic aligned

    box ht (UT.n.y-TC.s.y)+$margin wid In.wid+$margin \\
       at 1/2<UT,TC> fill 0xe0ecc8 behind In
    line invis from 0.25*$margin west of last.se up last.ht \\
      "Accessories" italic aligned
}]
set examples(191) [UnguardBs {
# pikchr.org file tests/test56.pikchr

    lineht *= 0.4
    $margin = lineht*2.5
    scale = 0.5
    fontscale = 1.125
    down
In: box "Interface" wid 150% ht 75% fill white
    arrow
CP: box same "SQL Command" "Processor"
    arrow
VM: box same "Virtual Machine"
    arrow down 1.25*$margin
BT: box same "B-Tree"
    arrow
    box same "Pager"
    arrow
OS: box same "OS Interface"
    box same with .w at 1.25*$margin east of 1st box.e "Tokenizer"
    arrow
    box same "Parser"
    arrow
CG: box same ht 200% "Code" "Generator"
UT: box same as 1st box at (Tokenizer,Pager) "Utilities"
    move lineht
TC: box same "Test Code"
    arrow from CP to 1/4<Tokenizer.sw,Tokenizer.nw> chop
    arrow from 1/3<CG.nw,CG.sw> to CP chop

    box ht (In.n.y-VM.s.y)+$margin wid In.wid+$margin \\
       at CP fill 0xd8ecd0 behind In
    line invis from 0.25*$margin east of last.sw up last.ht \\
        "Core" italic aligned

    box ht (BT.n.y-OS.s.y)+$margin wid In.wid+$margin \\
       at Pager fill 0xd0ece8 behind In
    line invis from 0.25*$margin east of last.sw up last.ht \\
       "Backend" italic aligned

    box ht (Tokenizer.n.y-CG.s.y)+$margin wid In.wid+$margin \\
       at 1/2<Tokenizer.n,CG.s> fill 0xe8d8d0 behind In
    line invis from 0.25*$margin west of last.se up last.ht \\
       "SQL Compiler" italic aligned

    box ht (UT.n.y-TC.s.y)+$margin wid In.wid+$margin \\
       at 1/2<UT,TC> fill 0xe0ecc8 behind In
    line invis from 0.25*$margin west of last.se up last.ht \\
      "Accessories" italic aligned
}]
set examples(192) {
# pikchr.org file tests/test57a.pikchr

line up 25% "aligned centered above" above aligned
}
set examples(193) {
# pikchr.org file tests/test57b.pikchr

line up 25% "aligned ljust above" above aligned ljust
}
set examples(194) {
# pikchr.org file tests/test57c.pikchr

line up 25% "aligned rjust below" aligned rjust below
}
set examples(195) {
# pikchr.org file tests/gridlines1.pikchr

# Gridlines
# (Copied, with modifications, from a post by Steve Nicolai.
#
thickness *= 0.5

line color gray from -1.25, 1 to 1.25, 1
line same from -1.25, .5 to 1.25, .5
line same from -1.25, -0.5 to 1.25, -0.5
line same from -1.25, -1 to 1.25, -1

line same from -1.0, -1.25 to -1.0, 1.25
line same from -0.5, -1.25 to -0.5, 1.25
line same from 0.5, -1.25 to 0.5, 1.25
line same from 1.0, -1.25 to 1.0, 1.25

right
arrow from -1.375, 0 to 1.375, 0 thick
text "x" fit
up
arrow from 0, -1.375 to 0, 1.375 thick
text "y" fit
}
set examples(196) {
# pikchr.org file tests/test59.pikchr

box "1cm top" "2cm bottom" "3cm right" "4cm left" fit
topmargin = 1cm
bottommargin = 2cm
rightmargin = 3cm
leftmargin = 4cm
}
set examples(197) {
# pikchr.org file tests/test64.pikchr

# Macro created within another macro
define dodef {
  define $1 {box "Hello"}
}
dodef(xyz)
xyz
rightmargin = 2in
print "Should just say 'hello'"
}
set examples(198) {
# pikchr.org file tests/test65.pikchr

box "autofit" "width" width 0
move
box "autofit" "height" height 0
move
box "autofit" "both" width 0 height 0
move
box "manual" "fit" fit
move
box "none"

move to 1in below first box.w
right
circle "autofit" "width" width 0
move
circle "autofit" "height" height 0
move
circle "autofit" "both" width 0 height 0
move
circle "manual" "fit" "test" fit
move
circle "none"

move to 1in below first circle.w
right
ellipse "autofit" "width" width 0
move
ellipse "autofit" "height" height 0
move
ellipse "autofit" "both" width 0 height 0
move
ellipse "a new" "manual fit test" "experiment" fit
move
ellipse "none"

move to 1in below first ellipse.w
right
cylinder "autofit" "width" width 0
move
cylinder "autofit" "height" height 0
move
cylinder "autofit" "both" width 0 height 0
move
cylinder "manual" "fit" fit
move
cylinder "none"

move to 1in below first cylinder.w
right
file "autofit" "width" width 0
move
file "autofit" "height" height 0
move
file "autofit" "both" width 0 height 0
move
file "manual" "fit" fit
move
file "none"

move to 1in below first file.w
right
oval "autofit" "width" width 0
move
oval "autofit" "height" height 0
move
oval "autofit" "both" width 0 height 0
move
oval "manual" "fit" fit
move
oval "none"

move to 1in below first oval.w
right
diamond "diamond" "autofit" "width" width 0
move 50%
diamond "autofit height" height 0
move same
diamond  "both" width 0 height 0
move same
diamond "fit" fit
move same
diamond "diamond" "wihtout autofit"
}
set examples(199) {
# pikchr.org file tests/test66.pikchr

boxwid = -1; boxht = -1;  /* Autofit boxes */
box "Testing \\backslash\\ support" "Also \"autofit\""
move
box "\a\b\c\f\t\n"
}
set examples(200) {
# pikchr.org file tests/test67.pikchr

box invis "invis"
move
box same solid "same" "solid"
move
box thin "thin"
move
box same solid "same" "solid"
}
set examples(201) {
# pikchr.org file tests/test68.pikchr

# Nested macros
define m00 {box $1 $2 $3 fit;}
define m01 {m00("m01",$1,$2);}
m01("one","two")
}
set examples(202) [UnguardBs {
# pikchr.org file tests/test69.pikchr

# Font size layout tests
#
box "small*2"  small small fit
move 10%
box "small" small fit
move same
box "normal" fit
move same
box "big" big fit
move same
box "big*2" big big fit
move to 2cm below 1st box.w
box "very small" small small "small" small "normal" \\
     "big" big "very big"  big big fit
move
box "Very big" big big "big" big "normal" \\
    "small" small "very small" small small fit
}]
set examples(203) {
# pikchr.org file tests/test70.pikchr

    fill = bisque
B1: box "Pointy" "Diamond" width 150% invis
    line from B1.w to B1.n to B1.e to B1.s close behind B1 rad 0px
    move
B2: box "Rounded" "Diamond" width 150% invis with .w at 1cm right of B1.e
    line from B2.w to B2.n to B2.e to B2.s close behind B2 rad 20px

    dot fill red at 1st line.start
    dot fill red at last line.start
}
set examples(204) [UnguardBs {
# pikchr.org file tests/test71.pikchr

      fill = bisque
      linerad = 15px
      leftmargin = 2cm

      oval "SUBMIT TICKET" width 150%
      down
      arrow 50%
NEW:  file "New bug ticket" "marked \"Open\"" fit
      arrow same
      box "Triage," "augment &" "correct" fit
      arrow same
DC:   box "Developer comments" fit
      arrow same
FR:   box "Filer responds" fit
      arrow 100%
REJ:  diamond "Reject?"
      right
      arrow 100% "Yes" above
      box "Mark ticket" "\"Rejected\" &" "\"Resolved\"" fit with .w at previous.e
      arrow right 50%
REJF: file "Rejected" "ticket" fit
      arrow right 50%
REOP: diamond "Reopen?"
      down
REJA: arrow 75% from REJ.s "  No; fix it" ljust
CHNG: box "Developer changes code" with .n at last arrow.s fit
      arrow 50%
FIXD: diamond "Fixed?"
      right
FNO:  arrow "No" above
RES:  box "Optional:" "Update ticket resolution:" "\"Partial Fix\", etc." fit
      down
      arrow 75% "  Yes" ljust from FIXD.s
      box "Mark ticket" "\"Fixed\" & \"Closed\"" fit
      arrow 50%
RESF: file "Resolved ticket" fit
      arrow same
      oval "END"

      line from 0.3<FR.ne,FR.se> right even with 0.25 right of DC.e then \\
          up even with DC.e then to DC.e ->

      line from NEW.w left 0.5 then down even with REJ.w then to REJ.w ->
      line invis from 2nd vertex of last line to 3rd vertex of last line \\
          "fast reject path" above aligned

      line from RES.e right 0.3 then up even with CHNG.e then to CHNG.e ->

      line from REOP.s "No" aligned above down 0.4
      line from previous.s down to (previous.s, RESF.e) then to RESF.e ->

      line from REOP.n "Yes" aligned below up 0.3
      line from previous.n up even with 0.6<FR.ne,FR.se> then to 0.6<FR.ne,FR.se> ->
}]
set examples(205) {
# pikchr.org file tests/test72.pikchr

C1: cylinder "radius 0%" rad 0
move
cylinder "radius 50%" rad 50%
move
cylinder "radius 100%"

C1B: cylinder "fit 0%" rad 0 fit with .n at 0.5cm below C1.s
move
cylinder "fit 50%" rad 50% fit
move
cylinder "fit 100%" fit

C2: cylinder "radius 125%" rad 125% with .n at 0.5cm below C1B.s
move
cylinder "radius 150%" rad 150%
move
cylinder "radius 200%" rad 200%

C3: cylinder "fit 125%" rad 125% with .n at 0.5cm below C2.s fit
move
cylinder "fit 150%" rad 150% fit
move
cylinder "fit 200%" rad 200% fit

C4: cylinder "fit" "80%" rad 80% with .n at 0.5cm below C3.s fit
move
cylinder "fit" "120%" rad 120% fit
move
cylinder "fit" "150%" rad 150% fit
}
set examples(206) {
# pikchr.org file tests/test73.pikchr
# Deliberate Error: overflowing text

/* Large radius on cylinders
** Forum post 983b36dbcf  2021-01-31
*/
C1: cylinder "rad 0%" rad 0
move
cylinder "rad 50%" rad 50%
move
cylinder "rad 100%"

C1b: cylinder "rad +1cm" rad +1cm with .n at 0.5cm below C1.s
move
cylinder "rad -1cm" rad -1cm
move
cylinder "rad -10px" rad -10px

C2: cylinder "fit 0%" rad 0 fit with .n at 1cm below C1b.s
move
cylinder "fit 200%" rad 200% fit
move
cylinder "fit 300%" rad 300% fit

C3: cylinder "fit 400%" rad 400% fit with .n at 0.5cm below C2.s
move
cylinder "fit +10px" rad +10px fit
move
cylinder "fit -10px" rad -10px fit

C4: cylinder "fit 1000%" rad 1000% fit with .n at 0.5cm below C3.s
move
cylinder "fit +1cm" rad +1cm fit
move
cylinder "fit -1cm" rad -1cm fit
}
set examples(207) [UnguardBs {
# pikchr.org file tests/test74.pikchr

/* Use of the "this" objectname
*/
A: box "a" fit ht this.wid
B: box "bbbb" fit ht this.wid with .sw at previous.se
C: box "ccccccccc" fit ht this.wid with .sw at previous.se

D: box "a" fit ht this.wid rad 0.25*this.wid \\
     with .n at 1cm below A.s
E: box "bbbb" fit ht this.wid rad 0.25*this.wid \\
     with .n at (previous.e.x+0.5*this.width, previous.n.y)
F: box "ccccccccc" fit ht this.wid rad 0.25*this.wid \\
     with .n at (previous.e.x+0.5*this.wid, previous.n.y)
}]
set examples(208) {
# pikchr.org file tests/test75.pikchr

box "Alternative spellings for arrow tokens <-, ->, and <->" invis fit
line &rarr; "&amp;rarr;" above from (previous.s.x-1.5cm,previous.s.y-0.75cm) right 3cm;
line &rightarrow; "&amp;rightarrow;" above from 0.75cm below previous.start right 3cm;
line → "→" above from 0.75cm below previous.start right 3cm;
line &larr; "&amp;larr;" above from 0.75cm below previous.start right 3cm;
line &leftarrow; "&amp;leftarrow;" above from 0.75cm below previous.start right 3cm;
line ← "←" above from 0.75cm below previous.start right 3cm;
line &leftrightarrow; "&amp;leftrightarrow;" above from 0.75cm below previous.start right 3cm;
line ↔ "↔" above from 0.75cm below previous.start right 3cm;
}
set examples(209) {
# pikchr.org file tests/test76.pikchr

box "Function test" width 5cm
pi = 3.1415926
print "abs(-10):",abs(-10)
print "cos(pi/3):",cos(pi/3)
print "int(18.5):",int(18.5)
print "max(5,-18.23):", max(5,-18.23)
print "min(5,-18.23):", min(5,-18.23)
print "sin(pi/6):",sin(pi/6)
print "sqrt(16):",sqrt(16)
}
set examples(210) [UnguardBs {
# pikchr.org file tests/test77.pikchr

arrow right
box width 2*boxht "Start"
arrow
box same "Right"
move to 1st box.s
down
arrow
box same "Down"
arrow
box same "Should continue down" "from \"Down\"" "not to the right!" \\
         "See forum post 75a2220c44" "on 2023-08-12" fit
}]
set examples(211) {
# pikchr.org file tests/test78.pikchr

down
text "Zero Thickness Objects"
box "Box" fill lightblue thickness 0 fit
circle "Circle" fill yellow thickness 0 fit
file "File" fill lightgreen thickness 0 fit
oval "Oval 1" fill pink thickness 0 fit
oval "Oval 2" fill lightgrey width 1.1cm height 2cm thickness 0
cylinder "Cylinder" fill orange fit thickness 0
diamond "Diamond" fill lightblue fit thickness 0
}
set examples(212) {
# pikchr.org file tests/test79.pikchr

box "Negative" "Thickness" "Lines" fit
move
arrow "above" above "below" below
move
arrow "above" above "below" below thickness -0.1
move
arrow "above" above "below" below thickness -0.2
}
set examples(213) [UnguardBs {
# pikchr.org file tests/test80.pikchr

TITLE: text "'with .start at' tests..." \\
            "Top row should match bottom row" \\
            "Forum post a48fbe155b on 2024-06-25" fit

B1: box with .nw at 1cm below TITLE.sw
C1: circle with .start at B1.end

B2: box with .n at 3cm below B1.n
C2: circle

down
B3: box with .w at 1cm right of C1.e
C3: circle with .start at B3.end

B4: box with .n at 3cm below B3.n
C4: circle

left
B5: box with .n at 4cm right of B3.n
C5: circle with .start at B5.end

B6: box with .n at 3cm below B5.n
C6: circle

up
B7: box with .n at 2.5cm right of B5.s
C7: circle with .start at B7.end

B8: box with .n at 3cm below B7.n
C7: circle
}]
set examples(214) [UnguardBs {
# pikchr.org file tests/test81.pikchr

text "Box B should full sized - not fit-to-text." \\
     "See forum post f9f5d90f33 on 2025-03-03."
down
text "A"
box "B" with nw at A.e
}]
set examples(215) {
# textForSvg test file debug-labels.pikchr

  D1: dot color red 
  arrow go 150% heading 90 "aligned" aligned above
  arrow go 150% heading 0 "aligned" aligned above from D1
  arrow go 150% heading 270 "aligned" aligned above from D1
  arrow go 150% heading 180 "aligned" aligned above from D1
  move to 4cm east of D1

  D2: dot color red
  arrow go 150% heading 45 "aligned" aligned above from D2
  arrow go 150% heading 315 "aligned" aligned above from D2
  arrow go 150% heading 225 "aligned" aligned above from D2
  arrow go 150% heading 135 "aligned" aligned above from D2
}
set examples(216) {
# pikchr.org forum post

O: text "DREAMS" color grey
circle rad 0.9 at 0.6 above O thick color red
text "INEXPENSIVE" big bold at 0.9 above O color red
circle rad 0.9   at 0.6 heading  120 from O thick color green
text "FAST" big bold at 0.9 heading  120 from O  color green
circle rad 0.9 at 0.6 heading -120 from O thick color blue
text "HIGH" big bold "QUALITY" big bold at 0.9 heading  -120 from O  color blue
text "EXPENSIVE" at 0.55 below O  color cyan
text "SLOW" at 0.55 heading  -60 from O  color magenta
text "POOR" "QUALITY" at 0.55 heading   60 from O  color gold
}
set examples(217) [UnguardBs {
# pikchr.org forum post by user pskechr on 2025-06-04
# https://pikchr.org/home/forumpost/33c0c524893390e6

[
[
layer = 2
X: line from (-1.875in+arrowwid,0) to (1.875in-arrowwid,0) thin thin color darkgrey
line from arrowwid left of X.start then right arrowwid color darkgrey <-
line from X.end then right arrowwid color darkgrey ->
text "x" italic with n at X.end color darkgrey
Y: line from (0,-1.875in+arrowwid) to (0,1.875in-arrowwid) thin thin color darkgrey
line from arrowwid below Y.start then up arrowwid color darkgrey <-
line from Y.end then up arrowwid color darkgrey ->
text "y " italic with e at Y.end color darkgrey

layer = 5
O1: circle with c at (0,0) width 0.05in thin color red fill pink
text "O₁" italic with c at 0.16in heading 47 from O1.c color red
O2: circle with c at O1.c+(-0.2in,0) width 0.05in thin color blue fill lightblue
text "O₂" italic with c at 0.14in heading 160 from O2.c color blue

layer = 3
C1: circle with c at O1.c radius 1.625in thin dashed 0.025in color red
text "C₁" italic with c at 0.12in heading 60 from C1.radius heading 60 from C1.c color red
C2: circle with c at O2.c radius 1.25in thin dashed 0.025in color blue
text "C₂" italic with c at 0.1in heading 240 from C2.radius heading 60 from C2.c color blue

define drawNewtonTransform {
   layer = 5
   P1: circle same as O1 with c at C1.radius heading $1 from C1.c
   P2: circle same as O2 with c at C2.radius/dist(C2.c,P1) between C2.c and P1
   Q: circle with c at (P1,P2) width 0.05in thin color black fill lightgrey
   
   layer = 3
   line from C2.c then to P1 then to Q then to P2 thin dashed 0.025in
}

drawNewtonTransform(23.881)
drawNewtonTransform(123.528)
layer = 5
text "P₁" italic with c at 0.13in heading 120 from P1.c color red 
text "P₂" italic with c at 0.17in heading 263 from P2.c color blue
text "Q" italic with c at 0.14in heading -30 from Q.c color black
drawNewtonTransform(216.119)
drawNewtonTransform(296.472)

layer = 4
FE: line \\
from    (C1.radius heading 5*0  from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*0  from C1.c) between C2.c and C1.radius heading 5*0  from C1.c) \\
then to (C1.radius heading 5*1  from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*1  from C1.c) between C2.c and C1.radius heading 5*1  from C1.c) \\
then to (C1.radius heading 5*2  from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*2  from C1.c) between C2.c and C1.radius heading 5*2  from C1.c) \\
then to (C1.radius heading 5*3  from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*3  from C1.c) between C2.c and C1.radius heading 5*3  from C1.c) \\
then to (C1.radius heading 5*4  from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*4  from C1.c) between C2.c and C1.radius heading 5*4  from C1.c) \\
then to (C1.radius heading 5*5  from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*5  from C1.c) between C2.c and C1.radius heading 5*5  from C1.c) \\
then to (C1.radius heading 5*6  from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*6  from C1.c) between C2.c and C1.radius heading 5*6  from C1.c) \\
then to (C1.radius heading 5*7  from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*7  from C1.c) between C2.c and C1.radius heading 5*7  from C1.c) \\
then to (C1.radius heading 5*8  from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*8  from C1.c) between C2.c and C1.radius heading 5*8  from C1.c) \\
then to (C1.radius heading 5*9  from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*9  from C1.c) between C2.c and C1.radius heading 5*9  from C1.c) \\
then to (C1.radius heading 5*10 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*10 from C1.c) between C2.c and C1.radius heading 5*10 from C1.c) \\
then to (C1.radius heading 5*11 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*11 from C1.c) between C2.c and C1.radius heading 5*11 from C1.c) \\
then to (C1.radius heading 5*12 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*12 from C1.c) between C2.c and C1.radius heading 5*12 from C1.c) \\
then to (C1.radius heading 5*13 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*13 from C1.c) between C2.c and C1.radius heading 5*13 from C1.c) \\
then to (C1.radius heading 5*14 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*14 from C1.c) between C2.c and C1.radius heading 5*14 from C1.c) \\
then to (C1.radius heading 5*15 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*15 from C1.c) between C2.c and C1.radius heading 5*15 from C1.c) \\
then to (C1.radius heading 5*16 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*16 from C1.c) between C2.c and C1.radius heading 5*16 from C1.c) \\
then to (C1.radius heading 5*17 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*17 from C1.c) between C2.c and C1.radius heading 5*17 from C1.c) \\
then to (C1.radius heading 5*18 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*18 from C1.c) between C2.c and C1.radius heading 5*18 from C1.c) \\
then to (C1.radius heading 5*19 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*19 from C1.c) between C2.c and C1.radius heading 5*19 from C1.c) \\
then to (C1.radius heading 5*20 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*20 from C1.c) between C2.c and C1.radius heading 5*20 from C1.c) \\
then to (C1.radius heading 5*21 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*21 from C1.c) between C2.c and C1.radius heading 5*21 from C1.c) \\
then to (C1.radius heading 5*22 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*22 from C1.c) between C2.c and C1.radius heading 5*22 from C1.c) \\
then to (C1.radius heading 5*23 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*23 from C1.c) between C2.c and C1.radius heading 5*23 from C1.c) \\
then to (C1.radius heading 5*24 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*24 from C1.c) between C2.c and C1.radius heading 5*24 from C1.c) \\
then to (C1.radius heading 5*25 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*25 from C1.c) between C2.c and C1.radius heading 5*25 from C1.c) \\
then to (C1.radius heading 5*26 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*26 from C1.c) between C2.c and C1.radius heading 5*26 from C1.c) \\
then to (C1.radius heading 5*27 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*27 from C1.c) between C2.c and C1.radius heading 5*27 from C1.c) \\
then to (C1.radius heading 5*28 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*28 from C1.c) between C2.c and C1.radius heading 5*28 from C1.c) \\
then to (C1.radius heading 5*29 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*29 from C1.c) between C2.c and C1.radius heading 5*29 from C1.c) \\
then to (C1.radius heading 5*30 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*30 from C1.c) between C2.c and C1.radius heading 5*30 from C1.c) \\
then to (C1.radius heading 5*31 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*31 from C1.c) between C2.c and C1.radius heading 5*31 from C1.c) \\
then to (C1.radius heading 5*32 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*32 from C1.c) between C2.c and C1.radius heading 5*32 from C1.c) \\
then to (C1.radius heading 5*33 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*33 from C1.c) between C2.c and C1.radius heading 5*33 from C1.c) \\
then to (C1.radius heading 5*34 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*34 from C1.c) between C2.c and C1.radius heading 5*34 from C1.c) \\
then to (C1.radius heading 5*35 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*35 from C1.c) between C2.c and C1.radius heading 5*35 from C1.c) \\
then to (C1.radius heading 5*36 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*36 from C1.c) between C2.c and C1.radius heading 5*36 from C1.c) \\
then to (C1.radius heading 5*37 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*37 from C1.c) between C2.c and C1.radius heading 5*37 from C1.c) \\
then to (C1.radius heading 5*38 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*38 from C1.c) between C2.c and C1.radius heading 5*38 from C1.c) \\
then to (C1.radius heading 5*39 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*39 from C1.c) between C2.c and C1.radius heading 5*39 from C1.c) \\
then to (C1.radius heading 5*40 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*40 from C1.c) between C2.c and C1.radius heading 5*40 from C1.c) \\
then to (C1.radius heading 5*41 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*41 from C1.c) between C2.c and C1.radius heading 5*41 from C1.c) \\
then to (C1.radius heading 5*42 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*42 from C1.c) between C2.c and C1.radius heading 5*42 from C1.c) \\
then to (C1.radius heading 5*43 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*43 from C1.c) between C2.c and C1.radius heading 5*43 from C1.c) \\
then to (C1.radius heading 5*44 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*44 from C1.c) between C2.c and C1.radius heading 5*44 from C1.c) \\
then to (C1.radius heading 5*45 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*45 from C1.c) between C2.c and C1.radius heading 5*45 from C1.c) \\
then to (C1.radius heading 5*46 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*46 from C1.c) between C2.c and C1.radius heading 5*46 from C1.c) \\
then to (C1.radius heading 5*47 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*47 from C1.c) between C2.c and C1.radius heading 5*47 from C1.c) \\
then to (C1.radius heading 5*48 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*48 from C1.c) between C2.c and C1.radius heading 5*48 from C1.c) \\
then to (C1.radius heading 5*49 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*49 from C1.c) between C2.c and C1.radius heading 5*49 from C1.c) \\
then to (C1.radius heading 5*50 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*50 from C1.c) between C2.c and C1.radius heading 5*50 from C1.c) \\
then to (C1.radius heading 5*51 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*51 from C1.c) between C2.c and C1.radius heading 5*51 from C1.c) \\
then to (C1.radius heading 5*52 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*52 from C1.c) between C2.c and C1.radius heading 5*52 from C1.c) \\
then to (C1.radius heading 5*53 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*53 from C1.c) between C2.c and C1.radius heading 5*53 from C1.c) \\
then to (C1.radius heading 5*54 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*54 from C1.c) between C2.c and C1.radius heading 5*54 from C1.c) \\
then to (C1.radius heading 5*55 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*55 from C1.c) between C2.c and C1.radius heading 5*55 from C1.c) \\
then to (C1.radius heading 5*56 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*56 from C1.c) between C2.c and C1.radius heading 5*56 from C1.c) \\
then to (C1.radius heading 5*57 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*57 from C1.c) between C2.c and C1.radius heading 5*57 from C1.c) \\
then to (C1.radius heading 5*58 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*58 from C1.c) between C2.c and C1.radius heading 5*58 from C1.c) \\
then to (C1.radius heading 5*59 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*59 from C1.c) between C2.c and C1.radius heading 5*59 from C1.c) \\
then to (C1.radius heading 5*60 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*60 from C1.c) between C2.c and C1.radius heading 5*60 from C1.c) \\
then to (C1.radius heading 5*61 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*61 from C1.c) between C2.c and C1.radius heading 5*61 from C1.c) \\
then to (C1.radius heading 5*62 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*62 from C1.c) between C2.c and C1.radius heading 5*62 from C1.c) \\
then to (C1.radius heading 5*63 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*63 from C1.c) between C2.c and C1.radius heading 5*63 from C1.c) \\
then to (C1.radius heading 5*64 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*64 from C1.c) between C2.c and C1.radius heading 5*64 from C1.c) \\
then to (C1.radius heading 5*65 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*65 from C1.c) between C2.c and C1.radius heading 5*65 from C1.c) \\
then to (C1.radius heading 5*66 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*66 from C1.c) between C2.c and C1.radius heading 5*66 from C1.c) \\
then to (C1.radius heading 5*67 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*67 from C1.c) between C2.c and C1.radius heading 5*67 from C1.c) \\
then to (C1.radius heading 5*68 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*68 from C1.c) between C2.c and C1.radius heading 5*68 from C1.c) \\
then to (C1.radius heading 5*69 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*69 from C1.c) between C2.c and C1.radius heading 5*69 from C1.c) \\
then to (C1.radius heading 5*70 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*70 from C1.c) between C2.c and C1.radius heading 5*70 from C1.c) \\
then to (C1.radius heading 5*71 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*71 from C1.c) between C2.c and C1.radius heading 5*71 from C1.c) \\
then to (C1.radius heading 5*72 from C1.c, C2.radius/dist(C2.c,C1.radius heading 5*72 from C1.c) between C2.c and C1.radius heading 5*72 from C1.c) \\
close color black fill none
line from FE.start same as FE color none fill whitesmoke behind X
text "Fₑ" italic with c at 0.11 heading 190 from (C1.radius heading 45 from C1.c, C2.radius/dist(C2.c,C1.radius heading 45 from C1.c) between C2.c and C1.radius heading 45 from C1.c)
]

[
A: box width 0.1875in height 0.2in "O₁" italic rjust thin thin invisible color red
B: box width 2.14in height 0.2in " = Center of 1ˢᵗ circle" ljust with w at 0.04in left of previous.e thin thin invisible color red
box same as A "C₁" italic rjust with ne at 0.04in above 2nd previous box .se color red 
box same as B " = Circumference of 1ˢᵗ circle" ljust with w at 0.04in left of previous.e color red
box same as A "P₁" italic rjust with ne at 0.04in above 2nd previous box .se color red
box same as B " = Point on C₁" ljust with w at 0.04in left of previous.e color red
box same as A "O₂" italic rjust with ne at 0.04in above 2nd previous box .se color blue
box same as B " = Center of 2ⁿᵈ circle" ljust with w at 0.04in left of previous.e color blue
box same as A "C₂" italic rjust with ne at 0.04in above 2nd previous box .se color blue
box same as B " = Circumference of 2ⁿᵈ circle" ljust with w at 0.04in left of previous.e color blue
box same as A "P₂" italic rjust with ne at 0.04in above 2nd previous box .se color blue
box same as B " = Point at intersection of line O₂P₁ and C₂" ljust with w at 0.04in left of previous.e color blue
box same as A "Q " italic rjust with ne at 0.04in above 2nd previous box .se color black
box same as B " = Point at (P₁.x, P₂.y)" ljust with w at 0.04in left of previous.e color black
box same as A "Fₑ" italic rjust with ne at 0.04in above 2nd previous box .se color black
box same as B " = All Q for all P₁, P₂" ljust with w at 0.04in left of previous.e color black
] with nw at previous.ne+(0.375in,-0.125in)
box with c at previous.c width previous.width+0.0625in height previous.height+0.0625in thin thin color darkgrey
]
text "Hügelschäffer egg curve" with n at 0.0625in below previous.s
}]
set examples(218) {
# pikchr.org forum post by user notlibrary on 2023-09-04
# https://pikchr.org/home/forumpost/14b4cd4c04ea1daf

#"Quiver" macro example by @notlibrary
define quiver {
	dot invis at 0.5 < $1.ne , $1.e >
	dot invis at 0.5 < $1.nw , $1.w >
	dot invis at 0.5 < $1.se , $1.e >
	dot invis at 0.5 < $1.sw , $1.w >

	dot at $2 right of 4th previous dot
        dot at $3 right of 4th previous dot
	dot at $4 right of 4th previous dot
        dot at $5 right of 4th previous dot
    
	arrow <- from previous dot to 2nd previous dot   
	arrow -> from 3rd previous dot to 4th previous dot   
	  
}

define show_compass_l {
	dot color red  at $1.e " .e" ljust
	dot same at $1.ne " .ne" ljust above
	line thick color green from previous to 2nd last dot
}

define show_compass_r {
	dot color red  at $1.w " .w" ljust
	dot same at $1.nw " .nw" ljust above 
	line thick color green from previous to 2nd last dot
}

PROGRAM: file "Program" rad 45px
show_compass_l(PROGRAM)
QUIVER: box invis ht 0.75 
DATABASE: oval "Database" ht 0.75 wid 1.1
show_compass_r(DATABASE)

quiver(QUIVER, 5px, -5px, 5px, 0px)

text "Query" with .c at 0.1in above last arrow
text "Records" with .c at 0.1in below 2nd last arrow 
}
set examples(219) [UnguardBs {
# pikchr.org forum post by Mike Swanson (user chungy) on 2025-04-23
# With revisions by Zellyn Hunter (user zellyn)
# https://pikchr.org/home/forumpost/71d6ebf831
# No text!  A honeycomb design.

define $hex {
  line from previous.e go 0.25cm heading 0 \\
       then 0.5cm heading 60 \\
       then 0.5cm heading 120 \\
       then 0.5cm heading 180 \\
       then 0.5cm heading 240 \\
       then 0.5cm heading 300 \\
       then 0.25cm heading 0 color gold close fill goldenrod
}

define $new_longer_row {
line from $1.w go 0.25cm heading 180 invis
$2: line from previous.s go 0.5cm heading 240 \\
       then 0.5cm heading 180 \\
       then 0.5cm heading 120 \\
       then 0.5cm heading 60 \\
       then 0.5cm heading 0 color gold close fill goldenrod
}

define $new_shorter_row {
$2: line from $1.s go 0.5cm heading 180 \\
       then 0.5cm heading 120 \\
       then 0.5cm heading 60 \\
       then 0.5cm heading 0 \\
       then 0.5cm heading 300 color gold close fill goldenrod
}

H0: dot invis

$new_shorter_row(H0, H1); $hex(); $hex(); $hex();
$new_longer_row(H1, H2); $hex(); $hex(); $hex(); $hex();
$new_longer_row(H2, H3); $hex(); $hex(); $hex(); $hex(); $hex();
$new_longer_row(H3, H4); $hex(); $hex(); $hex(); $hex(); $hex(); $hex();
$new_shorter_row(H4, H5); $hex(); $hex(); $hex(); $hex(); $hex();
$new_shorter_row(H5, H6); $hex(); $hex(); $hex(); $hex();
$new_shorter_row(H6, H7); $hex(); $hex(); $hex();
}]
set examples(220) [UnguardBs {
# pikchr.org forum post by user anonymous on 2025-05-01
# With revisions by Zellyn Hunter (user zellyn)
# https://pikchr.org/home/forumpost/1e49ae8b3e
# No text! The (new) Minnesota flag.

@NightSkyBlue = 0x002D5D
@WaterBlue = 0x52C9E8
@White = 0xFFFFFF
@N = 1.875in

A: box \\
   with nw at (0,0) \\
   width 5/3*@N \\
   height @N \\
   color @NightSkyBlue fill @NightSkyBlue thin thin

B: line \\
   from A.nw+(14/15*@N,0) \\
   then to A.ne \\
   then to A.se \\
   then left until even with A.nw+(14/15*@N,0) \\
   then up 1/2*@N left (14/15-13/20)*@N \\
   close \\
   color @WaterBlue fill @WaterBlue thin thin

C: A.nw+(21/60*@N,-1/2*@N)

C: line \\
   from    11/30/2*@N heading 0*360/8 from C \\
   then to 11/30/2*@N heading 3*360/8 from C \\
   then to 11/30/2*@N heading 6*360/8 from C \\
   then to 11/30/2*@N heading 1*360/8 from C \\
   then to 11/30/2*@N heading 4*360/8 from C \\
   then to 11/30/2*@N heading 7*360/8 from C \\
   then to 11/30/2*@N heading 2*360/8 from C \\
   then to 11/30/2*@N heading 5*360/8 from C \\
   close \\
   color @White fill @White thin thin
}]
#indent+4

    if {[array size examples] != $totalExamples} {
        ReportError "Expected $totalExamples examples; have [array size examples]."
    }

    return
}

proc GuardBs {in} {
    set map [list \\\n \\\\\n]
    string map $map $in
}

proc UnguardBs {in} {
    set map [list \\\\\n \\\n]
    string map $map $in
}

mainScript

