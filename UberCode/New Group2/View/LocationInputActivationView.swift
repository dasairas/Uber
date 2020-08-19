
import UIKit

protocol LocationInputActivationViewDelegate: class {
    
    func presentLocationInputView()
}



class LocationInputActivationView: UIView {
    
    
    //MARK: Properties
    
    weak var delegate: LocationInputActivationViewDelegate?
    
    
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let placeHolderLabel: UILabel =  {
        let label = UILabel()
        label.text = "where to?"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    
    
    //MARK: Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        addSubview(indicatorView)
        indicatorView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        indicatorView.setDimensions(height: 6, width: 6)
        
        addSubview(placeHolderLabel)
        placeHolderLabel.centerY(inView: self, leftAnchor: indicatorView.rightAnchor, paddingLeft: 20)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentLocationInputView))
        addGestureRecognizer(tap)
        
    }
    
    
    required init?(coder: NSCoder) { //FIX x el init lo hace
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: Selector
    
    @objc func presentLocationInputView() {
        delegate?.presentLocationInputView()
        
    }
    
}
