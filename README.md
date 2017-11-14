salesforce-food-bank
====================

Food Bank Manager built on Salesforce using Angular.js

This is a Salesforce.com and AngularJS application that tracks clients and service delivery for food banks.

![Food Bank App Check-in Screen](foodbankmgr.png)

## Intro Video

Here is a 5-minute video introduction: http://youtu.be/vzvGtpBY08E

##Getting Started

#Visual Studio Code Setup: https://github.com/forcedotcom/salesforcedx-vscode 
    Helpful Video: https://github.com/forcedotcom/salesforcedx-vscode/wiki 

#Cumulus CI Setup: https://github.com/SalesforceFoundation/CumulusCI

#Deploy to Scratch Org 
    cci deploy run task

#Open Scratch Org
    sfdx force:org:open

#Salesforce Instance Setup
    Edit System Administrator Profile > Field-Level Security for custom objects Client, Client Household, and Client Visit & give View/Edit permissions on all fields

#Open Food Bank App (FoodBankApp Visualforce Page)
    [instanceURL]/apex/FoodBankApp

##Running and Testing Locally

The Food Bank app has a mock data service that lets you test without connecting to Force.com.
There is an alternate home page, as well as a Jasmine Test Runner page.  For example, on a Mac:

 # Open a Terminal window to the food bank application root and type the following:
     cd resource-bundles/Angular.resource
     python -m SimpleHTTPServer
 # For the home page, open your web browser to: http://localhost:8000/
 # For the test runner, open to: http://localhost:8000/test/TestRunner.html


##Implementation Notes


##To-Do
 * documentation
 * 