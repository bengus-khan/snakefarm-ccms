#!/usr/bin/env python3

# README
# This script manages PNG optimization for the techdocs system.
# It monitors the PNG unprocessed directory for file changes and uses optipng to optimize PNG filesize, creating an optimized version of each uploaded PNG in the optimized directory.
# The script also maintains the optimized directory, ensuring file name changes, file deletions/removals, and file overwrites in the unprocessed directory are reflected in the optimized directory.
# Setting this script up as a service on the techdocs server makes it possible for authors to upload unoptimized PNGs for use in documents and seamlessly use optimized versions in rendered documents, cutting down on file size.



'''

GENERAL DEV NOTES
- Explore possibility of adding --nobanner argument to wall command in WallHandler object. Haven't implemented yet because this requires use of sudo privileges, which generally should be avoided when writing scripts.
- Evaluate script for error handling needs - both for script execution and for optipng errors. Need to set up warning/error log messages when error states arise.
- File 'optipng-bot.service' is not added to /etc/systemd/system/ yet - test script and ensure necessary permissions are set before adding service.
- Play around with optimization settings for optipng. See how much file size reduction you can accomplish without hurting overall CPU responsiveness or optimization speed.

SERVICE/CLI DEV NOTES
- Implement basic IPC between background event handling and CLI-invoked reinitialization using D-Bus
    - Modify event handler class
        - Move 'reinit' method from CLI class to event handler class
        - Register handler as a D-Bus service
        - Expose 'reinit' method so CLI user can call it over D-Bus
        - Send D-Bus signals back to CLI at various stages of task progression to enable direct console stream
            - May require tweaks to logger handlers
    - Modify CLI class
        - CLI should send method calls to event handler class via D-Bus, rather than executing file system actions directly
        - Potentially add verbosity argument to influence verbosity of wall_handler and console_handler
        - Ensure --help argument is supported

'''



# MODULE IMPORTS

import argparse
import logging
import os
import subprocess
import threading
import time
from datetime import time as datetime_time
from logging.handlers import TimedRotatingFileHandler
from watchdog.events import FileSystemEventHandler
from watchdog.observers import Observer



# GLOBAL THREADING SETUP

# create lock to control mutual exclusivity between CLI and background service
processing_lock = threading.Lock()

# create semaphore to limit number of concurrent optipng subprocesses
max_concurrent_tasks = 1
semaphore = threading.Semaphore(max_concurrent_tasks)

# track active optimizations and deferred event handling (only for use with events occurring during normal background operation)
active_bg_optimizations = {
    "file_in_progress": "",
    "deferred_file_delete": "",
    "deferred_file_rename": ""
}
active_bg_optimizations_lock = threading.Lock()

# track file system events that occur in unprocessed_dir while reinitialization is in progress
reinit_deferred_events = queue.Queue() # four event types can be put in the queue: 'new', 'modified', 'renamed', and 'removed'



# DIRECTORY & FILE PATH DEFINITIONS

# input ("unprocessed") and output ("optimized") directories
unprocessed_dir = ""
optimized_dir = ""

# log file path
log_file_path = ""

# ensure optimized directory exists
os.makedirs(optimized_dir, exist_ok=True)



# LOGGING

class WallHandler(logging.Handler):
    def emit(self,record):
        # get the log message
        message = self.format(record)
        # broadcast the message to all logged-in users using "wall" command
        subprocess.run(["wall", message])

def create_handlers():
    console_handler = logging.StreamHandler()
    wall_handler = WallHandler()
    log_file_handler = TimedRotatingFileHandler(
        filename=log_file_path,
        when="W0",                      # rotate on sunday
        interval=1,                     # every 1 week
        backupCount=2,                  # keeping logs for the last 2 weeks
        atTime=datetime_time(2,0)       # and handling the rotation at 2am
    )
    return console_handler, wall_handler, log_file_handler

def create_formatters():
    console_formatter = logging.Formatter("OptiPNG Bot | %(levelname)s - %(message)s") # added prefix for console messages to provide context so 'wall' broadcasts don't confuse users
    file_formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
    return console_formatter, file_formatter

def assign_formatters(console_handler, wall_handler, log_file_handler, console_formatter, file_formatter):
    console_handler.setFormatter(console_formatter)
    wall_handler.setFormatter(console_formatter)
    log_file_handler.setFormatter(file_formatter)

def assign_levels(console_handler, wall_handler, log_file_handler):
    console_handler.setLevel(logging.INFO)
    wall_handler.setLevel(logging.INFO)
    log_file_handler.setLevel(logging.DEBUG)

# create main logger and assign level & handlers
def create_main_logger(console_handler, wall_handler, log_file_handler):
    main_logger = logging.getLogger("main_logger")
    main_logger.setLevel(logging.INFO)
    main_logger.addHandler(console_handler)
    main_logger.addHandler(wall_handler)
    main_logger.addHandler(log_file_handler)
    return main_logger

# create cli logger and assign level & handlers
def create_cli_logger(console_handler, log_file_handler):
    cli_logger = logging.getLogger("cli_logger")
    cli_logger.setLevel(logging.INFO)
    cli_logger.addHandler(console_handler)
    cli_logger.addHandler(log_file_handler)
    return cli_logger

# call logging functions
console_handler, wall_handler, log_file_handler = create_handlers()
console_formatter, file_formatter = create_formatters()
assign_formatters(console_handler, wall_handler, log_file_handler, console_formatter, file_formatter)
assign_levels(console_handler, wall_handler, log_file_handler)
main_logger = create_main_logger(console_handler, wall_handler, log_file_handler)
cli_logger = create_cli_logger(console_handler, log_file_handler)



# CLI CLASS

class OptipngCLI:

    # pass optipng_executor instance to CLI class and set up cliparser stuff...?
    def __init__(self, optipng_executor):
        self.optipng_executor = optipng_executor
        self.cliparser = argparse.ArgumentParser(description="OptiPNG Bot CLI")
        self.cliparser.add_argument("-r", "--reinitialize", action="store_true", help=f"delete all .png files in {optimized_dir}, then re-process all .png files in {unprocessed_dir}")
        self.cliargs = self.cliparser.parse_args()

    # handle commands from terminal
    def handle_cli(self):
        if self.cliargs.reinitialize:
            cli_logger.info(f"OptiPNG Bot reinitializing")
            self.reinit()

    # processing for 'reinitialize' argument
    def reinit(self):
        # this method (and the OptipngCLI class in general) needs a lot of work in order to prevent conflicts between background functionality and CLI functionality - see CLI DEV NOTES at top of file

        if processing_lock.acquire(blocking=False):
            try:
                # abort operation if there are any values in active_bg_optimizations, indicating deferred bg processing that has not yet begun
                if any(value for value in active_bg_optimizations.values()):
                    cli_logger.error("Background service is actively processing file system events. Reattempt when processing is complete.")
                    return

                # broadcast message to all logged-in users announcing start and end of reinitialize operation
                main_logger.warning(f"Reinitializing {optimized_dir}...")

                # delete all .png files in optimized directory
                for file_name in os.listdir(optimized_dir):
                    if file_name.endswith(".png"):
                        file_path = os.path.join(optimized_dir, file_name)
                        os.remove(file_path)
                        cli_logger.info(f"Deleted: {file_path}")

                # reprocess all .png files in the unprocessed directory
                for file_name in os.listdir(unprocessed_dir):
                    if file_name.endswith(".png"):
                        file_path = os.path.join(unprocessed_dir, file_name)
                        self.optipng_executor.optimize(file_path)
                        cli_logger.info(f"{file_path} successfully reprocessed")
                main_logger.info(f"Reinitialization of {optimized_dir} complete.")

                # deferred processing for file system events that occur during reinitialization
                while not reinit_deferred_events.empty():
                    event = reinit_deferred_events.get()

                    # check number of data fields in event
                    if len(event) == 2:
                        event_type, src_path = event
                    elif len(event) == 3:
                        event_type, src_path, dest_path = event

                    # execute deferred processing
                    if event_type == 'new':
                        main_logger.info(f"Handling deferred optimization for new file: {src_path}")
                        self.optipng_executor.optimize(src_path)
                    
                    elif event_type == 'modified':
                        main_logger.info(f"Handling deferred optimization for modified file: {src_path}")
                        self.optipng_executor.optimize(src_path)

                    elif event_type == 'deleted':
                        main_logger.info(f"Handling deferred deletion of file: {src_path}")
                        os.remove(src_path)
                        main_logger.info(f"Deleted: {src_path}")
                    
                    elif event_type == 'renamed':
                        main_logger.info(f"Handling deferred renaming of file: {src_path}")
                        os.rename(src_path, dest_path)
                        main_logger.info(f"Renamed: {src_path} -> {dest_path}")

            # if lock is acquired, always release lock after attempting reinitialization
            finally:
                processing_lock.release()

        else:
            cli_logger.error("Background service is actively processing file system events. Reattempt when processing is complete.")



# OPTIPNG EXECUTION CLASS

class OptipngExecutor:

    # task queue counter
    tasks_waiting = 0
    tasks_waiting_lock = threading.Lock()

    # initialize class instance with necessary dependencies
    def __init__(self, semaphore, active_bg_optimizations_lock, optimized_dir):
        self.semaphore = semaphore
        self.active_bg_optimizations_lock = active_bg_optimizations_lock
        self.optimized_dir = optimized_dir

    # method to optimize PNG files and execute deferred event handling
    def optimize(self, file_path):
        if file_path.endswith(".png"):
            file_name = os.path.basename(file_path) # base name = filename with extension
            optimized_file = os.path.join(self.optimized_dir, file_name)

            # increment tasks_waiting when a task starts
            with self.tasks_waiting_lock:
                tasks_waiting += 1
                main_logger.info(f"Tasks to complete: {tasks_waiting}")

            # mark the file as being actively optimized
            with active_bg_optimizations_lock:
                active_bg_optimizations['file_in_progress'] = file_path

            # main optimization process, using semaphore to limit number of active optipng processes
            with semaphore:
                main_logger.info(f"Optimizing {file_path}")
                # decrement tasks_waiting once the semaphore is acquired
                with self.tasks_waiting_lock:
                    tasks_waiting -= 1

                # check optimized directory for filename conflicts and delete conflicting file if it exists
                if os.path.exists(optimized_file):
                    os.remove(optimized_file)
                    main_logger.info(f"{optimized_file} already existed and was deleted to prevent conflicts.")

                # run optipng - add ["nice", "-n", "10",...] to beginning of subprocess command to reduce CPU priority
                subprocess.run(["optipng", "-o4", file_path, "-out", optimized_file]) # set "-oX" to "-o7" and add "-zm1-9" option immediately after to maximize compression at the significant cost of speed

            # log "optimization successful" message
            main_logger.info(f"Optimized: {file_path} -> {optimized_file}")

            # handle active optimizations tracker and deferred processing for on_move and on_delete
            with active_bg_optimizations_lock:

                # remove the original file from active optimizations
                active_bg_optimizations['file_in_progress'] = ""

                # rename the file if deferred rename applies
                if active_bg_optimizations['deferred_file_rename'] != "":
                    os.rename(optimized_file, active_bg_optimizations['deferred_file_rename'])
                    main_logger.info(f"Renamed: {optimized_file} -> {active_bg_optimizations['deferred_file_rename']}")
                    active_bg_optimizations['deferred_file_rename'] = ""

                # delete the file if deferred delete applies
                if active_bg_optimizations['deferred_file_delete'] != "":
                    os.remove(active_bg_optimizations['deferred_file_delete'])
                    main_logger.info(f"Deleted: {active_bg_optimizations['deferred_file_delete']}")
                    active_bg_optimizations['deferred_file_delete'] = ""

            # log and broadcast remaining number of files in queue for optipng semaphore
            main_logger.info(f"Tasks in queue: {tasks_waiting}")



# BACKGROUND FILE SYSTEM EVENT HANDLER CLASS

class BackgroundEventHandler(FileSystemEventHandler):

    # pass the OptipngExecutor instance to this handler class
    def __init__(self, optipng_executor):
        self.optipng_executor = optipng_executor

    # method for file creation events
    def on_created(self, event):
        if event.src_path.endswith(".png"):
            main_logger.info(f"PNG file created: {event.src_path}")

            # acquire processing lock w/o blocking
            if processing_lock.acquire(blocking=False):
                # process event if lock is successfully acquired
                self.optipng_executor.optimize(event.src_path)
                processing_lock.release()

            # if lock is occupied by CLI
            else:
                # add event to queue
                reinit_deferred_events.put(('new', event.src_path))
                main_logger.info(f"Reinitialization in progress. File system event processing deferred: {event.src_path} (new)")

    # method for file modification events
    def on_modified(self, event):
        if event.src_path.endswith(".png"):

            # acquire processing lock w/o blocking
            if processing_lock.acquire(blocking=False):
                # process event if lock is successfully acquired
                self.optipng_executor.optimize(event.src_path)
                processing_lock.release()

            # if lock is occupied by CLI
            else:
                # add event to queue
                reinit_deferred_events.put(('modified', event.src_path))
                main_logger.info(f"Reinitialization in progress. File system event processing deferred: {event.src_path} (modified)")

    # method for file moving/renaming events
    def on_moved(self, event):
        if event.src_path.endswith(".png"):
            unproc_file_name_orig = os.path.basename(event.src_path) # get the original base name of the unprocessed file
            unproc_file_name_new = os.path.basename(event.dest_path) # get the new base name of the unprocessed file
            optimized_file_orig = os.path.join(optimized_dir, unproc_file_name_orig)
            optimized_file_new = os.path.join(optimized_dir, unproc_file_name_new)

            # acquire processing lock w/o blocking
            if processing_lock.acquire(blocking=False):

                # check if the original file is already actively being processed
                with active_bg_optimizations_lock:

                    # if the original file is being processed; defer action
                    if active_bg_optimizations['file_in_progress'] == event.src_path:

                        # if the original file was renamed, defer renaming of optimized file
                        if unprocessed_dir in event.src_path and unprocessed_dir in event.dest_path:
                            main_logger.info(f"File {optimized_file_orig} is being generated by optipng. Deferring renaming until optipng processing is complete.")
                            active_bg_optimizations['deferred_file_rename'] = optimized_file_new

                        # if the original file was moved out of the unprocessed directory, defer deletion of optimized file
                        elif unprocessed_dir in event.src_path and not unprocessed_dir in event.dest_path:
                            main_logger.info(f"File {optimized_file_orig} is being generated by optipng. Deferring deletion until optipng processing is complete.")
                            active_bg_optimizations['deferred_file_delete'] = optimized_file_orig
                        return

                # if original file is not actively being processed:

                # if file was moved within unprocessed directory (aka renamed), rename the optimized version. if for some reason an optimized version doesn't already exist, create one with the new file name
                if unprocessed_dir in event.src_path and unprocessed_dir in event.dest_path:
                    if os.path.exists(optimized_file_orig):
                        os.rename(optimized_file_orig, optimized_file_new)
                        main_logger.info(f"Renamed: {optimized_file_orig} -> {optimized_file_new}")
                    else:
                        self.optipng_executor.optimize(event.dest_path)

                # if file was moved from unprocessed directory to some other directory, delete the optimized version
                elif unprocessed_dir in event.src_path and not unprocessed_dir in event.dest_path:
                    if os.path.exists(optimized_file_orig):
                        os.remove(optimized_file_orig)
                        main_logger.info(f"Deleted: {optimized_file_orig}")

                # if file was moved into unprocessed directory from some other location, treat it as a newly created file and optimize it
                elif unprocessed_dir in event.dest_path and not unprocessed_dir in event.src_path:
                    main_logger.info(f"PNG file uploaded to directory: {event.dest_path}")
                    self.optipng_executor.optimize(event.dest_path)

            # if lock is occupied by CLI
            else:
                # if file was moved within unprocessed directory, add event to queue as 'renamed'
                if unprocessed_dir in event.src_path and unprocessed_dir in event.dest_path:
                    reinit_deferred_events.put(('renamed', optimized_file_orig, optimized_file_new))
                    main_logger.info(f"Reinitialization in progress. File system event processing deferred: {event.src_path} (renamed)")
                # if file was moved from unprocessed directory to some other directory, add event to queue as 'deleted'
                elif unprocessed_dir in event.src_path and not unprocessed_dir in event.dest_path:
                    reinit_deferred_events.put(('deleted', event.dest_path))
                    main_logger.info(f"Reinitialization in progress. File system event processing deferred: {event.src_path} (deleted)")
                # if file was moved into unprocessed directory from some other location, add event to queue as 'new'
                elif unprocessed_dir in event.dest_path and not unprocessed_dir in event.src_path:
                    reinit_deferred_events.put(('new', optimized_file_orig))
                    main_logger.info(f"Reinitialization in progress. File system event processing deferred: {event.src_path} (new)")



    # method for file deletion events
    def on_deleted(self, event):
        if event.src_path.endswith(".png"):
            file_name = os.path.basename(event.src_path)
            optimized_file = os.path.join(optimized_dir, file_name)
            
            # acquire processing lock w/o blocking
            if processing_lock.acquire(blocking=False):

                # check if the original file is actively being processed
                with active_bg_optimizations_lock:
                    if active_bg_optimizations['file_in_progress'] == event.src_path:
                        # the original file is being processed; defer deletion
                        main_logger.info(f"File {event.src_path} is being processed. Deferring deletion until processing is complete.")
                        active_bg_optimizations['deferred_file_delete'] = optimized_file
                        return
                
                # if original file is already processed, simply delete the processed file
                if os.path.exists(optimized_file):
                    os.remove(optimized_file)
                    main_logger.info(f"Deleted: {optimized_file}")

            # if lock is occupied by CLI
            else:
                reinit_deferred_events.put(('deleted', optimized_file))
                main_logger.info(f"Reinitialization in progress. File system event processing deferred: {event.src_path} (deleted)")




# MAIN BLOCK TO RUN THE SCRIPT

if __name__ == "__main__":
    # create an instance of OptipngExecutor
    optipng_executor = OptipngExecutor(semaphore, active_bg_optimizations_lock, optimized_dir)
    # create an instance of BackgroundEventHandler
    event_handler = BackgroundEventHandler(optipng_executor)
    # create an instance of watchdog observer
    observer = Observer()
    # schedule the observer to monitor the directory and use optipngHandler for events
    observer.schedule(event_handler, path=unprocessed_dir, recursive=False)
    # start the observer
    observer.start()
    # log a message indicating the directory is being monitored
    main_logger.info(f"Monitoring directory: {unprocessed_dir}")

    try:
        # keep the script running indefinitely
        while True:
            # sleep for 1 second in each iteration
            time.sleep(1)
    except KeyboardInterrupt:
        # stop the observer if the script is interrupted with Ctrl+C
        main_logger.info(f"Stopping OptiPNG Bot process...")
        observer.stop()
    
    # wait for observer thread to finish before stopping
    observer.join()
    main_logger.info(f"OptiPNG Bot process stopped.")
