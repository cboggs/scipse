import MainView from './main';
import DocumentShowView from './docview';

// Collection of specific view modules
const views = {
  DocumentShowView,
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}
