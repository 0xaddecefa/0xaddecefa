//
//  TNBNetworkRequest.m
//  buster
//
//  Created by Tamas Nemeth on 06/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import "TNBNetworkRequest.h"

@interface TNBNetworkRequest()
@property (nonatomic, strong, readwrite) NSString* URLString;
@property (nonatomic, strong, readwrite) id parameters;

@property (nonatomic, copy, readwrite) CompletionBlock complete;
@property (nonatomic, copy, readwrite) FailureBlock fail;

@end

@implementation TNBNetworkRequest

- (instancetype)initWithURLString: (NSString *)URL
					   parameters: (id)parameters
						  success: (CompletionBlock)complete
						  failure: (FailureBlock)fail {
	self = [self init];
	if (self) {
		self.URLString = URL;
		self.parameters = parameters;
		self.complete = complete;
		self.fail = fail;
	}

	return self;
}

@end
