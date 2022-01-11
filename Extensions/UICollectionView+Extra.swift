import UIKit

enum UICollectionViewReusableViewType: String {
    case header
    case footer
    
    var kind: String {
        switch self {
        case .header: return UICollectionView.elementKindSectionHeader
        case .footer: return UICollectionView.elementKindSectionFooter
        }
    }
}

extension UICollectionView {
    
    // MARK: - Register
    
    func register<T: UICollectionViewCell>(withClass cellClass: T.Type) {
        let stringClassName = String(describing: cellClass)
        register(cellClass, forCellWithReuseIdentifier: stringClassName)
        
        // Register nib if exists
        if Bundle.main.path(forResource: stringClassName, ofType: "nib") != nil {
            register(UINib(nibName: stringClassName, bundle: Bundle.main), forCellWithReuseIdentifier: stringClassName)
        } else {
            fatalError()
        }
    }
    
    func register<T: UICollectionReusableView>(withClass reusableViewClass: T.Type,
                                               reusableViewType: UICollectionViewReusableViewType,
                                               bundle: Bundle = Bundle.main) {
        let stringClassName = String(describing: reusableViewClass)
        register(reusableViewClass, forSupplementaryViewOfKind: reusableViewType.kind, withReuseIdentifier: stringClassName)
        
        if Bundle.main.path(forResource: stringClassName, ofType: "nib") != nil {
            register(UINib(nibName: stringClassName, bundle: bundle), forSupplementaryViewOfKind: reusableViewType.kind,
                     withReuseIdentifier: stringClassName)
        } else {
            fatalError()
        }
    }
    
    // MARK: - Dequeue
    
    func dequeueReusableCell<T: UICollectionViewCell>(withClass cellClass: T.Type, for indexPath: IndexPath) -> T {
        let stringClassName = String(describing: cellClass)
        guard let cell = dequeueReusableCell(withReuseIdentifier: stringClassName, for: indexPath) as? T else {
            return T()
        }
        return cell
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(withClass reusableViewClass: T.Type,
                                                                       ofType type: UICollectionViewReusableViewType,
                                                                       for indexPath: IndexPath) -> T {
        let stringClassName = String(describing: reusableViewClass)
        guard let view = dequeueReusableSupplementaryView(ofKind: type.kind,
                                                          withReuseIdentifier: stringClassName,
                                                          for: indexPath) as? T else {
            return T()
        }
        return view
    }
    
}
