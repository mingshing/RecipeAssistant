/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This type encapsulates the attributes of a recipe.
*/

import Foundation
import Intents

extension Recipe {
    
    public static var allRecipes: [Recipe] {
        return [
            Recipe(name: "Spicy Tomato Sauce",
                   iconImageName: "spicy_tomato_sauce",
                   servings: "6 cups",
                   time: "1 hour 20 minutes",
                   ingredients: [
                    "2 large onions, finely chopped",
                    "10 cloves garlic, minced",
                    "1 28oz can of peeled tomatoes",
                    "1 1/2 cup basil, chopped",
                    "2 tsp red crushed peppers",
                    "3 springs fresh thyme leaves, pulled off stem",
                    "1/4 cup olive oil",
                    "salt / freshly ground black pepper",
                    "1 tsp sugar"
                   ],
                   directions: [
                    "In a large pot, heat olive oil on medium heat.",
                    "Add minced garlic and sauté for a few seconds until fragrant.",
                    "Add chopped onions and cook until translucent (be sure not to burn or over-cook).",
                    "Add crushed red peppers and thyme leaves and cook for about 30 more seconds.",
                    "Add tomatoes and adjust heat to maintain a gentle simmer and cook for 1 hour.",
                    "The sauce will reduce by about 1/2 or until it has a thick consistency.",
                    "Add in the chopped basil and sugar and simmer for another 30 minutes.",
                    "Season with salt and freshly ground black pepper to taste.",
                    "Once the sauce is reduced and reaches desired consistency, " +
                    "use immediately or cool and store in fridge or freezer. "
                   ]),
            Recipe(name: "Chickpea Curry",
                   iconImageName: "chickpea_curry",
                   servings: "3",
                   time: "25 minutes",
                   ingredients: [
                    "2 medium onions, diced",
                    "1 bell pepper, seeded and diced",
                    "2 carrots, diced",
                    "2 tbsp olive oil",
                    "3 cloves garlic, chopped",
                    "1/4 cup lime juice",
                    "1-2 tsp curry paste",
                    "1 can coconut milk (1 can = 1.5 cups)",
                    "1 can chickpeas, drained and rinsed",
                    "1-2 tbsp soy sauce",
                    "2-3 medium tomato",
                    "1 cup basil, fresh",
                    "1 tsp maple syrup",
                    "1 tsp cilantro"
                   ],
                   directions: [
                    "Add oil, carrots, bell peppers, and onions into a large pan and cook " +
                    "on a low-medium heat until onions start to soften and turn clear, about 5 minutes.",
                    "Add garlic and cook for 1 minute.",
                    "Add curry paste and coconut milk, stirring until curry is dissolved.",
                    "Add chickpeas and soy sauce, and cook on a medium heat for 5 minutes, " +
                    "bringing the curry to a boil. If it starts to burn, reduce heat immediately.",
                    "Add the chopped tomatoes, chopped basil, lime juice, soy sauce and gently simmer the curry for another 2 minutes.",
                    "If desired, add a second tbsp soy sauce and the syrup or brown sugar. Give it another stir.",
                    "Garnish with cilantro and serve with lime wedges and rice."
                   ]
            ),
            Recipe(name: "香菇雞湯",
                   iconImageName: "test_recipe",
                   servings: "8 片",
                   time: "45 分鐘",
                   ingredients: [
                    "帶皮雞腿肉 500克（或 1 支）",
                    "油 10克",
                    "薑 10克",
                    "米酒 適量",
                    "水 適量",
                    "紅棗 10克",
                    "乾香菇 5 朵",
                    "枸杞 5 克",
                    "鹽 1 茶匙",
                    "湯鍋 1 個"
                   ],
                   directions: [
                    "乾香菇以熱水浸泡，放置於一旁",
                    "事先將開水煮沸，把帶皮雞腿川燙 30-60 秒去除雜質及血水，或至表面不紅就可以撈起（若雞腿較大塊，可以燙久一點），並將水倒掉",
                    "將香菇和薑切片",
                    "油和薑放入鍋中爆香",
                    "加入雞腿肉、香菇和紅棗，再加入水與米酒至淹過食材後，熬煮約 25 分鐘",
                    "加入鹽和枸杞，熬煮約 5 分鐘",
                    "熄火，燜 3-5 分鐘",
                    "完成"
                   ])
        ]
    }
    
    convenience init(name: String, iconImageName: String, servings: String, time: String, ingredients: [String], directions: [String]) {
        self.init(identifier: name, display: name, subtitle: nil, image: INImage(named: iconImageName))
        self.servings = servings
        self.time = time
        self.ingredients = ingredients
        self.directions = directions
        self.iconImageName = iconImageName
    }
    
}
