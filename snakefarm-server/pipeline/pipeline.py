#!/usr/local/bin/python3

# DEV NOTES:
# ---------------------------------------------------------
# - FOP config file needs to include all user fonts (along w/ stock fonts) - need to put this in user's system config instead of document config

# Obviously a ton of unused imports below - just putting all the potentially required imports here for now. Will remove unused imports once code is more complete and I have a better understanding of what's needed.

import argparse
import configparser
import flask_cors
import flask_migrate
import flask_socketio
import json
import logging
import os
import pathlib
import platform
import queue
import shutil
import subprocess
import threading
import yaml

# These are the main endpoints needed to begin processing - other required files are defined within config files. Setting up as global variables for now, may change this later.
# NOT defining fop_config_file in document_config.json or document_config.yaml, since this should be a global setting for the application.
doc_config_file = 'document_config.yaml'
fop_config_file = 'fop_config.xml'

# idk where to put this logic yet
if not os.path.exists(doc_config_file):
    print(f'Document config file {doc_config_file} not found.')

class DocBuilder:
    print('placeholder')

class XsltProcRunner:
    def __init__(self, doc_config_file):
        with open(doc_config_file, 'r') as dc_file:
            self.doc_config = yaml.safe_load(dc_file)
        self.image_root = self.doc_config['image_root']
        self.xsltproc_runner_semaphore = threading.Semaphore(3)

class FopRunner:
    def __init__(self, doc_config_file, fop_config_file):
        self.fop_config = fop_config_file
        with open(doc_config_file, 'r') as dc_file:
            self.doc_config = yaml.safe_load(dc_file)
        self.fo_file = self.doc_config['output_filename'] + '.fo'
        self.image_root = self.doc_config['image_root']
        self.output_selected_pdf = self.doc_config['output_format']['pdf']['selected']
        self.output_selected_postscript = self.doc_config['output_format']['postscript']['selected']
        self.fop_runner_semaphore = threading.Semaphore(1)

    def XslFoToPdf(self):
        if not os.path.exists(self.fo_file):
            print('XSL-FO file does not exist.') # placeholder for error log message
            return
        if self.output_selected_pdf == True:
            with self.fop_runner_semaphore:
                pdf_filename = self.doc_config['output_filename'] + '.pdf'
                subprocess.run(['fop', self.fo_file, '-c', self.fop_config, '-pdf', pdf_filename], check=True)

    def XslFoToPostScript(self):
        if not os.path.exists(self.fo_file):
            print('XSL-FO file does not exist.') # placeholder for error log message
            return
        if self.output_selected_postscript == True:
            with self.fop_runner_semaphore:
                postscript_filename = self.doc_config['output_filename'] + '.ps'
                subprocess.run(['fop', self.fo_file, '-c', self.fop_config, '-ps', postscript_filename], check=True)
