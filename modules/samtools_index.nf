/* ****************** samtools_index ****************** */

process SAMTOOLS_INDEX {
    tag "samtools_index on ${id}"
    label 'samtools'
    publishDir "${params.outdir}/aligned_reads", mode: 'copy'

    input:
    tuple val(id), path(bam)

    output:
    tuple val(id), path("${bam}.bai")

    """
    samtools index ${bam}

    """
}