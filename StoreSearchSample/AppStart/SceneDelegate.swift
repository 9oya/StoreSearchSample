//
//  SceneDelegate.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = rootViewController()
        window?.makeKeyAndVisible()
    }

}

extension SceneDelegate {
    
    private func rootViewController() -> UIViewController {
        let vc = SearchViewController(nibName: "SearchViewController",
                                      bundle: nil)
        let nc = UINavigationController(rootViewController: vc)
        nc.tabBarItem.image = {
            let config = UIImage
                .SymbolConfiguration(pointSize: 15.0,
                                     weight: .regular,
                                     scale: .large)
            return UIImage(systemName: "magnifyingglass",
                           withConfiguration: config)
        }()
        nc.tabBarItem.title = "검색"
        
        let vm = SearchViewModel(title: "검색",
                                 placeHolder: "게임, 앱, 스토리 등",
                                 provider: ServiceProvider.resolve())
        vc.viewModel = vm
        
        let tc = CustomTabbarController()
        tc.viewControllers = [nc]
        return tc
    }
    
}
