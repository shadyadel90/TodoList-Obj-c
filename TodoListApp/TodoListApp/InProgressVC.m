//
//  InProgressVC.m
//  TodoListApp
//
//  Created by Shady Adel on 12/08/2024.
//

#import "InProgressVC.h"
#import "Todo.h"
#import "View_Edit_VC.h"

@interface InProgressVC () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic) IBOutlet UITableView *inProgressTableView;
@property NSMutableArray<Todo*> *inProgressDisplayArray;
@property NSUserDefaults *defaults;
@property NSMutableArray<Todo*> *filteredTodoArray;
@property BOOL isSearching;
@property NSMutableArray<Todo*> *tasksArray;

@end

@implementation InProgressVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _inProgressDisplayArray = [NSMutableArray<Todo*> new];
    _defaults = [NSUserDefaults standardUserDefaults];
    _filteredTodoArray = [NSMutableArray<Todo*> new];
    _isSearching = NO;
    [self loadSavedTasks];
    
    self.searchBar.delegate = self;
    self.inProgressTableView.dataSource = self;
    self.inProgressTableView.delegate = self;
    
    
}

- (void)updateTableViewVisibility {
    if ((_isSearching && _filteredTodoArray.count == 0) || (!_isSearching && _inProgressDisplayArray.count == 0)) {
        _inProgressTableView.hidden = YES;
    } else {
        _inProgressTableView.hidden = NO;
        [self.inProgressTableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = @"In Progress Todo's";
    [self loadSavedTasks];
    [self updateTableViewVisibility];
    [self.inProgressTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _isSearching ? _filteredTodoArray.count : [self tasksForSection:section].count;
}

- (NSArray<Todo*> *)tasksForSection:(NSInteger)section {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"priority == %@", [self priorityStringForSection:section]];
    return _isSearching ? [_filteredTodoArray filteredArrayUsingPredicate:predicate] : [_inProgressDisplayArray filteredArrayUsingPredicate:predicate];
}
- (NSString *)priorityStringForSection:(NSInteger)section {
    if (section == 0) return @"high";
    if (section == 1) return @"medium";
    return @"low";
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title;
    if (section == 0) {
        title = @"High Priority";
    } else if (section == 1) {
        title = @"Medium Priority";
    } else {
        title = @"Low Priority";
    }
    return title;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    Todo *task = _isSearching ? _filteredTodoArray[indexPath.row] : [self tasksForSection:indexPath.section][indexPath.row];
    
    cell.textLabel.text = task.name;
    
    if ([task.status isEqualToString:@"todo"]) {
        cell.imageView.image = [UIImage imageNamed:@"todo"];
    } else if ([task.status isEqualToString:@"inprogress"]) {
        cell.imageView.image = [UIImage imageNamed:@"inprogress"];
    } else if ([task.status isEqualToString:@"done"]) {
        cell.imageView.image = [UIImage imageNamed:@"done"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Todo *selectedTask = _isSearching ? _filteredTodoArray[indexPath.row] : [self tasksForSection:indexPath.section][indexPath.row];
    
    View_Edit_VC *editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"View_Edit_VC"];
    editVC.taskToEdit = selectedTask;
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Todo *taskToDelete;
        if (_isSearching) {
            taskToDelete = _filteredTodoArray[indexPath.row];
           
            [_tasksArray removeObject:taskToDelete];
        } else {
            taskToDelete = [self tasksForSection:indexPath.section][indexPath.row];
           
            [_tasksArray removeObject:taskToDelete];
        }

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[self saveTasks];
    }
}

- (void)saveTasks {
    NSError *error;
    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:_tasksArray requiringSecureCoding:YES error:&error];
    if (error) {
        NSLog(@"Error archiving tasks: %@", error.localizedDescription);
        return;
    }
    
    [_defaults setObject:archiveData forKey:@"tasks"];
    [_defaults synchronize];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _isSearching = searchText.length > 0;
    [self filterTasksForSearchText:searchText];
    [self updateTableViewVisibility];
}

- (void)filterTasksForSearchText:(NSString *)searchText {
    [_filteredTodoArray removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
    NSArray<Todo*> *filtered = [_inProgressDisplayArray filteredArrayUsingPredicate:predicate];
    [_filteredTodoArray addObjectsFromArray:filtered];
}
- (void)loadSavedTasks {
    NSData *savedData = [_defaults objectForKey:@"tasks"];
    if (savedData) {
        NSError *error;
        NSSet *set = [NSSet setWithObjects:[NSArray class], [Todo class], nil];
        _tasksArray = [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedData error:&error];
        if (error) {
            NSLog(@"Error unarchiving tasks: %@", error.localizedDescription);
            return;
        }
        [_inProgressDisplayArray removeAllObjects];

        for (Todo *task in _tasksArray) {
            if ([task.status isEqualToString:@"inprogress"]) {
                [_inProgressDisplayArray addObject:task];
            }
        }
        [self.inProgressTableView reloadData];
    }
}
@end
