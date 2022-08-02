/*
See LICENSE folder for this sample’s licensing information.

Abstract:
An intent handler for `ShowDirectionsIntent` that returns recipes and the next set of directions inside a recipe.
*/

import UIKit
import Intents

class IntentHandler: NSObject, NextDirectionsIntentHandling, PreviousDirectionsIntentHandling, RepeatDirectionsIntentHandling {

    
    var currentRecipe: Recipe?
    weak var nextStepProvider: NextStepProviding?
    weak var previousStepProvider: PreviousStepProviding?
    weak var repeatStepProvider: RepeatStepProviding?
    
    init(
        nextStepProvider: NextStepProviding? = nil,
        previousStepProvider: PreviousStepProviding? = nil,
        repeatStepProvider: RepeatStepProviding? = nil,
        currentRecipe: Recipe? = nil
    ) {
        self.nextStepProvider = nextStepProvider
        self.previousStepProvider = previousStepProvider
        self.repeatStepProvider = repeatStepProvider
        self.currentRecipe = currentRecipe
    }
    
    // MARK: - ShowDirectionsIntentHandling
    
    func provideRecipeOptionsCollection(for intent: NextDirectionsIntent, with completion: @escaping (INObjectCollection<Recipe>?, Error?) -> Void) {
        completion(INObjectCollection(items: Recipe.allRecipes), nil)
    }
    
    func provideRecipeOptionsCollection(for intent: PreviousDirectionsIntent, with completion: @escaping (INObjectCollection<Recipe>?, Error?) -> Void) {
        completion(INObjectCollection(items: Recipe.allRecipes), nil)
    }
    
    func provideRecipeOptionsCollection(for intent: RepeatDirectionsIntent, with completion: @escaping (INObjectCollection<Recipe>?, Error?) -> Void) {
        completion(INObjectCollection(items: Recipe.allRecipes), nil)
    }
    
    
    func resolveRecipe(for intent: NextDirectionsIntent, with completion: @escaping (RecipeResolutionResult) -> Void) {
        guard let recipe = recipe(for: intent) else {
            completion(RecipeResolutionResult.disambiguation(with: Recipe.allRecipes))
            return
        }
        completion(RecipeResolutionResult.success(with: recipe))
    }
    
    func resolveRecipe(for intent: PreviousDirectionsIntent, with completion: @escaping (RecipeResolutionResult) -> Void) {
        guard let recipe = recipe(for: intent) else {
            completion(RecipeResolutionResult.disambiguation(with: Recipe.allRecipes))
            return
        }
        completion(RecipeResolutionResult.success(with: recipe))
    }
    
    func resolveRecipe(for intent: RepeatDirectionsIntent, with completion: @escaping (RecipeResolutionResult) -> Void) {
        guard let recipe = recipe(for: intent) else {
            completion(RecipeResolutionResult.disambiguation(with: Recipe.allRecipes))
            return
        }
        completion(RecipeResolutionResult.success(with: recipe))
    }
    
    
    func handle(intent: NextDirectionsIntent, completion: @escaping (NextDirectionsIntentResponse) -> Void) {
        guard let recipe = recipe(for: intent),
              let nextStepProvider = self.nextStepProvider,
              UIApplication.shared.applicationState != .background else {
            
            completion(NextDirectionsIntentResponse(code: .continueInApp, userActivity: nil))
            return
        }
        completion(nextStepProvider.nextStep(recipe: recipe))
    }
    
    func handle(intent: PreviousDirectionsIntent, completion: @escaping (PreviousDirectionsIntentResponse) -> Void) {
        guard let recipe = recipe(for: intent),
              let previousStepProvider = self.previousStepProvider,
              UIApplication.shared.applicationState != .background else {
            
            completion(PreviousDirectionsIntentResponse(code: .continueInApp, userActivity: nil))
            return
        }
        completion(previousStepProvider.previousStep(recipe: recipe))
    }
    
    func handle(intent: RepeatDirectionsIntent, completion: @escaping (RepeatDirectionsIntentResponse) -> Void) {
        guard let recipe = recipe(for: intent),
              let repeatStepProvider = self.repeatStepProvider,
              UIApplication.shared.applicationState != .background else {
            
            completion(RepeatDirectionsIntentResponse(code: .continueInApp, userActivity: nil))
            return
        }
        completion(repeatStepProvider.repeatStep(recipe: recipe))
    }
    
    
    private func recipe(for intent: NextDirectionsIntent) -> Recipe? {
        return currentRecipe != nil ? currentRecipe : intent.recipe
    }
    
    private func recipe(for intent: PreviousDirectionsIntent) -> Recipe? {
        return currentRecipe != nil ? currentRecipe : intent.recipe
    }
    
    private func recipe(for intent: RepeatDirectionsIntent) -> Recipe? {
        return currentRecipe != nil ? currentRecipe : intent.recipe
    }
}

/// All of the view controllers in this app use this protocol to respond to voice commands when they're frontmost.
protocol NextStepProviding: NSObject {
    
    /// The intent handler object processes resolve, confirm, and handle phases.
    var intentHandler: IntentHandler { get }
    
    /// When the intent handler is ready to advance to the next step, the app calls the `nextStep` method.
    @discardableResult
    func nextStep(recipe: Recipe) -> NextDirectionsIntentResponse
    
}

protocol PreviousStepProviding: NSObject {
    
    /// The intent handler object processes resolve, confirm, and handle phases.
    var intentHandler: IntentHandler { get }
    
    /// When the intent handler is ready to advance to the next step, the app calls the `nextStep` method.
    @discardableResult
    func previousStep(recipe: Recipe) -> PreviousDirectionsIntentResponse
    
}

protocol RepeatStepProviding: NSObject {
    
    /// The intent handler object processes resolve, confirm, and handle phases.
    var intentHandler: IntentHandler { get }
    
    @discardableResult
    func repeatStep(recipe: Recipe) -> RepeatDirectionsIntentResponse
    
}
