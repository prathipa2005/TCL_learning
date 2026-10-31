# =====================================================================
# Day 01 (2/3) - Tcl : strings and lists (the two data types you use most)
# =====================================================================
# In Tcl, everything is a string. A "list" is just a string with
# elements separated by whitespace. In EDA tools, collections of
# cells/nets/ports are handled with lists constantly.
#
# STRING commands:
#   string length $s          -> number of characters
#   string toupper / tolower  -> change case
#   string range $s i j       -> substring from index i to j
#   string match pattern $s   -> glob match (* ? [])  -- used everywhere in
#                                tool commands like get_cells u_alu/*
#   string map {old new} $s   -> replace text
#   append s "text"           -> add to the end of a string variable
#
# LIST commands:
#   list a b c        -> create a list
#   llength $l        -> number of elements
#   lindex $l i       -> element at index i (starts from 0, "end" = last)
#   lappend l item    -> add an item (modifies the variable itself)
#   lsort $l          -> sorted copy
#   lsearch $l item   -> index of item, or -1 if not found
#   lrange $l i j     -> sub-list
#   join $l ","       -> list -> string with separator
#   split $s ","      -> string -> list
#
# What this script does:
#   Works on a list of RTL module instance names the way you would in
#   a netlist/hierarchy cleanup script.
#
# Run:  tclsh day01_tcl_strings_lists.tcl
# =====================================================================

# ---------- strings ----------
set inst "u_alu_core/adder_0"
puts "Instance        : $inst"
puts "Length          : [string length $inst]"
puts "Upper case      : [string toupper $inst]"
puts "Replace / by _  : [string map {/ _} $inst]"

# glob match: does this instance belong to the ALU?
if {[string match "u_alu*" $inst]} {
    puts "Belongs to ALU  : yes"
}

# ---------- lists ----------
set instances [list u_reg_file u_alu u_ctrl]
lappend instances u_fifo u_alu_shifter

puts "\nAll instances   : $instances"
puts "Count           : [llength $instances]"
puts "First           : [lindex $instances 0]"
puts "Last            : [lindex $instances end]"
puts "Sorted          : [lsort $instances]"
puts "Index of u_ctrl : [lsearch $instances u_ctrl]"
puts "Index of u_mmu  : [lsearch $instances u_mmu]   (-1 means not found)"

# filter: only instances starting with u_alu
set alu_list {}
foreach i $instances {
    if {[string match "u_alu*" $i]} {
        lappend alu_list $i
    }
}
puts "ALU instances   : $alu_list"

# join / split
set csv [join $instances ","]
puts "\nJoined          : $csv"
puts "Split back      : [split $csv ,]"
