import UIKit

class CurrencyView: UIView {
    @IBOutlet private var abbreviationLabel: UILabel!
    @IBOutlet private var valueTextField: UITextField!

    weak var delegate: CurrencyViewDelegate?

    var currencyAbbreviation: String? {
        get {
            return abbreviationLabel.text
        }
        set {
            abbreviationLabel.text = newValue
        }
    }

    var currencyValue: Double {
        get {
            return Double(valueTextField.text ?? "") ?? 0.0
        }
        set {
            valueTextField.text = String(format: "%.2f", newValue)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViewFromNib()
    }

    private func setupViewFromNib() {
        let nib = UINib(nibName: "CurrencyView", bundle: nil)

        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Failed to load CurrencyView XIB")
        }

        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        valueTextField.delegate = self
    }


  

}

//MARK - UITextField Delegates
extension CurrencyView:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let newValue = Double(textField.text ?? ""), let abbreviation = abbreviationLabel.text {
            let requestCurrencyExchange = CurrencyModel(value: newValue, abbreviation: abbreviation)
            delegate?.currencyValueChanged(requestCurrencyExchange,view: self)
            return true
        }
        else
        {
            return false
        }
       
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let allowedCharacters = CharacterSet(charactersIn:".0123456789 ")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)

    }
}





protocol CurrencyViewDelegate:AnyObject {
    func currencyValueChanged(_ newValue: CurrencyModel ,view: CurrencyView)
}


