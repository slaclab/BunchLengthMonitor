# How to monitor FPGA reboots and reload configuration values

## Overview

YCPSWASYN uses CPSW for the communication with FPGA and AsynPortDriver for its integration into EPICS.

This document describes one way to detect FPGA reboots and automatically load the configuration values.

## Background

You should be familiar with CPSW and how hierarchies are defined in YAML. 

Go to the CPSW and YAML go to the official [confluence page about CPSW](https://confluence.slac.stanford.edu/display/ppareg/CPSW%3A+HowTo+User+Guide), or take a look at the README files in the CPSW framework package area.


## FPGA reboots

In this system architecture where we have the CPU where the IOC is running and the FPGA in to different chassis, it is possible that the FPGA reboots while the IOC is running. As the configuration values on the FPGA are lost after a reboot, your IOC must check if this happens and load the configuration values again. Without the configuration values loaded, many of the function implemented on the FPGA don't work.

## Detect FPGA reboots

One way to detect FPGA reboots is to take advantage of the volatile register behavior. You can use a general purpose R/W register, write a known values different from zero and constantly check if the register have the same value. If at some point you read back a zero, then you can assume there was due to an FPGA reboot. 

## Load configuration after reboot

Once you have detected an FPGA reboot, you can use the load configuration function describer in README.saveLoadConfig.

In the configuration file you are loading, you should add the register you are monitoring with the known value. This way, after the configuration is loaded, the register already have the value you are expecting.

## Example 

A database example is given as a reference. It it located in <TOP>/ycpswasyn/Db/monitorFPGAReboot.db
