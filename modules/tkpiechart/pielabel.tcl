set rcsId {$Id: pielabel.tcl,v 1.36 1998/03/28 08:59:39 jfontain Exp $}

class pieLabeler {

    set pieLabeler::(default,font) {Helvetica -12}

    proc pieLabeler {this canvas args} {
        set pieLabeler::($this,canvas) $canvas
    }

    proc ~pieLabeler {this} {}

    proc link {this pie} {
        set pieLabeler::($this,pie) $pie
    }

    virtual proc create {this slice args}                                                               ;# must return a canvasLabel

    virtual proc delete {this label}

    virtual proc update {this label value}

    virtual proc selectState {this label {state {}}}

}
