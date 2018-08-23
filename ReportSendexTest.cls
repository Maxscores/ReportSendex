/**
 * Description: test for ReportSendex
 *
 */


@IsTest
private class ReportSendexTest {
    @IsTest (SeeAllData=true)
    static void testCanSendCSVReport() {
        List<Report> reports = [
            Select Id, DeveloperName
            FROM Report
            Limit 5
        ];

        Map<String, List<String>> filtersByReport = new Map<String, List<String>>();
        for (Report report : reports) {
            filtersByReport.put(report.Id, new List<String>{'filter1', 'filter2', 'filter3'});
        }

        List<String> recipients = new List<String>{'test@example.com'};
        Messaging.SingleEmailMessage testEmail = new Messaging.SingleEmailMessage();

        ReportSender sender = new ReportSender(filtersByReport, testEmail, 'csv');

        String reportQuery = sender.getReportQuery(reports[0].id);

        String expectedQuery = '/' + report.Id + '?csv=1' + '&pv0=filter1&pv1=filter2&pv2=filter3';
        System.assertEquals(expectedQuery, reportQuery);

        // test methods do not allow callouts to ApexPages.PageReference, so we have to fake the content
        Blob reportContent = Blob.valueOf('report content!');

        String reportName = 'reportex';

        Messaging.EmailFileAttachment attachment = sender.getReportAttachment(reportContent, reportName);
        String today = Datetime.now().format('MM-dd-YYYY');

        System.assertEquals(reportName + '_' + today + '.csv', attachment.getFileName());
        System.assertEquals('text/csv', attachment.getContentType());

        List<Messaging.EmailFileAttachment> attachments = sender.getAllReportAttachments();

        System.assertEquals(reports.size(), attachments.size());
    }

    @IsTest (SeeAllData=true)
    static void testCanSendExcelReport() {
        List<Report> reports = [
            Select Id, DeveloperName
            FROM Report
            Limit 5
        ];

        Map<String, List<String>> filtersByReport = new Map<String, List<String>>();
        for (Report report : reports) {
            filtersByReport.put(report.Id, new List<String>{'filter1', 'filter2', 'filter3'});
        }

        List<String> recipients = new List<String>{'test@example.com'};
        Messaging.SingleEmailMessage testEmail = new Messaging.SingleEmailMessage();

        ReportSender sender = new ReportSender(filtersByReport, testEmail, 'xls');

        String reportQuery = sender.getReportQuery(reports[0].id);

        String expectedQuery = '/' + report.Id + '?xls=1' + '&pv0=filter1&pv1=filter2&pv2=filter3';
        System.assertEquals(expectedQuery, reportQuery);

        // test methods do not allow callouts to ApexPages.PageReference, so we have to fake the content
        Blob reportContent = Blob.valueOf('report content!');

        String reportName = 'reportex';

        Messaging.EmailFileAttachment attachment = sender.getReportAttachment(reportContent, reportName);
        String today = Datetime.now().format('MM-dd-YYYY');

        System.assertEquals(reportName + '_' + today + '.csv', attachment.getFileName());
        System.assertEquals('application/vnd.ms-excel', attachment.getContentType());

        List<Messaging.EmailFileAttachment> attachments = sender.getAllReportAttachments();

        System.assertEquals(reports.size(), attachments.size());
    }
}