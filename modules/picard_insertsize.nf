/* ****************** picard_insertsize ****************** */

process PICARD_INSERTSIZE {
    tag "picard_insertsize on ${id}"
    label 'picard'
    label 'docker_enabled'
    publishDir "${params.report_dir}", mode: 'copy'

    input:
    tuple val(id), path(bam)

    //output:
    //tuple val(id), path("${id}_aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered_insert_size_metrics.txt") , path("${id}_aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered_insert_size_histogram.pdf")

    """
    picard \
    CollectInsertSizeMetrics   \
    -I ${bam} \
    -O ${id}_aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered_insert_size_metrics.txt  \
    -H ${id}_aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered_insert_size_histogram.pdf  \
    -M 0.5 
    
    """
}