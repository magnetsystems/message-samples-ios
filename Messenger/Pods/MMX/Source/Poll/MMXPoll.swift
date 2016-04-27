/*
 * Copyright (c) 2015 Magnet Systems, Inc.
 * All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you
 * may not use this file except in compliance with the License. You
 * may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

import MagnetMaxCore

enum MMXPollErrorType : ErrorType {
    case IdEmpty
    case NameEmpty
    case OptionsEmpty
    case QuestionEmpty
}

extension Array where Element : Hashable {
    func exclude(A:Array<Element>) -> Array<Element> {
        var hash = [Int : Element]()
        for val in self {
            hash[val.hashValue] = val
        }
        var excluded = [Element]()
        for val in A {
            if let hashVal = hash[val.hashValue] {
                excluded.append(hashVal)
            }
        }
        return excluded
    }
    
    func union(A:Array<Element>) -> Array<Element> {
        var hash = [Int : Element]()
        for val in self {
            hash[val.hashValue] = val
        }
        var union = [Element]()
        for val in A {
            if let hashVal = hash[val.hashValue] {
                union.append(hashVal)
            }
        }
        return union
    }
}

@objc public class MMXPoll: NSObject {
    
    //MARK: Public Properties
    
    public private(set) var allowMultiChoice = false
    
    public private(set) var channel : MMXChannel?
    
    public let endDate: NSDate?
    
    public var extras: [String:String]?
    
    public let hideResultsFromOthers: Bool
    
    public private(set) var isPublished = false
    
    public private(set) var myVotes: [MMXPollOption]?
    
    public let name: String
    
    public var options: [MMXPollOption]
    
    public private(set) var ownerID: String?
    
    public private(set) var pollID: String?
    
    public let question: String
    
    //MARK: Private Properties
    
    private var underlyingSurvey: MMXSurvey?
    
    //MARK: Init
    
    public convenience init(name: String, question: String, options: [String], hideResultsFromOthers: Bool, endDate: NSDate? = nil, extras: [String:String]? = nil, allowMultiChoice: Bool = false) {
        
        var opts = [MMXPollOption]()
        for option in options {
            let mmxOption = MMXPollOption(text: option, count: 0)
            opts.append(mmxOption)
        }
        self.init(name : name, question: question, mmxPollOptions: opts, hideResultsFromOthers: hideResultsFromOthers, endDate: endDate, extras: extras, allowMultiChoice: allowMultiChoice)
    }
    
    //MARK: Creation
    
    public static func createPoll(name : String, question: String, options: [String], hideResultsFromOthers: Bool, endDate: NSDate? = nil, extras : [String:String]? = nil, allowMultiChoice : Bool = false) -> MMXPoll {
        return MMXPoll(name: name, question: question, options: options, hideResultsFromOthers: hideResultsFromOthers, endDate: endDate, extras: extras, allowMultiChoice: allowMultiChoice)
    }
    
    public static func createPoll(name : String, question: String, options: [String], hideResultsFromOthers: Bool, endDate: NSDate? = nil, extras : [String:String]? = nil) -> MMXPoll {
        return MMXPoll(name: name, question: question, options: options, hideResultsFromOthers: hideResultsFromOthers, endDate: endDate, extras: extras)
    }
    
    public static func createPoll(name : String, question: String, options: [String], hideResultsFromOthers: Bool, endDate: NSDate? = nil) -> MMXPoll {
        return MMXPoll(name: name, question: question, options: options, hideResultsFromOthers: hideResultsFromOthers, endDate: endDate)
    }
    
    public static func createPoll(name : String, question: String, options: [String], hideResultsFromOthers: Bool) -> MMXPoll {
        return MMXPoll(name: name, question: question, options: options, hideResultsFromOthers: hideResultsFromOthers)
    }
    
    //MARK: Private Init
    
    private init(name : String, question: String, mmxPollOptions options: [MMXPollOption], hideResultsFromOthers: Bool, endDate: NSDate?, extras: [String:String]?, allowMultiChoice: Bool) {
        self.question = question
        self.options = options
        self.name = name
        self.hideResultsFromOthers = hideResultsFromOthers
        self.endDate = endDate
        self.ownerID = MMUser.currentUser()?.userID
        self.extras = extras
        self.allowMultiChoice = allowMultiChoice
    }
    
    //MARK: Public Methods
    
    public func choose(option: MMXPollOption, success: ((MMXMessage?) -> Void)?, failure: ((error: NSError) -> Void)?) {
        choose(options: [option], success: success, failure: failure)
    }
    
    public func choose(options option: [MMXPollOption], success: ((MMXMessage?) -> Void)?, failure: ((error: NSError) -> Void)?) {
        
        guard let channel = self.channel else {
            assert(false, "Poll not related to a channel, please submit poll first.")
            
            return
        }
        
        guard option.count <= 1 || (option.count > 1 && self.allowMultiChoice) else {
            assert(false, "Only one option is allowed")
            
            return
        }
        
        var answers = [MMXSurveyAnswer]()
        let previousSelection = myVotes
        
        for opt in option {
            let answer = MMXSurveyAnswer()
            answer.selectedOptionId = opt.optionID
            answer.text = opt.text
            answer.questionId = self.underlyingSurvey?.surveyDefinition.questions.first?.questionId
            answers.append(answer)
        }
        
        let surveyAnswerRequest = MMXSurveyAnswerRequest()
        surveyAnswerRequest.answers = answers
        let call = MMXSurveyService().submitSurveyAnswers(self.pollID, body: surveyAnswerRequest, success: {
            let msg = MMXMessage(toChannel: channel, messageContent: [kQuestionKey: self.question], pushConfigName: kDefaultPollAnswerPushConfigNameKey)
            let result = MMXPollAnswer(self, selectedOptions: option, previousSelection: previousSelection)
            result.userID = MMUser.currentUser()?.userID ?? ""
            msg.payload = result
            self.myVotes = option
            if self.hideResultsFromOthers {
                success?(nil)
            } else {
                msg.sendWithSuccess({ [weak msg] users in
                    if let weakMessage = msg {
                        success?(weakMessage)
                    }
                    }, failure: { error in
                        failure?(error: error)
                })
            }
            }, failure: { error in
                failure?(error: error)
        })
        call.executeInBackground(nil)
    }
    
    public func mmxPayload() -> MMXPollIdentifier? {
        return self.pollID != nil ? MMXPollIdentifier(self.pollID!) : nil
    }
    
    public func refreshResults(answer answer: MMXPollAnswer) {
        if let previous = answer.previousSelection {
            for option in self.options.union(previous) {
                if let count = option.count {
                    option.count = count.integerValue - 1
                }
            }
        }
        
        for option in self.options.union(answer.currentSelection) {
            if let count = option.count {
                option.count = count.integerValue + 1
            }
        }
        if answer.userID == MMUser.currentUser()?.userID {
            self.myVotes = answer.currentSelection
        }
    }
    
    public func refreshResults(completion completion:((poll : MMXPoll?) -> Void)) {
        guard let pollID = self.pollID else {
            completion(poll: nil)
            return
        }
        MMXPoll.pollWithID(pollID, success: { (poll) in
            var hashMap = [Int: MMXPollOption]()
            for option in poll.options {
                hashMap[option.hashValue] = option
            }
            for option in self.options {
                option.count = hashMap[option.hashValue]?.count ?? 0
            }
            
            self.myVotes = poll.myVotes
            
            let comp = {[weak self] in
                completion(poll: self)
            }
            comp()
        }) { (error) in
            completion(poll: nil)
        }
    }
    
    //MARK: Public Static Methods
    //MARK: Publish
    public func publish(channel channel: MMXChannel,success: ((MMXMessage) -> Void)?, failure: ((error: NSError) -> Void)?) {
        let msg = MMXMessage(toChannel: channel, messageContent: [kQuestionKey: question], pushConfigName: kDefaultPollPushConfigNameKey)
        publish(message: msg, success: success, failure: failure)
    }
    
    private func publish(message message: MMXMessage, success: ((MMXMessage) -> Void)?, failure: ((error: NSError) -> Void)?) {
        guard let channel = message.channel as MMXChannel? else {
            assert(false, "Channel must be set on message for poll")
            return
        }
        
        createPoll(channel, success: {
            message.payload = self.mmxPayload();
            message.sendWithSuccess({ [weak message] users in
                self.isPublished = true
                if let weakMessage = message {
                    success?(weakMessage)
                }
                }, failure: { error in
                    failure?(error: error)
            })
            }, failure: { error in
                failure?(error: error)
        })
    }
    
    //MARK: Poll retrieval
    
    static public func pollFromMessage(message: MMXMessage, success: ((MMXPoll) -> Void), failure: ((error: NSError) -> Void)?) {
        if let payload = message.payload as? MMXPayload, let channel = message.channel {
            pollFromMMXPayload(payload, success: success, failure: failure)
        } else {
            let error = MMXClient.errorWithTitle("Poll", message: "Incompatible Message", code: 500)
            failure?(error : error)
        }
    }
    
    static public func pollWithID(pollID: String, success: ((MMXPoll) -> Void), failure: ((error: NSError) -> Void)?) {
        let service = MMXSurveyService()
        let call = service.getSurvey(pollID, success: {[weak service] survey in
            let call = service?.getResults(survey.surveyId, success: { surveyResults in
                MMXChannel.channelForID(survey.surveyDefinition.notificationChannelId, success: { (channel) in
                    do {
                        let poll = try self.pollFromSurveyResults(surveyResults, channel: channel)
                        success(poll)
                    } catch {
                        let error = MMXClient.errorWithTitle("Poll", message: "Error Parsing Poll", code: 400)
                        failure?(error : error)
                    }
                    }, failure: { (error) in
                        failure?(error : error)
                })
                }, failure: { error in
                    failure?(error : error)
            })
            call?.executeInBackground(nil)
            }, failure: { error in
                failure?(error : error)
        })
        call.executeInBackground(nil)
    }
    
    //MARK Private Static Methods
    
    private func createPoll(channel: MMXChannel, success: (() -> Void), failure: ((error: NSError) -> Void)) {
        
        guard let user = MMUser.currentUser() else  {
            let error = MMXClient.errorWithTitle("Login", message: "Must be logged in to use this API", code: 401)
            failure(error: error)
            return
        }
        
        let survey = MMXPoll.generateSurvey(channel: channel, owner: user, name: self.name, question: self.question, options: self.options, hideResultsFromOthers: self.hideResultsFromOthers, endDate: self.endDate, extras: self.extras, allowMultiChoice: self.allowMultiChoice)
        let call = MMXSurveyService().createSurvey(survey, success: { survey in
            let error = MMXClient.errorWithTitle("Poll", message: "Error Parsing Poll", code: 400)
            
            guard survey.surveyId != nil else {
                failure(error: error)
                return
            }
            
            self.pollID = survey.surveyId
            success()
            }, failure: { error in
                failure(error: error)
        })
        call.executeInBackground(nil)
    }
    
    private static func generateSurvey(channel channel: MMXChannel, owner: MMUser,name: String, question: String,  options: [MMXPollOption], hideResultsFromOthers: Bool, endDate: NSDate?, extras: [String : String]?, allowMultiChoice: Bool) -> MMXSurvey {
        let survey = MMXSurvey()
        survey.owners = [owner.userID]
        survey.name = name
        survey.metaData = extras
        let surveyDefinition = MMXSurveyDefinition()
        surveyDefinition.startDate = NSDate()
        surveyDefinition.endDate = endDate
        surveyDefinition.type = .POLL
        surveyDefinition.resultAccessModel = hideResultsFromOthers ? .PRIVATE : .PUBLIC
        surveyDefinition.participantModel = .PUBLIC
        survey.surveyDefinition = surveyDefinition
        let surveyQuestion = MMXSurveyQuestion()
        surveyQuestion.text = question
        surveyDefinition.notificationChannelId = channel.channelID
        var index = 0
        let surveyOptions : [MMXSurveyOption] = options.map({
            let option = MMXSurveyOption()
            option.displayOder = Int32(index)
            index += 1
            option.value = $0.text
            option.metaData = $0.extras
            
            return option
        })
        
        surveyQuestion.choices = surveyOptions
        surveyQuestion.displayOrder = 0
        surveyQuestion.type = allowMultiChoice ? .MULTI_CHOICE : .SINGLE_CHOICE
        surveyDefinition.questions = [surveyQuestion]
        
        return survey
    }
    
    private static func pollFromSurveyResults(results : MMXSurveyResults, channel : MMXChannel) throws -> MMXPoll {
        let survey = results.survey
        guard let sid = survey.surveyId else {
            throw MMXPollErrorType.IdEmpty
        }
        
        guard let name = survey.name else {
            throw MMXPollErrorType.NameEmpty
        }
        
        guard let question = survey.surveyDefinition.questions.first else {
            throw MMXPollErrorType.QuestionEmpty
        }
        
        guard let options = survey.surveyDefinition.questions.first?.choices else {
            throw MMXPollErrorType.OptionsEmpty
        }
        
        let hideResultsFromOthers = survey.surveyDefinition.resultAccessModel == .PRIVATE
        let endDate = survey.surveyDefinition.endDate
        
        var choiceMap = [String : MMXSurveyChoiceResult]()
        for choiceResult in results.summary {
            choiceMap[choiceResult.selectedChoiceId] = choiceResult
        }
        
        var pollOptions: [MMXPollOption] = []
        var myAnswers : [MMXPollOption] = []
        for option in options {
            let count : NSNumber? = choiceMap[option.optionId] != nil ? NSNumber(longLong: choiceMap[option.optionId]!.count) : nil
            let pollOption = MMXPollOption(text: option.value, count: count)
            pollOption.pollID = survey.surveyId
            pollOption.optionID = option.optionId
            pollOption.extras = option.metaData
            if results.myAnswers.map({$0.selectedOptionId}).contains(option.optionId) {
                myAnswers.append(pollOption)
            }
            pollOptions.append(pollOption)
        }
        
        let poll = MMXPoll.init(name: name, question: question.text, mmxPollOptions: pollOptions, hideResultsFromOthers: hideResultsFromOthers, endDate: endDate, extras: survey.metaData, allowMultiChoice: question.type == .MULTI_CHOICE)
        poll.underlyingSurvey = survey
        poll.myVotes = myAnswers
        poll.ownerID = survey.owners.first
        poll.pollID = sid
        poll.channel = channel
        poll.isPublished = true
        
        return poll
    }
    
    static private func pollFromMMXPayload(payload : MMXPayload?, success: ((MMXPoll) -> Void), failure: ((error: NSError) -> Void)?) {
        if let pollIdentifier = payload as? MMXPollIdentifier {
            self.pollWithID(pollIdentifier.pollID, success: success, failure: failure)
        } else if let pollID = (payload as? MMXPollAnswer)?.pollID {
            self.pollWithID(pollID, success: success, failure: failure)
        } else {
            let error = MMXClient.errorWithTitle("Poll", message: "Incompatible Object Type", code: 500)
            failure?(error : error)
        }
    }
}

// MARK: MMXPoll Equality

extension MMXPoll {
    
    override public var hash: Int {
        return pollID?.hashValue ?? 0
    }
    
    override public func isEqual(object: AnyObject?) -> Bool {
        if let rhs = object as? MMXPoll {
            return pollID == rhs.pollID
        }
        
        return false
        
    }
}
