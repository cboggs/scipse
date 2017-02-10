import MainView from './main';
import DocumentShowView from './docview';
import PagePdfView from './docview';

// Collection of specific view modules
const views = {
  DocumentShowView,
  PagePdfView,
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}
