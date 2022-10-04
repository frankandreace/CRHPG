#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on May 2 2022

@author: francescoandreace
"""

from sys import argv

def annotateGfa(fileName,toaugm):
    with open(fileName) as f:
     for line in f:
        if line[0] == "S":
            el = line.split("\t")
            if toaugm.get(el[1]) != None:
                print(line[:-1]+'\tCL:z:#aa0000\tC2:z:#aa0000\n',end='')
            else:
                print(line,end='')
        else:
            print(line,end='') 
    return 

if __name__ == '__main__':
    gfa = argv[1]
    nodelist=argv[2].strip().split(',')
    nodedict={}
    for el in nodelist:
        nodedict[el] = True

    annotateGfa(gfa,nodedict)


    