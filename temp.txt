# GenoLight
## Table of Contents

- [Getting Started](#started)
- [Users' Guide](#uguide)
  - [Installation](#install)
  - [General usage](#general)
  - [Getting help](#help)
[Citing GenoLight](#cite)


## <a name="uguide"></a>Users' Guide
Sequencing technologies have provided the basis of most modern genome sequencing studies due to their high base- level accuracy and relatively low cost. One of the central obstacles is mapping reads to the human reference genome. The reliance on a single reference human genome could introduce substantial biases in downstream analyses. More- over, including known variants in the reference makes read mapping, variant calling, and genotyping variant- aware. 
However, reads mapping is becoming a computationally intensive step for most genomic studies. Alignment-free methods have been used to save compute time and memory by avoiding the cost of full-scale alignment (Vinga and Almeida, Bioinformatics 2003). Recently, alignment-free approaches have been applied to SNP genotyping by (Shajiiet al., Bioinformatics 2016) and (Sun and Medvedev, Bioinformatics 2019). They introduce two SNP genotyping toolsnamed LAVA and 
VarGeno, respectively, which build an index from known SNPs (e.g. dbSNP) and then use approx-imate k-mer matching to genotype the donor from sequencing data. LAVA and VarGeno are reported to perform 4 to30 times faster than a standard alignment-based genotyping pipeline while achieving comparable accuracy. However,they require a large amount of memory, about 60GB. In this work, we introduce GenoLight that will address thisproblem with new efficient data structures.

---

## <a name="install"></a>Installation

To download and compile the code run the following commands.

First clone the repository, then cd into it and finally make it.
```sh
git clone --recursive https://github.com/frankandreace/GenoLight.git
cd GenoLight
make
```

You should now find the program in GenoLight folder.

---

##  <a name="general"></a>General Usage

GenoLight has two main functions: it creates a smart SNP dictionary from a reference genome and SNP dicitonary and then it performs the genotypization of a datasets.  
Since the first phase is divided into 5 steps, we provide a shell script, GENOLIGHT, that can be used to create the dictionary and necessary files to perform the genotyping in one call and to actually do the genotyping.  
In order to create the dictionaries and the preprocessing files, you just need to call (from within the GenoLight folder)
```sh
./GENOLIGHT preprocess [-r path to reference genome] [-v path to vcf file] [-n name] [-p prefix] [-o path/to/output/folder]
```
and then to  perform the genotyping
```sh
./GENOLIGHT geno [-x name of reference file (without extension)] [-d path to dataset] [-v path to vcf file] [-n name] [-p prefix] [-o path/to/output/folder]
```
You can also do both with one call using
```sh
./GENOLIGHT both [-r path to reference genome] [-x name of reference file (without extension)] [-d path to dataset] [-v path to vcf file] [-n name] [-p prefix] [-o path/to/output/folder]
```
  
NOTE THAT YOU MUST CHOOSE 2 NAMES FOR [-n name] [-p prefix]. They will be used to store the temporary files and the dictionaries.  

  
[-x name of reference file (without extension)] is the name of the reference genome without its extension (for example if ref = reference.fa than x must be 'reference').  

Moreover, the geno command of the script can be used only if you don't use paired end reads divided in two files with the inner distance between pairs. It uses the dataset file as single end.
  
  
If you don't want to use the script, here's a brief description of GenoLight commands.
The first phase is divided into 5 main functions:  

1. 'create_incomplete_smartSnpDictionary' needs 
    * -r [reference genome]
    * -s [snp dictionary]
    * -p [prefix you want to give to output files]
    * -o [output folder path];

    
    and returns 3 files in the output folder, named: 
    * [output files prefix]Temp.txt
    * [output files prefix]SmartDict[snp dictionary]
    * [output files prefix].chrlens;

2. 'reassembly' needs
    * -n [name you want to give to the new dict]
    * -p [output files prefix]
    * -o [output folder path];
    
    and returns 1 file in the output folder, named: 
    * testReassembly[name new dict].txt

3. 'createFMDIndex' needs
    * [reference genome]
    * [output folder path];

4. 'createFMDIndex' needs
    * [output folder path]/[prefix you want to give to output files]Reassembly[name you want to give to the new dict].txt
    * [output folder path]

5. 'complete_smartSnpDictionary' needs
    * -n [snp dictionary]
    * -p [output files prefix]
    * -o [output folder path].

Usage examples:

```sh
./genolight create_incomplete_smartSnpDictionary -r [reference genome] -s [snp dictionary] -p [output files prefix] -o [output folder path]

./genolight reassembly -n \'[output files prefix]SmartDict[snp dictionary]\' -p [output files prefix] -o [output folder path]

./genolight createFMDIndex [reference genome][output folder path]

./genolight createFMDIndex [output folder path]/[prefix you want to give to output files]Reassembly[name you want to give to the new dict].txt [output folder path]

./genolight complete_smartSnpDictionary -n [snp dictionary] -p [output files prefix] -o [output folder path]
```

The second one has only one function.

5. 'geno' needs
    * -t [number of threads]
    * -r [single end reads]
    * -rl [Left/.1 paired end reads]
    * -rr [Right/.2 paired end reads]
    * -i [inner_distance]
    * -q [quality score]
    * -s [snp dictionary]
    * -p [output files prefix]
    * -o [genotyping output file].

NOTE THAT you should EITHER use '-r' or '-rl' & '-rr' & 'i': or you use them without paired end information or you need to spilt them into 2 files and provide the inner distance between pairs.
The number of threads and the quality score are optional.

Usage example: 

Paired end 

```sh
./genolight geno -t [number of threads] -rl [Left/.1 paired end reads] -rr [Right/.2 paired end reads] -i [inner_distance] -s [snp dictionary] -p [output files prefix] -o [genotyping output file] -tmp [output folder path]
```
or 

Single end 

```sh
./genolight geno -t [number of threads] -r [single end reads] -s [snp dictionary] -p [output files prefix] -o [genotyping output path] -tmp [output folder path]
```
[output folder path] is the path given to all the previous functions.

---

## <a name="help"></a>Getting help
If you encounter bugs or have further questions or
requests, you can raise an issue at the [issue page][issue]. You can also contact Francesco Andreace at francesco.andreace@unipd.it .

---

## <a name="cite"></a>Citing GenoLight

GenoLight paper has been accepted at BITS 2021.
If you use GenoLight in your work, please cite:

[issue]: https://github.com/frankandreace/GenoLight/issues
