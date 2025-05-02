database -open waves -into waves_dig.shm -default -event
probe -create -shm -all -depth all -memories
probe -create top -depth all -all -memories
set assert_stop_level never
uvm_phase -stop_at build
probe -create $uvm:{uvm_test_top} -depth all -tasks -functions -uvm
run
