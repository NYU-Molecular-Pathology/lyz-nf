SHELL:=/bin/bash
LOGDIR:=logs
TIMESTAMP:=$(shell date +"%Y-%m-%d_%H-%M-%S")
# CONFIG:=config.json
CONFIG:=/ifs/data/molecpathlab/private_data/lyz-nf-config.json

# ~~~~~ SETUP ~~~~~ #
./nextflow:
	curl -fsSL get.nextflow.io | bash

install: ./nextflow

update: ./nextflow
	./nextflow self-update

CRONFILE:=cron.job
CRONINTERVAL:=*/5 * * * *
CRONCMD:=cd $(shell pwd); make run
cron:
	crontab -l > old.cron.$$(date +"%Y-%m-%d_%H-%M-%S") ; \
	croncmd='$(CRONINTERVAL) $(CRONCMD)'; \
	echo "$${croncmd}" > "$(CRONFILE)" && \
	crontab "$(CRONFILE)"


# ~~~~~ RUN ~~~~~ #
run: install
	if [ "$$( module > /dev/null 2>&1; echo $$?)" -eq 0 ]; then module unload java && module load java/1.8 ; fi ; \
	logdir="$(LOGDIR)/$(TIMESTAMP)" ; \
	mkdir -p "$${logdir}" ; \
	logfile="$${logdir}/nextflow.log" ; \
	stdoutlogfile="$${logdir}/nextflow.stdout.log" ; \
	export NXF_WORK="$${logdir}" ; \
	./nextflow -log "$${logfile}" run main.nf -with-trace -with-timeline -with-report --logSubDir "$(TIMESTAMP)" --externalConfigFile "$(CONFIG)" $(EP) | \
	tee -a "$${stdoutlogfile}"
