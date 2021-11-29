//
//  ViewController.swift
//  YoMediator
//
//  Created by YoSwiftKing on 11/27/2021.
//  Copyright (c) 2021 YoSwiftKing. All rights reserved.
//

import UIKit
import SnapKit
import YoMediator

class ViewController: UIViewController {
     lazy  var  tableView: UITableView = {
        let tableView = UITableView.init()
        self.view.addSubview(tableView)
         tableView.delegate  = self
         tableView.dataSource = self
         tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return tableView
    }()
    var datas: [String] = ["resent/默认/带导航","resent可选Style/可选导航栏",
                          "push/手动初始化", "push/默认用法", "push/可选动画，可选出发页面",
                           "URL/push",  "URL/present", "URL/present/全屏",
                           "类方法调用","实例方法调用/回传参数","实例方法调用",
                           "跨组件调用/打开其他Module的页面"
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.snp_makeConstraints { make in
            make.top.left.right.bottom.equalTo(self.view)
        }
    }
}
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let params: [String: Any] =  [
                        "str":"我是字符串",
                           "titleName":"resent/默认/带导航",
                           "num":13,
                           "dic":["a":12,"b":"测试字符串"]
                          ]
            YoMediator.shared.present("TestViewCtl", moduleName: "YoMediator", fromViewCtl: self, params:params)
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = self.datas[indexPath.row]
        return cell
    }
    
    
}

