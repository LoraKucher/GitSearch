import UIKit

extension UIStoryboard {
    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
}

extension UIStoryboard {
    
    var authViewController: UINavigationController {
        guard let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "AuthViewController") as? UINavigationController else {
            fatalError("AuthViewController couldn't be found in Storyboard file")
        }
        return vc
    }
    var searchViewController: UINavigationController {
        guard let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "SearchViewController") as? UINavigationController else {
            fatalError("SearchViewController couldn't be found in Storyboard file")
        }
        return vc
    }
    
    var historyViewController: UINavigationController {
        guard let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "HistoryViewController") as? UINavigationController else {
            fatalError("HistoryViewController couldn't be found in Storyboard file")
        }
        return vc
    }
}
