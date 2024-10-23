#!/usr/local/bin/python3

import argparse
import configparser
import json
import logging
import os
import queue
import subprocess
import threading

class FopRunner:

    def init(self): # Define endpoints
        self.document_config_file = None
        self.fop_config_file = None # FOP config file needs to include all user fonts (along with stock fonts) - need to put this in user's system config instead of document config

    def DocumentConfigParse(self): # syntax within variable defs is probably wrong - fix this soon
        self.config = json.load(self.document_config_file)
        self.fo_file = self.config.output_filename + ".fo"
        self.images_source = self.config.images_source
        self.output_formats = {"pdf": self.config.pdf, "postscript": self.config.postscript}

    def XslFoToPdf(self):
        if self.output_formats["pdf"]:
            self.pdf_filename = self.config.output_filename + ".pdf"
            try: subprocess.run("fop", [self.fo_file], [self.pdf_filename], "pdf") # Run fop --help to confirm correct arguments
            except: print("XSL-FO to PDF transformation unsuccessful.") # Placeholder for logger
    
    def XslFoToPostScript(self):
        if self.output_formats["postscript"]:
            self.postscript_filename = self.config.output_filename + ".ps"
            try: subprocess.run("fop", [self.fo_file], [self.postscript_filename], "postscript") # run fop --help to confirm correct arguments
            except: print("XSL-FO to PostScript transformation unsuccessful.") # Placeholder for logger
    
    def RunFop(self, XslFoToPdf, XslFoToPostScript): # Idk if I should have this here
        XslFoToPdf(self)
        XslFoToPostScript(self)
