# How to save and load YAML configuration files

## Overview

YCPSWASYN uses CPSW for the communication with FPGA and AsynPortDriver for its integration into EPICS.

This document describes how to save and load the registers configuration values from YAML files.

## Background

You should be familiar with CPSW and how hierarchies are defined in YAML. 

Go to the CPSW and YAML go to the official [confluence page about CPSW](https://confluence.slac.stanford.edu/display/ppareg/CPSW%3A+HowTo+User+Guide), or take a look at the README files in the CPSW framework package area.


## Asyn parameter

YCPSWASYN uses the following Asyn parameter in order to call the save and load function as well as to give the necessary parameters and :

| Asyn Parameter      | DTYP               | Description            
|:--------------------|:------------------:|:--------------------------------------------------------------------------
| CONFIG_LOAD         | asynInt32          | Start the loading of the configuration
| CONFIG_LOAD_FILE    | asynOctetWrite     | Name of the YAML configuration file to be loaded
| CONFIG_LOAD_STATUS  | asynUInt32Digital  | Status of the loading process (0: Idle, 1: loading, 2: success, 3: error)
| CONFIG_SAVE         | asynInt32          | Start the saving of the configuration
| CONFIG_SAVE_FILE    | asynOctetWrite     | Name of the YAML configuration file to be saved
| CONFIG_SAVE_STATUS  | asynUInt32Digital  | Status of the saving process (0: Idle, 1: saving, 2: success, 3: error)


## EPICS Database

In order to use the provided Asyn parameters, you need to attached then to appropriate records. This is done in the standard way AsynPortDriver does it, that is: use an Asyn device type on the record DTYP field, and define the INP or OUT fields following the AsynPortDriver convention as @asyn(PORT, ADDR, TIMEOUT)ASYN_PARAMETER_NAME or @asynMask(PORT, ADDR, MASK)ASYN_PARAMETER_NAME. You must use the parameter name defined on the previous table.

For this function, you should use ADDR = 6.

### Example

A database example is given as a reference. It it located in <TOP>/ycpswasyn/Db/saveLoadConfig.template
