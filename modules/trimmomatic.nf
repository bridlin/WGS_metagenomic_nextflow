/* ****************** timmomatic ****************** */


process TRIMMOMATIC {
    tag "TRIMMOMATIC on ${id}"
    label 'trimmomatic'
    publishDir "${params.outdir}/trimmedReads", mode: 'copy'
    
    input:
        tuple val(id), path("${id}_R1_trimmed.fastq.gz"), path("${id}_R2_trimmed.fastq.gz")
    
    output:
        tuple val(id), path("${id}_R1_trimmed_q20.fastq.gz"), path("${id}_R2_trimmed_q20.fastq.gz")
    
    script:
        """
        trimmomatic PE \
        -threads 1 \
        -trimlog ${id}trim \
        ${id}_R1_trimmed.fastq.gz ${id}_R2_trimmed.fastq.gz \
        ${id}_R1_trimmed_q20.fastq.gz  ${id}_R1_trimmed_q20_un.fastq.gz ${id}_R2_trimmed_q20.fastq.gz ${id}_R2_trimmed_q20_un.fastq.gz   \
        SLIDINGWINDOW:4:20 \
        MINLEN:40              
        """
}