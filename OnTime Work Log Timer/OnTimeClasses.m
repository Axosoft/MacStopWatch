//
//  OnTimeClasses.m
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/11/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import "OnTimeClasses.h"
#import "ItemObject.h"
#import "Items.h"
#import "PostTimeLog.h"
#import "UserInfo.h"
#import "TimeLog.h"
#import "OnTimeAPIClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "Items.h"
#import "TimeUnit.h"
#import "WorkDoneItemObject.h"

@implementation OnTimeClasses

+ (void)searchForItemByType:(NSString *)itemType andId:(NSString *)searchId andTable:(NSTableView *)table
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"false", @"with_lock"
                            , nil];
    NSString *path = [NSString stringWithFormat:@"%@/%@", [itemType lowercaseString], searchId];
//    [[OnTimeAPIClient sharedClient] requestWithMethod:@"GET" path:path parameters:params];
    [[OnTimeAPIClient sharedClient] getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Items *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Items" inManagedObjectContext:[[CoreDataHelper sharedInstance] managedObjectContext]];
        NSError *error;
        NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&error];
        [newItem setTitle:[jsonArray valueForKeyPath:@"data.name"]];
        [newItem setItemId:[jsonArray valueForKeyPath:@"data.id"]];
        [newItem setItemType:[jsonArray valueForKeyPath:@"data.item_type"]];
        [[CoreDataHelper sharedInstance] saveContext];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        NSString *message = [error localizedDescription];
        if ([[operation response] statusCode] == 404) {
            message = [NSString stringWithFormat:@"Item %@ could not be found as part of %@", searchId, itemType];
        }
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", message];
        [alert runModal];

    }];
}

// TODO: Add checking to confirm requests were successful before removing them from the work log
+ (void)uploadTime:(NSArrayController *)arrayController
{
    NSArray *objectArray = [arrayController selectedObjects];
    
    NSMutableArray *operationsArray = [NSMutableArray array];
    NSEntityDescription *userEntity = [NSEntityDescription entityForName:@"UserInfo" inManagedObjectContext:[[CoreDataHelper sharedInstance] managedObjectContext]];
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    [fetchRequest setEntity:userEntity];
    [fetchRequest setFetchLimit:1];
    NSError *error;
    NSArray *fetchResults = [[[CoreDataHelper sharedInstance] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    UserInfo *user = nil;
    
    if ([fetchResults count] > 0) {
        user = [fetchResults objectAtIndex:0];
#ifdef DEBUG
        NSLog(@"Found User: %@", user);
#endif
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Unable to find the associated user. Please try signing in again."];
        [alert runModal];
        return;
    }
    Items *uploadItem = [[objectArray objectAtIndex:0] valueForKey:@"item"];
    for (TimeLog *timeLog in objectArray) {
        TimeUnit *tempTimeUnit = [self getTimeUnitForTimeLogEntry:timeLog];
        
        PostTimeLog *postTimeLog = [PostTimeLog new];
        [postTimeLog setTimeLogId:[NSString stringWithFormat:@"%@", [[timeLog objectID] URIRepresentation]]];
        // UserID
        [[postTimeLog user] setId:user.userId];
        
        // Work_Done
        NSUInteger minutes = [OnTimeClasses getMinutesFromTime:[timeLog time]];
        double time = round((minutes / [[tempTimeUnit conversion_factor] doubleValue]) * 100) / 100.0;
        NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
        [fmt setFormat:@"0.##"];
        [[postTimeLog work_done] setDuration:[[fmt stringFromNumber:[NSNumber numberWithDouble:time]] doubleValue]];
        [[[postTimeLog work_done] time_unit] setId:[tempTimeUnit id]];
        
        // Item
        [[postTimeLog item] setId:[[timeLog item] itemId]];
        [[postTimeLog item] setItem_type:[[timeLog item] itemType]];
        
        // Date_Time
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm'Z'"];
        NSString *stringFormat = [dateFormatter stringFromDate:[timeLog date]];
        [postTimeLog setDate_time:stringFormat];
        [operationsArray addObject:[OnTimeClasses operationToPostWorkLogWithObject:postTimeLog arrayController:arrayController]];
    }
    
    [[DataClass sharedInstance] setUploadedTime:0];
    
    [[OnTimeAPIClient sharedClient] enqueueBatchOfHTTPRequestOperations:operationsArray
                                  progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
#ifdef DEBUG
                                      NSLog(@"Finished %ld of %ld", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations);
#endif
                                  }
                                completionBlock:^(NSArray *operations) {
#ifdef DEBUG
                                    NSLog(@"All operations finished");
#endif
                                    [[CoreDataHelper sharedInstance] saveContext];
                                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"updateRemainingTime"]) {
                                        [OnTimeClasses postRemainingTime:uploadItem];
                                    }
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"TimeUploadFinished" object:nil];
                                }];
    
}

+ (AFHTTPRequestOperation *)operationToPostWorkLogWithObject:(PostTimeLog *)postObject arrayController:(NSArrayController *)arrayController
{
    NSDictionary *params = [postObject objectToDictionary];
    NSURLRequest *request = [[OnTimeAPIClient sharedClient] requestWithMethod:@"POST"
                                                                         path:@"work_logs"
                                                                   parameters:params];
#ifdef DEBUG
    NSLog(@"Request: %@ - %@", request, params);
#endif
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
#ifdef DEBUG
        NSLog(@"Success: %li", response.statusCode);
#endif
        NSError *error;
        NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:kNilOptions error:&error];
//        if (response.statusCode == 200) {
            NSManagedObjectID *managedObjectId = [[[CoreDataHelper sharedInstance] persistentStoreCoordinator] managedObjectIDForURIRepresentation:[NSURL URLWithString:[jsonObj objectForKey:@"timeLogId"]]];
            NSManagedObject *timeLog = [[[CoreDataHelper sharedInstance] managedObjectContext] existingObjectWithID:managedObjectId error:&error];
            NSUInteger uploadedTime = [[DataClass sharedInstance] uploadedTime] + [[(TimeLog *)timeLog time] integerValue];
            [[DataClass sharedInstance] setUploadedTime:uploadedTime];
            [[[CoreDataHelper sharedInstance] managedObjectContext] deleteObject:timeLog];
            
//        } else {
//            NSString *message = [NSString stringWithFormat:@"We received response code %li but it seems we were successful. Please confirm the time saved to the worklog correctly and remove the time entry manually from the timer.", response.statusCode];
//            
//            NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", message];
//            [alert runModal];
//        }
    }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        NSLog(@"Failed: %@ ERROR: %@", request, error);
        NSString *message = [JSON objectForKey:@"error_description"];
        
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", message];
        [alert runModal];
    }];

    return operation;
}

+ (void)postRemainingTime:(Items *)item
{
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[@"false"] forKeys:@[@"with_lock"]];
    NSString *path = [NSString stringWithFormat:@"%@/%@", [item.itemType lowercaseString], item.itemId];
    
//    NSURLRequest *request = [[OnTimeAPIClient sharedClient] requestWithMethod:@"POST"
//                                                                         path:path
//                                                                   parameters:params];
    
    [[OnTimeAPIClient sharedClient] getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&error];
//        if ([[operation response] statusCode] == 200) {
            float duration = [[jsonArray valueForKeyPath:@"data.remaining_duration.duration"] floatValue];
            float remainingTime = 0.0;
            float uploadedTime = [[DataClass sharedInstance] uploadedTime] / 60.0;
            float formatedUploadedTime = 0.0;
            if ([[jsonArray valueForKeyPath:@"data.remaining_duration.time_unit.id"] integerValue] <= 0) {
                NSString *message = @"The time unit for this item does not have a proper remaining time, time unit id. Not going to attempt to update the remaining time as it is probably already 0.";
                NSLog(@"Update time remaning error: %@", message);
//                NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", message];
//                [alert runModal];
                return;
            }
            TimeUnit *tempTimeUnit = [OnTimeClasses getTimeUnitById:[jsonArray valueForKeyPath:@"data.remaining_duration.time_unit.id"]];
            if (tempTimeUnit == nil)
                return;
            WorkDoneItemObject *workDone = [[WorkDoneItemObject alloc] init];
            
            [[[workDone remaining_duration] time_unit] setId:tempTimeUnit.id];
            double time = round((uploadedTime / [[tempTimeUnit conversion_factor] doubleValue]) * 100) / 100.0;
            NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
            [fmt setFormat:@"0.##"];
            formatedUploadedTime = [[fmt stringFromNumber:[NSNumber numberWithDouble:time]] doubleValue];

            if (duration > 0) {
                if (duration > formatedUploadedTime) {
                    remainingTime = duration - formatedUploadedTime;
                }
                [[workDone remaining_duration] setDuration:remainingTime];
                
                NSDictionary *params2 = [NSDictionary dictionaryWithObjects:@[[workDone objectToDictionary]] forKeys:@[@"item"]];
                NSString *path2 = [NSString stringWithFormat:@"%@/%@", [item.itemType lowercaseString], item.itemId];
                [[OnTimeAPIClient sharedClient] postPath:path2 parameters:params2 success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                    if ([[operation response] statusCode] == 200) {
#ifdef DEBUG
                        NSLog(@"Updated remaining time successfully");
#endif
//                    } else {
//                        NSString *message = [operation responseString];
//                        
//                        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", message];
//                        [alert runModal];
//                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Failed: ERROR: %@", error);
                    NSString *message = [error localizedDescription];
                    
                    NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", message];
                    [alert runModal];
                }];
                
            } else {
#ifdef DEBUG
                NSLog(@"Remaining duration is already 0.");
#endif
            }
            
//        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed: ERROR: %@", error);
    }];
}

+ (void)getTimeUnits
{
    [[CoreDataHelper sharedInstance] clearEntity:@"TimeUnit"];
    
    
    NSString *path = [NSString stringWithFormat:@"picklists/time_units"];

    [[OnTimeAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *error;
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&error];
        NSArray *jsonArray = [dataDict objectForKey:@"data"];
        
        for (NSDictionary *dict in jsonArray) {
            TimeUnit *timeUnit = [NSEntityDescription insertNewObjectForEntityForName:@"TimeUnit" inManagedObjectContext:[[CoreDataHelper sharedInstance] managedObjectContext]];
            [timeUnit setId:[dict valueForKeyPath:@"id"]];
            [timeUnit setName:[dict valueForKeyPath:@"name"]];
            [timeUnit setAbbreviation:[dict valueForKeyPath:@"abbreviation"]];
            [timeUnit setConversion_factor:[dict valueForKeyPath:@"conversion_factor"]];
        }
        [[CoreDataHelper sharedInstance] saveContext];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        NSString *message = [error localizedDescription];
       
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", message];
        [alert runModal];
        
    }];
}

+ (TimeUnit *)getTimeUnitForTimeLogEntry:(TimeLog *)timeLog
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TimeUnit" inManagedObjectContext:[[CoreDataHelper sharedInstance] managedObjectContext]];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"conversion_factor <= %i", [OnTimeClasses getMinutesFromTime:[timeLog time]]];
    [request setPredicate:predicate];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"conversion_factor" ascending:NO];
    [request setSortDescriptors:@[sortDesc]];
    [request setFetchLimit:1];
    
    NSError *error;
    NSArray *array = [[[CoreDataHelper sharedInstance] managedObjectContext] executeFetchRequest:request error:&error];
    
    if ([array count] > 0) {
        TimeUnit *timeUnit = [array objectAtIndex:0];
        return timeUnit;
    }
    else {
        sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"conversion_factor" ascending:YES];
        [request setPredicate:nil];
        [request setSortDescriptors:@[sortDesc]];
        array = [[[CoreDataHelper sharedInstance] managedObjectContext] executeFetchRequest:request error:&error];
        if ([array count] > 0) {
            TimeUnit *timeUnit = [array objectAtIndex:0];
            return timeUnit;
        }
        
        NSString *message = @"Unable to find a good time unit for the entry.";
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", message];
        [alert runModal];
    }
    
    return nil;
}

+ (TimeUnit *)getTimeUnitById:(NSNumber *)timeId
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TimeUnit" inManagedObjectContext:[[CoreDataHelper sharedInstance] managedObjectContext]];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", timeId];
#ifdef DEBUG
    NSLog(@"getTimeUnitById: %@", predicate);
#endif
    [request setPredicate:predicate];
    [request setFetchLimit:1];
    
    NSError *error;
    NSArray *array = [[[CoreDataHelper sharedInstance] managedObjectContext] executeFetchRequest:request error:&error];
    if ([array count] > 0) {
        TimeUnit *timeUnit = [array objectAtIndex:0];
        return timeUnit;
    } else {
        NSString *message = @"Unable to find a time unit for the remaining time.";
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", message];
        [alert runModal];
    }
    
    return nil;
}

+ (NSInteger)getMinutesFromTime:(NSString *)time
{
    double minutesFloat = [time doubleValue] / 60;
    NSInteger minutes = round(minutesFloat);
    
    return minutes;
}
@end