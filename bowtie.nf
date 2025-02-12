/* ****************** bowtie2 ****************** */

process BOWTIE2 {
    tag "bowtie2 on ${id}"
    label 'bowtie2'
    publishDir "${params.outdir}/aligned_reads", mode: 'copy'
    
    input:
        tuple val(id), path(fastqs_1) , path(fastqs_2)
    
    output:
        tuple val(id),  file("${fastqs.baseName}.bam"), file("${fastqs.baseName}.bai")
        
    script:

    """
          
    """
                          
        
}