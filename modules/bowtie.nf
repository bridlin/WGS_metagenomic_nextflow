/* ****************** bowtie2 ****************** */

process BOWTIE2 {
    tag "bowtie2 on ${id}"
    label 'cutadapt_3prime'
    label 'bowtie2'
    publishDir "${params.outdir}/aligned_reads", mode: 'copy' , pattern: "*.sam"
    publishDir "${params.report_dir}", mode: 'copy' , pattern: "*.log"


    input:
        tuple val(id), path(fastqs_1) , path(fastqs_2) 
        tuple val(index_base), path(index_files)

    
    output: 
        tuple val(id), 
        path("${id}_aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam"), 
        path("${id}_nonhuman_reads.1.fastq"), 
        path("${id}_nonhuman_reads.2.fastq"), 
        emit: bowtie2
        path("${id}_bowtie.log"), emit: bowtie2_report 
    
    script:    

    """
    echo "bowtie alignment of  ${fastqs_1} ${fastqs_2} on genome ${index_base} " 
    bowtie2 \
        -x  ${index_base} \
        -1  ${fastqs_1} -2 ${fastqs_2}  \
        --un-conc ${id}_nonhuman_reads.fastq \
        -S ${id}_aln-pe_Homo_sapiens.GRCh38.dna.toplevel.sam \
        --met-file ${id}_bowtie.log
          
    """
                          
        
}