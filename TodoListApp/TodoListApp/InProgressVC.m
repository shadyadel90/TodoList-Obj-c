//
//  InProgressVC.m
//  TodoListApp
//
//  Created by Shady Adel on 12/08/2024.
//

#import "InProgressVC.h"
#import "Todo.h"
#import "View_Edit_VC.h"

@interface InProgressVC () <UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic) IBOutlet UITableView *inProgressTableView;
@property NSMutableArray* inProgressDisplayArray;
@property NSUserDefaults *defaults;
@property NSMutableArray<Todo*> *filteredTodoArray;
@property BOOL isSearching;
@end

@implementation InProgressVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _inProgressDisplayArray = [NSMutableArray new];
    _defaults = [NSUserDefaults standardUserDefaults];
    _filteredTodoArray = [NSMutableArray<Todo*> new];
    _isSearching = NO;
    [self loadSavedTasks];
    
    self.inProgressTableView.delegate = self;
    self.inProgressTableView.dataSource = self;
    self.searchBar.delegate = self;
    if (_inProgressDisplayArray.count == 0) {
        _inProgressTableView.hidden = true;
    } else {
        _inProgressTableView.hidden = false;
        [self.inProgressTableView reloadData];
    }
    [self updateTableViewVisibility];
    
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
    [self.inProgressTableView reloadData];
}


- (void)loadSavedTasks {
    NSData *savedData = [_defaults objectForKey:@"tasks"];
    if (savedData) {
        NSError *error;
        NSSet *set = [NSSet setWithObjects:[NSArray class], [Todo class], nil];
        NSArray<Todo*> *tasksArray = [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedData error:&error];
        if (error) {
            NSLog(@"Error unarchiving tasks: %@", error.localizedDescription);
            return;
        }
        [_inProgressDisplayArray removeAllObjects];
        
        for (Todo* task in tasksArray) {
            if ([task.status  isEqual: @"inprogress"]){
                [_inProgressDisplayArray addObject:task];
            }
        }
        
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSearching) {
        return _filteredTodoArray.count;
    } else {
        return _inProgressDisplayArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    Todo *task;
    if (_isSearching) {
        task = _filteredTodoArray[indexPath.row];
    } else {
        task = _inProgressDisplayArray[indexPath.row];
    }
    
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
    Todo *selectedTask;
    if (_isSearching) {
        selectedTask = _filteredTodoArray[indexPath.row];
    } else {
        selectedTask = _inProgressDisplayArray[indexPath.row];
    }
    View_Edit_VC *editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"View_Edit_VC"];
    editVC.taskToEdit = selectedTask;
    [self.navigationController pushViewController:editVC animated:YES];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_inProgressDisplayArray removeObjectAtIndex:indexPath.row];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
       // [self saveTask];
    }
}
- (void)saveTask {
    
    NSError *error;
    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:_inProgressDisplayArray requiringSecureCoding:YES error:&error];
    if (error) {
        NSLog(@"Error archiving tasks: %@", error.localizedDescription);
        return;
    }
    
    [_defaults setObject:archiveData forKey:@"tasks"];
    [_defaults synchronize];

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        _isSearching = NO;
    } else {
        _isSearching = YES;
        [self filterTasksForSearchText:searchText];
    }
    [self updateTableViewVisibility];
}

- (void)filterTasksForSearchText:(NSString *)searchText {
    [_filteredTodoArray removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
    NSArray<Todo*> *filtered = [_inProgressDisplayArray filteredArrayUsingPredicate:predicate];
    [_filteredTodoArray addObjectsFromArray:filtered];
}
@end
