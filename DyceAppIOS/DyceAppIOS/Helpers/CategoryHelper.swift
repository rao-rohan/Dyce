import Foundation
import UIKit

//chooses the appropriate background color for a specified category

struct CategoryHelper {
    func colorChooser(_ category: String) -> UIColor {
        var color: UIColor?
        switch(category) {
        case "Travel":
            color = UIColor.flatRed
            break
        case "Entertainment":
            color = UIColor.flatOrange
            break
        case "Meetup":
            color = UIColor.flatYellow
            break
        case "Listings":
            color = UIColor.flatGreen
            break
        case "Recommendations":
            color = UIColor.flatSkyBlue
            break
        case "Other":
            color = UIColor.flatMagenta
            break
        default:
            color = UIColor.flatBlack
        }
        return color!
    }
}
