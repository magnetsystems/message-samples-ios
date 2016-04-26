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
#import "MMXSurveyParticipantModel.h"
#import "MMXSurveyType.h"

@class MMXSurveyQuestion;

@interface MMXSurveyDefinition : MMModel


@property (nonatomic, assign) NSDate *startDate;

@property (nonatomic, assign) MMXSurveyParticipantModel  participantModel;

@property (nonatomic, copy) NSArray *questions;

@property (nonatomic, assign) NSDate *endDate;

@property (nonatomic, assign) MMXSurveyParticipantModel  resultAccessModel;

@property (nonatomic, assign) MMXSurveyType  type;

@property (nonatomic, copy) NSString *notificationChannelId;

@end
