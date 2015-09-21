set SCRIPT [file normalize [info script]]
set TOOL_ROOT [file dirname [file dirname $SCRIPT]]
set cwd [file dirname $SCRIPT]
if {[catch {package require shed}]} {
  puts "ADDING TOOL TO PKG PATH"
  lappend auto_path [file join $cwd .. .. shed modules]
  package require tool
  package require shed
}

tool begin tklib
###
# Build basic description of this tool
###
tool description: {
The reference implementation for the TOOL and SHED description languages.
}
tool distribution: fossil
tool class: sak

###
# List of mirrors
###
tool mirror http://core.tcl.tk/tklib
tool mirror http://fossil.etoyoc.com/fossil/tklib

###
# Populate the branches
###
tool branch trunk {
  version: 0.7b
  release: beta
}
tool branch tklib-0-6 {
  version: 0.6
  release: final
}

foreach file [glob [file join $TOOL_ROOT apps *]] {
  if {[file extension $file] ne {}} continue
  application_scan $file
}

###
# Build the module section
###
foreach path [glob [file join $TOOL_ROOT modules *]] {
  tool module_path [file tail $path] $path
}
tool write [file join [file dirname $SCRIPT] tool.shed]
