Every script is largely in four stages, consisting of the same order as the corresponding flow of the paper. This file describes the functions of each script.
Before start, enter conda environment named "cibersort". (# conda activate cibersort)

1.	Clustering
Consensus clustering script was written in R while K-means and Hierarchical clustering was scripted in Python. “TCGA_CIBERSORT.txt” was loaded at “1_ConsensusClustering.ipynb” and the clustering result is saved as “CC_result.txt”. The result file is preprocessed by “2_IC_best_score.ipynb” into “itemConsensus_BS.txt”. “3_Km_Hier_clustering.ipynb” performs K-means/hierarchical clustering and merges all clustering results including previous consensus clustering step with survival information from clinical profile(“TCGA_clinical.txt”). Merged data is saved as “clustered_sample.txt”. “4_survival_R.ipynb” shows K-M plot of each clustering method’s result and prints its chi-square and corresponding p-value. “5_survival_python.ipynb” prints/saves K-M plot of hierarchical clustering result, also focusing binary risk group as we stated in our paper (Figure 2).

2.	Boxplot
“boxplot.ipynb” was scripted in Python. The script uses “CIBERSORT_clsadded.txt” as input which includes merged information of the CIBERSORT result and some part of the “clustered_sample.txt” for convenience for various use in further analyses. The same plot as Figure 3 in our paper is saved as “res.tiff”.

3.	Validation
This part contains Python scripts for the internal/external validation of our paper. “1_binary_classification.ipynb” uses “TCGA_trainingset.csv” as training set, preprocessed TCGA CIBERSORT result in input format of our classifier. The dataset is split in a ratio of 8:1:1 and assigned as training set and primary/secondary testset respectively. Last accuracy of both testsets can be checked through the classifier.evaluate() function. Also during this step, graph of internal accuracy and corresponding loss graph are saved(Figure 4). For external validation, risk group of preprocessed ICGC cibersort result(“ORCA_testset.txt”) was predicted with our trained classifier. The result is saved as “CIBERSORT_prediction.txt”. Survival information from “donor.tsv” was merged with prediction result into “clustered_sample.txt”. “3_survival_analysis.ipynb” provides K-M plot of ICGC cohort and saves the plot in “survival.tiff”(Figure 5).

4.	DEG
R based “1_limma.ipynb” provides DEG between trained/predicted risk group of TCGA and ICGC cohort via Limma package. The script loads each gene expression table and corresponding risk group information and performs DEG analysis between high/low risk group of them. The result is saved in toptable format as “TCGA(ICGC)_Low_vs_High_risk.txt”. The result is separated into up/downregulation and individually saved with |logFC|>1.2 and p-value<0.05 thresholds applied via Python based “2_threshold.ipynb”. The script also outputs common DEGs between two cohorts.

You can run entire pipeline via pre-established docker image; https://hub.docker.com/r/asdoper0630/cibersort_final. It contains every required/resulted i/o data, pipeline scripts and required packages. For better effeciency, identical docker image can be built via uploaded "Dockerfile" and uploaded scripts can be run at the container from established image.
