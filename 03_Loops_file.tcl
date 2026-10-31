# =====================================================================
# Day 01 (3/3) - Tcl : file I/O, while loop, regexp, arrays
# =====================================================================
# Real flows read tool reports/logs and write summaries. This is the
# basic pattern you will use again and again.
#
# FILE commands:
#   open file r|w|a        -> returns a file handle (r=read, w=write, a=append)
#   gets $fh line          -> read one line into variable 'line'; returns -1 at EOF
#   puts $fh "text"        -> write a line to the file
#   close $fh              -> always close when done
#   file exists name       -> check if a file is there
#
# OTHER concepts:
#   while {cond} { ... }   -> loop while condition is true
#   regexp {pattern} $str all g1 g2 -> match; () groups go into g1, g2
#   array set / $arr(key)  -> key/value storage (Tcl's dictionary-like type)
#   array names arr        -> list of keys
#
# What this script does:
#   1. Writes a small sample timing report to a file.
#   2. Reads it line by line, extracts the path name and slack with regexp.
#   3. Stores slack per path in an array and writes a summary file with
#      only the violating paths.
#
# Run:  tclsh day01_tcl_file_io_report.tcl
# =====================================================================

set rpt "timing.rpt"
set out "violations.txt"

# ---- 1. create sample report ----
set fh [open $rpt w]
puts $fh "Startpoint: u_alu/reg_a   slack (VIOLATED) -0.25"
puts $fh "Startpoint: u_reg/reg_b   slack (MET) 0.40"
puts $fh "Startpoint: u_ctrl/reg_c  slack (VIOLATED) -0.10"
puts $fh "Startpoint: u_fifo/reg_d  slack (MET) 1.20"
close $fh

# ---- 2. read and parse ----
array set slack_of {}
set fh [open $rpt r]
while {[gets $fh line] >= 0} {
    if {[regexp {Startpoint:\s+(\S+)\s+slack \((\w+)\)\s+(-?[0-9.]+)} $line all name status value]} {
        set slack_of($name) $value
    }
}
close $fh

# ---- 3. write summary of violations ----
set fo [open $out w]
set count 0
foreach name [lsort [array names slack_of]] {
    if {$slack_of($name) < 0} {
        puts $fo [format "%-15s %6.2f" $name $slack_of($name)]
        incr count
    }
}
close $fo

puts "Parsed paths     : [array size slack_of]"
puts "Violating paths  : $count"
puts "Written to       : $out"
puts "---- $out ----"
set fh [open $out r]
puts [read $fh]
close $fh

# cleanup so the folder stays tidy
file delete $rpt $out
