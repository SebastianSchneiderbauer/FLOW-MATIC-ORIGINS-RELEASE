% scenes/scene_1.pl - The first scene of the game

% --- Scene Description ---
% This scene represents the players initial experience in the game. It includes the office with a PC and drawer.

% --- Room Definitions ---
room(office, 'You are in your office, behind your desk. The PC is on top of the desk. There is a drawer in your desk.', []).

% --- Room Intro Text ---
room_intro_text(office, [
    'You wake up in your office, behind your desk.',
    'It seems you have written code all night, a necessary evil.',
    'You have a Pentagon Meeting today, where you have to pitch your new programming language.',
    'The whole night you worked on getting the compiler to work, as well as a demo project.',
    'You will need to verify the compiler and demo program are working.'
]).

print_intro_text(Room) :-
    room_intro_text(Room, Lines),
    forall(member(Line, Lines), (write(Line), nl)).

% --- Objects/Locks ---
object(drawer, office, unlocked, none, [
    'You open the drawer and find your notebook.',
    'You pick it up.'
], '').
object(pc, office, locked, notebook, [
    'You use the notebook to access the PC.',
    'You now prepare to verify if your code works.'
], 'You need your notebook with a password and important code notes to access the PC.').

% --- Look Command Override for Drawer ---
handle_command(look(drawer)) :-
    player(Name, office),
    ( has(Name, notebook) ->
        forall(member(Line, [
            'You see your desk drawer.',
            'You already took the notebook from it.'
        ]), (write(Line), nl))
    ; forall(member(Line, [
        'You open the drawer on your desk and find your important notebook.',
        'You must have put it there just before you fell asleep.',
        'You take it.'
      ]), (write(Line), nl)),
      asserta(has(Name, notebook))
    ).

handle_command(look(pc)) :-
    write('You cannot look at that.'), nl.

handle_command(use(drawer)) :-
    write('You cannot use that.'), nl.

handle_command(use(pc)) :-
    player(Name, office),
    ( has(Name, notebook) ->
        forall(member(Line, [
            'You use the notebook to access the PC.',
            'You now prepare to verify if your code works.'
        ]), (write(Line), nl)),
        change_scene(2)
    ; write('You need your notebook with a password and important code notes to access the PC.'), nl
    ).

% --- Scene Reset Logic ---
scene_reset :-
    retractall(unlocked_object(pc)),
    retractall(has(_, notebook)).