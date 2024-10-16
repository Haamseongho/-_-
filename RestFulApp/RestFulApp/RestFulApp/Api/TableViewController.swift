//
//  TableViewController.swift
//  RestFulApp
//
//  Created by haams on 10/16/24.
//

import Foundation
import UIKit

struct DataKey: Hashable {
    let key: String
    let value: String
}

class TableViewController: UITableViewController {
    // 데이터: 각 항목의 체크 상태를 Bool 값으로 관리
    var data: [DataKey: Bool] = [
        DataKey(key: "key1", value: "value1"): false,
        DataKey(key: "key2", value: "value2"): false,
        DataKey(key: "key3", value: "value3"): false
    ]
    
    var expandedRows: [DataKey] = [] // 확장된 행을 관리할 배열
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count + expandedRows.count
    }
    
    override func tableView(_ tableView:UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let dataKeys = Array(data.keys)
        let rowIndex = indexPath.row
        let key = dataKeys[rowIndex]
        
        if expandedRows.contains(key) {
            cell.textLabel?.text = "Expanded Row for \(dataKeys[rowIndex])"
        } else {
            cell.textLabel?.text = "\(key.key) - \(key.value)"
            
            // 체크박스 추가
            let checkbox = UIButton(type: .system)
            checkbox.setTitle(data[key]! ? "☑️" : "⬜️", for: .normal) // 선택 여부에 따라 체크박스 설정
            checkbox.tag = rowIndex
            checkbox.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
            cell.accessoryView = checkbox
        }
        
        return cell
    }
    
    @objc func checkboxTapped(_ sender: UIButton) {
        let dataKeys = Array(data.keys)
        let key = dataKeys[sender.tag] // 현재 선택된 항목의 키 가져오기
        data[key]!.toggle() // 체크 상태 토글
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        
        if data[key]! {
            // 체크박스가 선택되면 행을 확장
            expandedRows.append(key)
            tableView.insertRows(at: [indexPath], with: .automatic)
        } else {
            // 체크박스가 해제되면 확장된 행을 제거
            if let index = expandedRows.firstIndex(of: key) {
                expandedRows.remove(at: index)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }

        // 체크박스 상태를 업데이트
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
