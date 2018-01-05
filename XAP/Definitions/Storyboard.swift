// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation
import UIKit

protocol StoryboardSceneType {
  static var storyboardName : String { get }
}

extension StoryboardSceneType {
  static func storyboard() -> UIStoryboard {
    return UIStoryboard(name: self.storyboardName, bundle: nil)
  }

  static func initialViewController() -> UIViewController {
    return Self.storyboard().instantiateInitialViewController()!
  }
}

extension StoryboardSceneType where Self: RawRepresentable, Self.RawValue == String {
  func viewController() -> UIViewController {
    return Self.storyboard().instantiateViewController(withIdentifier:self.rawValue)
  }
  static func viewController(identifier: Self) -> UIViewController {
    return identifier.viewController()
  }
}

protocol StoryboardSegueType : RawRepresentable { }

extension UIViewController {
  func performSegue<S : StoryboardSegueType>(_ segue: S, sender: AnyObject? = nil) where S.RawValue == String {
    performSegue(withIdentifier: segue.rawValue, sender: sender)
  }
}

struct XAPStoryboard {
  enum bulletinScene : String, StoryboardSceneType {
    static let storyboardName = "BulletinScene"

    case bulletin = "Bulletin"
    static func bulletinVC() -> BulletinViewController {
      return bulletinScene.bulletin.viewController() as! BulletinViewController
    }

    case bulletinDetail = "BulletinDetail"
    static func bulletinDetailVC() -> BulletinDetailViewController {
      return bulletinScene.bulletinDetail.viewController() as! BulletinDetailViewController
    }
  }
  enum chatScene : String, StoryboardSceneType {
    static let storyboardName = "ChatScene"

    case chatList = "ChatList"
    static func chatListVC() -> ChatListViewController {
      return chatScene.chatList.viewController() as! ChatListViewController
    }
  }
  enum helpScene : String, StoryboardSceneType {
    static let storyboardName = "HelpScene"

    case help = "Help"
    static func helpVC() -> HelpViewController {
      return helpScene.help.viewController() as! HelpViewController
    }

    case helpContactEnglish = "HelpContactEnglish"
    static func helpContactEnglishVC() -> UIViewController {
      return helpScene.helpContactEnglish.viewController()
    }

    case helpContactSpanish = "HelpContactSpanish"
    static func helpContactSpanishVC() -> UIViewController {
      return helpScene.helpContactSpanish.viewController()
    }
  }
  enum homeScene : String, StoryboardSceneType {
    static let storyboardName = "HomeScene"

    case choosingReason = "ChoosingReason"
    static func choosingReasonVC() -> ChoosingReasonViewController {
      return homeScene.choosingReason.viewController() as! ChoosingReasonViewController
    }

    case home = "Home"
    static func homeVC() -> HomeViewController {
      return homeScene.home.viewController() as! HomeViewController
    }

    case itemDetail = "ItemDetail"
    static func itemDetailVC() -> ItemDetailViewController {
      return homeScene.itemDetail.viewController() as! ItemDetailViewController
    }

    case mainNavigation = "MainNavigation"
    static func mainNavigationVC() -> MainNavigationViewController {
      return homeScene.mainNavigation.viewController() as! MainNavigationViewController
    }

    case sideMenu = "SideMenu"
    static func sideMenuVC() -> SideMenuVIewController {
      return homeScene.sideMenu.viewController() as! SideMenuVIewController
    }
  }
  enum inviteScene : String, StoryboardSceneType {
    static let storyboardName = "InviteScene"

    case inviteFriend = "InviteFriend"
    static func inviteFriendVC() -> InviteFriendViewController {
      return inviteScene.inviteFriend.viewController() as! InviteFriendViewController
    }
  }
  enum landingScene : String, StoryboardSceneType {
    static let storyboardName = "LandingScene"

    case forgotPassword = "ForgotPassword"
    static func forgotPasswordVC() -> ForgotPasswordViewController {
      return landingScene.forgotPassword.viewController() as! ForgotPasswordViewController
    }

    case landing = "Landing"
    static func landingVC() -> LandingViewController {
      return landingScene.landing.viewController() as! LandingViewController
    }

    case signIn = "SignIn"
    static func signInVC() -> SignInViewController {
      return landingScene.signIn.viewController() as! SignInViewController
    }
  }
  enum launchScreen : StoryboardSceneType {
    static let storyboardName = "LaunchScreen"
  }
  enum mediaPicker : String, StoryboardSceneType {
    static let storyboardName = "MediaPicker"

    case mediaPostScreen = "MediaPostScreen"
    static func mediaPostScreenVC() -> UIViewController {
      return mediaPicker.mediaPostScreen.viewController()
    }
  }
  enum postScene : String, StoryboardSceneType {
    static let storyboardName = "PostScene"

    case postItem = "PostItem"
    static func postItemVC() -> PostItemViewController {
      return postScene.postItem.viewController() as! PostItemViewController
    }

    case postItemName = "PostItemName"
    static func postItemNameVC() -> PostItemNameViewController {
      return postScene.postItemName.viewController() as! PostItemNameViewController
    }
  }
  enum profileScene : String, StoryboardSceneType {
    static let storyboardName = "ProfileScene"

    case editProfile = "EditProfile"
    static func editProfileVC() -> EditProfileViewController {
      return profileScene.editProfile.viewController() as! EditProfileViewController
    }

    case facebookVerify = "FacebookVerify"
    static func facebookVerifyVC() -> FacebookVerifyViewController {
      return profileScene.facebookVerify.viewController() as! FacebookVerifyViewController
    }

    case favoriteCategory = "FavoriteCategory"
    static func favoriteCategoryVC() -> FavoriteCategoryViewController {
      return profileScene.favoriteCategory.viewController() as! FavoriteCategoryViewController
    }

    case googlePlusVerify = "GooglePlusVerify"
    static func googlePlusVerifyVC() -> GooglePlusVerifyViewController {
      return profileScene.googlePlusVerify.viewController() as! GooglePlusVerifyViewController
    }

    case notificationSetting = "NotificationSetting"
    static func notificationSettingVC() -> NotificationSettingViewController {
      return profileScene.notificationSetting.viewController() as! NotificationSettingViewController
    }

    case phoneVerify = "PhoneVerify"
    static func phoneVerifyVC() -> PhoneVerifyViewController {
      return profileScene.phoneVerify.viewController() as! PhoneVerifyViewController
    }

    case profile = "Profile"
    static func profileVC() -> ProfileViewController {
      return profileScene.profile.viewController() as! ProfileViewController
    }

    case profileItemDetail = "ProfileItemDetail"
    static func profileItemDetailVC() -> ProfileItemDetailViewController {
      return profileScene.profileItemDetail.viewController() as! ProfileItemDetailViewController
    }

    case verifying = "Verifying"
    static func verifyingVC() -> VerifyingViewController {
      return profileScene.verifying.viewController() as! VerifyingViewController
    }
  }
  enum searchScene : String, StoryboardSceneType {
    static let storyboardName = "SearchScene"

    case search = "Search"
    static func searchVC() -> SearchViewController {
      return searchScene.search.viewController() as! SearchViewController
    }

    case searchResult = "SearchResult"
    static func searchResultVC() -> SearchResultViewController {
      return searchScene.searchResult.viewController() as! SearchResultViewController
    }

    case selectSortBy = "SelectSortBy"
    static func selectSortByVC() -> SelectSortByViewController {
      return searchScene.selectSortBy.viewController() as! SelectSortByViewController
    }

    case sortByListTable = "SortByListTable"
    static func sortByListTableVC() -> SortByListTableViewController {
      return searchScene.sortByListTable.viewController() as! SortByListTableViewController
    }
  }
}

struct XAPStoryboardSegue {
  enum inviteScene : String, StoryboardSegueType {
    case segueInviteContainSubViewcontroller = "segue_invite_contain_sub_viewcontroller"
  }
  enum profileScene : String, StoryboardSegueType {
    case segueToCategorySettings = "segue_to_category_settings"
    case segueToFacebookVerification = "segue_to_facebook_verification"
    case segueToGoogleVerification = "segue_to_google_verification"
    case segueToNotificationSettings = "segue_to_notification_settings"
    case segueToPhoneVerification = "segue_to_phone_verification"
    case segueToVerificationSettings = "segue_to_verification_settings"
  }
  enum searchScene : String, StoryboardSegueType {
    case embededSortByListSegue = "EmbededSortByListSegue"
  }
}
