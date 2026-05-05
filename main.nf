#! /usr/bin/env nextflow
nextflow.enable.dsl=2








// *************  DEAL with provided params ****************


// ****************************** MODULES ****************************
include { FASTQC as FASTQC_raw; FASTQC as FASTQC_trim  } from "${baseDir}/modules/fastqc.nf"
include { CUTADAPT_3PRIME } from "${baseDir}/modules/cutadapt_3prime.nf"
include { TRIMMOMATIC } from "${baseDir}/modules/trimmomatic.nf"
include { BOWTIE2 } from "${baseDir}/modules/bowtie.nf"
include { SAMTOOLS_BAM2SAM } from "${baseDir}/modules/samtools_samtobam.nf"
include { SAMTOOLS_SORT } from "${baseDir}/modules/samtools_sort.nf"
include { SAMTOOLS_INDEX } from "${baseDir}/modules/samtools_index.nf"
include { SAMTOOLS_REHEADER } from "${baseDir}/modules/samtools_reheader.nf"
include { PICARD_INSERTSIZE } from "${baseDir}/modules/picard_insertsize.nf"
include { CUTADAPT_5PRIME } from "${baseDir}/modules/cutadapt_5prime.nf"
include { KRAKEN2 } from "${baseDir}/modules/kraken2.nf"
include { MULTIQC } from "${baseDir}/modules/multiqc.nf"



kraken2_dbs = params.kraken2_dbs.collect { [ it[0], file(it[1]) ] }


log.info """

WGS_metagenomic analysis with Kraken2
===================================================

 General Parameters
     fastq                   : ${params.fastq}
     outdir                  : ${params.outdir}
     run                     : ${params.run}
     Kraken2_db              : ${kraken2_dbs.collect { it[0] }.join(', ')}
     Kraken2_db_path         : ${kraken2_dbs.collect { it[1] }.join(', ')}
     report_dir              : ${params.report_dir}
     genome                  : ${params.genome}



 """



workflow  {
 

    main:


    /*
     * creating channel with input reads
     */
    reads_file_ch = Channel
        .fromFilePairs(params.fastq, checkIfExists: true, flat:true )
        .ifEmpty{ exit 1 , "cannot find reads files ${params.fastq}"}
        
    reads_file_ch.view()
    
    /*
     * read qc and trimming
     */

    fastqc_raw_ch = FASTQC_raw(reads_file_ch)
    cutadapt_3p_out_ch = CUTADAPT_3PRIME(reads_file_ch)
    cutadapt_3p_reads_ch = cutadapt_3p_out_ch.cutadapt_3prime
    cutadapt_3p_report_ch = cutadapt_3p_out_ch.cutadapt_3p_report

    // generating channel with the trimmomatic output 
    trimmomatic_out = TRIMMOMATIC(cutadapt_3p_reads_ch)
    // selecting the reads only from the rtimmomatic channel
    trimmed_reads_ch = trimmomatic_out.trimmomatic_trimmed_reads
    trimmomatic_report_ch = trimmomatic_out.trimmomatic_report
    fastqc_trim_ch = FASTQC_trim(trimmed_reads_ch) 
   


    /*
     * generating channel with human genome for alignemnt
     */
    
    genome_index_ch = Channel
    .fromPath("${params.genome}.*.bt2")
    .collect()
    .ifEmpty { error "Bowtie2 index files not found: ${params.genome}.*.bt2" }
    .map { files -> 
        def firstFile = files[0].getBaseName()  // e.g., TriTrypDB-55_TbruceiLister427_2018_Genome.1
        def prefix = firstFile.replaceAll(/\.(1|2|3|4|rev\.1|rev\.2)$/, "")  // strip the .1 or .rev.1 part
        tuple(prefix, files)
    }
   
    
    /*
     * Alignment
     */

    bowtie2_out_ch = BOWTIE2(trimmed_reads_ch,genome_index_ch).bowtie2
    // bowtie2_ch.view()
    

    /*
     * samtools processing and picard index size
     */


    sam_input_ch = bowtie2_out_ch.map { tuple ->
    def (id, sam, nonhuman1, nonhuman2) = tuple
    [id, sam]
    }
   
    bam_ch = SAMTOOLS_BAM2SAM(sam_input_ch)
    sorted_bam_ch = SAMTOOLS_SORT(bam_ch)
    index_bam_ch  = SAMTOOLS_INDEX(sorted_bam_ch)
    reheader_bam_ch = SAMTOOLS_REHEADER(sorted_bam_ch)
    picard_ch = PICARD_INSERTSIZE(reheader_bam_ch)
    
    
    /*
     * Non‑human reads → 5′ trimming
     */

    nonhuman_reads_ch = bowtie2_out_ch.map { tuple ->
    def (id, sam, nonhuman1, nonhuman2) = tuple
    [id, nonhuman1, nonhuman2]
    }
    
    cutadapt_5p_out_ch = CUTADAPT_5PRIME(nonhuman_reads_ch)
    nonhuman_trimmed_ch = cutadapt_5p_out_ch.cutadapt_5prime
    cutadapt_5p_report_ch = cutadapt_5p_out_ch.cutadapt_5p_report

    
    

    /*
     * Kraken2 classification
     */


    kraken2_db_ch = Channel.from(params.kraken2_dbs)
    
    kraken2_results_ch = nonhuman_trimmed_ch
        .combine(kraken2_db_ch) 
        | KRAKEN2
     
    kraken2_report_ch = kraken2_results_ch.kraken_report
    kraken2_classification_ch = kraken2_results_ch.kraken_classification
   
    


    
    kraken2_mqc_ch =
        kraken2_report_ch.map { id, db_name, report_file ->
            report_file
        }


    
    all_reports_ch = Channel
        .empty()
        .mix(
            fastqc_raw_ch,
            cutadapt_3p_report_ch,
            trimmomatic_report_ch,
            fastqc_trim_ch,
            picard_ch,
            cutadapt_5p_report_ch,
            kraken2_mqc_ch
    )

    
    MULTIQC(all_reports_ch.collect())

    

}

