import UIKit
import Foundation
import DropDown
import Alamofire
import Combine

class ApiTabController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var historyItems: [ReqBodyModel] = []
    
    
    // 히스토리 꺼내기 위함
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return historyItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .systemBlue
        let label = UILabel()
        label.text = historyItems[indexPath.item].title
        label.textColor = .white
        label.textAlignment = .center
        label.frame = cell.contentView.bounds
        cell.contentView.addSubview(label)
        return cell
        
    }
    // MARK: - UICollectionView Delegate
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         self.dismiss(animated: true) {
             // 선택된 항목에 따라 다른 이벤트 실행
             let selectedItem = self.historyItems[indexPath.item]
             print("You selected: \(selectedItem)")
             
             self.reqBodyNote.text = selectedItem.body
             self.textField.text = selectedItem.url
             self.methodLabel.text = selectedItem.type
             self.tabIndex = 2
             self.requestBodyInfo()
         }
     }
    
    // var pickerView = UIPickerView()
    var methodTypeData = ["GET", "POST"]
    var tableView = UITableView()
    var data: [(key: String, value: String, checked: Bool)] = [("", "", false)] // Key-Value pairs
    var tabStackView = UIStackView()
    let dropDown = DropDown() // DropDown 인스턴스 생성
    let button = UIButton(type: .system)
    var methodLabel = UILabel()
    let titleField = UITextField()
    let textField = UITextField() // Enter Url
    var tabIndex = 0 // 0, 1 = Param, Header, 2 = Body
    var tabIndex2 = 0 // 0: Body, 1: Cookies, 2: Headers (for response)
    var responseTextView = UITextView()
    var buttonArray : [UIButton] = [] // Params, Headers, Body 버튼 넣어두는 배열
    let reqBodyNote = UITextView()  // reqBody
    let realmDao = RealmDao()
    let responseStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        return stackView
    }()
    // response header
    var responseHeader: [AnyHashable : Any] = [:]
    var responseJsonString: String = ""
    // 컨텐츠를 보여줄 뷰
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    var cookieString: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupURLInput()
        // setupDropDown()
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
    }
    
    
    @objc func showDropDown() {
        dropDown.show() // 드롭다운 표시
    }
    
    func setupURLInput() {
        
        // reqBody 히스토리
        let reqResults = self.realmDao.getRequestBodyInfo()
        historyItems  = Array(reqResults) // 리스트 넣어놓기
        
        methodLabel.text = "GET"
        methodLabel.textAlignment = .center
        methodLabel.backgroundColor = .lightGray
        methodLabel.textColor = .black
        methodLabel.layer.cornerRadius = 10
        methodLabel.layer.borderWidth = 1
        methodLabel.clipsToBounds = true
        methodLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(methodLabel)
        
        
        //        titleField.translatesAutoresizingMaskIntoConstraints = false
        //        titleField.placeholder = "제목입력해주세요."
        //        titleField.textColor = .black
        let borderView = UIView()
        borderView.backgroundColor = .black
        borderView.translatesAutoresizingMaskIntoConstraints = false
        //        view.addSubview(titleField)
        view.addSubview(borderView)
        
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
        
        textField.attributedPlaceholder = NSAttributedString(string: "Enter URL",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        // textField.borderStyle = .roundedRect
        // textField.backgroundColor = .lightGray
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        let sendButton = UIButton(type: .system)
        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            // Corrected textField constraints
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textField.heightAnchor.constraint(equalToConstant: 40),
            
            // Constraints for borderView
            borderView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 5),
            borderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            borderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            borderView.heightAnchor.constraint(equalToConstant: 3),
            
            // Constraints for methodLabel
            methodLabel.topAnchor.constraint(equalTo: borderView.bottomAnchor, constant: 20),
            methodLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            methodLabel.trailingAnchor.constraint(equalTo: sendButton.trailingAnchor, constant: -30),
            methodLabel.heightAnchor.constraint(equalToConstant: 40),
            
            // Constraints for sendButton
            sendButton.topAnchor.constraint(equalTo: methodLabel.topAnchor, constant: 0),
            sendButton.bottomAnchor.constraint(equalTo: methodLabel.bottomAnchor, constant: 0),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            sendButton.leadingAnchor.constraint(equalTo: methodLabel.trailingAnchor, constant: 10),
            sendButton.widthAnchor.constraint(equalToConstant: 40),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let sendButtonTapped = UITapGestureRecognizer(target: self, action: #selector(sendButtonClicked))
        sendButton.isUserInteractionEnabled = true
        sendButton.addGestureRecognizer(sendButtonTapped)
    }
    
    func saveRequestBodyInfo(){
        let reqBodyModel = ReqBodyModel()
        if let url = self.textField.text {
            reqBodyModel.url = url
        }
        
        if let body = self.reqBodyNote.text {
            reqBodyModel.body = body
        }
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let formattedDate = dateFormatter.string(from: currentDate)
        
        reqBodyModel.title = formattedDate // 시간 넣어주기(title)
        if let type = self.methodLabel.text {
            reqBodyModel.type = type
        }
        
        self.realmDao.insertReqBodyInfo(reqBodyModel)
        self.historyItems.append(reqBodyModel)
    }
    
    @objc func sendButtonClicked() {
        print("sendButtonClicked")
        // 클릭하면 자동으로 Body2에 선택되도록 구현
        buttonArray.forEach { button in
            if button.currentTitle == "Body2" {
                button.backgroundColor = .systemTeal
            } else {
                button.backgroundColor = .white
            }
        }
        for(key, value, checked) in data {
            print("Key : \(key) Value : \(value) Checked : \(checked)")
        }
        
        saveRequestBodyInfo()
        // save Data
        
        
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
    
    func saveApiCallData(apiUrl: String, methodType: String, params: [String: Any]) {
        let type = methodType
        let title = titleField.text ?? "테스트입니다."
        let url = apiUrl
        
        let requestModel = RequestModel()
        requestModel.title = title
        requestModel.type = type
        requestModel.url = url
        
        
        // Request 테이블에 넣어주기
        self.realmDao.insertRequest(requestData: requestModel)
        // Collection 테이블을 통해 Request로 접근해서 찾아온 것이라면, 해당 id값을 토대로 컬렉션을 찾은 다음 그곳에 Request 테이블 수정하기
        
        // History 테이블에 넣어주기
        /*
         @Persisted(primaryKey: true) var id: ObjectId
         @Persisted var type: String
         @Persisted var title: String
         @Persisted var url: String
         @Persisted var date: Date
         @Persisted var params = List<ParamsObject>()
         @Persisted var headers = List<ParamsObject>()
         @Persisted var body: String
         @Persisted var requestList = List<RequestModel>()
         */
        let historyModel = HistoryModel()
        historyModel.type = type
        historyModel.title = title
        historyModel.url = url
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let formattedDate = dateFormatter.string(from: today)
        historyModel.date = today
        
        print("requestModel : \(requestModel)")
        // Colleciton 테이블을 통해 Request로 접근해서 찾아온 것이라면, 해당 Id를 토대로 컬렉션의 History 테이블(리스트) 수정하기
        self.realmDao.insertHistoryToCollection(history: historyModel, request: requestModel, name: "date: \(today)")
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
        var apiUrl = textField.text ?? "" // 입력 Url
        let methodType = self.methodLabel
        print("apiUrl: \(apiUrl) methodType: \(methodType)")
        saveApiCallData(apiUrl: apiUrl, methodType: methodType.text ?? "GET", params: params)
        
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
                                self.responseJsonString = returnString
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
                    
                    if let httpResponse = response.response {
                        self.responseHeader = httpResponse.allHeaderFields  // header뽑기
                        print("headers: \(self.responseHeader)")
                        self.cookieString = ""// 쿠키 초기화
                        if let url = httpResponse.url {
                            if let cookies = HTTPCookieStorage.shared.cookies(for: url){
                                for cookie in cookies {
                                    self.cookieString += "\(cookie)"
                                    print("Cookies: \(cookie)")
                                }
                            } else {
                                print("No Cookies found")
                            }
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
                                self.responseJsonString = returnString
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
                    
                    if let httpResponse = response.response {
                        self.responseHeader = httpResponse.allHeaderFields  // header뽑기
                        print("headers: \(self.responseHeader)")
                        self.cookieString = ""// 쿠키 초기화
                        if let url = httpResponse.url {
                            if let cookies = HTTPCookieStorage.shared.cookies(for: url){
                                for cookie in cookies {
                                    self.cookieString += "\(cookie)"
                                    print("Cookies: \(cookie)")
                                }
                            } else {
                                print("No Cookies found")
                            }
                        }
                    }
                case .failure(let error):
                    print("POST 요청 실패: \(error)")
                }
            }
        }
        else {
            print("다른 메소드")
        }
        
    }
    
    // headers
    func apiCallByHeaders(){
        
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
        let apiUrl = textField.text ?? "" // 입력 Url
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
                                self.responseJsonString = returnString
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
                    
                    
                    if let httpResponse = response.response {
                        self.responseHeader = httpResponse.allHeaderFields  // header뽑기
                        print("headers: \(self.responseHeader)")
                        self.cookieString = ""// 쿠키 초기화
                        if let url = httpResponse.url {
                            if let cookies = HTTPCookieStorage.shared.cookies(for: url){
                                for cookie in cookies {
                                    self.cookieString += "\(cookie)"
                                    print("Cookies: \(cookie)")
                                }
                            } else {
                                print("No Cookies found")
                            }
                        }
                    }
                case .failure(let error):
                    print("GET 요청 실패: \(error)")
                }
            }
        } else if methodType.text == "POST" {
            AF.request(apiUrl, method: HTTPMethod.post, headers: headers).response { response in
                switch response.result {
                case .success(let data):
                    if let data = data {
                        do {
                            if let jsonString = String(data: data, encoding: .utf8) {
                                let returnString = self.formatJson(jsonString: jsonString)
                                self.responseTextView.text = returnString
                                self.responseJsonString = returnString
                                if let jsonData = jsonString.data(using: .utf8) {
                                    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                        print("JSON 응답 데이터: \(jsonObject)")
                                    }
                                }
                            }
                        } catch {
                            print("JSON POST Error")
                        }
                    }
                    // 응답 -> 해더 뽑기 & 쿠키뽑기
                    if let httpResponse = response.response {
                        self.responseHeader = httpResponse.allHeaderFields  // header뽑기
                        print("headers: \(self.responseHeader)")
                        self.cookieString = ""// 쿠키 초기화
                        if let url = httpResponse.url {
                            if let cookies = HTTPCookieStorage.shared.cookies(for: url){
                                for cookie in cookies {
                                    self.cookieString += "\(cookie)"
                                    print("Cookies: \(cookie)")
                                }
                            } else {
                                print("No Cookies found")
                            }
                        }
                    }
                case .failure(let error):
                    print("POST 요청 실패 \(error)")
                }
            }
        }
        else {
            print("다른 메소드")
        }
        
    }
    
    // body
    func apiCallByBody() {
        
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
        // Fetch the input string from reqBodyNote and clean it
        var reqBody = reqBodyNote.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        print("reqBody ::: \(reqBody)")
        // JSON으로 변환할 수 있는지 확인
        guard let jsonData = reqBody.data(using: .utf8) else {
            print("Failed to convert reqBody to Data.")
            return
        }
        
        // Replace newlines properly and remove unnecessary spaces
        //reqBody = reqBody.replacingOccurrences(of: "\n", with: "")
        //reqBody = reqBody.replacingOccurrences(of: " ", with: "")
        //reqBody = reqBody.replacingOccurrences(of: "{", with: "[")
        //reqBody = reqBody.replacingOccurrences(of: "}", with: "]")
        // 보낼 JSON 데이터 생성
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            print("Parsed JSON object: \(jsonObject)")
            let apiUrl = textField.text ?? "" // 입력 Url
            var methodType = self.methodLabel
            var request = URLRequest(url: URL(string: apiUrl)!)
            request.httpMethod = methodType.text
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Custom 헤더 추가
            headers.forEach { header in
                request.setValue(header.value, forHTTPHeaderField: header.name)
            }
            
            request.httpBody = jsonData
            AF.request(request).response { response in
                switch response.result {
                case .success(let data):
                    if let data = data {
                        do {
                            print("JSON Body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "")")
                            if let jsonString = String(data: data, encoding: .utf8) {
                                let returnString = self.formatJson(jsonString: jsonString)
                                self.responseTextView.text = returnString
                                self.responseJsonString = returnString
                                if let jsonData2 = jsonString.data(using: .utf8) {
                                    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                        print("JSON 응답 데이터: \(jsonObject)")
                                    }
                                }
                            }
                        } catch {
                            print("JSON POST Error")
                        }
                    }
                    
                    if let httpResponse = response.response {
                        self.responseHeader = httpResponse.allHeaderFields  // header뽑기
                        print("headers: \(self.responseHeader)")
                        self.cookieString = ""// 쿠키 초기화
                        if let url = httpResponse.url {
                            if let cookies = HTTPCookieStorage.shared.cookies(for: url){
                                for cookie in cookies {
                                    self.cookieString += "\(cookie)"
                                }
                            } else {
                                print("No Cookies found")
                            }
                        }
                    }
                case .failure(let error):
                    print("Error - body :\(error)")
                }
            }
        } catch {
            print("Error during JSONSerialization: \(error)")
        }
        
    }    // 탭 Params, Headders, Body 선택시 탭 색깔바꾸기
    
    @objc func changeButtonBackgroundColor(tabButton: UIButton){
        for button in buttonArray {
            button.backgroundColor = .white
            if button == tabButton {
                print("button : \(button.titleLabel!.text)")
                if button.currentTitle == "Cookies" || button.currentTitle == "Body2" || button.currentTitle == "Headers2"{
                    tabButton.backgroundColor = .systemTeal
                } else {
                    tabButton.backgroundColor = .systemYellow
                }
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
        
        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = .lightGray
        view.addSubview(borderView)
        
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
            tabStackView.heightAnchor.constraint(equalToConstant: 40),
            
            borderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            borderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            borderView.heightAnchor.constraint(equalToConstant: 1),
            borderView.topAnchor.constraint(equalTo: tabStackView.bottomAnchor, constant: 5)
        ])
    }
    
    func createButton(title: String) -> UIButton {
        var button = UIButton(type: .system)
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
        else if sender.currentTitle == "Params" || sender.currentTitle == "Headers"{
            tabIndex = 0
            requestTableInfo() // Table 형태 만들기
        }
        else if sender.currentTitle == "Cookies" {
            tabIndex2 = 1
            getCookiesFromResponse()
        }
        else if sender.currentTitle == "Headers2" {
            tabIndex2 = 2
            getHeadersFromResponse()
        }
        else if sender.currentTitle == "Body2" {
            tabIndex2 = 0
            getBodyFromResponse()
        }
        // 바로 직전꺼
        else if sender.currentTitle == "history" {
            loadPrevRequestData()
        }
        // 예시로 미리 넣어둔 것
        else if sender.currentTitle == "example" {
            loadExampleRequestData()
        }
        // reset
        else if sender.currentTitle == "reset"{
            self.responseTextView.text = ""
            self.reqBodyNote.text = ""
            self.textField.text = ""
        }
        else {
            tabIndex = 1
            requestTableInfo() // Table 형태 만들기
        }
        // Handle tab switching logic here
    }
    
    // 이전 조회한 요청 데이터(eg: reqBody) 셋팅해주기
    func loadPrevRequestData(){
        print("loadPrevRequestData Button Clicked")
        tabIndex = 2
        loadHistory()
     //   requestBodyInfo()
    }
    // alert 띄워서 requestBody History 가져오기
    func loadHistory(){
        let customVC = UIViewController()
        customVC.preferredContentSize = CGSize(width: 300, height: 200)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 280, height: 50) // 셀 크기
        layout.minimumLineSpacing = 10 // 셀 간격
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = .clear
        
        customVC.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: customVC.view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: customVC.view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: customVC.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: customVC.view.trailingAnchor)
        ])
        
        // UIAlertController 생성
        let alert = UIAlertController(title: "History Select Item", message: nil, preferredStyle: .alert)
        alert.setValue(customVC, forKey: "contentViewController")
        
        // 취소 버튼 추가
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // Clear History
        alert.addAction(UIAlertAction(title: "Clear", style: .default) { action in
            self.clearAllHistory()
        })
        // Alert 표시
        present(alert, animated: true, completion: nil)
    }
    
    func clearAllHistory(){
        self.realmDao.dropRequestBodyInfo()
        self.historyItems.removeAll()
    }
    
    // 기본 예시로 들어간 요청 데이터 셋팅해주기
    func loadExampleRequestData(){
        print("loadExampleRequestData Button Clicked")
        tabIndex = 2 // Body2
        self.textField.text = "https://zmkbglobal.kbstar.com/deposit/prdct/DpostPrdctInq"
        self.reqBodyNote.text = """
        {

                  "Scrno": "",

                  "Task": {

                      "bzwkCmnDvsn": {

                         "operGroupCd": "",

                         "brnCd": "",

                         "bzwkGroupCd": ""

                      },

                      "inItem": {

                        "prdctSbjctCd1": "",

                        "bbrnCd": "",

                        "joinWay": "",

                        "serchCndn": "",

                        "serchCtnt": "",

                        "dmndPageCnt": "1",

                        "screnDsplCnt": "100",

                        "groupCoCd": "",

                        "operGroupCd": "",

                        "boPrdctPtrnCd": "02",

                        "boPrdctSbjectcd": "",

                        "wwwJoinYn": "",

                        "dsplYn": "",

                        "acnDstic": "01",

                        "langDstic": "KOR",

                        "ovsesPpsnCoptDstic": ""

                      }

                   }

                }


    """
        requestBodyInfo()
        
    }
    
    // 쿠키만 뽑아내기
    func getCookiesFromResponse(){
        self.responseTextView.text = self.cookieString
        print("Content Size: \(self.responseTextView.contentSize)")
        print("Frame Size: \(self.responseTextView.frame.size)")
    }
    
    // 응답에서 해더 가져오기
    func getHeadersFromResponse(){
        
        var resHeaderString = ""
        for (key, value) in self.responseHeader {
            resHeaderString += "\(key): \(value)\n"
        }
        self.responseTextView.text = resHeaderString
    }
    // 응답에서 기존 결과 보여주기
    func getBodyFromResponse(){
        self.responseTextView.text = self.responseJsonString
    }
    
    func requestBodyInfo() {
        tableView.isHidden = true
        
        reqBodyNote.isHidden = false
        // 전체 배경 색상을 회색으로 설정
        reqBodyNote.backgroundColor = .white
        reqBodyNote.textColor = .black
        reqBodyNote.layer.borderWidth = 1
        reqBodyNote.layer.borderColor = UIColor.lightGray.cgColor
        reqBodyNote.delegate = self
        reqBodyNote.isScrollEnabled = true
        reqBodyNote.keyboardType = .default
        reqBodyNote.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(reqBodyNote)
        
        NSLayoutConstraint.activate([
            reqBodyNote.topAnchor.constraint(equalTo: tabStackView.bottomAnchor, constant: 10),
            reqBodyNote.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            reqBodyNote.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            reqBodyNote.heightAnchor.constraint(equalToConstant: 200)
            //   reqBodyNote.bottomAnchor.constraint(equalTo: responseTextView.topAnchor, constant: -50) // 여백 수정
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
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.borderWidth = 1
        tableView.register(TableViewController.self, forCellReuseIdentifier: "KeyValueCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: tabStackView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
    }
    // 응답 옆에 버튼 두기
    func setupResponseView() {
        let responseLabel = UILabel()
        responseLabel.text = "Response"
        responseLabel.textColor = .black
        responseLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(responseLabel)
        
        let exampleButton = createButton(title: "example")
        let prevButton = createButton(title: "history")
        let resetButton = createButton(title: "reset")
        
        exampleButton.translatesAutoresizingMaskIntoConstraints = false
        exampleButton.isUserInteractionEnabled = true
        exampleButton.layer.borderWidth = 1
        exampleButton.layer.borderColor = UIColor.lightGray.cgColor
        exampleButton.layer.cornerRadius = 10
        
        view.addSubview(exampleButton)
        
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        prevButton.isUserInteractionEnabled = true
        prevButton.layer.borderWidth = 1
        prevButton.layer.borderColor = UIColor.lightGray.cgColor
        prevButton.layer.cornerRadius = 10
        view.addSubview(prevButton)
        
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.isUserInteractionEnabled = true
        resetButton.layer.borderWidth = 1
        resetButton.layer.borderColor = UIColor.lightGray.cgColor
        resetButton.layer.cornerRadius = 10
        view.addSubview(resetButton)
        
        responseTextView.backgroundColor = .white
        responseTextView.textColor = .black
        responseTextView.text = "Hit send to get a response."
        responseTextView.layer.borderWidth = 1
        
        responseTextView.layer.borderColor = UIColor.lightGray.cgColor
        responseTextView.translatesAutoresizingMaskIntoConstraints = false
        responseTextView.isUserInteractionEnabled = true  // 사용자 상호작용 활성화
        responseTextView.isScrollEnabled = true // 스크롤 가능
        responseTextView.isEditable = false // 수정 불가능
        responseTextView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        //  view.addSubview(responseTextView)
        
        let responseTabStackView = UIStackView()
        responseTabStackView.axis = .horizontal
        responseTabStackView.distribution = .fillEqually
        let bodyButton = createButton(title: "Body2")
        let cookiesButton = createButton(title: "Cookies")
        let headerButton = createButton(title: "Headers2")
        
        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = .lightGray
        view.addSubview(borderView)
        
        
        // 버튼의 텍스트 색상 설정
        bodyButton.setTitleColor(.black, for: .normal)
        cookiesButton.setTitleColor(.black, for: .normal)
        headerButton.setTitleColor(.black, for: .normal)
        buttonArray.append(bodyButton)
        buttonArray.append(cookiesButton)
        buttonArray.append(headerButton)
        
        bodyButton.addTarget(self, action: #selector(changeButtonBackgroundColor(tabButton: )), for: .touchUpInside)
        cookiesButton.addTarget(self, action: #selector(changeButtonBackgroundColor(tabButton: )), for: .touchUpInside)
        headerButton.addTarget(self, action: #selector(changeButtonBackgroundColor(tabButton: )), for: .touchUpInside)
        
        responseTabStackView.addArrangedSubview(bodyButton)
        responseTabStackView.addArrangedSubview(cookiesButton)
        responseTabStackView.addArrangedSubview(headerButton)
        // statusTime, size Body Cookies, Headers 확인
        view.backgroundColor = .white
        view.addSubview(responseTabStackView)
        responseTabStackView.translatesAutoresizingMaskIntoConstraints = false
        
        responseLabel.textAlignment = .center // 텍스트를 가운데 정렬
        
        // 응답값 스크롤
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        
        view.addSubview(responseTextView)
        responseTextView.layoutIfNeeded()
        
        NSLayoutConstraint.activate([
            // responseLabel Constraints
            responseLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10),
            responseLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            //responseLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            responseLabel.heightAnchor.constraint(equalToConstant: 30),
            
            // 버튼관리
            exampleButton.heightAnchor.constraint(equalToConstant: 30),
            exampleButton.leadingAnchor.constraint(equalTo: responseLabel.trailingAnchor, constant: 5),
            exampleButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10),
            exampleButton.widthAnchor.constraint(equalToConstant: 90),
            
            prevButton.heightAnchor.constraint(equalToConstant: 30),
            prevButton.leadingAnchor.constraint(equalTo: exampleButton.trailingAnchor, constant: 5),
            prevButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10),
            prevButton.widthAnchor.constraint(equalToConstant: 90),
            
            resetButton.heightAnchor.constraint(equalToConstant: 30),
            resetButton.leadingAnchor.constraint(equalTo: prevButton.trailingAnchor, constant: 5),
            resetButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10),
            resetButton.widthAnchor.constraint(equalToConstant: 90),
            // borderView Constraints
            borderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            borderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            borderView.topAnchor.constraint(equalTo: responseLabel.bottomAnchor, constant: 10),
            borderView.heightAnchor.constraint(equalToConstant: 1),
            
            // responseTabStackView Constraints
            responseTabStackView.topAnchor.constraint(equalTo: borderView.bottomAnchor, constant: 10), // 수정된 topAnchor
            responseTabStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            responseTabStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            responseTabStackView.heightAnchor.constraint(equalToConstant: 50),
            
            // NSLayoutConstraint.activate([
            responseTextView.topAnchor.constraint(equalTo: responseTabStackView.bottomAnchor, constant: 10),
            responseTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            responseTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            responseTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            
            
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
        cell.backgroundColor = .systemTeal
        
        
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

