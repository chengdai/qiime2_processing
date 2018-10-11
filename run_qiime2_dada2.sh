# Parameters to change
export TMPDIR="/data01/datasets/metagenomics/analysis/16s_analysis/tmp"
project = 'multi_cities_updown_chelsea'
base='multi_cities_updown_chelsea'
parent_folder='16s_analysis'

source activate qiime2-2018.2

# Import demultiplexed sequences. Must give a manifest file with columns: sample-id, absolute-filepath, direction
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path ${parent_folder}/${project}/${base}_manifest.csv \
  --output-path ${parent_folder}/${project}/${base}_16s.qza \
  --source-format PairedEndFastqManifestPhred33

qiime demux summarize \
  --i-data ${parent_folder}/${project}/${base}_16s.qza \
  --o-visualization ${parent_folder}/${project}/${base}_16s.qzv

# Run DADA2
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs ${parent_folder}/${project}/${base}_16s.qza \
  --p-trim-left-f 10 \
  --p-trim-left-r 10 \
  --p-trunc-len-f 180 \
  --p-trunc-len-r 180 \
  --p-n-threads 20 \
  --verbose \
  --o-representative-sequences ${parent_folder}/${project}/${base}_rep-seqs-dada2.qza \
  --o-table ${parent_folder}/${project}/${base}_table-dada2.qza

# Generate feature table, must input a metadata file
qiime feature-table summarize \
  --i-table ${parent_folder}/${project}/${base}_table-dada2.qza \
  --o-visualization ${parent_folder}/${project}/${base}_table-dada2.qzv \
  --m-sample-metadata-file ${parent_folder}/${project}/${base}_qiime2_metadata.tsv

qiime feature-table tabulate-seqs \
  --i-data ${parent_folder}/${project}/${base}_rep-seqs-dada2.qza \
  --o-visualization ${parent_folder}/${project}/${base}_rep-seqs-dada2.qzv

if [! -d ${parent_folder}/${project}/feature_table]; then
  mkdir ${parent_folder}/${project}/feature_table
fi

# Export feature table into a tsv file
qiime tools export ${parent_folder}/${project}/${base}_table-dada2.qza --output-dir ${parent_folder}/${project}/feature_table/
biom convert -i ${parent_folder}/${project}/feature_table/feature-table.biom \
-o ${parent_folder}/${project}/feature_table/multi_cities_feature_table.tsv --to-tsv
