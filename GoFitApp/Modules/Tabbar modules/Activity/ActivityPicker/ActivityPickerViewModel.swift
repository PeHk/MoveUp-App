import Combine
import Foundation

class ActivityPickerViewModel: ViewModelProtocol {
    
    // MARK: - Enums
    enum Action {
        case selected(_ sport: Sport)
    }
    
    enum Step {
        
    }
    
    enum State {
        case initial
        case loading
        case error(_ error: NetworkError)
    }
    
    // MARK: Actions and States
    func processAction(_ action: Action) {
        switch action {
        case .selected(let sport):
            self.processSelection(sport: sport)
        }
    }
    
    func processState(_ state: State) {
        switch state {
        case .initial:
            initializeView()
        case .error(let error):
            isLoading.send(false)
            errorState.send(error)
        case .loading:
            isLoading.send(true)
        }
    }
    
    // MARK: - Variables
    var state = CurrentValueSubject<State, Never>(.initial)
    var action = PassthroughSubject<Action, Never>()
    var stepper = PassthroughSubject<Step, Never>()
    var errorState = PassthroughSubject<NetworkError, Never>()
    var isLoading = CurrentValueSubject<Bool, Never>(false)
    
    var subscription = Set<AnyCancellable>()
    
    let sportManager: SportManager
    
    var sections = CurrentValueSubject<[SectionData], Never>([])
    
    // MARK: - Init
    init(_ dependencyContainer: DependencyContainer) {
        self.sportManager = dependencyContainer.sportManager
        
        action.sink(receiveValue: { [weak self] action in
            self?.processAction(action)
        })
            .store(in: &subscription)
        
        state.sink(receiveValue: { [weak self] state in
            self?.processState(state)
        })
            .store(in: &subscription)
        
        self.sportManager.currentSports
            .sink { sports in
                let grouppedSports = Dictionary(grouping: sports, by: { $0.name?.prefix(1) ?? "" })
                
                let keys = grouppedSports.keys.sorted()
                
                var sections: [SectionData] = keys.map{ SectionData(sectionIndexName: String($0), sectionName: String($0), sectionItems: grouppedSports[$0]!.sorted(by: { $0.name ?? "" < $1.name ?? "" }))}
                
//                sections.insert(SectionData(sectionIndexName: "★", sectionName: "Recent", sectionItems: []), at: 0)
                
                self.sections.send(sections)
            }
            .store(in: &subscription)

    }
    
    internal func initializeView() {
        isLoading.send(false)
    }
    
    private func processSelection(sport: Sport) {
        
    }
    
    func createActivityCellViewModel(sport: Sport) -> ActivityCellViewModel {
        ActivityCellViewModel(name: sport.name ?? "", id: sport.id, enableSelection: false)
    }
}
