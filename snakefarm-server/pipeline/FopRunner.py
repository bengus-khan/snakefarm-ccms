#!/usr/local/bin/python3

# DEV NOTES:
# ---------------------------------------------------------
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
        # need to change these values to appropriate arguments instead of nulls... gotta figure out how this works in context of the larger automation
        self.document_config_file = None
        self.fop_config_file = None
        self.fop_runner_semaphore = threading.Semaphore(1)

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
            with self.fop_runner_semaphore:
                self.pdf_filename = self.config['output_filename'] + '.pdf'
                try: subprocess.run(['fop', '-c', self.fop_config_file, self.fo_file, '-pdf', self.pdf_filename])
                except: print('XSL-FO to PDF transformation unsuccessful.') # Placeholder for logger

    def XslFoToPostScript(self):
        if self.output_selected_postscript == True:
            with self.fop_runner_semaphore:
                self.postscript_filename = self.config['output_filename'] + '.ps'
                try: subprocess.run(['fop', '-c', self.fop_config_file, self.fo_file, '-ps', self.postscript_filename])
                except: print('XSL-FO to PostScript transformation unsuccessful.') # Placeholder for logger
