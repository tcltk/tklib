set rcsId {$Id: pielabel.tcl,v 1.38 1998/05/03 10:50:27 jfontain Exp $}

class pieLabeler {

    set pieLabeler::(default,font) {Helvetica -12}

    proc pieLabeler {this canvas args} {
        ::set pieLabeler::($this,canvas) $canvas
    }

    proc ~pieLabeler {this} {}

    proc link {this pie} {
        ::set pieLabeler::($this,pie) $pie
    }

    virtual proc new {this slice args}                                                                  ;# must return a canvasLabel

    virtual proc delete {this label}

    virtual proc set {this label value}

    virtual proc selectState {this label {state {}}}

    virtual proc update {this} {}

}
