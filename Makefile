all: README.md

Security.ctv: security.md buildxml.R
	pandoc -w html -o Security.ctv security.md
	Rscript --vanilla -e 'source("buildxml.R")'

Security.html: Security.ctv
	Rscript --vanilla -e 'if(!require("ctv")) install.packages("ctv", repos = "http://cran.rstudio.com/"); ctv::ctv2html("Security.ctv")'

README.md: Security.html
	pandoc -w markdown_github -o README.md Security.html
	sed -i.tmp -e 's|( \[|(\[|g' README.md
	sed -i.tmp -e 's| : |: |g' README.md
	sed -i.tmp -e 's|../packages/|http://cran.rstudio.com/web/packages/|g' README.md
	sed -i.tmp -e '4s/.*/| | |\n|---|---|/' README.md
	sed -i.tmp -e '4i*Do not edit this README by hand. See \[CONTRIBUTING.md\]\(CONTRIBUTING.md\).*\n' README.md
	rm *.tmp

check:
	Rscript --vanilla -e 'if(!require("ctv")) install.packages("ctv", repos = "http://cran.rstudio.com/"); print(ctv::check_ctv_packages("Security.ctv", repos = "http://cran.rstudio.com/"))'

checkurls:
	Rscript --vanilla -e 'source("checkurls.R")'

README.html: README.md
	pandoc --from=markdown_github -o README.html README.md

diff:
	git pull
	svn checkout svn://svn.r-forge.r-project.org/svnroot/ctv/pkg/inst/ctv
	cp ./ctv/Security.ctv Security.ctv
	git diff Security.ctv > cran.diff
	git checkout -- Security.ctv
	rm -r ./ctv

svn:
	svn checkout svn+ssh://hrbrmstr@svn.r-forge.r-project.org/svnroot/ctv/
	cp Security.ctv ./ctv/pkg/inst/ctv/
	cd ./ctv
	svn status

release:
	cd ./ctv
	svn commit --message "update Security"
	cd ../
	rm -r ./ctv
