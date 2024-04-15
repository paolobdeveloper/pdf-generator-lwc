import { LightningElement, api, wire, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import JS_PDF from '@salesforce/resourceUrl/jsPDFLibrary';
import JSPDF_AUTO_TABLE from '@salesforce/resourceUrl/jspdfAutotableLibraryPlugin';

export default class PdfGenerator extends LightningElement {

    jsPDFInitialized = false;

    //TEMPLATE INFO VARS
    POS_LOGO = 15;
    LEFT_SPACE = 10;
    CENTER = 105;
    DELTA = 12;
    INC_LINE = 6;
    TO_RIGHT = 200;
    MAX_LINE_WIDTH = 180;
    FONT = 'times';
    //
  
    @api recordId;

    imgLogo ='data:image/png;base64,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';
 

    //carichiamo le librerie
    renderedCallback() {
        if (!this.jsPDFInitialized) {
          this.jsPDFInitialized = true;
            loadScript(this, JS_PDF)
            .then(() => {
                // jsPDF is loaded successfully, now load jspdf-autotable
                return loadScript(this, JSPDF_AUTO_TABLE);
            }).catch((error) => {
              console.error("Error loading jsPDF library", error);
            });
        }
      }

      //per dare riscontro dell'operazione di salvataggio pdf
      refreshComp(){
        this.dispatchEvent(
          new ShowToastEvent({
                      title:'Success',
                      message:'File Saved Successfully',
                      variant:'Success'
          })
      )
          setTimeout(function(){
            location.reload();
        }, 2000); 
      }      

      // il cuore...
      handleGeneratePDF() {
        console.log("id:" + this.recordId);
        //console.log('actvitiy:'+JSON.stringify(this.activity));
        if (this.jsPDFInitialized) {
            getActivity({ recordId: this.recordId })
            .then((result) => {
              //console.log('Data from Apex:'+ JSON.stringify(result));
              if (result) {
                this.activity = result.activity;
                this.activityFunds = result.funds;
                this.activityExtAttendees = result.extAttendees;
                this.activityEntities = result.entities;
                this.activityPortfolios = result.portfolios;
                this.activityFiles = result.attachments;
                this.error = undefined;

                  console.log("Activity:Meeting/Call");
                  // Make sure to correctly reference the loaded jsPDF library.
                  const doc = new window.jspdf.jsPDF();
  
                  // create Template
                  this.createTemplateActivityMeetingCall(doc);
                  //doc.save("test.pdf"); //non funziona su mobile, da commentare quando inviamo email
                  // questo e' il codice che deve girare
                  
                              saveFileInAttachment({ids: this.recordId, name: this.activity.Name, pdfBody: btoa(doc.output())})
                              .then(result => {
                                  console.log('saveFileInAttachment ok');  
                                  this.refreshComp();
                              })
                              .catch(error => {
                                  console.log(error);
                              });
                              

              }
            })
            .catch((error) => {
              console.log(error);
              this.error = error;
            });            
        }        
      }

}