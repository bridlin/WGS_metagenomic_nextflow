#! /usr/bin/env nextflow
nextflow.enable.dsl=2

/*
 * Default pipeline parameters. They can be overriden on the command line eg.
 * given `params.foo` specify on the run command line `--foo some_value`.
 */

params.fastq = "$projectDir/data/*_R{1,2}_001.fastq"
params.outdir = "results"
//params.kraken2_db = "Kraken2_db/PlusPF"
//params.kraken2_db_E = "Kraken2_db/EuPathDB48"
//params.kraken_output_dir = "PlusPF"
//params.kraken_output_dir_2 = "EuPathDB48"
params.run = "runX"





// *************  DEAL with provided params ****************


// ****************************** MODULES ****************************
include { FASTQC } from "${baseDir}/modules/fastqc.nf"




log.info """

WGS_metagenomic analysis with Kraken2
===================================================

 General Parameters
     fastq                   : ${params.fastq}
     outdir                  : ${params.outdir}
     run                     : ${params.run}
     Kraken2_db              : ${params.kraken2_db}



 """



workflow  {
 

    main:
    Channel
        .fromFilePairs(params.fastq, checkIfExists: true)
        .ifEmpty{ exit 1 , "cannot find reads files ${params.fastq}"}
        .set{reads_file}
    fastqc_ch = FASTQC(reads_file)
    // trimming(reads).set{reads_trim}
    // alig(reads_trim).set{reads_trim_ali}
    
}

