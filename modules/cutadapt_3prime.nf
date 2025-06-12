/* ****************** cutadapt_3prime ****************** */

process CUTADAPT_3PRIME {
    tag "CUTADAPT_3PRIME on ${id}"
    label 'cutadapt'
    label 'docker_enabled'
    publishDir "${params.outdir}/trimmedReads", mode: 'copy'
    
    input:
        tuple val(id), path(fastqs1) , path(fastqs2)
    
    output:
        tuple val(id), path("${id}_R1_trimmed.fastq.gz"), path("${id}_R2_trimmed.fastq.gz")  , emit: cutadapt_3prime
    
    script:

        """
         
        cutadapt  -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA   -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT  \
        -o ${id}_R1_trimmed.fastq.gz \
        -p ${id}_R2_trimmed.fastq.gz  \
        ${fastqs1}  ${fastqs2} \
        --minimum-length 40 \
        > ${params.report_dir}/${id}_cutadapt.log                 
        """
}