import UIKit

class AlertView {
  
  static func show(title: String?, message: String? = nil, in view: UIViewController) {
    let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    show(title: title, message: message, cancelAction: cancelAction, in: view)
  }
  
  static func show(title: String?,
                   message: String? = nil,
                   action: UIAlertAction? = nil,
                   cancelAction: UIAlertAction,
                   in view: UIViewController) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    if let action = action {
      alertController.addAction(action)
    }
    alertController.addAction(cancelAction)
    
    view.present(alertController, animated: true, completion: nil)
  }
}
