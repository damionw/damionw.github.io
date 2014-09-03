all:
	@(cd src && ./build_html) > index.html

new:
	(cd src && date=$$(date '+%Y-%m-%d') && cp new_entry.m4 $${date}_blog.m4)
