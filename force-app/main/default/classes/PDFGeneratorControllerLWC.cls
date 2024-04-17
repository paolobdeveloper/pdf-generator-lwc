public without sharing class PDFGeneratorControllerLWC {

    @AuraEnabled(cacheable=false)
    public static AccountPDF getAccount(Id recordId){
        Account acc = [SELECT Id, Name, Type, Phone, Owner.Name, Industry, 
                            (SELECT Id, Name, StageName, Amount, CloseDate FROM Opportunities ORDER BY CreatedDate DESC),
                            (SELECT Id, Name, Title, Email, Phone FROM Contacts ORDER BY CreatedDate DESC)
                            FROM Account WHERE Id = :recordId];
        
        AccountPDF apdf = new AccountPDF();
        AccountDTO accDTO = new AccountDTO();
        accDTO.id = acc.Id;
        accDTO.name = acc.Name;
        accDTO.type = acc.Type;
        accDTO.industry = acc.Industry;
        accDTO.owner = acc.Owner.Name;
        apdf.account = accDTO;

        List<OppoDTO> opps = new List<OppoDTO>();
        for(Opportunity o : acc.Opportunities){
            OppoDTO oDTO = new OppoDTO();
            oDTO.Id = o.Id;
            oDTO.name = o.Name;
            oDTO.stage = o.StageName;
            oDTO.amount = o.Amount;
            oDTO.closeDate = o.CloseDate;
            opps.add(oDTO);
        }
        apdf.opps = opps;

        List<ContactDTO> cts = new List<ContactDTO>();
        for(Contact c : acc.Contacts){
            ContactDTO cDTO = new ContactDTO();
            cDTO.Id = c.Id;
            cDTO.name = c.Name;
            cDTO.title = c.Title;
            cDTO.email = c.Email;
            cDTO.phone = c.Phone;
            cts.add(cDTO);
        }
        apdf.contacts = cts;
        

        return apdf;
    }

    @AuraEnabled
    public static String saveFileInAttachment(String ids, String name, String pdfBody){
        try{
            String pdfName = name+'.pdf';
            //DELETE previous version if exist
            List<ContentVersion> prev = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId = :ids AND Title = :name];
            if(!prev.isEmpty()){
                List<ContentDocument> toDels = new List<ContentDocument>();
                for(ContentVersion co : prev){
                    ContentDocument cd = new ContentDocument(Id = co.ContentDocumentId);
                    toDels.add(cd);
                }
                delete toDels;
            }
            ContentVersion cv = new ContentVersion();
            cv.PathOnClient = pdfName;
            cv.Title = name;
            cv.Description = name;
            cv.VersionData = EncodingUtil.base64Decode(pdfBody);
            cv.FirstPublishLocationId = ids;
            insert cv;
            return 'OK';
        }catch(Exception exc){
            System.debug('Error during saving file for '+name+', for object ID:'+ids);
            return 'KO';
        }

    }
    
    
    public class AccountPDF {

        @AuraEnabled
        public AccountDTO account { get; set; }

        @AuraEnabled
        public List<OppoDTO> opps { get; set; }
        
        @AuraEnabled
        public List<ContactDTO> contacts { get; set; }      
        
        @AuraEnabled
        public List<BaseObject> attachments { get; set; }   
    }

    public virtual class BaseObject{
        @AuraEnabled
        public Id id {get; set;}

        @AuraEnabled
        public String name {get; set;}
    }

    public class AccountDTO extends BaseObject{
        @AuraEnabled public String phone;
        @AuraEnabled public String owner;
        @AuraEnabled public String industry;
        @AuraEnabled public String type;
    }

    public class OppoDTO extends BaseObject{
        @AuraEnabled public String stage;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public Date closeDate;        
    }

    public class ContactDTO extends BaseObject{
        @AuraEnabled public String phone;
        @AuraEnabled public String title;
        @AuraEnabled public String email;        
    }


}