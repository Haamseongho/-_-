import UIKit
import Foundation

class ApiTabController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {

    var pickerView = UIPickerView()
    var methodTypeData = ["GET", "POST", "PUT", "DELETE"]
    var tableView = UITableView()
    var data: [(key: String, value: String)] = [("key1", "value1"), ("key2", "value2"), ("key3", "value3")] // Key-Value pairs
    var tabStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
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
        
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
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
        // Handle tab switching logic here
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
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

    // MARK: UITableViewDataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let item = data[indexPath.row]
        cell.textLabel?.text = item.key
        cell.detailTextLabel?.text = item.value
        return cell
    }
}
