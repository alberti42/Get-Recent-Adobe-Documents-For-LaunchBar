#!/usr/bin/python3
# coding: utf-8
#
# LaunchBar Action Script

import sys
import os.path
import json
import locale

debug = False

if debug:
    example = """
{
    "path" :  "/Volumes/Macintosh HD/Users/andrea/Documents/Physics eBooks/Charles Kittel, Quantum Theory of Solids (2nd ed., John Wiley & Sons, 1987).pdf",
    "title" : "J. Phys. II. 1994 4(1999) Storey-Cohen-Tannoudji.pdf",
    "icon" : "com.adobe.Acrobat.Pro:ACP_Generic",
    "subtitle" : "/Volumes/Macintosh HD/Users/andrea/Documents/Papers library/1994",
    "actionRunsInBackground" : "true",
    "action" : "open_with_acrobat.py"
  }
"""
    if(len(sys.argv)==1):
        sys.argv.append(example);
    else:
        sys.argv[1] = example

if len(sys.argv) == 2:
    item = json.loads(sys.argv[1])
    os.system(f'open -b com.adobe.Acrobat.Pro "{item["path"]}"')
