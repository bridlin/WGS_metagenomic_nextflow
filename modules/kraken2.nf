/* ****************** kraken2 ****************** */

process KRAKEN2 {
    tag "kraken2 on ${id}_${db_name}"
    label 'kraken2'
    publishDir "${params.outdir}/kraken2/${db_name}", mode: 'copy'
    
    input:
    tuple val(id), path(read1), path(read2) 
    tuple val(db_name), path(db_path)
    
    
    
    output:
        tuple val(id), val(db_name), path("${id}_${db_name}.k2report"), emit: kraken_report
        tuple val(id), val(db_name), path("${id}_${db_name}.kraken2"), emit: kraken_classification

    
    script:

        """	

        
        echo "DEBUG db_name=${db_name}"
        echo "DEBUG db_path=${db_path}"



        echo "kraken2  of  ${read1} ${read2} on genome ${db_name} " 
        kraken2 \
        --db ${db_path} \
        --threads 8 \
        --minimum-hit-groups 3  \
        --report-minimizer-data \
        --report ${id}_${db_name}.k2report  \
        --paired ${read1} ${read2} \
        > ${id}_${db_name}.kraken2 
        
        
        """


}
