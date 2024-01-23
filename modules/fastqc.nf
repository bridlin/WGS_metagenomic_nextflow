/* ****************** fastqc ****************** */

process quality_check_fastq {
    tag "${id}"
    label 'fastqc'
    publishDir "${params.output}/fastqc", mode: 'copy'
    
    input:
        tuple val(id), file(fastqs)
    
    output:
        tuple val(id),  file("${fastqs.baseName}.html"), file("${fastqs.baseName}.zip")

    script:

        """
        mkdir fastqc_${id}
        fastqc -t ${task.cpu} -q ${fastqs} --outdir fastqc_${id}                         
        """
}
