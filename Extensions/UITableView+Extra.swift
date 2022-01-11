import UIKit

extension UITableView {
    
    func register<T: UITableViewCell>(withClass cellClass: T.Type, forBundle bundle: Bundle = Bundle.main) {
        let classNameString = String(describing: cellClass)
        register(cellClass, forCellReuseIdentifier: classNameString)
        if Bundle.main.path(forResource: classNameString, ofType: "nib") != nil {
            register(UINib(nibName: classNameString, bundle: Bundle.main), forCellReuseIdentifier: classNameString)
        } else {
            fatalError()
        }
    }
    
    func dequeueReusableCell<T: UITableViewCell>(withClass cellClass: T.Type) -> T {
        let classNameString = String(describing: cellClass)
        guard let cell = dequeueReusableCell(withIdentifier: classNameString) as? T else {
            return T()
        }
        
        return cell
    }
    
    func dequeueReusableCell<T: UITableViewCell>(withClass cellClass: T.Type, for indexPath: IndexPath) -> T {
        let classNameString = String(describing: cellClass)
        guard let cell = dequeueReusableCell(withIdentifier: classNameString, for: indexPath) as? T else {
            return T()
        }
        
        return cell
    }

    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView> (withClass viewClass: T.Type) -> T {
        let classNameString = String(describing: viewClass)
        guard let cell = dequeueReusableHeaderFooterView(withIdentifier: classNameString) as? T else {
            return T()
        }
        
        return cell
    }
    
    func hideExtraSeparators() {
        if tableFooterView == nil {
            tableFooterView = UIView()
        }
    }
}
