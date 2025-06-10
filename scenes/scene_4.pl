% scenes/scene_4.pl - The fourth scene of the game

% --- Room Definitions ---
room(hallway, 'You are in the hallway in front of the meeting room. The meeting room door is in front of you.', []).

% --- Room Intro Text ---
room_intro_text(hallway, [
    'Just in time, you have fixed the compiler and the demo programm.',
    'You get up, pack your things, and hurry to the Pentagon as fast as you can.',
    ' ',
    '1 HOUR LATER',
    ' ',
    'You are now standing in the hallway in front of the meeting room. The meeting room door is in front of you.'
]).

print_intro_text(Room) :-
    room_intro_text(Room, Lines),
    forall(member(Line, Lines), (write(Line), nl)).

:- discontiguous(handle_scene4_command/1).

% --- Scene Reset Logic ---
scene_reset.

% --- Look Command ---
handle_scene4_command(look) :-
    room(hallway, Desc, _),
    write(Desc), nl.

handle_scene4_command(look(door)) :-
    forall(member(Line, [
        'You listen at the door. You hear people talking inside.',
        'Some voices sound skeptical:',
        '  "Do you really think this new language will work?"',
        '  "She''s just a woman, can she really deliver?"',
        '  "I''m not convinced this is the right direction."',
        'You steel yourself for the challenge ahead.'
    ]), (write(Line), nl)).

% --- Use Door Command (enter meeting room) ---
handle_scene4_command(use(door)) :-
    write('You take a deep breath, open the door, and step into the meeting room.'), nl,
    change_scene(5).

% --- Help Command ---
handle_scene4_command(help) :-
    forall(member(Line, [
        'Available commands:',
        '  look.           -- look at your current location',
        '  look(door).     -- listen to the people inside the meeting room',
        '  use(door).      -- enter the meeting room',
        '  help.           -- show this help',
        '  quit.           -- quit the game'
    ]), (write(Line), nl)).
