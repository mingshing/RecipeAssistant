/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view controller that displays attributes of a recipe, such as the necessary ingredients.
*/

import UIKit
import Intents

class RecipeDetailViewController: UITableViewController, StartCookingProviding {
    
    var recipe: Recipe!
    
    // MARK: - Sections
    
    private enum SectionType {
        case servings, time, ingredients, directions
    }
    
    private typealias SectionModel = (sectionType: SectionType, title: String, rowContent: [String])
    private lazy var sectionData: [SectionModel] = [
        SectionModel(sectionType: .servings, title: "Servings", rowContent: [recipe.servings ?? ""]),
        SectionModel(sectionType: .time, title: "Time", rowContent: [recipe.time ?? ""]),
        SectionModel(sectionType: .ingredients, title: "Ingredients", rowContent: recipe.ingredients ?? []),
        SectionModel(sectionType: .directions, title: "Steps", rowContent: recipe.directions ?? [])
    ]
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = recipe.displayString
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppIntentHandler.shared.currentIntentHandler = intentHandler
        
        configHeaderView()
    }
    
    private func configHeaderView() {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 58))
        let actionButton: UIButton = {
            let button = UIButton()
            button.setTitle("開始", for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.layer.borderColor = UIColor.darkGray.cgColor
            button.layer.borderWidth = 2
            button.layer.cornerRadius = 8
            button.addTarget(self, action: #selector(tapStart), for: .touchUpInside)
            return button
        }()
        headerView.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
            make.height.equalTo(48)
        }
        self.tableView.tableHeaderView = headerView
    }
    
    
    @objc func tapStart() {
        
        print("tap start")
        let directionsVC = RecipeDirectionsViewController(recipe: recipe)
        //bookIntroVC.hidesBottomBarWhenPushed = true
        show(directionsVC, sender: self)
    }

    
    
    // MARK: - NextStepProviding
    
    lazy var intentHandler = IntentHandler()
    
    func startCooking() -> StartIntentResponse {
        tapStart()
        return StartIntentResponse(code: .success, userActivity: nil)
    }
/*
    func nextStep(recipe: Recipe) -> NextDirectionsIntentResponse {
        guard let directions = recipe.directions, let firstDirection = directions.first else {
            return NextDirectionsIntentResponse(code: .failure, userActivity: nil)
        }
        performSegue(withIdentifier: "Directions", sender: recipe)
        return NextDirectionsIntentResponse(code: .success, userActivity: nil)
    }
*/
}

extension RecipeDetailViewController {
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionData[section].rowContent.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        cell.textLabel?.text = sectionData[indexPath.section].rowContent[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}

extension RecipeDetailViewController {
    
    // MARK: - Table delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionData[section].title
    }

}
