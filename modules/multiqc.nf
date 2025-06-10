/* ****************** multiqc  ****************** */

process MULTIQC {
    tag "multiqc"
    label 'multiqc'
    publishDir "${params.outdir}/kraken2/${db_name}", mode: 'copy'
    
    input:
    path(report)
    
    
    
    script:

        """	           
        multiqc   \
        ${params.report_dir} \
        --outdir ${params.outdir}/multiqc
        """        


}
