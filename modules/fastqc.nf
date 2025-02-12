/* ****************** fastqc ****************** */

process FASTQC {
    tag "FASTQC on ${id}"
    label 'fastqc'
    publishDir "${params.outdir}/fastqc", mode: 'copy'
    
    input:
        tuple val(id), path(fastqs_1) , path(fastqs_2)
    
    output:
        //tuple val(id),  file("${fastqs.baseName}.html"), file("${fastqs.baseName}.zip")
        path("fastqc_${id}_${fastqs_1}_logs") , emit: fastqc_report
        //tuple val(id), path("*.html"), emit: html
        //tuple val(id), path("*.zip") , emit: zip
    script:

    """
    echo "fastqc on ${fastqs_1} ${fastqs_1}"
    mkdir fastqc_${id}_${fastqs_1}_logs 
    fastqc \
    -t ${task.cpus} \
    -q ${fastqs_1} ${fastqs_2}\
    --outdir fastqc_${id}_${fastqs_1}_logs       
    """
                          
        
}
