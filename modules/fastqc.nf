/* ****************** fastqc ****************** */

process FASTQC {
    tag "FASTQC on ${id}"
    label 'fastqc'
    publishDir "${params.outdir}/fastqc", mode: 'copy'
    
    input:
        tuple val(id), path(fastqs) 
    
    output:
        //tuple val(id),  file("${fastqs.baseName}.html"), file("${fastqs.baseName}.zip")
        path "fastqc_${id}_logs" emit: fastqc_report
    script:

        """
        mkdir fastqc_${id}_logs
        fastqc -t ${task.cpu} -q ${fastqs} --outdir fastqc_${id}_logs                         
        """
}
