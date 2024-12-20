#!/usr/local/bin/python3

'''
DEV NOTES:
-----------------------------------------------------------
- FOP config file needs to include all user fonts (along w/ stock fonts) - need to put this in user's system config instead of document config
- Might need to create XSLT stylesheets for DocBook <--> XLIFF transformations - unsure if DocBookXSL has support for XLIFF format

'''

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
doc_config_file = None
fop_config_file = None

class DocumentPublisher:
    print('placeholder')

class DocBookProfiler:
    def __init__(self, doc_config_file):
        if not os.path.exists(doc_config_file):
            print(f'Document configuration file {doc_config_file} does not exist.') # placeholder for error log message
            return
        with open(doc_config_file, 'r') as dc_file:
            self.doc_config = yaml.safe_load(dc_file)
        self.image_root = self.doc_config['image_root']
        self.docbook_profiler_semaphore = threading.Semaphore(1)

class DocBookConverter:
    # FUNCTIONS TO CREATE:
    #   DocBook to XSL-FO
    #   DocBook to HTML, chunked
    #   DocBook to HTML, single page
    #   DocBook to XLIFF - may require custom XSLT
    #   XLIFF to DocBook - may require custom XSLT
    #   DocBook to XHTML
    #   DocBook to EPUB
    #   DocBook to EPUB3

    def __init__(self, doc_config_file):
        if not os.path.exists(doc_config_file):
            print(f'Document configuration file {doc_config_file} does not exist.') # placeholder for error log message
            return
        with open(doc_config_file, 'r') as dc_file:
            self.doc_config = yaml.safe_load(dc_file)
        self.image_root = self.doc_config['image_root']
        self.docbook_converter_semaphore = threading.Semaphore(1)

class FopRunner:
    def __init__(self, doc_config_file, fop_config_file):
        if not os.path.exists(doc_config_file):
            print(f'Document configuration file {doc_config_file} does not exist.') # placeholder for error log message
            return
        if not os.path.exists(fop_config_file):
            print(f'FOP configuration file {doc_config_file} does not exist.') # placeholder for error log message
            return
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
            print(f'XSL-FO file {self.fo_file} does not exist.') # placeholder for error log message
            return
        if self.output_selected_pdf == True:
            with self.fop_runner_semaphore:
                pdf_filename = self.doc_config['output_filename'] + '.pdf'
                subprocess.run(['fop', self.fo_file, '-c', self.fop_config, '-pdf', pdf_filename], check=True)

    def XslFoToPostScript(self):
        if not os.path.exists(self.fo_file):
            print(f'XSL-FO file {self.fo_file} does not exist.') # placeholder for error log message
            return
        if self.output_selected_postscript == True:
            with self.fop_runner_semaphore:
                postscript_filename = self.doc_config['output_filename'] + '.ps'
                subprocess.run(['fop', self.fo_file, '-c', self.fop_config, '-ps', postscript_filename], check=True)
