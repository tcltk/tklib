set rcsId {$Id: pielabel.tcl,v 1.25 1997/06/05 20:25:51 jfontain Exp $}

package provide tkpiechart 3.0

class pieLabeller {}

proc pieLabeller::pieLabeller {this canvas args} {
    array set option {-offset 5 -xoffset 0}                                                                   ;# set options default
    array set option $args                                                                             ;# override with user options

    set pieLabeller::($this,offset) [winfo fpixels $canvas $option(-offset)]                             ;# convert offsets to pixel
    set pieLabeller::($this,xOffset) [winfo fpixels $canvas $option(-xoffset)]
    catch {set pieLabeller::($this,font) $option(-font)}
    set pieLabeller::($this,canvas) $canvas
}

proc pieLabeller::~pieLabeller {this} {}

proc pieLabeller::bind {this pieId} {
    set pieLabeller::($this,pieId) $pieId
}

# as this function is generic, it accepts only a few options, such as: -text, -background
virtual proc pieLabeller::create {this sliceId args}

virtual proc pieLabeller::update {this label value}

virtual proc pieLabeller::rotate {this label}
