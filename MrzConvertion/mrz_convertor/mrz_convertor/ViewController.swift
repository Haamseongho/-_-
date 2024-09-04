//
//  ViewController.swift
//  mrz_convertor
//
//  Created by haams on 9/3/24.
//

import UIKit
import Foundation
import Vision

class ViewController: UIViewController {
    
    var mrzDict : [String: String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    func extractMRZ(from image: UIImage){
        guard let cgImage = image.cgImage else { return }
        
        // 1. VNRecognizeTextRequest 생성
        let request = VNRecognizeTextRequest { (request, error) in
            // 2. 텍스트 인식 결과 처리
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var index = 0
            // 3. 각 관찰값에서 인식된 텍스트 추출
            for observation in observations {
                if let topCandidate = observation.topCandidates(1).first {
                    print("Recognized Text: \(topCandidate.string)")
                    if(topCandidate.string.contains("<")) {
                        self.mrzDict["mrz\(index)"] = topCandidate.string
                        index += 1
                    }
                }
            }
        }
        
       
        
        // 4. RecognizeTextRequest 설정 (높은 정확도 설정)
        request.recognitionLevel = .accurate
        
        // 5. 요청 핸들러 실행
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
        
        print("mrzDict: \(mrzDict)")
        convertMRZData(mrzDict)
    }
    
    @IBAction func translateMRZ(_ sender: UIButton) {
        let type = sender.currentTitle!
        if type.contains("Pass") {
            print("Passport")
            if let image = UIImage(named: "passport"){
                self.extractMRZ(from: image)
            }
        } else {
            print("IDCard")
            if let image2 = UIImage(named: "idcard"){
                self.extractMRZ(from: image2)
            }
        }
    }
    
    func convertMRZData(_ mrzDict: [String: String]) -> [Int: Any]{
        var convertedDict: [Int: Any] = [:]
        for (key, value) in mrzDict {
            // 1-2: 문서유형
            // 3-5: 발급국가코드
            // 6-14: 신분증번호
            // 15-30: 남은 부분 여백 or 추가정보
            if key == "mrz0" {
                convertedDict[0] = createMRZ0Dict(value)
            }
            
            else if key == "mrz1" {
                convertedDict[1] = createMRZ1Dict(value)
            }
            
            else {
                convertedDict[2] = createMRZ2Dict(value)
            }
        }
        return convertedDict
    }
    
    func createMRZ0Dict(_ mrz: String) -> [String: Any]{
        var mrzDict: [String: Any] = [:]
        let documentTypeLength = 2
        let issuingCountryLength = 3
        let idNumberLength = 10
        let personalNumberLength = 12
        let checkDigitLength = 1
        let fillerLength = 2

        // 추출하기
        let documentType = String(mrz.prefix(documentTypeLength))
        let issuingCountry = String(mrz.dropFirst(documentTypeLength).prefix(issuingCountryLength))
        let idNumber = String(mrz.dropFirst(documentTypeLength + issuingCountryLength).prefix(idNumberLength))
        let personalNumber = String(mrz.dropFirst(documentTypeLength + issuingCountryLength + idNumberLength).prefix(personalNumberLength))
        let checkDigit = String(mrz.dropFirst(documentTypeLength + issuingCountryLength + idNumberLength + personalNumberLength).prefix(checkDigitLength))
        let filler = String(mrz.dropFirst(documentTypeLength + issuingCountryLength + idNumberLength + personalNumberLength + checkDigitLength).prefix(fillerLength))
        let finalCheckDigit = String(mrz.suffix(1))
        // 출력하기
        print("문서 유형: \(documentType)") // ID
        print("발행국 코드: \(issuingCountry)") // VNM
        print("ID 번호: \(idNumber)") // 3010084949
        print("개인 식별 번호: \(personalNumber)") // 036301008494
        
        mrzDict["documentType"] = documentType
        mrzDict["country"] = issuingCountry
        mrzDict["idNumber"] = idNumber
        mrzDict["personalNumber"] = personalNumber
        
        return mrzDict
    }
    
    func createMRZ1Dict(_ mrz: String) -> [String: Any]{
        var mrzDict: [String: Any] = [:]
        let birthDateLength = 6
        let genderLength = 2
        let expireDateLength = 6
        let optionLength = 15
        let digitLength = 1
        
        let birthDate = String(mrz.prefix(birthDateLength))
        let gender = if isCharacterContainsNumber(str: String(mrz.dropFirst(birthDateLength).prefix(genderLength))) {
            String(mrz.dropFirst(birthDateLength).prefix(genderLength)).filter { !$0.isNumber }
        } else {
            String(mrz.dropFirst(birthDateLength).prefix(genderLength))
        }
        
        let expireDate = String(mrz.dropFirst(birthDateLength + genderLength).prefix(expireDateLength))
        let digit = String(mrz.dropFirst(birthDateLength + genderLength + expireDateLength + optionLength).prefix(digitLength))
        
        mrzDict["birthDate"] = birthDate
        mrzDict["gender"] = gender
        mrzDict["expireDate"] = expireDate
        mrzDict["digit"] = digit
        
        print("birhtDate : \(birthDate)")
        print("gender : \(gender)")
        print("expireDate : \(expireDate)")
        print("digit : \(digit)")
        // option은 뺌
        return mrzDict
    }
    
    func createMRZ2Dict(_ mrz: String) -> [String: Any]{
        var mrzDict: [String: Any] = [:]
        let splitter = "<<"
        var index = 0
        for i in 0 ... mrz.count {
            if mrz.prefix(i).contains(splitter) {
                index = i // 성 << 까지 포함해서 위치 뽑기
            }
        }
        var lastName = mrz.prefix(index - 2)
        
        for i in (index + 1) ... mrz.count {
            if mrz.dropFirst(index).prefix(i).contains("<") {
                
            }
        }
        
        return mrzDict
    }
    
    func isCharacterContainsNumber(str: String) -> Bool{
        for character in str {
            if character.isNumber {
                return true
            }
        }
        
        return false
    }
}

