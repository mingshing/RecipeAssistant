/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view controller that displays the directions for a recipe.
*/

import UIKit
import Intents
import IntentsUI
import AVFoundation

class RecipeDirectionsViewController: UITableViewController, NextStepProviding, PreviousStepProviding, RepeatStepProviding {
    
    var recipe: Recipe!
    var currentStep: Int = 0 {
        didSet {
            guard let directions = recipe.directions else { return }
            guard currentStep > 0 && currentStep < directions.count else { return }
            self.readSentence(directions[currentStep - 1])
        }
    }
    
    // MARK: - View lifecycle
    internal var ttsManager = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAudioSession()
        currentStep = 1
        
        
        self.navigationController?.isToolbarHidden = false
        self.toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: {
                let button = INUIAddVoiceShortcutButton(style: .automaticOutline)
                button.shortcut = INShortcut(intent: {
                    let intent = NextDirectionsIntent()
                    intent.suggestedInvocationPhrase = "下一步"
                    return intent
                }())
                button.delegate = self
                return button
            }()),
            UIBarButtonItem(customView: {
                let button = INUIAddVoiceShortcutButton(style: .automaticOutline)
                button.shortcut = INShortcut(intent: {
                    let intent = PreviousDirectionsIntent()
                    intent.suggestedInvocationPhrase = "上一步"
                    return intent
                }())
                button.delegate = self
                return button
            }()),
            UIBarButtonItem(customView: {
                let button = INUIAddVoiceShortcutButton(style: .automaticOutline)
                button.shortcut = INShortcut(intent: {
                    let intent = RepeatDirectionsIntent()
                    intent.suggestedInvocationPhrase = "重複這一步"
                    return intent
                }())
                button.delegate = self
                return button
            }()),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        ]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppIntentHandler.shared.currentIntentHandler = intentHandler
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
        UIApplication.shared.isIdleTimerDisabled = false
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
    
    @IBAction func nextStepBarButtonItemPressed(sender: UIBarButtonItem) {
        nextStep(recipe: recipe)
    }
    
    // MARK: - NextStepProviding
    
    lazy var intentHandler = IntentHandler(nextStepProvider: self, previousStepProvider: self, currentRecipe: recipe)
    
    @discardableResult
    func nextStep(recipe: Recipe) -> NextDirectionsIntentResponse {
        guard let directions = self.recipe.directions else {
            return NextDirectionsIntentResponse(code: .failure, userActivity: nil)
        }
        currentStep = currentStep >= directions.count ? 1 : currentStep + 1
        self.navigationItem.rightBarButtonItem?.title = (currentStep >= directions.count ? "Start Over" : "Next Step")
        tableView.reloadSections([0], with: .automatic)
        return NextDirectionsIntentResponse.showDirections(step: NSNumber(value: currentStep),
                                                           directions: directions[currentStep - 1])
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
    
    private func readSentence(_ str: String) {
        let seconds = 4.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            let utterance = AVSpeechUtterance(string: str)
            utterance.voice = AVSpeechSynthesisVoice(language: "zh-Hant")
            self.ttsManager.speak(utterance)
        }
    }
    
}

extension RecipeDirectionsViewController {
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RecipeDirectionsCell.identifier, for: indexPath)
        if let cell = cell as? RecipeDirectionsCell {
            cell.stepLabel.text = "\(currentStep)"
            cell.directionsLabel.text = recipe.directions?[currentStep - 1]
        }
        return cell
    }
}

extension RecipeDirectionsViewController {
    
    // MARK: - Table delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let directions = recipe.directions else {
            return nil
        }
        return "Step \(currentStep) of \(directions.count)"
    }

}

extension RecipeDirectionsViewController: INUIAddVoiceShortcutButtonDelegate {
    
    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        addVoiceShortcutViewController.delegate = self
        present(addVoiceShortcutViewController, animated: true, completion: nil)
    }
    
    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        editVoiceShortcutViewController.delegate = self
        present(editVoiceShortcutViewController, animated: true, completion: nil)
    }
    
}

extension RecipeDirectionsViewController: INUIAddVoiceShortcutViewControllerDelegate {
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController,
                                        didFinishWith voiceShortcut: INVoiceShortcut?,
                                        error: Error?) {
        if let error = error as NSError? {
            print("Error: \(error)")
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension RecipeDirectionsViewController: INUIEditVoiceShortcutViewControllerDelegate {
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController,
                                         didUpdate voiceShortcut: INVoiceShortcut?,
                                         error: Error?) {
        if let error = error as NSError? {
            print("Error: \(error)")
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController,
                                         didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

class RecipeDirectionsCell: UITableViewCell {
    
    static let identifier = "RecipeDirectionsCell"
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var directionsLabel: UILabel!
    
}
