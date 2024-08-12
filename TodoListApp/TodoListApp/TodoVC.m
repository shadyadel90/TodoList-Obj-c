//
//  TodoVC.m
//  TodoListApp
//
//  Created by Shady Adel on 12/08/2024.
//

#import "TodoVC.h"
#import "Todo.h"
#import "View_Edit_VC.h"

@interface TodoVC () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray<Todo*> *todoDisplayArray;
@property NSUserDefaults *defaults;

@end

@implementation TodoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _todoDisplayArray = [NSMutableArray new];
    _defaults = [NSUserDefaults standardUserDefaults];
    
    [self loadSavedTasks];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    if (_todoDisplayArray.count == 0) {
        _tableView.hidden = true;
    } else {
        _tableView.hidden = false;
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
    return _todoDisplayArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    Todo *task = _todoDisplayArray[indexPath.row];
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
    Todo *selectedTask = _todoDisplayArray[indexPath.row];
    View_Edit_VC *editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"View_Edit_VC"];
    editVC.taskToEdit = selectedTask;
    [self.navigationController pushViewController:editVC animated:YES];
}



@end
