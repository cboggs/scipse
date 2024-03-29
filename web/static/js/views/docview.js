import MainView from './main';
//import socket from '../socket.js';
import * as d3 from 'd3';

function start_box() {
    if (d3.event.button == 0) {
      this.adjusted = false;
      this.finish_margin_px = 3;
      let mouse = d3.mouse(this);
      let mouse_x = mouse[0];
      let mouse_y = mouse[1];
      this.start_x = mouse_x;
      this.start_y = mouse_y;
      this.g_id = "box_" + parseInt(mouse_x) + "_" + parseInt(mouse_y);

      let svg = d3.select(this);
      this.g = svg.append("g")
            .attr("id", this.g_id)
            .on("mouseover", box_mouseover)
            .on("mouseout", box_mouseout);

      this.rect =
        this.g.append("rect")
          .attr("x", mouse_x)
          .attr("y", mouse_y)
          .attr("width", 0)
          .attr("height", 1)
          .attr("rx", 10)
          .attr("ry", 10);
      svg.on("mousemove", adjust_box);
    }
  }

  function adjust_box() {
    let svg = d3.select(this);
    let svg_canvas_width = parseInt(svg.attr('width')) - this.finish_margin_px;
    let svg_canvas_height = parseInt(svg.attr('height')) - this.finish_margin_px;
    let mouse = d3.mouse(this);
    let mouse_x = mouse[0];
    let mouse_y = mouse[1];

    if (mouse_x >= this.start_x && mouse_x <= svg_canvas_width) {
      this.rect.attr("width", mouse_x - this.start_x);
    }
    else if (mouse_x < this.start_x && mouse_x >= this.finish_margin_px) {
      this.rect.attr("x", mouse_x)
          .attr("width", this.start_x - mouse_x);
    }
    else {
      dispatch_mouseup_to_svg(svg.attr('id'));
    }

    if (mouse_y >= this.start_y && mouse_y <= svg_canvas_height) {
      this.rect.attr("height", mouse_y - this.start_y);
    }
    else if (mouse_y < this.start_y && mouse_y >= this.finish_margin_px) {
      this.rect.attr("y", mouse_y)
          .attr("height", this.start_y - mouse_y);
    }
    else {
      dispatch_mouseup_to_svg(svg.attr('id'));
    }

    this.adjusted = true;
  }

  function finish_box() {
    if (d3.event.button == 0) {
      var svg = d3.select(this);
      svg.on("mousemove", null);

      if (!this.adjusted
          || this.rect.attr("width") <= 20
          || this.rect.attr("height") <= 20)
      {
        d3.select("#" + this.g_id).remove();
      }
      else {
        let delete_button =
          this.g.append("rect")
            .attr("class", "annotationDeleteButton")
            .attr("x", +this.rect.attr("x") + +this.rect.attr("width") - 15)
            .attr("y", +this.rect.attr("y") + 5)
            .attr("width", 10)
            .attr("height", 10)
            .attr("rx", 5)
            .attr("ry", 5)
            .attr("opacity", 0.0);

        var g_id = this.g_id;
        delete_button.on("mouseup", function() {
            d3.select("#" + g_id).remove();
            svg.on("mousedown", start_box);
            d3.event.stopPropagation();
          });
      }

      svg.on("mousedown", start_box);
      svg.on("mousemove", null);
    }
  }

  function dispatch_mouseup_to_svg(svg_id) {
    var evt = document.createEvent("MouseEvents");
    evt.initEvent("mouseup", true, true);
    document.getElementById(svg_id).dispatchEvent(evt);
  }

  function box_mouseover() {
    d3.select("#" + this.parentNode.id)
        .on("mousedown", null);
    d3.select(this)
      .select(".annotationDeleteButton")
      .attr("opacity", 1.0);
  }

  function box_mouseout() {
    d3.select("#" + this.parentNode.id)
        .on("mousedown", start_box);
    d3.select(this)
      .select(".annotationDeleteButton")
      .attr("opacity", 0.0);
  }

export default class DocumentShowView extends MainView {
  mount() {
    super.mount();
    const pdf_path = document.getElementById('pdf_path').dataset.pdfPath;
    const div = document.getElementById('pdfParentDiv');
    this.render_pdf(div, pdf_path);
  }

  render_pdf(div, pdf_path) {
    let parent_div_id = "pdfParentDiv";
    let base_pdf_svg_id = "pdf-svg";
    let pdf_svg_num = 0;

    PDFJS.workerSrc = '/vendor/pdf.worker.min.js';
    PDFJS.getDocument(pdf_path).then(function (pdf) {
      for (var pageNum = 1; pageNum <= pdf.numPages; pageNum++) {
        pdf.getPage(pageNum).then(function (page) {
          var scale = 1.0;
          var viewport = page.getViewport(scale);

          var container = document.getElementById(parent_div_id);

          container.style.width = viewport.width + "px";
          container.style.height = ((viewport.height * pdf.numPages) + 25) + "px";

          page.getOperatorList()
            .then(function (opList) {
              var svgGfx = new PDFJS.SVGGraphics(page.commonObjs, page.objs);
              return svgGfx.getSVG(opList, viewport);
            })
            .then(function (svg) {
              let svg_id = base_pdf_svg_id + '_' + pdf_svg_num;
              pdf_svg_num++;
              svg.setAttribute("id", svg_id);
              container.appendChild(svg);
              d3.selectAll("#" + svg_id)
                .attr("class", "pdfPageParentSvg")
                .on("mousedown", start_box)
                .on("mouseup", finish_box)
                .on("contextmenu", function(d, i) { d3.event.preventDefault(); });

              d3.selectAll("#" + svg_id)
                .selectAll("*")
                  .attr("class", "pdfPageSvg")
                  .on("contextmenu", function(d, i) { d3.event.preventDefault(); });

              console.log("Rendered page " + pdf_svg_num);
            });
        });
      }
    });
  }
}
