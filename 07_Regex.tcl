# =====================================================================
# Day 03 (1/3) - Tcl : regular expressions (regexp, regsub)
# =====================================================================
# Regex is the main tool for pulling numbers/names out of tool logs
# and reports, and for renaming nets/instances in bulk.
#
# regexp [options] {pattern} $string  matchVar sub1 sub2 ...
#   returns 1 if matched, 0 otherwise
#   matchVar = the whole match, sub1.. = the ( ) capture groups
#   options: -nocase   ignore case
#            -all      count/collect ALL matches
#            -inline   return the matches as a list instead of using variables
#            -indices  give positions instead of text
#
# regsub [options] {pattern} $string replacement newVar
#   returns number of substitutions, result goes into newVar
#   options: -all (replace every match, default is only the first), -nocase
#   In the replacement: & = whole match, \1 \2 = capture groups
#
# Regex building blocks:
#   .  any char       \d digit      \w word char     \s whitespace
#   *  0 or more      +  1 or more  ?  0 or 1        {n,m} n to m times
#   ^  start          $  end        [abc] one of     [^abc] none of
#   (a|b) either     \S \D \W = negated forms
#   ALWAYS put the pattern in { } so Tcl does not touch the backslashes.
#
# Run:  tclsh day03_tcl_regexp_regsub.tcl
# =====================================================================

# ---- 1. basic match + capture groups ----
set line "Info: tb_alu : TEST test_alu_add PASSED at 900 ns"
if {[regexp {TEST\s+(\w+)\s+(PASSED|FAILED)\s+at\s+(\d+)} $line all name result time]} {
    puts "whole match : $all"
    puts "test name   : $name"
    puts "result      : $result"
    puts "time (ns)   : $time"
}

# ---- 2. extract numbers: slack from a report line ----
set rpt "slack (VIOLATED)   -0.253"
regexp {slack\s+\((\w+)\)\s+(-?\d+\.\d+)} $rpt -> status slack
puts "\nstatus=$status  slack=$slack"

# ---- 3. -nocase ----
puts "\nnocase match : [regexp -nocase {error} {UVM_ERROR @ 250ns}]"

# ---- 4. -all -inline : collect every match ----
set netlist "wire a, b, data_in_0, data_in_1, data_in_2;"
set found [regexp -all -inline {data_in_\d+} $netlist]
puts "\nbus bits found : $found"
puts "how many       : [llength $found]"

# count matches only
puts "count of 'data': [regexp -all {data} $netlist]"

# ---- 5. regsub : rename / clean ----
# replace first match only
regsub {u_} "u_alu/u_adder" "X_" r1
puts "\nfirst only : $r1"

# replace all
regsub -all {u_} "u_alu/u_adder" "" r2
puts "all        : $r2"

# use capture groups in replacement: reg[3] -> reg_3
regsub -all {\[(\d+)\]} "data_reg\[3\] data_reg\[12\]" {_\1} r3
puts "bus rename : $r3"

# & = whole match: wrap every number in <>
regsub -all {\d+} "run 12 took 345 ns" {<&>} r4
puts "wrapped    : $r4"

# trim trailing spaces/comments
set raw "set clk_period 10   ;# 100 MHz"
regsub {\s*;#.*$} $raw "" clean
puts "cleaned    : '$clean'"

# ---- 6. validate a signal name ----
proc valid_signal {n} {
    return [regexp {^[a-zA-Z_][a-zA-Z0-9_]*$} $n]
}
foreach s {clk data_in 2bad bad-name rst_n} {
    puts [format "%-10s valid=%d" $s [valid_signal $s]]
}
