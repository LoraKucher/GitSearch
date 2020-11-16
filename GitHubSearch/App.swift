import UIKit

final class App {
    static let shared = App()
    
    func startInterface(in window: UIWindow) {
        
        let searchViewModel = SearchViewModel(dependencies: SearchViewModel.Dependencies(api: API()))
        let navigationSearchViewController = UIStoryboard.main.searchViewController
        let searchViewController = navigationSearchViewController.viewControllers.first as? SearchViewController
        searchViewController?.viewModel = searchViewModel
        
        let historyViewModel = HistoryViewModel(dependencies: HistoryViewModel.Dependencies(api: StorageRepository()))
        let navigationHistoryViewController = UIStoryboard.main.historyViewController
        let historyViewController = navigationHistoryViewController.viewControllers.first as? HistoryViewController
        historyViewController?.viewModel = historyViewModel
        
        
        let tabBarController = UITabBarController()
        tabBarController.tabBar.barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tabBarController.tabBar.tintColor = .black
        
        navigationSearchViewController.tabBarItem = UITabBarItem(title: "Search", image: nil, selectedImage: nil)
        navigationHistoryViewController.tabBarItem = UITabBarItem(title: "History", image: nil, selectedImage: nil)
        
        tabBarController.viewControllers = [
            navigationSearchViewController,
            navigationHistoryViewController
        ]
        
        let authViewModel = AuthViewModel(dependencies: AuthViewModel.Dependencies(api: API()))
        let navigationAuthViewController = UIStoryboard.main.authViewController
        let authViewController = navigationAuthViewController.viewControllers.first as? AuthViewController
        authViewController?.viewModel = authViewModel
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        tabBarController.present(navigationAuthViewController, animated: true, completion: nil)
    }
}
