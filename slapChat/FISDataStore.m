//
//  FISDataStore.m
//  playingWithCoreData
//
//  Created by Joe Burgess on 6/27/14.
//  Copyright (c) 2014 Joe Burgess. All rights reserved.
//

#import "FISDataStore.h"
#import "FISMessage.h"

@implementation FISDataStore
@synthesize managedObjectContext = _managedObjectContext;


+ (instancetype)sharedDataStore {
    static FISDataStore *_sharedDataStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataStore = [[FISDataStore alloc] init];
    });

    return _sharedDataStore;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }


    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"slapChat.sqlite"];

    NSError *error = nil;

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"slapChat" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];

    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (void)generateTestData
{
    FISMessage *messageOne = [NSEntityDescription insertNewObjectForEntityForName:@"FISMessage" inManagedObjectContext:self.managedObjectContext];
    
    messageOne.content = @"Message 1";
    messageOne.createdAt = [NSDate date];
    
    FISMessage *messageTwo = [NSEntityDescription insertNewObjectForEntityForName:@"FISMessage" inManagedObjectContext:self.managedObjectContext];
    messageTwo.content = @"Message 2";
    messageTwo.createdAt = [NSDate date];
    
    FISMessage *messageThree = [NSEntityDescription insertNewObjectForEntityForName:@"FISMessage" inManagedObjectContext:self.managedObjectContext];
    
    messageThree.content = @"Message 3";
    messageThree.createdAt = [NSDate date];
    [self saveContext];
    [self fetchData];
}

- (void)fetchData
{
    NSFetchRequest *messagesRequest = [NSFetchRequest fetchRequestWithEntityName:@"FISMessage"];

    NSSortDescriptor *createdAtSorter = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
    messagesRequest.sortDescriptors = @[createdAtSorter];

    self.messages = [self.managedObjectContext executeFetchRequest:messagesRequest error:nil];

    if ([self.messages count]==0) {
        [self generateTestData];
    }
}
@end
