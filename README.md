# CRHPG
## Table of Contents

- [Getting Started](#started)
- [Users' Guide](#uguide)
  - [Datasets generation commands](#dgen)
  - [Pangenome generation commands](#pgen)
    - [Bifrost](#bifrost)
    - [mdbg](#mdbg)
    - [Minigraph](#minigraph)
    - [pggb](#pggb)
  - [Region extraction commands](#general)
  - [Getting help](#help)
[Citing CRHPG](#cite)


## <a name="started"></a>Getting Started
This repo contains the commands and the script used to generate the pangenome graphs and the regions used in the CRHPG paper. To cite it, please see [here](#cite).
The scripts take as granted that the tools have already been installed in the computer/cluster used and the haplotypes have been downloaded.
To download the haplotypes, you can go to [Google Brain Genomics website][Google Brain Genomics] and [Human Pangenome Reference Consortium website][Human Pangenome Reference Consortium]. 
Loci sequences are provided in a folder of this repo and have been downloaded from the NCBI dataset.

---


## <a name="uguide"></a>Users' Guide

Here below a guide on how to generate the datasets used for the experiments presented in the CRHPG paper, generate the pangenome using the 4 different tools and run part of the analysis (loci extraction).

### <a name="dgen"></a>Dataset Generation Commands
In the paper two kind of datasets are used: the ones specific for Minigrah, that have CHM13 as first haplotype and the rest that use no reference genome in the 2 and 10 haplotype samples.

Minigraph needs a list of haplotypes (in fasta file) to be used in succession, one after the other, Bifrost a list of haplotypes and the other tools use directly one fasta with all the haplotypes inside.

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

### <a name="Pgen"></a>Pangenome Generation Commands
For each tool a command line will be given. If any parameter has to be changed (except the name of the input file), it will be specified before the actual command.
The parameters used are based on the tools documentation (github page or readthedocs) and on additional material (for pggb this [paper][dhpr] and [experimental setup page][hdpr_pggb]).

#### <a name="bifrost"></a>Bifrost Pagenome Generation Commands

To download Bifrost, visit [bifrost web page][bifrost]. 
Use the .txt files pro
To run it, use the 

```sh
Bifrost build -r $data_dir/assemblies_all.txt -o $graph_dir/bifrost_graph_all_100time -k 100 -t 8 -v -c
```
Replacing the [number_of_threads] with the actual number of threads you want to use (8 for the experiments) and [input_file_list] with the file list generated as descripted above.


#### <a name="mdbg"></a>mdbg Pagenome Generation Commands

To download mdbg, visit [mdbg web page][mdbg]. 
To generate the single fasta file for the 2,10 and 104 haplotypes datasets, use the commands specified in the section [dataset][#dgen]
To run it, use 

```sh
./rust-mdbg/target/release/rust-mdbg [input_dataset.fa] -k 10 -d 0.0001 --minabund 1 --reference --prefix [prefix_name]
gfatools asm -u  [prefix_name].gfa > [prefix_name].unitigs.gfa
./rust-mdbg/target/release/to_basespace --gfa [prefix_name].unitigs.gfa --sequences [prefix_name]
```

Replacing the [prefix_name] with the prefix name you want to use for the mdbg files (e.g. mdbg_10) and [input_dataset.fa] with the dataset fasta.
---

#### <a name="pggb"></a>pggb Pagenome Generation Commands

To download pggb, visit [pggb web page][pggb]. 
To generate the single fasta file for the 2,10 and 104 haplotypes datasets, use the commands specified in the section [dataset][#dgen]
To run it, use 
```sh
pggb -i $data_dir/concat1_m.fa -p 98 -s 100000 -n 10 -k 311 -G 13033,13117 -O 0.03 -t 8 -T 8 -Z -o $home/data/graphs/pggb/t1_m
```

Replacing the [number_of_threads] with the actual number of threads you want to use (8 for the experiments) and [input_file_list] with the file list generated as descripted above.
---

#### <a name="minigraph"></a>Minigraph Pagenome Generation Commands

To download Minigraph, visit [minigraph web page][minigraph]. 
To generate the file list for the 2,10 and 104 haplotypes datasets, use the commands specified in the section [dataset][#dgen]
To run it, use 
```sh
minigraph -cxggs -t[number_of_threads] [input_file_list] > out.gfa
```

Replacing the [number_of_threads] with the actual number of threads you want to use (8 for the experiments) and [input_file_list] with the file list generated as descripted above.

---


[Google Brain Genomics]: https://console.cloud.google.com/storage/browser/brain-genomics-public/research/deepconsensus/publication/analysis/genome_assembly
[Human Pangenome Reference Consortium]: https://s3-us-west-2.amazonaws.com/human-pangenomics/index.html?prefix=working/
[minigraph]:https://github.com/lh3/minigraph
[pggb]:https://github.com/pangenome/pggb
[mdbg]:https://github.com/ekimb/rust-mdbg
[bifrost]:https://github.com/pmelsted/bifrost
[hdpr_pggb]:https://github.com/pangenome/HPRCyear1v2genbank
[dhpr][https://www.biorxiv.org/content/10.1101/2022.07.09.499321v1]