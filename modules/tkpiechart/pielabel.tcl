set rcsId {$Id: pielabel.tcl,v 1.24 1996/12/29 13:05:48 jfontain Exp $}

package provide tkpiechart 2.3

proc pieLabeller::pieLabeller {this canvas args} {
    # set options default
    array set option {-offset 5 -xoffset 0}
    # override with user options
    array set option $args

    # convert offsets to pixel
    set pieLabeller($this,offset) [winfo fpixels $canvas $option(-offset)]
    set pieLabeller($this,xOffset) [winfo fpixels $canvas $option(-xoffset)]
    catch {set pieLabeller($this,font) $option(-font)}
    set pieLabeller($this,canvas) $canvas
}

proc pieLabeller::~pieLabeller {this} {}

proc pieLabeller::bind {this pieId} {
    set pieLabeller($this,pieId) $pieId
}

# as this function is generic, it accepts only a few options, such as: -text, -background
virtual proc pieLabeller::create {this sliceId args}

virtual proc pieLabeller::update {this label value}

virtual proc pieLabeller::rotate {this label}
