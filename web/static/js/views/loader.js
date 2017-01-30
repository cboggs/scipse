import MainView from './main';
//import DocShowView from './docview';
import PagePdfView from './docview';

// Collection of specific view modules
const views = {
  //DocShowView,
  PagePdfView,
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}
