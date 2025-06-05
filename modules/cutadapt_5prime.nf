/* ****************** cutadapt_5prime ****************** */

process CUTADAPT_5PRIME {
    tag "CUTADAPT_5PRIME on ${id}"
    label 'cutadapt_5prime'
    publishDir "${params.outdir}/multiqc", mode: 'copy'
    
    input:
        tuple  path(reports) , path(nonhuman2)
    
    output:
        tuple val(id), path("${id}_nonhuman_reads_5trimmed.1.fastq"), path("${id}_nonhuman_reads_5trimmed.2.fastq")  , emit: cutadapt_5prime
    
    script:

        """
        cutadapt  -g AGATCGGAAGAGCACACGTCTGAACTCCAGTCA   -G AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT  \
        -o ${id}_nonhuman_reads_5trimmed.1.fastq \
        -p ${id}_nonhuman_reads_5trimmed.2.fastq  \
        ${nonhuman1}  ${nonhuman2} \
        --minimum-length 40 \
        > ${params.report_dir}/${id}_cutadapt_5prime.log                 
        
        """

}