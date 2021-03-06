#!/bin/bash
# hisat2_se.sh <path to data dir> <path to index file (e.g. hoge.1.ht2)> <path to hisat2_se.cwl> <path to hisat2_se.yaml.sample>
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
INDEX_FILE_PATH="$(get_abs_path ${2})"
CWL_PATH="$(get_abs_path ${3})"
YAML_TMP_PATH="$(get_abs_path ${4})"

run_hisat2_se(){
  local fpath="${1}"
  local id=$(basename "${fpath}" | sed 's:.fastq.*$::g' | sed 's:_.$::g')
  local result_dir="${BASE_DIR}/result/${id:0:6}/${id}"
  local yaml_path="${result_dir}/${id}.yaml"

  mkdir -p "${result_dir}" && cd "${result_dir}"
  config_yaml_single_end "${yaml_path}" "${fpath}"
  run_cwl "${result_dir}" "${yaml_path}"

  cd "${BASE_DIR}"
}

config_yaml_single_end(){
  local yaml_path="${1}"
  local fpath="${2}"

  local idx_basedir=$(dirname ${INDEX_FILE_PATH})
  local idx_basename=$(basename ${INDEX_FILE_PATH} | sed 's:\..*$::g')

  cp "${YAML_TMP_PATH}" "${yaml_path}"
  sed -E \
    -i.buk \
    -e "s:_INDEX_DIR_PATH_:${idx_basedir}:" \
    -e "s:_INDEX_BASENAME_:${idx_basename}:" \
    -e "s:_FASTQ_PATH_:${fpath}:" \
    -e "s:_NTHREADS_:${NCPUS}:" \
    "${yaml_path}"
}

run_cwl(){
  local result_dir="${1}"
  local yaml_path="${2}"
  cwltool \
    --debug \
    --leave-container \
    --timestamps \
    --compute-checksum \
    --record-container-id \
    --cidfile-dir ${result_dir} \
    --outdir ${result_dir} \
    ${CWL_PATH} \
    "${yaml_path}" \
    2> "${result_dir}/cwltool.log"
}

find "${DATA_DIR_PATH}" -name '*.fastq*' | while read fpath; do
  run_hisat2_se "${fpath}"
done
