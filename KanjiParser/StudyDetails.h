//
//  StudyDetails.h
//  deck
//
//  Created by Ewan Leaver on 26/10/2014.
//  Copyright (c) 2014 Ewan Leaver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Character, TempStudyDetails;

@interface StudyDetails : NSManagedObject

@property (nonatomic, retain) NSNumber * eFactor;
@property (nonatomic, retain) NSNumber * interval;
@property (nonatomic, retain) NSNumber * intervalNum;
@property (nonatomic, retain) NSDate * lastStudied;
@property (nonatomic, retain) NSNumber * quality;
@property (nonatomic, retain) Character *character;
@property (nonatomic, retain) TempStudyDetails *tempStudyDetails;

@end
