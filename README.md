# CRHPG
## Table of Contents

- [Getting Started](#started)
- [Users' Guide](#uguide)
  - [Datasets generation commands](#dgen)
  - [Pangenome generation commands](#install)
  - [Region extraction commands](#general)
  - [Getting help](#help)
[Citing CRHPG](#cite)


## <a name="started"></a>Getting Started
This repo contains the commands and the script used to generate the pangenome graphs and the regions used in the CRHPG paper. To cite it, please see [here](#cite).
The scripts take as granted that the tools have already been installed in the computer/cluster used and the haplotypes have been downloaded.
To download the haplotypes, you can go to [Google Brain Genomics website][Google Brain Genomics] and [Human Pangenome Reference Consortium website][Human Pangenome Reference Consortium]
Loci sequences are provided in a folder of this repo and have been downloaded from the NCBI dataset.

---


## <a name="dgen"></a>Dataset Generation Commands
In the paper two kind of datasets are used: the ones specific for Minigrah, that have CHM13 as first haplotype and the rest that use no reference genome in the 2 and 10 haplotype samples.

Minigraph needs a list of haplotypes (in fasta file) to be used in succession, one after the other, while the other tools use directly one fasta with all the haplotypes inside.

To generate the file list for minigraph datasets, use 

```sh
input_files=""
file_list=$1

while IFS= read -r line; do
   input_files="${input_files} $line"
done < $file_list
```

giving as input the .txt files given in the "assemblies/minigraph" folder.

To generate the single fasta to give as input for the other 3 tools you can use

```sh
input_files=""
file_list=$1
outfile=$2

while IFS= read -r line; do
   input_files="$input_files $line"
done < $file_list

cat $input_files > $outfile
```
giving as 

## <a name="uguide"></a>Users' Guide
Tools have been run with their specific command line parameters.
###MINIGRAPH
To download Minigraph, visit the [minigraph web page][minigraph]. 
To generate the file list for the 2,10 and 104 haplotypes datasets, use 
```sh
input_files=""
file_list=assemblies.txt

while IFS= read -r line; do
   input_files="${input_files} $line"
done < $file_list
```
To run it, use 
```sh
minigraph -cxggs -t 8 CHM13.fa GRCh38.fa hap1.fa ...  > minigraph_pangenome.gfa
```


---


[Google Brain Genomics]: https://console.cloud.google.com/storage/browser/brain-genomics-public/research/deepconsensus/publication/analysis/genome_assembly
[Human Pangenome Reference Consortium]: https://s3-us-west-2.amazonaws.com/human-pangenomics/index.html?prefix=working/
[minigraph]:https://github.com/lh3/minigraph
[pggb]:https://github.com/pangenome/pggb
[mdbg]:https://github.com/ekimb/rust-mdbg
[bifrost]:https://github.com/pmelsted/bifrost
[hdpr_pggb]:https://github.com/pangenome/HPRCyear1v2genbank
