/* ****************** cutadapt_5prime ****************** */

process CUTADAPT_5PRIME {
    tag "CUTADAPT_5PRIME on ${id}"
    label 'docker_enabled'
    label 'cutadapt'
    publishDir "${params.outdir}/multiqc", mode: 'copy'
    publishDir "${params.report_dir}", mode: 'copy' , pattern: "*.log"


    input:
        tuple  val(id) , path(nonhuman1), path(nonhuman2)
    
    output:
        tuple val(id), 
            path("${id}_nonhuman_reads_5trimmed.1.fastq"), 
            path("${id}_nonhuman_reads_5trimmed.2.fastq")  , emit: cutadapt_5prime
        path("${id}_cutadapt_5p.log"), emit: cutadapt_5p_report 

    script:

        """
        cutadapt  -g AGATCGGAAGAGCACACGTCTGAACTCCAGTCA   -G AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT  \
        -o ${id}_nonhuman_reads_5trimmed.1.fastq \
        -p ${id}_nonhuman_reads_5trimmed.2.fastq  \
        ${nonhuman1}  ${nonhuman2} \
        --minimum-length 40 \
        > ${id}_cutadapt_5p.log                 
        
        """

}