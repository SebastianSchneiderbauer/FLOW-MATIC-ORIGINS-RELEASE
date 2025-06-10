% scenes/scene_3.pl - The third scene of the game

% --- Scene Description ---
% This scene represents the final stage where Grace Hopper demonstrates her compiler to colleagues and must fix a demo program.

% --- Room Definitions ---
room(terminal, 'You are at your computer, the analyzer is on the computer in front of you, and a paper printout of symbolic code and logs and your notebook is on the desk.', []).

% --- Room Intro Text ---
room_intro_text(terminal, [
    'This demo program is really important, as it will help convince the pentagon.',
    'However, its returning faulty machine instructions, so its time to investigate!',
    'An analyzer program is running on your computer, and you have the code as well as its output printed on a piece of paper. Your Notebook with important information also lies there.'
]).

print_intro_text(Room) :-
    room_intro_text(Room, Lines),
    forall(member(Line, Lines), (write(Line), nl)).

% --- Discontiguous Directive ---
:- discontiguous(handle_scene3_command/1).
:- dynamic(analyzer_state/2). % analyzer_state(FixedLines, Remaining)

% --- Scene Reset Logic ---
scene_reset :-
    write('After successfully fixing the compiler bugs, you are now ready to fix the demo program.'), nl,
    retractall(analyzer_state(_, _)),
    asserta(analyzer_state([], [1,4])).

% --- Interact Command for Scene 3 ---
handle_scene3_command(interact(terminal)) :-
    write('You are already working at the terminal.'), nl.

% --- Look Commands ---
handle_scene3_command(look(notebook)) :-
    forall(member(Line, [
        'Notebook: BASIC CODE SYNTAX',
        '  LOAD <var>   -- Load variable',
        '  ADD <num>    -- Add number',
        '  STORE <var>  -- Store variable',
        '  MULT <var>   -- Multiply by variable',
        '  JUMP <label> -- Jump to label',
        '  Variables must be defined before use.',
        '  Only LOAD, ADD, STORE, MULT, JUMP are valid commands.'
    ]), (write(Line), nl)).

handle_scene3_command(look(paper)) :-
    forall(member(Line, [
        'You see the symbolic code:',
        '  1. LOADX A',
        '  2. ADD 0005',
        '  3. STORE A',
        '  4. MULT B',
        '  5. JUMP END',
        'and the log:',
        '  Line 1 -> ERROR -- Unknown command LOADX',
        '  Line 2 -> WARNING -- Numeric operand 0005 normalized to 5',
        '  Line 3 -> OK',
        '  Line 4 -> ERROR -- Variable \'B\' is not defined',
        '  Line 5 -> OK'
    ]), (write(Line), nl)).

handle_scene3_command(look(analyzer)) :-
    forall(member(Line, [
        'The analyzer is ready to check and fix the demo code.',
        'Use \'use(analyzer).\' to begin.'
    ]), (write(Line), nl)).

% --- Use Analyzer Command (starts minigame) ---
handle_scene3_command(use(analyzer)) :-
    analyzer_state(Fixed, Remaining),
    ( Remaining == [] ->
        write('You found out the cause of each error, what allowed you to fix the demo program. Congratulations!'), nl
    ; write('Analyzer: Please enter fix(LineNumber, \'NewContent\'). to fix a line.'), nl
    ).

% --- Minigame Fix Command ---
handle_scene3_command(fix(Line, Content)) :-
    analyzer_state(Fixed, Remaining),
    ( member(Line, Fixed) ->
        write('You have already fixed this line.'), nl
    ; member(Line, Remaining) ->
        correct_fix(Line, Content) ->
            select(Line, Remaining, NewRemaining),
            NewFixed = [Line|Fixed],
            retract(analyzer_state(Fixed, Remaining)),
            asserta(analyzer_state(NewFixed, NewRemaining)),
            write('Correct! Line '), write(Line), write(' fixed.'), nl,
            ( NewRemaining == [] ->
                write('You found out the cause of each error, what allowed you to fix the demo program. Congratulations!'), nl,
                change_scene(4)
            ; true
            )
        ; write('That is not the correct fix for line '), write(Line), write('. Try again.'), nl
    ; write('Line '), write(Line), write(' does not need fixing.'), nl
    ).

% --- Correct Fixes for Each Line ---
correct_fix(1, 'LOAD A').
correct_fix(4, 'MULT A').

handle_scene3_command(help) :-
    forall(member(Line, [
        'Available commands:',
        '  look.           -- look at your current room',
        '  look(Object).   -- examine an object more closely',
        '  use(Object).    -- use or interact with an object',
        '  inventory.      -- show your inventory',
        '  help.           -- show this help',
        '  interact(terminal). -- interact with the terminal',
        '  fix(Line,Content). -- fix a line in the demo program',
        '  quit.           -- quit the game'
    ]), (write(Line), nl)).
