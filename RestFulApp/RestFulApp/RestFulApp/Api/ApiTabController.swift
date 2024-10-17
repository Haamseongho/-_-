import UIKit
import Foundation

class ApiTabController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {

    var pickerView = UIPickerView()
    var methodTypeData = ["GET", "POST", "PUT", "DELETE"]
    var tableView = UITableView()
    var data: [(key: String, value: String, checked: Bool)] = [("", "", false)] // Key-Value pairs
    var tabStackView = UIStackView()
    var receivedData: ApiModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    //    setupScrollView()
        setupPickerView()
        setupURLInput()
        setupCustomTabs()
        setupTableView()
        setupResponseView()
    }

    func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pickerView)
        
        
        let titleLabel = UILabel()
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
                pickerView.selectRow(index, inComponent: 0, animated: true)
            }
        } 
        else {
            titleLabel.text = "test"
            titleLabel.textColor = .black
            titleLabel.font = UIFont.systemFont(ofSize: 24)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            titleLabel.heightAnchor.constraint(equalToConstant: 50),
            borderView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            borderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            borderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            borderView.heightAnchor.constraint(equalToConstant: 3),
            pickerView.topAnchor.constraint(equalTo: borderView.bottomAnchor, constant: 20),
            pickerView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 10),
            pickerView.widthAnchor.constraint(equalToConstant: 130),
            pickerView.heightAnchor.constraint(equalToConstant: 100)
        ])
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
            textField.leadingAnchor.constraint(equalTo: pickerView.trailingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            textField.topAnchor.constraint(equalTo: pickerView.topAnchor),
            textField.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            sendButton.topAnchor.constraint(equalTo: textField.topAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 50),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
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
            tabStackView.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 10),
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
            tableView.heightAnchor.constraint(equalToConstant: 200)
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

    // MARK: UIPickerViewDataSource & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return methodTypeData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return methodTypeData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("selected : \(methodTypeData[row])")
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
