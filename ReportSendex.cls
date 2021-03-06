/**
 * Created by mstackhouse on 8/23/2018.
 * Description: Can be used to pull a report and email it to a list of recipients.
 *
 * More information about constructing this method:
 * Get full report in csv format: https://codecracksblog.wordpress.com/2017/04/11/how-to-exportcsvexcel-salesforce-reports-using-apex-and-send-email/
 * Change Report Filters by URL: https://success.salesforce.com/answers?id=90630000000hWv2AAE

 * Test: ReportSendexTest
 */

public without sharing class ReportSendex implements Queueable, Database.AllowsCallouts {
    public Set<Id> reportIds;
    public Map<Id, List<String>> filtersByReportId;
    public Map<Id, String> namesByReportId;
    public Messaging.SingleEmailMessage email;
    public String fileType;

    public ReportSendex(Map<Id, List<String>> filtersByReportId, Messaging.SingleEmailMessage email, String fileType) {
        this.reportIds = filtersByReportId.keySet();
        // order of the filters is important, they need to be in the order shown in the report UI
        this.filtersByReportId = filtersByReportId;
        this.email = email;
        List<Report> reports = [
                SELECT Id, DeveloperName
                FROM Report
                WHERE Id IN : filtersByReportId.keySet()
        ];
        Map<Id, String> namesByReportId = new Map<Id, String>();
        for (Report queriedReport : reports){
            namesByReportId.put(queriedReport.Id, queriedReport.DeveloperName);
        }
        this.namesByReportId = namesByReportId;
        this.fileType = fileType;
    }

    public void execute(QueueableContext context) {
        email.setFileAttachments(getAllReportAttachments());
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
    }

    public List<Messaging.EmailFileAttachment> getAllReportAttachments() {
        List<Messaging.EmailFileAttachment> emailFileAttachments = new List<Messaging.EmailFileAttachment>();
        for (String reportId : reportIds) {
            String reportQuery = getReportQuery((String) reportId);
            Blob reportContent;
            if (!Test.isRunningTest()) {
                ApexPages.PageReference report = new ApexPages.PageReference(reportQuery);
                reportContent = report.getContent();
            } else {
                reportContent = Blob.valueOf('test report content');
            }
            Messaging.EmailFileAttachment emailFileAttachment = getReportAttachment(reportContent, reportId);
            emailFileAttachments.add(emailFileAttachment);
        }
        return emailFileAttachments;
    }

    public Messaging.EmailFileAttachment getReportAttachment(Blob reportContent, String reportName) {
        Messaging.EmailFileAttachment emailFileAttachment = new Messaging.EmailFileAttachment();
        String today = Datetime.now().format('MM-dd-YYYY');
        if (fileType == 'csv') {
            emailFileAttachment.setContentType('text/csv');
        } else if (fileType == 'xls') {
            emailFileAttachment.setContentType('application/vnd.ms-excel');
        }
        emailFileAttachment.setFileName(reportName + '_' + today + '.' + fileType);
        emailFileAttachment.setBody(reportContent);

        return emailFileAttachment;
    }

    public String getReportQuery(String reportId) {
        String reportQuery = '/' + reportId + '?' + fileType + '=1';
        Integer i = 0;
        List<String> filters = filtersByReportId.get(reportId);
        for (String filter : filters ) {
            reportQuery += '&pv' + i + '=' + filter;
            i += 1;
        }

        return reportQuery;
    }
}