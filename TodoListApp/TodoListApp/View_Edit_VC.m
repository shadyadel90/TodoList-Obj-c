//
//  View_Edit_VC.m
//  TodoListApp
//
//  Created by Shady Adel on 12/08/2024.
//

#import "View_Edit_VC.h"
#import "Todo.h"

@interface View_Edit_VC ()

@property (weak, nonatomic) IBOutlet UIImageView *imgTodoImage;
@property (weak, nonatomic) IBOutlet UITextField *txfTodoTitle;
@property (weak, nonatomic) IBOutlet UITextView *txvTodoDescription;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segTodoPriorty;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segTodoType;
@property (weak, nonatomic) IBOutlet UIDatePicker *pickTodoDate;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit_SaveButton;
@property NSMutableArray<Todo*>* tasksArray;
@property NSUserDefaults* defaults;
@property NSArray<NSString*>* types;
@property NSArray<NSString*>* status;

@end

@implementation View_Edit_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Todo Screen";
    _defaults = [NSUserDefaults standardUserDefaults];
    _types =  [NSArray<NSString*> arrayWithObjects:@"low",@"medium",@"high", nil];
    _status =  [NSArray<NSString*> arrayWithObjects:@"todo",@"inprogress",@"done", nil];
    _tasksArray = [NSMutableArray<Todo*> new];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (self.taskToEdit) {
        if ([self.taskToEdit.status isEqualToString:@"todo"]) {
            self.imgTodoImage.image = [UIImage imageNamed:@"todo"];
        } else if ([self.taskToEdit.status isEqualToString:@"inprogress"]) {
            self.imgTodoImage.image = [UIImage systemImageNamed:@"hourglass.tophalf.filled"];
        } else {
            self.imgTodoImage.image = [UIImage systemImageNamed:@"checkmark.gobackward"];
        }
        
        
        
        self.txfTodoTitle.text = self.taskToEdit.name;
        self.txvTodoDescription.text = self.taskToEdit.descrption;
        self.segTodoPriorty.selectedSegmentIndex = [_types indexOfObject:self.taskToEdit.priority];
        self.segTodoType.selectedSegmentIndex = [_status indexOfObject:self.taskToEdit.status];
        self.pickTodoDate.date = self.taskToEdit.date;
        
       // [self updateSegmentControlForStatus:self.taskToEdit.status];
        
        [self.btnEdit_SaveButton setTitle:@"Edit" forState:UIControlStateNormal];
    }
}

- (IBAction)btnEdit_SaveButtonClicked:(UIButton *)sender {
    
    if (_txfTodoTitle.text.length == 0) {
        [self showAlertWithTitle:@"Missing Information" andMessage:@"Please enter a task title."];
        return;
    }
    
    if (_txvTodoDescription.text.length == 0) {
        [self showAlertWithTitle:@"Missing Information" andMessage:@"Please enter a task description."];
        return;
    }
    NSString *selectedStatus = _status[_segTodoType.selectedSegmentIndex];
    NSString *currentStatus = self.taskToEdit ? self.taskToEdit.status : @"todo";
    
    if ([currentStatus isEqualToString:@"inprogress"] && [selectedStatus isEqualToString:@"todo"]) {
        [self showAlertWithTitle:@"Invalid Transition" andMessage:@"You cannot move a task from 'In Progress' back to 'To Do'."];
        return;
    }
    
    if ([currentStatus isEqualToString:@"done"] && [selectedStatus isEqualToString:@"inprogress"]) {
        [self showAlertWithTitle:@"Invalid Transition" andMessage:@"You cannot move a task from 'Done' back to 'In Progress'."];
        return;
    }
    
    
    
    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:@"Confirm Save"
                                                                          message:@"Are you sure you want to save this task?"
                                                                   preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self loadTasks];
        [self saveTask];
        [self.navigationController popViewControllerAnimated:true];
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
    
    [confirmAlert addAction:yesAction];
    [confirmAlert addAction:noAction];
    
    [self presentViewController:confirmAlert animated:YES completion:nil];
}
- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}



- (void)saveTask {
    Todo *task = [Todo new];
    task.name = _txfTodoTitle.text;
    task.descrption = _txvTodoDescription.text;
    task.priority = _types[_segTodoPriorty.selectedSegmentIndex];
    task.status = _status[_segTodoType.selectedSegmentIndex];
    task.date = _pickTodoDate.date;
    
    BOOL taskUpdated = NO;
    for (NSInteger i = 0; i < _tasksArray.count; i++) {
        Todo *existingTask = _tasksArray[i];
        if ([existingTask isEqual:task]) {
            _tasksArray[i] = task;
            taskUpdated = YES;
            break;
        }
    }
    
    if (!taskUpdated) {
        [_tasksArray addObject:task];
    }
    
    NSError *error;
    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:_tasksArray requiringSecureCoding:YES error:&error];
    if (error) {
        NSLog(@"Error archiving tasks: %@", error.localizedDescription);
        return;
    }
    
    [_defaults setObject:archiveData forKey:@"tasks"];
    [_defaults synchronize];

}


-(void)loadTasks {
    [_tasksArray removeAllObjects];
        NSError *error;
        NSData *savedData = [_defaults objectForKey:@"tasks"];
        if (savedData) {
            NSSet *set = [NSSet setWithObjects:[NSArray class], [Todo class], nil];
            _tasksArray = [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedData error:&error];
            if (error) {
                NSLog(@"Error unarchiving tasks: %@", error.localizedDescription);
                return;
            }
        }
}

- (void)updateSegmentControlForStatus:(NSString *)status {
    if ([status isEqualToString:@"todo"]) {
        self.segTodoType.enabled = YES;
    } else if ([status isEqualToString:@"inprogress"]) {
        self.segTodoType.enabled = NO;
    } else if ([status isEqualToString:@"done"]) {
        self.segTodoType.enabled = NO;
    } else {
        self.segTodoType.enabled = YES;
    }
}
@end
