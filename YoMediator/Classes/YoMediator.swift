import UIKit

//MARK: 单利
public class YoMediator {
    public static let shared = YoMediator()
    private init(){
        //保证单例调用
    }
}
//MARK:  反射 objc
extension YoMediator {
    /*
     反射->init->视图对象
     */
    @discardableResult
    public func initViewCtl(_ viewCtlName: String, moduleName: String? = nil, params: [String : Any]? = nil) -> UIViewController? {
        var  nameSpace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        print(nameSpace)
        if let name = moduleName {
            nameSpace = name
        }
        let className = "\(nameSpace).\(viewCtlName)"
        let cls: AnyClass? = NSClassFromString(className)
        guard let viewCtlClass = cls as? UIViewController.Type  else {
            return nil
        }
        let viewCtl = viewCtlClass.init()
        setObjectParams(obj: viewCtl, params: params)
        return viewCtl
    }
    /*
      反射obj -> init (继承NSObject)
     */
    @discardableResult
    public func initObjc(_ objcName: String, moduleName: String? = nil,params: [String : Any]? = nil) -> NSObject? {
        var nameSpace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        if let name = moduleName {
            nameSpace = name
        }
        let className =   "\(nameSpace).\(objcName)"
        let cls: AnyClass? = NSClassFromString(className)
        guard let objcClass = cls as? NSObject.Type else {
            return nil
        }
        let objc = objcClass.init()
        setObjectParams(obj: objc, params: params)
        return objc
    }
}
//MARK: 检查属性
extension YoMediator {
    //MARK: 判断属性是否存在
    private func getTypeOfProperty( name:String, obj: AnyObject ) -> Bool{
        //obj是实例(对象)，如果是类，则无法获取其属性
        let mirror = Mirror(reflecting: obj)
        let superMirror = Mirror(reflecting: obj).superclassMirror
        for (key, _) in mirror.children {
            if key == name {
                return true
            }
        }
        guard let superMirror = superMirror else {
            return false
        }
        for (key, _) in superMirror.children {
            if key == name {
                return true
            }
        }
        return false
    }
    //MARK: 属性赋值 KVC - obj: 目标对象
    private func setObjectParams(obj: AnyObject, params: [String : Any]?) {
        if let params = params {
            for (key, value) in params {
                if getTypeOfProperty(name: key, obj: obj){
                    obj.setValue(value, forKey: key)
                }
            }
        }
    }
}
//MARK:  路由跳转
extension YoMediator {
    // 1.push
    public func push(_ viewCtlName: String, moduleName: String? = nil,fromViewCtl: UIViewController? = nil, params: [String: Any]? = nil, animated: Bool = true) {
        guard let viewCtl = initViewCtl(viewCtlName, moduleName: moduleName, params: params) else {
            return
         }
        pushViewCtl(animated: animated, viewCtl: viewCtl, fromViewCtl: fromViewCtl)
    }
    //2.present
    public func present(_ viewCtlName: String, moduleName: String? = nil,fromViewCtl: UIViewController? = nil, params: [String: Any]? = nil, animated: Bool = true, isShowNav: Bool = true, modelStyle: Int = 0) {
        guard let viewCtl = initViewCtl(viewCtlName, moduleName: moduleName, params: params)else{
            return
        }
      presentViewCtl(viewCtl, fromViewCtl: fromViewCtl, animated: animated, isShowNav: isShowNav, modelStyle: modelStyle)
        
    }
}
//MARK:  封装私有跳转（私有）
extension YoMediator {
    //push
    fileprivate func pushViewCtl(animated: Bool, viewCtl: UIViewController, fromViewCtl: UIViewController? = nil) {
        viewCtl.hidesBottomBarWhenPushed = true
        guard let fromViewCtl = fromViewCtl else {
            getCurrentNavgationCtl()?.pushViewController(viewCtl, animated: animated)
            return
        }
        fromViewCtl.navigationController?.pushViewController(viewCtl, animated: animated)
    }
    // present
    fileprivate func presentViewCtl(_ viewCtl: UIViewController, fromViewCtl: UIViewController? = nil,  animated: Bool, isShowNav: Bool, modelStyle: Int) {
        var container = viewCtl
        if isShowNav {
          container = UINavigationController(rootViewController: viewCtl)
        }
        //跳转风格
        switch modelStyle {
        case 1:
            container.modalPresentationStyle = .fullScreen
        case 2:
            container.modalPresentationStyle = .custom
        default:
            if #available(iOS 13.0, *) {
                container.modalPresentationStyle = .automatic
            } else {
                container.modalPresentationStyle = .fullScreen
            }
        }
        guard let from =  fromViewCtl else {
            getCurrentViewCtl()?.present(container, animated: animated, completion: nil)
            return
        }
        from.present(container, animated: animated, completion: nil)
    }
}

//MARK: 获取最上层视图
extension YoMediator {
    //MARK: 获取顶层Nav(根据window)
    public func getCurrentNavgationCtl() -> UINavigationController? {
        getCurrentViewCtl()?.navigationController
    }
    //MARK: 获取顶层ViewCtl(根据window)
    public func getCurrentViewCtl() -> UIViewController? {
        var window = UIApplication.shared.keyWindow
        //是否为当前显示的window
        if window?.windowLevel != UIWindowLevelNormal {
            let windows = UIApplication.shared.windows
            for  windowTemp in windows{
                if windowTemp.windowLevel == UIWindowLevelNormal {
                    window = windowTemp
                    break
                }
            }
        }
        let viewCtl = window?.rootViewController
        return getCurrentViewController(withCurrentVC: viewCtl)
    }
    ///根据控制器获取 顶层控制器 递归
    private func getCurrentViewController(withCurrentVC VC :UIViewController?) -> UIViewController? {
        if VC == nil {
            print("🌶： 找不到顶层控制器")
            return nil
        }
        if let presentVC = VC?.presentedViewController {
            //modal出来的 控制器
            return getCurrentViewController(withCurrentVC: presentVC)
        }
        else if let splitVC = VC as? UISplitViewController {
            // UISplitViewController 的跟控制器
            if splitVC.viewControllers.count > 0 {
                return getCurrentViewController(withCurrentVC: splitVC.viewControllers.last)
            }else{
                return VC
            }
        }
        else if let tabVC = VC as? UITabBarController {
            // tabBar 的跟控制器
            if tabVC.viewControllers != nil {
                return getCurrentViewController(withCurrentVC: tabVC.selectedViewController)
            }else{
                return VC
            }
        }
        else if let naiVC = VC as? UINavigationController {
            // 控制器是 nav
            if naiVC.viewControllers.count > 0 {
                //                return getCurrentViewController(withCurrentVC: naiVC.topViewController)
                return getCurrentViewController(withCurrentVC:naiVC.visibleViewController)
            }else{
                return VC
            }
        }
        else {
            // 返回顶控制器
            return VC
        }
    }
}
