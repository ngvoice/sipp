SIPP-Scenarios for IMS
=========================

This repository contains some basic [SIPP](http://sipp.sourceforge.net/) Scenarios for testing various IMS-Features.

Contents
==========

The tests consists of two parts: A scripts/utilities:
* create_users.sh - a shell script for creating the according IMPI's, IMPU's and stuff in the HSS-Database (the database is vendor specific) as well as the include files for SIPP (which are needed to run the scenarios)

The script needs two parameters:
	* the number of accounts to create (defaults to 500.000)
	* the IMS-Domain to use
	* ./create_users.sh 10 imscore.org

As a result, you get two files:
* clients.csv - the input file for SIPP
* create.sql - a SQL-Script to create database entries for those users (e.g. for Fraunhofer's HSS)

and some scenorios (more to follow):
* register.xml - the simplest scenario: Just register a UA
* register-unregister.xml - almost as simple: Register and unregister
* register-reginfo-unregister.xml - Register a client, subscribe for Reginfo/XML, wait for NOTIFY, Unregister

Compiling SIPP
=======================
(see http://sipp.sourceforge.net/doc/reference.html#Installing+SIPp)

Running the scenarios
=======================
./sipp <ip-of-pcscf> -sf ./register-unregister.xml -inf ./clients.csv -default_behaviors none -nd
