//
//  SignupService.swift
//  SOPT_iOS_2ndAssignment2
//
//  Created by SeongEun on 2020/05/21.
//  Copyright © 2020 SeongEun. All rights reserved.
//

import Foundation
import Alamofire

struct SignUpService{
    static let shared = SignUpService()
    
    private func makeParameter(_ id: String, _ pwd: String, _ name: String, _ email: String, _ phone: String) -> Parameters {
        return ["id" : id, "pwd" : pwd, "name" : name, "email" : email, "phone" : phone]
    }
    
    func signUp(id: String, pwd: String, name: String, email: String, phone: String, completion: @escaping (NetworkResult<Any>) -> Void) {
        let header: HTTPHeaders = ["Content-Type": "application/json"]
        
        let dataRequest = Alamofire.request(APIConstants.signupURL, method: .post, parameters: makeParameter(id, pwd, name, email, phone), encoding: JSONEncoding.default, headers: header)
        
        dataRequest.responseData { dataResponse in
            switch dataResponse.result {
            case .success:
                guard let statusCode = dataResponse.response?.statusCode else {return}
                guard let value = dataResponse.result.value else {return}
                let networkResult = self.judge(by: statusCode, value)
                completion(networkResult)
            case .failure: completion(.networkFail)
            }
        }
    }
    
    private func judge(by statusCode: Int, _ data: Data) -> NetworkResult<Any> {
        switch statusCode {
        case 200: return signUp(by: data)
        case 400: return .pathErr
        case 500: return .serverErr
        default: return .networkFail
        }
    }
    
    private func signUp(by data: Data) -> NetworkResult<Any> {
        let decoder = JSONDecoder()
        guard let decodeData = try? decoder.decode(SigninData.self, from: data) else { return .pathErr}
        if decodeData.success { return .success(decodeData.message)}
        else { return .requestErr(decodeData.message)}
    }
}
