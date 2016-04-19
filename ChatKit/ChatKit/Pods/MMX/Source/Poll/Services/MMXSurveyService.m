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

#import "MMXSurveyService.h"
#import "MMXSurvey.h"
#import "MMXSurveyResponse.h"
#import "MMXSurveyAnswer.h"
#import "MMXSurveyResults.h"
#import "MMXSurveyAnswerRequest.h"

@implementation MMXSurveyService

+ (NSDictionary *)metaData {
    static NSDictionary *__metaData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *serviceMetaData = [NSMutableDictionary dictionary];
        
        
        // schema for service method getResults:success:failure:
        MMServiceMethod *getResultsSuccessFailure = [[MMServiceMethod alloc] init];
        getResultsSuccessFailure.clazz = [self class];
        getResultsSuccessFailure.selector = @selector(getResults:success:failure:);
        getResultsSuccessFailure.path = @"com.magnet.server/surveys/survey/{surveyId}/poll/results";
        getResultsSuccessFailure.requestMethod = MMRequestMethodGET;
        getResultsSuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
        getResultsSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];
        
        NSMutableArray *getResultsSuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *getResultsSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        getResultsSuccessFailureParam0.name = @"surveyId";
        getResultsSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypePath;
        getResultsSuccessFailureParam0.type = MMServiceIOTypeString;
        getResultsSuccessFailureParam0.isOptional = NO;
        [getResultsSuccessFailureParams addObject:getResultsSuccessFailureParam0];
        
        getResultsSuccessFailure.parameters = getResultsSuccessFailureParams;
        getResultsSuccessFailure.returnType = MMServiceIOTypeMagnetNode;
        getResultsSuccessFailure.returnTypeClass = MMXSurveyResults.class;
        serviceMetaData[NSStringFromSelector(getResultsSuccessFailure.selector)] = getResultsSuccessFailure;
        
        // schema for service method submitSurveyAnswers:body:success:failure:
        MMServiceMethod *submitSurveyAnswersBodySuccessFailure = [[MMServiceMethod alloc] init];
        submitSurveyAnswersBodySuccessFailure.clazz = [self class];
        submitSurveyAnswersBodySuccessFailure.selector = @selector(submitSurveyAnswers:body:success:failure:);
        submitSurveyAnswersBodySuccessFailure.path = @"com.magnet.server/surveys/answers/{surveyId}";
        submitSurveyAnswersBodySuccessFailure.requestMethod = MMRequestMethodPUT;
        submitSurveyAnswersBodySuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
        submitSurveyAnswersBodySuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];
        
        NSMutableArray *submitSurveyAnswersBodySuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *submitSurveyAnswersBodySuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        submitSurveyAnswersBodySuccessFailureParam0.name = @"surveyId";
        submitSurveyAnswersBodySuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypePath;
        submitSurveyAnswersBodySuccessFailureParam0.type = MMServiceIOTypeString;
        submitSurveyAnswersBodySuccessFailureParam0.isOptional = NO;
        [submitSurveyAnswersBodySuccessFailureParams addObject:submitSurveyAnswersBodySuccessFailureParam0];
        
        MMServiceMethodParameter *submitSurveyAnswersBodySuccessFailureParam1 = [[MMServiceMethodParameter alloc] init];
        submitSurveyAnswersBodySuccessFailureParam1.name = @"body";
        submitSurveyAnswersBodySuccessFailureParam1.requestParameterType = MMServiceMethodParameterTypeBody;
        submitSurveyAnswersBodySuccessFailureParam1.type = MMServiceIOTypeMagnetNode;
        submitSurveyAnswersBodySuccessFailureParam1.typeClass = MMXSurveyAnswerRequest.class;
        submitSurveyAnswersBodySuccessFailureParam1.isOptional = NO;
        [submitSurveyAnswersBodySuccessFailureParams addObject:submitSurveyAnswersBodySuccessFailureParam1];
        
        submitSurveyAnswersBodySuccessFailure.parameters = submitSurveyAnswersBodySuccessFailureParams;
        submitSurveyAnswersBodySuccessFailure.returnType = MMServiceIOTypeVoid;
        serviceMetaData[NSStringFromSelector(submitSurveyAnswersBodySuccessFailure.selector)] = submitSurveyAnswersBodySuccessFailure;
        
        // schema for service method getSurveyAnswers:success:failure:
        MMServiceMethod *getSurveyAnswersSuccessFailure = [[MMServiceMethod alloc] init];
        getSurveyAnswersSuccessFailure.clazz = [self class];
        getSurveyAnswersSuccessFailure.selector = @selector(getSurveyAnswers:success:failure:);
        getSurveyAnswersSuccessFailure.path = @"com.magnet.server/surveys/answers/{surveyId}";
        getSurveyAnswersSuccessFailure.requestMethod = MMRequestMethodGET;
        getSurveyAnswersSuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
        getSurveyAnswersSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];
        
        NSMutableArray *getSurveyAnswersSuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *getSurveyAnswersSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        getSurveyAnswersSuccessFailureParam0.name = @"surveyId";
        getSurveyAnswersSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypePath;
        getSurveyAnswersSuccessFailureParam0.type = MMServiceIOTypeString;
        getSurveyAnswersSuccessFailureParam0.isOptional = NO;
        [getSurveyAnswersSuccessFailureParams addObject:getSurveyAnswersSuccessFailureParam0];
        
        getSurveyAnswersSuccessFailure.parameters = getSurveyAnswersSuccessFailureParams;
        getSurveyAnswersSuccessFailure.returnType = MMServiceIOTypeArray;
        getSurveyAnswersSuccessFailure.returnComponentType = MMServiceIOTypeMagnetNode;
        getSurveyAnswersSuccessFailure.returnTypeClass = MMXSurveyResponse.class;
        serviceMetaData[NSStringFromSelector(getSurveyAnswersSuccessFailure.selector)] = getSurveyAnswersSuccessFailure;
        
        // schema for service method updateSurvey:body:success:failure:
        MMServiceMethod *updateSurveyBodySuccessFailure = [[MMServiceMethod alloc] init];
        updateSurveyBodySuccessFailure.clazz = [self class];
        updateSurveyBodySuccessFailure.selector = @selector(updateSurvey:body:success:failure:);
        updateSurveyBodySuccessFailure.path = @"com.magnet.server/surveys/survey/{surveyId}";
        updateSurveyBodySuccessFailure.requestMethod = MMRequestMethodPUT;
        updateSurveyBodySuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
        updateSurveyBodySuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];
        
        NSMutableArray *updateSurveyBodySuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *updateSurveyBodySuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        updateSurveyBodySuccessFailureParam0.name = @"surveyId";
        updateSurveyBodySuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypePath;
        updateSurveyBodySuccessFailureParam0.type = MMServiceIOTypeString;
        updateSurveyBodySuccessFailureParam0.isOptional = NO;
        [updateSurveyBodySuccessFailureParams addObject:updateSurveyBodySuccessFailureParam0];
        
        MMServiceMethodParameter *updateSurveyBodySuccessFailureParam1 = [[MMServiceMethodParameter alloc] init];
        updateSurveyBodySuccessFailureParam1.name = @"body";
        updateSurveyBodySuccessFailureParam1.requestParameterType = MMServiceMethodParameterTypeBody;
        updateSurveyBodySuccessFailureParam1.type = MMServiceIOTypeMagnetNode;
        updateSurveyBodySuccessFailureParam1.typeClass = MMXSurvey.class;
        updateSurveyBodySuccessFailureParam1.isOptional = NO;
        [updateSurveyBodySuccessFailureParams addObject:updateSurveyBodySuccessFailureParam1];
        
        updateSurveyBodySuccessFailure.parameters = updateSurveyBodySuccessFailureParams;
        updateSurveyBodySuccessFailure.returnType = MMServiceIOTypeMagnetNode;
        updateSurveyBodySuccessFailure.returnTypeClass = MMXSurvey.class;
        serviceMetaData[NSStringFromSelector(updateSurveyBodySuccessFailure.selector)] = updateSurveyBodySuccessFailure;
        
        // schema for service method getSurvey:success:failure:
        MMServiceMethod *getSurveySuccessFailure = [[MMServiceMethod alloc] init];
        getSurveySuccessFailure.clazz = [self class];
        getSurveySuccessFailure.selector = @selector(getSurvey:success:failure:);
        getSurveySuccessFailure.path = @"com.magnet.server/surveys/survey/{surveyId}";
        getSurveySuccessFailure.requestMethod = MMRequestMethodGET;
        getSurveySuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
        getSurveySuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];
        
        NSMutableArray *getSurveySuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *getSurveySuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        getSurveySuccessFailureParam0.name = @"surveyId";
        getSurveySuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypePath;
        getSurveySuccessFailureParam0.type = MMServiceIOTypeString;
        getSurveySuccessFailureParam0.isOptional = NO;
        [getSurveySuccessFailureParams addObject:getSurveySuccessFailureParam0];
        
        getSurveySuccessFailure.parameters = getSurveySuccessFailureParams;
        getSurveySuccessFailure.returnType = MMServiceIOTypeMagnetNode;
        getSurveySuccessFailure.returnTypeClass = MMXSurvey.class;
        serviceMetaData[NSStringFromSelector(getSurveySuccessFailure.selector)] = getSurveySuccessFailure;
        
        // schema for service method deleteSurvey:success:failure:
        MMServiceMethod *deleteSurveySuccessFailure = [[MMServiceMethod alloc] init];
        deleteSurveySuccessFailure.clazz = [self class];
        deleteSurveySuccessFailure.selector = @selector(deleteSurvey:success:failure:);
        deleteSurveySuccessFailure.path = @"com.magnet.server/surveys/survey/{surveyId}";
        deleteSurveySuccessFailure.requestMethod = MMRequestMethodDELETE;
        deleteSurveySuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
        deleteSurveySuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];
        
        NSMutableArray *deleteSurveySuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *deleteSurveySuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        deleteSurveySuccessFailureParam0.name = @"surveyId";
        deleteSurveySuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypePath;
        deleteSurveySuccessFailureParam0.type = MMServiceIOTypeString;
        deleteSurveySuccessFailureParam0.isOptional = NO;
        [deleteSurveySuccessFailureParams addObject:deleteSurveySuccessFailureParam0];
        
        deleteSurveySuccessFailure.parameters = deleteSurveySuccessFailureParams;
        deleteSurveySuccessFailure.returnType = MMServiceIOTypeVoid;
        serviceMetaData[NSStringFromSelector(deleteSurveySuccessFailure.selector)] = deleteSurveySuccessFailure;
        
        // schema for service method createSurvey:success:failure:
        MMServiceMethod *createSurveySuccessFailure = [[MMServiceMethod alloc] init];
        createSurveySuccessFailure.clazz = [self class];
        createSurveySuccessFailure.selector = @selector(createSurvey:success:failure:);
        createSurveySuccessFailure.path = @"com.magnet.server/surveys/survey";
        createSurveySuccessFailure.requestMethod = MMRequestMethodPOST;
        createSurveySuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
        createSurveySuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];
        
        NSMutableArray *createSurveySuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *createSurveySuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        createSurveySuccessFailureParam0.name = @"body";
        createSurveySuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypeBody;
        createSurveySuccessFailureParam0.type = MMServiceIOTypeMagnetNode;
        createSurveySuccessFailureParam0.typeClass = MMXSurvey.class;
        createSurveySuccessFailureParam0.isOptional = NO;
        [createSurveySuccessFailureParams addObject:createSurveySuccessFailureParam0];
        
        createSurveySuccessFailure.parameters = createSurveySuccessFailureParams;
        createSurveySuccessFailure.returnType = MMServiceIOTypeMagnetNode;
        createSurveySuccessFailure.returnTypeClass = MMXSurvey.class;
        serviceMetaData[NSStringFromSelector(createSurveySuccessFailure.selector)] = createSurveySuccessFailure;
        
        
        __metaData = serviceMetaData;
    });
    
    return __metaData;
}

@end
