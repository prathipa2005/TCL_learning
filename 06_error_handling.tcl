# =====================================================================
# Day 02 (3/3) - Tcl : error handling (catch, error, info exists)
# =====================================================================
# In a long tool flow, one bad input should not crash everything
# silently. You check, report clearly and decide whether to continue.
#
# Concepts:
#   catch {script} result    -> runs script; returns 0 if OK, 1 if error.
#                               'result' holds the return value or the
#                               error message.
#   error "message"          -> raise your own error
#   file exists / file readable -> check before opening
#   info exists varname      -> 1 if the variable is defined
#   return -code error "msg" -> raise an error from inside a proc
#   try {...} finally {...}  -> (Tcl 8.6) run cleanup code always,
#                               e.g. close a file even on error
#
# What this script does:
#   1. catch on a failing file open.
#   2. A proc that validates a clock period and raises errors.
#   3. A safe report reader that always closes the file (try/finally).
#
# Run:  tclsh day02_tcl_catch_errors.tcl
# =====================================================================

# ---- 1. catch basics ----
if {[catch {open "missing_report.rpt" r} result]} {
    puts "ERROR caught: $result"
} else {
    puts "opened fine"
    close $result
}

# catch returns the value when there is no error
set code [catch {expr {10 / 4.0}} value]
puts "code=$code  value=$value"

# division by zero is an error
set code [catch {expr {10 / 0}} msg]
puts "code=$code  msg=$msg"

# ---- 2. raising your own errors ----
proc check_clock {period_ns} {
    if {![string is double -strict $period_ns]} {
        return -code error "period '$period_ns' is not a number"
    }
    if {$period_ns <= 0} {
        return -code error "period must be > 0, got $period_ns"
    }
    return [expr {1000.0 / $period_ns}]
}

foreach p {10 0 abc 2.5} {
    if {[catch {check_clock $p} res]} {
        puts [format "period %-4s -> ERROR : %s" $p $res]
    } else {
        puts [format "period %-4s -> %.1f MHz" $p $res]
    }
}

# ---- 3. safe file read with try/finally ----
# create a sample report with one bad line
set fh [open "sample.rpt" w]
puts $fh "u_alu/reg_a -0.25"
puts $fh "u_reg/reg_b 0.40"
puts $fh "BAD_LINE"
close $fh

proc read_slacks {file} {
    if {![file exists $file]} {
        return -code error "file $file not found"
    }
    set fh [open $file r]
    set bad 0
    try {
        while {[gets $fh line] >= 0} {
            if {[llength $line] != 2} {
                incr bad
                puts "  skipping malformed line: '$line'"
                continue
            }
            lassign $line name slack
            puts [format "  %-12s %6.2f" $name $slack]
        }
    } finally {
        close $fh
        puts "  (file closed)"
    }
    return $bad
}

puts "\nReading sample.rpt"
set bad [read_slacks sample.rpt]
puts "Malformed lines: $bad"

if {[catch {read_slacks nothere.rpt} err]} {
    puts "\nHandled: $err"
}

file delete sample.rpt
