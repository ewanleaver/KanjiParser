//
//  TempStudyDetails.h
//  deck
//
//  Created by Ewan Leaver on 26/10/2014.
//  Copyright (c) 2014 Ewan Leaver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StudyDetails;

@interface TempStudyDetails : NSManagedObject

@property (nonatomic, retain) NSNumber * numCorrect;
@property (nonatomic, retain) NSNumber * numIncorrect;
@property (nonatomic, retain) NSNumber * isStudying;
@property (nonatomic, retain) StudyDetails *studyDetails;

@end
