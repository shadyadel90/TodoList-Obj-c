//
//  TabBarController.m
//  TodoListApp
//
//  Created by Shady Adel on 12/08/2024.
//

#import "TabBarController.h"
#import "View_Edit_VC.h"
@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)addButtonClicked:(UIBarButtonItem *)sender {
    
    View_Edit_VC *destVc =  [self.storyboard instantiateViewControllerWithIdentifier:@"View_Edit_VC"];
   
    [self.navigationController pushViewController:destVc animated:true];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
