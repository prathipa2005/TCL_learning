# =====================================================================
# Day 02 (1/3) - Tcl : procs in depth (default args, args, return, upvar)
# =====================================================================
# Procs are how you build reusable pieces of a flow script, e.g. a proc
# that checks a report, converts units or prints a banner for each step.
#
# Concepts:
#   proc name {a b} {body}      -> normal arguments (must pass both)
#   proc name {a {b 10}} {body} -> 'b' has a default value of 10
#   proc name {args} {body}     -> variable number of arguments, collected
#                                  into a list called 'args'
#   return value                -> send a value back; without return, the
#                                  proc returns the result of its last command
#   Variable scope              -> variables inside a proc are LOCAL.
#       global var              -> bring a global variable inside a proc
#       upvar 1 name local      -> link to a variable in the CALLER's scope,
#                                  this is how Tcl does "pass by reference"
#
# What this script does:
#   Small utilities a VLSI engineer might write: frequency/period
#   conversion, slack checking with a default margin, summing a variable
#   number of path delays, and a proc that modifies a caller's list.
#
# Run:  tclsh day02_tcl_procs_args.tcl
# =====================================================================

# ---- 1. normal + return ----
# period (ns) from frequency (MHz):  T = 1000 / f
proc freq_to_period {freq_mhz} {
    return [expr {1000.0 / $freq_mhz}]
}
puts "100 MHz  -> [freq_to_period 100] ns"
puts "250 MHz  -> [freq_to_period 250] ns"

# ---- 2. default argument ----
# a path passes only if slack is above a margin; margin defaults to 0.05
proc slack_ok {slack {margin 0.05}} {
    return [expr {$slack >= $margin}]
}
puts "\nslack 0.10, default margin : [slack_ok 0.10]"
puts "slack 0.10, margin 0.20    : [slack_ok 0.10 0.20]"

# ---- 3. variable arguments (args) ----
# total delay of a path = sum of any number of cell/net delays
proc total_delay {args} {
    set sum 0.0
    foreach d $args { set sum [expr {$sum + $d}] }
    return $sum
}
puts "\nDelay of 3 stages : [total_delay 0.12 0.30 0.08]"
puts "Delay of 5 stages : [total_delay 0.12 0.30 0.08 0.25 0.11]"

# ---- 4. global variable ----
set run_count 0
proc log_step {msg} {
    global run_count
    incr run_count
    puts "\[step $run_count\] $msg"
}
puts ""
log_step "reading RTL"
log_step "running synthesis"
log_step "writing netlist"

# ---- 5. upvar : modify a variable of the caller ----
proc add_violation {listname path} {
    upvar 1 $listname lst
    lappend lst $path
}
set violators {}
add_violation violators u_alu/reg_a
add_violation violators u_ctrl/reg_c
puts "\nViolators list (changed via upvar) : $violators"
