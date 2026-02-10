########
# Diff #
########

# Returns the list of changed files for some given extensions and some given folders.
#
# @param $1 The file extensions of changed files
# @param $2 The relative folders to parse for changed files
#
# Examples:
#
# Example #1: list PHP and Javascript files changed in the src and test folders
#
#   $(call git_diff, php js, src test)

define git_diff
$(shell \
	for ext in $(if $(strip $(1)),$(strip $(1)),"") ; \
	do \
		for dir in $(if $(strip $(2)),$(strip $(2)),"") ; \
		do \
			git --no-pager diff --name-status "$$(git merge-base HEAD origin/master)" \
				| grep "$${ext}\$$" \
				| grep "\\s$${dir}" \
				| grep -v '^D' \
				| awk '{ print $$NF }' || true ; \
		done ; \
	done \
)
endef
