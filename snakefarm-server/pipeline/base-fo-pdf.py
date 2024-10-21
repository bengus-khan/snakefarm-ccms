#!/the-right-directory python3

import argparse
import logging
import os
import queue
import subprocess
import threading

# ENDPOINTS:
    # Need to define in document config file:
        # input_file
        # output_filename
        # images_source
    # Global
        # fop_config_file - needs to include all font info

class XslFoToPdf:

     # placeholder function to shut Pylance up
    def transform(self):
        print("hello")