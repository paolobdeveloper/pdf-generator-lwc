public without sharing class PDFGeneratorControllerLWC {

    @AuraEnabled(cacheable=false)
    public static AccountPDF getAccount(Id recordId){
        return null;
    }
    
    public class AccountPDF {
        @AuraEnabled
        public AccountDTO account { get; set; }

        @AuraEnabled
        public List<OppoDTO> opps { get; set; }
        
        @AuraEnabled
        public List<ContactDTO> contacts { get; set; }        
    }

    public class AccountDTO{

    }

    public class OppoDTO{
        
    }

    public class ContactDTO{
        
    }
}