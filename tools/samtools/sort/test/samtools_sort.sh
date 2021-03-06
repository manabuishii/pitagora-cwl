#!/bin/bash
# samtools_sort.sh <path to data dir> <path to samtools_sort.cwl> <path to samtools_sort.yml.sample>
#
set -e

get_abs_path(){
  echo "$(cd $(dirname "${1}") && pwd -P)/$(basename "${1}")"
}

case "$(uname -s)" in
  Darwin) NCPUS=$(sysctl -n hw.ncpu) ;;
  Linux ) NCPUS=$(nproc) ;;
  * ) NCPUS=1 ;;
esac

BASE_DIR="$(pwd -P)"
DATA_DIR_PATH="$(get_abs_path ${1})"
CWL_PATH="$(get_abs_path ${2})"
YAML_TMP_PATH="$(get_abs_path ${3})"

find "${DATA_DIR_PATH}" -name '*.bam' | while read fpath; do
  id="$(basename "${fpath}" | sed -e 's:.bam$::g')"
  result_dir="${BASE_DIR}/result/${id:0:6}/${id}"
  mkdir -p "${result_dir}" && cd "${result_dir}"

  yaml_path="${result_dir}/${id}.yml"
  cp "${YAML_TMP_PATH}" "${yaml_path}"

  sed -i.buk \
    -e "s:_INPUT_BAM_:${fpath}:" \
    -e "s:_NTHREADS_:${NCPUS}:" \
    "${yaml_path}"

  cwltool \
    --debug \
    --leave-container \
    --timestamps \
    --compute-checksum \
    --record-container-id \
    --cidfile-dir ${result_dir} \
    --outdir ${result_dir} \
    "${CWL_PATH}" \
    "${yaml_path}" \
    2> "${result_dir}/cwltool.log"

  cd "${BASE_DIR}"
done
