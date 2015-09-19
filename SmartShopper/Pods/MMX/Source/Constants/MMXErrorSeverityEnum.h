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

/**
 *  Used as an indication of the severity an error.
 */
typedef NS_ENUM(NSInteger, MMXErrorSeverity){
	/**
	 *  No error.
	 */
	MMXErrorSeverityNone = 0,
	/**
	 *  The server is unable to quantify the severity of the error.
	 */
	MMXErrorSeverityUnknown,
	/**
	 *  Most likely a user error.
	 */
	MMXErrorSeverityTrivial,
	/**
	 *  An error that a simple rety should solve the error.
	 */
	MMXErrorSeverityTemporary,
	/**
	 *  An error that suggests this operation should be avoided
	 */
	MMXErrorSeverityMajor,
	/**
	 *  An issue in the server that client should abort or exit
	 */
	MMXErrorSeverityCritical
};
