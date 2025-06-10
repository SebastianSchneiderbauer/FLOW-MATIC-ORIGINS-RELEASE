% scenes/scene_2.pl - The second scene of the game

% --- Scene Description ---
% This scene represents a minigame on the PC. For now, it simply prints a placeholder message.

% --- Room Definitions ---
room(pc, 'You are at your desk, looking at the code on your PC screen. The compiler needs debugging.', []).

% --- Room Intro Text ---
room_intro_text(pc, [
    'Maybe looking which lines/collums match between the error messages could help.'
]).

print_intro_text(Room) :-
    room_intro_text(Room, Lines),
    forall(member(Line, Lines), (write(Line), nl)).

% --- Discontiguous Directive ---
:- discontiguous(handle_scene2_command/1).

% --- Dynamic Predicate for Current Errors ---
:- dynamic(current_errors/4).

% --- Scene Reset Logic ---
scene_reset :-
    write('You are now working on debugging your compiler. 2 Errors will be presented, each having multiple possible points of origin.'), nl,
    random_combination(Error1, Error2, Line, Col),
    retractall(current_errors(_, _, _, _)),
    asserta(current_errors(Error1, Error2, Line, Col)),
    write('Errors: '), write(Error1), write(' and '), write(Error2), nl,
    write('Hint: Check your notebook (\'use(notebook).\') for the correct line and column to fix (\'solve(Line,Col).\') these errors.'), nl.

% --- Interact Command for Scene 2 ---
handle_scene2_command(interact(pc)) :-
    write('You are already working on the PC.').

% --- Command to Read Notebook ---
handle_scene2_command(use(notebook)) :-
    forall(member(Line, [
        'Notebook Contents:',
        '  - Error Code: ERR-001',
        '    - Meaning: You might have a typo in your code.',
        '    - Possible Code Lines: [145, 684]',
        '    - Possible Columns: [10, 45]',
        '',
        '  - Error Code: ERR-002',
        '    - Meaning: A variable is not initialized.',
        '    - Possible Code Lines: [49, 145]',
        '    - Possible Columns: [23, 10]',
        '',
        '  - Error Code: ERR-003',
        '    - Meaning: A loop is not terminating.',
        '    - Possible Code Lines: [684, 49]',
        '    - Possible Columns: [45, 23]',
        '',
        '  - Error Code: ERR-004',
        '    - Meaning: A function is missing a return statement.',
        '    - Possible Code Lines: [145, 49]',
        '    - Possible Columns: [10, 23]',
        '',
        '  - Error Code: ERR-005',
        '    - Meaning: An instruction is not recognized by the compiler.',
        '    - Possible Code Lines: [684, 145]',
        '    - Possible Columns: [45, 10]',
        '',
        '  - Error Code: ERR-006',
        '    - Meaning: A label is missing in the assembly code.',
        '    - Possible Code Lines: [49, 684]',
        '    - Possible Columns: [23, 45]',
        ''
    ]), (write(Line), nl)).

% --- Command to Show Help ---
handle_scene2_command(help) :-
    forall(member(Line, [
        'Available commands:',
        '  look.           -- look at your current room',
        '  look(Object).   -- examine an object more closely',
        '  use(Object).    -- use or interact with an object',
        '  inventory.      -- show your inventory',
        '  help.           -- show this help',
        '  solve(Line,Col).-- attempt to fix the errors',
        '  use(notebook).  -- read your notebook',
        '  quit.           -- quit the game'
    ]), (write(Line), nl)).

% --- Error Definitions ---
% error(ErrorCode, Meaning, [Lines], [Cols])
error('ERR-001', 'You might have a typo in your code.', [145, 684], [10, 45]).
error('ERR-002', 'A variable is not initialized.', [49, 145], [23, 10]).
error('ERR-003', 'A loop is not terminating.', [684, 49], [45, 23]).
error('ERR-004', 'A function is missing a return statement.', [145, 49], [10, 23]).
error('ERR-005', 'An instruction is not recognized by the compiler.', [684, 145], [45, 10]).
error('ERR-006', 'A label is missing in the assembly code.', [49, 684], [23, 45]).

% --- Error Combinations ---
% combination(Error1, Error2, Line, Col)
combination('ERR-001', 'ERR-002', 145, 10).
combination('ERR-001', 'ERR-003', 684, 45).
combination('ERR-002', 'ERR-004', 49, 23).
combination('ERR-003', 'ERR-005', 684, 45).
combination('ERR-004', 'ERR-006', 49, 23).
combination('ERR-001', 'ERR-006', 145, 45).

% --- Random Combination Generator ---
random_combination(Error1, Error2, Line, Col) :-
    findall((E1, E2, L, C), combination(E1, E2, L, C), Combinations),
    random_member((Error1, Error2, Line, Col), Combinations).

% --- Custom Random Member Implementation ---
random_member(Element, List) :-
    length(List, Length),
    random(0, Length, Index),
    nth0(Index, List, Element).

% --- Notebook Content ---
% notebook_entry(ErrorCode, Meaning, [Lines], [Cols])
notebook_entry('ERR-001', 'You might have a typo in your code.', [145, 684], [10, 45]).
notebook_entry('ERR-002', 'A variable is not initialized.', [49, 145], [23, 10]).
notebook_entry('ERR-003', 'A loop is not terminating.', [684, 49], [45, 23]).
notebook_entry('ERR-004', 'A function is missing a return statement.', [145, 49], [10, 23]).
notebook_entry('ERR-005', 'An instruction is not recognized by the compiler.', [684, 145], [45, 10]).
notebook_entry('ERR-006', 'A label is missing in the assembly code.', [49, 684], [23, 45]).

% --- Minigame Logic ---
:- dynamic(minigame/1).
minigame(0).

% --- Command to Solve Errors ---
handle_scene2_command(solve(Line,Col)) :-
    minigame(Attempts),
    current_errors(Error1, Error2, CorrectLine, CorrectCol),
    ( Attempts < 3 ->
        ( Line == CorrectLine, Col == CorrectCol ->
            NewAttempts is Attempts + 1,
            retract(minigame(Attempts)),
            asserta(minigame(NewAttempts)),
            write('Correct! You fixed the errors.'), nl,
            ( NewAttempts == 3 ->
                write('Congratulations! You have successfully fixed all errors in the compiler!'), nl,
                retract(minigame(NewAttempts)),
                retractall(current_errors(_, _, _, _)),
                change_scene(3)
            ; random_combination(NewError1, NewError2, NewLine, NewCol),
              retractall(current_errors(_, _, _, _)),
              asserta(current_errors(NewError1, NewError2, NewLine, NewCol)),
              write('Errors: '), write(NewError1), write(' and '), write(NewError2), nl
            )
        ; write('You have tried the wrong fix and the errors have multiplied. You feel forced to restart'), nl,
          retract(minigame(Attempts)),
          asserta(minigame(0)),
          random_combination(NewError1, NewError2, NewLine, NewCol),
          retractall(current_errors(_, _, _, _)),
          asserta(current_errors(NewError1, NewError2, NewLine, NewCol)),
          write('Errors: '), write(NewError1), write(' and '), write(NewError2), nl
        )
    ; write('You have already completed the minigame!'), nl
    ).