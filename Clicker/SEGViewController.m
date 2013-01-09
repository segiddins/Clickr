//
//  SEGViewController.m
//  Clicker
//
//  Created by Samuel E. Giddins on 11/17/12.
//  Copyright (c) 2012 Samuel E. Giddins. All rights reserved.
//

#import "SEGViewController.h"

@interface SEGViewController ()

@property (nonatomic, retain) SEGClicker* currentGame;
@property (strong, nonatomic) IBOutlet UIView *clickerView;
@property Boolean isPaused;
@property NSString *mostRecentAlertViewText;

//Labels
@property (weak, nonatomic) IBOutlet UILabel *awayLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeLabel;
@property (weak, nonatomic) IBOutlet UILabel *strikeCount;
@property (weak, nonatomic) IBOutlet UILabel *ballCount;
@property (weak, nonatomic) IBOutlet UILabel *runCount;
@property (weak, nonatomic) IBOutlet UILabel *outCount;
@property (weak, nonatomic) IBOutlet UILabel *inningCount;
@property (weak, nonatomic) IBOutlet UILabel *walkCount;
@property (weak, nonatomic) IBOutlet UILabel *walkLabel;
@property (weak, nonatomic) IBOutlet UILabel *fieldNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *gradeLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

//Scoreboard
@property (weak, nonatomic) IBOutlet UILabel *top1;
@property (weak, nonatomic) IBOutlet UILabel *bottom1;
@property (weak, nonatomic) IBOutlet UILabel *top2;
@property (weak, nonatomic) IBOutlet UILabel *bottom2;
@property (weak, nonatomic) IBOutlet UILabel *top3;
@property (weak, nonatomic) IBOutlet UILabel *bottom3;
@property (weak, nonatomic) IBOutlet UILabel *top4;
@property (weak, nonatomic) IBOutlet UILabel *bottom4;
@property (weak, nonatomic) IBOutlet UILabel *top5;
@property (weak, nonatomic) IBOutlet UILabel *bottom5;
@property (weak, nonatomic) IBOutlet UILabel *top6;
@property (weak, nonatomic) IBOutlet UILabel *bottom6;
@property (weak, nonatomic) IBOutlet UILabel *awayScore;
@property (weak, nonatomic) IBOutlet UILabel *homeScore;


//Controls (so they can be reset)
@property (weak, nonatomic) IBOutlet UIStepper *strikeStepper;
@property (weak, nonatomic) IBOutlet UIStepper *ballStepper;
@property (weak, nonatomic) IBOutlet UIStepper *runStepper;
@property (weak, nonatomic) IBOutlet UIStepper *outStepper;
@property (weak, nonatomic) IBOutlet UIStepper *inningStepper;
@property (weak, nonatomic) IBOutlet UISegmentedControl *inningHalfSegmentedControl;


//...DidChange methods
- (IBAction)strikeValueDidChange:(id)sender;
- (IBAction)ballValueDidChange:(UIStepper *)sender;
- (IBAction)outValueDidChange:(UIStepper *)sender;
- (IBAction)runValueDidChange:(id)sender;
- (IBAction)inningValueDidChange:(UIStepper *)sender;
- (IBAction)battingTeamDidChange:(UISegmentedControl *)sender;
- (IBAction)togglePause:(UIButton *)sender;
- (IBAction)newPitcher:(UIButton *)sender;

@end

@implementation SEGViewController

int scoreboard[2][6];

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _currentGame = [[SEGClicker alloc] init];

    [self updateCounterValues];

    [_inningHalfSegmentedControl setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIFont systemFontOfSize:25], UITextAttributeFont,
                                                          nil]  forState:UIControlStateNormal];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/d/YYYY"];
    NSString *dateStr = [dateFormat stringFromDate:[NSDate date]]; //for current date
    //NSLog(@"%@",dateStr);
    //_dateLabel.text = @"";
    [_dateLabel setText: dateStr];
    
    _isPaused = FALSE;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    //NSLog(@"setValue: %@ for undefined key: %@",value,key);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)strikeValueDidChange:(id)sender {
    if (!_isPaused)
        _currentGame.strikes = (NSInteger) [(UIStepper*)sender value];
    [self updateCounterValues];
}

- (IBAction)ballValueDidChange:(UIStepper *)sender {
    if (!_isPaused)
        _currentGame.balls = (NSInteger) [sender value];
    [self updateCounterValues];
}

- (IBAction)outValueDidChange:(UIStepper *)sender {
    if (!_isPaused)
        _currentGame.outs = (NSInteger) [sender value];
    [_currentGame newBatter];
    [self updateCounterValues];
}

- (IBAction)runValueDidChange:(UIStepper*)sender {
    if (!_isPaused)
        [_currentGame setScore:[_inningHalfSegmentedControl selectedSegmentIndex]:_currentGame.inning:[sender value]];
    [_currentGame newBatter];
    [self updateCounterValues];
}

- (IBAction)inningValueDidChange:(UIStepper *)sender {
    if (!_isPaused)
        _currentGame.inning = [sender value];
    [_currentGame newInning];
    [self updateCounterValues];
}

- (IBAction)battingTeamDidChange:(UISegmentedControl *)sender {
    if (!_isPaused)
    {
    if (sender.selectedSegmentIndex == 0) {
        _currentGame.isTopOfInning = TRUE;
    } else {
        _currentGame.isTopOfInning = FALSE;
    }
    }
    [self updateCounterValues];
}

- (IBAction)togglePause:(UIButton *)sender {
    _isPaused = !_isPaused;
    if (_isPaused) {
        [sender setTitle:NSLocalizedString(@"Unpause", @"") forState:UIControlStateNormal];
    } else {
        [sender setTitle:NSLocalizedString(@"Pause", @"") forState:UIControlStateNormal];
    }
}

- (IBAction)newPitcher:(UIButton *)sender {
    if (!_isPaused)
        _currentGame.currentPitcherWalks = 0;
    [self updateCounterValues];
}

- (void)updateCounterValues
{
    
    [_currentGame gameStateHasChanged];
    
    [_strikeCount setText:[NSString stringWithFormat:@"%d", _currentGame.strikes]];
    [_strikeStepper setValue:_currentGame.strikes];
    
    [_ballCount setText:[NSString stringWithFormat:@"%d", _currentGame.balls]];
    [_ballStepper setValue:_currentGame.balls];
    
    [_outCount setText:[NSString stringWithFormat:@"%d", _currentGame.outs]];
    [_outStepper setValue:_currentGame.outs];
    
    //has to run first to make sure run counter gets reset at beginning of new inning
    if (_currentGame.isTopOfInning) {
        _awayLabel.font = [UIFont boldSystemFontOfSize:17];
        _homeLabel.font = [UIFont systemFontOfSize:17];
        _inningHalfSegmentedControl.selectedSegmentIndex = 0;
    } else {
        _homeLabel.font = [UIFont boldSystemFontOfSize:17];
        _awayLabel.font = [UIFont systemFontOfSize:17];
        _inningHalfSegmentedControl.selectedSegmentIndex = 1;
    }
    _homeLabel.text = _currentGame.homeName;
    _awayLabel.text = _currentGame.awayName;
    [_fieldNameLabel setText:_currentGame.fieldName];
    _gradeLevelLabel.text = [NSString stringWithFormat: 0==_currentGame.gradeLevel ? [NSString string] : @"Grade: %d",_currentGame.gradeLevel];
    
    [_runCount setText:[_currentGame getScore:[_inningHalfSegmentedControl selectedSegmentIndex] :_currentGame.inning]];
    [_runCount setTextColor:[[_runCount text] intValue]>=7 ? [UIColor colorWithRed:1 green:0 blue:0 alpha:1] : [UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
    [_runStepper setValue: [[_currentGame getScore:[_inningHalfSegmentedControl selectedSegmentIndex] :_currentGame.inning] intValue]];
    
    [_top1 setText: [_currentGame getScore:0 : 1]];
    [_top2 setText: [_currentGame getScore:0 : 2]];
    [_top3 setText: [_currentGame getScore:0 : 3]];
    [_top4 setText: [_currentGame getScore:0 : 4]];
    [_top5 setText: [_currentGame getScore:0 : 5]];
    [_top6 setText: [_currentGame getScore:0 : 6]];
    [_awayScore setText: [_currentGame getScore:0 :7]];

    [_bottom1 setText: [_currentGame getScore:1 : 1]];
    [_bottom2 setText: [_currentGame getScore:1 : 2]];
    [_bottom3 setText: [_currentGame getScore:1 : 3]];
    [_bottom4 setText: [_currentGame getScore:1 :
                        4]];
    [_bottom5 setText: [_currentGame getScore:1 : 5]];
    [_bottom6 setText: [_currentGame getScore:1 : 6]];
    [_homeScore setText: [_currentGame getScore:1 :7]];
    
    [_inningCount setText: [NSString stringWithFormat:@"%d", _currentGame.inning]];
    [_inningStepper setValue:_currentGame.inning];
    
    [_walkCount setText: [NSString stringWithFormat:@"%d", _currentGame.currentPitcherWalks]];
    if (_currentGame.currentPitcherWalks >= 4) {
        [_walkCount setTextColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:1]];
        [_walkLabel setTextColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:1]];
    }
    else
    {
        [_walkCount setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
        [_walkLabel setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
    }
    

}

- (IBAction)newGameWasPressed:(UIButton *)sender {
    UIActionSheet *confirmBox = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Start a new game?", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"No", @"") destructiveButtonTitle:NSLocalizedString(@"Yes", @"") otherButtonTitles: NSLocalizedString(@"Reset Current Game", @""), nil];
    [confirmBox showInView: _clickerView];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [_currentGame newGame];
        [self updateCounterValues];
    } else if (buttonIndex == 0) {
        _currentGame = [[SEGClicker alloc] init];            [self updateCounterValues];
        
        UIAlertView *fieldName = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Game Info", @"") message:NSLocalizedString(@"Field Name:", @"") delegate:self cancelButtonTitle: nil otherButtonTitles: NSLocalizedString(@"Next", @""), nil];
        [fieldName setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[fieldName textFieldAtIndex:0] setPlaceholder:@""];
        [[fieldName textFieldAtIndex:0] setAutocapitalizationType: UITextAutocapitalizationTypeWords];
        [fieldName setTag:100];
        [fieldName show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch ([alertView tag]) {
        case 100:
        {
            _currentGame.fieldName = [[alertView textFieldAtIndex:0] text];
            //NSLog(@"current game field name is: %@", _currentGame.fieldName);
            [self updateCounterValues];
            
            UIAlertView *home = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Game Info", @"") message:NSLocalizedString(@"Home Team:", @"") delegate:self cancelButtonTitle: nil otherButtonTitles: NSLocalizedString(@"Next", @""), nil];
            [home setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[home textFieldAtIndex:0] setPlaceholder:NSLocalizedString(@"Home", @"")];
            [[home textFieldAtIndex:0] setAutocapitalizationType: UITextAutocapitalizationTypeWords];
            [home setTag:101];
            [home show];
            break;
        }
            
        case 101:
        {
            _currentGame.homeName = [[[alertView textFieldAtIndex:0] text] length] >  0 ? [[alertView textFieldAtIndex:0] text] : NSLocalizedString(@"Home", @"");
            //NSLog(@"current home name is: %@", _currentGame.homeName);
            [self updateCounterValues];
            
            UIAlertView *away = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Game Info", @"") message:NSLocalizedString(@"Away Team:", @"") delegate:self cancelButtonTitle: nil otherButtonTitles: NSLocalizedString(@"Next", @""), nil];
            [away setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[away textFieldAtIndex:0] setPlaceholder:NSLocalizedString(@"Away", @"")];
            [[away textFieldAtIndex:0] setAutocapitalizationType: UITextAutocapitalizationTypeWords];
            [away setTag:102];
            [away show];
            break;
        }
            
        case 102:
        {
            _currentGame.awayName = [[[alertView textFieldAtIndex:0] text] length] >  0 ? [[alertView textFieldAtIndex:0] text] : NSLocalizedString(@"Away", @"");
            //NSLog(@"current away name is: %@", _currentGame.awayName);
            [self updateCounterValues];
            
            UIAlertView *grade = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Game Info", @"") message:NSLocalizedString(@"Grade:", @"") delegate:self cancelButtonTitle: NSLocalizedString(@"Done", @"") otherButtonTitles: nil];
            [grade setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[grade textFieldAtIndex:0] setPlaceholder:@"0"];
            [[grade textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
            [grade setTag:103];
            [grade show];
            break;
        }
            
        case 103:
        {
            _currentGame.gradeLevel = [[[alertView textFieldAtIndex:0] text] integerValue];
            //NSLog(@"current away name is: %d", _currentGame.gradeLevel);
            [self updateCounterValues];
        }
            
        default:
            break;
    }
}

@end
