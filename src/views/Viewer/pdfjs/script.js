/* SOLUTION N°1 */
var numPage = 1;
var totalPage = null;
var oPdf = PDFJS.getDocument("/home/camilo/Downloads/Carta Pasantia correccion(1).pdf");
oPdf.then(renderPDF);

function renderPDF(pdf){
    if (totalPage == null){
        pdf.getPage(numPage).then(renderPage);
        numPage++;
    }
    if (numPage <= totalPage){
        pdf.getPage(numPage).then(renderPage);
        numPage++;

        setTimeout("renderPDF(pdf)", 3000);
    }
}

function renderPage(page){
    var scale = 1.5;
    var viewport = page.getViewport(scale)
    var canvas = document.getElementById("the-canvas")
    var context = canvas.getContext('2d')
    canvas.height = viewport.height
    canvas.width = viewport.width
    var renderContext = {
        canvasContext: context,
        viewport: viewport
    };
    page.render(renderContext);
}
