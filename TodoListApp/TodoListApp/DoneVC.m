//
//  DoneVC.m
//  TodoListApp
//
//  Created by Shady Adel on 12/08/2024.
//

#import "DoneVC.h"

@interface DoneVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray* doneDisplayArray;

@end

@implementation DoneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _doneDisplayArray = [NSMutableArray new];
    
    if (_doneDisplayArray.count == 0) {
        _tableView.hidden = true;
    }}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.navigationItem.title = @"Done Todo's";
}

@end
