# ReportSendex
Library to Email Reports in Salesforce Asychronously. Can be used from internal apex classes, scheduled jobs, and even called from communities & lightning controllers.


## Installation
Copy and Paste these into new files called ReportSendex.cls and ReportSendexTest.cls

## How To Use
Pass parameters to the below queued method call.

**filtersByReportId** - filters must be in the order displayed in the Salesforce Report UI
**email** - pass in your email object with recipients, subject, and body set [SF Docs](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_email_outbound_single.htm) this class will set the attachments and send the email.
**fileType** - 'csv' or 'xls'. cvs reports are sent without groupings, just raw data rows

```
System.enqueueJob(new ReportSendex(Map<Id, List<String>> filtersByReportId, Messaging.SingleEmailMessage email, String fileType));
```
