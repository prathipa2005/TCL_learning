# =====================================================================
# Day 03 (3/3) - Tcl : mini project - parse a synthesis report
# =====================================================================
# Puts together Day 1 + 2 + 3: file I/O, regexp, dict, lists, proc,
# catch, format. This is the shape of a real "report checker" script
# that runs after synthesis and decides PASS/FAIL.
#
# Flow:
#   1. write a sample report file (stands in for a tool-generated one)
#   2. parse_report  -> reads it, fills a dict per block
#   3. check_results -> compares against limits (area, WNS)
#   4. write_summary -> writes summary.txt, prints, returns exit status
#
# Concepts used again: regexp with groups, dict set/get, dict for,
# lsort, format, catch, file open/close, proc returning values.
# New: exit code from Tcl ("exit 1" on failure) so a shell/CI flow
# can react to it.
#
# Run:  tclsh day03_tcl_mini_report_parser.tcl
# =====================================================================

set REPORT  "synth.rpt"
set SUMMARY "summary.txt"

# limits for the check
set AREA_LIMIT 5000.0   ;# um^2
set WNS_LIMIT  0.0      ;# ns, anything below is a fail

# ---- 1. sample report ----
proc make_sample {file} {
    set fh [open $file w]
    puts $fh "Block: alu     Area: 3200.50  WNS: -0.25  Power: 1.8"
    puts $fh "Block: regfile Area: 4100.00  WNS: 0.40   Power: 2.5"
    puts $fh "Block: ctrl    Area: 800.75   WNS: -0.10  Power: 0.3"
    puts $fh "# comment line should be ignored"
    puts $fh "Block: fifo    Area: 5600.00  WNS: 1.20   Power: 3.1"
    puts $fh "garbage line"
    close $fh
}

# ---- 2. parse ----
proc parse_report {file} {
    set data [dict create]
    set fh [open $file r]
    try {
        while {[gets $fh line] >= 0} {
            if {[regexp {^Block:\s+(\w+)\s+Area:\s+([0-9.]+)\s+WNS:\s+(-?[0-9.]+)\s+Power:\s+([0-9.]+)} \
                    $line -> blk area wns pwr]} {
                dict set data $blk area  $area
                dict set data $blk wns   $wns
                dict set data $blk power $pwr
            }
        }
    } finally {
        close $fh
    }
    return $data
}

# ---- 3. check ----
proc check_results {data area_limit wns_limit} {
    set issues {}
    dict for {blk info} $data {
        if {[dict get $info area] > $area_limit} {
            lappend issues [format "%s: area %.2f exceeds %.2f" $blk [dict get $info area] $area_limit]
        }
        if {[dict get $info wns] < $wns_limit} {
            lappend issues [format "%s: WNS %.2f below %.2f" $blk [dict get $info wns] $wns_limit]
        }
    }
    return $issues
}

# ---- 4. summary ----
proc write_summary {file data issues} {
    set fh [open $file w]
    puts $fh [format "%-10s %10s %8s %7s" Block Area WNS Power]
    puts $fh [string repeat - 38]
    foreach blk [lsort [dict keys $data]] {
        set info [dict get $data $blk]
        puts $fh [format "%-10s %10.2f %8.2f %7.1f" $blk \
            [dict get $info area] [dict get $info wns] [dict get $info power]]
    }
    puts $fh ""
    if {[llength $issues] == 0} {
        puts $fh "RESULT: PASS"
    } else {
        puts $fh "RESULT: FAIL ([llength $issues] issues)"
        foreach i $issues { puts $fh "  - $i" }
    }
    close $fh
}

# ---------------- main ----------------
make_sample $REPORT

if {[catch {parse_report $REPORT} data]} {
    puts "Could not parse report: $data"
    exit 2
}

puts "Blocks parsed : [dict size $data]"

set issues [check_results $data $AREA_LIMIT $WNS_LIMIT]
write_summary $SUMMARY $data $issues

# show the summary file
set fh [open $SUMMARY r]
puts [read $fh]
close $fh

file delete $REPORT $SUMMARY

if {[llength $issues] > 0} { exit 1 }
exit 0
