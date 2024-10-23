import UIKit
import Foundation
import DropDown
import Alamofire
import Combine

class ApiTabController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
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
    let textField = UITextField()
    var tabIndex = 0 // 0, 1 = Param, Header, 2 = Body
    let responseTextView = UITextView()
    var buttonArray : [UIButton] = [] // Params, Headers, Body 버튼 넣어두는 배열
    let reqBodyNote = UITextView()  // reqBody
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupDropDown()
        setupURLInput()
        setupCustomTabs()
        setupTableView()
        setupResponseView()
        
        let tapGestureByKeyDown = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureByKeyDown)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
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
        
        textField.placeholder = "Enter URL"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .lightGray
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
        print("sendButtonClicked")
        for(key, value, checked) in data {
            print("Key : \(key) Value : \(value) Checked : \(checked)")
        }
        
        // Body
        if tabIndex == 2 {
            // textField 내용을 넣어서 반영할 것
            apiCallByBody()
        }
        // Headers
        else if tabIndex == 1{
            apiCallByHeaders()
        }
        // Params
        else {
            apiCallByParams()
        }
    }
    
    // params
    func apiCallByParams(){
        var params: [String: Any] = [:]
        for(key, value, checked) in data {
            if checked {
                params[key] = value
            }
        }
        print("Params : \(params)")
        // var apiUrl = textField.text ?? "" // 입력 Url
        var apiUrl = "http://13.125.207.44:2721/api/get"
        let methodType = self.methodLabel
        if methodType.text == "GET" {
            print("GET 테스트")
            AF.request(apiUrl, method: .get).response { response in
                switch response.result {
                case .success(let data):
                    if let data = data {
                        print("data : \(data)")
                        if let mimeType = response.response?.mimeType {
                            print("응답 MIME 타입: \(mimeType)")
                        }
                        
                        do {
                            if let jsonString = String(data: data, encoding: .utf8) {
                                
                                let returnString = self.formatJson(jsonString: jsonString)
                                self.responseTextView.text = returnString
                                if let jsonData = jsonString.data(using: .utf8) {
                                    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                        print("JSON 응답 데이터: \(jsonObject)")
                                        
                                    }
                                }
                            }
                        } catch {
                            print("JSON 파싱 실패: \(error)")
                        }
                    }
                case .failure(let error):
                    print("GET 요청 실패: \(error)")
                }
            }
        } else if methodType.text == "POST" {
            AF.request(apiUrl, method: HTTPMethod.post, parameters: params, encoding: JSONEncoding.default).response { response in
                switch response.result {
                case .success(let data):
                    if let data = data {
                        print("data : \(data)")
                        if let mimeType = response.response?.mimeType {
                            print("응답 MIME 타입: \(mimeType)")
                        }
                        
                        do {
                            if let jsonString = String(data: data, encoding: .utf8) {
                                let returnString = self.formatJson(jsonString: jsonString)
                                self.responseTextView.text = returnString
                                if let jsonData = jsonString.data(using: .utf8) {
                                    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                        print("JSON 응답 데이터: \(jsonObject)")
                                    }
                                }
                            }
                        } catch {
                            print("JSON 파싱 실패: \(error)")
                        }
                    }
                case .failure(let error):
                    print("POST 요청 실패: \(error)")
                }
            }
        } else if methodType.text == "PUT" {
            AF.request(apiUrl, method: HTTPMethod.put, parameters: params, encoding: JSONEncoding.default).response { response in
                switch response.result {
                case .success(let data):
                    if let data = data {
                        print("data : \(data)")
                        if let mimeType = response.response?.mimeType {
                            print("응답 MIME 타입: \(mimeType)")
                        }
                        
                        do {
                            if let jsonString = String(data: data, encoding: .utf8) {
                                let returnString = self.formatJson(jsonString: jsonString)
                                self.responseTextView.text = returnString
                                if let jsonData = jsonString.data(using: .utf8) {
                                    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                        print("JSON 응답 데이터: \(jsonObject)")
                                    }
                                }
                            }
                        } catch {
                            print("JSON 파싱 실패: \(error)")
                        }
                    }
                case .failure(let error):
                    print("POST 요청 실패: \(error)")
                }
            }
        } else if methodType.text == "DELETE" {
            AF.request(apiUrl, method: HTTPMethod.delete).response { response in
                switch response.result {
                case .success(let data):
                    if let data = data {
                        print("data : \(data)")
                        if let mimeType = response.response?.mimeType {
                            print("응답 MIME 타입: \(mimeType)")
                        }
                        
                        do {
                            if let jsonString = String(data: data, encoding: .utf8) {
                                let returnString = self.formatJson(jsonString: jsonString)
                                self.responseTextView.text = returnString
                                if let jsonData = jsonString.data(using: .utf8) {
                                    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                        print("JSON 응답 데이터: \(jsonObject)")
                                    }
                                }
                            }
                        } catch {
                            print("JSON 파싱 실패: \(error)")
                        }
                    }
                case .failure(let error):
                    print("POST 요청 실패: \(error)")
                }
            }
        } else {
            print("다른 메소드")
        }
        
    }
    
    // headers
    func apiCallByHeaders(){
        var apiUrl = "http://13.125.207.44:2721/api/get"
        
        var params: [String: Any] = [:]
        for(key, value, checked) in data {
            if checked {
                params[key] = value
            }
        }
        print("Params : \(params)")
        var headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        for(key, value, checked) in data {
            if checked {
                headers[key] = value
            }
        }
        print("Header : \(headers)")
       // let apiUrl = textField.text ?? "" // 입력 Url
        let methodType = self.methodLabel
        if methodType.text == "GET" {
            AF.request(apiUrl, method: HTTPMethod.get, headers: headers).response { response in
                switch response.result {
                case .success(let data):
                    if let data = data {
                        print("data : \(data)")
                        if let mimeType = response.response?.mimeType {
                            print("응답 MIME 타입: \(mimeType)")
                        }
                        
                        do {
                            if let jsonString = String(data: data, encoding: .utf8) {
                                let returnString = self.formatJson(jsonString: jsonString)
                                self.responseTextView.text = returnString
                                if let jsonData = jsonString.data(using: .utf8) {
                                    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                        print("JSON 응답 데이터: \(jsonObject)")
                                    }
                                }
                            }
                        } catch {
                            print("JSON 파싱 실패: \(error)")
                        }
                    }
                case .failure(let error):
                    print("GET 요청 실패: \(error)")
                }
            }
        } else if methodType.text == "DELETE" {
            AF.request(apiUrl, method: HTTPMethod.delete).response { response in
                switch response.result {
                case .success(let data):
                    if let data = data {
                        print("data : \(data)")
                        if let mimeType = response.response?.mimeType {
                            print("응답 MIME 타입: \(mimeType)")
                        }
                        
                        do {
                            if let jsonString = String(data: data, encoding: .utf8) {
                                let returnString = self.formatJson(jsonString: jsonString)
                                self.responseTextView.text = returnString
                                if let jsonData = jsonString.data(using: .utf8) {
                                    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                        print("JSON 응답 데이터: \(jsonObject)")
                                    }
                                }
                            }
                        } catch {
                            print("JSON 파싱 실패: \(error)")
                        }
                    }
                case .failure(let error):
                    print("POST 요청 실패: \(error)")
                }
            }
        } else {
            print("다른 메소드")
        }
        
    }
    
    // body
    func apiCallByBody() {
        // Fetch the input string from reqBodyNote and clean it
        var reqBody = reqBodyNote.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Replace newlines properly and remove unnecessary spaces
        reqBody = reqBody.replacingOccurrences(of: "\n", with: "")
        reqBody = reqBody.replacingOccurrences(of: " ", with: "")
        reqBody = reqBody.replacingOccurrences(of: "{", with: "[")
        reqBody = reqBody.replacingOccurrences(of: "}", with: "]")
        // 보낼 JSON 데이터 생성
        let parameters: [String: Any] = [
            "No": "D190322",
            "inItem": [
                "name": "SEONGHO",
                "age": 32
            ]
        ]
        print(parameters)
        
        // AF.request(
        
        // Convert the cleaned string to Data
        if let jsonData = reqBody.data(using: .utf8) {
            print("jsonData: \(jsonData)")
            
            do {
                // Try to convert the Data to a JSON object
                let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                print("jsonObject: \(jsonObject)")
            } catch {
                print("Error during JSONSerialization: \(error)")
            }
        } else {
            print("Failed to convert reqBody to Data.")
        }
        
        print("Final reqBody: \(reqBody)")
    }    // 탭 Params, Headders, Body 선택시 탭 색깔바꾸기
    
    @objc func changeButtonBackgroundColor(tabButton: UIButton){
        for button in buttonArray {
            button.backgroundColor = .white
            if button == tabButton {
                tabButton.backgroundColor = .systemBlue
            }
        }
    }
    
    
    func setupCustomTabs() {
        let paramsButton = createButton(title: "Params")
        let headersButton = createButton(title: "Headers")
        let bodyButton = createButton(title: "Body")
        
        // 버튼의 텍스트 색상 설정
        paramsButton.setTitleColor(.black, for: .normal)
        headersButton.setTitleColor(.black, for: .normal)
        bodyButton.setTitleColor(.black, for: .normal)
            
        buttonArray = [paramsButton, headersButton, bodyButton]
        
        // 클릭 이벤트 연결 - selector 사용 시 인수는 자동으로 전달됨
        paramsButton.addTarget(self, action: #selector(changeButtonBackgroundColor(tabButton:)), for: .touchUpInside)
        headersButton.addTarget(self, action: #selector(changeButtonBackgroundColor(tabButton:)), for: .touchUpInside)
        bodyButton.addTarget(self, action: #selector(changeButtonBackgroundColor(tabButton:)), for: .touchUpInside)
        
        
        tabStackView.axis = .horizontal
        tabStackView.distribution = .fillEqually
        tabStackView.addArrangedSubview(paramsButton)
        tabStackView.addArrangedSubview(headersButton)
        tabStackView.addArrangedSubview(bodyButton)
        tabStackView.translatesAutoresizingMaskIntoConstraints = false
        tabStackView.backgroundColor = .white
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
            tabIndex = 2
            requestBodyInfo()  // Body Information 만들기
        }
        else if sender.currentTitle == "Params" {
            tabIndex = 0
            requestTableInfo() // Table 형태 만들기
        }
        else {
            tabIndex = 1
            requestTableInfo() // Table 형태 만들기
        }
        // Handle tab switching logic here
    }
    
    func requestBodyInfo() {
        tableView.isHidden = true
        
        reqBodyNote.isHidden = false
        // 전체 배경 색상을 회색으로 설정
        reqBodyNote.backgroundColor = .lightGray
        reqBodyNote.delegate = self
        reqBodyNote.isScrollEnabled = true
        reqBodyNote.keyboardType = .default
        reqBodyNote.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(reqBodyNote)
        
        NSLayoutConstraint.activate([
            reqBodyNote.topAnchor.constraint(equalTo: tabStackView.bottomAnchor, constant: 10),
            reqBodyNote.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            reqBodyNote.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            reqBodyNote.bottomAnchor.constraint(equalTo: responseTextView.topAnchor, constant: -10) // 여백 수정
        ])
        
    }
    
    func requestTableInfo(){
        tableView.isHidden = false
        reqBodyNote.isHidden = true
    }
    
    func setupTableView() {
        tableView.isHidden = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.register(TableViewController.self, forCellReuseIdentifier: "KeyValueCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: tabStackView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
    }
    
    func setupResponseView() {
        let responseLabel = UILabel()
        responseLabel.text = "Response"
        responseLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(responseLabel)
        
        
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
            guard let self = self else { return }
            // Update the data array with the new key and value
            self.data[indexPath.row] = (key, value, self.data[indexPath.row].checked)
            print("입력 Key: \(key) 입력 Value: \(value)")
        }
        cell.checkBoxTapped = { [weak self] in
            guard let self = self else { return }
            // Toggle the checked state
            self.data[indexPath.row].checked.toggle()
            
            if self.data[indexPath.row].checked {
                // Add a new row if checkbox is selected
                self.data.append((key: "", value: "", checked: false))
                let newIndexPath = IndexPath(row: self.data.count - 1, section: 0)
                self.tableView.insertRows(at: [newIndexPath], with: .automatic)
            } else {
                // Remove the last row if checkbox is deselected
                self.data.removeLast()
                let lastIndexPath = IndexPath(row: self.data.count, section: 0)
                self.tableView.deleteRows(at: [lastIndexPath], with: .automatic)
            }
            // Reload only the current cell to reflect the changes
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        return cell
    }
    
    func formatJson(jsonString: String) -> String{
        var returnData = ""
        var inx = 0
        let size = jsonString.count
        for elem in jsonString {
            inx += 1
            if elem == "{" || elem == "," || elem == "}" {
                print(elem)
                if inx < size {
                    returnData = returnData + String(elem) + "\n" + "  "
                }
                else {
                    returnData = returnData + "\n" + String(elem)
                }
            } else {
                returnData = returnData + "" + String(elem)
            }
           
        }
        print(returnData)
        return returnData
    }
}
