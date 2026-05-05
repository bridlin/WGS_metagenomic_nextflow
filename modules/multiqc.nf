/* ****************** multiqc  ****************** */

process MULTIQC {
    tag "multiqc"
    label 'multiqc'
    publishDir "${params.outdir}/multiqc", mode: 'copy'
    
    input:
    path(report_dir)
    
    
    output:
    path("multiqc_report.html")
    path("multiqc_data")

    
    script:

        """	           
        multiqc   \
            ${report_dir} \
            --outdir .
        """        


}
