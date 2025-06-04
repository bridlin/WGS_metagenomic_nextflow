process SAMTOOLS_REHEADER {
    tag "samtools_reheader on ${id}"
    label 'samtools_reheader'
    publishDir "${params.outdir}/aligned_reads", mode: 'copy'

    input:
    tuple val(id), path(bam)

    output:
    path("${id}_aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered.bam")

    """
    samtools reheader -c 'grep -v ^@PG' ${bam} > ${id}_aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered.bam
    
    samtools \
    reheader -c 'grep -v ^@PG' $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted.bam  \
    > $fastq_directory/$sample\aln-pe_Homo_sapiens.GRCh38.dna.toplevel_sorted_reheadered.bam &&
    """
}