set rcsId {$Id: pielabel.tcl,v 1.22 1995/11/04 17:44:33 jfontain Exp $}

proc pieLabeller::pieLabeller {this canvas args} {
    # set options default
    array set option {-offset 5}
    # override with user options
    array set option $args

    # convert offset to pixel
    set pieLabeller($this,offset) [winfo fpixels $canvas $option(-offset)]
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
