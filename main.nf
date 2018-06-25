current_dir_path = new File(System.getProperty("user.dir")).getCanonicalPath()

log.info "~~~~~~~ Lyz-nf: lab monitor workflow ~~~~~~~"
log.info "* pwd:                ${current_dir_path}"
log.info "* logDir:             ${params.logDir}"
log.info "* externalConfigFile: ${params.externalConfigFile}"
log.info "* user:               ${params.username}"
log.info "* system:             ${params.hostname}"

println "externalConfig: ${params.externalConfig}"

def MCITdir = params.externalConfig.MCITdir
def syncServer = params.externalConfig.syncServer
def productionDir = params.externalConfig.productionDir
def productionDirNGS50 = params.externalConfig.productionDirNGS50
process sync_demultiplexing {
    input:
    val(x) from Channel.from('')

    script:
    """
    rsync --dry-run -vrthP -e ssh "${productionDir}/" "${params.username}"@"${syncServer}":"${MCITdir}/" \
        --include="Demultiplexing" \
        --include="Demultiplexing/*" \
        --include="Demultiplexing/*/output/***" \
        --exclude="*:*" \
        --exclude="*"
    """
}

enable_sync_NGS580 = false
process sync_NGS580 {
    echo true
    input:
    val(x) from Channel.from('')

    when:
    enable_sync_NGS580 == true

    script:
    """
    rsync --dry-run -vrthPL -e ssh "${productionDir}/ "${params.username}"@"${syncServer}":"${MCITdir}/" \
    --include="NGS580" \
    --include="NGS580/*" \
    --include="NGS580/*/output/***" \
    --exclude="*:*" \
    --exclude="*"
    """
}

enable_sync_NGS50 = true
process sync_NGS50 {
    echo true
    input:
    val(x) from Channel.from('')

    when:
    enable_sync_NGS50 == true

    script:
    """
    rsync --dry-run -vrthP -e ssh "${productionDirNGS50}/" "${params.username}"@"${syncServer}":"${MCITdir}/IonTorrent/NGS50/output/" \
    --exclude='.git*' \
    --exclude='*old' \
    --exclude='*oldbad' \
    --exclude='*_old' \
    --exclude='*_test1' \
    --exclude='*_test' \
    --exclude='test*' \
    --exclude="*:*"
    """
}
