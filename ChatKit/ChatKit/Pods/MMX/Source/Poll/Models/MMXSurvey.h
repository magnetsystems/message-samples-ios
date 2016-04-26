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

@class MMXSurveyDefinition;

@interface MMXSurvey : MMModel

@property (nonatomic, copy) NSString *surveyId;

@property (nonatomic, strong) MMXSurveyDefinition *surveyDefinition;

@property (nonatomic, copy) NSArray<NSString *>*resultViewers;

@property (nonatomic, copy) NSArray<NSString *>*participants;

@property (nonatomic, copy) NSArray<NSString *>*owners;

@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *metaData;

@property (nonatomic, copy) NSString *name;

@end
