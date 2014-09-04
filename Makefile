today_file := $(shell echo $$(date '+%Y-%m-%d')_blog.m4)

all:
	@(cd src && ./build_html) > index.html

new: new_content all

new_content:
	@(cd src && test -f $(today_file) && echo $(today_file) already exists || cp new_entry.m4 $(today_file))
