/* ****************** cutadapt_3prime ****************** */

process CUTADAPT_3PRIME {
    tag "CUTADAPT_3PRIME on ${id}"
    label 'cutadapt_3prime'
    publishDir "${params.outdir}/trimmedReads", mode: 'copy'
    
    input:
        tuple val(id), path(fastqs) , path(fastqs)
    
    output:
        tuple val(id), path("${id}_R1_trimmed.fastq.gz"), path("${id}_R2_trimmed.fastq.gz")  , emit: cutadapt_3prime
    
    script:

        """
        mkdir -p ${params.report_dir} 
        cutadapt  -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA   -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT  \
        -o ${id}_R1_trimmed.fastq.gz \
        -p ${id}_R2_trimmed.fastq.gz  \
        ${id}_R1_001.fastq  ${id}_R2_001.fastq \
        --minimum-length 40 \
        > ${params.report_dir}/${id}_cutadapt.log                 
        """
}