###
# Populate the branches
###
my shed set name: tklib
my shed set installer: sak
my add {
  name: tklib-0-6
  linktype: release
  version: 0.6
  checkout: tklib-0-6
}

foreach file [glob [file join $::TOOL_ROOT apps *]] {
  if {[file extension $file] ne {}} continue
  my scan $file {class: application}
}

###
# Build the module section
###
foreach path [glob [file join $::TOOL_ROOT modules *]] {
  my scan $path {class: source}
}
