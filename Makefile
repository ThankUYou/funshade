# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.21

# Default target executed when no arguments are given to make.
default_target: all
.PHONY : default_target

# Allow only one "make -f Makefile2" at a time, but pass parallelism.
.NOTPARALLEL:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /make/rast/.local/lib/python3.8/site-packages/cmake/data/bin/cmake

# The command to remove a file.
RM = /make/rast/.local/lib/python3.8/site-packages/cmake/data/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /make/rast/FSS/funshade

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /make/rast/FSS/funshade

#=============================================================================
# Targets provided globally by CMake.

# Special rule for the target rebuild_cache
rebuild_cache:
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --cyan "Running CMake to regenerate build system..."
	/make/rast/.local/lib/python3.8/site-packages/cmake/data/bin/cmake --regenerate-during-build -S$(CMAKE_SOURCE_DIR) -B$(CMAKE_BINARY_DIR)
.PHONY : rebuild_cache

# Special rule for the target rebuild_cache
rebuild_cache/fast: rebuild_cache
.PHONY : rebuild_cache/fast

# Special rule for the target edit_cache
edit_cache:
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --cyan "No interactive CMake dialog available..."
	/make/rast/.local/lib/python3.8/site-packages/cmake/data/bin/cmake -E echo No\ interactive\ CMake\ dialog\ available.
.PHONY : edit_cache

# Special rule for the target edit_cache
edit_cache/fast: edit_cache
.PHONY : edit_cache/fast

# The main all target
all: cmake_check_build_system
	$(CMAKE_COMMAND) -E cmake_progress_start /make/rast/FSS/funshade/CMakeFiles /make/rast/FSS/funshade//CMakeFiles/progress.marks
	$(MAKE) $(MAKESILENT) -f CMakeFiles/Makefile2 all
	$(CMAKE_COMMAND) -E cmake_progress_start /make/rast/FSS/funshade/CMakeFiles 0
.PHONY : all

# The main clean target
clean:
	$(MAKE) $(MAKESILENT) -f CMakeFiles/Makefile2 clean
.PHONY : clean

# The main clean target
clean/fast: clean
.PHONY : clean/fast

# Prepare targets for installation.
preinstall: all
	$(MAKE) $(MAKESILENT) -f CMakeFiles/Makefile2 preinstall
.PHONY : preinstall

# Prepare targets for installation.
preinstall/fast:
	$(MAKE) $(MAKESILENT) -f CMakeFiles/Makefile2 preinstall
.PHONY : preinstall/fast

# clear depends
depend:
	$(CMAKE_COMMAND) -S$(CMAKE_SOURCE_DIR) -B$(CMAKE_BINARY_DIR) --check-build-system CMakeFiles/Makefile.cmake 1
.PHONY : depend

#=============================================================================
# Target rules for targets named funshade

# Build rule for target.
funshade: cmake_check_build_system
	$(MAKE) $(MAKESILENT) -f CMakeFiles/Makefile2 funshade
.PHONY : funshade

# fast build rule for target.
funshade/fast:
	$(MAKE) $(MAKESILENT) -f CMakeFiles/funshade.dir/build.make CMakeFiles/funshade.dir/build
.PHONY : funshade/fast

#=============================================================================
# Target rules for targets named test_fss

# Build rule for target.
test_fss: cmake_check_build_system
	$(MAKE) $(MAKESILENT) -f CMakeFiles/Makefile2 test_fss
.PHONY : test_fss

# fast build rule for target.
test_fss/fast:
	$(MAKE) $(MAKESILENT) -f CMakeFiles/test_fss.dir/build.make CMakeFiles/test_fss.dir/build
.PHONY : test_fss/fast

fss.o: fss.c.o
.PHONY : fss.o

# target to build an object file
fss.c.o:
	$(MAKE) $(MAKESILENT) -f CMakeFiles/funshade.dir/build.make CMakeFiles/funshade.dir/fss.c.o
.PHONY : fss.c.o

fss.i: fss.c.i
.PHONY : fss.i

# target to preprocess a source file
fss.c.i:
	$(MAKE) $(MAKESILENT) -f CMakeFiles/funshade.dir/build.make CMakeFiles/funshade.dir/fss.c.i
.PHONY : fss.c.i

fss.s: fss.c.s
.PHONY : fss.s

# target to generate assembly for a file
fss.c.s:
	$(MAKE) $(MAKESILENT) -f CMakeFiles/funshade.dir/build.make CMakeFiles/funshade.dir/fss.c.s
.PHONY : fss.c.s

test/test_fss.o: test/test_fss.c.o
.PHONY : test/test_fss.o

# target to build an object file
test/test_fss.c.o:
	$(MAKE) $(MAKESILENT) -f CMakeFiles/test_fss.dir/build.make CMakeFiles/test_fss.dir/test/test_fss.c.o
.PHONY : test/test_fss.c.o

test/test_fss.i: test/test_fss.c.i
.PHONY : test/test_fss.i

# target to preprocess a source file
test/test_fss.c.i:
	$(MAKE) $(MAKESILENT) -f CMakeFiles/test_fss.dir/build.make CMakeFiles/test_fss.dir/test/test_fss.c.i
.PHONY : test/test_fss.c.i

test/test_fss.s: test/test_fss.c.s
.PHONY : test/test_fss.s

# target to generate assembly for a file
test/test_fss.c.s:
	$(MAKE) $(MAKESILENT) -f CMakeFiles/test_fss.dir/build.make CMakeFiles/test_fss.dir/test/test_fss.c.s
.PHONY : test/test_fss.c.s

# Help Target
help:
	@echo "The following are some of the valid targets for this Makefile:"
	@echo "... all (the default if no target is provided)"
	@echo "... clean"
	@echo "... depend"
	@echo "... edit_cache"
	@echo "... rebuild_cache"
	@echo "... funshade"
	@echo "... test_fss"
	@echo "... fss.o"
	@echo "... fss.i"
	@echo "... fss.s"
	@echo "... test/test_fss.o"
	@echo "... test/test_fss.i"
	@echo "... test/test_fss.s"
.PHONY : help



#=============================================================================
# Special targets to cleanup operation of make.

# Special rule to run CMake to check the build system integrity.
# No rule that depends on this can have commands that come from listfiles
# because they might be regenerated.
cmake_check_build_system:
	$(CMAKE_COMMAND) -S$(CMAKE_SOURCE_DIR) -B$(CMAKE_BINARY_DIR) --check-build-system CMakeFiles/Makefile.cmake 0
.PHONY : cmake_check_build_system
