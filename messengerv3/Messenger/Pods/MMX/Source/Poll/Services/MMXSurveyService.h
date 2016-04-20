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

@import MagnetMaxCore;

@class MMXSurvey;
@class MMXSurveyAnswer;
@class MMXSurveyResults;
@class MMXSurveyResponse;
@class MMXSurveyAnswerRequest;

@protocol MMXSurveyServiceProtocol <NSObject>

@optional
/**
 
 GET /com.magnet.server/surveys/survey/{surveyId}/poll/results
 @param surveyId style:PATH
 @return A 'MMCall' object.
 */
- (MMCall *)getResults:(NSString *)surveyId
               success:(void (^)(MMXSurveyResults *response))success
               failure:(void (^)(NSError *error))failure;
/**
 
 PUT /com.magnet.server/surveys/answers/{surveyId}
 @param surveyId style:PATH
 @param body style:BODY
 @return A 'MMCall' object.
 */
- (MMCall *)submitSurveyAnswers:(NSString *)surveyId
                           body:(MMXSurveyAnswerRequest *)body
                        success:(void (^)())success
                        failure:(void (^)(NSError *error))failure;
/**
 
 GET /com.magnet.server/surveys/answers/{surveyId}
 @param surveyId style:PATH
 @return A 'MMCall' object.
 */
- (MMCall *)getSurveyAnswers:(NSString *)surveyId
                     success:(void (^)(NSArray<MMXSurveyResponse *>*response))success
                     failure:(void (^)(NSError *error))failure;
/**
 
 PUT /com.magnet.server/surveys/survey/{surveyId}
 @param surveyId style:PATH
 @param body style:BODY
 @return A 'MMCall' object.
 */
- (MMCall *)updateSurvey:(NSString *)surveyId
                    body:(MMXSurvey *)body
                 success:(void (^)(MMXSurvey *response))success
                 failure:(void (^)(NSError *error))failure;
/**
 
 GET /com.magnet.server/surveys/survey/{surveyId}
 @param surveyId style:PATH
 @return A 'MMCall' object.
 */
- (MMCall *)getSurvey:(NSString *)surveyId
              success:(void (^)(MMXSurvey *response))success
              failure:(void (^)(NSError *error))failure;
/**
 
 DELETE /com.magnet.server/surveys/survey/{surveyId}
 @param surveyId style:PATH
 @return A 'MMCall' object.
 */
- (MMCall *)deleteSurvey:(NSString *)surveyId
                 success:(void (^)())success
                 failure:(void (^)(NSError *error))failure;
/**
 
 POST /com.magnet.server/surveys/survey
 @param body style:BODY
 @return A 'MMCall' object.
 */
- (MMCall *)createSurvey:(MMXSurvey *)body
                 success:(void (^)(MMXSurvey *response))success
                 failure:(void (^)(NSError *error))failure;

@end

@interface MMXSurveyService : MMService<MMXSurveyServiceProtocol>

@end
