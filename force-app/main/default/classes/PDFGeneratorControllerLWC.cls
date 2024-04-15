public without sharing class PDFGeneratorControllerLWC {

    @AuraEnabled(cacheable=false)
    public static AccountPDF getAccount(Id recordId){
        Account acc = [SELECT Id, Name, (SELECT Id, Name FROM Opportunities),(SELECT Id, Name FROM Contacts)
                            FROM Account WHERE Id = :recordId];
        
        AccountPDF apdf = new AccountPDF();
        AccountDTO accDTO = new AccountDTO();
        accDTO.id = acc.Id;
        accDTO.Name = acc.Name;
        apdf.account = accDTO;

        List<OppoDTO> opps = new List<OppoDTO>();
        for(Opportunity o : acc.Opportunities){
            OppoDTO oDTO = new OppoDTO();
            oDTO.Id = o.Id;
            oDTO.Name = o.Name;
            opps.add(oDTO);
        }
        apdf.opps = opps;
        

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
        public String Name {get; set;}
    }

    public class AccountDTO extends BaseObject{

    }

    public class OppoDTO extends BaseObject{
        
    }

    public class ContactDTO extends BaseObject{
        
    }


}