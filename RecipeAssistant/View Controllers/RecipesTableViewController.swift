/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view controller that displays the contents of the `RecipeBook`.
*/

import UIKit
import Intents
import IntentsUI

class RecipesTableViewController: UITableViewController, NextStepProviding {

    lazy var intentHandler = IntentHandler()

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configFooterView()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppIntentHandler.shared.currentIntentHandler = intentHandler
    }
    
    private func configFooterView() {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        let nextButton = INUIAddVoiceShortcutButton(style: .automaticOutline)
        let nextIntent = INShortcut(intent: {
            let intent = NextDirectionsIntent()
            intent.suggestedInvocationPhrase = "下一步"
            return intent
        }())
        nextButton.shortcut = nextIntent
        nextButton.delegate = self
        
        let prevIntent = INShortcut(intent: {
            let intent = PreviousDirectionsIntent()
            intent.suggestedInvocationPhrase = "上一步"
            return intent
        }())
        let prevButton = INUIAddVoiceShortcutButton(style: .automaticOutline)
        prevButton.shortcut = prevIntent
        prevButton.delegate = self
        
        let repeatIntent = INShortcut(intent: {
            let intent = RepeatDirectionsIntent()
            intent.suggestedInvocationPhrase = "重複這一步"
            return intent
        }())
        let repeatButton = INUIAddVoiceShortcutButton(style: .automaticOutline)
        repeatButton.shortcut = repeatIntent
        repeatButton.delegate = self
        
        let startIntent = INShortcut(intent: {
            let intent = StartIntent()
            intent.suggestedInvocationPhrase = "開始煮菜"
            return intent
        }())
        let startButton = INUIAddVoiceShortcutButton(style: .automaticOutline)
        startButton.shortcut = startIntent
        startButton.delegate = self
        
        let ingredientIntent = INShortcut(intent: {
            let intent = IngredientIntent()
            intent.suggestedInvocationPhrase = "食材數量"
            return intent
        }())
        let gredientButton = INUIAddVoiceShortcutButton(style: .automaticOutline)
        gredientButton.shortcut = ingredientIntent
        gredientButton.delegate = self
        
        let siriButtonContainer: UIStackView = {
            let container = UIStackView()
            container.axis = .horizontal
            container.alignment = .center
            container.spacing = 10
            container.distribution = .fillEqually
            container.isLayoutMarginsRelativeArrangement = true
            
            return container
        }()
        
        footerView.addSubview(siriButtonContainer)
        siriButtonContainer.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview()
        }
        siriButtonContainer.addArrangedSubview(nextButton)
        siriButtonContainer.addArrangedSubview(prevButton)
        siriButtonContainer.addArrangedSubview(repeatButton)
        siriButtonContainer.addArrangedSubview(startButton)
        siriButtonContainer.addArrangedSubview(gredientButton)
        self.tableView.tableFooterView = footerView
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "Recipe Details" else {
            return
        }
        
        var recipe = sender as? Recipe

        if sender is UITableViewCell,
            let selectedIndexPaths = tableView.indexPathsForSelectedRows,
            let selectedIndexPath = selectedIndexPaths.first {
            recipe = Recipe.allRecipes[selectedIndexPath.row]
        }
        
        if let destination = segue.destination as? RecipeDetailViewController, let recipe = recipe {
            destination.recipe = recipe
        }
    }
    
    // MARK: - NextStepProviding
    
    //lazy var intentHandler = IntentHandler(nextStepProvider: self)
    func nextStep(recipe: Recipe) -> NextDirectionsIntentResponse {
        return NextDirectionsIntentResponse(code: .success, userActivity: nil)
    }
}

extension RecipesTableViewController {
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Recipe.allRecipes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeDetailCell", for: indexPath)
        let recipe = Recipe.allRecipes[indexPath.row]
        if let iconImageName = recipe.iconImageName {
            cell.imageView?.image = UIImage(named: iconImageName)
        }
        cell.imageView?.layer.cornerRadius = 8
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.text = recipe.displayString
        cell.detailTextLabel?.text = nil
        return cell
    }
}

extension RecipesTableViewController: INUIAddVoiceShortcutButtonDelegate {
    
    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        addVoiceShortcutViewController.delegate = self
        present(addVoiceShortcutViewController, animated: true, completion: nil)
    }
    
    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        editVoiceShortcutViewController.delegate = self
        present(editVoiceShortcutViewController, animated: true, completion: nil)
    }
    
}

extension RecipesTableViewController: INUIAddVoiceShortcutViewControllerDelegate {
    
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

extension RecipesTableViewController: INUIEditVoiceShortcutViewControllerDelegate {
    
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
