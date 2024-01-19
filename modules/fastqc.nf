/* ****************** fastqc ****************** */

process quality_check_fastq {
    tag "${id}"
    label 'fastqc'
    publishDir "${params.output}/${fastqc.baseName}/fastqc", mode: 'copy'
    input:
        tuple val(id), file(fastq)
    output:
        tuple val(id),  file("${baseName}.html") , file("${baseName}.zip")

    script:

        """
        fastqc ${fastq} --outdir ${outdir}               
        fastqc ${fastq} --outdir ${outdir}               
        """
}
