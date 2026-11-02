# =====================================================================
# Day 03 (2/3) - Tcl : advanced list handling
# =====================================================================
# Commands:
#   lassign $list a b c        -> unpack list elements into variables
#   lmap x $list {expr}        -> build a new list by transforming each item
#                                 (Tcl 8.6)  'continue' inside skips an item
#   foreach a $l1 b $l2 {..}   -> loop over several lists in parallel
#   lsort -real / -integer / -decreasing / -index N / -unique
#   lsearch -all -glob $l pat  -> indices of ALL matches / -inline gives items
#   lreverse, lreplace, linsert, lrange, concat
#   {*}$list                   -> expand a list into separate arguments
#   lrepeat n item             -> list of n copies
#   lset l idx value           -> change an element in place
#
# What this script does:
#   Handles per-path data (name / slack / fanout) the way you would
#   when post-processing a timing report: sort worst-first, filter,
#   transform and print.
#
# Run:  tclsh day03_tcl_list_advanced.tcl
# =====================================================================

set names   {u_alu/p1 u_reg/p2 u_ctrl/p3 u_fifo/p4 u_alu/p5}
set slacks  {-0.25 0.40 -0.10 1.20 -0.05}
set fanouts {4 12 3 20 7}

# ---- 1. foreach over multiple lists in parallel ----
puts "--- parallel foreach ---"
foreach n $names s $slacks f $fanouts {
    puts [format "%-10s slack=%6.2f fanout=%2d" $n $s $f]
}

# ---- 2. lassign ----
lassign {u_alu/p1 -0.25 4} p sl fo
puts "\nlassign -> path=$p slack=$sl fanout=$fo"

# ---- 3. list of lists, sort by slack (worst first) ----
set rows {}
foreach n $names s $slacks f $fanouts { lappend rows [list $n $s $f] }
set sorted [lsort -real -index 1 $rows]
puts "\n--- sorted by slack (worst first) ---"
foreach r $sorted {
    lassign $r n s f
    puts [format "%-10s %6.2f" $n $s]
}

# ---- 4. lmap: transform + filter ----
# convert ns to ps
set ps [lmap s $slacks {expr {$s * 1000}}]
puts "\nslack in ps : $ps"

# keep only violating paths (skip positives with continue)
set viol [lmap n $names s $slacks {
    if {$s >= 0} { continue }
    set n
}]
puts "violating   : $viol"

# ---- 5. lsearch variants ----
puts "\nindices of u_alu paths : [lsearch -all -glob $names u_alu*]"
puts "items of u_alu paths   : [lsearch -all -inline -glob $names u_alu*]"

# ---- 6. sort options ----
puts "\nunique sorted blocks   : [lsort -unique [lmap n $names {lindex [split $n /] 0}]]"
puts "fanout descending      : [lsort -integer -decreasing $fanouts]"

# ---- 7. modify lists ----
set l {a b c d}
puts "\nreverse  : [lreverse $l]"
puts "insert   : [linsert $l 2 X]"
puts "replace  : [lreplace $l 1 2 B C]"
lset l 0 Z
puts "lset     : $l"
puts "concat   : [concat $l {e f}]"
puts "repeat   : [lrepeat 4 0]"

# ---- 8. {*} expansion ----
set stages {0.12 0.30 0.08}
# {*} cannot be used inside expr, so call the math function as a command
puts "\nmax delay via {*}: [::tcl::mathfunc::max {*}$stages]"
