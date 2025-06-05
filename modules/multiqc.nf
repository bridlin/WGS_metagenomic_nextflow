/* ****************** multiqc  ****************** */

process MULTIQC {
    tag "multiqc"
    label 'multiqc'
    publishDir "${params.outdir}/kraken2/${db_name}", mode: 'copy'
    
    input:
    path(report)
    
    
    // output:
    // tuple val(id), val(db_name), path("${id}_${db_name}_k2report"), emit: kraken2
    
    script:

        """	           
        multiqc   \
        ${params.report_dir} \
        --outdir ${params.outdir}/multiqc
        """        


}
