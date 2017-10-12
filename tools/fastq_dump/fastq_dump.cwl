cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: inutano/sra-toolkit:2.8.2

baseCommand: [fastq-dump, --split-spot, --stdout, --readids]

requirements:
  - class: InlineJavascriptRequirement

inputs:
  sraFiles:
    type: File[]
    inputBinding:
      position: 1
  out_fastq_prefix:
    type: string

outputs:
  fastq:
    type: stdout

stdout: $(inputs.out_fastq_prefix + ".fastq")
