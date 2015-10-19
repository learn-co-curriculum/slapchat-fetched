//
//  FISTableViewController.m
//  slapChat
//
//  Created by Joe Burgess on 6/27/14.
//  Copyright (c) 2014 Joe Burgess. All rights reserved.
//

#import "FISTableViewController.h"
#import "FISMessage.h"
#import "FISDataStore.h"

@interface FISTableViewController () <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) FISDataStore *store;
@property (strong, nonatomic) NSFetchedResultsController *resultsController;
@end

@implementation FISTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.store = [FISDataStore sharedDataStore];
    [self setupResultsController];
    [self.resultsController performFetch:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.resultsController.fetchedObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basiccell" forIndexPath:indexPath];
    
    FISMessage *eachMessage = self.resultsController.fetchedObjects[indexPath.row];
    cell.textLabel.text = eachMessage.content;
    
    return cell;
}

#pragma mark - Add Button

- (IBAction)addButtonTapped:(id)sender {
    FISMessage *newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"FISMessage" inManagedObjectContext:self.store.managedObjectContext];
    
    newMessage.createdAt = [NSDate date];
    newMessage.content = [NSString stringWithFormat:@"%@", newMessage.createdAt];
    
    [self.store saveContext];
}
#pragma mark - Results Controller Setup

-(void) setupResultsController
{
    NSFetchRequest *messagesRequest = [NSFetchRequest fetchRequestWithEntityName:@"FISMessage"];
    messagesRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    // dont forget the sort descriptor or it wont work!
    
    self.resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:messagesRequest managedObjectContext:self.store.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    self.resultsController.delegate = self;
}

#pragma mark - NSFetchedResultsControllerDelegate (boilerplate)


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            // option+click the constants (NSFetchedResultsChange____) to read what they mean
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            // option+click the constants (NSFetchedResultsChange____) to read what they mean
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            // nothing implemented; we're not allowing editing of the tableView rows or storage array.
            break;
            
        case NSFetchedResultsChangeUpdate:
            // not implemented; we're not allowing editing of message objects. For this app we'd probably just reload the cell that had its FISMessage changed so it would display the correct title.
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

 
@end
