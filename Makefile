.DEFAULT_GOAL := help

.PHONY: all help build virtualbox qemu clean install

IMAGES		:= $(wildcard *.json)
VIRTUALBOX	:= $(patsubst %.json, virtualbox-%.box, $(IMAGES))
LIBVIRT		:= $(patsubst %.json, libvirt-%.box, $(IMAGES))

all:

help:  ## display this help
	@cat $(MAKEFILE_LIST) | grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' | \
		sort -k1,1 | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: $(VIRTUALBOX) $(LIBVIRT)  ## build all vagrant boxes

virtualbox: $(VIRTUALBOX)  ## build all vagrant virtualbox boxes

qemu: $(LIBVIRT)  ## build all vagrant qemu boxes

clean:  ## remove all images
	rm packer
	rm -rf *.qcow2 *.box packer_cache/

virtualbox-%.box: %.json | packer
	@echo "Build vagrant box $@"
	./packer build --only=virtualbox-iso $<

libvirt-%.box: %.json | packer
	@echo "Build libvirt box $@"
	./packer build --only=qemu $<

packer:  ## install hashicorp packer to local directory
	wget -O .packer.zip https://releases.hashicorp.com/packer/1.3.3/packer_1.3.3_linux_amd64.zip
	unzip .packer.zip
	rm -f .packer.zip

install:  ## install vagrant boxes
	for f in *.box; do \
		vagrant box remove "$$(basename "$$f" .box | cut -d- -f2-)"; \
		vagrant box add --name "$$(basename "$$f" .box | cut -d- -f2-)" "$$f"; \
	done
