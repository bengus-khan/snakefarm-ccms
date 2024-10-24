#!/usr/local/bin/python3

# DEV NOTES:
# ---------------------------------------------------------
# - Run fop --help to confirm correct arguments
# - FOP config file needs to include all user fonts (along w/ stock fonts) - need to put this in user's system config instead of document config

import argparse
import configparser
import json
import logging
import os
import queue
import subprocess
import threading
import yaml

class FopRunner:

    def __init__(self): # Define endpoints
        # may change these values to arguments instead of nulls... gotta figure out how this works in context of the larger automation
        self.document_config_file = None
        self.fop_config_file = None

    def DocumentConfigParse(self):
        if not os.path.exists(self.document_config_file):
            print(f'Document config file {self.document_config_file} not found.')
            return
        with open(self.document_config_file, 'r') as doc_conf:
            self.config = json.load(doc_conf)
        self.fo_file = self.config['output_filename'] + '.fo'
        self.image_root = self.config['image_root']
        self.output_selected_pdf = self.config['output_format']['pdf']['selected']
        self.output_selected_postscript = self.config['output_format']['postscript']['selected']

    def XslFoToPdf(self):
        if self.output_selected_pdf == True:
            self.pdf_filename = self.config['output_filename'] + '.pdf'
            try: subprocess.run(['fop', self.fo_file, self.pdf_filename, 'pdf'])
            except: print('XSL-FO to PDF transformation unsuccessful.') # Placeholder for logger

    def XslFoToPostScript(self):
        if self.output_selected_postscript == True:
            self.postscript_filename = self.config['output_filename'] + '.ps'
            try: subprocess.run(['fop', self.fo_file, self.postscript_filename, 'postscript'])
            except: print('XSL-FO to PostScript transformation unsuccessful.') # Placeholder for logger
