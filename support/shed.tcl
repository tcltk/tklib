###
# Populate the branches
###
my shed set name: tklib
my shed set installer: sak
my release add tklib-0-6 {
  version: 0.6
  checkout: tklib-0-6
}

foreach file [glob [file join $::TOOL_ROOT apps *]] {
  if {[file extension $file] ne {}} continue
  my application scan $file
}

###
# Build the module section
###
foreach path [glob [file join $::TOOL_ROOT modules *]] {
  my module scan $path
}
