//
//  TNBImageConfigurationModel.h
//  buster
//
//  Created by Tamas Nemeth on 07/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TNBImageConfigurationModel : NSObject

@property (nonatomic, strong, readonly) NSString *baseURL;
@property (nonatomic, strong, readonly) NSDictionary *posterSizes;
@property (nonatomic, strong, readonly) NSDictionary *backdropSizes;

- (instancetype) initWithDictionary: (NSDictionary *)dictionary;
@end
