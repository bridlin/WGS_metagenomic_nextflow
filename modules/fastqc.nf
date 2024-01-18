/* ****************** fastqc ****************** */

process quality_check_fastq {
    tag "${id}"
    label 'fastqc'
    publishDir "${params.output}/${assembly.baseName}/agat", mode: 'copy'
    input:
        tuple val(id), file(fastq)
    output:
        tuple val(id),  file("${annotation.baseName}.fa")

    script:

        """
        agat_sp_extract_sequences.pl --gff ${annotation} --fasta ${assembly} -p -o ${annotation.baseName}.fa


        fastqc $fastq_directory/$sample\L001_R1_001.fastq.gz --outdir $output_dir 
        fastqc $fastq_directory/$sample\L001_R2_001.fastq.gz --outdir $output_dir
        """
}
