#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 21/12/2021

@author: francescoandreace


Accept a GAF/PAF file from minimap2/minigraph mapping and outputs the mapped nodes.
1st argument is the file, second the treshold of the minimum ratio between the mapped section and the length of the node 
to output the node or not. For Bifrost or stuff like that is better to give high thresholds (eg 0.9)
Doesn't need 2nd argument for gaf files
"""

from sys import argv
from sys import stderr
import argparse

def get_pos(str):
    counter=0
    start=-1
    end=-1
    for chr in str:
        if chr.isnumeric() and start<0:
            start=counter
        if not chr.isnumeric() and start>0:
            end=counter
        counter+=1
    if end<0:
        end=len(str)
    return start,end

def print_nodes(extracted_nodes):
    out_nodes=""
    for node in extracted_nodes:
        if node != "*":
            out_nodes+=node+","
    print(out_nodes[:-1])

def getnodes_gaf(filen):
    
    nodes = set()
    for line in filen:
        seq=line.split('\t')[5]
        el=""
        for c in seq[1:]:
            if c == ">" or c == "<":
                nodes.add(el)
                el = ""
            else:
                el+=c
        nodes.add(el)
    
    if len(nodes) > 0:
        starting_pos,ending_pos = get_pos(list(nodes)[0])
        return sorted(nodes,key=lambda x : int(x[starting_pos:ending_pos]))
        
    return None

def getnodes_paf(filen, threshold):
    nodes = set()

    for line in filen:
        if line[0] != "@":
            nl = line.split("\t")

            if int(nl[9])/int(nl[1]) > threshold:
                nodes.add(nl[0])
    if len(nodes) > 0:
        starting_pos,ending_pos = get_pos(list(nodes)[0])
        return sorted(nodes,key=lambda x : int(x[starting_pos:ending_pos]))
        
    return None

def getnodes_tsv(filen):
    nodes = set()

    for line in filen:
        node_line=line.split('\t')[1].split(',')

        for node in node_line:
            nodes.add(node)
    
    if len(nodes) > 0:
        starting_pos,ending_pos = get_pos(list(nodes)[0])
        return sorted(nodes,key=lambda x : int(x[starting_pos:ending_pos]))
        
    return None


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='File manipulation for loci analysis')
    subparser = parser.add_subparsers(dest='command')
    parseAlignment = subparser.add_parser('palignment')
    parseNodes = subparser.add_parser('pnodes')
    colour = subparser.add_parser('colour')
    bedfile = subparser.add_parser('bed')

    parseAlignment.add_argument('--input', '-i', type=str, dest='alignment_file', required=True, help='Alignment file [paf or gaf]')
    parseAlignment.add_argument('--threshold', '-t', type=str, dest='threshold', required=False, help='Treshold for alignment ratio in paf files [float]')
    parseAlignment.add_argument('--locus', '-l', type=str, dest='locus_name', required=False, help='locus name')

    parseNodes.add_argument('--input', '-i', type=str, dest='nodes_file', required=True, help='Nodes related to locus file [tsv]')

    colour.add_argument('--graph', '-i', type=str, dest='graph_file', required=True, help='Graph file [gfa]')
    colour.add_argument('--labels', '-l', type=str, dest='nodes_file', required=True, help='Nodes related to locus file [tsv]')
    colour.add_argument('--colours', '-c', type=str, dest='colour_scheme', required=True, help='File with hexadecimals of colours you want to assign to the loci. For every line use a locus and a colour. [csv]')

    bedfile.add_argument('--input', '-i', type=str, dest='alignment_file', required=True, help='minimap2 alignemnt file [paf]')

    args = parser.parse_args()
    #print(args)

    if args.command == 'palignment':
        with open(args.alignment_file, newline='') as f:
            newfile=f.read().splitlines()

        if 'gaf' in args.alignment_file:
            extracted_nodes = getnodes_gaf(newfile)
        elif 'paf' in args.alignment_file:
            threshold = args.threshold
            extracted_nodes = getnodes_paf(newfile, threshold)
        
        if extracted_nodes is not None:
            if args.locus_name is not None:
                name=str(args.locus_name)
                print(name,end="\t")
            
            print_nodes(extracted_nodes)
    
    elif args.command == 'pnodes':
        with open(args.nodes_file, newline='') as f:
            newfile=f.read().splitlines()
        extracted_nodes = getnodes_tsv(newfile)

        if extracted_nodes is not None:
            print_nodes(extracted_nodes)

    elif args.command == 'colour':
        with open(args.colour_scheme, newline='') as f:
            colours_line=f.read().splitlines()
            loc_col_dic = {}
            for line in colours_line:
                loc,col = line.split(',')
                loc_col_dic[loc] = col

        with open(args.nodes_file, newline='') as f:
            nodes_file=f.read().splitlines()

        nodes_col_dic = {}
        
        counter = 0
        for line in nodes_file:
            locus, nodelist = line.split('\t')
            if loc_col_dic.get(locus) != None:
                nodes = nodelist.split(',')

                for node in nodes:
                    nodes_col_dic[node] = loc_col_dic[locus]


        with open(args.graph_file, newline='') as f:
            for line in f:
                if line[0] == 'S':
                    elements = line.strip('\n').split('\t')
                    node = elements[1]
                    if len(elements) > 3:
                        if nodes_col_dic.get(node) != None:
                            print(elements[0]+'\t'+elements[1]+'\t*\t'+elements[3]+'\tCL:z:'+nodes_col_dic.get(node)+'\n',end='')
                        else:
                            print(elements[0]+'\t'+elements[1]+'\t*\t'+elements[3]+'\n',end='')
                    else:
                        if nodes_col_dic.get(node) != None:
                            print(elements[0]+'\t'+elements[1]+'\t*\t'+'LN:i:'+str(len(elements[2]))+'\tCL:z:'+nodes_col_dic.get(node)+'\n',end='')
                        else:
                            print(elements[0]+'\t'+elements[1]+'\t*\t'+'LN:i:'+str(len(elements[2]))+'\n',end='')
                else:
                    print(line,end='') 

    elif args.command == 'bed':
        ranges = {}

        with open(args.alignment_file, newline='') as f:
            for line in f:
                line = line.split('\t')
                st = int(line[7])
                fn = int(line[8])

                if line[5] not in ranges:
                    ranges[line[5]] = [st,fn]
                else:
                    if fn - st > ranges[line[5]][1]-ranges[line[5]][0]:
                        ranges[line[5]][0] = st
                        ranges[line[5]][1] = fn

                    #if fn < ranges[line[5]][1]:
                    #   ranges[line[5]][1] = fn
                
        for el in ranges:
            out=el+'\t'+str(ranges[el][0])+'\t'+str(ranges[el][1])
            print(out)
