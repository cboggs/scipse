import MainView from './main';
//import socket from '../socket.js';

export default class AdminPdfView extends MainView {
  mount() {
    super.mount();
    console.log("Entered AdminPdfView");
    this.get_pdf_pages();
  }

  get_pdf_pages() {
    require('pdfjs-dist');
    PDFJS.workerSrc = '/vendor/pdf.worker.min.js';
    PDFJS.getDocument('/vendor/test.pdf').then(function (pdf) {
      pdf.getPage(1).then(function (page) {
        var scale = 1.0;
        var viewport = page.getViewport(scale);

        var canvas = document.getElementById('pdf-canvas');
        var context = canvas.getContext('2d');

        canvas.height = viewport.height;
        canvas.width = viewport.width;

        var renderContext = {
          canvasContext: context,
          viewport: viewport
        };
        page.render(renderContext);
      });
    });
  }
}
