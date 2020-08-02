//
//  SeparateDigitsRow.swift
//  
//
//  Created by Artyom Zagoskin on 01.08.2020.
//

import UIKit

// MARK: - Type Aliases

typealias Handler = () -> Void

// MARK: - SeparateDigitsCellState
    
public enum SeparateDigitsCellState {
    case standard
    case error
}

// MARK: - Base

@IBDesignable
open class SeparateDigitsCell: Cell<String>, CellType {
    
    // MARK: UI
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: contentView.frame)
        stackView.distribution = .fillEqually
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        stackView.alignment = .center
        stackView.spacing = 5
        stackView.axis = .horizontal
        
        return stackView
    }()
    private var digitTextFields: [DigitTextField] = []
    private var textFieldBottomLines: [UIView] = []
    
    // MARK: - Properties
    
    @IBInspectable private var digitsCount: Int = 4
    @IBInspectable private var standardColor: UIColor = .gray
    @IBInspectable private var selectionColor: UIColor = .black
    @IBInspectable private var errorColor: UIColor = .red
    
    // MARK: - Init
    
    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        changeState(to: .standard)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        selectionStyle = .none
        changeState(to: .standard)
    }
    
    open override func setup() {
        super.setup()
        setUpStackView()
    }
    
    open override func update() {}
    
}


// MARK: - Public API

extension SeparateDigitsCell {
    
    open func setUp(digitsCount: Int = 4, standardColor: UIColor = .gray, selectionColor: UIColor = .black, errorColor: UIColor = .red) {
        self.digitsCount = digitsCount
        self.standardColor = standardColor
        self.selectionColor = selectionColor
        self.errorColor = errorColor
        
        setUpTextFields()
    }
    
    open func changeState(to state: SeparateDigitsCellState) {
        let color: UIColor
        switch state {
        case .error:
            color = errorColor
        case .standard:
            color = standardColor
        }
        
        textFieldBottomLines.forEach { $0.backgroundColor = color }
    }
    
}


// MARK: - Private API

extension SeparateDigitsCell {
    
    private func checkCodeIfNeeded() {
        let isValid = !digitTextFields.contains(where: { $0.text?.isEmpty ?? false })
        if isValid {
            row.value = digitTextFields.reduce("", { result, textField in
                guard let unwrappedResult = result, let text = textField.text else { return result }
                return unwrappedResult + text
            })
        } else {
            row.value = ""
        }
    }
    
    private func setUpStackView() {
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint = stackView.heightAnchor.constraint(equalToConstant: 70)
        heightConstraint.priority = .init(999)
        heightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor, constant: 10),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func setUpTextFields() {
        for _ in 0..<digitsCount {
            let textField = setUpDigitTextField()
            
            let view = setUpBottomLine()
            textField.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
                view.heightAnchor.constraint(equalToConstant: 1)
            ])
            
            textFieldBottomLines.append(view)
            stackView.addArrangedSubview(textField)
            textField.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textField.heightAnchor.constraint(equalTo: stackView.heightAnchor),
            ])
            
            digitTextFields.append(textField)
        }
    }
    
    private func setUpDigitTextField() -> DigitTextField {
        let textField = DigitTextField()
        textField.digitTextFieldDelegate = self
        textField.textAlignment = .center
        textField.contentHorizontalAlignment = .center
        textField.keyboardType = .numberPad
        textField.borderStyle = .none
        textField.adjustsFontSizeToFitWidth = false
        
        return textField
    }
    
    private func setUpBottomLine() -> UIView {
        let view = UIView()
        view.backgroundColor = standardColor
        
        return view
    }
    
}

// MARK: - DigitTextFieldDelegate

extension SeparateDigitsCell: DigitTextFieldDelegate {
    
    func digitTextField(_ textField: DigitTextField, changedCharactersIn range: NSRange, replacementString string: String) {
        
        if !string.isEmpty {
            if textField != digitTextFields.last, let index = digitTextFields.firstIndex(of: textField) {
                let field = digitTextFields[index + 1]
                field.becomeFirstResponder()
            } else if textField == digitTextFields.last {
                textField.endEditing(true)
            }
        }
        
        textField.text = string

        checkCodeIfNeeded()
    }
    
    func backspaceActionInEmptyTextField(_ textField: DigitTextField) {
        if textField != digitTextFields.first, let index = digitTextFields.firstIndex(of: textField) {
            let field = digitTextFields[index - 1]
            field.text = ""
            field.becomeFirstResponder()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: DigitTextField) {
        changeState(to: .standard)
        if let index = digitTextFields.firstIndex(of: textField) {
            textFieldBottomLines[index].backgroundColor = selectionColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: DigitTextField) {
        if let index = digitTextFields.firstIndex(of: textField) {
            textFieldBottomLines[index].backgroundColor = standardColor
        }
    }
    
}

// MARK: SeparateDigitsRow

open class _SeparateDigitsRow: Row<SeparateDigitsCell> {

    required public init(tag: String?) {
        super.init(tag: tag)
    }
    
}

public final class SeparateDigitsRow: _SeparateDigitsRow, RowType {

    required public init(tag: String?) {
        super.init(tag: tag)
    }
    
    convenience init(digitsCount: Int, standardColor: UIColor, selectionColor: UIColor, errorColor: UIColor, completion: (SeparateDigitsRow) -> Void) {
        self.init(nil, completion)
        cell.setUp(digitsCount: digitsCount, standardColor: standardColor, selectionColor: selectionColor, errorColor: errorColor)
    }
    
}

// MARK: - DigitTextFieldDelegate

extension SeparateDigitsCell: DigitTextFieldDelegate {
    
    func digitTextField(_ textField: DigitTextField, changedCharactersIn range: NSRange, replacementString string: String) {
        
        if !string.isEmpty {
            if textField != digitTextFields.last, let index = digitTextFields.firstIndex(of: textField) {
                let field = digitTextFields[index + 1]
                field.becomeFirstResponder()
            } else if textField == digitTextFields.last {
                textField.endEditing(true)
            }
        }
        
        textField.text = string

        checkCodeIfNeeded()
    }
    
    func backspaceActionInEmptyTextField(_ textField: DigitTextField) {
        if textField != digitTextFields.first, let index = digitTextFields.firstIndex(of: textField) {
            let field = digitTextFields[index - 1]
            field.text = ""
            field.becomeFirstResponder()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: DigitTextField) {
        changeState(to: .error)
        if let index = digitTextFields.firstIndex(of: textField) {
            textFieldBottomLines[index].backgroundColor = selectionColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: DigitTextField) {
        if let index = digitTextFields.firstIndex(of: textField) {
            #warning("Add colors")
            textFieldBottomLines[index].backgroundColor = standardColor
        }
    }
    
}

// MARK: SeparateDigitsRow

open class _SeparateDigitsRow: Row<SeparateDigitsCell> {

    required public init(tag: String?) {
        super.init(tag: tag)
    }
    
}

/** Use $0.cell.setUp(digitsCount: %d, standardColor: %@, errorColor: %@) in closure */

public final class SeparateDigitsRow: _SeparateDigitsRow, RowType {

    required public init(tag: String?) {
        super.init(tag: tag)
    }
    
    convenience init(digitsCount: Int, standardColor: UIColor, selectionColor: UIColor, errorColor: UIColor) {
        self.init()
        cell.setUp(digitsCount: digitsCount, standardColor: standardColor, selectionColor: selectionColor, errorColor: errorColor)
    }
    
}

// MARK: - DigitTextFieldDelegate

protocol DigitTextFieldDelegate: class {
    func digitTextField(_ textField: DigitTextField, changedCharactersIn range: NSRange, replacementString string: String)
    func backspaceActionInEmptyTextField(_ textField: DigitTextField)
    func textFieldDidBeginEditing(_ textField: DigitTextField)
    func textFieldDidEndEditing(_ textField: DigitTextField)
}


extension DigitTextFieldDelegate {
    func digitTextField(_ textField: DigitTextField, changedCharactersIn range: NSRange, replacementString string: String) {}
    func backspaceActionInEmptyTextField(_ textField: DigitTextField) {}
    func textFieldDidBeginEditing(_ textField: DigitTextField) {}
    func textFieldDidEndEditing(_ textField: DigitTextField) {}
}


// MARK: - DigitTextField

final class DigitTextField: UITextField {
    
    // MARK: - Properties
    
    weak var digitTextFieldDelegate: DigitTextFieldDelegate?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
    }
    
    // MARK: - Overridden API
    
    override func deleteBackward() {
        if text?.isEmpty ?? true {
            digitTextFieldDelegate?.backspaceActionInEmptyTextField(self)
        }
        super.deleteBackward()
    }
    
}

// MARK: - UITextFieldDelegate

extension DigitTextField: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if NSPredicate(format: "SELF MATCHES %@", "[0-9]{0,1}").evaluate(with: string) {
            digitTextFieldDelegate?.digitTextField(self, changedCharactersIn: range, replacementString: string)
        }

        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        digitTextFieldDelegate?.textFieldDidBeginEditing(self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        digitTextFieldDelegate?.textFieldDidEndEditing(self)
    }
    
}

