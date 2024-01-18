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
        fastqc ${fastq}/$sample\L001_R1_001.fastq.gz --outdir ${outdir}               # how do I define the individual samples here?
        fastqc ${fastq}/$sample\L001_R2_001.fastq.gz --outdir ${outdir}               # how do I define the individual samples here?
        """
}
