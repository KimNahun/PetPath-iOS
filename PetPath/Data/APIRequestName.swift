//
//  APIRequestName.swift
//  PetPath
//
//  Created by 김나훈 on 3/4/25.
//

import Foundation

enum APIRequestName: String {
    // User
    case getCertResult = "GetCertResult"
    case getIsEmailUsing = "GetIsEmailUsing"
    case signUp = "SignUp"
    case findUserId = "FindUserId"
    case findUserPassword = "FindUserPassword"
    case signIn = "SignIn"
    case getUserInfo = "GetUserInfo"
    case setAccountType = "SetAccountType"
    case setPushToken = "SetPushToken"
    case getUserFullInfo = "GetUserFullInfo"
    case modifyUserInfo = "ModifyUserInfo"
    case deleteAccount = "DeleteAccount"
    case getPushAlertSetting = "GetPushAlertSetting"
    case modifyPushAlertSetting = "ModifyPushAlertSetting"
    
    // Dog
    case getDogCertInfoValid = "GetDogCertInfoValid"
    case getKeywordTagList = "GetKeywordTagList"
    case registMyDog = "RegistMyDog"
    case getMyDogList = "GetMyDogList"
    case getMyDogDetail = "GetMyDogDetail"
    case modifyDogInfo = "ModifyDogInfo"
    case deleteMyDog = "DeleteMyDog"
    
    // Payment
    case addCard = "AddCard"
    case getCardList = "GetCardList"
    case deleteCard = "DeleteCard"
    case getPaymentHistory = "GetPaymentHistory"
    case getCouponList = "GetCouponList" // 견주
    case getAvailableCouponList = "GetAvailableCouponList" // 견주
    case getActualPayPrice = "GetActualPayPrice"
    case getWalkPaymentInfo = "GetWalkPaymentInfo"
    case getWalkPayoutInfo = "GetWalkPayoutInfo"
    case getPayoutContract = "GetPayoutContract"
    case modifyPayoutContract = "ModifyPayoutContract"
    case getAvailablePayoutAmount = "GetAvailablePayoutAmount"
    case getPayoutHistory = "GetPayoutHistory"
    case getPayoutDetail = "GetPayoutDetail"
    case requestPayout = "RequestPayout"
    case calcCancelWalkPenalty = "CalcCancelWalkPenalty"
    
    // Walk
    case getRecentWalkPath = "GetRecentWalkPath" // 견주
    case getRecentPickupPosition = "GetRecentPickupPosition"
    case getWalkPredictPrice = "GetWalkPredictPrice"
    case requestWalk = "RequestWalk"
    case getWalkRequestList = "GetWalkRequestList"
    case getWalkHistoryList = "GetWalkHistoryList"
    case getWalkDetail = "GetWalkDetail"
    case applyWalker = "ApplyWalker"
    case getApplyWalkerList = "GetApplyWalkerList"
    case getWalkerWalkApplied = "GetWalkerWalkApplied"
    case cancelWalkApply = "CancelWalkApply"
    case getMatchedWalkerInfo = "GetMatchedWalkerInfo"
    case matchWalker = "MatchWalker"
    case startWalk = "StartWalk"
    case endWalk = "EndWalk"
    case cancelWalk = "CancelWalk"
    case requestReport = "RequestReport"
    case getWalkerTrainStatus = "GetWalkerTrainStatus"
    case getWalkerTrainList = "GetWalkerTrainList"
    case getWalkerTrainContent = "GetWalkerTrainContent"
    case setWalkerTrainProgress = "SetWalkerTrainProgress"
    case getWalkerTrainQuiz = "GetWalkerTrainQuiz"
    case submitWalkerTrainQuiz = "SubmitWalkerTrainQuiz"
    case pushWalkPosition = "PushWalkPosition"
    case getMainCurrentWalkList = "GetMainCurrentWalkList"
    
    // Chat
    case getChatRoomList = "GetChatRoomList"
    case getUnreadChatIndex = "GetUnreadChatIndex"
    case getChatHistory = "GetChatHistory"
    
    // Util
    case searchAddressByKeyword = "SearchAddressByKeyword"
    case positionToAddress = "PositionToAddress"
    case getMainNotice = "GetMainNotice"
    case getAppVersion = "GetAppVersion"
}
