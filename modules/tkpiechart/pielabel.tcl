set rcsId {$Id: pielabel.tcl,v 1.34 1998/03/27 22:16:12 jfontain Exp $}

class pieLabeller {

    set pieLabeller::(default,font) {Helvetica 12}

    proc pieLabeller {this canvas args} {
        set pieLabeller::($this,canvas) $canvas
    }

    proc ~pieLabeller {this} {}

    proc link {this pie} {
        set pieLabeller::($this,pie) $pie
    }

    virtual proc create {this slice args}                                                               ;# must return a canvasLabel

    virtual proc delete {this label}

    virtual proc update {this label value}

    virtual proc selectState {this label {state {}}}

}
