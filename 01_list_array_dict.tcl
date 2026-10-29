#!/usr/bin/tclsh
#======================================================================
# File    : 01_list_array_dict.tcl
# Topic   : List vs Array vs Dictionary in TCL
# Purpose : Store the same data (port widths) three different ways
#           and compare how each one is used.
#
# Explanation
#   LIST  : ordered items, accessed by position (index starts at 0).
#   ARRAY : lookup by string key. It is NOT a single value (you cannot
#           "puts $arr"), and key order is not guaranteed.
#   DICT  : lookup by key. It IS a single value, so it can be passed
#           to a proc, returned, and copied. Keys keep insertion order.
#
# Rules to remember
#   1. Commands that CHANGE a variable take its NAME (no $):
#        lappend, incr, dict set, dict unset, unset, lassign targets
#   2. Commands that only READ a value take $name:
#        dict get $d key, dict size $d, llength $lst
#   3. Use "lsort [array names arr]" when output order matters.
#   4. Braces {} block substitution. Use [list ...] or [dict create ...]
#      when the values come from variables.
#   5. "array get arr" turns an array into a flat key/value list,
#      which is also a valid dict.
#======================================================================

# ---------------- LIST ----------------
puts "=== LIST ==="
set names {clk rst_n data_in}
lappend names valid                       ;# no $ before names
puts "List      : $names"
puts "Count     : [llength $names]"
puts "Index 2   : [lindex $names 2]"
puts "Last item : [lindex $names end]"

# ---------------- ARRAY ----------------
puts "\n=== ARRAY ==="
array set w {clk 1 rst_n 1 data_in 8 valid 1}
puts "Size      : [array size w]"
puts "data_in   : $w(data_in)"
foreach k [lsort [array names w]] {       ;# sorted so output is repeatable
    puts "  $k = $w($k)"
}
if {[info exists w(reset_n)]} {
    puts "reset_n found"
} else {
    puts "reset_n not found"
}

# ---------------- DICT ----------------
puts "\n=== DICT ==="
set d [dict create clk 1 rst_n 1 data_in 8]
dict set d valid 1                        ;# no $ before d
puts "Size      : [dict size $d]"
puts "data_in   : [dict get $d data_in]"
puts "Keys      : [dict keys $d]"
dict for {n wd} $d {
    puts "  $n = $wd"
}
puts "valid exists? [dict exists $d valid]"

# Nested dict (config style data)
dict set cfg timing setup 0.1
dict set cfg timing hold  0.05
puts "Setup     : [dict get $cfg timing setup]"

# ---------------- Passing to a proc ----------------
puts "\n=== PASSING TO A PROC ==="
proc total_bits {portdict} {
    set s 0
    dict for {n wd} $portdict {
        incr s $wd
    }
    return $s
}
puts "Total bits (dict)           : [total_bits $d]"
puts "Total bits (array converted): [total_bits [array get w]]"
