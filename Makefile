SHELL:=/bin/bash
LOGDIR:=logs
TIMESTAMP:=$(shell date +"%Y-%m-%d_%H-%M-%S")

# un-comment this and change it for your config file:
# CONFIG:=config.json
CONFIG:=/gpfs/data/molecpathlab/private_data/lyz-nf-config.json


# ~~~~~ SETUP ~~~~~ #
./nextflow:
	curl -fsSL get.nextflow.io | bash

install: ./nextflow

update: ./nextflow
	./nextflow self-update

CRONFILE:=cron.job
# “At minute 0 past hour 12 and 23.” e.g. 12:00, 23:00 # https://crontab.guru/
CRONINTERVAL:=0 12,18,23 * * *
# CRONINTERVAL:=* * * * *
CRONCMD:=. $(shell echo $$HOME)/.bash_profile; cd $(shell pwd); make run >/dev/null 2>&1
cron:
	@crontab -l > old.cron.$$(date +"%Y-%m-%d_%H-%M-%S") ; \
	croncmd='$(CRONINTERVAL) $(CRONCMD)'; \
	echo "$${croncmd}" > "$(CRONFILE)" && \
	crontab "$(CRONFILE)"


# ~~~~~ RUN ~~~~~ #
run: install
	@if grep -q 'phoenix' <<<'$(HOSTNAME)'; then module unload java && module load java/1.8; fi ; \
	if grep -q 'bigpurple' <<<'$(HOSTNAME)'; then export NXF_PROFILE_ARG='-profile bigpurple'; fi; \
	logdir="$(LOGDIR)/$(TIMESTAMP)" ; \
	mkdir -p "$${logdir}" ; \
	logfile="$${logdir}/nextflow.log" ; \
	stdoutlogfile="$${logdir}/nextflow.stdout.log" ; \
	export NXF_WORK="$${logdir}" ; \
	./nextflow -log "$${logfile}" run main.nf -with-trace -with-timeline -with-report $${NXF_PROFILE_ARG:-} --logSubDir "$(TIMESTAMP)" --externalConfigFile "$(CONFIG)" $(EP) | \
	tee -a "$${stdoutlogfile}"
