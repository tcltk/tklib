set rcsId {$Id: pielabel.tcl,v 1.40 1998/06/07 10:07:30 jfontain Exp $}

class pieLabeler {

    set pieLabeler::(default,font) {Helvetica -12}

    proc pieLabeler {this canvas args} {
        ::set pieLabeler::($this,canvas) $canvas
    }

    proc ~pieLabeler {this} {}

    virtual proc new {this slice args}                                                                  ;# must return a canvasLabel

    virtual proc delete {this label}

    virtual proc set {this label value}

    virtual proc selectState {this label {state {}}}

    # must be invoked only by pie, which knows when it is necessary to update (new or deleted label)
    virtual proc update {this left top right bottom}

    virtual proc room {this arrayName}

}
