/* ****************** bowtie2 ****************** */

process BOWTIE2 {
    tag "bowtie2 on ${id}"
    label 'bowtie2'
    publishDir "${params.outdir}/aligned_reads", mode: 'copy'
    
    input:
        tuple val(id), path(fastqs_1) , path(fastqs_2)
    
    output: 
        tuple val(id), 
        path("${id}_aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam"), 
        path("${id}_nonhuman_reads.1.fastq"), 
        path("${id}_nonhuman_reads.2.fastq"), 
        emit: bowtie2
    
    script:    

    """
    echo "bowtie alignment of  ${fastqs_1} ${fastqs_2} on genome ${params.genome}" 
    bowtie2 \
        -x ${params.genome} \
        -1  ${fastqs_1} -2 ${fastqs_2}  \
        --un-conc ${id}_nonhuman_reads.fastq \
        -S ${id}_aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam \
        2> ${params.report_dir}/${id}_bowtie.log
          
    """
                          
        
}