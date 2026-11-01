# =====================================================================
# Day 02 (2/3) - Tcl : dict and switch
# =====================================================================
# 'dict' is Tcl's proper key/value data type (arrays are older and
# cannot be passed to procs easily; dicts can). Used for configs,
# register maps, per-block results.
#
# DICT commands:
#   dict create k1 v1 k2 v2  -> make a dict
#   dict set d key value     -> add/change a key (modifies variable d)
#   dict get $d key          -> read a value (error if key is missing)
#   dict exists $d key       -> 1 if key is present, else 0
#   dict keys $d / values $d -> lists of keys / values
#   dict size $d             -> number of keys
#   dict for {k v} $d {...}  -> loop over all key/value pairs
#   dict unset d key         -> remove a key
#   Nested: dict get $d top sub  /  dict set d top sub value
#
# SWITCH:
#   switch -exact|-glob|-regexp -- $value { pattern {body} ... default {body} }
#   Cleaner than long if/elseif chains.
#
# What this script does:
#   1. Builds a register map (name -> address, reset value) like an
#      AMBA APB peripheral and reads/updates it.
#   2. Classifies each register address range with switch.
#   3. Uses a nested dict to hold per-block timing results.
#
# Run:  tclsh day02_tcl_dict_switch.tcl
# =====================================================================

# ---- 1. register map ----
set regs [dict create CTRL 0x00 STATUS 0x04 DATA 0x08]
dict set regs IRQ_EN 0x0C
puts "Registers : [dict keys $regs]"
puts "Count     : [dict size $regs]"
puts "DATA addr : [dict get $regs DATA]"

if {[dict exists $regs BAUD]} {
    puts "BAUD exists"
} else {
    puts "BAUD is NOT in the map"
}

puts "\n--- register table ---"
dict for {name addr} $regs {
    puts [format "%-8s @ %s" $name $addr]
}

# ---- 2. switch ----
proc reg_type {name} {
    switch -glob -- $name {
        CTRL*   { return "control" }
        STATUS* { return "status (read only)" }
        IRQ*    { return "interrupt" }
        default { return "data" }
    }
}
puts "\n--- register types ---"
foreach n [dict keys $regs] {
    puts [format "%-8s -> %s" $n [reg_type $n]]
}

# exact match with switch
set protocol_state IDLE
switch -exact -- $protocol_state {
    IDLE   { puts "\nAPB state: waiting for PSEL" }
    SETUP  { puts "\nAPB state: address phase" }
    ACCESS { puts "\nAPB state: data phase (PENABLE=1)" }
}

# ---- 3. nested dict ----
set results [dict create]
dict set results u_alu  wns -0.25
dict set results u_alu  tns -0.35
dict set results u_ctrl wns -0.10
dict set results u_ctrl tns -0.10
dict set results u_fifo wns  1.20
dict set results u_fifo tns  0.00

puts "\n--- per block timing ---"
dict for {blk info} $results {
    set wns [dict get $info wns]
    set flag [expr {$wns < 0 ? "FIX" : "OK"}]
    puts [format "%-8s WNS=%6.2f  TNS=%6.2f  %s" $blk $wns [dict get $info tns] $flag]
}
