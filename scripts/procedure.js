// creation of image
function createImage()
{   
    var placeholder = document.getElementById('controlAddIn');        //find a place
    var ImageBitmap = document.createElement('img');                  //create object
    ImageBitmap.id = 'buxee_img';                                         //sets its params
    //ImageBitmap.height = '100%';
    //ImageBitmap.width = '100%';
    placeholder.appendChild(ImageBitmap);                             //add object to place
}

// embedding the page to the BC page and BC card
function embedPicture()
{
    createImage();                                             //run function to create
    var ImageBitmap = document.getElementById('img');                //find our Iframe
    ImageBitmap.src = 'https://businesscentral.dynamics.com/78037602-8821-4156-8e6d-068591ae1b78/Sandbox/?page=51&company=Societ%C3%A0%20Corso&dc=0&bookmark=29%3bJgAAAACLAgAAAAJ7BjEAMAA3ADQAMgAw';
}

document.write('<div class="wrapper"><image id="purchase-picture" class="purchase-picture"></div>');
/*
// Adjust canvas coordinate space taking into account pixel ratio,
// to make it look crisp on mobile devices.
// This also causes canvas to be cleared.
function resizeCanvas() {
    // When zoomed out to less than 100%, for some very strange reason,
    // some browsers report devicePixelRatio as less than 1
    // and only part of the canvas is cleared then.
    var ratio = Math.max(window.devicePixelRatio || 1, 1);
    canvas.width = canvas.offsetWidth * ratio;
    canvas.height = canvas.offsetHeight * ratio;
    canvas.getContext("2d").scale(ratio, ratio);
} */

var image = new PurchasePicture(canvas, {
    backgroundColor: 'rgb(255, 255, 255)' // necessary for saving image as JPEG; can be removed is only saving as PNG or SVG
});

function SaveImage(image = "") {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('AfterSaveImage', [canvas.toDataURL()]);
};

function Clear() {
    purchasePicture.clear();
};

function Undo() {
    var data = purchasePicture.toData();
    if (data) {
        data.pop(); // remove the last dot or line
        purchasePicture.fromData(data);
    }
};