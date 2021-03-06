# Donwload high-throughput nucleotide sequence data file from Sequence Read Archive

## Requirement

- Docker
- cwltool

## Usage

If you already installed [cwltool](https://github.com/common-workflow-language/cwltool) or another CWL implementation, try:

```
$ cwltool "https://raw.githubusercontent.com/pitagora-network/pitagora-cwl/master/workflows/download-fastq/download-fastq.cwl" --run_ids "SRR1274307"
```

Use job config file to give input parameters to download multiple runs:

```
$ curl -o job.yml "https://raw.githubusercontent.com/pitagora-network/pitagora-cwl/master/workflows/download-fastq/download-fastq.yml"
$ # Edit job.yml
$ cwltool --debug "https://raw.githubusercontent.com/pitagora-network/pitagora-cwl/master/workflows/download-fastq/download-fastq.cwl" "job.yml"
```

You can download the workflow definition file and run:

```
$ curl -o "download-fastq.cwl" "https://raw.githubusercontent.com/pitagora-network/pitagora-cwl/master/workflows/download-fastq/download-fastq.cwl"
$ cwltool download-fastq.cwl --run_ids "SRR1274307"
```

If you haven't installed any CWL runner and don't have time to, you can use cwltool Docker container:

```
$ curl -o "download-fastq.cwl" "https://raw.githubusercontent.com/pitagora-network/pitagora-cwl/master/workflows/download-fastq/download-fastq.cwl"
$ ls
download-fastq.cwl
$ docker run -ti -w /work -v $(pwd):/work -v /tmp:/tmp -v /var/run/docker.sock:/var/run/docker.sock quay.io/inutano/cwltool:1.0.20180820141117-alpine3.8 sh
$ cwltool "download-fastq.cwl" --run_ids "SRR1274307"
```

## Troubleshoot

This workflow downloads data from EBI ftp server by default, but sometimes you cannot download a file for some reasons. You can change the repository by adding the option `--repo`

```
$ cwltool "https://raw.githubusercontent.com/pitagora-network/pitagora-cwl/master/workflows/download-fastq/download-fastq.cwl" --run_ids "SRR1274306" --repo "ncbi"
```

Or you can edit the job conf YAML file.
