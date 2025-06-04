/* ****************** samtools_samtobam ****************** */


process SAMTOOLS_BAM2SAM {
    tag "samtools_samtobam on ${id}"
    label 'samtools_samtobam'
    publishDir "${params.outdir}/aligned_reads", mode: 'copy'



    input:
    tuple val(id), path(sam)

    output:
    tuple val(id), path("${id}_aln-pe_Homo_sapiens.GRCh38.dna.toplevel.bam")

    """
    samtools view -S  -b ${sam}  > ${id}_aln-pe_Homo_sapiens.GRCh38.dna.toplevel.bam
    """
}


