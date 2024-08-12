//
//  InProgressVC.m
//  TodoListApp
//
//  Created by Shady Adel on 12/08/2024.
//

#import "InProgressVC.h"
#import "Todo.h"
#import "View_Edit_VC.h"

@interface InProgressVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) IBOutlet UITableView *inProgressTableView;
@property NSMutableArray* inProgressDisplayArray;
@property NSUserDefaults *defaults;

@end

@implementation InProgressVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _inProgressDisplayArray = [NSMutableArray new];
    _defaults = [NSUserDefaults standardUserDefaults];
    [self loadSavedTasks];
    
    self.inProgressTableView.delegate = self;
    self.inProgressTableView.dataSource = self;
    
    if (_inProgressDisplayArray.count == 0) {
        _inProgressTableView.hidden = true;
    } else {
        _inProgressTableView.hidden = false;
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
    return _inProgressDisplayArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    Todo *task = _inProgressDisplayArray[indexPath.row];
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
    Todo *selectedTask = _inProgressDisplayArray[indexPath.row];
    View_Edit_VC *editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"View_Edit_VC"];
    editVC.taskToEdit = selectedTask;
    [self.navigationController pushViewController:editVC animated:YES];
}



@end
