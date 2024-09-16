PKG = el-who.el

test: checkdoc
checkdoc:
	emacs \
	--batch \
	-Q \
	--load $(PKG) \
	$(PKG) \
	-f checkdoc

test:
	emacs --batch -Q --load el-who.el --load el-who-test.el -f ert-run-tests-batch-and-exit
