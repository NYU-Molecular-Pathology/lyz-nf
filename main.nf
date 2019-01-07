// check for lock file
def lockFile = new File("${params.lockFile}")
def isLocked = lockFile.exists()
// create lock file if it does not exist
if ( isLocked == false ){
    lockFile.createNewFile()
}
def workflowTimestamp = "${workflow.start.format('yyyy-MM-dd-HH-mm-ss')}"

log.info "~~~~~~~ lyz-nf: lab monitor workflow ~~~~~~~"
log.info "* launchDir:          ${workflow.launchDir}"
log.info "* workDir:            ${workflow.workDir}"
log.info "* logDir:             ${params.logDir}"
log.info "* externalConfigFile: ${params.externalConfigFile}"
log.info "* user:               ${params.username}"
log.info "* system:             ${params.hostname}"
log.info "* isLocked:           ${isLocked}"
log.info "* Launch time:        ${workflowTimestamp}"
log.info "* Project dir:        ${workflow.projectDir}"
log.info "* Launch dir:         ${workflow.launchDir}"
log.info "* Work dir:           ${workflow.workDir.toUriString()}"
log.info "* Profile:            ${workflow.profile ?: '-'}"
log.info "* Script name:        ${workflow.scriptName ?: '-'}"
log.info "* Script ID:          ${workflow.scriptId ?: '-'}"
log.info "* Container engine:   ${workflow.containerEngine?:'-'}"
log.info "* Workflow session:   ${workflow.sessionId}"
log.info "* Nextflow run name:  ${workflow.runName}"
log.info "* Nextflow version:   ${workflow.nextflow.version}, build ${workflow.nextflow.build} (${workflow.nextflow.timestamp})"
log.info "* Launch command:\n${workflow.commandLine}\n"


// // get external configs
def MCITdir = params.MCITdir
def syncServer = params.syncServer
def productionDir = params.productionDir
def productionDirNGS50 = params.productionDirNGS50


// ~~~~~ TASKS TO RUN ~~~~~ //
// only create processes if not locked
if ( isLocked == false ){
    process sync_demultiplexing {

        input:
        val(x) from Channel.from('')

        script:
        if ( workflow.profile == 'bigpurple' )
            """
            ssh '${syncServer}' <<E0F
            rsync -vrthP "${productionDir}/" "/mnt/${params.username}/molecular/MOLECULAR/" \
            --include="Demultiplexing" \
            --include="Demultiplexing/*" \
            --include="Demultiplexing/*/output/***" \
            --exclude='*_test' \
            --exclude="*:*" \
            --exclude="*"
            E0F
            """
        else
            """
            # copy only 'output' directory
            # dont copy files with ':' in the name

            rsync -vrthP -e ssh "${productionDir}/" "${params.username}"@"${syncServer}":"${MCITdir}/" \
            --include="Demultiplexing" \
            --include="Demultiplexing/*" \
            --include="Demultiplexing/*/output/***" \
            --exclude='*_test' \
            --exclude="*:*" \
            --exclude="*"
            """
    }

    enable_sync_NGS580 = true
    process sync_NGS580 {

        input:
        val(x) from Channel.from('')

        when:
        enable_sync_NGS580 == true

        script:
        if ( workflow.profile == 'bigpurple' )
            """
            ssh '${syncServer}' <<E0F
            rsync -vrthP "${productionDir}/" "/mnt/${params.username}/molecular/MOLECULAR/" \
            --include="NGS580" \
            --include="NGS580/*" \
            --include="NGS580/*/output/***" \
            --exclude="*:*" \
            --exclude='*_test' \
            --exclude="*"
            E0F
            """
        else
            """
            # copy only 'output' directory
            # dont copy files with ':' in the name

            rsync -vrthP -e ssh "${productionDir}/" "${params.username}"@"${syncServer}":"${MCITdir}/" \
            --include="NGS580" \
            --include="NGS580/*" \
            --include="NGS580/*/output/***" \
            --exclude="*:*" \
            --exclude='*_test' \
            --exclude="*"
            """
    }

    enable_sync_NGS50 = false
    process sync_NGS50 {

        input:
        val(x) from Channel.from('')

        when:
        enable_sync_NGS50 == true

        script:
        if ( workflow.profile == 'bigpurple' )
            """
            ssh '${syncServer}' <<E0F
            rsync -vrthP "${productionDirNGS50}/" "/mnt/${params.username}/molecular/MOLECULAR/IonTorrent/NGS50/output/" \
            --exclude='.git*' \
            --exclude='*old' \
            --exclude='*oldbad' \
            --exclude='*_old' \
            --exclude='*_test1' \
            --exclude='*_test' \
            --exclude='test*' \
            --exclude="*:*" | \
            grep -v '^skipping'
            E0F
            """
        else
            """
            # dont copy symlinks
            # dont copy files with ':' in the name

            rsync -vrthP -e ssh "${productionDirNGS50}/" "${params.username}"@"${syncServer}":"${MCITdir}/IonTorrent/NGS50/output/" \
            --exclude='.git*' \
            --exclude='*old' \
            --exclude='*oldbad' \
            --exclude='*_old' \
            --exclude='*_test1' \
            --exclude='*_test' \
            --exclude='test*' \
            --exclude="*:*" | \
            grep -v '^skipping'
            """
    }
} else {
    log.info "Workflow is locked; another instance of this workflow is probably running. No tasks will be run"
}


// ~~~~~ CLEANUP ~~~~~ //
workflow.onComplete {
    log.info "Workflow completed"

    // check workflow status
    def status = "NA"
    if( workflow.success ) {
        status = "SUCCESS"
    } else {
        status = "FAILED"
    }

    def msg = """
        lyz-nf execution summary
        ---------------------------
        Success           : ${workflow.success}
        exit status       : ${workflow.exitStatus}
        Launch time       : ${workflow.start.format('dd-MMM-yyyy HH:mm:ss')}
        Ending time       : ${workflow.complete.format('dd-MMM-yyyy HH:mm:ss')} (duration: ${workflow.duration})
        Launch directory  : ${workflow.launchDir}
        Work directory    : ${workflow.workDir.toUriString()}
        Project directory : ${workflow.projectDir}
        Log directory     : ${params.logDir}
        Config File       : ${params.externalConfigFile}
        Script name       : ${workflow.scriptName ?: '-'}
        Script ID         : ${workflow.scriptId ?: '-'}
        Workflow session  : ${workflow.sessionId}
        Workflow repo     : ${workflow.repository ?: '-' }
        Workflow revision : ${workflow.repository ? "$workflow.revision ($workflow.commitId)" : '-'}
        Workflow profile  : ${workflow.profile ?: '-'}
        Workflow container: ${workflow.container ?: '-'}
        container engine  : ${workflow.containerEngine?:'-'}
        Nextflow run name : ${workflow.runName}
        Nextflow version  : ${workflow.nextflow.version}, build ${workflow.nextflow.build} (${workflow.nextflow.timestamp})
        User              : ${params.username}
        System            : ${params.hostname}
        Is Locked         : ${isLocked}
        The command used to launch the workflow was as follows:
        ${workflow.commandLine}
        --
        This email was sent by Nextflow
        cite doi:10.1038/nbt.3820
        http://nextflow.io
        """.stripIndent()


    log.info "Checking lock status"
    // if locked, change status and email messages & subject
    if ( isLocked==true ) {
        status = "LOCKED"
        msg = "* WORKFLOW LOCKED, TASKS NOT RUN *\n${msg}"
    }
    // if not locked and lockfile exists, delete lockfile
    if ( isLocked==false && lockFile.exists()==true ) {
        log.info "Workflow was not locked, lockfile exists"
        log.info "Deleteing lock file"
        lockFile.delete()
    }

    if ( params.sendEmail==true ) {
        log.info "Sending workflow email"
        sendMail {
            to "${params.emailTo}"
            from "${params.emailFrom}"
            subject "[${params.workflowLabel}] ${status} (${params.logSubDir})"
            body "${msg}"
        }
    }
}
