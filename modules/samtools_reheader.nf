/* ****************** samtools_reheader ****************** */

process SAMTOOLS_REHEADER {
    tag "samtools_reheader on ${id}"
    label 'samtools'
    publishDir "${params.outdir}/aligned_reads", mode: 'copy'

    input:
    tuple val(id), path(bam)

    output:
    tuple val(id), path("${id}_aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered.bam")

    """
    samtools reheader -c 'grep -v ^@PG' ${bam} > ${id}_aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered.bam
    
    
    """
}