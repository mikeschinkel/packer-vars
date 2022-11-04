.force:

# The parameter $@ passes the target name that called packer_build()
define packer_build
	packer build -force -var-file="./vars.json" "$@"
endef

all: step1 step2

step1: .force
	$(call packer_build)


step2: .force
	$(call packer_build)
