/* ****************** samtools_sort ****************** */

process SAMTOOLS_SORT {
    tag "samtools_sort on ${id}"
    label 'samtools_sort'
    publishDir "${params.outdir}/aligned_reads", mode: 'copy'

    input:
    tuple val(id), path(bam)

    output:
    tuple val(id), path("${id}_aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted.bam")

    """
    samtools sort ${bam} -o ${id}_aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted.bam 
    
    """
}