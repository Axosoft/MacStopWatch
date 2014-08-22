//
//  CoreDataHelper.m
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/12/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

static CoreDataHelper *instance = nil;

+ (CoreDataHelper *) sharedInstance
{
	if( instance == nil )
	{
		instance = [[CoreDataHelper alloc] init];
	}
	return instance;
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.bjost.OnTime_Work_Log_Timer" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.bjost.OnTime_Work_Log_Timer"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"OnTime_Work_Log_Timer" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"OnTime_Work_Log_Timer.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                   [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                                                                                   [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil] error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

- (void)saveContext
{
    NSError *error = nil;
    [_managedObjectContext save:&error];
    if (error) {
        NSLog(@"Core Data Save Error: %@", [error localizedDescription]);
    }
}

- (BOOL)clearEntity:(NSString *)entity
{
    NSFetchRequest *fetchAllObjects = [[NSFetchRequest alloc] init];
    [fetchAllObjects setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:_managedObjectContext]];
    [fetchAllObjects setIncludesPropertyValues:NO]; //only fetch the managedObjectID

    NSError *error = nil;
    NSArray *allObjects = [_managedObjectContext executeFetchRequest:fetchAllObjects error:&error];
    // uncomment next line if you're NOT using ARC
    // [allObjects release];
    if (error) {
        [[NSApplication sharedApplication] presentError:error];
    }

    for (NSManagedObject *object in allObjects) {
        [_managedObjectContext deleteObject:object];
    }

    NSError *saveError = nil;
    if (![_managedObjectContext save:&saveError]) {
        [[NSApplication sharedApplication] presentError:error];
    }

    return (saveError == nil);
}



@end
