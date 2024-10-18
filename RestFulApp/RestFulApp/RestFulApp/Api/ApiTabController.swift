import UIKit
import Foundation
import DropDown
import Alamofire

class ApiTabController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
   // var pickerView = UIPickerView()
    var methodTypeData = ["GET", "POST", "PUT", "DELETE"]
    var tableView = UITableView()
    var data: [(key: String, value: String, checked: Bool)] = [("", "", false)] // Key-Value pairs
    var tabStackView = UIStackView()
    var receivedData: ApiModel?
    let dropDown = DropDown() // DropDown 인스턴스 생성
    let button = UIButton(type: .system)
    var methodLabel = UILabel()
    let titleLabel = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupDropDown()
        setupURLInput()
        setupCustomTabs()
        setupTableView()
        setupResponseView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if receivedData?.title != nil && receivedData?.type != nil {
            titleLabel.text = receivedData?.title
            titleLabel.textColor = .black
            titleLabel.font = UIFont.systemFont(ofSize: 16)
            let type = receivedData?.type ?? "GET"
            if let index = methodTypeData.firstIndex(of: type) {
                dropDown.selectRow(index)
                methodLabel.text = type
            }
        }
    }
    
    func setupDropDown(){
       
        methodLabel.text = "GET"
        methodLabel.textAlignment = .center
        methodLabel.backgroundColor = .lightGray
        methodLabel.textColor = .black
        methodLabel.layer.cornerRadius = 10
        methodLabel.layer.borderWidth = 1
        methodLabel.clipsToBounds = true
        methodLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(methodLabel)
        
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let borderView = UIView()
        borderView.backgroundColor = .black
        borderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        view.addSubview(borderView)
        if receivedData?.title != nil && receivedData?.type != nil{
            let title = receivedData?.title
            titleLabel.text = title
            titleLabel.textColor = .black
            titleLabel.font = UIFont.systemFont(ofSize: 16)
            let type = receivedData?.type ?? "GET"
            if let index = methodTypeData.firstIndex(of: type) {
                dropDown.selectRow(index)
                methodLabel.text = type
            }
        }
        else {
            titleLabel.text = "test"
            titleLabel.textColor = .black
            titleLabel.font = UIFont.systemFont(ofSize: 24)
        }
        
        // DropDown 설정
        dropDown.anchorView = borderView // 드롭다운을 버튼 아래에 앵커링
        dropDown.dataSource = methodTypeData // 드롭다운 항목
        dropDown.bottomOffset = CGPoint(x: 0, y: borderView.bounds.height) // View를 가리지 않고 View 아래에 Item 팝업이 붙도록 설정
        
        
        
     //   dropDown.translatesAutoresizingMaskIntoConstraints = false
     //   view.addSubview(dropDown)
        

        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(showDropDown))
        methodLabel.isUserInteractionEnabled = true
        methodLabel.addGestureRecognizer(tapGesture2)
        
        
        // 드롭다운 항목 선택 시 처리
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self?.methodLabel.text = item
        }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            titleLabel.heightAnchor.constraint(equalToConstant: 50),
            borderView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            borderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            borderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            borderView.heightAnchor.constraint(equalToConstant: 3),
            methodLabel.topAnchor.constraint(equalTo: borderView.bottomAnchor, constant: 20),
            methodLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            methodLabel.widthAnchor.constraint(equalToConstant: 130), // 고정된 너비 추가
            methodLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func showDropDown() {
        dropDown.show() // 드롭다운 표시
    }
    
    func setupURLInput() {
        let textField = UITextField()
        textField.placeholder = "Enter URL"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        let sendButton = UIButton(type: .system)
        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: methodLabel.trailingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            textField.topAnchor.constraint(equalTo: methodLabel.topAnchor, constant: 0),
            textField.bottomAnchor.constraint(equalTo: methodLabel.bottomAnchor, constant: 0),
            textField.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            sendButton.topAnchor.constraint(equalTo: methodLabel.topAnchor, constant: 0),
            sendButton.bottomAnchor.constraint(equalTo: methodLabel.bottomAnchor, constant: 0),
            sendButton.widthAnchor.constraint(equalToConstant: 50),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let sendButtonTapped = UITapGestureRecognizer(target: self, action: #selector(sendButtonClicked))
        sendButton.isUserInteractionEnabled = true
        sendButton.addGestureRecognizer(sendButtonTapped)
    }
    
    @objc func sendButtonClicked() {
        
    }
    
    func setupCustomTabs() {
        let paramsButton = createButton(title: "Params")
        let headersButton = createButton(title: "Headers")
        let bodyButton = createButton(title: "Body")
        
        tabStackView.axis = .horizontal
        tabStackView.distribution = .fillEqually
        tabStackView.addArrangedSubview(paramsButton)
        tabStackView.addArrangedSubview(headersButton)
        tabStackView.addArrangedSubview(bodyButton)
        tabStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabStackView)
        
        NSLayoutConstraint.activate([
            tabStackView.topAnchor.constraint(equalTo: methodLabel.bottomAnchor, constant: 10),
            tabStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tabStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tabStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    @objc func tabButtonTapped(_ sender: UIButton) {
        print("Tab selected: \(sender.currentTitle ?? "")")
        if sender.currentTitle == "Body" {
            requestBodyInfo()
        } else {
            requestTableInfo()
        }
        // Handle tab switching logic here
    }
    
    func requestBodyInfo() {
        tableView.isHidden = true
    }
    
    func requestTableInfo(){
        tableView.isHidden = false
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableViewController.self, forCellReuseIdentifier: "KeyValueCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: tabStackView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        let addButton = UIButton(type: .system)
        addButton.setTitle("+", for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func setupResponseView() {
        let responseLabel = UILabel()
        responseLabel.text = "Response"
        responseLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(responseLabel)
        
        let responseTextView = UITextView()
        responseTextView.text = "Hit send to get a response."
        responseTextView.layer.borderWidth = 1
        responseTextView.layer.borderColor = UIColor.lightGray.cgColor
        responseTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(responseTextView)
        
        NSLayoutConstraint.activate([
            responseLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 50),
            responseLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            
            responseTextView.topAnchor.constraint(equalTo: responseLabel.bottomAnchor, constant: 5),
            responseTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            responseTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            responseTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: UITableViewDataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "KeyValueCell", for: indexPath) as? TableViewController else { return UITableViewCell() }
        let item = data[indexPath.row]
        cell.keyTextField.text = item.key
        cell.valueTextField.text = item.value
        cell.checkBox.isSelected = item.checked
        
        cell.onTextChange = { [weak self] key, value in
            self?.data[indexPath.row] = (key, value, false)
        }
        cell.checkBoxTapped = { [weak self] in
            self?.data[indexPath.row].checked.toggle()
            if self?.data[indexPath.row].checked == true {
                self?.data.append((key: "", value: "", checked: false))
            }
            self?.tableView.reloadData()
        }
        return cell
    }
    
    
}
