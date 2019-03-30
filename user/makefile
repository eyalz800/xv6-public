.PHONY: all clean

PROJECTS = ulib \
	cat \
	echo \
	grep \
	init \
	kill \
	ln \
	ls \
	mkdir \
	rm \
	sh \
	wc \
	uthread

all: 
	@for project in $(PROJECTS) ; do \
		$(MAKE) -s -C $$project; \
	done

clean:
	@for project in $(PROJECTS) ; do \
		$(MAKE) -s -C $$project clean; \
	done