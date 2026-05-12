//
//  CommonNetworkService.swift
//  PetPath
//
//  Created by 김나훈 on 3/3/25.
//

import Moya
import UIKit

final class CommonNetworkService {
    
    private let provider = MoyaProvider<CommonAPI>()
    static func setAllButtonsEnabledGlobally(_ enabled: Bool) {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first(where: { $0.isKeyWindow }) else {
            return
        }
        setAllButtonsEnabled(enabled, in: window)
    }
    
    private static func setAllButtonsEnabled(_ enabled: Bool, in view: UIView) {
        for subview in view.subviews {
            if subview is UINavigationBar { continue }

            // UITableViewCell
            if let tableCell = subview as? UITableViewCell {
                tableCell.isUserInteractionEnabled = enabled
                setAllButtonsEnabled(enabled, in: tableCell.contentView)
                continue
            }

            // UICollectionViewCell
            if let collectionCell = subview as? UICollectionViewCell {
                collectionCell.isUserInteractionEnabled = enabled
                setAllButtonsEnabled(enabled, in: collectionCell.contentView)
                continue
            }

            // UIButton
            if let button = subview as? UIButton {
                button.isUserInteractionEnabled = enabled
            }

            // 다른 하위 뷰 재귀
            setAllButtonsEnabled(enabled, in: subview)
        }
    }
    func requestSingleOperation<Param: Encodable, T: Decodable, Code: Error>(
        operationName: String,
        param: Param,
        successType: T.Type,
        codeInit: @escaping (String) -> Code
    ) async throws -> T {
        let notTracking = operationName != APIRequestName.pushWalkPosition.rawValue
        
        if notTracking {
            await MainActor.run {
            //    Self.setAllButtonsEnabledGlobally(false)
            }
        }
        
        defer {
            if notTracking {
                DispatchQueue.main.async {
             //       Self.setAllButtonsEnabledGlobally(true)
                }
            }
        }
        
        do {
            // 1) 요청 객체 생성
            let requestObj = OperationRequest(operation: operationName, param: param)
            let anyRequest = AnyEncodable(requestObj)
            print("\n❇️Request created: \(requestObj)❇️\n")
            
            // 2) 네트워크 요청
            let response = try await provider.requestAsync(.sendOperations([anyRequest]))
            print("\n🟨Status code: \(response.statusCode)🟨\n")
            
            // 3) 서버 응답 디코딩
            let baseArr = try JSONDecoder().decode([CommonResponse<T>].self, from: response.data)
            guard let base = baseArr.first else {
                throw CommonAPIError<Code>(
                    code: codeInit("unknown_error"),
                    message: "서버 응답 파싱 실패: 응답 배열이 비어 있음",
                    target: nil
                )
            }
            
            // 4) 서버 코드 체크
            guard base.response == 200 else {
                print("\n🟥not 200. \(base.errorCode ?? "unknown_error") 🟥\n🟥message: \(base.message ?? "no message")🟥\n")
                
                // ⚡️ 에러 발생 시 -> raw Data 그대로 넘김
                let error = CommonAPIError<Code>(
                    code: codeInit(base.errorCode ?? "unknown_error"),
                    message: base.message,
                    target: base.target,
                    underlying: nil,
                    data: response.data // <- 여기!
                )
                throw error
            }
            
            // 5) 정상 데이터 반환
            print("\n🟪data: \(String(describing: base.data))🟪\n")
            
            if T.self == EmptyResponse.self, base.data == nil {
                return EmptyResponse() as! T
            }
            
            guard let data = base.data else {
                throw CommonAPIError<Code>(
                    code: codeInit("unknown_error"),
                    message: "서버 응답 파싱 실패: 응답 데이터가 없음",
                    target: nil
                )
            }
            
            return data
            
        } catch let moyaErr as MoyaError {
            print("[DEBUG] MoyaError occurred: \(moyaErr)")
            throw CommonAPIError<Code>(
                code: codeInit("network_error"),
                message: moyaErr.localizedDescription,
                target: nil
            )
        } catch let decErr as DecodingError {
            print("[DEBUG] DecodingError occurred: \(decErr)")
            throw CommonAPIError<Code>(
                code: codeInit("decode_error"),
                message: "응답 디코딩 실패",
                target: nil
            )
        } catch let apiError as CommonAPIError<Code> {
            throw apiError
        } catch {
            print("[DEBUG] Unknown error occurred: \(error)")
            throw CommonAPIError<Code>(
                code: codeInit("unknown_error"),
                message: error.localizedDescription,
                target: nil
            )
        }
    }
}

extension CommonNetworkService {
    func request<T: Decodable, Code: Error>(
        operation: APIRequestName,
        param: Encodable,
        successType: T.Type,
        codeInit: @escaping (String) -> Code
    ) async throws -> T {
        print("[DEBUG] Operation: \(operation.rawValue)")
        return try await requestSingleOperation(
            operationName: operation.rawValue,
            param: param,
            successType: successType,
            codeInit: codeInit
        )
    }
}
