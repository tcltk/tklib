#notifywindow.tcl: provides routines for posting a Growl-style "notification window" in the upper right corner of the screen, fading in and out in an unobtrusive fashion 

#(c) 2015 Kevin Walzer/WordTech Communications LLC. License: MIT license. 
 
package provide notifywindow 1.0

namespace eval notifywindow {


    
    #Main procedure for window

    proc notifywindow {msg img} {
	set w [toplevel _notify]
	wm geometry $w 200x75
	wm overrideredirect $w true
	wm attributes $w -alpha 0.0
	bind $w <1> {destroy $w}
	set xpos [expr [winfo screenwidth $w] - 225]
	label $w.l -text "msg" -bg gray30 -fg white -img $img -compound right
	pack $w.l -fill both -expand yes
	wm geometry $w +$xpos+30
	fade_in $w
	after 3000 {list fade_out $w}
	
    }

    proc fade_out {w} {

	set prev_degree [wm attributes $w -alpha]
	set new_degree [expr $prev_degree - 0.05]
	set current_degree [wm attributes $w -alpha $new_degree]
	if {$new_degree > 0.0 && $new_degree != $prev_degree} {
	    after 10 [list fade_out $w]
	} else {
	    destroy $w
	}

    }

    proc fade_in {w} {
	raise $w
	wm attributes $w -topmost 1
	set prev_degree [wm attributes $w -alpha]
	set new_degree [expr $prev_degree + 0.05]
	set current_degree [wm attributes $w -alpha $new_degree]
	if {$new_degree < 0.9 && $new_degree != $prev_degree} {
	    after 10 [list fade_in $w]
	} else {
	    return
	}
    }

    proc demo {} {

	image create photo flag -data {
	    R0lGODlhFAAUAPcAAAAAAIAAAACAAICAAAAAgIAAgACAgMDAwMDcwKbK8P/w1Pjisd/UjtHJ
	    a8O4SL2qJcWqAK+SAJN6AGJiAEpKADIyAP/j1P/Hsf+rjv+Pa/9zSP9XJf9VANxJALk9AJYx
	    AHMlAFAZAP/U1P+xsf+Ojv9ra/9ISP8lJf4AANwAALkAAJYAAHMAAFAAAP/U4/+xx/+Oq/9r
	    j/9Ic/8lV/8AVdwASbkAPZYAMXMAJVAAGf/U8P+x4v+O1P9rxv9IuP8lqv8AqtwAkrkAepYA
	    YnMASlAAMv/U//+x//+O//9r//9I//8l//4A/twA3LkAuZYAlnMAc1AAUPDU/+Kx/9SO/8Zr
	    /7hI/6ol/6oA/5IA3HoAuWIAlkoAczIAUOPU/8ex/6uO/49r/3NI/1cl/1UA/0kA3D0AuTEA
	    liUAcxkAUNTU/7Gx/46O/2tr/0hI/yUl/wAA/gAA3AAAuQAAlgAAcwAAUNTj/7HH/46r/2uP
	    /0hz/yVX/wBV/wBJ3AA9uQAxlgAlcwAZUNTw/7Hi/47U/2vG/0i4/yWq/wCq/wCS3AB6uQBi
	    lgBKcwAyUNT//7H//47//2v//0j//yX//wD+/gDc3AC5uQCWlgBzcwBQUNT/8LH/4o7/1Gv/
	    xkj/uCX/qgD/qgDckgC5egCWYgBzSgBQMtT/47H/x47/q2v/j0j/cyX/VwD/VQDcSQC5PQCW
	    MQBzJQBQGdT/1LH/sY7/jmv/a0j/SCX/JQD+AADcAAC5AACWAABzAABQAOP/1Mf/sav/jo//
	    a3P/SFf/JVX/AEncAD25ADGWACVzABlQAPD/1OL/sdT/jsb/a7j/SKr/Jar/AJLcAHq5AGKW
	    AEpzADJQAP//1P//sf//jv//a///SP//Jf7+ANzcALm5AJaWAHNzAFBQAPLy8ubm5tra2s7O
	    zsLCwra2tqqqqp6enpKSkoaGhnp6em5ubmJiYlZWVkpKSj4+PjIyMiYmJhoaGg4ODv/78KCg
	    pICAgP8AAAD/AP//AAAA//8A/wD//////yH5BAEAAAEALAAAAAAUABQAAAiZAAMIHEhQoLqD
	    CAsqFAigIQB3Dd0tNKjOXSxXrmABWBABgLqCByECuAir5EYJHimKvOgqFqxXrzZ2lBhgJUaY
	    LV/GOpkSIqybOF3ClPlQIEShMF/lfLVzAcqPRhsKXRqTY1GCFaUy1ckTKkiRGhtapTkxa82u
	    ExUSJZs2qtOUbQ2ujTsQ4luvbdXNpRtA712+UeEC7ou3YEAAADt=
	}

	notifwindow::notifywindow "This is what a notification window looks like" flag

    }

    namespace export *
}





