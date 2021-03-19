
// connettore tra JavaScript e Business Central
Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnControlAddInReady', '');

var PictureAddIn, imageDiv;

function init() {
    PictureAddIn = new PictureAddIn;
    PictureAddIn.init();
    //RaiseAddInReady();
}

/* controlAddIn =$("#PictureAddIn");

imageDiv = $("<div />", {id : "picDiv"});
image = $("<img />", 
{src : Microsoft.Dynamics.NAV.GetImageResource()});

imageDiv.append(image);
controlAddIn.append(imageDiv); */