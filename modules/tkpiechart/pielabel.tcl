set rcsId {$Id: pielabel.tcl,v 1.17 1995/10/14 11:24:01 jfontain Exp $}

virtual proc pieLabeller::pieLabeller {id canvas args} {
    global pieLabeller

    # set options default then parse switched options
    array set option {-offset 5}
    array set option $args

    # convert offset to pixel
    set pieLabeller($id,offset) [winfo fpixels $canvas $option(-offset)]
    catch {set pieLabeller($id,font) $option(-font)}
    set pieLabeller($id,canvas) $canvas
}

virtual proc pieLabeller::~pieLabeller {id}

proc pieLabeller::bind {id pieId} {
    global pieLabeller

    set pieLabeller($id,pieId) $pieId
}

# as this function is generic, it accepts only a few options, such as: -text, -background
virtual proc pieLabeller::create {id sliceId args}

virtual proc pieLabeller::update {id label value}

virtual proc pieLabeller::rotate {id label}
