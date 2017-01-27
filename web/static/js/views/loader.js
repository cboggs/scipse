import MainView from './main';
//import DocShowView from './docview';
import AdminPdfView from './docview';

// Collection of specific view modules
const views = {
  //DocShowView,
  AdminPdfView,
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}
