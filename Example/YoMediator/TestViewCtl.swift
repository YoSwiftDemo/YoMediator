//
//  TestViewCtl.swift
//  YoMediator_Example
//
//  Created by admin on 2021/11/29.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit

class TestViewCtl: UIViewController {
    
    @objc var titleName : String?
    @objc var str : String?
    @objc var num : Int = 0
    @objc var dic : [String : Any]?
    
    override func viewDidLoad() {
        lazy var closeBtn: UIButton = {
            let btn = UIButton()
            btn.setTitle("关闭", for: .normal)
            btn.backgroundColor = .red
            return btn
        }()
     lazy var patamLab: UILabel = {
            let lab = UILabel()
         lab.numberOfLines = 0
         lab.backgroundColor = .yellow
            return lab
        }()
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .blue
        patamLab.text = String(describing: dic)
        //关闭
        closeBtn.snp_makeConstraints { make in
            make.width.height.equalTo(100)
            make.top.left.equalTo(view).offset(0)
        }
        //传过来的字典 显示
        patamLab.snp_makeConstraints { make in
            make.top.equalTo(closeBtn.snp_bottom)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.greaterThanOrEqualTo(0)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
