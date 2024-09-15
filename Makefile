PKG = el-who.el

test: checkdoc
checkdoc:
	emacs \
	--batch \
	-Q \
	--load $(PKG) \
	$(PKG) \
	-f checkdoc
