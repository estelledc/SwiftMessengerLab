import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let environment = AppEnvironment.makeDefault()
        let messenger = ConversationListViewController(environment: environment)
        let messengerNavigation = UINavigationController(rootViewController: messenger)
        messengerNavigation.tabBarItem = UITabBarItem(
            title: "Messenger",
            image: UIImage(systemName: "message"),
            selectedImage: UIImage(systemName: "message.fill")
        )

        let learn = LearningCatalogViewController(progressStore: .shared)
        let learnNavigation = UINavigationController(rootViewController: learn)
        learnNavigation.tabBarItem = UITabBarItem(
            title: "Learn",
            image: UIImage(systemName: "book"),
            selectedImage: UIImage(systemName: "book.fill")
        )

        let tabs = UITabBarController()
        tabs.viewControllers = [messengerNavigation, learnNavigation]

        let launchArguments = ProcessInfo.processInfo.arguments
        if launchArguments.contains("--showcase-learn") {
            tabs.selectedIndex = 1
        } else if launchArguments.contains("--showcase-uiview"),
                  let lesson = LearningCatalog.lessons.first(where: { $0.id == 11 }),
                  let experiment = LearningCatalog.primaryExperiment(for: lesson) {
            tabs.selectedIndex = 1
            learnNavigation.pushViewController(
                InteractiveExperimentViewController(
                    lesson: lesson,
                    experiment: experiment,
                    progressStore: .shared
                ),
                animated: false
            )
        }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tabs
        window.makeKeyAndVisible()
        // The inbox assigns its large navigation title during view loading.
        // Re-assert the shorter tab label after that lifecycle pass.
        messengerNavigation.tabBarItem.title = "Messenger"
        learnNavigation.tabBarItem.title = "Learn"
        self.window = window

        environment.log.record(.lifecycle, "Scene connected -> Messenger + Learn tabs")
    }
}
