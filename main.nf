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
    Channel
        .fromFilePairs(params.fastq, checkIfExists: true, flat:true )
        .ifEmpty{ exit 1 , "cannot find reads files ${params.fastq}"}
        .set{reads_file}
    //reads_file.view()
    fastqc_ch = FASTQC_raw(reads_file)
    cutadapt_ch = CUTADAPT_3PRIME(reads_file)  
    trimmomatic_trimmed_reads_ch = TRIMMOMATIC(cutadapt_ch).trimmomatic_trimmed_reads
    //trimmomatic_report_ch = TRIMMOMATIC(cutadapt_ch).trimmomatic_report
    
    //trimmomatic_ch.groupTuple().view()
    // trimmomatic_ch.view()
    fastqc_ch_2 = FASTQC_trim(trimmomatic_trimmed_reads_ch) 
    // bowtie2_input_ch = trimmomatic_trimmed_reads_ch.map { id, r1, r2 -> tuple(id, r1, r2, file(params.genome)) }
    // bowtie2_input_ch.view()
    genome_index_ch = Channel
    .fromPath("${params.genome}.*.bt2")
    .collect()
    .ifEmpty { error "Bowtie2 index files not found: ${params.genome}.*.bt2" }
    .map { files -> 
        def firstFile = files[0].getBaseName()  // e.g., TriTrypDB-55_TbruceiLister427_2018_Genome.1
        def prefix = firstFile.replaceAll(/\.(1|2|3|4|rev\.1|rev\.2)$/, "")  // strip the .1 or .rev.1 part
        tuple(prefix, files)
    }
   
    // genome_index_ch.view()

    bowtie2_ch = BOWTIE2(trimmomatic_trimmed_reads_ch,genome_index_ch).bowtie2
    // bowtie2_ch.view()
    
    sam_input_ch = bowtie2_ch.map { tuple ->
    def (id, sam, nonhuman1, nonhuman2) = tuple
    [id, sam]
    }
    // sam_input_ch.view()
    
    bam_ch = SAMTOOLS_BAM2SAM(sam_input_ch)
    // bam_ch.view()

    sorted_ch = SAMTOOLS_SORT(bam_ch)
    // sorted_ch.view()
    index_ch  = SAMTOOLS_INDEX(sorted_ch)
    // index_ch.view()
    reheader_ch = SAMTOOLS_REHEADER(sorted_ch)
    //reheader_ch.view()

    insert_size_ch = PICARD_INSERTSIZE(reheader_ch)
    // insert_size_ch.view()

    cutadapt5_input_ch = bowtie2_ch.map { tuple ->
    def (id, sam, nonhuman1, nonhuman2) = tuple
    [id, nonhuman1, nonhuman2]
    }
    // cutadapt5_input_ch.view()
    
     // Nonhuman reads trimming
     // This is the 5' end trimming of nonhuman reads
     // It is done after bowtie2 alignment to remove the adapter sequences
     // from the nonhuman reads
    nonhuman_ch=CUTADAPT_5PRIME(cutadapt5_input_ch)
    // nonhuman_ch.view()
    
    kraken2_db_ch = Channel.from(params.kraken2_dbs)
    // kraken2_db_ch.view()

    // nonhuman_ch.combine(kraken2_db_ch).view()
    
    kraken2_results_ch = nonhuman_ch.combine(kraken2_db_ch) | KRAKEN2
    // kraken2_results_ch.view() 

   
    Channel.fromPath(params.report_dir).view() 
        .ifEmpty{ exit 1 , "cannot find reports (${params.report_dir}"}
        .set{multiqc_ch}
    
    
    MULTIQC(multiqc_ch)

    

}

