set rcsId {$Id: pielabel.tcl,v 1.32 1998/03/26 20:18:52 jfontain Exp $}

class pieLabeller {

    set pieLabeller::(default,font) {Helvetica 12}

    proc pieLabeller {this canvas args} {
        set pieLabeller::($this,canvas) $canvas
    }

    proc ~pieLabeller {this} {}

    proc link {this pie} {
        set pieLabeller::($this,pie) $pie
    }

    # as this function is generic, it accepts only a few options, such as: -text, -background
    virtual proc create {this slice args}                                                               ;# must return a canvasLabel

    virtual proc delete {this label}

    virtual proc update {this label value}

    proc bind {this label sequence command} {                                                              ;# label is a canvasLabel
        $pieLabeller::($this,canvas) bind canvasLabel($label) $sequence $command
    }

    virtual proc selectState {this label {state {}}}
}
