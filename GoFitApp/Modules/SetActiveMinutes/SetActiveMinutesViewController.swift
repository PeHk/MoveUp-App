import Combine
import UIKit

class SetActiveMinutesViewController: BaseViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var minutesField: UITextField!
    @IBOutlet weak var plusButtonView: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(increaseMinutes(_:)))
            plusButtonView.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var minusButtonView: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(decreaseMinutes(_:)))
            minusButtonView.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var setButton: PrimaryButton!
    
    var viewModel: SetActiveMinutesViewModel!
    weak var coordinator: SetActiveMinutesCoordinator!
    
    private var subscription = Set<AnyCancellable>()
    private var activityMinutes: Int = 0
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    private func setupView() {
        plusButtonView.layer.cornerRadius = plusButtonView.bounds.height / 2
        minusButtonView.layer.cornerRadius = minusButtonView.bounds.height / 2
        
        minutesField.delegate = self
    }
    
    // MARK: Bindings
    private func setupBindings() {
        viewModel.errorState
            .compactMap( { $0 })
            .assign(to: \.errorState, on: self)
            .store(in: &subscription)
        
        viewModel.isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &subscription)
        
        viewModel.currentUser
            .sink { currentUser in
                if let user = currentUser {
                    let data = user.bio_data.array(of: BioData.self).first
                    self.activityMinutes = Int(data?.activity_minutes ?? 150)
                    self.minutesField.text = "\(self.activityMinutes)"
                }
            }
            .store(in: &subscription)
        
    }
    
    // MARK: Actions
    @IBAction func setButtonTapped(_ sender: Any) {
        let inputMinutes = Int(minutesField.text ?? "150") ?? 150
        
        if self.activityMinutes == inputMinutes {
            viewModel.stepper.send(.save)
        } else {
            viewModel.action.send(.saveTapped(inputMinutes))
        }
    }
    
    @objc func increaseMinutes(_ sender: UITapGestureRecognizer) {
        if let currentInput = minutesField.text {
            
            if let maxNum = Int(currentInput) {
                if maxNum >= 2000 {
                    self.minutesField.text = "2000"
                    return 
                }
            }
            
            let num = (Int(currentInput) ?? 0) + viewModel.increaseNumber
            self.minutesField.text = "\(num)"
        }
    }
    
    @objc func decreaseMinutes(_ sender: UITapGestureRecognizer) {
        guard minutesField.text != "0" && minutesField.text != "" else { return }
        if let currentInput = minutesField.text {
            let num = (Int(currentInput) ?? 0) - viewModel.increaseNumber
            self.minutesField.text = "\(num)"
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
