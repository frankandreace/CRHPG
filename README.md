# CRHPG
## Table of Contents

- [Getting Started](#started)
- [Users' Guide](#uguide)
  - [Datasets generation commands](#dgen)
  - [Pangenome generation commands](#pgen)
    - [Bifrost](#bifrost)
    - [mdbg](#mdbg)
    - [pggb](#pggb)
    - [Minigraph](#minigraph)
  - [Region extraction commands](#rext)
  - [Getting help](#help)
- [Citing CRHPG](#cite)


## <a name="started"></a>Getting Started
This repo contains the commands and the script used to generate the pangenome graphs and the regions used in the CRHPG paper. To cite it, please see [here](#cite). 
Note: this repository is distributed under MIT licence. See LICENCE.txt for more information.
The scripts take as granted that the tools have already been installed in the computer/cluster used and the haplotypes have been downloaded.  
To download the haplotypes, you can go to [Google Brain Genomics website][Google Brain Genomics] and [Human Pangenome Reference Consortium website][Human Pangenome Reference Consortium].   
Loci sequences are provided in the 'loci' folder of this repo and have been downloaded from the NCBI dataset or [pggb dataset][pggb_dataset].  

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
giving as $1 the list of files you want to join and as $2 the output fasta containing the concatenation of fastas. 

### <a name="Pgen"></a>Pangenome Generation Commands
For each tool a command line will be given. If any parameter has to be changed (except the name of the input file), it will be specified before the actual command.  
The parameters used are based on the tools documentation (github page or readthedocs) and on additional material (for pggb this [paper][dhpr] and [experimental setup page][hdpr_pggb]).

### <a name="bifrost"></a>Bifrost Pagenome Generation Commands

To download Bifrost, visit [bifrost web page][bifrost]. Read carefully the instruction to build it with k-mer length > 63.
Use the .txt assemblies list provided in the assemblies directory as input.
To run it, use the 

```sh
Bifrost build -r [haplotype_fasta_list] -o [output prefix_name] -k 100 -t [number_of_threads] -v -c
```
Replacing the [number_of_threads] with the actual number of threads you want to use (8 for the experiments) and [haplotype_fasta_list] with the haplotype list given in the directory assemblies.  
The '-r' is used to give Bifrost 'reference' quality sequences. The k-mer length used is 100 (-k option). The color data structure is built using the command '-c'.


### <a name="mdbg"></a>mdbg Pagenome Generation Commands

To download mdbg, visit [mdbg web page][mdbg]. You will also need [gfatools][gfatools].  
To generate the single fasta file for the 2,10 and 104 haplotypes datasets, use the commands specified in the section [dataset](#dgen).
To run it, use 

```sh
target/release/rust-mdbg [input_dataset.fa] -k 10 -d 0.0001 --minabund 1 --reference --prefix [prefix_name]
gfatools asm -u  [prefix_name].gfa > [prefix_name].unitigs.gfa
target/release/to_basespace --gfa [prefix_name].unitigs.gfa --sequences [prefix_name]
```

Replacing the [prefix_name] with the prefix name you want to use for the mdbg files (e.g. mdbg_10) and [input_dataset.fa] with the dataset fasta.   
For the choice of the parameters, please see [mdbg web page][mdbg].

### <a name="pggb"></a>pggb Pagenome Generation Commands

To download pggb, visit [pggb web page][pggb].  
To see how they built the draft human pangenome reference with pggb, visit [this page][hdpr_pggb].  
To generate the single fasta file for the 2,10 and 104 haplotypes datasets, use the commands specified in the section [dataset](#dgen).  
To run it, use 
```sh
pggb -i [input_dataset.fa] -p 98 -s 100000 -n 10 -k 311 -G 13033,13117 -O 0.03 -t [number_of_threads] -T [number_of_threads] -Z -o [output_folder]
```

Replacing the [number_of_threads] with the actual number of threads you want to use (8 for the experiments) and[input_dataset.fa] with the dataset fasta.   
To understand better the choice of the parameters, please refer to [pggb web page][pggb] (and readthedocs) and the [hdpr paper pipeline for pggb][hdpr_pggb].


### <a name="minigraph"></a>Minigraph Pagenome Generation Commands

To download Minigraph, visit [minigraph web page][minigraph]. 
To generate the file list for the 2,10 and 104 haplotypes datasets, use the commands specified in the section [dataset](#dgen).
To run it, use 
```sh
minigraph -cxggs -t[number_of_threads] [input_file_list] > [out.gfa]
```

Replacing the [number_of_threads] with the actual number of threads you want to use (8 for the experiments) and [input_file_list] with the file list generated as descripted above.

### <a name="rext"></a>Region Extraction Commands
In order to use the script, you should have these tools installed:  
[Minigraph][minigraph];  
[minimap2][minimap2];   
[GraphAligner][graphaligner];   
[Bandage][bandage] (blast+ is required by Bandage);  
[odgi][odgi].  

The script also uses some python scripts to do some operations like tips trimming, graphs colouring for Bandage and formatting outputs of some tools to be used as input for others. They are in the folder /scripts/python.  
The script works with the files organized in this repository as they are. If you change anything, please check the script to make sure it works. 

Usage example for each tool.  
Please, use the [loci_list], [color_scheme] and [selected_region_fasta] provided in the 'loci' subdirectory (same name for same experiment).
Run them from the CRHPG directory to be sure each file is found!

To replicate HLA-E subgraphs extractions, set   
[loci_list] = 'HLA-E_exp.loci.txt' 
[color_scheme] = 'HLA-E.colors.tsv' 
[selected_region_fasta] = 'HLA-E.fa'  

To replicate HLA-A subgraphs extractions, set    
[loci_list] = 'HLA-A_exp.loci.txt'  
[color_scheme] = 'HLA-A.colors.tsv'  
[selected_region_fasta] = 'HLA-A_region.fa'  


Minigraph pangenome graph:  
[bandage_reduce_distance] has to be set to 3.
```sh
sh ./scripts/extract_subgraph.sh mini [input_graph (without .gfa extension)] [loci_list] [threads] [output_folder] [color_scheme] [selected_region_fasta] [bandage_reduce_distance]
```
bifrost pangenome graph:  
[bandage_reduce_distance] has to be set to 3.
```sh
sh ./scripts/extract_subgraph.sh dbg [input_graph (without .gfa extension)] [loci_list] [threads] [output_folder] [color_scheme] [selected_region_fasta] [bandage_reduce_distance] bifrost
```

mdbg pangenome graph:  
[bandage_reduce_distance] has to be set to 1.
```sh
sh ./scripts/extract_subgraph.sh dbg [input_graph (without .gfa extension)] [loci_list] [threads] [output_folder] [color_scheme] [selected_region_fasta] [bandage_reduce_distance] mdbg
```

pggb pangenome graph:  
```sh
sh ./scripts/extract_subgraph.sh pggb [input_graph (without .gfa extension)] [loci_list] [threads] [output_folder] [color_scheme] [selected_region_fasta] [fasta_used_to_generate_the_pangenome] [additional_graph_length_in_bases(-c -L of odgi extract)]

```

additional variation graph extraction using Graphaligner and not odgi or minigraph:
```sh
sh ./scripts/extract_subgraph.sh ga_vg [input_graph (without .gfa extension)] [loci_list] [threads] [output_folder] [color_scheme] [selected_region_fasta] [bandage_reduce_distance]
```


ADDITIONAL INFO:  
[output_folder] should be like : ' ~/my_output_folder ' (no final '/').  

## <a name="help"></a>Getting Help

Please contact francesco[dot]andreace{at}pasteur[dot]fr.  

## <a name="cite"></a>Citing CRHPG



[Google Brain Genomics]: https://console.cloud.google.com/storage/browser/brain-genomics-public/research/deepconsensus/publication/analysis/genome_assembly
[Human Pangenome Reference Consortium]: https://s3-us-west-2.amazonaws.com/human-pangenomics/index.html?prefix=working/
[minigraph]:https://github.com/lh3/minigraph
[pggb]:https://github.com/pangenome/pggb
[mdbg]:https://github.com/ekimb/rust-mdbg
[bifrost]:https://github.com/pmelsted/bifrost
[hdpr_pggb]:https://github.com/pangenome/HPRCyear1v2genbank
[gfatools]:https://github.com/lh3/gfatools
[minimap2]:https://github.com/lh3/minimap2
[graphaligner]:https://github.com/maickrau/GraphAligner
[odgi]:https://github.com/pangenome/odgi
[bandage]:https://github.com/rrwick/Bandage

[dhpr]:https://www.biorxiv.org/content/10.1101/2022.07.09.499321v1
[pggb_dataset]:https://github.com/pangenome/pggb/tree/master/data/HLA
