all: setup
	@echo "Please use Cabal to build this package; not make."
	./setup configure
	./setup build

setup: Setup.hs
	ghc --make -package Cabal -o setup Setup.hs

install: setup
	./setup install

clean:
	-runghc Setup.hs clean
	-rm -rf html `find . -name "*.o"` `find . -name "*.hi" | grep -v debian` \
		`find . -name "*~" | grep -v debian` *.a setup dist testsrc/runtests \
		local-pkg doctmp
	-rm -rf testtmp/* testtmp*

.PHONY: test
test: test-ghc test-hugs
	@echo ""
	@echo "All tests pass."

test-hugs: setup
	@echo " ****** Running hugs tests"
	./setup configure -f buildtests --hugs --extra-include-dirs=/usr/lib/hugs/include
	./setup build
	runhugs -98 +o -P$(PWD)/dist/scratch:$(PWD)/dist/scratch/programs/runtests: \
		dist/scratch/programs/runtests/Main.hs

test-ghc: setup
	@echo " ****** Building GHC tests"
	./setup configure -f buildtests
	./setup build
	@echo " ****** Running GHC tests"
	./dist/build/runtests/runtests
