
home="$(pwd)"
query=$home/loci

tool=$1
input_file=$2
loci_list=$query/$3
threads=$4
output_folder=$5 
colour_scheme=$query/$6
region=$query/$7


input_name=$(basename $input_file .gfa)
locus_name=$(basename $loci_list .txt)
output_subgraph=$output_folder/graph

echo "----------"
echo -e "[EML]: RUNNING ON NEW FILE \n"
echo "OPTIONS"
echo "GRAPH TYPE: $tool"
echo "INPUT FILE: $input_file"
echo "LOCI LIST: $loci_list"
echo "THREADS: $threads"
echo "OUTPUT FOLDER: $output_folder"
echo "COLOR SCHEME: $colour_scheme"
echo "REGION: $region"
echo "OUTPUT SUBGRAPH: $output_subgraph"


if [ ! -d $output_folder ]
then
    mkdir $output_folder
fi

if [ -f $output_folder/${input_name}.loci_nodes.tsv ]
then
    rm $output_folder/${input_name}.loci_nodes.tsv
fi


case $tool in
    
    mini)
        #module load minigraph
        #module load blast+/2.10.0
        #module load Bandage

        node_distance=$8

        echo -e "NODE DISTANCE: $node_distance \n"

        echo "[EML]: MINIGRAPH on $input_file"
        if [ ! -f $output_folder/region.gaf ]
        then
            minigraph -k 28 -w 15 --vc -t $threads $input_file.gfa $region > $output_folder/region.gaf
        fi
        python3 $home/scripts/python/nodes_manipulation.py palignment -i $output_folder/region.gaf -l 'region' > $output_folder/region_nodes.tsv

        echo '[EML]: getting subgraph.'
        sel_nodes=$(python3 $home/scripts/python/nodes_manipulation.py pnodes -i $output_folder/region_nodes.tsv)
        Bandage reduce $input_file.gfa $output_subgraph.gfa --scope aroundnodes --nodes $sel_nodes --distance $node_distance
        
        while IFS= read -r locus; do
            temp_name="$locus"

            echo "[EML]: Aligning $locus."
            minigraph -k 28 -w 15 --vc -t $threads $output_subgraph.gfa $query/$locus.fa > $output_folder/$temp_name.gaf
            python3 $home/scripts/python/nodes_manipulation.py palignment -i $output_folder/${temp_name}.gaf -l $locus >> $output_folder/loci_nodes.tsv
        done < $loci_list

        echo '[EML]: annotating subgraph.'
        python3 $home/scripts/python/nodes_manipulation.py colour -i $output_subgraph.gfa -l $output_folder/loci_nodes.tsv -c $colour_scheme > $output_subgraph.annotated.gfa
        
        ;;
    
    pggb)
        #module load minimap2
        #module load odgi
        #module load GraphAligner

        input_pggb=$8
        extend_bases=$9

        echo -e "PGGB INPUT FILE: $input_pggb \n"

        echo "[EML]: PGGB on $input_file.gfa"
        if [ ! -f $output_folder/loci_regions.bed ]
        then
            if [ ! -f $output_folder/${input_name}.${locus_name}.paf ]
            then
                minimap2 -cxasm5 -t$threads $input_pggb $region > $output_folder/${input_name}.${locus_name}.paf #-k28 -w20 -s1000
            fi
            python3 $home/scripts/python/nodes_manipulation.py bed -i $output_folder/${input_name}.${locus_name}.paf > $output_folder/loci_regions.bed
        fi

        if [ ! -f $input_file.og ]
        then
            odgi build -t $threads -g $input_file.gfa -o $input_file.og --sort
        fi
        echo '[EML]: getting subgraph - odgi extract'
        echo "odgi extract -i $input_file.og -o $output_subgraph.og -b $output_folder/${input_name}.${locus_name}.loci_regions.bed -E -L $extend_bases --threads $threads"
        odgi extract -i $input_file.og -o $output_subgraph.og -b $output_folder/loci_regions.bed -E -L -c $extend_bases --threads $threads
        echo '[EML]: getting subgraph - odgi view'
        echo "odgi view -i $output_subgraph.og -g -t $threads > $output_subgraph.gfa"
        odgi view -i $output_subgraph.og -g -t $threads > $output_subgraph.gfa

        while IFS= read -r locus; do
            temp_name="$locus"

            echo "[EML]: Aligning ${locus}."
            GraphAligner -t $threads -g $output_subgraph.gfa -f $query/$locus.fa -a $output_folder/${temp_name}.gaf -x vg --precise-clipping 0.95 #
            python3 $home/scripts/python/nodes_manipulation.py palignment -i $output_folder/${temp_name}.gaf -l $locus >> $output_folder/loci_nodes.tsv
        done < $loci_list
        
        echo '[EML]: annotating subgraph.'
        python3 $home/scripts/python/nodes_manipulation.py colour -i $output_subgraph.gfa -l $output_folder/loci_nodes.tsv -c $colour_scheme > $output_subgraph.annotated.gfa
        ;;
    
    dbg)
        #module load GraphAligner
        #module load blast+/2.10.0
        #module load Bandage
        #module load gfatools 
            
        node_distance=$8
        alg=$9

        echo "NODE_DISTANCE: $node_distance"
        echo "TOOL: $alg"
        echo ""
        
        echo "[EML]: DBG on $input_file.gfa for $locus_name"
        if [ ! -f $output_folder/region.gaf ]
        then
            GraphAligner -t $threads -g $input_file.gfa -f $region -a $output_folder/region.gaf -x dbg --precise-clipping 0.98
        fi

        python3 $home/scripts/python/nodes_manipulation.py palignment -i $output_folder/region.gaf -l 'region' > $output_folder/region_nodes.tsv

        echo "[EML]: getting nodes from $output_folder/region_nodes.tsv"
        sel_nodes=$(python3 $home/scripts/python/nodes_manipulation.py pnodes -i $output_folder/region_nodes.tsv)
        
        #if [ ! -f $output_subgraph.gfa ]
        #then
        echo '[EML]: getting subgraph'
        echo "Bandage reduce  $input_file.gfa $output_subgraph.gfa --scope aroundnodes --nodes $sel_nodes --distance $node_distance"
        Bandage reduce  $input_file.gfa $output_subgraph.gfa --scope aroundnodes --nodes $sel_nodes --distance $node_distance
        #fi

        case $alg in 

        bifrost)
            echo '[EML]: CLEANING subgraph - bifrost.'
            python3 $home/scripts/python/simplify_dbg.py $output_subgraph.gfa $sel_nodes > $output_subgraph.cleaned.gfa
            mv $output_subgraph.gfa $output_subgraph.raw.gfa
            mv $output_subgraph.cleaned.gfa $output_subgraph.gfa
            ;;
        esac
        

        while IFS= read -r locus; do
            temp_name="$locus"
            if [ ! -f $output_folder/$locus.gaf ]
            then
                echo "[EML]: Aligning ${locus}."
                GraphAligner GraphAligner -t $threads -g $output_subgraph.gfa -f $query/$locus.fa -a $output_folder/$locus.gaf -x dbg --precise-clipping 0.98
            fi
            
            echo "[EML]: reading alignment ${locus}."
            python3 $home/scripts/python/nodes_manipulation.py palignment -i $output_folder/$locus.gaf -l $locus >> $output_folder/loci_nodes.tsv
            
        done < $loci_list
        
        sel_nodes=$(python3 $home/scripts/python/nodes_manipulation.py pnodes -i $output_folder/loci_nodes.tsv)
    
        echo "[EML]: annotating subgraph to $output_subgraph.annotated.gfa"
        python3 $home/scripts/python/nodes_manipulation.py colour -i $output_subgraph.gfa -l $output_folder/loci_nodes.tsv -c $colour_scheme > $output_subgraph.annotated.gfa
    
        ;;

    ga_vg)
        #module load GraphAligner
        #module load blast+/2.10.0
        #module load Bandage
        #module load gfatools

        node_distance=$8

        echo "[EML]: GrahAligner Variation Graphs on $input_file.gfa"
        GraphAligner GraphAligner -t $threads -g $input_file.gfa -f $region -a $output_folder/${input_name}_region.gaf -x vg --precise-clipping 0.95
        python3 $home/scripts/python/nodes_manipulation.py palignment -i $output_folder/${input_name}_region.gaf -l 'region' > $output_folder/${input_name}.region_nodes.tsv

        echo '[EML]: getting subgraph nodes.'
        sel_nodes=$(python3 $home/scripts/python/nodes_manipulation.py pnodes -i $output_folder/${input_name}.region_nodes.tsv)
        if [ ! -f $output_subgraph.vg.gfa ]
            then
            echo '[EML]: getting subgraph.'
            echo "Bandage reduce  $input_file.gfa $output_subgraph.vg.gfa --scope aroundnodes --nodes $sel_nodes --distance $node_distance"
	    Bandage reduce  $input_file.gfa $output_subgraph.vg.gfa --scope aroundnodes --nodes $sel_nodes --distance $node_distance
        fi
        while IFS= read -r locus; do
            temp_name="$input_name$locus"

            echo "[EML]: Aligning ${locus}."
            GraphAligner GraphAligner -t $threads -g $output_subgraph.vg.gfa -f $query/$locus.fa -a $output_folder/${temp_name}.gaf -x vg --precise-clipping 0.98
            python3 $home/scripts/python/nodes_manipulation.py palignment -i $output_folder/${temp_name}.gaf -l $locus >> $output_folder/${input_name}.loci_nodes.tsv
        done < $loci_list
        
        echo '[EML]: annotating subgraph.'
        python3 $home/scripts/python/nodes_manipulation.py colour -i $output_subgraph.vg.gfa -l $output_folder/${input_name}.loci_nodes.tsv -c $colour_scheme > $output_subgraph.vg.annotated.gfa

        ;;

    *)  echo "USAGE"
        echo "sh extract_multiple_loci.sh dbg your_dbg(no_extension) loci_list.txt <threads> output_folder colour_scheme_for_loci.tsv region_to_extract.fa <node_distance> <bifrost/mdbg>"
        echo "sh extract_multiple_loci.sh mini your_minigraph_vg(no_extension) loci_list.txt <threads> output_folder colour_scheme_for_loci.tsv region_to_extract.fa <node_distance>"
        echo "sh extract_subgraph.sh pggb pggb_graph(no_extension) loci_list.txt <threads> output_folder colour_scheme_for_loci.tsv region_to_extract.fa input_file_given_to_pggb.fa <additional_graph_length_in_bases(-c -L of odgi extract)>"
        ;;
esac

echo -e "-------------\n\n\n"
