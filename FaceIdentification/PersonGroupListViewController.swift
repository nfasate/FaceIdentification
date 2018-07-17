//
//  PersonGroupListViewController.swift
//  FaceIdentification
//
//  Created by NILESH_iOS on 22/06/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

class PersonGroupListViewController: UIViewController {

    @IBOutlet var groupListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        groupListTableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        groupListTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addPersonGroupBtnTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PersonGroupViewController") as! PersonGroupViewController
        controller.pIndex = Constant.groups.count
        controller.isCreate = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension PersonGroupListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constant.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        cell.textLabel?.text = Constant.groups[indexPath.row].groupName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PersonGroupViewController") as! PersonGroupViewController
        controller.personGroup = Constant.groups[indexPath.row]
        controller.pIndex = indexPath.row
        controller.isCreate = false
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
