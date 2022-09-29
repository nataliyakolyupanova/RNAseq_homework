params.results_dir = "results/"
SRA_list = params.SRA.split(",")
tr  = params.transcriptome

log.info ""
log.info "SRA number         : ${SRA_list}"
log.info "Results location   : ${params.results_dir}"

process DownloadFastQ {
  publishDir "${params.results_dir}"

  input:
    val sra

  output:
    path "${sra}/*"

  script:
    """
    /content/sratoolkit.3.0.0-ubuntu64/bin/fastq-dump --gzip --split-3 ${sra} -O ${sra}/
    """
}


process Kallisto {
  input:
    path transcriptome
    path reads
  script:
    """
    /content/kallisto/build/src/kallisto index -i transcriptome.idx ${transcriptome}
    /content/kallisto/build/src/kallisto quant -i transcriptome.idx -o results --single -l 31 -s 1 $reads
    """
}


workflow {
  data = Channel.of( SRA_list )
  DownloadFastQ(data)
  Kallisto( tr , DownloadFastQ.out )
}
