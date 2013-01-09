//
//  SEGClicker.m
//  Clicker
//
//  Created by Samuel E. Giddins on 11/17/12.
//  Copyright (c) 2012 Samuel E. Giddins. All rights reserved.
//

#import "SEGClicker.h"

@implementation SEGClicker

int scoreboard[2][7];

- (id)initWithField:(NSString *)field andHomeTeam:(NSString *)homeTeam andAwayTeam:(NSString *)awayTeam andGrade:(NSInteger)grade
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self newGame];
        _fieldName = field;
        _homeName = homeTeam;
        _awayName = awayTeam;
        _gradeLevel = grade;
    }
    
    return self;
}

- (id)init
{
    self = [self initWithField:@" " andHomeTeam:NSLocalizedString(@"Home", @"") andAwayTeam:NSLocalizedString(@"Away", @"") andGrade:0];
    return self;
}

-(void)newGame
{
    _strikes = 0;
    _outs = 0;
    _balls = 0;
    _inning = 1;
    _isTopOfInning = TRUE;
    _homeTeamRuns = 0;
    _awayTeamRuns = 0;
    _currentPitcherWalks = 0;
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 7; j++) {
            scoreboard[i][j] = 0;
        }
    }
}

-(void)newHalfInning
{
    if (!_isTopOfInning && _inning <= 6) {
        _inning++;
    }
    _strikes = 0;
    _outs = 0;
    _balls = 0;
    _isTopOfInning = !_isTopOfInning;
    _currentPitcherWalks = 0;
}

-(void)newInning
{
    //_inning++;
    _strikes = 0;
    _outs = 0;
    _balls = 0;
    _currentPitcherWalks = 0;
}

-(void)newBatter
{
    _strikes = 0;
    _balls = 0;
}

-(void)gameStateHasChanged
{
    if (_strikes == 3) {
        _outs += 1;
        [self newBatter];
    }
    if (_balls == 4) {
        [self newBatter];
        _currentPitcherWalks++;
    }
    if (_outs == 3) {
        [self newHalfInning];
    }
}

-(NSString *)getScore:(int)inningHalf :(int)inning
{
    return [NSString stringWithFormat:@"%d", scoreboard[inningHalf][inning-1]];
}

-(void)setScore:(int)inningHalf :(int)inning:(int)score
{
    scoreboard[inningHalf][inning-1] = score;
    for (int j=0; j<2; j++) {
        scoreboard[j][6] = 0;
        for (int i=0; i<6; i++) {
            scoreboard[j][6] += scoreboard[j][i];
        }
    }
}

@end
