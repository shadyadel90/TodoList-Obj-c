//
//  TodoVC.m
//  TodoListApp
//
//  Created by Shady Adel on 12/08/2024.
//

#import "TodoVC.h"
#import "Todo.h"
#import "View_Edit_VC.h"

@interface TodoVC () <UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray<Todo*> *todoDisplayArray;
@property NSUserDefaults *defaults;
@property NSMutableArray<Todo*> *filteredTodoArray;
@property BOOL isSearching;

@end

@implementation TodoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _todoDisplayArray = [NSMutableArray<Todo*> new];
    _defaults = [NSUserDefaults standardUserDefaults];
    _filteredTodoArray = [NSMutableArray<Todo*> new];
    _isSearching = NO;
    [self loadSavedTasks];
    
    self.searchBar.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    
    [self updateTableViewVisibility];
    
}

- (void)updateTableViewVisibility {
    if ((_isSearching && _filteredTodoArray.count == 0) || (!_isSearching && _todoDisplayArray.count == 0)) {
        _tableView.hidden = YES;
    } else {
        _tableView.hidden = NO;
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = @"Todo's";
    
    [self loadSavedTasks];
    [self.tableView reloadData];
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
        [_todoDisplayArray removeAllObjects];
        [_todoDisplayArray addObjectsFromArray:tasksArray];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSearching) {
        return _filteredTodoArray.count;
    } else {
        return _todoDisplayArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    Todo *task;
    if (_isSearching) {
        task = _filteredTodoArray[indexPath.row];
    } else {
        task = _todoDisplayArray[indexPath.row];
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
        selectedTask = _todoDisplayArray[indexPath.row];
    }
    View_Edit_VC *editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"View_Edit_VC"];
    editVC.taskToEdit = selectedTask;
    [self.navigationController pushViewController:editVC animated:YES];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_todoDisplayArray removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self saveTask];
    }
}
- (void)saveTask {
    
    NSError *error;
    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:_todoDisplayArray requiringSecureCoding:YES error:&error];
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
    NSArray<Todo*> *filtered = [_todoDisplayArray filteredArrayUsingPredicate:predicate];
    [_filteredTodoArray addObjectsFromArray:filtered];
}

@end
