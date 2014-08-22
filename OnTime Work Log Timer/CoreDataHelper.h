//
//  CoreDataHelper.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/12/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataHelper : NSObject

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CoreDataHelper *) sharedInstance;
- (void)saveContext;
- (BOOL)clearEntity:(NSString *)entity;

@end
