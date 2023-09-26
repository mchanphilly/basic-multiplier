.DEFAULT_GOAL := all
BUILD_DIR=build
SCHED_DIR=schedules

BINARY_NAME=MultiplierUnitTest
BSC_FLAGS=--aggressive-conditions --show-schedule -vdir $(BUILD_DIR) -bdir $(BUILD_DIR) -simdir $(BUILD_DIR) -info-dir $(SCHED_DIR) -o 

all: clean test_cases MultiplierUnitTest

MultiplierUnitTest:
	mkdir -p $(BUILD_DIR) $(SCHED_DIR)
	bsc $(BSC_FLAGS) $@ -sim -g mk$@ -u $@.bsv  # Generate code
	bsc $(BSC_FLAGS) $@ -sim -e mk$@  # Generate top-level module

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(SCHED_DIR)
	rm -rf *.so
	rm -rf multiplier MultiplierUnitTest test_cases.vmh

test_cases:
	gcc multiplier.c -o multiplier
	./multiplier