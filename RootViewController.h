//
//  RootViewController.h
//  Locaion
//
//  Created by 相澤 隆志 on 2014/02/26.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RootViewController : UITableViewController <CLLocationManagerDelegate>
{
    NSMutableArray* eventsArray;
    NSManagedObjectContext* managedObjectContext;
    CLLocationManager* locationManager;
    UIBarButtonItem *addButton;
}

@property (nonatomic,retain) NSMutableArray* eventsArray;
@property (nonatomic,retain) NSManagedObjectContext* managedObjectContext;
@property (nonatomic,retain) CLLocationManager* locationManager;
@property (nonatomic,retain) UIBarButtonItem *addButton;

@end
