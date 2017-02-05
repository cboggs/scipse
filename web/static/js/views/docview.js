import MainView from './main';
//import socket from '../socket.js';
import * as d3 from 'd3';

export default class PagePdfView extends MainView {
  mount() {
    super.mount();
    let div = this.create_parent_div();
    this.render_pdf(div);
    this.add_overlay(div);
  }

  create_parent_div() {
//    var d3 = require("d3");
//    let svg = d3.select("body").append("svg")
//      .attr("id", "parent-svg")
//      .attr("width", 600)
//      .attr("height", 400)
//      .attr("FLOOBETY", "bloobety");
    let parent_div = d3.select("body").append("div")
        .attr("id", "parent-div");
//      .on("mousedown", start_box)
//      .on("mouseup", finish_box)
//      .on("contextmenu", function(d, i) { d3.event.preventDefault(); });

    return parent_div;
  }

  add_overlay(div) {
    var rect_adjusted = false;
    var box_current_id = 0;

//    fo = svg.append("foreignObject")                                
//        .attr("width", 499)                                         
//        .attr("height", 499)                                        
//        .attr("requiredExtensions", "http://www.w3.org/1999/xhtml");

  } 

  render_pdf(div) {
    let parent_div_id = div.attr("id");
    let child_svg_id = "child-svg";
    PDFJS.workerSrc = '/vendor/pdf.worker.min.js';
    PDFJS.getDocument('/vendor/test.pdf').then(function (pdf) {
      pdf.getPage(1).then(function (page) {
        var scale = 0.85;
        var viewport = page.getViewport(scale);

        var container = document.getElementById(parent_div_id);

        container.style.width = viewport.width + "px";
        container.style.height = viewport.height + "px";

        page.getOperatorList()
          .then(function (opList) {
            var svgGfx = new PDFJS.SVGGraphics(page.commonObjs, page.objs);
            return svgGfx.getSVG(opList, viewport);
          })
          .then(function (svg) {
            svg.setAttribute("id", child_svg_id);
            container.appendChild(svg);

            d3.select("#" + child_svg_id)
                .on("mousedown", function() { console.log("Nope!"); })
                .attr("class", "pdf-svg");

            var s = d3.select("#" + child_svg_id).selectAll("*").attr("class", "pdf-svg");
          });

      });
    });
  }
}
