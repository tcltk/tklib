set rcsId {$Id: pielabel.tcl,v 1.19 1995/10/21 20:29:18 jfontain Exp $}

proc pieLabeller::pieLabeller {this canvas options} {
    ### should be able to use args instead of options here: fix stooop ###

    # set options default then parse switched options
    array set option {-offset 5}
    array set option $options

    # convert offset to pixel
    set pieLabeller($this,offset) [winfo fpixels $canvas $option(-offset)]
    catch {set pieLabeller($this,font) $option(-font)}
    set pieLabeller($this,canvas) $canvas
}

virtual proc pieLabeller::~pieLabeller {this}

proc pieLabeller::bind {this pieId} {
    set pieLabeller($this,pieId) $pieId
}

# as this function is generic, it accepts only a few options, such as: -text, -background
virtual proc pieLabeller::create {this sliceId args}

virtual proc pieLabeller::update {this label value}

virtual proc pieLabeller::rotate {this label}
