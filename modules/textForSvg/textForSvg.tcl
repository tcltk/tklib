# ------------------------------------------------------------------------------
# FILE:
#       textForSvg-VERSION.tm, textForSvg.tcl
#
# DESCRIPTION:
#       Module/Package to add text strings to a SVG image on a canvas.
#
# LICENCE:
#       Copyright (C) 2021-2025 Keith Nash.
#       This file may be used subject to the terms in the Tklib license;
#       please note in particular the terms repeated here:
#
#     IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
#     FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
#     ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
#     DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
#     POSSIBILITY OF SUCH DAMAGE.
#
#     THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
#     INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
#     FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
#     IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
#     NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
#     MODIFICATIONS.
#
# ------------------------------------------------------------------------------

package require Tk 8.6-
package require tdom
package require htmlparse
# package img::window is loaded on demand by imageCreatePhoto.

if {    ([package vcompare 8.7a0 [package require Tk]] == 1)
     && (![interp issafe])
} {
    package require tksvg
} elseif {([package vcompare 8.7a0 [package require Tk]] == 1)} {
    return -code error {unpatched tksvg is not available to safe interpreters\
            in Tk 8.6.  Consider upgrading to Tcl/Tk 9.0.}
}

namespace eval textForSvg {
    variable CONFIG
    variable FontStyles
    variable Waiter

    namespace export addText scaleSvg imageCreatePhoto cget configure
    namespace export chooseFontFamily strictConvertTo strictConvertFrom fontIsPresent
    namespace export getDefaultFontFamily
}

# ------------------------------------------------------------------------------
#  Proc textForSvg::addText
# ------------------------------------------------------------------------------
# Command to render the text elements of an SVG image as canvas items.
#
# Notes.
# - Argument xmldata is a binary string (utf-8 encoded) by default; but if a Tcl
#   string is available it can be used by setting argument "binary" to 0.
# - The binary format is needed by the command "image create photo -data", and
#   is the default for command textForSvg::imageCreatePhoto.
#
# Arguments:
# xmldata     - a string holding SVG image data
# can         - the canvas to which text strings will be added as canvas items
# imX         - (optional, integer) horizontal offset of text items in canvas
#               i.e. The canvas x-coordinate of the top-left corner of the SVG
#               image item in canvas pixel coordinates (a floating point number)
# imY         - (optional, integer) vertical offset of text items in canvas
#               i.e. The canvas y-coordinate of the top-left corner of the SVG
#               image item in canvas pixel coordinates (a floating point number)
# binary      - (optional, boolean) iff true, argument xmldata is provided as a
#               binary string with utf-8 encoding.  Otherwise as a Tcl string.
#
# Return Value: list of canvas item ids for text items created by the command
# ------------------------------------------------------------------------------

proc textForSvg::addText {xmldata can {imX 0} {imY 0} {binary 1}} {
    if {!$binary} {
        set xmldataTcl $xmldata
    } elseif {[catch {strictConvertFrom $xmldata utf-8} res]} {
        set msg {argument "binary" is true, requesting conversion of\
                 argument "xmldata" from a utf-8-encoded binary string\
                 to a Tcl string; but this conversion failed}
        append msg " - $res"
        return -code error $msg
    } else {
        # Argument $xmldata is a binary string whose bytes are valid UTF-8.
        # xmldataTcl is the corresponding Tcl string.
        set xmldataTcl $res
    }

    if {![string match -nocase *<svg* $xmldataTcl]} {
        # Not valid SVG.  Nothing to do.
        return
    }
    set lwc [string tolower $xmldataTcl]
    set pos1 [string first <svg  $lwc]
    set pos2 [string last </svg> $lwc]
    if {$pos1 == -1 || $pos2 == -1 || ($pos2 < $pos1)} {
        # Not valid SVG.  Nothing to do.
        return
    }

    # printing is valid even if pos1 is 0.
    # Currently unused.
    # FIXME display it; also error messages from pikchr/tDOM.
    set printing   [string range $xmldataTcl 0 $pos1-1]
    set printing2  [string range $xmldataTcl $pos2+6 end]
    set xmldataTcl [string range $xmldataTcl $pos1 $pos2+5]

    # tDOM crashes if it finds inessential character entities.
    # So, escape the essential 5 again; then unescape the lot in one call.
    set map [list {&lt;}   {&amp;lt;}   {&gt;}   {&amp;gt;}   \
                  {&amp;}  {&amp;amp;}  {&apos;} {&amp;apos;} \
                  {&quot;} {&amp;quot;}]
    set xmldataTcl [string map $map $xmldataTcl]
    set xmldataTcl [htmlparse::mapEscapes $xmldataTcl]

    if {[catch {dom parse $xmldataTcl} doc]} {
        # Not valid XML.  Nothing to do.
        # FIXME report error
        return
    }
    lassign [GetScaleFactors $doc] sX sY

    set txtList [$doc getElementsByTagName text]
    set SvgTextItems {}
    foreach xmlNode $txtList {
        # Copy all attributes of the text node to dictionary attrDict.
        set attrList [$xmlNode attributes]
        set attrDict {}
        foreach attr $attrList {
            dict set attrDict $attr [$xmlNode getAttribute $attr]
        }

        # Skip this node if any of these attributes are missing.
        foreach attr {x y} {
            if {$attr ni $attrList} {
                continue
            }
        }
        # All attributes used below:
        # x
        # y
        # text-anchor
        # transform
        # font-family (if present, ="monospace")
        # font-size
        # font-style
        # font-weight
        # fill
        # Present but unused: dominant-baseline="central"

        # Text String.
        set textString [$xmlNode text]

        # Text Anchor.
        set where {
            start  w
            middle center
            end    e
        }
        set anchor [DictGetSafely $where [DictGetSafely $attrDict text-anchor] center]

        # Text Position.
        set xAttr [dict get $attrDict x]
        set yAttr [dict get $attrDict y]
        lassign [GetRotation [DictGetSafely $attrDict transform]] angle oX oY
        if {abs($angle) < 1.E-5} {
            # No rotation.
            set xRef $xAttr
            set yRef $yAttr
        } else {
            # The rotation is anticlockwise by $angle degrees about (oX, oY).
            # The canvas item -angle rotates the text, but the anchor of the
            # item is moved too.
            set theta [expr {$angle * atan(1.0) / 45.}]
            set xDel [expr {$xAttr - $oX}]
            set yDel [expr {$yAttr - $oY}]
            set xRef [expr {$oX + cos($theta) * $xDel + sin($theta) * $yDel}]
            set yRef [expr {$oY - sin($theta) * $xDel + cos($theta) * $yDel}]
        }

        # Font Size as %.
        set fontSize [DictGetSafely $attrDict font-size 100%]
        if {    ([string index $fontSize end] eq {%})
             && ([string is double -strict [set siz [string range $fontSize 0 end-1]]])
        } {
            # OK
        } else {
            set siz 100
        }

        # Font Style.
        set styles {
            normal  {}
            italic  italic
            oblique italic
        }
        set fontStyle [DictGetSafely $styles [DictGetSafely $attrDict font-style]]

        # Font Weight.
        # Numerical values are ignored.
        # Values "bolder", "lighter" are supposed to be relative to parent element.
        set weights {
            normal  {}
            bold    bold
            bolder  bold
            lighter {}
        }
        set fontWeight [DictGetSafely $weights [DictGetSafely $attrDict font-weight]]

        # Font Color.
        set color [GetColor [DictGetSafely $attrDict fill]]

        # Font Family.  Default (attribute not present) or "monospace".
        if {[DictGetSafely $attrDict font-family] eq {monospace}} {
            set fam [cget -monofont]
            set fht [cget -monoheight]
        } else {
            set fam [cget -defaultfont]
            set fht [cget -defaultheight]
        }

        # Font Definition: family, size, style, and weight.
        # Cannot change the font aspect ratio, so scale the font size by
        # the horizontal scale factor.
        set fontPix [expr {round(-1 * $fht * $sX * $siz / 100.)}]
        set font [list $fam $fontPix {*}$fontStyle {*}$fontWeight]

        # Define the canvas item of type "text", and record its index.
        lappend SvgTextItems [$can create text \
                [expr {$sX * $xRef + $imX}] [expr {$sY * $yRef + $imY}] \
                -text    $textString \
                -justify left    \
                -anchor  $anchor \
                -fill    $color  \
                -font    $font   \
                -angle   $angle  \
        ]
    }

    $doc delete
    return $SvgTextItems
}

# ------------------------------------------------------------------------------
#  Proc textForSvg::GetScaleFactors
# ------------------------------------------------------------------------------
# Command to return scaling factors for conversion of SVG image coordinates to
# canvas coordinates.
# Valid only for case when viewBox attribute is supplied, and (if present)
# height and width are numbers (not percentages or distances with units).
#
# Offset is not considered but in these pikchr examples is always (0, 0).
#
# Arguments:
# doc         - a document command returned by the tdom DOM parser.
#
# Return Value: list of two numbers, scale factors for x and y
# ------------------------------------------------------------------------------

proc textForSvg::GetScaleFactors {doc} {
    set root [$doc documentElement]
    set attrList [$root attributes]
    if {{viewBox} ni $attrList} {
        return {1 1}
    }
    lassign [$root getAttribute viewBox] l u r d
    foreach varName {l u r d} {
        if {![string is double -strict [set $varName]]} {
            return {1 1}
        }
    }
    set dX [expr {$r - $l}]
    set dY [expr {$d - $u}]

    set sX 1
    set sY 1
    if {    ({width} in $attrList)
         && [string is double -strict [set w [$root getAttribute width]]]
    } {
        set sX [expr {$w / ($dX + 0.)}]
    }
    if {    ({height} in $attrList)
         && [string is double -strict [set h [$root getAttribute height]]]
    } {
        set sY [expr {$h / ($dY + 0.)}]
    }

    return [list $sX $sY]
}


# ------------------------------------------------------------------------------
#  Proc textForSvg::GetColor
# ------------------------------------------------------------------------------
# Command to convert value of text element attribute "fill" to a Tcl color.
#
# Recognizes only format fill="rgb(255,255,255)" which is the format used by
# pikchr.
#
# Arguments:
# fillValue   - value of attribute "fill", or {} if attribute not supplied
# default     - return value if no fillValue   
#
# Return Value: color in format #rrggbb
# ------------------------------------------------------------------------------

proc textForSvg::GetColor {fillValue {default #000000}} {
    set pattern {rgb\((([^(), ]+),([^(), ]+),([^(), ]+))\)}
    if {    ($fillValue ne {})
         && [regexp -- $pattern $fillValue full rgbArgs r g b]
         && [string is integer -strict $r] && ($r >= 0) && ($r <= 255)
         && [string is integer -strict $g] && ($g >= 0) && ($g <= 255)
         && [string is integer -strict $b] && ($b >= 0) && ($b <= 255)
    } {
        # OK
        set color [format #%02x%02x%02x $r $g $b]
    } else {
        set color $default
    }
    return $color
}


# ------------------------------------------------------------------------------
#  Proc textForSvg::GetRotation
# ------------------------------------------------------------------------------
# Command to extract rotation parameters from the value of the "transform"
# attribute.  That value is assumed to have only a rotate() element; this is
# sufficient for svg images generated by pikchr.
#
# Arguments:
# trans       - value of attribute "transform", or {} if attribute not supplied
#
# Return Value: list of three numbers:
#               - angle of rotation in degrees (anticlockwise)
#               - x value of centre of rotation in image coordinates
#               - y value of same
# ------------------------------------------------------------------------------

proc textForSvg::GetRotation {trans} {
    set pattern {rotate\((([^() ,]+)[ ,]+([^(), ]+),([^(), ]+) *)\)}
    if {    ($trans ne {})
         && [regexp -- $pattern $trans full rotArgs angle originX originY]
         && [string is double -strict $angle]
         && [string is double -strict $originX]
         && [string is double -strict $originY]
    } {
        # OK
    } else {
        set angle   0.0
        set originX 0.0
        set originY 0.0
    }
    list [expr {-1 * $angle}] $originX $originY
}


# ------------------------------------------------------------------------------
#  Proc textForSvg::DictGetSafely
# ------------------------------------------------------------------------------
# Command to read the value corresponding to a key in a dictionary; if the key
# does not exist, don't raise an error (like dict get), instead return a default
# value.
#
# Arguments:
# dictionary  - a dictionary value
# keyList     - the key list whose corresponding value is requested.  An empty
#               list is treated as "key {}" rather than as "no argument".
# default     - (optional) value to return if key is not found in the dictionary
#
# Return Value: the value from the dictionary, or $default if the key is not
#               found
# ------------------------------------------------------------------------------

proc textForSvg::DictGetSafely {dictionary keyList {default {}}} {
    if {$keyList eq {}} {
        set keyList [list {}]
    }
    if {[catch {dict get $dictionary {*}$keyList} value]} {
        set value $default
    }
    return $value
}

# ------------------------------------------------------------------------------
#  Proc textForSvg::imageCreatePhoto
# ------------------------------------------------------------------------------
# Command to create a Tk PNG image where the -data or -file option supplies a
# SVG image with text.
#
# - Use this command if you need a pure image rather than a canvas that holds a
#   image and text canvas items.
# - The command replaces "image create photo" for a SVG image and creates a
#   complete Tk image that includes any SVG text elements.  It uses img::window
#   to process the image and draws a transient window on the screen.  It
#   replaces transparent pixels with a background color specified by an
#   option/value pair.
# - NOTE: The command is a SUBSTITUTE for "image create photo" but not an
#   EQUIVALENT.  For example, it does not allow -data or -file to be specified
#   by "imageName configure" after image creation.
#
# Usage:
# textForSvg::imageCreatePhoto ?name? ?option value ...?
#
# name        - If specified, the name used for the image and its command.
#               If not specified, Tk assigns a name.
#               If specified as "--", an image is not created, and the return
#               value is the base64-encoded PNG image data, not an image name.
#
# Options (cf. Tk command "image create photo"):
# -data       - Specifies the image as SVG data in:
#               EITHER a binary string whose bytes represent text encoded in
#                  utf-8. "image create photo" needs a binary string. and so
#                  this is also the default for this command.
#               OR a standard Tcl string.  Supply the arguments "-binary 0" to
#                  identify this format to the command. 
#               If the -data and -file options are specified, the -file
#               option takes precedence.
# -format     - IGNORED
# -file       - the name of a file that is to be read to supply data for the
#               photo image.  The file format must be SVG.
# -gamma      - IGNORED
# -height     - Specifies the height of the image, in pixels.  This option is
#               useful primarily in situations where the user wishes to build up
#               the contents of the image piece by piece.  A value of zero (the
#               default) allows the image to expand or shrink vertically to
#               fit the data stored in it.
# -metadata   - IGNORED
# -palette    - IGNORED
# -width      - Specifies the width of the image, in pixels.  This option is
#               useful primarily in situations where the user wishes to build up
#               the contents of the image piece by piece.  A value of zero (the
#               default) allows the image to expand or shrink horizontally to
#               fit the data stored in it.
#
# Options (specific to this command):
# -binary     - (optional) boolean: if true (the default) any value supplied for
#               -data is a binary string with UTF-8 encoding, if false the value
#               is a Tcl string.  Does not apply to an image read from -file.
# -toplev     - (optional) Tk window path of transient toplevel to use for the
#               conversion.  Must not already exist.  img::window requires a
#               toplevel whose name begins with a lower-case letter.
# -transcolor - (optional) background color to be shown where the image is
#               transparent.  Transparency is not preserved.
# -scale      - (optional) scale factor.
#
# Return Value: name of image command, or image data if argument "name" is "--"
# ------------------------------------------------------------------------------

proc textForSvg::imageCreatePhoto {args} {
    set opts [ArgsToOpts {*}$args]

    set binary  [dict get $opts -binary]
    set xmldata [dict get $opts -data]
    set name    [dict get $opts -name]
    set tlev    [dict get $opts -toplev]
    set bgColor [dict get $opts -transcolor]
    set fac     [dict get $opts -scale]
    dict unset opts -binary
    dict unset opts -data
    dict unset opts -name
    dict unset opts -toplev
    dict unset opts -transcolor
    dict unset opts -scale
    # Leaves only -height -width.  These default to 0.
    # ArgsToOpts ensures that $xmldata is always binary.

    if {$name ne {}} {
        set name [list $name]
    }

    set delay [cget -delay]

    package require img::window

    if {![string match -nocase *<svg* $xmldata]} {
        return -code error {argument xmldata is not a SVG image}
    }
    if {[catch {dom parse $xmldata} doc]} {
        return -code error {argument xmldata is not a valid SVG image}
    } else {
        $doc delete
    }

    if {[catch {
        set EnlargedSvgData [textForSvg::scaleSvg $xmldata $fac]
        set img1 [image create photo -data $EnlargedSvgData {*}$opts]
        toplevel $tlev
        wm overrideredirect $tlev
        canvas $tlev.can -width  [image width $img1] \
                         -height [image height $img1] \
                         -bg     $bgColor \
                         -highlightthickness 0
        $tlev.can create image 0.0 0.0 -image $img1 -anchor nw
        textForSvg::addText $EnlargedSvgData $tlev.can 0 0 1

        after idle [list pack $tlev.can]
        tkwait visibility $tlev.can
        after $delay set [namespace current]::Waiter($img1) 0
        vwait [namespace current]::Waiter($img1)

        set img2 [image create photo -format window -data $tlev.can]
        set imgData [$img2 data -format png]
        if {($name eq {--}) && ([string range $imgData 0 4] eq {iVBOR})} {
            # Tk 8
            package require base64
            set img3 [base64::decode $imgData]
        } elseif {$name eq {--}} {
            # Tk 9
            set img3 $imgData
        } else {
            set img3 [image create photo {*}$name -data $imgData {*}$opts]
        }
        destroy $tlev
        image delete $img1
        image delete $img2
        unset [namespace current]::Waiter($img1)
    } msg catchOpts]} {
        destroy $tlev
        catch {image delete $img1}
        catch {image delete $img2}
        catch {unset -nocomplain [namespace current]::Waiter($img1)}
        return -code error -options $catchOpts "error converting SVG image - $msg"
    }
    return $img3
}


# ------------------------------------------------------------------------------
#  Proc textForSvg::ArgsToOpts
# ------------------------------------------------------------------------------
# Command to take the arguments of textForSvg::imageCreatePhoto and return
# a dictionary of options.
#
# Arguments:
# args: ?name? ?option value ...?
# (see textForSvg::imageCreatePhoto usage)
#
# Return value: a dictionary with:
# - key -name for argument "name",
# - default values for options -binary, -name, -toplev, -transcolor, -scale if
#   values are not supplied by the caller,
# - option -file replaced with -data from the filename value,
# - non-handled options removed (except -height, -width).
# - therefore has keys -binary -name -toplev -transcolor -scale -data -height
#   and -width
# ------------------------------------------------------------------------------

proc textForSvg::ArgsToOpts {args} {
    set opts {
        -binary     1
        -name       {}
        -toplev     .svg_conversion_in_textForSvg
        -transcolor #ffffff
        -scale      1.0
        -width      0
        -height     0
    }
    if {[string index [lindex $args 0] 0] ne {-} || [lindex $args 0] eq {--}} {
        dict set opts -name [list [lindex $args 0]]
        set args [lrange $args 1 end]
    }
    if {[llength $args] % 2} {
        set args [lrange $args 0 end-1]
        set final [lindex $args end]
        set ok 0
    } else {
        set ok 1
    }
    set args [dict create {*}$args]
    # For each option with duplicates, keep the last value.

    if {[dict exists $args -file] && [dict exists $args -data]} {
        # Option -file overrides option -data.
        dict unset args -data
    }
    set UsingOptionFile [dict exists $args -file]

    foreach {opt val} $args {
        dict set opts {*}[ProcessOption $opt $val]
    }
    if {!$ok} {
        ProcessOption $final
    }
    # Note that [ProcessOption -file value] returns {-data DATA} where DATA is
    # a binary string. [ProcessOption -data value] returns {-data value}, and
    # -binary BOOL indicates whether "value" is binary.  If it is not, we
    # convert it and always return -data as a binary string.

    if {![dict exists $opts -data]} {
        # We cannot use image configure to write the SVG image later, so
        # we require one of these options.
        return -code error "option \"-file\" or \"-data\" must be provided"
    }

    if {(![dict get $opts -binary]) && (!$UsingOptionFile)} {
        # Value for -data is a Tcl string.  Convert to binary/utf-8.
        dict set opts -data [strictConvertTo [dict get $opts -data] utf-8]
    }

    return $opts
}


# ------------------------------------------------------------------------------
#  Proc textForSvg::ProcessOption
# ------------------------------------------------------------------------------
# Command to process an option/value pair (or an option without a value).
#
# Usage: textForSvg::ProcessOption option ?value?
# Return Value: a list of 0 or 1 option/value pairs. 0 for a valid option that
# is ignored; 1 for a non-ignored option. Option/value are passed through except
# -file FILE which is converted to -data DATA which tries to be binary/utf-8.
# ------------------------------------------------------------------------------

proc textForSvg::ProcessOption {args} {
    set opts    {-binary -data -file -gamma -height -width -palette -metadata \
                 -format -transcolor -scale -toplev}
    set handled {-binary -data -file -height -width -transcolor -scale -toplev}
    set lenny   [llength $args]

    if {$lenny ni {1 2}} {
        return -code error {internal error: bad call to ProcessOption}
    }
    lassign $args opt val
    if {$opt ni $opts} {
        return -code error "unknown option \"$opt\""
    }
    if {$lenny == 1} {
        return -code error "value for \"$opt\" missing"
    }
    if {($opt ni $handled)} {
        # Silently ignore.
        return
    }
    if {$opt eq "-file" && [interp issafe]} {
        return -code error "no file access in a safe interpreter"
    } elseif {$opt eq "-file"} {
        # Fetch file into dat.
        # image(n) -data expects data in binary format.
        # Yes, this does apply to SVG.
        set fin [open $val]
        fconfigure $fin -translation binary
        set dat [read $fin]
        close $fin

        # - We need to return a binary string encoded as utf-8.
        # - When the system encoding is utf-8, we assume that the file is
        #   encoded as utf-8.
        # - When the system encoding is something else, we try utf-8 first, and
        #   then try the system encoding.  If the file has the system encoding,
        #   convert its data to binary/utf-8.
        if {    ([encoding system] ne {utf-8})
             && ( [catch {strictConvertFrom $dat utf-8}])
             && (![catch {strictConvertFrom $dat [encoding system]} da2])
             && (![catch {strictConvertTo   $da2 utf-8} da3])
        } {
            set dat $da3
            # In other cases, return the original binary string "dat" that was
            # read from the file and has either utf-8 or undetermined encoding.
        }
        set args [list -data $dat]
    }
    return $args
    # The return value is either [list -data $dat] from the -file option, the
    # supplied arguments (all other cases that get this far), or {} (early
    # return for arguments that are not processed).
}

proc textForSvg::cget {option} {
    variable CONFIG

    if {![dict exists $CONFIG $option]} {
        return -code error "unknown option \"$option\""
    }
    return [dict get $CONFIG $option value]
}

# Atomic.  No validation of new values.

proc textForSvg::configure {args} {
    variable CONFIG

    set lenny [llength $args]

    foreach {option value} $args {
        if {![dict exists $CONFIG $option]} {
            return -code error "unknown option \"$option\""
        }
    }
    if {($lenny % 2) && ($lenny > 1)} {
        return -code error "value for \"$option\" missing"
    }

    # Error cases removed above.
    if {$lenny == 0} {
        set res {}
        foreach option [dict keys $CONFIG] {
            lappend res [configure $option]
        }
        return $res
    } elseif {$lenny == 1} {
        set option [lindex $args 0]
        return [dict values [dict get $CONFIG $option]]
    } elseif {$lenny == 2} {
        set option [lindex $args 0]
        set value  [lindex $args 1]
        dict set CONFIG $option value $value
        return
    } else {
        foreach {option value} $args {
            dict set CONFIG $option value $value
        }
        return
    }
}

proc textForSvg::InitConfigure {defaultsDict} {
    variable CONFIG

    foreach {option default} $defaultsDict {
        dict set CONFIG $option [dict create option $option ns1 {} ns2 {} default $default value {}]
    }

    # Initialise values to defaults.
    foreach option [dict keys $CONFIG] {
        dict set CONFIG $option value [dict get $CONFIG $option default]
    }

    return
}

# Select a suitable font family from a list and a fallback.

proc textForSvg::chooseFontFamily {fontList fallback} {
    foreach fnt $fontList {
        if {[fontIsPresent $fnt]} {
            return $fnt
        }
    }
    if {$fallback in [font names]} {
        return [font actual $fallback -family]
    } else {
        return [font actual [list $fallback] -family]
    }
}

# ------------------------------------------------------------------------------
#  Proc textForSvg::strictConvertFrom
# ------------------------------------------------------------------------------
# Command wrapper for "encoding convertfrom".  Binary string -> Tcl string.
# Attempts to convert a binary string to a Tcl string, assuming that the former
# has a particular encoding.
#
# Returns with error status upon failure.  Strict conversion, with failure
# character reported in error message for Tcl 8 or 9.
#
# Arguments:
# binString     - the binary string to be interpreted.  This must be a
#                 binary string, either generated as such or read from a file
#                 with suitable fconfigure settings.
# enc           - a valid encoding
#
# Return Value:   Tcl string holding converted input
# ------------------------------------------------------------------------------

proc textForSvg::strictConvertFrom {binString enc} {
    if {$enc ni [encoding names]} {
        return -code error "encoding \"$enc\" is not available"
    }

    if {[lindex [split $::tcl_version .] 0] eq {9}} {
        set tclString [encoding convertfrom -profile strict -failindex varFail $enc $binString]
        set validText [expr {$varFail == -1}]
        set suffix " at index $varFail"
    } else {
        set tclString [encoding convertfrom $enc $binString]

        # If the result is valid, the conversion will be reversible.
        # This is a useful test at least for UTF-8.
        set binString2 [encoding convertto $enc $tclString]
        set validText [expr {$binString eq $binString2}]
        if {$validText} {
            set suffix {}
        } else {
            for {set i 0} {$i < [string length $binString]} {incr i} {
                if {[string index $binString $i] ne [string index $binString2 $i]} {
                    break
                }
            }
            set suffix " at index $i"
        }
    }

    if {!$validText} {
        return -code error "conversion from a binary string with\
                            encoding \"$enc\" to a Tcl string failed$suffix"
    }
    return $tclString
}


# ------------------------------------------------------------------------------
#  Proc textForSvg::strictConvertTo
# ------------------------------------------------------------------------------
# Command wrapper for "encoding convertto".  Tcl string -> binary string.
# Converts a Tcl string to a binary string whose bytes have a specific encoding.
#
# Returns with error status upon failure.  Strict conversion, with failure
# character reported in error message for Tcl 8 or 9.
#
# Arguments:
# binString     - the binary string to be interpreted.  This must be a
#                 binary string, either generated as such or read from a file
#                 with suitable fconfigure settings.
# enc           - a valid encoding
#
# Return Value:   Tcl string holding converted input
# ------------------------------------------------------------------------------

proc textForSvg::strictConvertTo {tclString enc} {
    if {$enc ni [encoding names]} {
        return -code error "encoding \"$enc\" is not available"
    }
    if {[lindex [split $::tcl_version .] 0] eq {9}} {
        set binString [encoding convertto -profile strict -failindex varFail $enc $tclString]
        set validText [expr {$varFail == -1}]
        set suffix " at index $varFail"
    } else {
        set binString [encoding convertto $enc $tclString]
        # If the result is valid, the conversion will be reversible.
        # This is a useful test for UTF-8.
        set tclString2 [encoding convertfrom $enc $binString]
        set validText [expr {$tclString eq $tclString2}]
        if {$validText} {
            set suffix {}
        } else {
            for {set i 0} {$i < [string length $tclString]} {incr i} {
                if {[string index $tclString $i] ne [string index $tclString2 $i]} {
                    break
                }
            }
            set suffix " at index $i"
        }
    }
    if {!$validText} {
        return -code error "conversion from a Tcl string to a binary string\
                            with encoding \"$enc\" failed$suffix"
    }
    return $binString
}

# Test whether a font family is present on the system.

proc textForSvg::fontIsPresent {fam} {
    expr {[font actual [list $fam -16] -family] eq $fam}
}

# Return the font family that textForSvg uses by default in
# one of three categories: Sans, Serif, and Mono.

proc textForSvg::getDefaultFontFamily {style} {
    variable FontStyles

    if {![dict exists $FontStyles $style choice]} {
        return -code error "unknown style \"$style\""
    }
    dict get $FontStyles $style choice
}

# Commands scaleSvg and ExtraScaleFactor are not related to rendering of SVG
# text elements and do not depend on the other commands in this module.

# ------------------------------------------------------------------------------
#  Proc textForSvg::scaleSvg
# ------------------------------------------------------------------------------
# Command to scale a SVG image.  For a subset of SVG images.
#
# Arguments:
# xmldata     - svg image data (either binary string or Tcl string)
# fac         - scale factor
#
# Return Value: revised svg image data, same encoding as input
# ------------------------------------------------------------------------------

proc textForSvg::scaleSvg {xmldata fac} {
    if {![string match -nocase *<svg* $xmldata]} {
        # Not valid SVG.  Nothing to do.
        return $xmldata
    }
    if {[catch {dom parse $xmldata} doc]} {
        # Not valid XML.  Nothing to do.
        return $xmldata
    }
    if {abs($fac - 1.0) < 1.E-3 || $fac > 33 || $fac < 0.03} {
        # Scale factor very close to 1, or too large, or too small
        return $xmldata
    }

    ExtraScaleFactor $doc $fac

    set newSvg [$doc asXML -indent none]
    $doc delete
    return $newSvg
}


# ------------------------------------------------------------------------------
#  Proc textForSvg::ExtraScaleFactor
# ------------------------------------------------------------------------------
# Command to scale a SVG image parsed by tdom.  For a subset of SVG images.
#
# Arguments:
# doc         - a document command returned by the tdom DOM parser.
# fac         - scale factor
#
# Return Value: none
# ------------------------------------------------------------------------------

proc textForSvg::ExtraScaleFactor {doc fac} {
    set root [$doc documentElement]
    set attrList [$root attributes]

    if {    ({viewBox} ni $attrList)
         && (({height} ni $attrList) || ({width} ni $attrList))
    } {
        # Would need to examine the coordinates of every element.
        return
    }

    if {{viewBox} ni $attrList} {
        # Construct viewBox from width, height, whose existence is guaranteed by
        # the previous test.
        if {    [string is double -strict [set w [$root getAttribute width]]]
             && [string is double -strict [set h [$root getAttribute height]]]
        } {
            $root setAttribute viewBox "0 0 $w $h"
        } else {
            return
        }
    }
    # At this point the doc always has a viewBox.
    # If it started with a viewBox but without height and/or width, these
    # will be set below.

    lassign [$root getAttribute viewBox] l u r d
    foreach varName {l u r d} {
        if {![string is double -strict [set $varName]]} {
            return
        }
    }
    set dX [expr {$r - $l}]
    set dY [expr {$d - $u}]

    if {    ({width} in $attrList)
         && [string is double -strict [set w [$root getAttribute width]]]
    } {
        set wX [expr {$w * $fac}]
    } else {
        set wX [expr {$dX * $fac}]
    }
    $root setAttribute width $wX

    if {    ({height} in $attrList)
         && [string is double -strict [set h [$root getAttribute height]]]
    } {
        set hY [expr {$h * $fac}]
    } else {
        set hY [expr {$dY * $fac}]
    }
    $root setAttribute height $hY

    return
}

# Defines the dict FontStyles.
# For the dict key "choice", call chooseFontFamily to choose the default fonts from those available.

proc textForSvg::InitFontStyles {} {
    variable FontStyles  {}

    set FontsSans  {Arial \
            {Droid Sans} Bahnschrift {MS Sans Serif} {Microsoft Sans Serif} \
            {Helvetica Neue} Optima \
            {Liberation Sans} {Nimbus Sans} {FreeSans} \
            {Segoe UI}}
    set FontsSerif {{Times New Roman} \
            {Californian FB} Centaur {MS Serif} Garamond Cambria Constantia \
            Cochin Baskerville Charter \
            {Liberation Serif} {Nimbus Roman} {FreeSerif}}
    set FontsMono  {{Andale Mono} \
            Consolas {Lucida Console} {Lucida Sans Typewriter} \
            Menlo {PT Mono} Monaco \
            {DejaVu Sans Mono} {Source Code Pro} \
            {Liberation Mono} {Nimbus Mono PS} {FreeMono} \
            {Courier New}}

    dict set FontStyles Sans  [dict create list $FontsSans  fallback TkDefaultFont]
    dict set FontStyles Serif [dict create list $FontsSerif fallback Times]
    dict set FontStyles Mono  [dict create list $FontsMono  fallback Courier]

    foreach kind {Sans Serif Mono} {
        set res [chooseFontFamily [dict get $FontStyles $kind list] [dict get $FontStyles $kind fallback]]
        dict set FontStyles $kind choice $res
    }

    return
}

# Command to initialise the module.  Calls InitFontStyles for font discovery and InitConfigure to set cget/configure defaults and initial values.

proc textForSvg::Init {} {
    variable FontStyles

    set defaultsDict {
        -delay         100
        -defaultfont   -
        -defaultheight 16
        -monofont      -
        -monoheight    13
    }

    InitFontStyles
    dict set defaultsDict -defaultfont [dict get $FontStyles Sans choice]
    dict set defaultsDict -monofont    [dict get $FontStyles Mono choice]

    InitConfigure $defaultsDict
    return
}

textForSvg::Init

package provide textForSvg 1.0b1
