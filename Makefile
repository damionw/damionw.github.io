TODAYS_FILE := src/$(shell echo $$(date '+%Y-%m-%d')_blog.m4)

all:
	@(cd src && ./build_html) > index.html

latest:
	@find src/[123][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*.m4 -printf "%f\n" | awk -F_ '{print $$1, $$0;}' | sort -r | head -1 | sed -e 's/^[^ ][^ ]*[ ]*//g'

today: $(TODAYS_FILE) latest

$(TODAYS_FILE):
	@cp src/new_entry.m4 $@