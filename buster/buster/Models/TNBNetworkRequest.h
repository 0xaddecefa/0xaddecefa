//
//  TNBNetworkRequest.h
//  buster
//
//  Created by Tamas Nemeth on 06/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TNBNetworkRequest;

typedef void (^CompletionBlock)(TNBNetworkRequest *operation, id responseObject);
typedef void (^FailureBlock)(TNBNetworkRequest *operation, NSError *error);

@interface TNBNetworkRequest : NSObject

- (instancetype)initWithURLString: (NSString *)URL
					   parameters: (id)parameters
						  success: (CompletionBlock)complete
						  failure: (FailureBlock)fail;

@property (nonatomic, strong, readonly) NSString* URLString;
@property (nonatomic, strong, readonly) id parameters;

@property (nonatomic, copy, readonly) CompletionBlock complete;
@property (nonatomic, copy, readonly) FailureBlock fail;


@end
