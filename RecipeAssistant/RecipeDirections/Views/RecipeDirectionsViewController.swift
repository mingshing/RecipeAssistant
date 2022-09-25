/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view controller that displays the directions for a recipe.
*/

import UIKit
import SnapKit
import Intents
import IntentsUI
import AVFoundation

class RecipeDirectionsViewController: UIViewController, NextStepProviding, PreviousStepProviding, RepeatStepProviding, CheckIngredientProviding {
    
    private lazy var tableView: UITableView = { [weak self] in
        let table = UITableView(frame: CGRect.zero, style: .insetGrouped)
        table.separatorStyle = .none
        table.register(
            RecipeDirectionsCell.self,
            forCellReuseIdentifier: String(describing: RecipeDirectionsCell.self)
        )
        table.delegate = self
        table.dataSource = self
    
        return table
    }()
    
    var recipe: Recipe!
    var currentStep: Int = 0 {
        didSet {
            guard let directions = recipe.directions else { return }
            guard currentStep > 0 && currentStep < directions.count else { return }
            self.readSentence(directions[currentStep - 1])
        }
    }
    private var startStep: Int
    init(recipe: Recipe, startStep: Int = 1) {
        self.recipe = recipe
        self.startStep = startStep
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - View lifecycle
    internal var ttsManager = AVSpeechSynthesizer()
    lazy var intentHandler = IntentHandler(currentRecipe: recipe)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAudioSession()
        currentStep = startStep
        self.navigationController?.isToolbarHidden = false
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppIntentHandler.shared.currentIntentHandler = intentHandler
        UIApplication.shared.isIdleTimerDisabled = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next Step", style: .plain, target: self, action: #selector(nextStepBarButtonItemPressed))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        ttsManager.stopSpeaking(at: .immediate)
    }
    
    private func setupView() {
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    
    private func setAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
            NSLog("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            NSLog("Session is Active")
        } catch {
            NSLog("ERROR: CANNOT PLAY MUSIC IN BACKGROUND. Message from code: \"\(error)\"")
        }
    }
    
    // MARK: - Actions
    
    @objc func nextStepBarButtonItemPressed(sender: UIBarButtonItem) {
        nextStep(recipe: recipe)
    }
    
    @discardableResult
    func nextStep(recipe: Recipe) -> NextDirectionsIntentResponse {
        guard let directions = self.recipe.directions else {
            return NextDirectionsIntentResponse(code: .failure, userActivity: nil)
        }
        currentStep = currentStep >= directions.count ? 1 : currentStep + 1
        self.navigationItem.rightBarButtonItem?.title = (currentStep >= directions.count ? "Start Over" : "Next Step")
        tableView.reloadSections([0], with: .automatic)
        return NextDirectionsIntentResponse(code: .success, userActivity: nil)
    }
    
    @discardableResult
    func previousStep(recipe: Recipe) -> PreviousDirectionsIntentResponse {
        guard let _ = self.recipe.directions else {
            return PreviousDirectionsIntentResponse(code: .failure, userActivity: nil)
        }
        currentStep = currentStep == 1 ? 1 : currentStep - 1
        
        tableView.reloadSections([0], with: .automatic)
        
        return PreviousDirectionsIntentResponse(code: .success, userActivity: nil)
    }
    
    @discardableResult
    func repeatStep(recipe: Recipe) -> RepeatDirectionsIntentResponse {
        guard let directions = self.recipe.directions else {
            return RepeatDirectionsIntentResponse(code: .failure, userActivity: nil)
        }
        readSentence(directions[currentStep - 1])
        
        return RepeatDirectionsIntentResponse(code: .success, userActivity: nil)
    }
    
    @discardableResult
    func checkIngredient() -> IngredientIntentResponse {
        guard let ingredients = self.recipe.directionDetails else {
            return IngredientIntentResponse(code: .failure, userActivity: nil)
        }
        readSentence(ingredients[currentStep - 1])
        
        return IngredientIntentResponse(code: .success, userActivity: nil)
    }
    
    private func readSentence(_ str: String) {
        let seconds = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            let utterance = AVSpeechUtterance(string: str)
            utterance.voice = AVSpeechSynthesisVoice(language: "zh-Hant")
            self.ttsManager.stopSpeaking(at: .immediate)
            self.ttsManager.speak(utterance)
        }
    }
    
}

extension RecipeDirectionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RecipeDirectionsCell.self), for: indexPath)
        if let cell = cell as? RecipeDirectionsCell {
            //cell.stepLabel.text = "\(currentStep)"
            cell.directionsLabel.text = recipe.directions?[currentStep - 1]
            if let directionDetail = recipe.directionDetails?[currentStep - 1],
               !directionDetail.isEmpty{
                cell.requireIngredientLabel.text = "食材:\t" + directionDetail
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let directions = recipe.directions else {
            return nil
        }
        return "Step \(currentStep) of \(directions.count)"
    }
}
