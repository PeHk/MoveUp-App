import Combine
import UIKit

class SetCaloriesViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var caloriesField: UITextField!
    @IBOutlet weak var plusButtonView: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(increaseCalories(_:)))
            plusButtonView.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var minusButtonView: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(decreaseCalories(_:)))
            minusButtonView.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var setButton: PrimaryButton!
    var viewModel: SetCaloriesViewModel!
    var coordinator: SetCaloriesCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    private func setupView() {
        plusButtonView.layer.cornerRadius = plusButtonView.bounds.height / 2
        minusButtonView.layer.cornerRadius = minusButtonView.bounds.height / 2
        
        caloriesField.delegate = self
    }
    
    private func setupBindings() {
        
    }
    
    @IBAction func setButtonTapped(_ sender: Any) {
        viewModel.stepper.send(.save)
    }
    
    @objc func increaseCalories(_ sender: UITapGestureRecognizer) {
        if let currentInput = caloriesField.text {
            
            if let maxNum = Int(currentInput) {
                if maxNum >= 2000 {
                    self.caloriesField.text = "2000"
                    return 
                }
            }
            
            let num = (Int(currentInput) ?? 0) + viewModel.increaseNumber
            self.caloriesField.text = "\(num)"
        }
    }
    
    @objc func decreaseCalories(_ sender: UITapGestureRecognizer) {
        guard caloriesField.text != "0" && caloriesField.text != "" else { return }
        if let currentInput = caloriesField.text {
            let num = (Int(currentInput) ?? 0) - viewModel.increaseNumber
            self.caloriesField.text = "\(num)"
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text.starts(with: "0") {
            textField.text = "0"
        } else if let num = Int(text) {
            if num > 2000 {
                textField.text = "2000"
            }
        }
    }
}
