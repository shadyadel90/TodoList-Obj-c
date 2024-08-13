// DoneVC.m
#import "DoneVC.h"
#import "Todo.h"
#import "View_Edit_VC.h"

@interface DoneVC () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic) IBOutlet UITableView *doneTableView;
@property (strong, nonatomic) NSMutableArray<Todo*> *doneDisplayArray;
@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) NSMutableArray<Todo*> *filteredTodoArray;
@property (assign, nonatomic) BOOL isSearching;

@end

@implementation DoneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.doneDisplayArray = [NSMutableArray new];
    self.defaults = [NSUserDefaults standardUserDefaults];
    self.filteredTodoArray = [NSMutableArray new];
    self.isSearching = NO;
    
    [self loadSavedTasks];
    self.searchBar.delegate = self;
    self.doneTableView.dataSource = self;
    self.doneTableView.delegate = self;
    
    [self updateTableViewVisibility];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = @"Done Todo's";
    [self loadSavedTasks];
    [self.doneTableView reloadData];
}

- (void)updateTableViewVisibility {
    BOOL shouldHideTableView = (self.isSearching && self.filteredTodoArray.count == 0) || (!self.isSearching && self.doneDisplayArray.count == 0);
    self.doneTableView.hidden = shouldHideTableView;
    
    if (!shouldHideTableView) {
        [self.doneTableView reloadData];
    }
}

- (void)loadSavedTasks {
    NSData *savedData = [self.defaults objectForKey:@"tasks"];
    if (savedData) {
        NSError *error;
        NSSet *set = [NSSet setWithObjects:[NSArray class], [Todo class], nil];
        NSArray<Todo*> *tasksArray = [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedData error:&error];
        if (error) {
            NSLog(@"Error unarchiving tasks: %@", error.localizedDescription);
            return;
        }
        [self.doneDisplayArray removeAllObjects];
        
        for (Todo *task in tasksArray) {
            if ([task.status isEqualToString:@"done"]) {
                [self.doneDisplayArray addObject:task];
            }
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.isSearching ? self.filteredTodoArray.count : [self tasksForSection:section].count;
}

- (NSArray<Todo*> *)tasksForSection:(NSInteger)section {
    NSString *priority = [self priorityStringForSection:section];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"priority == %@", priority];
    return self.isSearching ? [self.filteredTodoArray filteredArrayUsingPredicate:predicate] : [self.doneDisplayArray filteredArrayUsingPredicate:predicate];
}

- (NSString *)priorityStringForSection:(NSInteger)section {
    if (section == 0) return @"high";
    if (section == 1) return @"medium";
    return @"low";
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) return @"High Priority";
    if (section == 1) return @"Medium Priority";
    return @"Low Priority";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    Todo *task = self.isSearching ? self.filteredTodoArray[indexPath.row] : [self tasksForSection:indexPath.section][indexPath.row];
    
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
    Todo *selectedTask = self.isSearching ? self.filteredTodoArray[indexPath.row] : [self tasksForSection:indexPath.section][indexPath.row];
    
    View_Edit_VC *editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"View_Edit_VC"];
    editVC.taskToEdit = selectedTask;
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Todo *taskToDelete = self.isSearching ? self.filteredTodoArray[indexPath.row] : [self tasksForSection:indexPath.section][indexPath.row];
        [self.doneDisplayArray removeObject:taskToDelete];
        [self.filteredTodoArray removeObject:taskToDelete];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self saveTasks];
    }
}

- (void)saveTasks {
    NSError *error;
    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:self.doneDisplayArray requiringSecureCoding:YES error:&error];
    if (error) {
        NSLog(@"Error archiving tasks: %@", error.localizedDescription);
        return;
    }
    
    [self.defaults setObject:archiveData forKey:@"tasks"];
    [self.defaults synchronize];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.isSearching = searchText.length > 0;
    [self filterTasksForSearchText:searchText];
    [self updateTableViewVisibility];
}

- (void)filterTasksForSearchText:(NSString *)searchText {
    [self.filteredTodoArray removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
    NSArray<Todo*> *filtered = [self.doneDisplayArray filteredArrayUsingPredicate:predicate];
    [self.filteredTodoArray addObjectsFromArray:filtered];
}

@end
