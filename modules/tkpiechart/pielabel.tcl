set rcsId {$Id: pielabel.tcl,v 1.30 1998/03/22 14:33:26 jfontain Exp $}

class pieLabeller {

    set pieLabeller::(default,font) {Helvetica 12}

    proc pieLabeller {this canvas args} {
        set pieLabeller::($this,canvas) $canvas
    }

    proc ~pieLabeller {this} {}

    proc bind {this pie} {
        set pieLabeller::($this,pie) $pie
    }

    # as this function is generic, it accepts only a few options, such as: -text, -background
    virtual proc create {this slice args}

    virtual proc delete {this label}

    virtual proc update {this label value}

}
