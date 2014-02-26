//
//  Event.h
//  Locaion
//
//  Created by 相澤 隆志 on 2014/02/26.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;

@end
