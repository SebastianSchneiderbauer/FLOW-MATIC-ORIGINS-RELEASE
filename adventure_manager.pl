% --- Prolog Text Adventure Engine ---
% Refactored for single-scene, room-based navigation
% See HTML guide for best practices

:- dynamic(player/2). % player(Name, Location)
:- dynamic(has/2).
:- dynamic(item_at/2).
:- dynamic(unlocked_object/1).
:- dynamic(shown_scene_text/1).
:- dynamic(current_scene/1).

:- discontiguous(room/3).
:- discontiguous(room_intro_text/2).
:- discontiguous(scene_reset/0).
:- discontiguous(room_transition/2).
:- discontiguous(handle_command/1).
:- discontiguous(handle_command_generic/1).
:- discontiguous(print_items/1).

% --- Room Definitions ---
:- include('scenes/scene_1.pl').


% --- Splash Screen ---
splash :-
    write('========================================='), nl,
    write('          FLOW-MATIC: ORIGINS'), nl,
    write('========================================='), nl,
    write('  Welcome to the Prolog Text Adventure!'), nl,
    write(''), nl,
    write('Type start. to begin your journey.'), nl,
    write('NOTE: Only enter valid Prolog commands (e.g., look., help., use(pc).).'), nl,
    write('Typing random text or numbers will cause a Prolog syntax error.'), nl,
    write('> '),
    splash_loop.

splash_loop :-
    read(Input),
    ( Input == start -> start ;
      write('Please type start. to begin the game.'), nl, write('> '),
      splash_loop
    ).

% --- Entry Point ---
:- initialization(splash).

% --- Game Start ---
start :-
    retractall(player(_,_)),
    retractall(has(_,_)),
    scene_reset, % Call scene-specific reset logic
    retractall(shown_scene_text(_)),
    asserta(player('Grace Hopper', office)), 
    ( room_intro_text(office, _) ->
        print_intro_text(office),
        asserta(shown_scene_text(office))
    ; true ),
    write('Type help. for a list of commands.'), nl,
    game_loop.

% --- Helper: Show Room Description for Current Player Location ---
show_current_room_desc :-
    player(_, Location),
    ( room(Location, Desc, _) -> write(Desc), nl ; write('You see nothing special.'), nl ).

% --- Game Loop ---
game_loop :-
    repeat,
    write('> '),
    read(Command),
    ( Command == end_of_file -> !, fail
    ; catch(handle_command(Command), E, (write('Error: '), write(E), nl, fail)) ->
        (Command == quit -> ! ; true)
      ; write('Unknown command. Try "help."'), nl, fail
    ),
    (Command == quit -> true ; fail).

% --- Command Dispatcher for Scene-Specific Commands ---
handle_command(Command) :-
    current_scene(scene_2),
    !,
    ( catch(handle_scene2_command(Command), _, fail) -> true ; handle_command_generic(Command) ).

handle_command(Command) :-
    current_scene(scene_3),
    !,
    ( catch(handle_scene3_command(Command), _, fail) -> true ; handle_command_generic(Command) ).

handle_command(Command) :-
    current_scene(scene_4),
    !,
    ( catch(handle_scene4_command(Command), _, fail) -> true ; handle_command_generic(Command) ).

handle_command(Command) :-
    current_scene(scene_5),
    !,
    ( catch(handle_scene5_command(Command), _, fail) -> true ; handle_command_generic(Command) ).

handle_command(Command) :-
    handle_command_generic(Command).

handle_command_generic(start) :-
    write('Game already started.'), nl.
handle_command_generic(look) :-
    show_current_room_desc.
handle_command_generic(inventory) :-
    player(Name, _),
    findall(Item, has(Name, Item), Items),
    ( Items == [] -> write('Your inventory is empty.'), nl
    ; write('You are carrying:'), nl,
      print_items(Items)
    ).
print_items([]).
print_items([I|T]) :- write('  - '), write(I), nl, print_items(T).
handle_command_generic(take(Item)) :-
    player(Name, Location),
    ( item_at(Item, Location) ->
        asserta(has(Name, Item)),
        retract(item_at(Item, Location)),
        write('You take the '), write(Item), write('.'), nl
    ; write('There is no '), write(Item), write(' here.'), nl
    ).
handle_command_generic(help) :-
    write('Available commands:'), nl,
    write('  look.           -- look at your current room'), nl,
    write('  look(Object).   -- examine an object more closely'), nl,
    write('  use(Object).    -- use or interact with an object'), nl,
    write('  inventory.      -- show your inventory'), nl,
    write('  help.           -- show this help'), nl,
    write('  quit.           -- quit the game'), nl.
handle_command_generic(quit) :-
    write('Thanks for playing!'), nl.
handle_command_generic(look(Object)) :-
    player(_, Location),
    object(Object, Location, locked, _, _),
    ( unlocked_object(Object) ->
        write('The '), write(Object), write(' is unlocked.'), nl
    ; write('The '), write(Object), write(' is locked.'), nl
    ), !.
handle_command_generic(look(_)) :-
    player(_, Location),
    object(_, Location, unlocked, _, _),
    write('The object is unlocked.'), nl, !.
handle_command_generic(look(_)) :-
    write('There is no such thing here.'), nl, !.
handle_command_generic(use(Object)) :-
    handle_generic_use(Object).
handle_command_generic(Command) :-
    write('Unknown command: '), write(Command), write('. Try "help."'), nl.

% --- Command Handlers ---
handle_command(start) :-
    write('Game already started.'), nl.
handle_command(look) :-
    show_current_room_desc.
handle_command(inventory) :-
    player(Name, _),
    findall(Item, has(Name, Item), Items),
    ( Items == [] -> write('Your inventory is empty.'), nl
    ; write('You are carrying:'), nl,
      print_items(Items)
    ).
print_items([]).
print_items([I|T]) :- write('  - '), write(I), nl, print_items(T).
handle_command(take(Item)) :-
    player(Name, Location),
    ( item_at(Item, Location) ->
        asserta(has(Name, Item)),
        retract(item_at(Item, Location)),
        write('You take the '), write(Item), write('.'), nl
    ; write('There is no '), write(Item), write(' here.'), nl
    ).
% Fixed missing period in the help command handler
handle_command(help) :-
    write('Available commands:'), nl,
    write('  look.           -- look at your current room'), nl,
    write('  look(Object).   -- examine an object more closely'), nl,
    write('  use(Object).    -- use or interact with an object'), nl,
    write('  inventory.      -- show your inventory'), nl,
    write('  help.           -- show this help'), nl,
    write('  quit.           -- quit the game'), nl.
handle_command(quit) :-
    write('Thanks for playing!'), nl.
% --- Debugging for room_transition/2 ---
handle_command(look(Object)) :-
    player(_, Location),
    object(Object, Location, locked, _, _),
    ( unlocked_object(Object) ->
        write('The '), write(Object), write(' is unlocked.'), nl
    ; write('The '), write(Object), write(' is locked.'), nl
    ), !.
handle_command(look(_)) :-
    player(_, Location),
    object(_, Location, unlocked, _, _),
    write('The object is unlocked.'), nl, !.
handle_command(look(_)) :-
    write('There is no such thing here.'), nl, !.

% --- Use Command Enhancement ---
handle_generic_use(Object) :-
    player(Name, Location),
    object(Object, Location, locked, Item, UnlockText, _),
    has(Name, Item),
    ( unlocked_object(Object) ->
        write('The '), write(Object), write(' is already unlocked.'), nl
    ; asserta(unlocked_object(Object)),
      ( is_list(UnlockText) -> forall(member(Line, UnlockText), (write(Line), nl)) ; write(UnlockText), nl ),
      % Handle scene transitions
      ( Object == pc -> change_scene(2)
      ; Object == terminal -> change_scene(3)
      ; true )
    ), !.

handle_generic_use(Object) :-
    player(Name, Location),
    object(Object, Location, locked, Item, _, AfterText),
    \+ has(Name, Item),
    write('The '), write(Object), write(' is locked.'), nl,
    ( AfterText \= '' -> write(AfterText), nl ; true ), !.

handle_generic_use(Object) :-
    player(_, Location),
    object(Object, Location, unlocked, _, UnlockText, _),
    write(UnlockText), nl, !.

handle_generic_use(_Item) :-
    write('You cannot use that here.'), nl, !.

% --- Command Dispatcher for Scene-Specific Commands ---
handle_command(Command) :-
    current_scene(scene_2),
    !,
    ( handle_scene2_command(Command) -> true ; handle_command_fallback(Command) ).

handle_command(Command) :-
    current_scene(scene_3),
    !,
    ( handle_scene3_command(Command) -> true ; handle_command_fallback(Command) ).

handle_command(use(Object)) :-
    handle_generic_use(Object).

handle_command(Command) :-
    handle_command_fallback(Command).

handle_command_fallback(Command) :-
    write('Unknown command: '), write(Command), write('. Try "help."'), nl.

% --- Scene 2 Command Handler ---
handle_scene2_command(Command) :-
    ( predicate_property(handle_command(Command), defined) ->
        handle_command(Command)
    ; write('Unknown command: '), write(Command), write('. Try "help."'), nl
    ).

% --- Scene 3 Command Handler ---
handle_scene3_command(Command) :-
    ( predicate_property(handle_command(Command), defined) ->
        handle_command(Command)
    ; write('Unknown command: '), write(Command), write('. Try "help."'), nl
    ).

% --- Default Command Handler ---
handle_command(Command) :-
    write('Unknown command: '), write(Command), write('. Try "help."'), nl.

% --- Default Definition for blocks_transition/3 ---
% Ensures no transitions are blocked unless explicitly defined
blocks_transition(_, _, _) :- fail.


% --- Change Scene ---
change_scene(2) :-
    retractall(player(_, _)),
    retractall(has(_, _)),
    retractall(item_at(_, _)),
    retractall(unlocked_object(_)),
    retractall(shown_scene_text(_)),
    retractall(current_scene(_)),
    asserta(current_scene(scene_2)),
    consult('scenes/scene_2.pl'), % Ensure the new scene is loaded
    scene_reset,
    asserta(player('Grace Hopper', pc)),
    ( room_intro_text(pc, _) ->
        print_intro_text(pc),
        asserta(shown_scene_text(pc))
    ; true ).

change_scene(3) :-
    retractall(player(_, _)),
    retractall(has(_, _)),
    retractall(item_at(_, _)),
    retractall(unlocked_object(_)),
    retractall(shown_scene_text(_)),
    retractall(current_scene(_)),
    asserta(current_scene(scene_3)),
    consult('scenes/scene_3.pl'), % Ensure the new scene is loaded
    scene_reset,
    asserta(player('Grace Hopper', terminal)),
    ( room_intro_text(terminal, _) ->
        print_intro_text(terminal),
        asserta(shown_scene_text(terminal))
    ; true ),
    show_current_room_desc.

change_scene(4) :-
    retractall(player(_, _)),
    retractall(has(_, _)),
    retractall(item_at(_, _)),
    retractall(unlocked_object(_)),
    retractall(shown_scene_text(_)),
    retractall(current_scene(_)),
    asserta(current_scene(scene_4)),
    consult('scenes/scene_4.pl'),
    scene_reset,
    asserta(player('Grace Hopper', hallway)),
    ( room_intro_text(hallway, _) ->
        print_intro_text(hallway),
        asserta(shown_scene_text(hallway))
    ; true ).

change_scene(5) :-
    retractall(player(_, _)),
    retractall(has(_, _)),
    retractall(item_at(_, _)),
    retractall(unlocked_object(_)),
    retractall(shown_scene_text(_)),
    retractall(current_scene(_)),
    asserta(current_scene(scene_5)),
    consult('scenes/scene_5.pl'),
    scene_reset,
    asserta(player('Grace Hopper', meeting_room)),
    ( room_intro_text(meeting_room, _) ->
        print_intro_text(meeting_room),
        asserta(shown_scene_text(meeting_room))
    ; true ).